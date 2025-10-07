name: "DispatchSync XSLT 3.0 Mapping Implementation with BDD Tests"
description: |

## Purpose
Implement a comprehensive XSLT 3.0 mapping file that transforms DELVRY07 IDOC source data to DispatchSync target format, with complete BDD test coverage for all 26 field mappings using behave framework and saxonche processor.

## Core Principles
1. **Context is King**: Full XSLT 3.0 spec, saxonche API, and existing pattern examples
2. **Validation Loops**: BDD tests for every mapping + integration tests
3. **Information Dense**: Follow patterns from examples/I405_ZRDA_V2.xsl and examples/Z_I152_TELEMA_ORDER.xsl
4. **Progressive Success**: Build templates incrementally, validate each mapping
5. **Global rules**: Follow all rules in CLAUDE.md

---

## Goal
Create an XSLT 3.0 mapping file (src/dispatch_mapping.xsl) that implements all 26 field mapping requirements from INITIAL.md, transforming DELVRY07 IDOC structure to DispatchSync target structure. Each field mapping must have corresponding BDD test scenarios.

## Why
- **Business value**: Enable automated transformation of SAP delivery IDoc data to Astro DispatchSync format
- **Integration**: Part of enterprise integration platform for logistics data exchange
- **Quality assurance**: BDD tests ensure each mapping works correctly and handles edge cases

## What
Transform SAP DELVRY07 delivery IDocs to DispatchSync XML format following these patterns:
- Use `<xsl:call-template>` for fixed values and calculated fields without source data
- Use `<xsl:apply-templates>` for repeating source elements (cardinality {1..*} or {0..*})
- Use `<xsl:value-of>` for simple {1..1} or {0..1} cardinality field mappings
- Add namespace prefix 'ns0:' to all target elements
- Implement conditional logic for optional elements
- Format numbers to 2 decimal places where specified
- Convert units according to mapping table (Requirement 23)
- Handle date/time formatting (Requirements 2, 13)
- Navigate using ancestor:: axis where needed (Requirement 26)

### Success Criteria
- [x] XSLT file is valid XSLT 3.0 syntax
- [x] All 26 requirements mapped with correct template architecture
- [x] Minimum 26 BDD scenarios (one per requirement) - all passing
- [x] Edge case scenarios for conditional logic (empty elements, missing data)
- [x] Integration test transforming complete DELVRY07 to DispatchSync
- [x] All templates documented with `<xsl:comment>` explaining purpose
- [x] Test fixtures created for source IDoc data

## All Needed Context

### Documentation & References (list all context needed to implement the feature)
```yaml
# MUST READ - Include these in your context window

- url: https://www.w3.org/TR/xslt-30/
  why: Official W3C XSLT 3.0 specification - reference for syntax, functions, and features
  section: Templates, apply-templates, call-template, XPath 3.0 expressions
  critical: XSLT 3.0 supports maps, arrays, and advanced XPath 3.0 functions

- url: https://www.saxonica.com/html/documentation12/using-xsl/saxonc-transformation/python-api-transformation.html
  why: Saxonche Python API documentation - how to execute XSLT 3.0 transformations
  section: PySaxonProcessor, new_xslt30_processor(), compile_stylesheet(), transform_to_string()
  critical: saxonche requires license=False parameter for HE edition

- url: https://behave.readthedocs.io/
  why: Behave BDD framework documentation - writing feature files and step definitions
  section: Gherkin syntax, Given/When/Then, step matching patterns, context object
  critical: Feature files use Gherkin, steps use @given/@when/@then decorators

- file: examples/I405_ZRDA_V2.xsl
  why: Perfect pattern showing namespace usage, apply-templates, date formatting, number formatting
  critical: Shows ns0: prefix usage, parent:: axis navigation, predicate filtering [@PARTNER_Q='WE']

- file: examples/Z_I152_TELEMA_ORDER.xsl
  why: Complex template patterns, xsl:choose, xsl:for-each, mode usage
  critical: Shows template modes, variable usage, external functions pattern

- file: examples/Z_I149_TELEMA_INVOIC.xsl
  why: Additional template patterns, nested apply-templates
  critical: Shows nested template structures, GROUP patterns

- file: INITIAL.md
  why: Complete specification of all 26 field mapping requirements
  critical: Source for requirement details, cardinality rules, special instructions
```

