## FEATURE:

We want to create an MCP server using this repos template.

The goal of the MCP server is to be passed in an XPath element and the XSD schema files, and to return only the subset of the XSD that's relevant to validating the elements/attributes selected by that XPath.

### Feature #1

The XSD Schema files are located in the projects repository under the /xsd folder and is read by the MCP server and stored as a variable.

Reason: we only want to load the XSD schema once into the MCP server when the MCP server is instantiated, not every time it is accessed.

### Feature #2

When the relevant XSD fragment for the XPath element is returned, so are all of the dependent XSD parts.

Reason: we want to pass back a complete description of the XSD schema to allow the recipient LLM to have all of the relevant XSD schema parts in its context.

### Feature #3

The function that will return the XSD parts will be called retrieve_xsd_fragments and it should be decorated with an annotation that names the MCP Tool 'retrieve-xsd-fragments'.

Reason: we want to name the MCP Tool ourselves.

### Feature #4

The function contains a Python docstring that helps the LLM identify the correct usage of the tool, and it is to describe that it is passed in an XPath element and the XSD schema file name, and it returns only the subset of the XSD that's relevant to validating the elements/attributes selected by that XPath.

Reason: we want the LLM to know what this tool is for and when it should use it. Also what arguments are passed in and what is returned.

## EXAMPLES:

In examples/ is the following example file:

- Example_input_output.md - shows the input XPath that would be passed in, and the returned XSD fragments.

## DOCUMENTATION:

[List out any documentation (web pages, sources for an MCP server like Crawl4AI RAG, etc.) that will need to be referenced during development]

## OTHER CONSIDERATIONS:

[Any other considerations or specific requirements - great place to include gotchas that you see AI coding assistants miss with your projects a lot]
