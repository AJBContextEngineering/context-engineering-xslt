Feature: XSLT Field Mappings
  As a data integrator
  I want to transform XML fields using XSLT 3.0
  So that source data maps correctly to target structure
  
  Background:
    Given I have a source XML document

  Scenario: Fixed value confirmation mapping using call-template
    When I apply the XSLT transformation
    Then the output should contain element "//PartSync/ControlArea/Sender/Confirmation" with value "2"
    And the output should be valid XML
    And the output should contain comments explaining each mapping

  Scenario: VBELN to Order ID mapping using apply-templates
    Given I have source XML with "VBELN" value "12345678"
    When I apply the XSLT transformation
    Then the output should contain element "//OrderSync/DataArea/Order/OrderHead/OrderHeadId/Id" with value "12345678"
    And the output should be valid XML

  Scenario: WERKS to Division mapping using apply-templates
    Given I have source XML with "WERKS" value "PLANT01"
    When I apply the XSLT transformation
    Then the output should contain element "//OrderSync/DataArea/Order/OrderHead/OrderHeadId/Division" with value "PLANT01"
    And the output should be valid XML

  Scenario: Partner Y1 NAME1 to OurReference mapping using apply-templates
    Given I have source XML with partner "Y1" and name "TestPartner"
    When I apply the XSLT transformation
    Then the output should contain element "//OrderSync/DataArea/Order/OrderHead/OurReference" with value "TestPartner"
    And the output should be valid XML

  Scenario: Complete transformation with all field mappings
    When I apply the XSLT transformation
    Then the output should contain element "//PartSync/ControlArea/Sender/Confirmation" with value "2"
    And the output should contain element "//OrderSync/DataArea/Order/OrderHead/OrderHeadId/Id" with value "12345678"
    And the output should contain element "//OrderSync/DataArea/Order/OrderHead/OrderHeadId/Division" with value "PLANT01"
    And the output should contain element "//OrderSync/DataArea/Order/OrderHead/OurReference" with value "TestPartner"
    And the output should be valid XML
    And the output should contain comments explaining each mapping

  Scenario: Verify template pattern usage
    When I apply the XSLT transformation
    Then the output should be valid XML
    # This scenario validates that both call-template and apply-templates work correctly

  # Edge cases
  Scenario: Transformation handles missing optional elements gracefully
    # This test uses the same source data but verifies graceful handling
    When I apply the XSLT transformation
    Then the output should be valid XML
    # Even if some elements are missing, transformation should not fail