### Current Codebase tree
```
D:\GithubProjects\context-engineering-xslt/
├── .claude/
│   ├── commands/
│   │   ├── generate-prp.md
│   │   └── execute-prp.md
│   └── settings.local.json
├── PRPs/
│   └── templates/
│       └── prp_base.md
├── examples/
│   ├── I403_Mapping.xsl
│   ├── I405_ZRDA_V2.xsl          # KEY PATTERN EXAMPLE
│   ├── I407_GoodsReceipt_AstroFI_ECC.xsl
│   ├── Z_I149_TELEMA_INVOIC.xsl  # COMPLEX PATTERNS
│   └── Z_I152_TELEMA_ORDER.xsl   # ADVANCED PATTERNS
├── behave.ini
├── CLAUDE.md
├── INITIAL.md
├── README.md
├── TASK.md
└── pyproject.toml
```

### Desired Codebase tree with files to be added and responsibility of file
```
D:\GithubProjects\context-engineering-xslt/
├── src/
│   └── dispatch_mapping.xsl            # Main XSLT 3.0 mapping file with all 26 requirements
├── tests/
│   ├── features/
│   │   └── dispatch_mappings.feature   # BDD scenarios for all 26 requirements
│   ├── steps/
│   │   └── dispatch_steps.py           # Step definitions using saxonche
│   ├── fixtures/
│   │   ├── source_delvry07_full.xml   # Complete test fixture with all elements
│   │   ├── source_empty_elements.xml   # Edge case: empty BTGEW/VOLUM
│   │   ├── source_no_bolnr.xml        # Edge case: missing BOLNR
│   │   ├── source_no_exidv2.xml       # Edge case: EXIDV2 missing, EXIDV present
│   │   └── source_no_charg.xml        # Edge case: empty CHARG
│   └── conftest.py                     # Behave configuration with saxonche setup
└── [existing files...]
```

### Known Gotchas of our codebase & Library Quirks
```python
# CRITICAL: saxonche requires license=False for HE (Home Edition)
from saxonche import PySaxonProcessor
proc = PySaxonProcessor(license=False)  # MUST set license=False

# CRITICAL: XSLT 3.0 uses version="3.0" in stylesheet element
# Example from existing patterns shows version="1.0" but we need 3.0
<xsl:stylesheet version="3.0" xmlns:xsl="...">

# CRITICAL: Namespace prefix 'ns0:' required on ALL target elements
# Namespace: http://www.consafelogistics.com/astro/project
xmlns:ns0="http://www.consafelogistics.com/astro/project"

# CRITICAL: Use full XPath in template match, not just element name
# CORRECT: <xsl:template match="/DELVRY07/IDOC/E1EDL20/E1EDL37">
# WRONG:   <xsl:template match="E1EDL37">

# CRITICAL: Remove leading zeros uses translate() not substring
# From I405_ZRDA_V2.xsl line 14:
<xsl:value-of select="translate(/DELVRY07/IDOC/EDI_DC40/DOCNUM, '0', '')"/>

# CRITICAL: Number formatting to 2 decimal places
# From I405_ZRDA_V2.xsl line 74:
format-number(round(LFIMG * 100) div 100, '0.00')

# CRITICAL: Date/time formatting uses concat + substring
# From I405_ZRDA_V2.xsl lines 10-11:
concat(substring(/DELVRY07/IDOC/EDI_DC40/CREDAT, 1, 4), '-', ...)

# CRITICAL: Cardinality rules per CLAUDE.md
# {0..*} or {1..*} -> use <xsl:apply-templates>
# {0..1} or {1..1} -> use <xsl:value-of>
# No source, fixed value -> use <xsl:call-template> or direct in template

# CRITICAL: behave expects features/ and steps/ directories
# Configure in behave.ini:
# paths = tests/features
# step_definitions = tests/steps

# CRITICAL: Static structure elements don't need apply-templates
# Per CLAUDE.md "Static Structure Rule" - elements appearing exactly once
# are written as literal XML in template, not generated via apply-templates

# CRITICAL: Unit conversion mapping for Requirement 23
# 'BG' -> 'BAG', 'NAR' -> 'EA', 'KGM' -> 'KG', 'LTR' -> 'L'
# 'MTR' -> 'M', 'MTK' -> 'M2', 'PR' -> 'PAA', 'PK' -> 'PAK'
```

