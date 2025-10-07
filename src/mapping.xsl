<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

    <!-- XSLT 3.0 transformation for DELVRY07 IDoc to OrderSync/PartSync formats -->

    <xsl:strip-space elements="*"/>
    <xsl:output method="xml" indent="yes"/>

    <!-- Root template - main entry point -->
    <xsl:template match="/">
        <Root>
            <!-- PartSync for fixed value mapping -->
            <PartSync>
                <ControlArea>
                    <Sender>
                        <!-- Feature #1: Fixed value '2' using call-template -->
                        <xsl:call-template name="fixed-confirmation-value"/>
                    </Sender>
                </ControlArea>
            </PartSync>

            <!-- OrderSync for dynamic field mappings -->
            <OrderSync>
                <DataArea>
                    <Order>
                        <OrderHead>
                            <OrderHeadId>
                                <!-- Feature #2: VBELN to Id -->
                                <xsl:apply-templates select="/DELVRY07/ZASTRO_DELVRY07/IDOC/E1EDL20/VBELN"/>
                                <!-- Feature #3: WERKS to Division -->
                                <xsl:apply-templates select="/DELVRY07/ZASTRO_DELVRY07/IDOC/E1EDL20/E1EDL24/WERKS"/>
                            </OrderHeadId>
                            <!-- Feature #4: NAME1 with PARTNER_Q='Y1' to OurReference -->
                            <xsl:apply-templates select="/DELVRY07/ZASTRO_DELVRY07/IDOC/E1EDL20/E1ADRM1[@PARTNER_Q='Y1']/NAME1"/>
                        </OrderHead>
                    </Order>
                </DataArea>
            </OrderSync>
        </Root>
    </xsl:template>

    <!-- Feature #1: Fixed value template for Confirmation -->
    <xsl:template name="fixed-confirmation-value">
        <xsl:comment>
            Fixed value mapping: Always output '2'
            Target: /PartSync/ControlArea/Sender/Confirmation
            Requirement: Feature #1 - Use call-template for fixed values
        </xsl:comment>
        <Confirmation>2</Confirmation>
    </xsl:template>

    <!-- Feature #2: VBELN to OrderHeadId/Id mapping -->
    <xsl:template match="/DELVRY07/ZASTRO_DELVRY07/IDOC/E1EDL20/VBELN">
        <xsl:comment>
            Map VBELN to OrderHeadId/Id
            Source: /DELVRY07/ZASTRO_DELVRY07/IDOC/E1EDL20/VBELN
            Target: /OrderSync/DataArea/Order/OrderHead/OrderHeadId/Id
            Requirement: Feature #2 - Use apply-templates for source mappings
        </xsl:comment>
        <Id>
            <xsl:value-of select="."/>
        </Id>
    </xsl:template>

    <!-- Feature #3: WERKS to Division mapping -->
    <xsl:template match="/DELVRY07/ZASTRO_DELVRY07/IDOC/E1EDL20/E1EDL24/WERKS">
        <xsl:comment>
            Map WERKS (plant) to Division
            Source: /DELVRY07/ZASTRO_DELVRY07/IDOC/E1EDL20/E1EDL24/WERKS
            Target: /OrderSync/DataArea/Order/OrderHead/OrderHeadId/Division
            Requirement: Feature #3 - Use apply-templates for source mappings
        </xsl:comment>
        <Division>
            <xsl:value-of select="."/>
        </Division>
    </xsl:template>

    <!-- Feature #4: NAME1 with PARTNER_Q='Y1' predicate to OurReference -->
    <xsl:template match="/DELVRY07/ZASTRO_DELVRY07/IDOC/E1EDL20/E1ADRM1[@PARTNER_Q='Y1']/NAME1">
        <xsl:comment>
            Map NAME1 from E1ADRM1 where PARTNER_Q='Y1' to OurReference
            Source: /DELVRY07/ZASTRO_DELVRY07/IDOC/E1EDL20/E1ADRM1[@PARTNER_Q='Y1']/NAME1
            Target: /OrderSync/DataArea/Order/OrderHead/OurReference
            Requirement: Feature #4 - Use apply-templates with XPath predicate
        </xsl:comment>
        <OurReference>
            <xsl:value-of select="."/>
        </OurReference>
    </xsl:template>

</xsl:stylesheet>
