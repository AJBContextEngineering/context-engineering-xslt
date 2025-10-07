<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:ns0="http://www.consafelogistics.com/astro/project">

    <xsl:output method="xml" indent="yes"/>

    <!--
    DispatchSync XSLT 3.0 Mapping
    Transforms DELVRY07 IDOC to DispatchSync format
    Implements 26 field mapping requirements
    -->

    <xsl:template match="/">
        <xsl:comment>Root template - creates static DispatchSync structure</xsl:comment>
        <ns0:DispatchSync version="0100">
            <ns0:ControlArea>
                <ns0:Sender>
                    <xsl:comment>Requirement 1: Fixed confirmation value '2'</xsl:comment>
                    <ns0:Confirmation>2</ns0:Confirmation>
                </ns0:Sender>
                <xsl:comment>Requirement 2: Current date and time in ISO format</xsl:comment>
                <ns0:CreationDateTime>
                    <xsl:value-of select="format-dateTime(current-dateTime(), '[Y0001]-[M01]-[D01]T[H01]:[m01]:[s01]')"/>
                </ns0:CreationDateTime>
                <ns0:ReferenceId>
                    <xsl:comment>Requirement 3: DOCNUM with leading zeros removed</xsl:comment>
                    <ns0:Id>
                        <xsl:value-of select="translate(/DELVRY07/IDOC/EDI_DC40/DOCNUM, '0', '')"/>
                    </ns0:Id>
                </ns0:ReferenceId>
            </ns0:ControlArea>
            <ns0:DataArea>
                <ns0:Sync>
                    <xsl:comment>Requirement 4: Fixed action value 'Add'</xsl:comment>
                    <ns0:ActionCriteria action="Add"/>
                </ns0:Sync>
                <ns0:Dispatch>
                    <ns0:DispatchHead>
                        <xsl:comment>Requirement 5: DispatchId from VBELN</xsl:comment>
                        <ns0:DispatchId>
                            <ns0:Id>
                                <xsl:value-of select="/DELVRY07/IDOC/E1EDL20/VBELN"/>
                            </ns0:Id>
                        </ns0:DispatchId>

                        <xsl:comment>Requirements 6, 7, 8: Empty elements</xsl:comment>
                        <ns0:ShipFrom/>
                        <ns0:ShipTo/>
                        <ns0:DivisionGroup/>

                        <xsl:comment>Requirements 9, 10: Conditional DispatchDimensionArea - only if BTGEW and VOLUM are not empty</xsl:comment>
                        <xsl:if test="/DELVRY07/IDOC/E1EDL20/BTGEW != '' and /DELVRY07/IDOC/E1EDL20/VOLUM != ''">
                            <ns0:DispatchDimensionArea>
                                <ns0:Weight>
                                    <xsl:value-of select="format-number(round(/DELVRY07/IDOC/E1EDL20/BTGEW * 100) div 100, '0.00')"/>
                                </ns0:Weight>
                                <ns0:Volume>
                                    <xsl:value-of select="format-number(round(/DELVRY07/IDOC/E1EDL20/VOLUM * 100) div 100, '0.00')"/>
                                </ns0:Volume>
                            </ns0:DispatchDimensionArea>
                        </xsl:if>

                        <xsl:comment>Requirement 11: ShipUnitQuantity from ANZPK</xsl:comment>
                        <ns0:ShipUnitQuantity>
                            <xsl:value-of select="/DELVRY07/IDOC/E1EDL20/ANZPK"/>
                        </ns0:ShipUnitQuantity>

                        <xsl:comment>Requirement 12: Conditional TransportId - only if BOLNR exists</xsl:comment>
                        <xsl:if test="boolean(/DELVRY07/IDOC/E1EDL20/BOLNR)">
                            <ns0:TransportArea>
                                <ns0:TransportId>
                                    <ns0:Id>
                                        <xsl:value-of select="/DELVRY07/IDOC/E1EDL20/BOLNR"/>
                                    </ns0:Id>
                                </ns0:TransportId>
                            </ns0:TransportArea>
                        </xsl:if>

                        <xsl:comment>Requirement 13: TransportDate formatted from CREDAT and CRETIM</xsl:comment>
                        <ns0:TransportArea>
                            <ns0:TransportDate>
                                <xsl:value-of select="concat(substring(/DELVRY07/IDOC/EDI_DC40/CREDAT, 1, 4), '-', substring(/DELVRY07/IDOC/EDI_DC40/CREDAT, 5, 2), '-', substring(/DELVRY07/IDOC/EDI_DC40/CREDAT, 7, 2), 'T', substring(/DELVRY07/IDOC/EDI_DC40/CRETIM, 1, 2), ':', substring(/DELVRY07/IDOC/EDI_DC40/CRETIM, 3, 2), ':', substring(/DELVRY07/IDOC/EDI_DC40/CRETIM, 5, 2))"/>
                            </ns0:TransportDate>
                        </ns0:TransportArea>
                    </ns0:DispatchHead>

                    <xsl:comment>Requirements 14-26: Apply templates to E1EDL37 pallet elements</xsl:comment>
                    <xsl:apply-templates select="DELVRY07/IDOC/E1EDL20/E1EDL37"/>
                </ns0:Dispatch>
            </ns0:DataArea>
        </ns0:DispatchSync>
    </xsl:template>

    <!-- Template for E1EDL37 - Pallet level mappings -->
    <xsl:template match="/DELVRY07/IDOC/E1EDL20/E1EDL37">
        <xsl:comment>Requirements 14-17: Pallet mappings</xsl:comment>
        <ns0:Pallet>
            <ns0:PalletId>
                <xsl:comment>Requirement 14: Use EXIDV2 if exists, else EXIDV</xsl:comment>
                <ns0:Id>
                    <xsl:choose>
                        <xsl:when test="EXIDV2 and EXIDV2 != ''">
                            <xsl:value-of select="EXIDV2"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="EXIDV"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </ns0:Id>
            </ns0:PalletId>

            <xsl:comment>Requirement 15: PalletTypeId based on MAGRV value</xsl:comment>
            <ns0:PalletTypeId>
                <ns0:Id>
                    <xsl:choose>
                        <xsl:when test="MAGRV = 'Z001'">B1</xsl:when>
                        <xsl:otherwise>P2</xsl:otherwise>
                    </xsl:choose>
                </ns0:Id>
            </ns0:PalletTypeId>

            <xsl:comment>Requirements 16, 17: PalletDimensionArea with Volume and Weight</xsl:comment>
            <ns0:PalletDimensionArea>
                <ns0:Volume>
                    <xsl:value-of select="format-number(round(BTVOL * 100) div 100, '0.00')"/>
                </ns0:Volume>
                <ns0:Weight>
                    <xsl:value-of select="format-number(round(BRGEW * 100) div 100, '0.00')"/>
                </ns0:Weight>
            </ns0:PalletDimensionArea>

            <xsl:comment>Requirement 18: Static PalletContent structure with apply-templates to E1EDL44</xsl:comment>
            <ns0:PalletContent>
                <ns0:PalletContentItem>
                    <xsl:apply-templates select="E1EDL44"/>
                </ns0:PalletContentItem>
            </ns0:PalletContent>
        </ns0:Pallet>
    </xsl:template>

    <!-- Template for E1EDL44 - PalletContentItem mappings -->
    <xsl:template match="/DELVRY07/IDOC/E1EDL20/E1EDL37/E1EDL44">
        <xsl:comment>Requirements 19-26: PalletContentItem mappings</xsl:comment>

        <xsl:comment>Requirements 19, 20, 21: PartId with material, revision (space), and division</xsl:comment>
        <ns0:PartId>
            <ns0:Id>
                <xsl:value-of select="MATNR"/>
            </ns0:Id>
            <ns0:Revision><xsl:text> </xsl:text></ns0:Revision>
            <ns0:Division>
                <xsl:value-of select="WERKS"/>
            </ns0:Division>
        </ns0:PartId>

        <xsl:comment>Requirement 22: AdvisedQuantity from VEMNG, formatted to 2 decimal places</xsl:comment>
        <ns0:AdvisedQuantity>
            <xsl:value-of select="format-number(round(VEMNG * 100) div 100, '0.00')"/>
        </ns0:AdvisedQuantity>

        <xsl:comment>Requirement 23: AdvisedUnit with unit conversion from VEMEH</xsl:comment>
        <ns0:AdvisedUnit>
            <xsl:choose>
                <xsl:when test="VEMEH = 'BG'">BAG</xsl:when>
                <xsl:when test="VEMEH = 'NAR'">EA</xsl:when>
                <xsl:when test="VEMEH = 'KGM'">KG</xsl:when>
                <xsl:when test="VEMEH = 'LTR'">L</xsl:when>
                <xsl:when test="VEMEH = 'MTR'">M</xsl:when>
                <xsl:when test="VEMEH = 'MTK'">M2</xsl:when>
                <xsl:when test="VEMEH = 'PR'">PAA</xsl:when>
                <xsl:when test="VEMEH = 'PK'">PAK</xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="VEMEH"/>
                </xsl:otherwise>
            </xsl:choose>
        </ns0:AdvisedUnit>

        <xsl:comment>Requirements 24, 25, 26: Conditional LotInfo - only if CHARG is not empty</xsl:comment>
        <xsl:if test="CHARG != ''">
            <ns0:LotInfo>
                <ns0:LotId>
                    <ns0:Id>
                        <xsl:value-of select="CHARG"/>
                    </ns0:Id>
                    <xsl:comment>Requirement 26: SupplierId from ancestor E1EDL20/E1ADRM1 with PARTNER_Q='LF'</xsl:comment>
                    <ns0:SupplierId>
                        <xsl:value-of select="ancestor::E1EDL20/E1ADRM1[PARTNER_Q='LF']/PARTNER_ID"/>
                    </ns0:SupplierId>
                </ns0:LotId>
            </ns0:LotInfo>
        </xsl:if>
    </xsl:template>

</xsl:stylesheet>
