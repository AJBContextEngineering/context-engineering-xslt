<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:sap="http://www.sap.com/sapxsl" xmlns:sdn="http://sdn.sap.com/sapxsl" version="1.0">

	<xsl:strip-space elements="*"/>
	<xsl:output indent="yes"/>

	<xsl:variable name="abap_engine" select="true()"/>

	<xsl:variable name="party_id" select="/EDIFACT/ORDERS/GROUP_2/NAD[NAD01-PartyQualifier = 'SE']/NAD02-PartyIdentificationDetails/NAD0201-PartyIdIdentification/text()"/>
	
	<xsl:variable name="sales_org">
		<xsl:choose>
			<xsl:when test="$party_id = '10232094'">E110</xsl:when>
			<xsl:when test="$party_id = '4740054000002'">E110</xsl:when>
			<xsl:when test="$party_id = '40003244865'">L110</xsl:when>
			<xsl:when test="$party_id = '4750761000004'">L110</xsl:when>
		</xsl:choose>
	</xsl:variable>

	<xsl:variable name="dist_chan">01</xsl:variable>

	<sap:external-function class="ZCL_I152" kind="class" method="MATERIAL_CHECK_EXISTENCE" name="sdn:check_exists">
		<sap:argument param="IM_MATNR" type="string"/>
		<sap:argument param="IM_VKORG" type="string"/>
		<sap:argument param="IM_VTWEG" type="string"/>
		<sap:argument param="IM_EAN" type="string"/>
		<sap:argument param="IM_PARMATNR" type="string"/>
		<sap:argument param="IM_KUNNR" type="string"/>
		<sap:result param="EX_EXISTS" type="string"/>
	</sap:external-function>


