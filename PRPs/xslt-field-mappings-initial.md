name: "XSLT Field Mappings with BDD Testing"
description: |

## Purpose
Implement 4 XSLT field mappings using XSLT 3.0 with comprehensive BDD tests. This demonstrates proper use of `<xsl:call-template>` for fixed values and `<xsl:apply-templates>` for source field mappings, with full test coverage using behave framework and SaxonHE processor.

## Core Principles
1. **Context is King**: Include ALL necessary documentation, examples, and caveats
2. **Validation Loops**: Provide executable tests that can validate each mapping
3. **Information Dense**: Use keywords and patterns from the codebase
4. **Progressive Success**: Start simple, validate, then enhance
5. **Global rules**: Follow all rules in CLAUDE.md

---

## Goal
Create an XSLT 3.0 mapping file that transforms DELVRY07 IDoc messages to OrderSync/PartSync formats, with one fixed value mapping and three dynamic field mappings. Each mapping must have a corresponding BDD test that validates the transformation using SaxonHE Python processor.

## Why
- **Business value**: Automates data transformation between SAP IDoc format and proprietary XML schemas
- **Integration**: Demonstrates proper XSLT 3.0 architecture patterns with template-based design
- **Problems solved**: Ensures accurate, testable field mappings with automated validation

## What
An XSLT transformation system that:
- Maps a fixed value '2' to `/PartSync/ControlArea/Sender/Confirmation`
- Maps `/DELVRY07/ZASTRO_DELVRY07/IDOC/E1EDL20/VBELN` to `/OrderSync/DataArea/Order/OrderHead/OrderHeadId/Id`
- Maps `/DELVRY07/ZASTRO_DELVRY07/IDOC/E1EDL20/E1EDL24/WERKS` to `/OrderSync/DataArea/Order/OrderHead/OrderHeadId/Division`
- Maps `/DELVRY07/ZASTRO_DELVRY07/IDOC/E1EDL20/E1ADRM1[PARTNER_Q='Y1']/NAME1` to `/OrderSync/DataArea/Order/OrderHead/OurReference`
- Provides 7+ BDD scenarios testing each mapping individually and edge cases

### Success Criteria
- [ ] XSLT file uses XSLT 3.0 syntax and is valid
- [ ] Feature #1 (fixed value) uses `<xsl:call-template>` pattern
- [ ] Features #2-4 use `<xsl:apply-templates>` pattern with dedicated templates
- [ ] All 7+ BDD scenarios pass when run with behave
- [ ] Each template has explanatory `<xsl:comment>` documentation
- [ ] Code follows patterns from examples/I405_ZRDA_V2.xsl and examples/Z_I152_TELEMA_ORDER.xsl

## All Needed Context

### Documentation & References
```yaml
# MUST READ - Include these in your context window
- url: https://www.w3.org/TR/xslt-30/
  why: XSLT 3.0 specification for syntax reference
  section: Templates, xsl:apply-templates, xsl:call-template

- url: https://www.saxonica.com/documentation12/index.html#!using-xsl/xsltfromxquery
  why: Saxon XSLT 3.0 processor documentation and features

- url: https://saxonica.com/saxon-c/doc12/html/saxonc.html
  why: SaxonC Python API documentation for saxonche library

- url: https://behave.readthedocs.io/en/stable/
  why: Behave BDD framework for writing Gherkin scenarios and step definitions
  section: Tutorial, Gherkin syntax, Step implementations

- file: examples/I405_ZRDA_V2.xsl
  why: Shows EXACT source path patterns (/DELVRY07/IDOC/E1EDL20/VBELN, E1EDL24/WERKS, E1ADRM1[PARTNER_Q='AG'])
  critical: This file shows the correct IDoc structure and XPath patterns to use

- file: examples/Z_I152_TELEMA_ORDER.xsl
  why: Demonstrates proper <xsl:apply-templates> pattern with mode attributes and template matching
  critical: Shows how to organize multiple templates with clear comments

- file: examples/Z_I149_TELEMA_INVOIC.xsl
  why: Shows advanced template patterns with modes and proper commenting

- file: examples/I403_Mapping.xsl
  why: Simple example showing basic template structure and fixed value assignment

- file: CLAUDE.md
  why: Project-specific rules about XSLT architecture, testing requirements, and code style
  critical: Must use <xsl:apply-templates> wherever possible, create BDD test for each template
```

