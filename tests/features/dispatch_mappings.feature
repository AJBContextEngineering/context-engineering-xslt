Feature: DispatchSync XSLT Field Mappings
  As a data integration developer
  I want to transform DELVRY07 IDocs to DispatchSync format
  So that logistics data can be exchanged between systems

  Background:
    Given the XSLT mapping file "src/dispatch_mapping.xsl"

  # Requirements 1-4: ControlArea & Sync

  Scenario: Requirement 1 - Fixed Confirmation value
    Given the source file "tests/fixtures/source_delvry07_full.xml"
    When I transform the source using the XSLT
    Then the XPath "//ns0:Confirmation/text()" should equal "2"

  Scenario: Requirement 2 - CreationDateTime is generated
    Given the source file "tests/fixtures/source_delvry07_full.xml"
    When I transform the source using the XSLT
    Then the XPath "//ns0:CreationDateTime/text()" should match pattern "^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}$"

  Scenario: Requirement 3 - ReferenceId without leading zeros
    Given the source file "tests/fixtures/source_delvry07_full.xml"
    When I transform the source using the XSLT
    Then the XPath "//ns0:ReferenceId/ns0:Id/text()" should equal "123456"

  Scenario: Requirement 4 - Fixed ActionCriteria action attribute
    Given the source file "tests/fixtures/source_delvry07_full.xml"
    When I transform the source using the XSLT
    Then the XPath "//ns0:ActionCriteria/@action" should equal "Add"

  # Requirements 5-13: DispatchHead

  Scenario: Requirement 5 - DispatchId from VBELN
    Given the source file "tests/fixtures/source_delvry07_full.xml"
    When I transform the source using the XSLT
    Then the XPath "//ns0:DispatchHead/ns0:DispatchId/ns0:Id/text()" should equal "8000123456"

  Scenario: Requirement 6 - ShipFrom is empty element
    Given the source file "tests/fixtures/source_delvry07_full.xml"
    When I transform the source using the XSLT
    Then the element "//ns0:ShipFrom" should exist
    And the element "//ns0:ShipFrom" should be empty

  Scenario: Requirement 7 - ShipTo is empty element
    Given the source file "tests/fixtures/source_delvry07_full.xml"
    When I transform the source using the XSLT
    Then the element "//ns0:ShipTo" should exist
    And the element "//ns0:ShipTo" should be empty

  Scenario: Requirement 8 - DivisionGroup is empty element
    Given the source file "tests/fixtures/source_delvry07_full.xml"
    When I transform the source using the XSLT
    Then the element "//ns0:DivisionGroup" should exist
    And the element "//ns0:DivisionGroup" should be empty

  Scenario: Requirement 9 - DispatchDimensionArea Weight when BTGEW not empty
    Given the source file "tests/fixtures/source_delvry07_full.xml"
    When I transform the source using the XSLT
    Then the XPath "//ns0:DispatchHead/ns0:DispatchDimensionArea/ns0:Weight/text()" should equal "125.50"

  Scenario: Requirement 10 - DispatchDimensionArea Volume when VOLUM not empty
    Given the source file "tests/fixtures/source_delvry07_full.xml"
    When I transform the source using the XSLT
    Then the XPath "//ns0:DispatchHead/ns0:DispatchDimensionArea/ns0:Volume/text()" should equal "2.75"

  Scenario: Requirement 11 - ShipUnitQuantity from ANZPK
    Given the source file "tests/fixtures/source_delvry07_full.xml"
    When I transform the source using the XSLT
    Then the XPath "//ns0:ShipUnitQuantity/text()" should equal "5"

  Scenario: Requirement 12 - TransportId when BOLNR exists
    Given the source file "tests/fixtures/source_delvry07_full.xml"
    When I transform the source using the XSLT
    Then the XPath "//ns0:TransportArea/ns0:TransportId/ns0:Id/text()" should equal "BOL2025001"

  Scenario: Requirement 13 - TransportDate formatted from CREDAT and CRETIM
    Given the source file "tests/fixtures/source_delvry07_full.xml"
    When I transform the source using the XSLT
    Then the XPath "//ns0:TransportDate/text()" should equal "2025-01-07T14:35:30"

  # Requirements 14-17: Pallet (E1EDL37)

  Scenario: Requirement 14 - PalletId from EXIDV2 when present
    Given the source file "tests/fixtures/source_delvry07_full.xml"
    When I transform the source using the XSLT
    Then the XPath "(//ns0:Pallet)[1]/ns0:PalletId/ns0:Id/text()" should equal "PAL001-EXT"

  Scenario: Requirement 15 - PalletTypeId B1 when MAGRV is Z001
    Given the source file "tests/fixtures/source_delvry07_full.xml"
    When I transform the source using the XSLT
    Then the XPath "(//ns0:Pallet)[1]/ns0:PalletTypeId/ns0:Id/text()" should equal "B1"

  Scenario: Requirement 15b - PalletTypeId P2 when MAGRV is not Z001
    Given the source file "tests/fixtures/source_delvry07_full.xml"
    When I transform the source using the XSLT
    Then the XPath "(//ns0:Pallet)[2]/ns0:PalletTypeId/ns0:Id/text()" should equal "P2"

  Scenario: Requirement 16 - PalletDimensionArea Volume formatted
    Given the source file "tests/fixtures/source_delvry07_full.xml"
    When I transform the source using the XSLT
    Then the XPath "(//ns0:Pallet)[1]/ns0:PalletDimensionArea/ns0:Volume/text()" should equal "1.25"

  Scenario: Requirement 17 - PalletDimensionArea Weight formatted
    Given the source file "tests/fixtures/source_delvry07_full.xml"
    When I transform the source using the XSLT
    Then the XPath "(//ns0:Pallet)[1]/ns0:PalletDimensionArea/ns0:Weight/text()" should equal "45.75"

  # Requirements 19-26: PalletContentItem (E1EDL44)

  Scenario: Requirement 19 - PartId Id from MATNR
    Given the source file "tests/fixtures/source_delvry07_full.xml"
    When I transform the source using the XSLT
    Then the XPath "(//ns0:PalletContentItem//ns0:PartId)[1]/ns0:Id/text()" should equal "MAT12345"

  Scenario: Requirement 20 - PartId Revision is one space
    Given the source file "tests/fixtures/source_delvry07_full.xml"
    When I transform the source using the XSLT
    Then the XPath "(//ns0:PalletContentItem//ns0:PartId)[1]/ns0:Revision/text()" should equal " "

  Scenario: Requirement 21 - PartId Division from WERKS
    Given the source file "tests/fixtures/source_delvry07_full.xml"
    When I transform the source using the XSLT
    Then the XPath "(//ns0:PalletContentItem//ns0:PartId)[1]/ns0:Division/text()" should equal "1000"

  Scenario: Requirement 22 - AdvisedQuantity formatted from VEMNG
    Given the source file "tests/fixtures/source_delvry07_full.xml"
    When I transform the source using the XSLT
    Then the XPath "(//ns0:PalletContentItem//ns0:AdvisedQuantity)[1]/text()" should equal "100.50"

  Scenario: Requirement 23 - AdvisedUnit converted from KGM to KG
    Given the source file "tests/fixtures/source_delvry07_full.xml"
    When I transform the source using the XSLT
    Then the XPath "(//ns0:PalletContentItem//ns0:AdvisedUnit)[1]/text()" should equal "KG"

  Scenario: Requirement 23b - AdvisedUnit converted from NAR to EA
    Given the source file "tests/fixtures/source_delvry07_full.xml"
    When I transform the source using the XSLT
    Then the XPath "(//ns0:PalletContentItem//ns0:AdvisedUnit)[2]/text()" should equal "EA"

  Scenario: Requirement 23c - AdvisedUnit converted from BG to BAG
    Given the source file "tests/fixtures/source_delvry07_full.xml"
    When I transform the source using the XSLT
    Then the XPath "(//ns0:PalletContentItem//ns0:AdvisedUnit)[3]/text()" should equal "BAG"

  Scenario: Requirement 24 - LotInfo LotId Id from CHARG when present
    Given the source file "tests/fixtures/source_delvry07_full.xml"
    When I transform the source using the XSLT
    Then the XPath "(//ns0:PalletContentItem//ns0:LotInfo)[1]/ns0:LotId/ns0:Id/text()" should equal "BATCH2025001"

  Scenario: Requirement 26 - LotInfo SupplierId from ancestor E1ADRM1
    Given the source file "tests/fixtures/source_delvry07_full.xml"
    When I transform the source using the XSLT
    Then the XPath "(//ns0:PalletContentItem//ns0:LotInfo)[1]/ns0:LotId/ns0:SupplierId/text()" should equal "SUPPLIER001"

  # Edge Cases

  Scenario: Edge case - Empty BTGEW and VOLUM should not generate DispatchDimensionArea
    Given the source file "tests/fixtures/source_empty_elements.xml"
    When I transform the source using the XSLT
    Then the element "//ns0:DispatchHead/ns0:DispatchDimensionArea" should not exist

  Scenario: Edge case - Missing BOLNR should not generate TransportId
    Given the source file "tests/fixtures/source_no_bolnr.xml"
    When I transform the source using the XSLT
    Then the element "//ns0:TransportId" should not exist

  Scenario: Edge case - EXIDV2 empty should use EXIDV
    Given the source file "tests/fixtures/source_no_exidv2.xml"
    When I transform the source using the XSLT
    Then the XPath "//ns0:PalletId/ns0:Id/text()" should equal "PAL005"

  Scenario: Edge case - Empty CHARG should not generate LotInfo
    Given the source file "tests/fixtures/source_no_charg.xml"
    When I transform the source using the XSLT
    Then the element "//ns0:LotInfo" should not exist

  # Integration Test

  Scenario: Integration - Complete DELVRY07 to DispatchSync transformation
    Given the source file "tests/fixtures/source_delvry07_full.xml"
    When I transform the source using the XSLT
    Then the transformation should succeed
    And the output should be valid XML
    And the element "//ns0:DispatchSync" should exist
    And the element "//ns0:ControlArea" should exist
    And the element "//ns0:DataArea" should exist
    And the element "//ns0:Dispatch" should exist
    And the element "//ns0:DispatchHead" should exist
    Then the XPath "count(//ns0:Pallet)" should equal "2"
    And the XPath "count(//ns0:PalletContentItem)" should equal "2"
