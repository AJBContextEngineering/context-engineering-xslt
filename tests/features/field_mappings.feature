Feature: XSLT Field Mappings for DELVRY07 to OrderSync/PartSync
  As a data integration developer
  I want to transform DELVRY07 IDoc messages to OrderSync/PartSync formats
  So that SAP delivery data can be integrated with the target system

  Background:
    Given the XSLT transformation file exists at "src/mapping.xsl"

  Scenario: Map fixed value to Confirmation field
    Given a source DELVRY07 IDoc document at "tests/fixtures/source_idoc.xml"
    When the XSLT transformation is applied
    Then the output should contain element "Confirmation" with value "2"
    And the Confirmation element should be under PartSync/ControlArea/Sender

  Scenario: Map VBELN to OrderHeadId/Id
    Given a source DELVRY07 IDoc document at "tests/fixtures/source_idoc.xml"
    When the XSLT transformation is applied
    Then the output should contain element "Id" with value "OrderId12345"
    And the Id element should be under OrderSync/DataArea/Order/OrderHead/OrderHeadId

  Scenario: Map WERKS to Division
    Given a source DELVRY07 IDoc document at "tests/fixtures/source_idoc.xml"
    When the XSLT transformation is applied
    Then the output should contain element "Division" with value "Plant01"
    And the Division element should be under OrderSync/DataArea/Order/OrderHead/OrderHeadId

  Scenario: Map NAME1 with PARTNER_Q Y1 to OurReference
    Given a source DELVRY07 IDoc document at "tests/fixtures/source_idoc.xml"
    When the XSLT transformation is applied
    Then the output should contain element "OurReference" with value "Reference Name Y1"
    And the OurReference element should be under OrderSync/DataArea/Order/OrderHead

  Scenario: Handle missing PARTNER_Q Y1 element
    Given a source DELVRY07 IDoc document at "tests/fixtures/edge_case_no_partner.xml"
    When the XSLT transformation is applied
    Then the output should not contain element "OurReference"
    But the output should still contain element "Id"
    And the output should still contain element "Division"
    And the output should still contain element "Confirmation"

  Scenario: Handle wrong PARTNER_Q value
    Given a source DELVRY07 IDoc document at "tests/fixtures/edge_case_wrong_partner.xml"
    When the XSLT transformation is applied
    Then the output should not contain element "OurReference"
    But the output should still contain element "Id"
    And the output should still contain element "Division"

  Scenario: Complete transformation with all mappings
    Given a source DELVRY07 IDoc document at "tests/fixtures/source_idoc.xml"
    When the XSLT transformation is applied
    Then the output should be valid XML
    And the output should contain all required elements:
      | Element      | Value              |
      | Confirmation | 2                  |
      | Id           | OrderId12345       |
      | Division     | Plant01            |
      | OurReference | Reference Name Y1  |

  Scenario: Transformation produces well-formed XML structure
    Given a source DELVRY07 IDoc document at "tests/fixtures/source_idoc.xml"
    When the XSLT transformation is applied
    Then the output should be valid XML
    And the output should have root element "Root"
    And the output should contain element "PartSync"
    And the output should contain element "OrderSync"
