## Requirements:

## Requirement 1

Source XPath:
Source Cardinality:
Target XPath: /DispatchSync/ControlArea/Sender/Confirmation/text()
Target Cardinality: {1..1}
Special Rules: Fixed value '2'

## Requirement 2

Source XPath:
Source Cardinality:
Target XPath: /DispatchSync/ControlArea/CreationDateTime/text()
Target Cardinality: {1..1}
Special Rules: Provide the current date and time in the format YYYY-MM-DDThh:mm:ss

## Requirement 3

Source XPath: /DELVRY07/IDOC/EDI_DC40/DOCNUM
Source Cardinality: {1..1}
Target XPath: /DispatchSync/ControlArea/ReferenceId/Id/text()
Target Cardinality: {1..1}
Special Rules: Remove leading zeroes.

## Requirement 4

Source XPath:
Source Cardinality:
Target XPath: /DispatchSync/DataArea/Sync/ActionCriteria/@action/text()
Target Cardinality: {1..1}
Special Rules: Fixed value 'Add'

## Requirement 5

Source XPath: /DELVRY07/IDOC/E1EDL20/VBELN/text()
Source Cardinality:  {1..1}
Target XPath: /DispatchSync/DataArea/Dispatch/DispatchHead/DispatchId/Id/text()
Target Cardinality: {1..1}
Special Rules:

## Requirement 6

Source XPath:
Source Cardinality: 
Target XPath: /DispatchSync/DataArea/Dispatch/DispatchHead/ShipFrom
Target Cardinality: {1..1}
Special Rules: Provide as an empty element.

## Requirement 7

Source XPath:
Source Cardinality: 
Target XPath: /DispatchSync/DataArea/Dispatch/DispatchHead/ShipTo
Target Cardinality: {1..1}
Special Rules: Provide as an empty element.

## Requirement 8

Source XPath:
Source Cardinality: 
Target XPath: /DispatchSync/DataArea/Dispatch/DispatchHead/DivisionGroup
Target Cardinality: {1..1}
Special Rules: Provide as an empty element.

## Requirement 9

Source XPath:
Source Cardinality: 
Target XPath: /DispatchSync/DataArea/Dispatch/DispatchHead/DispatchDimensionArea/Weight/text()
Target Cardinality: {1..1}
Special Rules: If /DELVRY07/IDOC/E1EDL20/BTGEW/text() is not empty and /DELVRY07/IDOC/E1EDL20/VOLUM is not empty then calculate as follows:
format-number(round(/DELVRY07/IDOC/E1EDL20/BTGEW * 100) div 100, '0.00').
Only generate element DispatchDimensionArea if weight/text() will contain a value.

## Requirement 10

Source XPath:
Source Cardinality: 
Target XPath: /DispatchSync/DataArea/Dispatch/DispatchHead/DispatchDimensionArea/Volume/text()
Target Cardinality: {1..1}
Special Rules: If /DELVRY07/IDOC/E1EDL20/BTGEW/text() is not empty and /DELVRY07/IDOC/E1EDL20/VOLUM is not empty then calculate as follows:
format-number(round(/DELVRY07/IDOC/E1EDL20/VOLUM * 100) div 100, '0.00').
Only generate element DispatchDimensionArea if Volume/text() will contain a value.

## Requirement 11

Source XPath: /DELVRY07/IDOC/E1EDL20/ANZPK/text()
Source Cardinality:  {1..1}
Target XPath: /DispatchSync/DataArea/Dispatch/DispatchHead/ShipUnitQuantity/text()
Target Cardinality: {1..1}
Special Rules:

## Requirement 12

Source XPath: /DELVRY07/IDOC/E1EDL20/BOLNR/text()
Source Cardinality:  {1..1}
Target XPath: /DispatchSync/DataArea/Dispatch/DispatchHead/TransportArea/TransportId/Id/text()
Target Cardinality: {1..1}
Special Rules: Only generate if boolean(/DELVRY07/IDOC/E1EDL20/BOLNR) is true.

## Requirement 13

Source XPath:
Source Cardinality:
Target XPath: /DispatchSync/DataArea/Dispatch/DispatchHead/TransportArea/TransportDate/text()
Target Cardinality: {1..1}
Special Rules: Target text value is concat(substring(/DELVRY07/IDOC/EDI_DC40/CREDAT, 1, 4), '-', substring(/DELVRY07/IDOC/EDI_DC40/CREDAT, 5, 2), '-', substring(/DELVRY07/IDOC/EDI_DC40/CREDAT, 7, 2), 'T', substring(/DELVRY07/IDOC/EDI_DC40/CRETIM, 1, 2), ':', substring(/DELVRY07/IDOC/EDI_DC40/CRETIM, 3, 2), ':', substring(/DELVRY07/IDOC/EDI_DC40/CRETIM, 5, 2))

## Requirement 14

Source XPath: /DELVRY07/IDOC/E1EDL20/E1EDL37
Source Cardinality:  {1..*}
Target XPath: /DispatchSync/DataArea/Dispatch/Pallet/PalletId/Id/text()
Target Cardinality: {1..*}
Special Rules: If EXIDV2 exists in the context, then text = EXIDV2. Otherwise, if EXIDV exists, then text = EXIDV.