## Implementation Blueprint

### Data models and structure

**XSLT Template Architecture:**
```xml
Root template (match="/"):
  - DispatchSync (static structure)
    - ControlArea (static)
      - Templates for Req 1, 2, 3
    - DataArea (static)
      - Sync (static)
        - Template for Req 4
      - Dispatch (static)
        - DispatchHead (static)
          - Templates for Req 5-13
        - Pallet (apply-templates) -> Req 14-26

Template for E1EDL37 (Pallet level):
  - Generates Pallet element
  - Templates for Req 14-17
  - PalletContent/PalletContentItem (static structure per Req 18)
    - Apply-templates to E1EDL44

Template for E1EDL44 (Pallet content items):
  - Generates mapping for Req 19-26
  - PartId, AdvisedQuantity, AdvisedUnit, LotInfo
```

**BDD Test Structure:**
```gherkin
Feature: DispatchSync XSLT Mappings

  Scenario: Requirement 1 - Fixed confirmation value
  Scenario: Requirement 2 - Current datetime generation
  Scenario: Requirement 3 - ReferenceId with leading zeros removed
  ...
  Scenario: Requirement 26 - SupplierId from ancestor E1EDL20/E1ADRM1

  Scenario: Edge case - Empty BTGEW/VOLUM (Req 9,10)
  Scenario: Edge case - Missing BOLNR (Req 12)
  Scenario: Edge case - EXIDV2 missing, EXIDV present (Req 14)
  Scenario: Edge case - Empty CHARG (Req 24,25)

  Scenario: Integration - Complete DELVRY07 transformation
```

### List of tasks to be completed to fulfill the PRP in the order they should be completed

