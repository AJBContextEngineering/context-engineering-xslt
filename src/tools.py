"""
MCP Tools Module

Defines MCP tool functions for XSD fragment extraction.
"""

from fastmcp import FastMCP
try:
    # Try relative imports first (when run as module)
    from .schema_loader import get_schema
    from .fragment_extractor import extract_fragments
except ImportError:
    # Fall back to absolute imports (when run directly)
    from schema_loader import get_schema
    from fragment_extractor import extract_fragments
import logging


def register_tools(mcp: FastMCP) -> None:
    """
    Register all MCP tools.

    Args:
        mcp: FastMCP instance to register tools with
    """

    @mcp.tool(name="retrieve-xsd-fragments")
    def retrieve_xsd_fragments(xpath: str, schema_file: str) -> str:
        """
        Retrieve relevant XSD schema fragments for a given XPath query.

        This tool extracts the minimal subset of an XSD schema needed to validate
        the XML elements/attributes selected by an XPath expression. It returns
        the element definition along with ALL dependent type definitions, including
        base types from restrictions and extensions.

        Args:
            xpath (str): XPath expression selecting an element in an XML document.
                        Example: /*[local-name()='PartSync']/*[local-name()='DataArea']/*[local-name()='Part']/*[local-name()='PartId']/*[local-name()='Id']
            schema_file (str): Name of the XSD schema file to query (e.g., 'PartSync_0100.xsd').
                              The file must exist in the configured XSD schema directory.

        Returns:
            str: Formatted XML string containing all relevant XSD fragments, including:
                 - The element definition
                 - The element's type definition (if not a built-in XSD type)
                 - All base types referenced through restrictions or extensions
                 - XML annotations and documentation from the schema

                 If warnings occur (e.g., missing dependencies), they are included
                 in XML comments at the top of the output.

        Example:
            Input:
                xpath = "/*[local-name()='Part']/*[local-name()='PartId']/*[local-name()='Id']"
                schema_file = "PartSync_0100.xsd"

            Output:
                <xs:element name="Id" type="PartId_0100"/>
                <xs:simpleType name="PartId_0100">
                  <xs:annotation>
                    <xs:documentation xml:lang="en">Part number.</xs:documentation>
                  </xs:annotation>
                  <xs:restriction base="string24"/>
                </xs:simpleType>
        """
        # Reason: Get schema from pre-loaded cache for performance
        schema_tree = get_schema(schema_file)

        if not schema_tree:
            return f"<!-- ERROR: Schema file '{schema_file}' not found or failed to load -->"

        try:
            # Extract fragments
            result = extract_fragments(xpath, schema_tree)

            # Format output
            output_lines = []

            # Add warnings as XML comments if any
            if result.warnings:
                output_lines.append("<!-- WARNINGS:")
                for warning in result.warnings:
                    output_lines.append(f"  - {warning}")
                output_lines.append("-->")
                output_lines.append("")

            # Add each fragment
            for fragment in result.fragments:
                output_lines.append(fragment.xml_content)
                output_lines.append("")  # Blank line between fragments

            return "\n".join(output_lines)

        except Exception as e:
            logging.error(f"Error extracting fragments: {e}", exc_info=True)
            return f"<!-- ERROR: {str(e)} -->"
