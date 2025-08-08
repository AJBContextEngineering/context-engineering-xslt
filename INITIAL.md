## FEATURE:

### Feature #1

Map the following fields in the XSLT Mapping:

Source Field: Fixed value '2'

Target Field: /PartSync/ControlArea/Sender/Confirmation

Additional requirements: None

### Feature #2

Map the following fields in the XSLT Mapping:

Source Field: /DELVRY07/ZASTRO_DELVRY07/IDOC/E1EDL20/VBELN

Target Field: /OrderSync/DataArea/Order/OrderHead/OrderHeadId/Id

### Feature #3

Map the following fields in the XSLT Mapping:

Source Field: /DELVRY07/ZASTRO_DELVRY07/IDOC/E1EDL20/E1EDL24/WERKS

Target Field: /OrderSync/DataArea/Order/OrderHead/OrderHeadId/Division

### Feature #4

Map the following fields in the XSLT Mapping:

Source Field: /DELVRY07/ZASTRO_DELVRY07/IDOC/E1EDL20/E1ADRM1[PARTNER_Q='Y1']/NAME1

Target Field: /OrderSync/DataArea/Order/OrderHead/OurReference

## EXAMPLES:

In examples/ are the following example XSLT files:

- I403_Mapping.xsl - a very simple XSL mapping file
- I405_ZRDA_V2.xsl - a very simple XSL mapping file
- I407_GoodsReceipt_AstroFI_ECC.xsl - a very simple XSL mapping file
- Z_I149_TELEMA_INVOIC.xsl - a more complex XSL mapping file. Shows how I like templates to be applied.
- Z_I152_TELEMA_ORDER.xsl - a more complex XSL mapping file. Shows how I like templates to be applied.

## DOCUMENTATION:

[List out any documentation (web pages, sources for an MCP server like Crawl4AI RAG, etc.) that will need to be referenced during development]

## OTHER CONSIDERATIONS:

[Any other considerations or specific requirements - great place to include gotchas that you see AI coding assistants miss with your projects a lot]