<xsl:template match="/">
		<ORDERS05>
			<IDOC BEGIN="1">
				<EDI_DC40 SEGMENT="1">
					<REFINT>
						<xsl:value-of select="EDIFACT/ORDERS/UNH/UNH01-MessageReferenceNumber"/>
					</REFINT>
				</EDI_DC40>
				<xsl:comment>Populating E1EDK01</xsl:comment>
				<E1EDK01 SEGMENT="1">
					<CURCY>
						<xsl:value-of select="EDIFACT/ORDERS/GROUP_7/CUX/CUX01-CurrencyDetails/CUX0102-CurrencyCoded"/>
					</CURCY>
				</E1EDK01>
				<!-- Populate E1EDK14 -->
				<xsl:apply-templates mode="E1EDK14" select="EDIFACT/ORDERS/GROUP_2"/>
				<!-- Populate Sales Order Type in E1EDK14 -->
				<xsl:apply-templates mode="E1EDK14" select="EDIFACT/ORDERS/BGM"/>

				<xsl:comment>Populating E1EDK03</xsl:comment>
				<xsl:apply-templates select="EDIFACT/ORDERS/DTM"/>

				<xsl:comment>Populating E1EDKA1</xsl:comment>
				<xsl:apply-templates select="EDIFACT/ORDERS/GROUP_2"/>
				<xsl:comment>Populating E1EDK02</xsl:comment>
				<E1EDK02 SEGMENT="1">
					<xsl:apply-templates select="EDIFACT/ORDERS/BGM"/>
				</E1EDK02>

				<!-- Populate the Text segments -->
				<xsl:apply-templates mode="E1EDKT1" select="EDIFACT/ORDERS/FTX"/>



				<xsl:for-each select="EDIFACT/ORDERS/GROUP_25">
					<!-- Check if the material exists; supply a dummy if it doesnt -->
					<xsl:variable name="material" select="PIA/PIA02-ItemNumberIdentification/PIA0201-ItemNumber/text()"/>
					<xsl:variable name="ean_code" select="LIN/LIN03-ItemNumberIdentification/LIN0301-ItemNumber/text()"/>
					<xsl:variable name="partner_material">
						<xsl:choose>
							<xsl:when test="PIA/PIA03-ItemNumberIdentification[PIA0302-ItemNumberTypeCoded = 'IN']/PIA0301-ItemNumber">
								<xsl:value-of select="PIA/PIA03-ItemNumberIdentification[PIA0302-ItemNumberTypeCoded = 'IN']/PIA0301-ItemNumber/text()"/>
							</xsl:when>
							<xsl:when test="PIA/PIA02-ItemNumberIdentification[PIA0202-ItemNumberTypeCoded = 'IN']/PIA0201-ItemNumber">
								<xsl:value-of select="PIA/PIA02-ItemNumberIdentification[PIA0202-ItemNumberTypeCoded = 'IN']/PIA0201-ItemNumber/text()"/>
							</xsl:when>
							<xsl:otherwise></xsl:otherwise>
						</xsl:choose>
					</xsl:variable>
					<xsl:variable name="customer" select="../GROUP_2/NAD[NAD01-PartyQualifier='BY']/NAD02-PartyIdentificationDetails/NAD0201-PartyIdIdentification/text()"/>

					<xsl:variable name="material_exists">
						<xsl:if test="$abap_engine">
							<xsl:value-of select="sdn:check_exists(string($material),string($sales_org),string($dist_chan),string($ean_code),string($partner_material),string($customer))"/>
						</xsl:if>
					</xsl:variable>
					<CUSTOMER><xsl:value-of select="$customer"/></CUSTOMER>
					<SALES_ORG><xsl:value-of select="$sales_org"/></SALES_ORG>
					<DIST_CHAN><xsl:value-of select="$dist_chan"/></DIST_CHAN>
					<MATERIAL><xsl:value-of select="$material"/></MATERIAL>
					<EAN_CODE><xsl:value-of select="$ean_code"/></EAN_CODE>
					<PARTNER_MATERIAL><xsl:value-of select="$partner_material"/></PARTNER_MATERIAL>
					<MATERIAL_EXISTS><xsl:value-of select="$material_exists"/></MATERIAL_EXISTS>

					<xsl:variable name="material_not_found_text">
						<xsl:value-of select="concat('Material ', $material, ' not found in system')"/>
					</xsl:variable>
					<E1EDP01 SEGMENT="1">
						<POSEX>
							<xsl:value-of select="(count(preceding::GROUP_25) + 1) * 10"/>
						</POSEX>
						<!-- Reason for Rejection code removed as result of email from T.Ojanaho 25092008 -->
						<!--<xsl:if test="not($material_exists = 'X')">-->
							<!--<ABGRU>Z1</ABGRU>-->
						<!--</xsl:if>-->
						<xsl:apply-templates select="QTY"/>
						<!-- Monetary amounts map to E1EDP05 -->
						<!--<xsl:apply-templates select="MOA"/>-->
						<xsl:apply-templates select="GROUP_28/PRI/PRI01-PriceInformation[PRI0101-PriceQualifier='AAA']"/>
						<xsl:choose>
							<xsl:when test="LIN/LIN03-ItemNumberIdentification/LIN0302-ItemNumberTypeCoded = 'EN'">
								<E1EDP19 SEGMENT="1">
									<QUALF>003</QUALF>
									<IDTNR>
										<xsl:value-of select="LIN/LIN03-ItemNumberIdentification/LIN0301-ItemNumber"/>
									</IDTNR>
								</E1EDP19>
							</xsl:when>
						</xsl:choose>

						<xsl:variable name="PIA_IN_VALUE">
							<xsl:choose>
								<xsl:when test="PIA/PIA03-ItemNumberIdentification[PIA0302-ItemNumberTypeCoded = 'IN']/PIA0301-ItemNumber">
									<xsl:value-of select="PIA/PIA03-ItemNumberIdentification[PIA0302-ItemNumberTypeCoded = 'IN']/PIA0301-ItemNumber"/>
								</xsl:when>
								<xsl:when test="PIA/PIA02-ItemNumberIdentification[PIA0202-ItemNumberTypeCoded = 'IN']/PIA0201-ItemNumber">
									<xsl:value-of select="PIA/PIA02-ItemNumberIdentification[PIA0202-ItemNumberTypeCoded = 'IN']/PIA0201-ItemNumber"/>
								</xsl:when>
								<xsl:otherwise>noValue</xsl:otherwise>
							</xsl:choose>
						</xsl:variable>
						<xsl:if test="$PIA_IN_VALUE != 'noValue'">
							<E1EDP19 SEGMENT="1">
								<QUALF>001</QUALF>
								<IDTNR>
									<xsl:value-of select="$PIA_IN_VALUE"/>
								</IDTNR>
							</E1EDP19>
						</xsl:if>

						<xsl:for-each select="PIA">
							<xsl:choose>
								<xsl:when test="PIA02-ItemNumberIdentification/PIA0202-ItemNumberTypeCoded = 'VP'">
									<E1EDP19 SEGMENT="1">
										<QUALF>002</QUALF>
										<IDTNR>
											<xsl:choose>
												<xsl:when test="$material_exists = 'X'">
													<xsl:value-of select="PIA02-ItemNumberIdentification/PIA0201-ItemNumber"/>
												</xsl:when>
												<xsl:otherwise>
													<xsl:value-of select="'ZZDUMMY'"/>
												</xsl:otherwise>
											</xsl:choose>
										</IDTNR>
									</E1EDP19>
								</xsl:when>
								<xsl:when test="PIA02-ItemNumberIdentification/PIA0202-ItemNumberTypeCoded = 'SA'">
									<E1EDP19 SEGMENT="1">
										<QUALF>002</QUALF>
										<IDTNR>
											<xsl:choose>
												<xsl:when test="$material_exists = 'X'">
													<xsl:value-of select="PIA02-ItemNumberIdentification/PIA0201-ItemNumber"/>
												</xsl:when>
												<xsl:otherwise>
													<xsl:value-of select="'ZZDUMMY'"/>
												</xsl:otherwise>
											</xsl:choose>
										</IDTNR>
									</E1EDP19>
								</xsl:when>
							</xsl:choose>
						</xsl:for-each>
					</E1EDP01>
				</xsl:for-each>
			</IDOC>
		</ORDERS05>
	</xsl:template>
	<xsl:template match="EDIFACT/ORDERS/BGM">
		<QUALF>001</QUALF>
		<BELNR>
			<xsl:value-of select="BGM02-DocumentMessageNumber"/>
		</BELNR>
	</xsl:template>
	<xsl:template match="EDIFACT/ORDERS/DTM">
		<E1EDK03 SEGMENT="1">
			<xsl:choose>
				<!-- Document Date/Time -->
				<xsl:when test="DTM01-DateTimePeriod/DTM0101-DateTimePeriodQualifier = '137'">
					<IDDAT>012</IDDAT>
					<DATUM>
						<xsl:value-of select="DTM01-DateTimePeriod/DTM0102-DateTimePeriod"/>
					</DATUM>
				</xsl:when>
				<!-- Requested Delivery Date/Time -->
				<xsl:when test="DTM01-DateTimePeriod/DTM0101-DateTimePeriodQualifier = '2'">
					<IDDAT>002</IDDAT>
					<DATUM>
						<xsl:value-of select="DTM01-DateTimePeriod/DTM0102-DateTimePeriod"/>
					</DATUM>
				</xsl:when>
				<!-- Order Date/Time -->
				<xsl:when test="DTM01-DateTimePeriod/DTM0101-DateTimePeriodQualifier = '4'">
					<IDDAT>029</IDDAT>
					<DATUM>
						<xsl:value-of select="DTM01-DateTimePeriod/DTM0102-DateTimePeriod"/>
					</DATUM>
				</xsl:when>
			</xsl:choose>
		</E1EDK03>
	</xsl:template>
	<xsl:template match="EDIFACT/ORDERS/GROUP_2">
		<xsl:for-each select="NAD">
			<xsl:choose>
				<xsl:when test="NAD01-PartyQualifier='BY'">
					<E1EDKA1 SEGMENT="1">
						<PARVW>AG</PARVW>
						<PARTN>
							<xsl:value-of select="NAD02-PartyIdentificationDetails/NAD0201-PartyIdIdentification"/>
						</PARTN>
					</E1EDKA1>
				</xsl:when>
				<xsl:when test="NAD01-PartyQualifier='DP'">
					<E1EDKA1 SEGMENT="1">
						<PARVW>WE</PARVW>
						<PARTN>
							<xsl:value-of select="NAD02-PartyIdentificationDetails/NAD0201-PartyIdIdentification"/>
						</PARTN>
					</E1EDKA1>
				</xsl:when>
			</xsl:choose>
		</xsl:for-each>
	</xsl:template>
	<xsl:template match="QTY">
		<xsl:choose>
			<xsl:when test="QTY01-QuantityDetails/QTY0101-QuantityQualifier='21'">
				<MENGE>
					<xsl:value-of select="QTY01-QuantityDetails/QTY0102-Quantity"/>
				</MENGE>
			</xsl:when>
		</xsl:choose>
		<!-- Translate UOM from EDIFACT to SAP -->
		<xsl:choose>
			<xsl:when test="QTY01-QuantityDetails/QTY0103-MeasureUnitQualifier='PCE'">
				<MENEE>PCE</MENEE>
			</xsl:when>
		</xsl:choose>
	</xsl:template>
	<xsl:template match="MOA">
		<xsl:choose>
			<xsl:when test="MOA01-MonetaryAmount/MOA0101-MonetaryAmountTypeQualifier='38'">
				<E1EDP05 SEGMENT="1">
					<KSCHL>ZMAN</KSCHL>
					<KRATE>
						<xsl:value-of select="MOA01-MonetaryAmount/MOA0102-MonetaryAmount"/>
					</KRATE>
				</E1EDP05>
			</xsl:when>
		</xsl:choose>
	</xsl:template>
	<xsl:template match="EDIFACT/ORDERS/GROUP_2" mode="E1EDK14">
		<xsl:for-each select="NAD">
			<xsl:choose>
				<xsl:when test="NAD01-PartyQualifier='SE'">
					<E1EDK14 SEGMENT="1">
						<QUALF>008</QUALF>
						<ORGID><xsl:value-of select="$sales_org"/></ORGID>
					</E1EDK14>
					<!-- Values for Division and Distribution Channel -->
					<E1EDK14 SEGMENT="1">
						<QUALF>007</QUALF>
						<ORGID>01</ORGID>
					</E1EDK14>
					<E1EDK14 SEGMENT="1">
						<QUALF>006</QUALF>
						<ORGID>00</ORGID>
					</E1EDK14>
				</xsl:when>
			</xsl:choose>
		</xsl:for-each>
	</xsl:template>

	<xsl:template match="EDIFACT/ORDERS/BGM" mode="E1EDK14">
		<E1EDK14 SEGMENT="1">
			<QUALF>012</QUALF>
			<xsl:choose>
				<xsl:when test="BGM01-DocumentMessageName/BGM0101-DocumentMessageNameCoded = '220' ">
					<ORGID>ZED</ORGID>
				</xsl:when>
				<xsl:when test="BGM01-DocumentMessageName/BGM0101-DocumentMessageNameCoded = '228' ">
					<ORGID>ZSI</ORGID>
				</xsl:when>
				<xsl:when test="BGM01-DocumentMessageName/BGM0101-DocumentMessageNameCoded = '447' ">
					<ORGID>ZED</ORGID>
				</xsl:when>
				<xsl:when test="BGM01-DocumentMessageName/BGM0101-DocumentMessageNameCoded = 'MMT' ">
					<ORGID>ZED</ORGID>
				</xsl:when>
			</xsl:choose>
		</E1EDK14>
	</xsl:template>

	<xsl:template match="EDIFACT/ORDERS/FTX" mode="E1EDKT1">
		<E1EDKT1 SEGMENT="1">
			<TDID>
				<xsl:choose>
					<xsl:when test="FTX01-TextSubjectQualifier = 'AAI'">Z002</xsl:when>
					<xsl:when test="FTX01-TextSubjectQualifier = 'AAJ'">Z002</xsl:when>
				</xsl:choose>
			</TDID>
			<xsl:choose>
				<xsl:when test="/EDIFACT/ORDERS/GROUP_2/NAD[NAD01-PartyQualifier='SE']/NAD02-PartyIdentificationDetails/NAD0201-PartyIdIdentification='10232094'">
					<TSSPRAS_ISO>ET</TSSPRAS_ISO>
				</xsl:when>
				<xsl:when test="/EDIFACT/ORDERS/GROUP_2/NAD[NAD01-PartyQualifier='SE']/NAD02-PartyIdentificationDetails/NAD0201-PartyIdIdentification='40003244865'">
					<TSSPRAS_ISO>LV</TSSPRAS_ISO>
				</xsl:when>
			</xsl:choose>
		</E1EDKT1>
		<E1EDKT2 SEGMENT="1">
			<TDLINE>
				<xsl:value-of select="FTX04-TextLiteral/FTX0401-FreeText"/>
			</TDLINE>
			<TDFORMAT>*</TDFORMAT>
		</E1EDKT2>
	</xsl:template>

	<xsl:template match="GROUP_28/PRI/PRI01-PriceInformation[PRI0101-PriceQualifier='AAA']">
		<E1EDP05 SEGMENT="1">
			<KSCHL>ZMAN</KSCHL>
			<KRATE>
				<xsl:value-of select="PRI0102-Price"/>
			</KRATE>
		</E1EDP05>
	</xsl:template>


