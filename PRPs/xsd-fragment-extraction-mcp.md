name: "XSD Fragment Extraction MCP Server"
description: |

## Purpose
Build a FastMCP server that extracts relevant XSD schema fragments based on XPath queries, including all dependent type definitions to provide complete schema context.

## Core Principles
1. **Context is King**: Include ALL necessary documentation, examples, and caveats
2. **Validation Loops**: Provide executable tests/lints the AI can run and fix
3. **Information Dense**: Use keywords and patterns from the codebase
4. **Progressive Success**: Start simple, validate, then enhance
5. **Global rules**: Be sure to follow all rules in CLAUDE.md

---

## Goal
Create an MCP server using FastMCP2 that:
- Loads XSD schema files from the `/xsd` folder once at startup
- Accepts an XPath query and schema filename
- Returns the relevant XSD fragment(s) that validate elements/attributes selected by the XPath
- Includes ALL dependent type definitions (restrictions, extensions, base types) for complete context

## Why
- **LLM Context Optimization**: LLMs need complete schema definitions to understand XML validation rules, but full XSD files are too large
- **Dependency Resolution**: XSD types reference other types in complex chains - missing one breaks the context
- **Reusability**: Loading schemas once improves performance for repeated queries
- **Integration**: MCP servers enable Claude and other LLMs to access this functionality as a tool

## What
An MCP server with a single tool `retrieve-xsd-fragments` that extracts minimal, complete XSD subsets.

### Success Criteria
- [x] MCP server starts and loads XSD schemas from `/xsd` folder
- [x] Tool accepts XPath string and schema filename, returns XSD fragments
- [x] All type dependencies are recursively collected and returned
- [x] XSD includes (schemaLocation) are followed and resolved
- [x] Built-in XSD types (xs:string, xs:dateTime) are not extracted
- [x] Missing dependencies are handled gracefully with warnings
- [x] BDD tests pass for simple and complex element queries
- [x] Tool docstring clearly explains usage for LLM consumption

## All Needed Context

### Documentation & References
```yaml
# FastMCP2 Framework
- url: https://gofastmcp.com/
  why: Official FastMCP 2.0 documentation for MCP server patterns
  critical: |
    - Use @mcp.tool decorator for tool functions
    - Server initialization: mcp = FastMCP("name")
    - Run with mcp.run()
    - Type hints required for all parameters

- url: https://www.datacamp.com/tutorial/building-mcp-server-client-fastmcp
  why: Tutorial showing complete FastMCP server implementation
  section: Server setup and tool definition patterns

# XSD Processing with lxml
- url: https://lxml.de/validation.html
  why: Understanding lxml's XSD validation capabilities
  critical: lxml parses XSD files as XML documents, not as schemas

- url: https://stackoverflow.com/questions/42395979/i-want-to-be-able-to-walk-a-nested-xsd-using-lxml-from-python-3
  why: Patterns for traversing XSD files with lxml
  section: Using XPath to navigate XSD element and type definitions

# XPath and XSD
- url: https://www.w3schools.com/xml/xpath_syntax.asp
  why: XPath syntax reference for parsing user queries

# Example Files
- file: examples/example_input_output.md
  why: Shows expected input XPath and output XSD fragments
  critical: Output must include element definition AND type definition with base types

- file: xsd/PartSync_0100.xsd
  why: Main schema file showing structure and includes
  pattern: xs:include schemaLocation pattern for dependencies

- file: xsd/Element.xsd
  why: Shows simpleType and complexType definitions with restrictions
  pattern: xs:restriction base="typename" pattern

- file: xsd/Segment.xsd
  why: Shows complexType with xs:extension base pattern
```

### Current Codebase Tree
```bash
context-engineering-xsd-mcp/
├── .claude/
│   ├── commands/
│   │   ├── generate-prp.md
│   │   └── execute-prp.md
│   └── settings.local.json
├── PRPs/
│   ├── templates/
│   │   └── prp_base.md
│   └── xsd-fragment-extraction-mcp.md  # This PRP
├── examples/
│   └── example_input_output.md
├── xsd/
│   ├── PartSync_0100.xsd
│   ├── Segment.xsd
│   └── Element.xsd
├── tests/
│   └── features/                       # BDD feature files
├── CLAUDE.md                           # Project rules
├── INITIAL.md                          # Feature requirements
├── pyproject.toml                      # Dependencies
└── README.md
```

