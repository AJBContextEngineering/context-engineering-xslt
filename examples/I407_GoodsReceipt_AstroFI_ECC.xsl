<?xml version='1.0' ?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:a="http://www.consafelogistics.com/astro/project">
	<xsl:template match="/">
		<MBGMCR03>
			<IDOC BEGIN="1">
				<EDI_DC40 SEGMENT="1">
					<TABNAM>EDI_DC40</TABNAM>
					<DIRECT>2</DIRECT>
					<IDOCTYP>MBGMCR03</IDOCTYP>
					<MESTYP>MBGMCR</MESTYP>
					<SNDPOR><xsl:text></xsl:text></SNDPOR>
					<SNDPRT>LS</SNDPRT>
					<SNDPRN>ASTROFI</SNDPRN>
					<RCVPOR><xsl:text></xsl:text></RCVPOR>
					<RCVPRT>LS</RCVPRT>
					<RCVPRN>ASTROFI</RCVPRN>
				</EDI_DC40>
				<E1MBGMCR SEGMENT="1">
					<E1BP2017_GM_HEAD_01 SEGMENT="1">
						<xsl:variable name="postingYear" select="substring(DispatchHeadShow/DataArea/DispatchHead/TransportArea/TransportDate,1,4)"/>
						<xsl:variable name="postingMonth" select="substring(DispatchHeadShow/DataArea/DispatchHead/TransportArea/TransportDate,6,2)"/>
						<xsl:variable name="postingDay" select="substring(DispatchHeadShow/DataArea/DispatchHead/TransportArea/TransportDate,9,2)"/>
						<PSTNG_DATE>
							<xsl:value-of select="concat($postingYear,$postingMonth,$postingDay)"/>
						</PSTNG_DATE>
					</E1BP2017_GM_HEAD_01>
					<E1BP2017_GM_CODE SEGMENT="1">
						<GM_CODE>01</GM_CODE>
					</E1BP2017_GM_CODE>
					<xsl:apply-templates select="DispatchHeadShow/DataArea/ShipmentLine"/>
					<E1BP2017_GM_ITEM_CREATE SEGMENT="1">
						<MATERIAL>
							<xsl:value-of select="DispatchContentReceive/DataArea/DispatchContent/PartId/Id"/>
						</MATERIAL>
						<PLANT>
							<xsl:value-of select="DispatchContentReceive/DataArea/DispatchContent/PartId/Division"/>
						</PLANT>
						<BATCH>
							<xsl:value-of select="DispatchContentReceive/DataArea/DispatchContent/ReceivedReference/LotId/Id"/>
						</BATCH>
						<MOVE_TYPE>
							<xsl:choose>
								<xsl:when test="starts-with(DispatchContentReceive/DataArea/DispatchContent/PurchaseOrderLineId/PurchaseOrderHeadId,'4300')">
									<xsl:value-of select="101"/>
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="103"/>
								</xsl:otherwise>
							</xsl:choose>
						</MOVE_TYPE>
						<VENDOR>
							<xsl:value-of select="DispatchContentReceive/DataArea/DispatchContent/ReceivedReference/LotId/SupplierId"/>
						</VENDOR>
						<ENTRY_QNT>
							<xsl:value-of select="DispatchContentReceive/DataArea/DispatchContent/ReceivedReference/ReceivedQuantity"/>
						</ENTRY_QNT>
						<PO_NUMBER>
							<xsl:value-of select="DispatchContentReceive/DataArea/DispatchContent/PurchaseOrderLineId/PurchaseOrderHeadId"/>
						</PO_NUMBER>
						<PO_ITEM>
							<xsl:value-of select="DispatchContentReceive/DataArea/DispatchContent/PurchaseOrderLineId/Id"/>
						</PO_ITEM>
						<MVT_IND>B</MVT_IND>
					</E1BP2017_GM_ITEM_CREATE>
				</E1MBGMCR>
			</IDOC>
		</MBGMCR03>
	</xsl:template>
</xsl:stylesheet><!-- Stylus Studio meta-information - (c) 2004-2009. Progress Software Corporation. All rights reserved.

<metaInformation>
	<scenarios/>
	<MapperMetaTag>
		<MapperInfo srcSchemaPathIsRelative="yes" srcSchemaInterpretAsXML="no" destSchemaPath="..\XSD\MBGMCR.MBGMCR03.xsd" destSchemaRoot="MBGMCR03" destSchemaPathIsRelative="yes" destSchemaInterpretAsXML="no">
			<SourceSchema srcSchemaPath="..\..\..\..\..\..\..\..\..\Github\Onnela-Astro-schemas\Doc\DispatchContentReceive_0100.xsd" srcSchemaRoot="DispatchContentReceive" AssociatedInstance="" loaderFunction="document" loaderFunctionUsesURI="no"/>
		</MapperInfo>
		<MapperBlockPosition>
			<template match="/">
				<block path="MBGMCR03/IDOC/E1MBGMCR/E1BP2017_GM_HEAD_01/PSTNG_DATE/xsl:value-of" x="477" y="180"/>
				<block path="MBGMCR03/IDOC/E1MBGMCR/E1BP2017_GM_ITEM_CREATE/MOVE_TYPE/xsl:choose" x="407" y="85"/>
				<block path="MBGMCR03/IDOC/E1MBGMCR/E1BP2017_GM_ITEM_CREATE/MOVE_TYPE/xsl:choose/starts-with[0]" x="361" y="79"/>
				<block path="MBGMCR03/IDOC/E1MBGMCR/E1BP2017_GM_ITEM_CREATE/MOVE_TYPE/xsl:choose/xsl:when/xsl:value-of" x="517" y="115"/>
				<block path="MBGMCR03/IDOC/E1MBGMCR/E1BP2017_GM_ITEM_CREATE/MOVE_TYPE/xsl:choose/xsl:otherwise/xsl:value-of" x="357" y="115"/>
			</template>
		</MapperBlockPosition>
		<TemplateContext></TemplateContext>
		<MapperFilter side="source"></MapperFilter>
	</MapperMetaTag>
</metaInformation>
-->