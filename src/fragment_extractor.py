"""
XSD Fragment Extractor Module

Extracts XSD fragments with dependency resolution for XPath queries.
"""

from lxml import etree
from pydantic import BaseModel, Field
from typing import List, Set, Optional, Tuple, Dict
import re

XSD_NAMESPACE = "http://www.w3.org/2001/XMLSchema"
NSMAP = {"xs": XSD_NAMESPACE}

# Module-level variable to store all schemas for cross-schema lookups
_all_schemas: Dict[str, etree._ElementTree] = {}

# CRITICAL: Built-in XSD types should NOT be extracted
BUILTIN_TYPES = {
    "string",
    "int",
    "integer",
    "decimal",
    "boolean",
    "date",
    "dateTime",
    "time",
    "duration",
    "anyURI",
    "base64Binary",
    "float",
    "double",
    "long",
    "short",
    "byte",
    "nonNegativeInteger",
    "positiveInteger",
    "negativeInteger",
    "nonPositiveInteger",
    "unsignedLong",
    "unsignedInt",
    "unsignedShort",
    "unsignedByte",
    "normalizedString",
    "token",
    "language",
    "NMTOKEN",
    "NMTOKENS",
    "Name",
    "NCName",
    "ID",
    "IDREF",
    "IDREFS",
    "ENTITY",
    "ENTITIES",
    "hexBinary",
    "QName",
    "NOTATION",
    "gYear",
    "gYearMonth",
    "gMonth",
    "gMonthDay",
    "gDay",
}


class XSDFragment(BaseModel):
    """Represents a single XSD fragment (element or type definition)"""

    xml_content: str = Field(description="The XML text of the XSD fragment")
    name: str = Field(description="The name of the element/type")
    node_type: str = Field(description="element, simpleType, or complexType")


class FragmentExtractionResult(BaseModel):
    """Result of XSD fragment extraction"""

    fragments: List[XSDFragment]
    warnings: List[str] = Field(default_factory=list)


def set_all_schemas(schemas: Dict[str, etree._ElementTree]) -> None:
    """
    Set all loaded schemas for cross-schema lookups.

    Args:
        schemas: Dict mapping filename to parsed ElementTree
    """
    global _all_schemas
    _all_schemas = schemas


def extract_fragments(
    xpath: str, schema_tree: etree._ElementTree
) -> FragmentExtractionResult:
    """
    Extract XSD fragments based on XPath query.

    Args:
        xpath: XPath expression using local-name() pattern
        schema_tree: Parsed XSD schema

    Returns:
        FragmentExtractionResult with fragments and warnings
    """
    # PATTERN: Parse XPath to extract all element names in path
    element_path = _parse_element_path_from_xpath(xpath)

    if not element_path:
        return FragmentExtractionResult(
            fragments=[], warnings=["Could not parse XPath expression"]
        )

    # Follow the XPath to find the correct element in context
    # Reason: Multiple elements can have the same name; context matters
    element_node = _find_element_in_path(element_path, schema_tree)

    if element_node is None:
        element_name = element_path[-1]
        return FragmentExtractionResult(
            fragments=[], warnings=[f"Element '{element_name}' not found in schema"]
        )

    # Collect fragments with dependency resolution
    fragments = []
    visited: Set[str] = set()
    warnings = []

    # Add element definition itself
    elem_fragment = _element_to_fragment(element_node)
    fragments.append(elem_fragment)

    # Get type attribute and resolve dependencies
    type_attr = element_node.get("type")
    if type_attr:
        # GOTCHA: Remove namespace prefix if present
        type_name = _strip_namespace_prefix(type_attr)

        if not is_builtin_type(type_name):
            type_fragments, type_warnings = collect_type_dependencies(
                type_name, schema_tree, visited
            )
            fragments.extend(type_fragments)
            warnings.extend(type_warnings)

    return FragmentExtractionResult(fragments=fragments, warnings=warnings)