</xsl:transform><!-- Stylus Studio meta-information - (c) 2004-2007. Progress Software Corporation. All rights reserved.
<metaInformation>
<scenarios ><scenario default="no" name="Test GROUP_28 Addition" userelativepaths="yes" externalpreview="no" url="Test GROUP_28 addition.xml" htmlbaseurl="" outputurl="" processortype="internal" useresolver="yes" profilemode="0" profiledepth="" profilelength="" urlprofilexml="" commandline="" additionalpath="" additionalclasspath="" postprocessortype="none" postprocesscommandline="" postprocessadditionalpath="" postprocessgeneratedext="" validateoutput="no" validator="internal" customvalidator=""/><scenario default="yes" name="Scenario1" userelativepaths="yes" externalpreview="no" url="Dummy Material Test\LVORDERTE_EC71EAC0-016B-11DD-CB37-003005FB7D2A.xml" htmlbaseurl="" outputurl="" processortype="internal" useresolver="yes" profilemode="0" profiledepth="" profilelength="" urlprofilexml="" commandline="" additionalpath="" additionalclasspath="" postprocessortype="none" postprocesscommandline="" postprocessadditionalpath="" postprocessgeneratedext="" validateoutput="no" validator="internal" customvalidator=""/></scenarios><MapperMetaTag><MapperInfo srcSchemaPathIsRelative="yes" srcSchemaInterpretAsXML="no" destSchemaPath="" destSchemaRoot="" destSchemaPathIsRelative="yes" destSchemaInterpretAsXML="no"/><MapperBlockPosition></MapperBlockPosition><TemplateContext></TemplateContext><MapperFilter side="source"></MapperFilter></MapperMetaTag>
</metaInformation>
-->