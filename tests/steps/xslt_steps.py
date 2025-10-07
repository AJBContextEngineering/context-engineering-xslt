"""
BDD step definitions for XSLT field mapping tests.
Uses saxonche for XSLT 3.0 transformation and lxml for XML validation.
"""

import os
from behave import given, when, then
from saxonche import PySaxonProcessor
from lxml import etree


@given('the XSLT transformation file exists at "{xslt_path}"')
def step_verify_xslt_exists(context, xslt_path):
    """
    Verify that the XSLT transformation file exists.

    Args:
        context: Behave context object
        xslt_path (str): Path to XSLT file
    """
    assert os.path.exists(xslt_path), f"XSLT file not found at {xslt_path}"
    context.xslt_path = xslt_path


@given('a source DELVRY07 IDoc document at "{source_path}"')
def step_load_source_idoc(context, source_path):
    """
    Load the source IDoc XML document.

    Args:
        context: Behave context object
        source_path (str): Path to source XML file
    """
    assert os.path.exists(source_path), f"Source file not found at {source_path}"
    context.source_path = source_path

    # Load and verify it's valid XML
    with open(source_path, 'r', encoding='utf-8') as f:
        context.source_xml = f.read()

    # Parse to ensure valid XML
    try:
        etree.fromstring(context.source_xml.encode('utf-8'))
    except etree.XMLSyntaxError as e:
        raise AssertionError(f"Source XML is not valid: {e}")


@when('the XSLT transformation is applied')
def step_apply_xslt(context):
    """
    Apply the XSLT transformation using saxonche.

    Args:
        context: Behave context object
    """
    # Reason: Use saxonche PySaxonProcessor for XSLT 3.0 support
    try:
        with PySaxonProcessor(license=False) as proc:
            # Create XSLT 3.0 processor
            xslt_proc = proc.new_xslt30_processor()

            # Compile the stylesheet
            executable = xslt_proc.compile_stylesheet(stylesheet_file=context.xslt_path)

            # Transform the source XML
            context.output_xml = executable.transform_to_string(source_file=context.source_path)

            # Parse output for later validation
            context.output_doc = etree.fromstring(context.output_xml.encode('utf-8'))

    except Exception as e:
        raise AssertionError(f"XSLT transformation failed: {e}")


@then('the output should contain element "{element}" with value "{value}"')
def step_verify_element_value(context, element, value):
    """
    Verify that an element exists with a specific value.

    Args:
        context: Behave context object
        element (str): Element name to find
        value (str): Expected value
    """
    # Reason: Use .// to search anywhere in the document tree
    result = context.output_doc.xpath(f'.//{element}/text()')

    assert len(result) > 0, f"Element '{element}' not found in output XML"
    assert result[0] == value, f"Element '{element}' expected value '{value}', got '{result[0]}'"


@then('the {element} element should be under {path}')
def step_verify_element_path(context, element, path):
    """
    Verify that an element exists under a specific path.

    Args:
        context: Behave context object
        element (str): Element name to find
        path (str): XPath path (simplified notation)
    """
    # Convert simplified path notation to XPath
    xpath = f'.//{path}/{element}'
    result = context.output_doc.xpath(xpath)

    assert len(result) > 0, f"Element '{element}' not found under path '{path}'"


@then('the output should not contain element "{element}"')
def step_verify_element_absent(context, element):
    """
    Verify that an element does NOT exist in the output.

    Args:
        context: Behave context object
        element (str): Element name that should not exist
    """
    result = context.output_doc.xpath(f'.//{element}')

    assert len(result) == 0, f"Element '{element}' should not exist but was found in output"


@then('the output should still contain element "{element}"')
def step_verify_element_exists(context, element):
    """
    Verify that an element exists (for edge case scenarios).

    Args:
        context: Behave context object
        element (str): Element name to find
    """
    result = context.output_doc.xpath(f'.//{element}')

    assert len(result) > 0, f"Element '{element}' should exist but was not found in output"


@then('the output should be valid XML')
def step_verify_valid_xml(context):
    """
    Verify that the output is valid, well-formed XML.

    Args:
        context: Behave context object
    """
    try:
        # Already parsed in the when step, but verify again
        doc = etree.fromstring(context.output_xml.encode('utf-8'))
        assert doc is not None, "Output XML parsing returned None"
    except etree.XMLSyntaxError as e:
        raise AssertionError(f"Output is not valid XML: {e}")


@then('the output should contain all required elements:')
def step_verify_all_elements(context):
    """
    Verify multiple elements with their values from a table.

    Args:
        context: Behave context object with table data
    """
    # Reason: Iterate through table rows to check each element
    for row in context.table:
        element = row['Element']
        expected_value = row['Value']

        result = context.output_doc.xpath(f'.//{element}/text()')

        assert len(result) > 0, f"Element '{element}' not found in output XML"
        assert result[0] == expected_value, \
            f"Element '{element}' expected value '{expected_value}', got '{result[0]}'"


@then('the output should have root element "{root_name}"')
def step_verify_root_element(context, root_name):
    """
    Verify the root element name.

    Args:
        context: Behave context object
        root_name (str): Expected root element name
    """
    actual_root = context.output_doc.tag

    assert actual_root == root_name, \
        f"Root element expected '{root_name}', got '{actual_root}'"


@then('the output should contain element "{element}"')
def step_verify_element_present(context, element):
    """
    Verify that an element exists in the output.

    Args:
        context: Behave context object
        element (str): Element name to find
    """
    result = context.output_doc.xpath(f'.//{element}')

    assert len(result) > 0, f"Element '{element}' not found in output XML"