```yaml
Task 1: Create project structure
  CREATE tests/features/ directory
  CREATE tests/steps/ directory
  CREATE tests/fixtures/ directory
  CREATE src/ directory

Task 2: Create main XSLT mapping file structure
  CREATE src/dispatch_mapping.xsl
  - Add XSLT 3.0 declaration with version="3.0"
  - Add namespace declarations (xsl, ns0)
  - Create root template match="/"
  - Create static structure skeleton per "Static Structure Rule"
  - Add comments explaining architecture

Task 3: Implement ControlArea mappings (Requirements 1-3)
  MODIFY src/dispatch_mapping.xsl:
  - Req 1: Create named template "confirmationValue" for fixed value '2'
  - Req 2: Create named template "currentDateTime" with current-dateTime()
  - Req 3: Add value-of for DOCNUM with translate() to remove leading zeros
  - Add xsl:comment for each mapping explaining requirement

Task 4: Implement DataArea/Sync mapping (Requirement 4)
  MODIFY src/dispatch_mapping.xsl:
  - Create template for ActionCriteria @action attribute with fixed value 'Add'
  - Add xsl:comment

Task 5: Implement DispatchHead mappings (Requirements 5-13)
  MODIFY src/dispatch_mapping.xsl:
  - Req 5: Add value-of for VBELN to DispatchId/Id
  - Req 6,7,8: Add empty elements ShipFrom, ShipTo, DivisionGroup
  - Req 9,10: Add conditional template for DispatchDimensionArea with xsl:if
  - Req 11: Add value-of for ANZPK
  - Req 12: Add conditional TransportId with xsl:if test="boolean(BOLNR)"
  - Req 13: Add TransportDate with concat/substring date formatting
  - Add xsl:comment for each mapping

Task 6: Implement Pallet template (Requirements 14-17)
  MODIFY src/dispatch_mapping.xsl:
  - CREATE template match="/DELVRY07/IDOC/E1EDL20/E1EDL37"
  - Req 14: PalletId/Id with xsl:choose for EXIDV2 vs EXIDV
  - Req 15: PalletTypeId/Id with xsl:choose for MAGRV='Z001'
  - Req 16: PalletDimensionArea/Volume with format-number(round(BTVOL))
  - Req 17: PalletDimensionArea/Weight with format-number(round(BRGEW))
  - Add apply-templates select="E1EDL44" inside PalletContentItem
  - Add xsl:comment for each mapping

Task 7: Implement PalletContentItem template (Requirements 19-26)
  MODIFY src/dispatch_mapping.xsl:
  - CREATE template match="/DELVRY07/IDOC/E1EDL20/E1EDL37/E1EDL44"
  - Req 19: PartId/Id from MATNR
  - Req 20: PartId/Revision with fixed text " " (one space)
  - Req 21: PartId/Division from WERKS
  - Req 22: AdvisedQuantity with format-number(round(VEMNG))
  - Req 23: AdvisedUnit with xsl:choose for unit conversion
  - Req 24,25: Conditional LotInfo/LotId/Id with xsl:if test="CHARG != ''"
  - Req 26: LotInfo/LotId/SupplierId with ancestor::E1EDL20/E1ADRM1[@PARTNER_Q='LF']/PARTNER_ID
  - Add xsl:comment for each mapping

Task 8: Create test fixtures
  CREATE tests/fixtures/source_delvry07_full.xml:
  - Complete DELVRY07 structure with all elements
  - Multiple E1EDL37 pallets
  - Multiple E1EDL44 items per pallet
  - All optional elements populated

  CREATE tests/fixtures/source_empty_elements.xml:
  - BTGEW and VOLUM empty (test Req 9,10)

  CREATE tests/fixtures/source_no_bolnr.xml:
  - BOLNR missing (test Req 12)

  CREATE tests/fixtures/source_no_exidv2.xml:
  - EXIDV2 missing, EXIDV present (test Req 14)

  CREATE tests/fixtures/source_no_charg.xml:
  - CHARG empty (test Req 24,25)

Task 9: Create BDD feature file with all scenarios
  CREATE tests/features/dispatch_mappings.feature:
  - Feature description
  - Background section for common setup
  - 26 scenarios (one per requirement)
  - 5 edge case scenarios
  - 1 integration scenario
  - Use clear Given/When/Then structure

Task 10: Create step definitions
  CREATE tests/steps/dispatch_steps.py:
  - Import saxonche (PySaxonProcessor)
  - @given step: load XSLT and source fixture
  - @when step: execute transformation
  - @then steps: assert XPath expressions on result
  - Helper functions for XPath assertions
  - Handle context.xslt, context.source, context.result

Task 11: Create behave configuration
  CREATE tests/conftest.py:
  - Setup saxonche processor with license=False
  - Define before_all hook
  - Define after_scenario hook for cleanup
  - Configure logging if needed

Task 12: Run validation loop - Syntax validation
  RUN: uv run python -c "from saxonche import *; proc=PySaxonProcessor(license=False); xslt=proc.new_xslt30_processor(); xslt.compile_stylesheet(stylesheet_file='src/dispatch_mapping.xsl')"
  - Fix any XSLT syntax errors
  - Re-run until no errors

Task 13: Run validation loop - Execute BDD tests
  RUN: uv run behave tests/features -v
  - Review failures
  - Fix XSLT templates or test assertions
  - Re-run until all scenarios pass

Task 14: Verify integration test
  RUN: uv run behave tests/features -n "Integration"
  - Ensure complete transformation succeeds
  - Validate output structure
  - Check all 26 requirements in single output

Task 15: Final validation and documentation
  - Verify all templates have xsl:comment documentation
  - Verify all 26 requirements implemented
  - Run final test suite: uv run behave tests/features -v
  - All tests MUST pass
```