### Current Codebase tree
```bash
.
├── .claude/
│   └── commands/
│       ├── generate-prp.md
│       └── execute-prp.md
├── examples/
│   ├── I403_Mapping.xsl           # Simple XSLT example
│   ├── I405_ZRDA_V2.xsl           # EXACT patterns for DELVRY07 IDoc paths
│   ├── I407_GoodsReceipt_AstroFI_ECC.xsl
│   ├── Z_I149_TELEMA_INVOIC.xsl   # Complex template patterns
│   └── Z_I152_TELEMA_ORDER.xsl    # Template mode examples
├── PRPs/
│   ├── templates/
│   │   └── prp_base.md
│   └── EXAMPLE_multi_agent_prp.md
├── src/                           # EMPTY - code goes here
├── tests/                         # EMPTY - tests go here
├── behave.ini                     # Behave configuration
├── CLAUDE.md                      # Project rules
├── INITIAL.md                     # Feature requirements
├── TASK.md                        # Task tracking
├── pyproject.toml                 # Dependencies (saxonche, behave, pytest, lxml)
└── README.md
```

### Desired Codebase tree with files to be added and responsibility
```bash
.
├── src/
│   └── mapping.xsl                # Main XSLT 3.0 transformation file
│       # Responsibility: Transform DELVRY07 IDoc to OrderSync/PartSync formats
│       # Contains: Root template, fixed value template, 3 field mapping templates
│
├── tests/
│   ├── features/
│   │   └── field_mappings.feature # Gherkin BDD scenarios
│   │       # Responsibility: Define all test scenarios in Given/When/Then format
│   │       # Contains: 7+ scenarios (1 per mapping + edge cases)
│   │
│   ├── steps/
│   │   └── xslt_steps.py          # Step definitions for BDD tests
│   │       # Responsibility: Python code implementing Gherkin steps
│   │       # Contains: Step functions using saxonche to run XSLT and validate results
│   │
│   ├── fixtures/
│   │   ├── source_idoc.xml        # Sample DELVRY07 IDoc input
│   │   │   # Responsibility: Test data with all required source fields
│   │   │
│   │   └── expected_output.xml    # Expected transformation output
│   │       # Responsibility: Expected results for validation
│   │
│   └── conftest.py                # Pytest/behave configuration
│       # Responsibility: Shared fixtures and test setup
│       # Contains: Paths, saxonche initialization, cleanup
```

### Known Gotchas & Library Quirks
```python
# CRITICAL: XSLT 3.0 requires version="3.0" in xsl:stylesheet or xsl:transform
# CRITICAL: SaxonHE 12.x is free and supports XSLT 3.0 (saxonche Python package)
# CRITICAL: saxonche.PySaxonProcessor() creates processor; use compile_stylesheet() then transform_to_string()
# CRITICAL: Behave expects tests/features/*.feature files and tests/steps/*_steps.py
# CRITICAL: behave.ini configures paths - already set to tests/features and tests/steps
# CRITICAL: For fixed values, use <xsl:call-template> to explicitly show it's not source-dependent
# CRITICAL: For source mappings, use <xsl:apply-templates select="path"/> with matching template
# CRITICAL: Template match paths in examples use simplified paths like "DELVRY07/IDOC/E1EDL20/E1EDL24"
# CRITICAL: XPath predicates use syntax [PARTNER_Q='Y1'] for filtering elements
# CRITICAL: Always add <xsl:comment> inside templates to document what they do
# CRITICAL: Use format-number() for numeric formatting, concat() for string manipulation
# CRITICAL: Namespace prefixes must be declared in xsl:stylesheet element
# CRITICAL: behave automatically discovers *.feature files in configured paths
# CRITICAL: Step definitions use @given, @when, @then decorators from behave module
```

## Implementation Blueprint

### Data models and structure

The XSLT mapping will transform between two XML schemas:

**Source Schema (DELVRY07 IDoc):**
```xml
<DELVRY07>
  <ZASTRO_DELVRY07>
    <IDOC>
      <E1EDL20>
        <VBELN>OrderId123</VBELN>
        <E1EDL24>
          <WERKS>Plant01</WERKS>
        </E1EDL24>
        <E1ADRM1 PARTNER_Q="Y1">
          <NAME1>Reference Name</NAME1>
        </E1ADRM1>
      </E1EDL20>
    </IDOC>
  </ZASTRO_DELVRY07>
</DELVRY07>
```

**Target Schemas (OrderSync and PartSync):**
```xml
<!-- For fixed value mapping -->
<PartSync>
  <ControlArea>
    <Sender>
      <Confirmation>2</Confirmation>
    </Sender>
  </ControlArea>
</PartSync>

<!-- For dynamic field mappings -->
<OrderSync>
  <DataArea>
    <Order>
      <OrderHead>
        <OrderHeadId>
          <Id>OrderId123</Id>
          <Division>Plant01</Division>
        </OrderHeadId>
        <OurReference>Reference Name</OurReference>
      </OrderHead>
    </Order>
  </DataArea>
</OrderSync>
```

### List of tasks to be completed to fulfill the PRP in order

```yaml
Task 1: Create XSLT Mapping File
  CREATE src/mapping.xsl:
    - START with XSLT 3.0 declaration: <xsl:stylesheet version="3.0">
    - DECLARE namespaces if target schemas require them
    - CREATE root template match="/"
    - STRUCTURE output with PartSync and OrderSync root elements
    - ADD placeholder calls for the 4 field mappings

Task 2: Implement Fixed Value Mapping (Feature #1)
  MODIFY src/mapping.xsl:
    - CREATE named template "fixed-confirmation-value"
    - TEMPLATE outputs: <Confirmation>2</Confirmation>
    - USE <xsl:call-template name="fixed-confirmation-value"/> in root template
    - ADD <xsl:comment> explaining this is a fixed value mapping

Task 3: Implement VBELN Mapping (Feature #2)
  MODIFY src/mapping.xsl:
    - CREATE template match="/DELVRY07/ZASTRO_DELVRY07/IDOC/E1EDL20/VBELN"
    - TEMPLATE outputs: <Id><xsl:value-of select="."/></Id>
    - USE <xsl:apply-templates select="/DELVRY07/ZASTRO_DELVRY07/IDOC/E1EDL20/VBELN"/> in root
    - ADD <xsl:comment> explaining this maps VBELN to OrderHeadId/Id

Task 4: Implement WERKS Mapping (Feature #3)
  MODIFY src/mapping.xsl:
    - CREATE template match="/DELVRY07/ZASTRO_DELVRY07/IDOC/E1EDL20/E1EDL24/WERKS"
    - TEMPLATE outputs: <Division><xsl:value-of select="."/></Division>
    - USE <xsl:apply-templates select="/DELVRY07/ZASTRO_DELVRY07/IDOC/E1EDL20/E1EDL24/WERKS"/>
    - ADD <xsl:comment> explaining this maps plant to Division

Task 5: Implement NAME1 with Predicate Mapping (Feature #4)
  MODIFY src/mapping.xsl:
    - CREATE template match="/DELVRY07/ZASTRO_DELVRY07/IDOC/E1EDL20/E1ADRM1[@PARTNER_Q='Y1']/NAME1"
    - TEMPLATE outputs: <OurReference><xsl:value-of select="."/></OurReference>
    - USE <xsl:apply-templates select="/DELVRY07/.../E1ADRM1[@PARTNER_Q='Y1']/NAME1"/>
    - ADD <xsl:comment> explaining this maps partner Y1 name to reference

Task 6: Create Test Fixtures
  CREATE tests/fixtures/source_idoc.xml:
    - INCLUDE all 4 source fields with test values
    - ENSURE E1ADRM1 element has PARTNER_Q="Y1" attribute
    - INCLUDE edge case data (empty values, special characters)

  CREATE tests/fixtures/expected_output.xml:
    - SHOW expected output for all 4 mappings
    - MATCH structure of PartSync and OrderSync schemas

Task 7: Create BDD Feature File
  CREATE tests/features/field_mappings.feature:
    - WRITE Feature description
    - CREATE Scenario for Feature #1 (fixed value '2')
    - CREATE Scenario for Feature #2 (VBELN mapping)
    - CREATE Scenario for Feature #3 (WERKS mapping)
    - CREATE Scenario for Feature #4 (NAME1 with predicate)
    - CREATE Scenario for missing E1ADRM1 element (edge case)
    - CREATE Scenario for wrong PARTNER_Q value (edge case)
    - CREATE Scenario for all mappings together (integration test)

Task 8: Create BDD Step Definitions
  CREATE tests/steps/xslt_steps.py:
    - IMPORT saxonche, behave, lxml
    - CREATE @given step to load source XML
    - CREATE @when step to execute XSLT transformation using saxonche
    - CREATE @then steps to validate each output field using XPath
    - HANDLE edge cases (missing elements, empty values)
    - ADD proper error messages for test failures

Task 9: Create Test Configuration
  CREATE tests/conftest.py:
    - DEFINE fixtures for file paths (XSLT, XML inputs/outputs)
    - CREATE SaxonC processor initialization fixture
    - ADD cleanup functions if needed
    - SET up proper Python paths for imports

Task 10: Validate XSLT Syntax
  RUN validation:
    - Use saxonche to compile XSLT (catches syntax errors)
    - Check for well-formed XML structure
    - Verify all templates are properly closed

Task 11: Run BDD Tests
  EXECUTE behave tests:
    - Run: uv run behave tests/features
    - VERIFY all 7+ scenarios pass
    - FIX any failures by updating XSLT or test data

Task 12: Document and Update TASK.md
  UPDATE TASK.md:
    - MARK task as completed
    - ADD any discovered gotchas or notes
    - DOCUMENT test execution commands
```

