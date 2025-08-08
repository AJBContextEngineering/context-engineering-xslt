name: "XSLT Field Mappings Implementation with BDD Testing"
description: |

## Purpose
Implement XSLT 3.0 field mappings with comprehensive BDD testing using behave framework and SaxonHE Python processor to ensure each field mapping works correctly with both `<xsl:apply-templates>` and `<xsl:call-template>` patterns.

## Core Principles
1. **Context is King**: Include XSLT 3.0 patterns, SaxonHE integration, and BDD testing context
2. **Validation Loops**: Provide executable BDD tests and XSLT validation
3. **Information Dense**: Use existing XSLT patterns from codebase examples
4. **Progressive Success**: Start with basic mappings, validate, then enhance
5. **Global rules**: Follow all rules in CLAUDE.md

---

## Goal
Create an XSLT 3.0 mapping file that transforms source XML fields to target XML fields using proper `<xsl:apply-templates>` and `<xsl:call-template>` patterns, with comprehensive BDD tests for each mapping using Python behave framework and SaxonHE processor.

## Why
- **Field Mapping Accuracy**: Ensure each source field correctly maps to target field specification
- **Template Pattern Compliance**: Follow architectural patterns using `<xsl:apply-templates>` for field mappings and `<xsl:call-template>` for non-match dependent code
- **Testing Coverage**: Validate every field mapping and template call with BDD tests
- **XSLT 3.0 Compliance**: Use modern XSLT 3.0 features with proper Saxon processor

## What
Implement 4 specific field mappings in XSLT 3.0 with comprehensive BDD testing:

1. **Feature #1**: Fixed value '2' → `/PartSync/ControlArea/Sender/Confirmation`
2. **Feature #2**: `/DELVRY07/ZASTRO_DELVRY07/IDOC/E1EDL20/VBELN` → `/OrderSync/DataArea/Order/OrderHead/OrderHeadId/Id`
3. **Feature #3**: `/DELVRY07/ZASTRO_DELVRY07/IDOC/E1EDL20/E1EDL24/WERKS` → `/OrderSync/DataArea/Order/OrderHead/OrderHeadId/Division`
4. **Feature #4**: `/DELVRY07/ZASTRO_DELVRY07/IDOC/E1EDL20/E1ADRM1[PARTNER_Q='Y1']/NAME1` → `/OrderSync/DataArea/Order/OrderHead/OurReference`

### Success Criteria
- [ ] XSLT 3.0 file created with all 4 field mappings
- [ ] Each field mapping implemented using `<xsl:apply-templates>` where possible
- [ ] `<xsl:call-template>` used for non-source-dependent mappings (like fixed values)
- [ ] BDD tests created for each field mapping with behave framework
- [ ] All BDD tests pass using SaxonHE processor
- [ ] XSLT file includes comments explaining each template
- [ ] Test coverage for both successful mappings and edge cases

## All Needed Context

### Documentation & References
```yaml
# MUST READ - Include these in your context window
- url: https://www.saxonica.com/html/documentation12/xsl-elements/template.html
  why: Official Saxon XSLT 3.0 template documentation for proper syntax
  
- url: https://xsltdev.com/xslt/xsl-apply-templates/
  why: XSLT 3.0 apply-templates patterns and best practices
  
- url: https://pypi.org/project/saxonche/
  why: SaxonHE Python API documentation for XSLT processing
  critical: Use compile_stylesheet() method for XSLT 3.0 processing
  
- url: https://behave.readthedocs.io/
  why: Behave BDD framework documentation for test structure
  section: Step definitions with @given, @when, @then decorators
  
- file: examples/I405_ZRDA_V2.xsl
  why: Pattern to follow for apply-templates and value-of selections
  critical: Shows proper namespace handling and template structure
  
- file: examples/Z_I152_TELEMA_ORDER.xsl
  why: Complex template patterns with apply-templates and external functions
  critical: Demonstrates proper template organization and apply-templates usage

- docfile: CLAUDE.md
  why: Project architecture patterns and requirements
  critical: Use apply-templates wherever possible, create template for every source field mapping
```