### Per task pseudocode as needed

```python
# Task 2: Main XSLT structure pseudocode
<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:ns0="http://www.consafelogistics.com/astro/project">

    <xsl:output method="xml" indent="yes"/>

    <xsl:template match="/">
        <ns0:DispatchSync version="0100">
            <ns0:ControlArea>
                <!-- Req 1, 2, 3 go here -->
            </ns0:ControlArea>
            <ns0:DataArea>
                <ns0:Sync>
                    <!-- Req 4 -->
                </ns0:Sync>
                <ns0:Dispatch>
                    <ns0:DispatchHead>
                        <!-- Req 5-13 -->
                    </ns0:DispatchHead>
                    <!-- Apply templates to E1EDL37 for Req 14-26 -->
                    <xsl:apply-templates select="DELVRY07/IDOC/E1EDL20/E1EDL37"/>
                </ns0:Dispatch>
            </ns0:DataArea>
        </ns0:DispatchSync>
    </xsl:template>

    <!-- Additional templates for E1EDL37 and E1EDL44 -->
</xsl:stylesheet>

# Task 3: ControlArea mappings pseudocode
# Req 1: Fixed value '2' - use direct value or call-template
<ns0:Confirmation>2</ns0:Confirmation>

# Req 2: Current datetime - use XSLT 3.0 current-dateTime() or format manually
<ns0:CreationDateTime>
    <xsl:value-of select="format-dateTime(current-dateTime(), '[Y0001]-[M01]-[D01]T[H01]:[m01]:[s01]')"/>
</ns0:CreationDateTime>

# Req 3: Remove leading zeros - use translate() like I405_ZRDA_V2.xsl
<ns0:Id>
    <xsl:value-of select="translate(/DELVRY07/IDOC/EDI_DC40/DOCNUM, '0', '')"/>
</ns0:Id>

# Task 6: Pallet template pseudocode
<xsl:template match="/DELVRY07/IDOC/E1EDL20/E1EDL37">
    <xsl:comment>Requirement 14-17: Pallet mappings</xsl:comment>
    <ns0:Pallet>
        <ns0:PalletId>
            <ns0:Id>
                <!-- Req 14: Choose EXIDV2 if exists, else EXIDV -->
                <xsl:choose>
                    <xsl:when test="EXIDV2 and EXIDV2 != ''">
                        <xsl:value-of select="EXIDV2"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="EXIDV"/>
                    </xsl:otherwise>
                </xsl:choose>
            </ns0:Id>
        </ns0:PalletId>

        <!-- Req 15: PalletTypeId based on MAGRV -->
        <ns0:PalletTypeId>
            <ns0:Id>
                <xsl:choose>
                    <xsl:when test="MAGRV = 'Z001'">B1</xsl:when>
                    <xsl:otherwise>P2</xsl:otherwise>
                </xsl:choose>
            </ns0:Id>
        </ns0:PalletTypeId>

        <!-- Req 16, 17: PalletDimensionArea -->
        <ns0:PalletDimensionArea>
            <ns0:Volume>
                <xsl:value-of select="format-number(round(BTVOL * 100) div 100, '0.00')"/>
            </ns0:Volume>
            <ns0:Weight>
                <xsl:value-of select="format-number(round(BRGEW * 100) div 100, '0.00')"/>
            </ns0:Weight>
        </ns0:PalletDimensionArea>

        <!-- Req 18: Static structure with apply-templates -->
        <ns0:PalletContent>
            <ns0:PalletContentItem>
                <xsl:apply-templates select="E1EDL44"/>
            </ns0:PalletContentItem>
        </ns0:PalletContent>
    </ns0:Pallet>
</xsl:template>

# Task 7: PalletContentItem template pseudocode
<xsl:template match="/DELVRY07/IDOC/E1EDL20/E1EDL37/E1EDL44">
    <xsl:comment>Requirement 19-26: PalletContentItem mappings</xsl:comment>

    <!-- Req 19-21: PartId -->
    <ns0:PartId>
        <ns0:Id><xsl:value-of select="MATNR"/></ns0:Id>
        <ns0:Revision> </ns0:Revision>  <!-- Req 20: one space -->
        <ns0:Division><xsl:value-of select="WERKS"/></ns0:Division>
    </ns0:PartId>

    <!-- Req 22: AdvisedQuantity -->
    <ns0:AdvisedQuantity>
        <xsl:value-of select="format-number(round(VEMNG * 100) div 100, '0.00')"/>
    </ns0:AdvisedQuantity>

    <!-- Req 23: AdvisedUnit with conversion -->
    <ns0:AdvisedUnit>
        <xsl:choose>
            <xsl:when test="VEMEH = 'BG'">BAG</xsl:when>
            <xsl:when test="VEMEH = 'NAR'">EA</xsl:when>
            <xsl:when test="VEMEH = 'KGM'">KG</xsl:when>
            <!-- ... other conversions ... -->
        </xsl:choose>
    </ns0:AdvisedUnit>

    <!-- Req 24,25: Conditional LotInfo -->
    <xsl:if test="CHARG != ''">
        <ns0:LotInfo>
            <ns0:LotId>
                <ns0:Id><xsl:value-of select="CHARG"/></ns0:Id>
                <!-- Req 26: SupplierId using ancestor -->
                <ns0:SupplierId>
                    <xsl:value-of select="ancestor::E1EDL20/E1ADRM1[@PARTNER_Q='LF']/PARTNER_ID"/>
                </ns0:SupplierId>
            </ns0:LotId>
        </ns0:LotInfo>
    </xsl:if>
</xsl:template>

# Task 9: BDD feature pseudocode
Feature: DispatchSync XSLT Field Mappings

  Background:
    Given the XSLT mapping file "src/dispatch_mapping.xsl"

  Scenario: Requirement 1 - Fixed Confirmation value
    Given the source file "tests/fixtures/source_delvry07_full.xml"
    When I transform the source using the XSLT
    Then the XPath "/ns0:DispatchSync/ns0:ControlArea/ns0:Sender/ns0:Confirmation/text()" should equal "2"

  Scenario: Requirement 3 - ReferenceId without leading zeros
    Given the source file "tests/fixtures/source_delvry07_full.xml"
    When I transform the source using the XSLT
    Then the XPath "/ns0:DispatchSync/ns0:ControlArea/ns0:ReferenceId/ns0:Id/text()" should not start with "0"

  # ... more scenarios ...

# Task 10: Step definitions pseudocode
from behave import given, when, then
from saxonche import PySaxonProcessor

@given('the XSLT mapping file "{xslt_file}"')
def load_xslt(context, xslt_file):
    context.xslt_file = xslt_file
    context.proc = PySaxonProcessor(license=False)
    context.xslt_proc = context.proc.new_xslt30_processor()

@given('the source file "{source_file}"')
def load_source(context, source_file):
    with open(source_file, 'r') as f:
        context.source_xml = f.read()

@when('I transform the source using the XSLT')
def transform(context):
    executable = context.xslt_proc.compile_stylesheet(
        stylesheet_file=context.xslt_file
    )
    document = context.proc.parse_xml(xml_text=context.source_xml)
    context.result = executable.transform_to_string(xdm_node=document)

@then('the XPath "{xpath}" should equal "{expected}"')
def assert_xpath_equals(context, xpath, expected):
    # Parse result and evaluate XPath
    result_doc = context.proc.parse_xml(xml_text=context.result)
    xpath_proc = context.proc.new_xpath_processor()
    xpath_proc.set_context(xdm_item=result_doc)
    xpath_proc.declare_namespace('ns0', 'http://www.consafelogistics.com/astro/project')
    value = xpath_proc.evaluate_single(xpath)
    assert str(value) == expected, f"Expected {expected}, got {value}"
```