def find_element_by_name(
    element_name: str, schema_tree: etree._ElementTree
) -> Optional[etree._Element]:
    """
    Find xs:element with matching name attribute.

    Searches first in the specified schema, then across all loaded schemas.

    Args:
        element_name: Name of element to find
        schema_tree: Parsed XSD schema (primary search location)

    Returns:
        Element node or None
    """
    # CRITICAL: Use XPath with namespace
    xpath_query = f"//xs:element[@name='{element_name}']"

    # First search in the primary schema
    results = schema_tree.xpath(xpath_query, namespaces=NSMAP)
    if results:
        return results[0]

    # If not found, search across all loaded schemas
    # Reason: XSD includes mean elements can be defined in other files
    for schema in _all_schemas.values():
        results = schema.xpath(xpath_query, namespaces=NSMAP)
        if results:
            return results[0]

    return None


def collect_type_dependencies(
    type_name: str, schema_tree: etree._ElementTree, visited: Set[str]
) -> Tuple[List[XSDFragment], List[str]]:
    """
    Recursively collect type definition and its dependencies.

    Args:
        type_name: Name of type to collect
        schema_tree: Parsed XSD schema
        visited: Set of already-visited type names (prevents cycles)

    Returns:
        Tuple of (fragments, warnings)
    """
    # CRITICAL: Prevent infinite loops with circular dependencies
    if type_name in visited:
        return ([], [])

    visited.add(type_name)
    fragments = []
    warnings = []

    # Find simpleType or complexType definition
    type_node = _find_type_definition(type_name, schema_tree)

    if type_node is None:
        warnings.append(f"Type '{type_name}' not found in schema")
        return (fragments, warnings)

    # Add the type definition itself
    fragments.append(_element_to_fragment(type_node))

    # Check for restriction base
    restriction = type_node.find(".//xs:restriction", namespaces=NSMAP)
    if restriction is not None:
        base_type = restriction.get("base")
        if base_type:
            base_name = _strip_namespace_prefix(base_type)
            if not is_builtin_type(base_name):
                base_frags, base_warns = collect_type_dependencies(
                    base_name, schema_tree, visited
                )
                fragments.extend(base_frags)
                warnings.extend(base_warns)

    # Check for extension base
    extension = type_node.find(".//xs:extension", namespaces=NSMAP)
    if extension is not None:
        base_type = extension.get("base")
        if base_type:
            base_name = _strip_namespace_prefix(base_type)
            if not is_builtin_type(base_name):
                base_frags, base_warns = collect_type_dependencies(
                    base_name, schema_tree, visited
                )
                fragments.extend(base_frags)
                warnings.extend(base_warns)

    return (fragments, warnings)


def is_builtin_type(type_name: str) -> bool:
    """
    Check if type is XSD built-in.

    Args:
        type_name: Type name to check

    Returns:
        True if type is built-in XSD type
    """
    # Remove 'xs:' or 'xsd:' prefix if present
    clean_name = _strip_namespace_prefix(type_name)
    return clean_name in BUILTIN_TYPES


def _strip_namespace_prefix(name: str) -> str:
    """
    Remove namespace prefix from type name.

    Args:
        name: Type name potentially with prefix

    Returns:
        Type name without prefix
    """
    # PATTERN: Handle 'xs:string' -> 'string'
    if ":" in name:
        return name.split(":", 1)[1]
    return name


def _parse_element_name_from_xpath(xpath: str) -> str:
    """
    Extract final element name from XPath query.

    Args:
        xpath: XPath like /*[local-name()='Part']/*[local-name()='Id']

    Returns:
        Element name (e.g., 'Id')
    """
    # PATTERN: Match local-name()='ElementName' patterns
    # Get the LAST occurrence for the final element
    matches = re.findall(r"local-name\(\s*\)\s*=\s*['\"]([^'\"]+)['\"]", xpath)

    if matches:
        return matches[-1]

    # Fallback: simple path like /Part/Id
    parts = xpath.strip("/").split("/")
    return parts[-1] if parts else ""