### Per task pseudocode with CRITICAL details

**Task 1: XSLT Structure**
```xml
<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

    <!-- CRITICAL: version="3.0" enables XSLT 3.0 features -->
    <!-- CRITICAL: strip-space removes whitespace-only text nodes -->
    <xsl:strip-space elements="*"/>
    <xsl:output method="xml" indent="yes"/>

    <!-- Root template - main entry point -->
    <xsl:template match="/">
        <!-- Create both output structures -->
        <Root>
            <!-- PartSync for fixed value -->
            <PartSync>
                <ControlArea>
                    <Sender>
                        <!-- PATTERN: Use call-template for fixed values -->
                        <xsl:call-template name="fixed-confirmation-value"/>
                    </Sender>
                </ControlArea>
            </PartSync>

            <!-- OrderSync for dynamic mappings -->
            <OrderSync>
                <DataArea>
                    <Order>
                        <OrderHead>
                            <OrderHeadId>
                                <!-- PATTERN: Use apply-templates for source mappings -->
                                <xsl:apply-templates select="...VBELN"/>
                                <xsl:apply-templates select="...WERKS"/>
                            </OrderHeadId>
                            <xsl:apply-templates select="...NAME1"/>
                        </OrderHead>
                    </Order>
                </DataArea>
            </OrderSync>
        </Root>
    </xsl:template>

    <!-- Templates for each mapping follow... -->
</xsl:stylesheet>
```

**Task 2-5: Template Pattern**
```xml
<!-- PATTERN for each field mapping template -->
<xsl:template match="full/xpath/to/source/element">
    <xsl:comment>
        Map source field X to target field Y
        Source: /DELVRY07/.../FIELD
        Target: /OrderSync/.../TARGET
    </xsl:comment>
    <TargetElement>
        <xsl:value-of select="."/>
    </TargetElement>
</xsl:template>

<!-- PATTERN for fixed value template -->
<xsl:template name="template-name">
    <xsl:comment>
        Fixed value mapping: Always output '2'
        Target: /PartSync/ControlArea/Sender/Confirmation
    </xsl:comment>
    <Confirmation>2</Confirmation>
</xsl:template>
```