### Desired Codebase Tree
```bash
context-engineering-xsd-mcp/
├── src/
│   ├── __init__.py
│   ├── server.py           # FastMCP server entry point
│   ├── tools.py            # retrieve_xsd_fragments tool
│   ├── schema_loader.py    # XSD schema loading and parsing
│   └── fragment_extractor.py  # Core XSD fragment extraction logic
├── tests/
│   ├── features/
│   │   └── xsd_fragment_extraction.feature  # BDD scenarios
│   └── steps/
│       └── xsd_steps.py    # Step definitions for behave
├── .env.example            # Environment variables template
└── (existing files remain)
```

### Known Gotchas & Library Quirks
```python
# CRITICAL: lxml does NOT automatically resolve XSD includes
# You must manually parse included files and combine them
# Pattern: Parse main XSD, find xs:include elements, load those files

# CRITICAL: XSD namespace handling
XSD_NAMESPACE = "http://www.w3.org/2001/XMLSchema"
NSMAP = {'xs': XSD_NAMESPACE}
# Use namespace in XPath: tree.xpath('//xs:simpleType', namespaces=NSMAP)

# CRITICAL: XPath from user input uses local-name() and namespace-uri()
# These are namespace-agnostic XPaths, but XSD navigation uses prefixes
# Example user XPath:
#   /*[local-name()='PartSync']/*[local-name()='DataArea']/*[local-name()='Part']/*[local-name()='PartId']/*[local-name()='Id']
# Extract element name 'Id' and search XSD for xs:element[@name='Id']

# CRITICAL: Built-in XSD types should NOT be extracted
BUILTIN_TYPES = {'string', 'int', 'integer', 'decimal', 'boolean', 'date',
                  'dateTime', 'time', 'duration', 'anyURI', 'base64Binary'}
# Check if type starts with 'xs:' or is in BUILTIN_TYPES

# CRITICAL: FastMCP2 requires python-dotenv for environment variables
# Use load_dotenv() at the top of server.py

# CRITICAL: This codebase uses 'uv' package manager, not pip
# Use: uv add <package> to add dependencies
# Use: uv run <command> to run in virtual environment

# GOTCHA: Some XSD files reference ../DataTypes/DataTypes.xsd which doesn't exist
# Handle missing includes gracefully - log warning but continue

# GOTCHA: Circular dependencies are possible in XSD
# Use visited set to prevent infinite loops
```

## Implementation Blueprint

### Data Models and Structure
```python
# pydantic models for type safety

from pydantic import BaseModel, Field
from typing import List, Optional

class XSDFragment(BaseModel):
    """Represents a single XSD fragment (element or type definition)"""
    xml_content: str = Field(description="The XML text of the XSD fragment")
    name: str = Field(description="The name of the element/type")
    node_type: str = Field(description="element, simpleType, or complexType")

class FragmentExtractionResult(BaseModel):
    """Result of XSD fragment extraction"""
    fragments: List[XSDFragment]
    warnings: List[str] = Field(default_factory=list)

    def to_xml_string(self) -> str:
        """Format fragments as XML string for return to LLM"""
        # Join all fragment XML with proper formatting
        pass
```

### List of Tasks (in order)