def _parse_element_path_from_xpath(xpath: str) -> List[str]:
    """
    Extract all element names from XPath query in order.

    Args:
        xpath: XPath like /*[local-name()='Part']/*[local-name()='PartId']/*[local-name()='Id']

    Returns:
        List of element names (e.g., ['Part', 'PartId', 'Id'])
    """
    # PATTERN: Match local-name()='ElementName' patterns
    matches = re.findall(r"local-name\(\s*\)\s*=\s*['\"]([^'\"]+)['\"]", xpath)

    if matches:
        return matches

    # Fallback: simple path like /Part/Id
    parts = xpath.strip("/").split("/")
    return [p for p in parts if p]


def _find_element_in_path(
    element_path: List[str], schema_tree: etree._ElementTree
) -> Optional[etree._Element]:
    """
    Find an element by following the path structure.

    Traverses the XSD schema following the element path to find the correct
    element in the proper context.

    Args:
        element_path: List of element names in order
        schema_tree: Parsed XSD schema

    Returns:
        Element node or None
    """
    if not element_path:
        return None

    # Start by finding the first element in the path
    current_element = find_element_by_name(element_path[0], schema_tree)

    if current_element is None:
        return None

    # If path has only one element, we're done
    if len(element_path) == 1:
        return current_element

    # Follow the path through type definitions
    for next_element_name in element_path[1:]:
        # Get the type of the current element
        type_attr = current_element.get("type")

        if not type_attr:
            # No type attribute, can't continue
            return None

        type_name = _strip_namespace_prefix(type_attr)

        # Find the type definition
        type_node = _find_type_definition(type_name, schema_tree)

        if type_node is None:
            # Type not found, can't continue
            return None

        # Search for the next element within this type definition
        xpath_query = f".//xs:element[@name='{next_element_name}']"
        results = type_node.xpath(xpath_query, namespaces=NSMAP)

        if not results:
            # Element not found in this type, return None
            return None

        current_element = results[0]

    return current_element


def _element_to_fragment(element: etree._Element) -> XSDFragment:
    """
    Convert lxml element to XSDFragment model.

    Args:
        element: lxml Element to convert

    Returns:
        XSDFragment instance
    """
    # PATTERN: Use etree.tostring() with pretty_print
    xml_str = etree.tostring(element, encoding="unicode", pretty_print=True).strip()

    name = element.get("name", "unknown")
    node_type = element.tag.split("}")[-1]  # Remove namespace

    return XSDFragment(xml_content=xml_str, name=name, node_type=node_type)


def _find_type_definition(
    type_name: str, schema_tree: etree._ElementTree
) -> Optional[etree._Element]:
    """
    Find simpleType or complexType by name.

    Searches first in the specified schema, then across all loaded schemas.

    Args:
        type_name: Name of type to find
        schema_tree: Parsed XSD schema (primary search location)

    Returns:
        Element node or None
    """
    # Try simpleType in primary schema
    xpath_query = f"//xs:simpleType[@name='{type_name}']"
    results = schema_tree.xpath(xpath_query, namespaces=NSMAP)
    if results:
        return results[0]

    # Try complexType in primary schema
    xpath_query = f"//xs:complexType[@name='{type_name}']"
    results = schema_tree.xpath(xpath_query, namespaces=NSMAP)
    if results:
        return results[0]

    # If not found, search across all loaded schemas
    # Reason: XSD includes mean types can be defined in other files
    for schema in _all_schemas.values():
        # Try simpleType
        xpath_query = f"//xs:simpleType[@name='{type_name}']"
        results = schema.xpath(xpath_query, namespaces=NSMAP)
        if results:
            return results[0]

        # Try complexType
        xpath_query = f"//xs:complexType[@name='{type_name}']"
        results = schema.xpath(xpath_query, namespaces=NSMAP)
        if results:
            return results[0]

    return None
