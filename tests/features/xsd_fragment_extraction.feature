Feature: XSD Fragment Extraction
  As an LLM using the MCP server
  I want to retrieve minimal XSD schema fragments for XPath queries
  So that I can understand XML validation rules without loading entire schemas

  Background:
    Given the XSD schemas are loaded from "xsd" directory
    And the schema "PartSync_0100.xsd" is available

  Scenario: Extract simple element with simple type
    When I query with XPath "/*[local-name()='PartSync']/*[local-name()='DataArea']/*[local-name()='Part']/*[local-name()='PartId']/*[local-name()='Id']"
    And schema file "PartSync_0100.xsd"
    Then the result should contain an element definition for "Id"
    And the result should contain a type definition for "PartId_0100"
    And the type definition should have a restriction base

  Scenario: Handle missing schema file
    When I query with XPath "/*[local-name()='Test']"
    And schema file "NonExistent.xsd"
    Then the result should contain an error message
    And the error should mention "not found"

  Scenario: Handle element not in schema
    When I query with XPath "/*[local-name()='NonExistentElement']"
    And schema file "PartSync_0100.xsd"
    Then the result should contain a warning
    And the warning should mention "not found in schema"