```yaml
Task 1: Setup project dependencies
  ACTION: UPDATE pyproject.toml
  - ADD fastmcp>=2.0.0
  - ADD python-dotenv>=1.0.0
  - ENSURE lxml>=6.0.0 exists (already present)
  - ENSURE pydantic is available

Task 2: Create schema loader module
  CREATE: src/schema_loader.py
  RESPONSIBILITY: Load and parse all XSD files at startup
  PATTERN: Use lxml.etree.parse() to load XSD as XML
  INCLUDES:
    - load_all_schemas(schema_dir: str) -> Dict[str, etree._ElementTree]
    - get_schema(filename: str) -> Optional[etree._ElementTree]
    - resolve_includes(schema_tree, schema_dir) -> None

Task 3: Create fragment extractor module
  CREATE: src/fragment_extractor.py
  RESPONSIBILITY: Extract XSD fragments with dependencies
  PATTERN: Recursive traversal with visited set
  INCLUDES:
    - extract_fragments(xpath: str, schema_tree) -> FragmentExtractionResult
    - find_element_by_name(element_name: str, schema_tree) -> Optional[Element]
    - collect_type_dependencies(type_name: str, schema_tree, visited: set) -> List[XSDFragment]
    - is_builtin_type(type_name: str) -> bool
    - format_fragment(element: Element) -> XSDFragment

Task 4: Create MCP tools module
  CREATE: src/tools.py
  RESPONSIBILITY: Define MCP tool functions
  PATTERN: Use @mcp.tool decorator from FastMCP
  INCLUDES:
    - retrieve_xsd_fragments(xpath: str, schema_file: str) -> str
  CRITICAL: Tool name must be 'retrieve-xsd-fragments' via decorator
  CRITICAL: Detailed docstring for LLM understanding

Task 5: Create MCP server entry point
  CREATE: src/server.py
  RESPONSIBILITY: Initialize FastMCP server and load schemas at startup
  PATTERN: FastMCP initialization and tool registration
  INCLUDES:
    - Initialize FastMCP instance
    - Load schemas from xsd/ directory using schema_loader
    - Import and register tools from tools.py
    - mcp.run() to start server

Task 6: Create BDD feature tests
  CREATE: tests/features/xsd_fragment_extraction.feature
  RESPONSIBILITY: Define behavior scenarios in Gherkin
  SCENARIOS:
    - Simple element with simple type and base type
    - Complex element with multiple dependencies
    - Element with extension base type
    - Missing schema file handling
    - Invalid XPath handling

Task 7: Create BDD step definitions
  CREATE: tests/steps/xsd_steps.py
  RESPONSIBILITY: Implement test steps for behave
  PATTERN: Use behave context and step decorators
  INCLUDES:
    - Given I have loaded the XSD schema "filename"
    - When I query for XPath "xpath_string"
    - Then I should receive XSD fragments containing "element_name"
    - And the fragments should include type "type_name"

Task 8: Create environment configuration
  CREATE: .env.example
  CONTENT:
    XSD_SCHEMA_DIR=./xsd
    MCP_SERVER_NAME=XSD Fragment Extractor

Task 9: Run validation loop
  ACTION: Execute validation gates (see Validation Loop section)
  - Fix any linting/type errors
  - Fix any failing tests
  - Iterate until all validations pass
```

### Pseudocode for Key Components