**Task 7: BDD Feature Pattern**
```gherkin
# PATTERN: Each scenario tests one mapping
Feature: XSLT Field Mappings for DELVRY07 to OrderSync/PartSync

  Scenario: Map fixed value to Confirmation field
    Given a source DELVRY07 IDoc document
    When the XSLT transformation is applied
    Then the output should contain Confirmation element with value "2"

  Scenario: Map VBELN to OrderHeadId
    Given a source DELVRY07 IDoc with VBELN "12345"
    When the XSLT transformation is applied
    Then the output should contain Id element with value "12345"

  # ... more scenarios for each mapping

  Scenario: Handle missing PARTNER_Q Y1 element
    Given a source DELVRY07 IDoc without PARTNER_Q Y1
    When the XSLT transformation is applied
    Then the output should not contain OurReference element
```

**Task 8: Step Definition Pattern**
```python
# PATTERN: Step definitions using saxonche
from behave import given, when, then
from saxonche import PySaxonProcessor
from lxml import etree

@given('a source DELVRY07 IDoc document')
def step_load_source_idoc(context):
    # CRITICAL: Load XML as string for saxonche
    with open('tests/fixtures/source_idoc.xml', 'r') as f:
        context.source_xml = f.read()

@when('the XSLT transformation is applied')
def step_apply_xslt(context):
    # CRITICAL: Use saxonche processor
    with PySaxonProcessor(license=False) as proc:
        # CRITICAL: compile_stylesheet returns executable
        xslt = proc.new_xslt30_processor()
        executable = xslt.compile_stylesheet(stylesheet_file='src/mapping.xsl')

        # CRITICAL: transform_to_string needs source as node
        context.output_xml = executable.transform_to_string(source_file='tests/fixtures/source_idoc.xml')

@then('the output should contain {element} with value "{value}"')
def step_verify_element_value(context, element, value):
    # CRITICAL: Parse output and check with XPath
    doc = etree.fromstring(context.output_xml.encode())
    # GOTCHA: Use .// to search anywhere in document
    result = doc.xpath(f'.//{element}/text()')
    assert len(result) > 0, f"Element {element} not found"
    assert result[0] == value, f"Expected {value}, got {result[0]}"
```

### Integration Points
```yaml
SAXONCHE:
  - import: from saxonche import PySaxonProcessor
  - usage: "with PySaxonProcessor(license=False) as proc:"
  - critical: "Free version (license=False) supports XSLT 3.0"

BEHAVE:
  - config: behave.ini already configured
  - paths: tests/features (*.feature), tests/steps (*_steps.py)
  - run: "uv run behave" from project root

LXML:
  - usage: Parse XML output for validation
  - xpath: Use .xpath() method for assertions
  - critical: "fromstring() requires bytes, use .encode()"

UV (Python environment):
  - run commands: "uv run behave", "uv run pytest"
  - dependencies: Already in pyproject.toml
```

## Validation Loop

### Level 1: XSLT Syntax Validation
```bash
# Validate XSLT syntax using saxonche
uv run python -c "
from saxonche import PySaxonProcessor
with PySaxonProcessor(license=False) as proc:
    xslt = proc.new_xslt30_processor()
    executable = xslt.compile_stylesheet(stylesheet_file='src/mapping.xsl')
    print('✓ XSLT is valid')
"

# Expected: No errors, prints "✓ XSLT is valid"
# If errors: READ the Saxon error message carefully - it shows line numbers and specific issues
```

### Level 2: BDD Tests - Individual Mappings
```bash
# Run behave with verbose output
uv run behave tests/features -v

# Expected: All scenarios pass (7+ scenarios)
# Output shows each scenario result:
#   Feature: XSLT Field Mappings for DELVRY07 to OrderSync/PartSync
#     Scenario: Map fixed value to Confirmation field ... passed
#     Scenario: Map VBELN to OrderHeadId ... passed
#     ... etc

# If failing:
#   1. READ the specific scenario that failed
#   2. CHECK the assertion message (shows expected vs actual)
#   3. DEBUG by printing context.output_xml in step definition
#   4. VERIFY XSLT template match paths and output structure
#   5. FIX XSLT or test data, never mock to pass tests
```

