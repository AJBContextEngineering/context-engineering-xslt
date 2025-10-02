"""
BDD Step Definitions for XSD Fragment Extraction

Implements Gherkin steps for testing XSD fragment extraction functionality.
"""

from behave import given, when, then
from src.schema_loader import load_all_schemas, get_schema
from src.fragment_extractor import extract_fragments, set_all_schemas


@given('the XSD schemas are loaded from "{directory}" directory')
def step_load_schemas_from_directory(context, directory):
    """
    Load all XSD schemas from the specified directory.

    Args:
        context: Behave context object
        directory: Directory path containing XSD files
    """
    context.schemas = load_all_schemas(directory)
    assert len(context.schemas) > 0, f"No schemas loaded from {directory}"
    # Set schemas for cross-schema lookups
    set_all_schemas(context.schemas)


@given('the schema "{schema_file}" is available')
def step_schema_is_available(context, schema_file):
    """
    Verify that a specific schema file is loaded.

    Args:
        context: Behave context object
        schema_file: Name of schema file to verify
    """
    schema = get_schema(schema_file)
    assert schema is not None, f"Schema {schema_file} not loaded"


@when('I query with XPath "{xpath}"')
def step_query_with_xpath(context, xpath):
    """
    Store XPath query for later use.

    Args:
        context: Behave context object
        xpath: XPath expression to query
    """
    context.xpath = xpath


@when('schema file "{schema_file}"')
def step_use_schema_file(context, schema_file):
    """
    Execute fragment extraction with stored XPath and specified schema.

    Args:
        context: Behave context object
        schema_file: Name of schema file to query
    """
    schema = get_schema(schema_file)

    if schema is None:
        # Store error message for missing schema
        context.result = (
            f"<!-- ERROR: Schema file '{schema_file}' not found or failed to load -->"
        )
    else:
        # Extract fragments
        extraction_result = extract_fragments(context.xpath, schema)

        # Format output similar to tools.py
        output_lines = []

        if extraction_result.warnings:
            output_lines.append("<!-- WARNINGS:")
            for warning in extraction_result.warnings:
                output_lines.append(f"  - {warning}")
            output_lines.append("-->")
            output_lines.append("")

        for fragment in extraction_result.fragments:
            output_lines.append(fragment.xml_content)
            output_lines.append("")

        context.result = "\n".join(output_lines)


@then('the result should contain an element definition for "{element_name}"')
def step_result_contains_element_definition(context, element_name):
    """
    Verify result contains element definition with specified name.

    Args:
        context: Behave context object
        element_name: Name of element to find
    """
    assert context.result is not None, "No result stored"
    assert (
        f"<xs:element" in context.result and f'name="{element_name}"' in context.result
    ), f"Element definition for '{element_name}' not found in result"


@then('the result should contain a type definition for "{type_name}"')
def step_result_contains_type_definition(context, type_name):
    """
    Verify result contains type definition with specified name.

    Args:
        context: Behave context object
        type_name: Name of type to find
    """
    assert context.result is not None, "No result stored"
    # Check for either simpleType or complexType with flexible matching
    # (namespace declarations can appear between tag and name attribute)
    has_simple = (
        "<xs:simpleType" in context.result and f'name="{type_name}"' in context.result
    )
    has_complex = (
        "<xs:complexType" in context.result and f'name="{type_name}"' in context.result
    )
    assert has_simple or has_complex, (
        f"Type definition for '{type_name}' not found in result"
    )


@then("the type definition should have a restriction base")
def step_type_has_restriction_base(context):
    """
    Verify result contains xs:restriction element.

    Args:
        context: Behave context object
    """
    assert context.result is not None, "No result stored"
    assert "<xs:restriction base=" in context.result, (
        "No restriction base found in type definition"
    )


@then("the result should contain an error message")
def step_result_contains_error(context):
    """
    Verify result contains an error message.

    Args:
        context: Behave context object
    """
    assert context.result is not None, "No result stored"
    assert "<!-- ERROR:" in context.result, "No error message found in result"


@then('the error should mention "{text}"')
def step_error_mentions_text(context, text):
    """
    Verify error message contains specific text.

    Args:
        context: Behave context object
        text: Text to find in error message
    """
    assert context.result is not None, "No result stored"
    assert text in context.result, f"Error message does not mention '{text}'"


@then("the result should contain a warning")
def step_result_contains_warning(context):
    """
    Verify result contains a warning.

    Args:
        context: Behave context object
    """
    assert context.result is not None, "No result stored"
    assert "<!-- WARNINGS:" in context.result, "No warning found in result"


@then('the warning should mention "{text}"')
def step_warning_mentions_text(context, text):
    """
    Verify warning message contains specific text.

    Args:
        context: Behave context object
        text: Text to find in warning message
    """
    assert context.result is not None, "No result stored"
    assert text in context.result, f"Warning message does not mention '{text}'"