```python
# Task 2: schema_loader.py
from lxml import etree
from pathlib import Path
from typing import Dict, Optional
import logging

XSD_NAMESPACE = "http://www.w3.org/2001/XMLSchema"
NSMAP = {'xs': XSD_NAMESPACE}

# Global schema storage
_schemas: Dict[str, etree._ElementTree] = {}

def load_all_schemas(schema_dir: str) -> Dict[str, etree._ElementTree]:
    """
    Load all XSD files from directory.

    Args:
        schema_dir: Path to directory containing XSD files

    Returns:
        Dict mapping filename to parsed ElementTree
    """
    # PATTERN: Use pathlib.Path for cross-platform paths
    schema_path = Path(schema_dir)

    # PATTERN: glob for all .xsd files
    for xsd_file in schema_path.glob("**/*.xsd"):
        try:
            tree = etree.parse(str(xsd_file))
            filename = xsd_file.name
            _schemas[filename] = tree
            logging.info(f"Loaded schema: {filename}")
        except Exception as e:
            # GOTCHA: Some XSD files may be malformed
            logging.warning(f"Failed to load {xsd_file}: {e}")

    return _schemas

def get_schema(filename: str) -> Optional[etree._ElementTree]:
    """Get loaded schema by filename"""
    return _schemas.get(filename)


# Task 3: fragment_extractor.py
from lxml import etree
from typing import List, Set, Optional, Tuple
import re

BUILTIN_TYPES = {
    'string', 'int', 'integer', 'decimal', 'boolean', 'date',
    'dateTime', 'time', 'duration', 'anyURI', 'base64Binary',
    'float', 'double', 'long', 'short', 'byte', 'nonNegativeInteger'
}

def extract_fragments(xpath: str, schema_tree: etree._ElementTree) -> FragmentExtractionResult:
    """
    Extract XSD fragments based on XPath query.

    Args:
        xpath: XPath expression using local-name() pattern
        schema_tree: Parsed XSD schema

    Returns:
        FragmentExtractionResult with fragments and warnings
    """
    # PATTERN: Parse XPath to extract final element name
    element_name = _parse_element_name_from_xpath(xpath)

    # Find element definition in schema
    element_node = find_element_by_name(element_name, schema_tree)

    if not element_node:
        return FragmentExtractionResult(
            fragments=[],
            warnings=[f"Element '{element_name}' not found in schema"]
        )

    # Collect fragments with dependency resolution
    fragments = []
    visited: Set[str] = set()
    warnings = []

    # Add element definition itself
    elem_fragment = _element_to_fragment(element_node)
    fragments.append(elem_fragment)

    # Get type attribute and resolve dependencies
    type_attr = element_node.get('type')
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

def find_element_by_name(element_name: str, schema_tree: etree._ElementTree) -> Optional[etree._Element]:
    """
    Find xs:element with matching name attribute.

    Args:
        element_name: Name of element to find
        schema_tree: Parsed XSD schema

    Returns:
        Element node or None
    """
    # CRITICAL: Use XPath with namespace
    xpath_query = f"//xs:element[@name='{element_name}']"
    results = schema_tree.xpath(xpath_query, namespaces=NSMAP)

    # Return first match or None
    return results[0] if results else None

def collect_type_dependencies(
    type_name: str,
    schema_tree: etree._ElementTree,
    visited: Set[str]
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

    if not type_node:
        warnings.append(f"Type '{type_name}' not found in schema")
        return (fragments, warnings)

    # Add the type definition itself
    fragments.append(_element_to_fragment(type_node))

    # Check for restriction base
    restriction = type_node.find('.//xs:restriction', namespaces=NSMAP)
    if restriction is not None:
        base_type = restriction.get('base')
        if base_type:
            base_name = _strip_namespace_prefix(base_type)
            if not is_builtin_type(base_name):
                base_frags, base_warns = collect_type_dependencies(
                    base_name, schema_tree, visited
                )
                fragments.extend(base_frags)
                warnings.extend(base_warns)

    # Check for extension base
    extension = type_node.find('.//xs:extension', namespaces=NSMAP)
    if extension is not None:
        base_type = extension.get('base')
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
    """Check if type is XSD built-in"""
    # Remove 'xs:' or 'xsd:' prefix if present
    clean_name = _strip_namespace_prefix(type_name)
    return clean_name in BUILTIN_TYPES

def _strip_namespace_prefix(name: str) -> str:
    """Remove namespace prefix from type name"""
    # PATTERN: Handle 'xs:string' -> 'string'
    if ':' in name:
        return name.split(':', 1)[1]
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
    parts = xpath.strip('/').split('/')
    return parts[-1] if parts else ''

def _element_to_fragment(element: etree._Element) -> XSDFragment:
    """Convert lxml element to XSDFragment model"""
    # PATTERN: Use etree.tostring() with pretty_print
    xml_str = etree.tostring(
        element,
        encoding='unicode',
        pretty_print=True
    ).strip()

    name = element.get('name', 'unknown')
    node_type = element.tag.split('}')[-1]  # Remove namespace

    return XSDFragment(
        xml_content=xml_str,
        name=name,
        node_type=node_type
    )

def _find_type_definition(type_name: str, schema_tree: etree._ElementTree) -> Optional[etree._Element]:
    """Find simpleType or complexType by name"""
    # Try simpleType
    xpath_query = f"//xs:simpleType[@name='{type_name}']"
    results = schema_tree.xpath(xpath_query, namespaces=NSMAP)
    if results:
        return results[0]

    # Try complexType
    xpath_query = f"//xs:complexType[@name='{type_name}']"
    results = schema_tree.xpath(xpath_query, namespaces=NSMAP)
    if results:
        return results[0]

    return None


# Task 4: tools.py
from fastmcp import FastMCP
from .schema_loader import get_schema
from .fragment_extractor import extract_fragments
import logging

# FastMCP instance will be passed in from server.py
def register_tools(mcp: FastMCP):
    """Register all MCP tools"""

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


# Task 5: server.py
from fastmcp import FastMCP
from dotenv import load_dotenv
import os
import logging
from .schema_loader import load_all_schemas
from .tools import register_tools

# CRITICAL: Load environment variables first
load_dotenv()

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)

# PATTERN: Get config from environment with defaults
XSD_SCHEMA_DIR = os.getenv('XSD_SCHEMA_DIR', './xsd')
MCP_SERVER_NAME = os.getenv('MCP_SERVER_NAME', 'XSD Fragment Extractor')

# Initialize FastMCP
mcp = FastMCP(MCP_SERVER_NAME)

# CRITICAL: Load schemas at startup, not on each request
# Reason: Performance - XSD parsing is expensive
logging.info(f"Loading XSD schemas from {XSD_SCHEMA_DIR}...")
schemas = load_all_schemas(XSD_SCHEMA_DIR)
logging.info(f"Loaded {len(schemas)} schemas")

# Register tools
register_tools(mcp)

if __name__ == "__main__":
    # PATTERN: FastMCP run() handles MCP protocol
    mcp.run()
```