### Integration Points
```yaml
DEPENDENCIES:
  - saxonche: XSLT 3.0 processor (version >=12.8.0)
  - behave: BDD testing framework (version >=1.3.0)
  - lxml: XML parsing (version >=6.0.0)
  - pytest: Additional testing support (version >=8.4.1)

PROJECT_STRUCTURE:
  - behave.ini: Already configured with paths and step_definitions
  - pyproject.toml: Already has all dependencies
  - CLAUDE.md: Contains XSLT mapping rules and testing requirements

ENVIRONMENT:
  - Use uv package manager for all Python commands
  - Virtual environment required for Python execution
```

## Validation Loop

### Level 1: XSLT Syntax Validation
```bash
# Validate XSLT syntax by attempting compilation
uv run python -c "from saxonche import PySaxonProcessor; proc=PySaxonProcessor(license=False); xslt=proc.new_xslt30_processor(); xslt.compile_stylesheet(stylesheet_file='src/dispatch_mapping.xsl'); print('XSLT syntax valid')"

# Expected: "XSLT syntax valid"
# If errors: READ the error message, find line number, fix XSLT, re-run
```

### Level 2: Individual Mapping Tests
```bash
# Run BDD tests for specific requirements
uv run behave tests/features -v --name="Requirement 1"
uv run behave tests/features -v --name="Requirement 3"
# ... test each requirement individually

# Expected: Each scenario passes
# If failing:
#   1. Read the failure message
#   2. Check expected vs actual output
#   3. Review XSLT template for that requirement
#   4. Fix template logic
#   5. Re-run test
```