### Level 3: Manual Transformation Test
```bash
# Create a manual test script to see the actual output
uv run python -c "
from saxonche import PySaxonProcessor

with PySaxonProcessor(license=False) as proc:
    xslt = proc.new_xslt30_processor()
    executable = xslt.compile_stylesheet(stylesheet_file='src/mapping.xsl')
    result = executable.transform_to_string(source_file='tests/fixtures/source_idoc.xml')
    print('=== TRANSFORMATION OUTPUT ===')
    print(result)
"

# Expected: Valid XML output with all 4 field mappings visible
# Check:
#   - <Confirmation>2</Confirmation> exists
#   - <Id> contains value from VBELN
#   - <Division> contains value from WERKS
#   - <OurReference> contains value from NAME1 where PARTNER_Q='Y1'
```

### Level 4: Edge Case Validation
```bash
# Test with missing/edge case data
# Create tests/fixtures/edge_case_idoc.xml with:
#   - Missing E1ADRM1 element
#   - E1ADRM1 with wrong PARTNER_Q value
#   - Empty VBELN element

# Run specific scenarios
uv run behave tests/features -n "missing PARTNER_Q"

# Expected: Test passes, OurReference not in output when predicate doesn't match
```

## Final Validation Checklist
- [ ] XSLT compiles without errors: `uv run python -c "...compile_stylesheet..."`
- [ ] All BDD scenarios pass: `uv run behave tests/features`
- [ ] Fixed value template uses `<xsl:call-template>`
- [ ] Dynamic mappings use `<xsl:apply-templates>` with dedicated templates
- [ ] Each template has `<xsl:comment>` documentation
- [ ] Edge cases handled (missing elements, wrong predicates)
- [ ] Manual transformation produces valid XML output
- [ ] TASK.md updated with completion status
- [ ] Code follows patterns from examples/I405_ZRDA_V2.xsl

---

## Anti-Patterns to Avoid
- ❌ Don't use XSLT 1.0 or 2.0 - must be version="3.0"
- ❌ Don't use `<xsl:value-of>` directly in root template - use templates
- ❌ Don't use `<xsl:apply-templates>` for fixed values - use `<xsl:call-template>`
- ❌ Don't forget XPath predicates syntax: `[@PARTNER_Q='Y1']` not `[PARTNER_Q='Y1']`
- ❌ Don't skip `<xsl:comment>` documentation in templates
- ❌ Don't create BDD tests that don't actually validate output (must use assertions)
- ❌ Don't hardcode test data in step definitions - use fixtures
- ❌ Don't mock saxonche or XSLT execution to make tests pass
- ❌ Don't ignore Saxon error messages - they're very specific and helpful
- ❌ Don't forget to close all XML tags properly

## Expected Timeline
- Task 1-5 (XSLT creation): ~30 minutes
- Task 6 (Fixtures): ~10 minutes
- Task 7-9 (BDD setup): ~30 minutes
- Task 10-11 (Validation): ~20 minutes
- Task 12 (Documentation): ~10 minutes
**Total: ~100 minutes for one-pass implementation**

## Success Indicators
✅ 7+ BDD scenarios all passing
✅ XSLT compiles without warnings
✅ Each mapping validated independently
✅ Edge cases properly handled
✅ Code matches patterns from examples/
✅ All templates documented with comments
✅ TASK.md shows completion

---

## PRP Confidence Score: 9/10

**Reasoning:**
- ✅ Exact source path patterns available in examples/I405_ZRDA_V2.xsl
- ✅ Clear architecture patterns in examples/Z_I152_TELEMA_ORDER.xsl
- ✅ All dependencies already installed (saxonche, behave, lxml)
- ✅ Project structure and rules clearly defined in CLAUDE.md
- ✅ Behave configuration already in place (behave.ini)
- ✅ Comprehensive validation strategy with executable tests
- ✅ Step-by-step implementation plan with specific code patterns
- ⚠️ Minor: First-time BDD setup in this project (not seen existing test examples)
- ⚠️ Minor: Saxon error messages may require interpretation

**One-pass success probability: Very High (90%)**

The PRP includes all necessary context, specific code patterns from the codebase, executable validation steps, and clear anti-patterns to avoid. The AI has everything needed to implement working code with comprehensive tests on the first attempt.