### Integration Points
```yaml
ENVIRONMENT:
  - add: .env file (copy from .env.example)
  - variables:
      XSD_SCHEMA_DIR: ./xsd
      MCP_SERVER_NAME: XSD Fragment Extractor

DEPENDENCIES:
  - add to: pyproject.toml
  - packages:
      fastmcp: ">=2.0.0"
      python-dotenv: ">=1.0.0"
  - install: uv sync

TESTING:
  - framework: behave (already in dependencies)
  - config: behave.ini (if needed)
  - run: uv run behave tests/features/
```

## Validation Loop

### Level 1: Syntax & Style
```bash
# Run these FIRST - fix any errors before proceeding
uv run ruff check src/ --fix      # Auto-fix linting issues
uv run ruff format src/            # Format code

# Expected: No errors. If errors, READ the error and fix.
```

### Level 2: Unit Tests with Behave BDD
```gherkin
# File: tests/features/xsd_fragment_extraction.feature

Feature: XSD Fragment Extraction
  As an LLM using the MCP server
  I want to retrieve minimal XSD schema fragments for XPath queries
  So that I can understand XML validation rules without loading entire schemas

  Background:
    Given the XSD schemas are loaded from "xsd" directory
    And the schema "PartSync_0100.xsd" is available

  Scenario: Extract simple element with simple type
    When I query with XPath "/*[local-name()='PartSync']/*[local-name()='DataArea']/*[local-name()='Part']/*[local-name()='PartId']/*[local-name()='Id']"
    And schema file "PartSync_0100.xsd"
    Then the result should contain an element definition for "Id"
    And the result should contain a type definition for "PartId_0100"
    And the type definition should have a restriction base

  Scenario: Handle missing schema file
    When I query with XPath "/*[local-name()='Test']"
    And schema file "NonExistent.xsd"
    Then the result should contain an error message
    And the error should mention "not found"

  Scenario: Handle element not in schema
    When I query with XPath "/*[local-name()='NonExistentElement']"
    And schema file "PartSync_0100.xsd"
    Then the result should contain a warning
    And the warning should mention "not found in schema"
```

```bash
# Run and iterate until passing:
uv run behave tests/features/ -v

# If failing: Read error, understand root cause, fix code, re-run
# NEVER mock to pass tests - fix the actual implementation
```

### Level 3: Manual Integration Test
```bash
# Start the MCP server
uv run python -m src.server

# Test using MCP client or claude desktop
# Expected: Server starts, loads schemas, responds to tool calls

# Check logs for:
# - "Loading XSD schemas from ./xsd..."
# - "Loaded N schemas"
# - No errors during startup
```

## Final Validation Checklist
- [ ] All BDD tests pass: `uv run behave tests/features/ -v`
- [ ] No linting errors: `uv run ruff check src/`
- [ ] Code is formatted: `uv run ruff format src/`
- [ ] Server starts without errors: `uv run python -m src.server`
- [ ] Tool returns correct fragments for example XPath from examples/example_input_output.md
- [ ] Warnings are shown for missing dependencies
- [ ] Built-in XSD types (dateTime, string) are not extracted
- [ ] README.md is updated with usage instructions

---

## Anti-Patterns to Avoid
- ❌ Don't parse XSD files on every request - load once at startup
- ❌ Don't return incomplete type definitions - follow dependency chain
- ❌ Don't extract built-in XSD types (xs:string, xs:int, etc.)
- ❌ Don't fail silently on missing includes - log warnings
- ❌ Don't use string concatenation for XPath - use proper namespaces
- ❌ Don't ignore circular dependencies - use visited set
- ❌ Don't hardcode schema paths - use environment variables
- ❌ Don't skip docstrings - LLMs need them to understand tool usage

## Quality Score

**Confidence Level: 8/10**

**Rationale:**
- ✅ Comprehensive context with documentation URLs
- ✅ Clear implementation blueprint with pseudocode
- ✅ Executable validation gates with BDD tests
- ✅ Real examples from codebase
- ✅ Gotchas and anti-patterns documented
- ✅ Proper dependency resolution algorithm
- ⚠️ Moderate complexity in XSD parsing logic
- ⚠️ External XSD dependencies may not exist (handled with warnings)

**Areas of Risk:**
1. XPath parsing complexity - may need refinement for edge cases
2. Handling of XSD includes across directories - requires path resolution
3. Performance with large XSD schemas - may need optimization

**Mitigation:**
- Start with simple test cases and iterate
- Use BDD tests to validate each scenario
- Add logging throughout for debugging

This PRP should enable one-pass implementation with iterative refinement through the validation loop.
