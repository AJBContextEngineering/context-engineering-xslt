<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:sap="http://www.sap.com/sapxsl" version="1.0">

	<xsl:strip-space elements="*"/>
	<xsl:output indent="yes"/>
	<xsl:template match="/">
		<EDIFACT>
			<INVOIC>
				<UNH>
					<UNH01-MessageReferenceNumber>
						<xsl:value-of select="substring(ZTELINVOIC02/IDOC/EDI_DC40/DOCNUM,3,16)"/>
					</UNH01-MessageReferenceNumber>
					<UNH02-MessageIdentifier>
						<UNH0201-MessageType>INVOIC</UNH0201-MessageType>
						<UNH0202-MessageVersionNumber>D</UNH0202-MessageVersionNumber>
						<UNH0203-MessageReleaseNumber>96A</UNH0203-MessageReleaseNumber>
						<UNH0204-ControllingAgency>UN</UNH0204-ControllingAgency>
						<!--Element UNH0205-AssociationAssignedCode is optional-->
						<UNH0205-AssociationAssignedCode>EAN007</UNH0205-AssociationAssignedCode>
					</UNH02-MessageIdentifier>
				</UNH>
				<xsl:apply-templates select="ZTELINVOIC02/IDOC/E1EDK01"/>
				<xsl:apply-templates select="ZTELINVOIC02/IDOC/E1EDK03"/>
				<xsl:apply-templates select="ZTELINVOIC02/IDOC/E1EDKT1"/>
				<xsl:apply-templates select="ZTELINVOIC02/IDOC/E1EDK02" mode="GROUP_1"/>
				<xsl:apply-templates select="ZTELINVOIC02/IDOC" mode="partners"/>
				<xsl:apply-templates select="ZTELINVOIC02/IDOC/E1EDP01"/>
				<!-- Sum amounts -->
				<UNS>
					<UNS01-SectionIdentification>S</UNS01-SectionIdentification>
				</UNS>
				<xsl:apply-templates select="ZTELINVOIC02/IDOC" mode="sum_amounts"/>
			</INVOIC>
		</EDIFACT>
	</xsl:template>
	<xsl:template match="ZTELINVOIC02/IDOC/E1EDK01">
		<BGM>
			<BGM01-DocumentMessageName>
				<BGM0101-DocumentMessageNameCoded>
					<xsl:choose>
						<xsl:when test="BSART = 'ZF2'">380</xsl:when>
						<xsl:when test="BSART = 'ZCR'">381</xsl:when>
					</xsl:choose>
				</BGM0101-DocumentMessageNameCoded>
			</BGM01-DocumentMessageName>
			<BGM02-DocumentMessageNumber>
				<xsl:choose>
					<xsl:when test="../E1EDK14[QUALF = '008']/ORGID = 'L110'">
						<xsl:value-of select="../E1EDK02[QUALF = '022']/BELNR"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="BELNR"/>
					</xsl:otherwise>
				</xsl:choose>
			</BGM02-DocumentMessageNumber>
			<BGM03-MessageFunctionCoded>9</BGM03-MessageFunctionCoded>
		</BGM>
	</xsl:template>
	<xsl:template match="ZTELINVOIC02/IDOC/E1EDK03">
		<xsl:choose>
			<xsl:when test="IDDAT = '028'">
				<DTM>
					<DTM01-DateTimePeriod>
						<xsl:comment>Payment Due Date</xsl:comment>
						<DTM0101-DateTimePeriodQualifier>140</DTM0101-DateTimePeriodQualifier>
						<DTM0102-DateTimePeriod>
							<xsl:value-of select="DATUM"/>
						</DTM0102-DateTimePeriod>
						<DTM0103-DateTimePeriodFormatQualifier>102</DTM0103-DateTimePeriodFormatQualifier>
					</DTM01-DateTimePeriod>
				</DTM>
			</xsl:when>
			<xsl:when test="IDDAT = '012'">
				<DTM>
					<DTM01-DateTimePeriod>
						<xsl:comment>Processing date/time</xsl:comment>
						<DTM0101-DateTimePeriodQualifier>9</DTM0101-DateTimePeriodQualifier>
						<DTM0102-DateTimePeriod>
							<xsl:value-of select="DATUM"/>
						</DTM0102-DateTimePeriod>
					</DTM01-DateTimePeriod>
					<DTM0103-DateTimePeriodFormatQualifier>102</DTM0103-DateTimePeriodFormatQualifier>
				</DTM>
			</xsl:when>
		</xsl:choose>
	</xsl:template>
	<xsl:template match="ZTELINVOIC02/IDOC/E1EDKT1">
		<FTX>
			<xsl:choose>
				<xsl:when test="TDID = 'Z001'">
					<FTX01-TextSubjectQualifier>AAI</FTX01-TextSubjectQualifier>
					<FTX04-TextLiteral>
						<FTX0401-FreeText>
							<xsl:value-of select="E1EDKT2/TDLINE"/>
						</FTX0401-FreeText>
					</FTX04-TextLiteral>
				</xsl:when>
			</xsl:choose>
		</FTX>
	</xsl:template>
	<xsl:template match="ZTELINVOIC02/IDOC" mode="partners">
		<xsl:comment>Invoicee</xsl:comment>
		<GROUP_2>
			<NAD>
				<NAD01-PartyQualifier>IV</NAD01-PartyQualifier>
				<NAD02-PartyIdentificationDetails>
					<NAD0201-PartyIdIdentification>
						<xsl:value-of select="E1EDKA1[PARVW='RE']/PARTN"/>
					</NAD0201-PartyIdIdentification>
					<NAD0203-CodeListResponsibleAgencyCoded>9</NAD0203-CodeListResponsibleAgencyCoded>
				</NAD02-PartyIdentificationDetails>
				<NAD04-PartyName>
					<NAD0401-PartyName>
						<xsl:value-of select="E1EDKA1[PARVW='RE']/NAME1"/>
					</NAD0401-PartyName>
				</NAD04-PartyName>
				<NAD05-Street>
					<NAD0501-StreetAndNumberPOBox>
						<xsl:value-of select="E1EDKA1[PARVW='RE']/STRAS"/>
					</NAD0501-StreetAndNumberPOBox>
				</NAD05-Street>
				<NAD06-CityName>
					<xsl:value-of select="E1EDKA1[PARVW='RE']/ORT01"/>
				</NAD06-CityName>
				<NAD08-PostcodeIdentification>
					<xsl:value-of select="E1EDKA1[PARVW='RE']/PSTLZ"/>
				</NAD08-PostcodeIdentification>
				<NAD09-CountryCoded>
					<xsl:value-of select="E1EDKA1[PARVW='RE']/LAND1"/>
				</NAD09-CountryCoded>
			</NAD>
			<!--			<GROUP_5>
				<CTA></CTA>
				<xsl:if test="E1EDKA1[PARVW='RE']/TELF1 != ''">
					<COM>
						<COM01-CommunicationContact>
							<COM0101-CommunicationNumber>
								<xsl:value-of select="E1EDKA1[PARVW='RE']/TELF1"/>
							</COM0101-CommunicationNumber>
							<COM0102-CommunicationChannelQualifier>AM</COM0102-CommunicationChannelQualifier>
						</COM01-CommunicationContact>
					</COM>
				</xsl:if>
				<xsl:if test="E1EDKA1[PARVW='RE']/TELFX != ''">
					<COM>
						<COM01-CommunicationContact>
							<COM0101-CommunicationNumber>
								<xsl:value-of select="E1EDKA1[PARVW='RE']/TELFX"/>
							</COM0101-CommunicationNumber>
							<COM0102-CommunicationChannelQualifier>FX</COM0102-CommunicationChannelQualifier>
						</COM01-CommunicationContact>
					</COM>
				</xsl:if>
			</GROUP_5>-->
		</GROUP_2>
		<xsl:comment>Buyer (Sold-to Party in SAP)</xsl:comment>
		<GROUP_2>
			<NAD>
				<NAD01-PartyQualifier>BY</NAD01-PartyQualifier>
				<NAD02-PartyIdentificationDetails>
					<NAD0201-PartyIdIdentification>
						<xsl:value-of select="E1EDKA1[PARVW='AG']/PARTN"/>
					</NAD0201-PartyIdIdentification>
					<NAD0203-CodeListResponsibleAgencyCoded>9</NAD0203-CodeListResponsibleAgencyCoded>
				</NAD02-PartyIdentificationDetails>
				<NAD04-PartyName>
					<NAD0401-PartyName>
						<xsl:value-of select="E1EDKA1[PARVW='AG']/NAME1"/>
					</NAD0401-PartyName>
				</NAD04-PartyName>
				<NAD05-Street>
					<NAD0501-StreetAndNumberPOBox>
						<xsl:value-of select="E1EDKA1[PARVW='AG']/STRAS"/>
					</NAD0501-StreetAndNumberPOBox>
				</NAD05-Street>
				<NAD06-CityName>
					<xsl:value-of select="E1EDKA1[PARVW='AG']/ORT01"/>
				</NAD06-CityName>
				<NAD08-PostcodeIdentification>
					<xsl:value-of select="E1EDKA1[PARVW='AG']/PSTLZ"/>
				</NAD08-PostcodeIdentification>
				<NAD09-CountryCoded>
					<xsl:value-of select="E1EDKA1[PARVW='AG']/LAND1"/>
				</NAD09-CountryCoded>
			</NAD>
			<!--			<GROUP_5>
				<CTA></CTA>
				<xsl:if test="E1EDKA1[PARVW='AG']/TELF1 != ''">
					<COM>
						<COM01-CommunicationContact>
							<COM0101-CommunicationNumber>
								<xsl:value-of select="E1EDKA1[PARVW='AG']/TELF1"/>
							</COM0101-CommunicationNumber>
							<COM0102-CommunicationChannelQualifier>AM</COM0102-CommunicationChannelQualifier>
						</COM01-CommunicationContact>
					</COM>
				</xsl:if>
				<xsl:if test="E1EDKA1[PARVW='AG']/TELFX != ''">
					<COM>
						<COM01-CommunicationContact>
							<COM0101-CommunicationNumber>
								<xsl:value-of select="E1EDKA1[PARVW='AG']/TELFX"/>
							</COM0101-CommunicationNumber>
							<COM0102-CommunicationChannelQualifier>FX</COM0102-CommunicationChannelQualifier>
						</COM01-CommunicationContact>
					</COM>
				</xsl:if>
			</GROUP_5>-->
		</GROUP_2>
		<!--		<xsl:comment>Seller</xsl:comment>
		<GROUP_2>
			<NAD>
				<NAD01-PartyQualifier>SE</NAD01-PartyQualifier>
				<NAD02-PartyIdentificationDetails>
					<NAD0201-PartyIdIdentification>
						<xsl:value-of select="E1EDKA1[PARVW='RS']/LIFNR"/>
					</NAD0201-PartyIdIdentification>
					<NAD0203-CodeListResponsibleAgencyCoded>9</NAD0203-CodeListResponsibleAgencyCoded>
				</NAD02-PartyIdentificationDetails>
				<NAD03-NameAndAddress>
					<NAD0301-NameAndAddressLine>
						<xsl:value-of select="E1EDKA1[PARVW='RS']/NAME1"/>
					</NAD0301-NameAndAddressLine>
				</NAD03-NameAndAddress>
				<NAD05-Street>
					<NAD0501-StreetAndNumberPOBox>
						<xsl:value-of select="E1EDKA1[PARVW='RS']/STRAS"/>
					</NAD0501-StreetAndNumberPOBox>
				</NAD05-Street>
				<NAD06-CityName>
					<xsl:value-of select="E1EDKA1[PARVW='RS']/ORT01"/>
				</NAD06-CityName>
				<NAD08-PostcodeIdentification>
					<xsl:value-of select="E1EDKA1[PARVW='RS']/PSTLZ"/>
				</NAD08-PostcodeIdentification>
				<NAD09-CountryCoded>
					<xsl:value-of select="E1EDKA1[PARVW='RS']/LAND1"/>
				</NAD09-CountryCoded>
			</NAD>
			<GROUP_5>
				<CTA></CTA>
				<xsl:if test="E1EDKA1[PARVW='RS']/TELF1 != ''">
				<COM>
					<COM01-CommunicationContact>
						<COM0101-CommunicationNumber>
							<xsl:value-of select="E1EDKA1[PARVW='RS']/TELF1"/>
						</COM0101-CommunicationNumber>
						<COM0102-CommunicationChannelQualifier>AM</COM0102-CommunicationChannelQualifier>
					</COM01-CommunicationContact>
				</COM>
				</xsl:if>
				<xsl:if test="E1EDKA1[PARVW='RS']/TELFX != ''">
				<COM>
					<COM01-CommunicationContact>
						<COM0101-CommunicationNumber>
							<xsl:value-of select="E1EDKA1[PARVW='RS']/TELFX"/>
						</COM0101-CommunicationNumber>
						<COM0102-CommunicationChannelQualifier>FX</COM0102-CommunicationChannelQualifier>
					</COM01-CommunicationContact>
				</COM>
				</xsl:if>
			</GROUP_5>
		</GROUP_2>                                                                                                 -->
		<xsl:comment>Delivery Party (Ship-to Party in SAP)</xsl:comment>
		<GROUP_2>
			<NAD>
				<NAD01-PartyQualifier>DP</NAD01-PartyQualifier>
				<NAD02-PartyIdentificationDetails>
					<NAD0201-PartyIdIdentification>
						<xsl:value-of select="E1EDP01/E1EDPA1[PARVW='WE']/PARTN"/>
					</NAD0201-PartyIdIdentification>
					<NAD0203-CodeListResponsibleAgencyCoded>9</NAD0203-CodeListResponsibleAgencyCoded>
				</NAD02-PartyIdentificationDetails>
				<NAD04-PartyName>
					<NAD0401-PartyName><xsl:value-of select="E1EDKA1[PARVW='WE']/NAME1"/></NAD0401-PartyName>
				</NAD04-PartyName>
				<NAD05-Street>
					<NAD0501-StreetAndNumberPOBox>
						<xsl:value-of select="E1EDKA1[PARVW='WE']/STRAS"/>
					</NAD0501-StreetAndNumberPOBox>
				</NAD05-Street>
				<NAD06-CityName>
					<xsl:value-of select="E1EDKA1[PARVW='WE']/ORT01"/>
				</NAD06-CityName>
				<NAD08-PostcodeIdentification>
					<xsl:value-of select="E1EDKA1[PARVW='WE']/PSTLZ"/>
				</NAD08-PostcodeIdentification>
				<NAD09-CountryCoded>
					<xsl:value-of select="E1EDKA1[PARVW='WE']/LAND1"/>
				</NAD09-CountryCoded>
			</NAD>
			<!--			<GROUP_5>
				<CTA></CTA>
				<xsl:if test="E1EDKA1[PARVW='WE']/TELF1 != ''">
					<COM>
						<COM01-CommunicationContact>
							<COM0101-CommunicationNumber>
								<xsl:value-of select="E1EDKA1[PARVW='WE']/TELF1"/>
							</COM0101-CommunicationNumber>
							<COM0102-CommunicationChannelQualifier>AM</COM0102-CommunicationChannelQualifier>
						</COM01-CommunicationContact>
					</COM>
				</xsl:if>
				<xsl:if test="E1EDKA1[PARVW='WE']/TELFX != ''">
					<COM>
						<COM01-CommunicationContact>
							<COM0101-CommunicationNumber>
								<xsl:value-of select="E1EDKA1[PARVW='WE']/TELFX"/>
							</COM0101-CommunicationNumber>
							<COM0102-CommunicationChannelQualifier>FX</COM0102-CommunicationChannelQualifier>
						</COM01-CommunicationContact>
					</COM>
				</xsl:if>
			</GROUP_5>-->
		</GROUP_2>
	</xsl:template>
	<xsl:template match="ZTELINVOIC02/IDOC/E1EDP01">
		<GROUP_25>
        		<LIN>
        			<LIN01-LineItemNumber>
        				<xsl:value-of select="number(POSEX)"/>
        			</LIN01-LineItemNumber>
        			<xsl:for-each select="E1EDP19">
        				<xsl:choose>
        					<xsl:when test="QUALF = '003'">
        							<LIN03-ItemNumberIdentification>
        								<LIN0301-ItemNumber>
        									<xsl:value-of select="IDTNR"/>
        								</LIN0301-ItemNumber>
        								<LIN0302-ItemNumberTypeCoded>EN</LIN0302-ItemNumberTypeCoded>
        							</LIN03-ItemNumberIdentification>
        					</xsl:when>
        				</xsl:choose>
        			</xsl:for-each>
                    </LIN>
			<xsl:for-each select="E1EDP19">
				<xsl:choose>
					<xsl:when test="QUALF = '002'">
						<PIA>
							<PIA01-ProductIdFunctionQualifier>5</PIA01-ProductIdFunctionQualifier>
							<PIA02-ItemNumberIdentification>
								<PIA0201-ItemNumber>
									<xsl:value-of select="IDTNR"/>
								</PIA0201-ItemNumber>
								<PIA0202-ItemNumberTypeCoded>VP</PIA0202-ItemNumberTypeCoded>
							</PIA02-ItemNumberIdentification>
						</PIA>
						<IMD>
							<IMD01-ItemDescriptionTypeCoded>F</IMD01-ItemDescriptionTypeCoded>
							<IMD02-ItemCharacteristicCoded>8</IMD02-ItemCharacteristicCoded>
							<IMD03-ItemDescription>
								<!--Element IMD0301-ItemDescriptionIdentification is optional-->
								<IMD0301-ItemDescriptionIdentification>1</IMD0301-ItemDescriptionIdentification>
								<!--Element IMD0303-CodeListResponsibleAgencyCoded is optional-->
								<IMD0303-CodeListResponsibleAgencyCoded>91</IMD0303-CodeListResponsibleAgencyCoded>
								<!--Element IMD0304-ItemDescription is optional-->
								<IMD0304-ItemDescription>
									<xsl:value-of select="KTEXT"/>
								</IMD0304-ItemDescription>
							</IMD03-ItemDescription>
							<!--Element IMD04-SurfaceLayerIndicatorCoded is optional-->
							<IMD04-SurfaceLayerIndicatorCoded>str</IMD04-SurfaceLayerIndicatorCoded>
						</IMD>
						<QTY>
							<QTY01-QuantityDetails>
								<QTY0101-QuantityQualifier>47</QTY0101-QuantityQualifier>
								<QTY0102-Quantity>
									<xsl:value-of select="../MENGE"/>
								</QTY0102-Quantity>
								<QTY0103-MeasureUnitQualifier>
									<xsl:value-of select="../MENEE"/>
								</QTY0103-MeasureUnitQualifier>
							</QTY01-QuantityDetails>
						</QTY>
					</xsl:when>
				</xsl:choose>
			</xsl:for-each>
			<GROUP_26>
				<MOA>
					<MOA01-MonetaryAmount>
						<MOA0101-MonetaryAmountTypeQualifier>203</MOA0101-MonetaryAmountTypeQualifier>
						<MOA0102-MonetaryAmount>
							<xsl:value-of select="E1EDP26[QUALF='012']/BETRG"/>
						</MOA0102-MonetaryAmount>
					</MOA01-MonetaryAmount>
				</MOA>
			</GROUP_26>
			<!-- PRI segments in GROUP 28 -->
			<GROUP_28>
				<PRI>
					<PRI01-PriceInformation>
						<PRI0101-PriceQualifier>AAB</PRI0101-PriceQualifier>
						<PRI0102-Price>
							<xsl:value-of select="E1EDP05[ALCKZ='+'][not(KSCHL)][position()=1]/KRATE"/>
						</PRI0102-Price>
					</PRI01-PriceInformation>
				</PRI>
				<PRI>
					<PRI01-PriceInformation>
						<PRI0101-PriceQualifier>AAA</PRI0101-PriceQualifier>
						<PRI0102-Price>
							<xsl:value-of select="E1EDP05[ALCKZ='+'][not(KSCHL)][position()= last()]/KRATE"/>
						</PRI0102-Price>
					</PRI01-PriceInformation>
				</PRI>
			</GROUP_28>
			<xsl:for-each select="E1EDP04">
				<!-- Remove line item with VAT = 0% because this is handled by PANT item -->
				<xsl:if test="MWSKZ != 'V0'">
					<GROUP_33>
						<TAX>
							<TAX01-DutyTaxFeeFunctionQualifier>7</TAX01-DutyTaxFeeFunctionQualifier>
							<TAX02-DutyTaxFeeType>
								<TAX0201-DutyTaxFeeTypeCoded>VAT</TAX0201-DutyTaxFeeTypeCoded>
							</TAX02-DutyTaxFeeType>
							<TAX05-DutyTaxFeeDetail>
								<TAX0504-DutyTaxFeeRate>
									<xsl:value-of select="MSATZ"/>
								</TAX0504-DutyTaxFeeRate>
							</TAX05-DutyTaxFeeDetail>
						</TAX>
						<MOA>
							<MOA01-MonetaryAmount>
								<MOA0101-MonetaryAmountTypeQualifier>150</MOA0101-MonetaryAmountTypeQualifier>
								<MOA0102-MonetaryAmount>
									<xsl:value-of select="MWSBT"/>
								</MOA0102-MonetaryAmount>
							</MOA01-MonetaryAmount>
						</MOA>
					</GROUP_33>
				</xsl:if>
			</xsl:for-each>
		</GROUP_25>
		<!-- Extra LIN item for the bottle deposit if found -->
		<xsl:for-each select="E1EDP05[KSCHL = 'ZDEP']">
			<GROUP_25>
				<LIN>
					<LIN01-LineItemNumber>
						<xsl:value-of select="../POSEX + 1"/>
					</LIN01-LineItemNumber>
					<LIN03-ItemNumberIdentification>
						<LIN0301-ItemNumber/>
						<LIN0302-ItemNumberTypeCoded/>
					</LIN03-ItemNumberIdentification>
				</LIN>
				<IMD>
					<IMD03-ItemDescription>
						<IMD0304-ItemDescription>PANT</IMD0304-ItemDescription>
					</IMD03-ItemDescription>
				</IMD>
				<QTY>
					<QTY01-QuantityDetails>
						<QTY0101-QuantityQualifier>47</QTY0101-QuantityQualifier>
						<QTY0102-Quantity>
							<xsl:value-of select="KOBAS"/>
						</QTY0102-Quantity>
						<!--Element QTY0103-MeasureUnitQualifier is optional-->
						<QTY0103-MeasureUnitQualifier>
							<xsl:value-of select="MEAUN"/>
						</QTY0103-MeasureUnitQualifier>
					</QTY01-QuantityDetails>
				</QTY>
				<GROUP_26>
					<MOA>
						<MOA01-MonetaryAmount>
							<MOA0101-MonetaryAmountTypeQualifier>203</MOA0101-MonetaryAmountTypeQualifier>
							<MOA0102-MonetaryAmount>
								<xsl:value-of select="BETRG"/>
							</MOA0102-MonetaryAmount>
						</MOA01-MonetaryAmount>
					</MOA>
				</GROUP_26>
				<GROUP_28>
					<PRI>
						<PRI01-PriceInformation>
							<PRI0101-PriceQualifier>AAA</PRI0101-PriceQualifier>
							<PRI0102-Price>
								<xsl:value-of select="KRATE"/>
							</PRI0102-Price>
						</PRI01-PriceInformation>
					</PRI>
				</GROUP_28>
				<GROUP_33>
					<TAX>
						<TAX01-DutyTaxFeeFunctionQualifier>7</TAX01-DutyTaxFeeFunctionQualifier>
						<TAX02-DutyTaxFeeType>
							<TAX0201-DutyTaxFeeTypeCoded>VAT</TAX0201-DutyTaxFeeTypeCoded>
						</TAX02-DutyTaxFeeType>
						<TAX05-DutyTaxFeeDetail>
							<TAX0504-DutyTaxFeeRate>
								<xsl:value-of select="../E1EDP04[MWSKZ='V0']/MSATZ"/>
							</TAX0504-DutyTaxFeeRate>
						</TAX05-DutyTaxFeeDetail>
					</TAX>
					<MOA>
						<MOA01-MonetaryAmount>
							<MOA0101-MonetaryAmountTypeQualifier>150</MOA0101-MonetaryAmountTypeQualifier>
							<MOA0102-MonetaryAmount>
								<xsl:value-of select="../E1EDP04[MWSKZ='V0']/MWSBT"/>
							</MOA0102-MonetaryAmount>
						</MOA01-MonetaryAmount>
					</MOA>
				</GROUP_33>
			</GROUP_25>
		</xsl:for-each>
	</xsl:template>
	<xsl:template match="ZTELINVOIC02/IDOC" mode="sum_amounts">
		<GROUP_48>
			<MOA>
				<MOA01-MonetaryAmount>
					<MOA0101-MonetaryAmountTypeQualifier>125</MOA0101-MonetaryAmountTypeQualifier>
					<MOA0102-MonetaryAmount>
						<xsl:value-of select="E1EDS01[SUMID = '010']/SUMME"/>
					</MOA0102-MonetaryAmount>
					<!--Element MOA0103-CurrencyCoded is optional-->
					<MOA0103-CurrencyCoded>
						<xsl:value-of select="../IDOC/E1EDK01/CURCY"/>
					</MOA0103-CurrencyCoded>
				</MOA01-MonetaryAmount>
			</MOA>
		</GROUP_48>
		<GROUP_48>
			<MOA>
				<MOA01-MonetaryAmount>
					<MOA0101-MonetaryAmountTypeQualifier>39</MOA0101-MonetaryAmountTypeQualifier>
					<MOA0102-MonetaryAmount>
						<xsl:value-of select="E1EDS01[SUMID = '010']/SUMME + E1EDS01[SUMID = '005']/SUMME"/>
					</MOA0102-MonetaryAmount>
					<!--Element MOA0103-CurrencyCoded is optional-->
					<MOA0103-CurrencyCoded>
						<xsl:value-of select="../IDOC/E1EDK01/CURCY"/>
					</MOA0103-CurrencyCoded>
				</MOA01-MonetaryAmount>
			</MOA>
		</GROUP_48>
		<xsl:for-each select="//Z1EDS04">
			<GROUP_50>
				<TAX>
					<TAX01-DutyTaxFeeFunctionQualifier>7</TAX01-DutyTaxFeeFunctionQualifier>
					<TAX02-DutyTaxFeeType>
						<TAX0201-DutyTaxFeeTypeCoded>VAT</TAX0201-DutyTaxFeeTypeCoded>
					</TAX02-DutyTaxFeeType>
					<TAX05-DutyTaxFeeDetail>
						<TAX0504-DutyTaxFeeRate>
							<xsl:value-of select="MSATZ"/>
						</TAX0504-DutyTaxFeeRate>
					</TAX05-DutyTaxFeeDetail>
				</TAX>
				<!--Element MOA is optional, maxOccurs=2-->
				<MOA>
					<MOA01-MonetaryAmount>
						<MOA0101-MonetaryAmountTypeQualifier>125</MOA0101-MonetaryAmountTypeQualifier>
						<!--Element MOA0102-MonetaryAmount is optional-->
						<MOA0102-MonetaryAmount>
							<xsl:value-of select="BETRG"/>
						</MOA0102-MonetaryAmount>
						<!--Element MOA0103-CurrencyCoded is optional-->
						<MOA0103-CurrencyCoded>
							<xsl:value-of select="../IDOC/E1EDK01/CURCY"/>
						</MOA0103-CurrencyCoded>
					</MOA01-MonetaryAmount>
				</MOA>
				<MOA>
					<MOA01-MonetaryAmount>
						<MOA0101-MonetaryAmountTypeQualifier>150</MOA0101-MonetaryAmountTypeQualifier>
						<!--Element MOA0102-MonetaryAmount is optional-->
						<MOA0102-MonetaryAmount>
							<xsl:choose>
								<xsl:when test="MWSKZ = 'V0'">
									<xsl:value-of select="/ZTELINVOIC02/IDOC/E1EDK04[MWSKZ = 'V0']/MWSBT"/>
								</xsl:when>
								<xsl:when test="MWSKZ = 'V1'">
									<xsl:value-of select="/ZTELINVOIC02/IDOC/E1EDK04[MWSKZ = 'V1']/MWSBT"/>
								</xsl:when>
								<xsl:when test="MWSKZ = 'R1'">
									<xsl:value-of select="/ZTELINVOIC02/IDOC/E1EDK04[MWSKZ = 'R1']/MWSBT"/>
								</xsl:when>
								<xsl:when test="MWSKZ = 'R2'">
									<xsl:value-of select="/ZTELINVOIC02/IDOC/E1EDK04[MWSKZ = 'R2']/MWSBT"/>
								</xsl:when>
								<xsl:when test="MWSKZ = 'E1'">
									<xsl:value-of select="/ZTELINVOIC02/IDOC/E1EDK04[MWSKZ = 'E1']/MWSBT"/>
								</xsl:when>
								<xsl:when test="MWSKZ = 'E2'">
									<xsl:value-of select="/ZTELINVOIC02/IDOC/E1EDK04[MWSKZ = 'E2']/MWSBT"/>
								</xsl:when>
								<xsl:when test="MWSKZ = 'V6'">
									<xsl:value-of select="/ZTELINVOIC02/IDOC/E1EDK04[MWSKZ = 'V6']/MWSBT"/>
								</xsl:when>
								<xsl:when test="MWSKZ = 'V7'">
									<xsl:value-of select="/ZTELINVOIC02/IDOC/E1EDK04[MWSKZ = 'V7']/MWSBT"/>
								</xsl:when>
							</xsl:choose>
						</MOA0102-MonetaryAmount>
						<!--Element MOA0103-CurrencyCoded is optional-->
						<MOA0103-CurrencyCoded>
							<xsl:value-of select="../IDOC/E1EDK01/CURCY"/>
						</MOA0103-CurrencyCoded>
					</MOA01-MonetaryAmount>
				</MOA>
			</GROUP_50>
		</xsl:for-each>
	</xsl:template>
	<xsl:template match="ZTELINVOIC02/IDOC/E1EDK02" mode="GROUP_1">
		<xsl:choose>
			<xsl:when test="QUALF='001'">
				<GROUP_1>
					<RFF>
        				<RFF01-Reference>
            				<RFF0101-ReferenceQualifier>ON</RFF0101-ReferenceQualifier>
            				<!--Element RFF0102-ReferenceNumber is optional-->
            				<RFF0102-ReferenceNumber>
								<xsl:value-of select="BELNR"/>
							</RFF0102-ReferenceNumber>
        				</RFF01-Reference>
    				</RFF>
				</GROUP_1>
			</xsl:when>
			<xsl:when test="QUALF='022'">
				<GROUP_1>
					<RFF>
						<RFF01-Reference>
							<RFF0101-ReferenceQualifier>PQ</RFF0101-ReferenceQualifier>
							<RFF0102-ReferenceNumber>
								<xsl:value-of select="BELNR"/>
							</RFF0102-ReferenceNumber>
						</RFF01-Reference>
					</RFF>
				</GROUP_1>
			</xsl:when>
		</xsl:choose>
	</xsl:template>
