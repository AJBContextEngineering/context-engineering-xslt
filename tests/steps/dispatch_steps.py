"""
Step definitions for DispatchSync XSLT mapping BDD tests
Uses saxonche for XSLT 3.0 transformation
"""
from behave import given, when, then
from saxonche import PySaxonProcessor
import re
from lxml import etree


@given('the XSLT mapping file "{xslt_file}"')
def load_xslt(context, xslt_file):
    """Load the XSLT mapping file for transformation"""
    context.xslt_file = xslt_file
    context.proc = PySaxonProcessor(license=False)
    context.xslt_proc = context.proc.new_xslt30_processor()


@given('the source file "{source_file}"')
def load_source(context, source_file):
    """Load the source XML file to be transformed"""
    with open(source_file, 'r', encoding='utf-8') as f:
        context.source_xml = f.read()


@when('I transform the source using the XSLT')
def transform(context):
    """Execute the XSLT transformation"""
    try:
        executable = context.xslt_proc.compile_stylesheet(
            stylesheet_file=context.xslt_file
        )
        document = context.proc.parse_xml(xml_text=context.source_xml)
        context.result = executable.transform_to_string(xdm_node=document)
        context.transformation_success = True
    except Exception as e:
        context.transformation_success = False
        context.transformation_error = str(e)
        raise


@then('the XPath "{xpath}" should equal "{expected}"')
def assert_xpath_equals(context, xpath, expected):
    """Assert that an XPath expression evaluates to an expected value"""
    result_doc = context.proc.parse_xml(xml_text=context.result)
    xpath_proc = context.proc.new_xpath_processor()
    xpath_proc.set_context(xdm_item=result_doc)
    xpath_proc.declare_namespace('ns0', 'http://www.consafelogistics.com/astro/project')

    # Use evaluate() to get XdmValue, then access first item
    value = xpath_proc.evaluate(xpath)
    if value is None or value.size == 0:
        actual = None
    else:
        item = value.item_at(0)
        # Try to get string_value attribute if available (for text nodes)
        if hasattr(item, 'string_value'):
            actual_str = item.string_value
        else:
            actual_str = str(item)

        # Handle attribute values that come back with name="value" format
        if '="' in actual_str and actual_str.endswith('"'):
            # Extract just the value part from attribute format
            actual = actual_str.split('="', 1)[1].rstrip('"')
        else:
            actual = actual_str

    assert actual == expected, f"XPath '{xpath}' expected '{expected}', but got '{actual}'"


@then('the XPath "{xpath}" should match pattern "{pattern}"')
def assert_xpath_matches_pattern(context, xpath, pattern):
    """Assert that an XPath expression matches a regex pattern"""
    result_doc = context.proc.parse_xml(xml_text=context.result)
    xpath_proc = context.proc.new_xpath_processor()
    xpath_proc.set_context(xdm_item=result_doc)
    xpath_proc.declare_namespace('ns0', 'http://www.consafelogistics.com/astro/project')

    value = xpath_proc.evaluate_single(xpath)
    actual = str(value) if value is not None else ""

    assert re.match(pattern, actual), f"XPath '{xpath}' value '{actual}' does not match pattern '{pattern}'"


@then('the element "{xpath}" should exist')
def assert_element_exists(context, xpath):
    """Assert that an element exists in the result"""
    result_doc = context.proc.parse_xml(xml_text=context.result)
    xpath_proc = context.proc.new_xpath_processor()
    xpath_proc.set_context(xdm_item=result_doc)
    xpath_proc.declare_namespace('ns0', 'http://www.consafelogistics.com/astro/project')

    result = xpath_proc.evaluate(xpath)
    count = 0
    if result:
        iterator = result
        for _ in iterator:
            count += 1

    assert count > 0, f"Element '{xpath}' does not exist in result"


@then('the element "{xpath}" should not exist')
def assert_element_not_exists(context, xpath):
    """Assert that an element does not exist in the result"""
    result_doc = context.proc.parse_xml(xml_text=context.result)
    xpath_proc = context.proc.new_xpath_processor()
    xpath_proc.set_context(xdm_item=result_doc)
    xpath_proc.declare_namespace('ns0', 'http://www.consafelogistics.com/astro/project')

    result = xpath_proc.evaluate(xpath)
    count = 0
    if result:
        iterator = result
        for _ in iterator:
            count += 1

    assert count == 0, f"Element '{xpath}' should not exist, but found {count} occurrence(s)"


@then('the element "{xpath}" should be empty')
def assert_element_empty(context, xpath):
    """Assert that an element has no text content or children"""
    result_doc = context.proc.parse_xml(xml_text=context.result)
    xpath_proc = context.proc.new_xpath_processor()
    xpath_proc.set_context(xdm_item=result_doc)
    xpath_proc.declare_namespace('ns0', 'http://www.consafelogistics.com/astro/project')

    # Use lxml for more detailed inspection
    tree = etree.fromstring(context.result.encode('utf-8'))
    namespaces = {'ns0': 'http://www.consafelogistics.com/astro/project'}
    elements = tree.xpath(xpath, namespaces=namespaces)

    assert len(elements) > 0, f"Element '{xpath}' does not exist"
    element = elements[0]

    # Check that element has no text and no children
    has_text = element.text is not None and element.text.strip() != ''
    has_children = len(element) > 0

    assert not has_text and not has_children, f"Element '{xpath}' is not empty"


@then('the transformation should succeed')
def assert_transformation_succeeded(context):
    """Assert that the transformation completed successfully"""
    assert context.transformation_success, f"Transformation failed: {getattr(context, 'transformation_error', 'Unknown error')}"


@then('the output should be valid XML')
def assert_valid_xml(context):
    """Assert that the transformation output is valid XML"""
    try:
        etree.fromstring(context.result.encode('utf-8'))
    except etree.XMLSyntaxError as e:
        raise AssertionError(f"Output is not valid XML: {e}")
