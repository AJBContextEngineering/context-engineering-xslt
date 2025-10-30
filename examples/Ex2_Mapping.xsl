<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"  xmlns:ns0="http://www.nwn.com/turf/project" >
	<xsl:output method="xml" indent="yes"/>
	<xsl:template match="/">
		<ns0:PurchaseOrderSync version="0100">
			<ns0:ControlArea>
				<ns0:Sender>
					<ns0:Confirmation>2</ns0:Confirmation>
				</ns0:Sender>
				<ns0:CreationDateTime>
					<xsl:value-of select="concat(substring(/DELVRY07/IDOC/EDI_DC40/CREDAT, 1, 4), '-', substring(/DELVRY07/IDOC/EDI_DC40/CREDAT, 5, 2), '-', substring(/DELVRY07/IDOC/EDI_DC40/CREDAT, 7, 2), 'T', substring(/DELVRY07/IDOC/EDI_DC40/CRETIM, 1, 2), ':', substring(/DELVRY07/IDOC/EDI_DC40/CRETIM, 3, 2), ':', substring(/DELVRY07/IDOC/EDI_DC40/CRETIM, 5, 2))"/>
				</ns0:CreationDateTime>
				<ns0:ReferenceId>
					<ns0:Id>
						<xsl:value-of select="translate(/DELVRY07/IDOC/EDI_DC40/DOCNUM, '0', '')"/>
					</ns0:Id>
				</ns0:ReferenceId>
			</ns0:ControlArea>
			<ns0:DataArea>
				<ns0:Sync>
					<ns0:ActionCriteria>
						<xsl:attribute name="action">Replace</xsl:attribute>
					</ns0:ActionCriteria>
				</ns0:Sync>
				<ns0:PurchaseOrder>
					<ns0:PurchaseOrderHead>
						<ns0:PurchaseOrderHeadId>
							<ns0:Id>
								<xsl:value-of select="/DELVRY07/IDOC/E1EDL20/VBELN"/>
							</ns0:Id>
							<ns0:Division>
								<xsl:value-of select="/DELVRY07/IDOC/E1EDL20/E1EDL24/WERKS"/>
							</ns0:Division>
						</ns0:PurchaseOrderHeadId>
						<ns0:PurchaseOrderType>4</ns0:PurchaseOrderType>
						<ns0:PurchaseOrderSupplierArea>
							<ns0:Name>
								<xsl:value-of select="/DELVRY07/IDOC/E1EDL20/E1ADRM1[PARTNER_Q='WE']/NAME1"/>
							</ns0:Name>
						</ns0:PurchaseOrderSupplierArea>
					</ns0:PurchaseOrderHead>
					<xsl:apply-templates select="DELVRY07/IDOC/E1EDL20/E1EDL24"/>
				</ns0:PurchaseOrder>
			</ns0:DataArea>
		</ns0:PurchaseOrderSync>
	</xsl:template>

	<xsl:template match="DELVRY07/IDOC/E1EDL20/E1EDL24">
		<ns0:PurchaseOrderLine>
			<ns0:PurchaseOrderLineId>
				<ns0:PurchaseOrderHeadId>
					<xsl:value-of select="parent::E1EDL20/VBELN"/>
				</ns0:PurchaseOrderHeadId>
				<ns0:Division>
					<xsl:value-of select="WERKS"/>
				</ns0:Division>
				<ns0:Id>
					<xsl:value-of select="POSNR"/>
				</ns0:Id>
			</ns0:PurchaseOrderLineId>
			<ns0:PartId>
				<ns0:Id>
					<xsl:value-of select="MATNR"/>
				</ns0:Id>
				<ns0:Revision> </ns0:Revision>
				<ns0:Division>
					<xsl:value-of select="WERKS"/>
				</ns0:Division>
			</ns0:PartId>
			<ns0:PurchaseOrderLineType>4</ns0:PurchaseOrderLineType>
			<ns0:DeliveryDate>
				<xsl:value-of select="concat(substring(E1EDL43[QUALF='H']/DATUM, 1, 4), '-', substring(E1EDL43[QUALF='H']/DATUM, 5, 2), '-', substring(E1EDL43[QUALF='H']/DATUM, 7, 2))"/>
			</ns0:DeliveryDate>
			<ns0:OrderedQuantity>
				<xsl:value-of select="format-number(round(LFIMG * 100) div 100, '0.00')"/>
			</ns0:OrderedQuantity>
			<ns0:PartDescription>
				<xsl:value-of select="ARKTX"/>
			</ns0:PartDescription>
			<ns0:DeliveredUnit>
				<xsl:value-of select="VRKME"/>
			</ns0:DeliveredUnit>
			<ns0:ConversionFactorDeliveredUnit>1</ns0:ConversionFactorDeliveredUnit>
				<ns0:SupplierNumber>
					<xsl:value-of select="parent::E1EDL20/E1ADRM1[PARTNER_Q='AG']/PARTNER_ID"/>							
				</ns0:SupplierNumber>
		</ns0:PurchaseOrderLine>
	</xsl:template>
</xsl:stylesheet>
<!-- Stylus Studio meta-information - (c) 2004-2009. Progress Software Corporation. All rights reserved.

<metaInformation>
	<scenarios>
		<scenario default="yes" name="IDoc 457033680 " userelativepaths="yes" externalpreview="no" url="..\XML\IDoc 457033680 .xml" htmlbaseurl="" outputurl="..\XML\IDoc 457033680 Output from I405_ZRDA_v2.xml" processortype="saxon8" useresolver="yes"
		          profilemode="0" profiledepth="" profilelength="" urlprofilexml="" commandline="" additionalpath="" additionalclasspath="" postprocessortype="none" postprocesscommandline="" postprocessadditionalpath="" postprocessgeneratedext=""
		          validateoutput="no" validator="internal" customvalidator="">
			<advancedProp name="bSchemaAware" value="true"/>
			<advancedProp name="xsltVersion" value="2.0"/>
			<advancedProp name="schemaCache" value="||"/>
			<advancedProp name="iWhitespace" value="0"/>
			<advancedProp name="bWarnings" value="true"/>
			<advancedProp name="bXml11" value="false"/>
			<advancedProp name="bUseDTD" value="false"/>
			<advancedProp name="bXsltOneIsOkay" value="true"/>
			<advancedProp name="bTinyTree" value="true"/>
			<advancedProp name="bGenerateByteCode" value="true"/>
			<advancedProp name="bExtensions" value="true"/>
			<advancedProp name="iValidation" value="0"/>
			<advancedProp name="iErrorHandling" value="fatal"/>
			<advancedProp name="sInitialTemplate" value=""/>
			<advancedProp name="sInitialMode" value=""/>
		</scenario>
	</scenarios>
	<MapperMetaTag>
		<MapperInfo srcSchemaPathIsRelative="yes" srcSchemaInterpretAsXML="no" destSchemaPath="" destSchemaRoot="" destSchemaPathIsRelative="yes" destSchemaInterpretAsXML="no"/>
		<MapperBlockPosition></MapperBlockPosition>
		<TemplateContext></TemplateContext>
		<MapperFilter side="source"></MapperFilter>
	</MapperMetaTag>
</metaInformation>
-->