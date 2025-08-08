"""
BDD Step Definitions for XSLT Field Mappings

This module provides step definitions for testing XSLT transformations
using the behave BDD framework and SaxonHE processor.
"""

from behave import given, when, then
from saxonche import PySaxonProcessor
from lxml import etree
import os
from pathlib import Path

# Configure paths
TEST_ROOT = Path(__file__).parent.parent
PROJECT_ROOT = TEST_ROOT.parent
XSL_FILE = PROJECT_ROOT / "src" / "mapping.xsl"
TEST_DATA_DIR = TEST_ROOT / "test_data"

@given('I have a source XML document')
def step_source_xml_document(context):
    """Load the source XML document for transformation."""
    source_file = TEST_DATA_DIR / "source_sample.xml"
    
    if not source_file.exists():
        raise FileNotFoundError(f"Source XML not found: {source_file}")
    
    # Store source XML path in context for transformation
    context.source_xml_path = str(source_file)

@given('I have source XML with "{element}" value "{value}"')
def step_source_xml_with_element(context, element, value):
    """Verify source XML contains specific element with expected value."""
    source_file = TEST_DATA_DIR / "source_sample.xml"
    
    # Parse and verify the source XML contains expected element/value
    with open(source_file, 'r', encoding='utf-8') as f:
        xml_content = f.read()
    
    root = etree.fromstring(xml_content.encode('utf-8'))
    
    # Find element by name and verify value
    elements = root.xpath(f"//{element}")
    if not elements:
        raise ValueError(f"Element '{element}' not found in source XML")
    
    found_value = elements[0].text
    if found_value != value:
        raise ValueError(f"Expected '{element}' to have value '{value}', but found '{found_value}'")
    
    context.source_xml_path = str(source_file)
    context.expected_element = element
    context.expected_value = value

@given('I have source XML with partner "{partner_code}" and name "{name}"')
def step_source_xml_with_partner(context, partner_code, name):
    """Verify source XML contains partner element with expected attributes and name."""
    source_file = TEST_DATA_DIR / "source_sample.xml"
    
    # Parse and verify the source XML contains expected partner
    with open(source_file, 'r', encoding='utf-8') as f:
        xml_content = f.read()
    
    root = etree.fromstring(xml_content.encode('utf-8'))
    
    # Find E1ADRM1 element with specific PARTNER_Q attribute
    partner_elements = root.xpath(f"//E1ADRM1[@PARTNER_Q='{partner_code}']")
    if not partner_elements:
        raise ValueError(f"Partner element with PARTNER_Q='{partner_code}' not found")
    
    # Verify NAME1 child element
    name_element = partner_elements[0].find('NAME1')
    if name_element is None or name_element.text != name:
        raise ValueError(f"Expected partner '{partner_code}' to have NAME1='{name}'")
    
    context.source_xml_path = str(source_file)
    context.partner_code = partner_code
    context.partner_name = name

@when('I apply the XSLT transformation')
def step_apply_xslt_transformation(context):
    """Apply XSLT transformation using SaxonHE processor."""
    if not hasattr(context, 'source_xml_path'):
        raise ValueError("No source XML path set in context")
    
    if not XSL_FILE.exists():
        raise FileNotFoundError(f"XSLT file not found: {XSL_FILE}")
    
    try:
        # Initialize SaxonHE processor for XSLT 3.0
        proc = PySaxonProcessor(license=False)
        xslt_proc = proc.new_xslt30_processor()
        
        # Compile stylesheet for performance
        executable = xslt_proc.compile_stylesheet(stylesheet_file=str(XSL_FILE))
        
        # Transform XML document
        result = executable.transform_to_string(source_file=context.source_xml_path)
        
        # Store result in context for verification
        context.transformation_result = result
        
        # Also parse result as XML tree for XPath queries
        context.result_tree = etree.fromstring(result.encode('utf-8'))
        
    except Exception as e:
        # Store error for debugging
        context.transformation_error = str(e)
        raise RuntimeError(f"XSLT transformation failed: {e}")

@then('the output should contain element "{xpath}" with value "{expected}"')
def step_verify_element_value(context, xpath, expected):
    """Verify transformation output contains element with expected value."""
    if not hasattr(context, 'result_tree'):
        raise ValueError("No transformation result available")
    
    try:
        # Find elements matching XPath
        elements = context.result_tree.xpath(xpath)
        
        if not elements:
            # Get actual output for debugging
            actual_output = etree.tostring(context.result_tree, pretty_print=True, encoding='unicode')
            raise AssertionError(f"XPath '{xpath}' found no elements.\nActual output:\n{actual_output}")
        
        # Get text content of first matching element
        actual_value = elements[0].text
        
        if actual_value != expected:
            raise AssertionError(f"Expected element at '{xpath}' to have value '{expected}', but got '{actual_value}'")
            
    except Exception as e:
        # Provide detailed error information
        actual_output = etree.tostring(context.result_tree, pretty_print=True, encoding='unicode')
        raise AssertionError(f"Element verification failed: {e}\nActual output:\n{actual_output}")

@then('the output should be valid XML')
def step_verify_valid_xml(context):
    """Verify that transformation result is valid XML."""
    if not hasattr(context, 'transformation_result'):
        raise ValueError("No transformation result available")
    
    try:
        # Attempt to parse the result as XML
        etree.fromstring(context.transformation_result.encode('utf-8'))
    except etree.XMLSyntaxError as e:
        raise AssertionError(f"Transformation result is not valid XML: {e}")

@then('the output should contain comments explaining each mapping')
def step_verify_comments(context):
    """Verify that output contains explanatory comments."""
    if not hasattr(context, 'transformation_result'):
        raise ValueError("No transformation result available")
    
    # Check for expected comment patterns
    expected_comments = [
        "Feature #1:",
        "Feature #2:", 
        "Feature #3:",
        "Feature #4:"
    ]
    
    missing_comments = []
    for comment in expected_comments:
        if comment not in context.transformation_result:
            missing_comments.append(comment)
    
    if missing_comments:
        raise AssertionError(f"Missing expected comments: {missing_comments}")