## Requirement 15

Source XPath: /DELVRY07/IDOC/E1EDL20/E1EDL37
Source Cardinality:  {1..*}
Target XPath: /DispatchSync/DataArea/Dispatch/Pallet/PalletTypeId/Id/text()
Target Cardinality: {1..*}
Special Rules: If MAGRV in the context = 'Z001', set text() = 'B1'. Otherwise set text() = 'P2'.

## Requirement 16

Source XPath: /DELVRY07/IDOC/E1EDL20/E1EDL37
Source Cardinality:  {1..*}
Target XPath: /DispatchSync/DataArea/Dispatch/Pallet/PalletDimensionArea/Volume/text()
Target Cardinality: {1..*}
Special Rules: Take the value in the context element BTVOL, round it to 2 decimal places, and display it with exactly 2 decimal places (adding zeros if needed).

## Requirement 17

Source XPath: /DELVRY07/IDOC/E1EDL20/E1EDL37
Source Cardinality:  {1..*}
Target XPath: /DispatchSync/DataArea/Dispatch/Pallet/PalletDimensionArea/Weight/text()
Target Cardinality: {1..*}
Special Rules: Take the value in the context element BRGEW, round it to 2 decimal places, and display it with exactly 2 decimal places (adding zeros if needed).

## Requirement 18

Source XPath: /DELVRY07/IDOC/E1EDL20/E1EDL37
Source Cardinality: {1..*}
Target XPath: /DispatchSync/DataArea/Dispatch/Pallet/PalletContent/PalletContentItem
Target Cardinality: {1..1}
Special Rules: Generate as static structure with <xsl:apply-templates select="E1EDL44"/> inside the PalletContentItem element.

## Requirement 19

Source XPath: /DELVRY07/IDOC/E1EDL20/E1EDL37/E1EDL44/MATNR
Source Cardinality: {1..*}
Target XPath: /DispatchSync/DataArea/Dispatch/Pallet/PalletContent/PalletContentItem/PartId/Id
Target Cardinality: {1..*}
Special Rules: 

## Requirement 20

Source XPath: /DELVRY07/IDOC/E1EDL20/E1EDL37/E1EDL44
Source Cardinality: {1..*}
Target XPath: /DispatchSync/DataArea/Dispatch/Pallet/PalletContent/PalletContentItem/PartId/Revision
Target Cardinality: {1..*}
Special Rules: Fixed text one blank space.

## Requirement 21

Source XPath: /DELVRY07/IDOC/E1EDL20/E1EDL37/E1EDL44/WERKS
Source Cardinality: {1..*}
Target XPath: /DispatchSync/DataArea/Dispatch/Pallet/PalletContent/PalletContentItem/PartId/Division
Target Cardinality: {1..*}
Special Rules: 

## Requirement 22

Source XPath: /DELVRY07/IDOC/E1EDL20/E1EDL37/E1EDL44/VEMNG
Source Cardinality: {1..*}
Target XPath: /DispatchSync/DataArea/Dispatch/Pallet/PalletContent/PalletContentItem/AdvisedQuantity
Target Cardinality: {1..*}
Special Rules: Take the value in the context element VEMNG22, round it to 2 decimal places, and display it with exactly 2 decimal places (adding zeros if needed).

## Requirement 23

Source XPath: /DELVRY07/IDOC/E1EDL20/E1EDL37/E1EDL44/VEMEH
Source Cardinality: {1..*}
Target XPath: /DispatchSync/DataArea/Dispatch/Pallet/PalletContent/PalletContentItem/AdvisedUnit
Target Cardinality: {1..*}
Special Rules: Convert the value of VEMEH as follows:
'BG' -> 'BAG'

'NAR' -> 'EA'

'KGM' -> 'KG'

'LTR' -> 'L'

'MTR' -> 'M'

'MTK' -> 'M2'

'PR' -> 'PAA'

'PK' -> 'PAK'

## Requirement 24

Source XPath: /DELVRY07/IDOC/E1EDL20/E1EDL37/E1EDL44/CHARG
Source Cardinality: {1..*}
Target XPath: /DispatchSync/DataArea/Dispatch/Pallet/PalletContent/PalletContentItem/LotInfo/LotId/Id
Target Cardinality: {1..*}
Special Rules: Only provide this element in the output if there is something in the CHARG element.

## Requirement 25

Source XPath: /DELVRY07/IDOC/E1EDL20/E1EDL37/E1EDL44/CHARG
Source Cardinality: {1..*}
Target XPath: /DispatchSync/DataArea/Dispatch/Pallet/PalletContent/PalletContentItem/LotInfo/LotId/Id
Target Cardinality: {1..*}
Special Rules: Only provide this element in the output if there is something in the CHARG element.

## Requirement 26

Source XPath: .
Source Cardinality: {1..*}
Target XPath: /DispatchSync/DataArea/Dispatch/Pallet/PalletContent/PalletContentItem/LotInfo/LotId/SupplierId
Target Cardinality: {1..*}
Special Rules: Using the ancestor:: axis command, Go up the XPath Data Model from the current context to the nearest E1EDL20 section, find the E1ADRM1 element where the partner qualifier is 'LF', and use PARTNER_ID.

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
