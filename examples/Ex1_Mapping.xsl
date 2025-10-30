<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<xsl:output method="xml" indent="yes"/>
	<xsl:template match="/">
		<SYSTAT01>
			<IDOC BEGIN="1">
				<EDI_DC40 SEGMENT="1">
					<TABNAM>EDI_DC40</TABNAM>
					<DIRECT>2</DIRECT>
					<IDOCTYP>SYSTAT01</IDOCTYP>
					<MESTYP>STATUS</MESTYP>
					<SNDPOR>
						<xsl:text/>
					</SNDPOR>
					<SNDPRT>LS</SNDPRT>
					<SNDPRN>ASTROFI</SNDPRN>
					<RCVPOR>
						<xsl:text/>
					</RCVPOR>
					<RCVPRN>ASTROFI</RCVPRN>
				</EDI_DC40>
				<E1STATS SEGMENT="1">
					<DOCNUM>
						<xsl:value-of select="/ConfirmBOD/DataArea/BOD/OriginalReferenceId/Id"/>
					</DOCNUM>
					<STATUS>
						<xsl:choose>
							<xsl:when test="/ConfirmBOD/DataArea/BOD/SuccessCode = 'Y'">
								<xsl:text>41</xsl:text>
							</xsl:when>
							<xsl:when test="/ConfirmBOD/DataArea/BOD/SuccessCode = 'N'">
								<xsl:text>40</xsl:text>
							</xsl:when>
						</xsl:choose>
					</STATUS>
					<STATYP>
						<xsl:choose>
							<xsl:when test="/ConfirmBOD/DataArea/BOD/SuccessCode = 'Y'">
								<xsl:text>S</xsl:text>
							</xsl:when>
							<xsl:when test="/ConfirmBOD/DataArea/BOD/SuccessCode = 'N'">
								<xsl:text>E</xsl:text>
							</xsl:when>
						</xsl:choose>
					</STATYP>
					<STATXT>
						<xsl:value-of select="/ConfirmBOD/DataArea/BOD/Description"/>
					</STATXT>
					<STAPA1>
						<xsl:value-of select="/ConfirmBOD/DataArea/BOD/Description"/>
					</STAPA1>
					<STAMID>
						<xsl:text>ZASTRO</xsl:text>
					</STAMID>
					<STAMNO>
						<xsl:choose>
							<xsl:when test="/ConfirmBOD/DataArea/BOD/SuccessCode = 'Y'">
								<xsl:text>001</xsl:text>
							</xsl:when>
							<xsl:when test="/ConfirmBOD/DataArea/BOD/SuccessCode = 'N'">
								<xsl:text>002</xsl:text>
							</xsl:when>
						</xsl:choose>
					</STAMNO>
				</E1STATS>
			</IDOC>
		</SYSTAT01>
	</xsl:template>
</xsl:stylesheet><!-- Stylus Studio meta-information - (c) 2004-2009. Progress Software Corporation. All rights reserved.

<metaInformation>
	<scenarios/>
	<MapperMetaTag>
		<MapperInfo srcSchemaPathIsRelative="yes" srcSchemaInterpretAsXML="no" destSchemaPath="" destSchemaRoot="" destSchemaPathIsRelative="yes" destSchemaInterpretAsXML="no"/>
		<MapperBlockPosition></MapperBlockPosition>
		<TemplateContext></TemplateContext>
		<MapperFilter side="source"></MapperFilter>
	</MapperMetaTag>
</metaInformation>
-->