### Current Codebase tree
```bash
context-engineering-xslt/
├── CLAUDE.md                    # Project instructions and architecture
├── INITIAL.md                  # Feature requirements (4 field mappings)
├── examples/                   # XSLT example files for patterns
│   ├── I403_Mapping.xsl       # Simple mapping patterns
│   ├── I405_ZRDA_V2.xsl       # Apply-templates patterns with namespaces
│   ├── I407_GoodsReceipt_AstroFI_ECC.xsl # Variable usage patterns
│   ├── Z_I149_TELEMA_INVOIC.xsl # Complex template matching
│   └── Z_I152_TELEMA_ORDER.xsl # Advanced apply-templates usage
├── main.py                     # Python entry point
├── pyproject.toml             # Python dependencies
└── PRPs/                      # Project Requirements Plans
    └── templates/
        └── prp_base.md
```

### Desired Codebase tree with files to be added
```bash
context-engineering-xslt/
├── src/
│   └── mapping.xsl            # Main XSLT 3.0 mapping file
├── tests/
│   ├── features/
│   │   └── field_mappings.feature # BDD feature file
│   ├── steps/
│   │   └── xslt_steps.py      # BDD step definitions
│   ├── test_data/
│   │   ├── source_sample.xml  # Sample source XML for testing
│   │   └── expected_output.xml # Expected transformation result
│   └── conftest.py           # Pytest/behave configuration
└── TASK.md                   # Task tracking file
```

### Known Gotchas of our codebase & Library Quirks
```python
# CRITICAL: SaxonHE requires specific initialization for XSLT 3.0
from saxonche import PySaxonProcessor
proc = PySaxonProcessor(license=False)  # HE version is free
xslt_proc = proc.new_xslt30_processor()  # Use XSLT 3.0 processor specifically

# CRITICAL: XSLT 3.0 template matching supports atomic values
# Can match string literals and numbers directly in addition to nodes

# CRITICAL: behave BDD requires context.user_data for sharing data between steps
# Use context.user_data["xml_result"] to pass transformation results

# CRITICAL: Apply-templates changes current node context, call-template does not
# Use apply-templates for source-dependent mappings, call-template for fixed values

# CRITICAL: Saxon requires compile_stylesheet() for performance
# Always compile stylesheet once, then execute multiple times for testing
```

## Implementation Blueprint

### Data models and structure

XSLT 3.0 templates structure following project architecture:
```xsl
<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:output method="xml" indent="yes"/>
  
  <!-- Root template -->
  <xsl:template match="/">
    <!-- Call template for fixed values -->
    <xsl:call-template name="generate-fixed-confirmation"/>
    <!-- Apply templates for source-dependent mappings -->
    <xsl:apply-templates select="DELVRY07/ZASTRO_DELVRY07/IDOC/E1EDL20"/>
  </xsl:template>
  
  <!-- Named template for fixed values -->
  <xsl:template name="generate-fixed-confirmation">
    <xsl:comment>Fixed value mapping using call-template</xsl:comment>
    <!-- Implementation here -->
  </xsl:template>
  
  <!-- Match templates for source field mappings -->
  <xsl:template match="E1EDL20">
    <xsl:comment>Source field mapping using apply-templates</xsl:comment>
    <!-- Implementation here -->
  </xsl:template>
</xsl:stylesheet>
```

### list of tasks to be completed to fulfill the PRP in the order they should be completed