</xsl:transform><!-- Stylus Studio meta-information - (c) 2004-2007. Progress Software Corporation. All rights reserved.
<metaInformation>
<scenarios ><scenario default="yes" name="IDoc 582206" userelativepaths="yes" externalpreview="no" url="..\..\..\Altia Brain\Altia_brain\Files\8CAF83D9-3250-E880-4C9C-B678CC0042B1\IDOC 6053606.xml" htmlbaseurl="" outputurl="" processortype="internal" useresolver="yes" profilemode="0" profiledepth="" profilelength="" urlprofilexml="" commandline="" additionalpath="" additionalclasspath="" postprocessortype="none" postprocesscommandline="" postprocessadditionalpath="" postprocessgeneratedext="" validateoutput="no" validator="internal" customvalidator="" ><advancedProp name="sInitialMode" value=""/><advancedProp name="bXsltOneIsOkay" value="true"/><advancedProp name="bSchemaAware" value="true"/><advancedProp name="bXml11" value="false"/><advancedProp name="iValidation" value="0"/><advancedProp name="bExtensions" value="true"/><advancedProp name="iWhitespace" value="0"/><advancedProp name="sInitialTemplate" value=""/><advancedProp name="bTinyTree" value="true"/><advancedProp name="bWarnings" value="true"/><advancedProp name="bUseDTD" value="false"/><advancedProp name="iErrorHandling" value="fatal"/></scenario></scenarios><MapperMetaTag><MapperInfo srcSchemaPathIsRelative="yes" srcSchemaInterpretAsXML="no" destSchemaPath="" destSchemaRoot="" destSchemaPathIsRelative="yes" destSchemaInterpretAsXML="no"/><MapperBlockPosition></MapperBlockPosition><TemplateContext></TemplateContext><MapperFilter side="source"></MapperFilter></MapperMetaTag>
</metaInformation>
-->