### Level 3: Edge Case Tests
```bash
# Run edge case scenarios
uv run behave tests/features -v --name="Edge case"

# Expected: All edge cases handled gracefully
# Test cases:
#   - Empty BTGEW/VOLUM should NOT generate DispatchDimensionArea
#   - Missing BOLNR should NOT generate TransportId
#   - EXIDV2 missing should fall back to EXIDV
#   - Empty CHARG should NOT generate LotInfo
```

### Level 4: Full Integration Test
```bash
# Run complete transformation test
uv run behave tests/features -v

# Expected: All scenarios pass
# Verify:
#   - All 26 requirements mapped
#   - Edge cases handled
#   - Complete DELVRY07 -> DispatchSync transformation
#   - Output is well-formed XML
#   - Namespace prefixes correct
```

### Level 5: Manual Transformation Check
```bash
# Manually transform a test file and inspect output
uv run python -c "
from saxonche import PySaxonProcessor

proc = PySaxonProcessor(license=False)
xslt_proc = proc.new_xslt30_processor()
executable = xslt_proc.compile_stylesheet(stylesheet_file='src/dispatch_mapping.xsl')

with open('tests/fixtures/source_delvry07_full.xml', 'r') as f:
    source = f.read()

document = proc.parse_xml(xml_text=source)
result = executable.transform_to_string(xdm_node=document)
print(result)
" > output.xml

# Then manually inspect output.xml
# Verify structure, namespaces, data accuracy
```

## Final Validation Checklist
- [ ] XSLT file compiles without errors (Level 1)
- [ ] All 26 requirement scenarios pass (Level 2)
- [ ] All edge case scenarios pass (Level 3)
- [ ] Integration test passes (Level 4)
- [ ] Manual inspection confirms correct output (Level 5)
- [ ] All templates have `<xsl:comment>` documentation
- [ ] XSLT follows patterns from I405_ZRDA_V2.xsl
- [ ] All target elements have ns0: prefix
- [ ] Number formatting uses format-number() with '0.00'
- [ ] Date formatting uses concat() + substring()
- [ ] Full XPath used in template match attributes
- [ ] Conditional elements use xsl:if or xsl:choose appropriately