```yaml
Task 1:
CREATE TASK.md:
  - ADD entry: "XSLT Field Mappings Implementation - [today's date]"
  - DESCRIBE: "Implement 4 XSLT field mappings with BDD tests using behave and SaxonHE"

Task 2:
CREATE src/mapping.xsl:
  - FOLLOW pattern from: examples/I405_ZRDA_V2.xsl for basic structure
  - USE XSLT 3.0 version declaration
  - INCLUDE proper XML output formatting with indent="yes"
  - ADD namespace declarations as needed for target XML structure

Task 3:
IMPLEMENT Template #1 - Fixed Value Mapping:
  - CREATE named template "generate-fixed-confirmation"
  - USE xsl:call-template pattern (not source-dependent)
  - MAP fixed value '2' to /PartSync/ControlArea/Sender/Confirmation
  - ADD xsl:comment explaining the mapping

Task 4:
IMPLEMENT Template #2 - VBELN Field Mapping:
  - CREATE match template for E1EDL20 element
  - USE xsl:apply-templates pattern with select="VBELN"
  - MAP to /OrderSync/DataArea/Order/OrderHead/OrderHeadId/Id
  - ADD xsl:comment explaining the source to target mapping

Task 5:
IMPLEMENT Template #3 - WERKS Field Mapping:
  - CREATE match template for E1EDL24 element  
  - USE xsl:apply-templates pattern with select="WERKS"
  - MAP to /OrderSync/DataArea/Order/OrderHead/OrderHeadId/Division
  - ADD xsl:comment explaining the division mapping

Task 6:
IMPLEMENT Template #4 - NAME1 with Predicate Mapping:
  - CREATE match template for E1ADRM1[PARTNER_Q='Y1'] element
  - USE xsl:apply-templates pattern with predicate matching
  - MAP NAME1 to /OrderSync/DataArea/Order/OrderHead/OurReference
  - ADD xsl:comment explaining the conditional partner mapping

Task 7:
CREATE test sample data:
  - CREATE tests/test_data/source_sample.xml with representative DELVRY07 structure
  - INCLUDE all source elements: VBELN, WERKS, and E1ADRM1 with PARTNER_Q='Y1'
  - CREATE tests/test_data/expected_output.xml with expected transformation result

Task 8:
SETUP BDD testing infrastructure:
  - CREATE tests/features/field_mappings.feature with Gherkin scenarios
  - CREATE tests/steps/xslt_steps.py with step definitions using SaxonHE
  - CREATE tests/conftest.py for pytest/behave configuration
  - FOLLOW pattern from behave documentation for context management

Task 9:
IMPLEMENT BDD Feature Scenarios:
  - CREATE scenario for each of the 4 field mappings
  - USE Given/When/Then structure for XML input/XSLT transform/output verification
  - INCLUDE edge case scenarios (missing elements, wrong partner codes)
  - VERIFY both apply-templates and call-template patterns work correctly

Task 10:
RUN comprehensive testing:
  - EXECUTE behave tests and ensure all scenarios pass
  - VALIDATE XSLT 3.0 syntax using SaxonHE processor
  - VERIFY all field mappings produce expected output
  - CHECK that comments explain each template's purpose
```

### Per task pseudocode as needed added to each task

```python
# Task 1 - TASK.md Creation
# Simple task tracking file following CLAUDE.md requirements
"## Tasks\n- XSLT Field Mappings Implementation - [date]\n  Description: Implement 4 field mappings with BDD tests\n  Status: In Progress"

# Task 8 - BDD Testing Infrastructure
# Use SaxonHE with behave framework for XSLT testing
@given('I have source XML with "{element}" value "{value}"')
def step_source_xml(context, element, value):
    # Load source XML and verify element exists
    context.source_xml = load_xml_with_element(element, value)

@when('I apply the XSLT transformation')  
def step_apply_xslt(context):
    # PATTERN: Use SaxonHE compile_stylesheet() for performance
    proc = PySaxonProcessor(license=False)
    xslt_proc = proc.new_xslt30_processor()
    
    # CRITICAL: Compile stylesheet once for reuse
    executable = xslt_proc.compile_stylesheet(stylesheet_file="src/mapping.xsl")
    context.result = executable.transform_to_string(source=context.source_xml)

@then('the output should contain element "{xpath}" with value "{expected}"')
def step_verify_output(context, xpath, expected):
    # PATTERN: Use XPath to verify transformation results
    result_doc = etree.fromstring(context.result)
    actual_value = result_doc.xpath(xpath)[0].text
    assert actual_value == expected, f"Expected {expected}, got {actual_value}"
```