---

## Anti-Patterns to Avoid
- ❌ Don't use version="1.0" - must be version="3.0"
- ❌ Don't forget ns0: prefix on target elements
- ❌ Don't use short element names in template match - use full XPath
- ❌ Don't use substring() for removing leading zeros - use translate()
- ❌ Don't forget license=False when creating PySaxonProcessor
- ❌ Don't create apply-templates for static single-occurrence elements
- ❌ Don't forget to test edge cases (empty elements, missing data)
- ❌ Don't skip xsl:comment documentation for templates
- ❌ Don't hardcode dates - use current-dateTime() or source data
- ❌ Don't forget namespace declaration in XPath assertions

## Requirements Breakdown for Quick Reference

**Requirements 1-4: ControlArea & Sync**
- Req 1: Fixed value '2' → /DispatchSync/ControlArea/Sender/Confirmation
- Req 2: Current datetime → /DispatchSync/ControlArea/CreationDateTime
- Req 3: DOCNUM (no leading zeros) → /DispatchSync/ControlArea/ReferenceId/Id
- Req 4: Fixed value 'Add' → /DispatchSync/DataArea/Sync/ActionCriteria/@action

**Requirements 5-13: DispatchHead**
- Req 5: VBELN → /DispatchSync/DataArea/Dispatch/DispatchHead/DispatchId/Id
- Req 6-8: Empty elements → ShipFrom, ShipTo, DivisionGroup
- Req 9-10: Conditional DispatchDimensionArea (Weight, Volume) if BTGEW and VOLUM not empty
- Req 11: ANZPK → ShipUnitQuantity
- Req 12: BOLNR → TransportId/Id (conditional on boolean(BOLNR))
- Req 13: Formatted datetime → TransportDate

**Requirements 14-17: Pallet (E1EDL37)**
- Req 14: EXIDV2 or EXIDV → PalletId/Id
- Req 15: MAGRV='Z001' → 'B1', else 'P2' → PalletTypeId/Id
- Req 16: BTVOL (formatted) → PalletDimensionArea/Volume
- Req 17: BRGEW (formatted) → PalletDimensionArea/Weight

**Requirements 18-26: PalletContentItem (E1EDL44)**
- Req 18: Static structure with apply-templates to E1EDL44
- Req 19: MATNR → PartId/Id
- Req 20: Fixed " " (space) → PartId/Revision
- Req 21: WERKS → PartId/Division
- Req 22: VEMNG (formatted) → AdvisedQuantity
- Req 23: VEMEH (converted) → AdvisedUnit
- Req 24-25: CHARG → LotInfo/LotId/Id (conditional on CHARG not empty)
- Req 26: ancestor::E1EDL20/E1ADRM1[@PARTNER_Q='LF']/PARTNER_ID → LotInfo/LotId/SupplierId

---

## PRP Confidence Score: 9/10

**Rationale:**
- ✅ Complete requirements specification (26 detailed mappings)
- ✅ Comprehensive external documentation (W3C XSLT 3.0, saxonche, behave)
- ✅ Strong codebase examples (I405_ZRDA_V2.xsl pattern)
- ✅ Clear validation loops (5 levels of testing)
- ✅ Detailed task breakdown (15 sequential tasks)
- ✅ Known gotchas documented (namespace, cardinality rules)
- ✅ Edge cases identified and planned
- ⚠️  Minor risk: Requirement 26 ancestor:: axis complexity
- ⚠️  Minor risk: First-time integration of complex nested templates

**Success probability:** Very high (90%+) - all context provided, clear patterns to follow, comprehensive testing strategy ensures iterative refinement to working solution.