### Integration Points
```yaml
DEPENDENCIES:
  - install: "pip install saxonche behave pytest lxml"
  - pattern: "uv add saxonche behave pytest lxml"
  
CONFIG:
  - add to: pyproject.toml
  - pattern: "dependencies = ['saxonche>=12.0', 'behave>=1.2.6', 'pytest>=7.0', 'lxml>=4.9']"
  
TESTING:
  - command: "uv run behave tests/features/"
  - pattern: "Run BDD tests using behave with SaxonHE processor"
  
VALIDATION:
  - command: "uv run python -c 'from saxonche import PySaxonProcessor; print(\"Saxon available\")'"
  - pattern: "Verify SaxonHE installation and XSLT 3.0 support"
```

## Validation Loop

### Level 1: XSLT Syntax & SaxonHE Validation
```bash
# Run these FIRST - fix any errors before proceeding
uv run python -c "
from saxonche import PySaxonProcessor
proc = PySaxonProcessor(license=False)
xslt_proc = proc.new_xslt30_processor()
try:
    executable = xslt_proc.compile_stylesheet(stylesheet_file='src/mapping.xsl')
    print('XSLT compilation successful - XSLT 3.0 syntax valid')
except Exception as e:
    print(f'XSLT compilation failed: {e}')
"

# Expected: "XSLT compilation successful" - if errors, READ Saxon error message and fix syntax
```

### Level 2: BDD Feature Tests
```python
# CREATE tests/features/field_mappings.feature with these scenarios:
Feature: XSLT Field Mappings
  As a data integrator
  I want to transform XML fields using XSLT
  So that source data maps correctly to target structure

  Scenario: Fixed value confirmation mapping
    Given I have a source XML document
    When I apply the XSLT transformation  
    Then the output should contain element "//PartSync/ControlArea/Sender/Confirmation" with value "2"

  Scenario: VBELN to Order ID mapping
    Given I have source XML with "VBELN" value "12345"
    When I apply the XSLT transformation
    Then the output should contain element "//OrderHead/OrderHeadId/Id" with value "12345"

  Scenario: WERKS to Division mapping  
    Given I have source XML with "WERKS" value "PLANT01"
    When I apply the XSLT transformation
    Then the output should contain element "//OrderHead/OrderHeadId/Division" with value "PLANT01"

  Scenario: Partner Y1 NAME1 mapping
    Given I have source XML with partner "Y1" and name "TestPartner"
    When I apply the XSLT transformation
    Then the output should contain element "//OrderHead/OurReference" with value "TestPartner"
```

```bash
# Run and iterate until passing:
uv run behave tests/features/field_mappings.feature -v
# If failing: Read error, understand root cause, fix XSLT/steps, re-run
```

### Level 3: Template Pattern Validation
```bash
# Verify apply-templates vs call-template usage:
grep -n "xsl:apply-templates" src/mapping.xsl
grep -n "xsl:call-template" src/mapping.xsl

# Expected: 
# - apply-templates for source field mappings (Features #2, #3, #4)  
# - call-template for fixed value mapping (Feature #1)
# If pattern incorrect: Refactor templates to follow architecture guidelines
```

## Final validation Checklist
- [ ] All BDD tests pass: `uv run behave tests/features/ -v`
- [ ] XSLT 3.0 syntax valid: SaxonHE compilation successful
- [ ] All 4 field mappings implemented correctly
- [ ] Apply-templates used for source-dependent mappings
- [ ] Call-template used for non-source-dependent mappings  
- [ ] Each template includes explanatory comments
- [ ] Edge cases handled (missing elements, wrong predicates)
- [ ] Sample test data covers all mapping scenarios
- [ ] Task marked complete in TASK.md

---

## Anti-Patterns to Avoid
- ❌ Don't use call-template for source field mappings - use apply-templates
- ❌ Don't skip BDD tests because "XSLT should work" - validate every mapping  
- ❌ Don't ignore Saxon compilation errors - they indicate XSLT syntax issues
- ❌ Don't hardcode namespaces without checking target XML requirements
- ❌ Don't create overly complex XPath expressions - keep mappings simple and clear
- ❌ Don't mix XSLT versions - stick to 3.0 throughout

**PRP Confidence Score: 9/10** - Comprehensive context provided with specific patterns from codebase, detailed validation steps, and clear implementation path using proven XSLT and BDD testing approaches.