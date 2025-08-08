<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  
  <xsl:output method="xml" indent="yes" encoding="UTF-8"/>
  
  <!--
    XSLT 3.0 Field Mappings Implementation
    
    This stylesheet implements 4 field mappings:
    1. Fixed value '2' → /PartSync/ControlArea/Sender/Confirmation (call-template)
    2. VBELN → /OrderSync/DataArea/Order/OrderHead/OrderHeadId/Id (apply-templates)
    3. WERKS → /OrderSync/DataArea/Order/OrderHead/OrderHeadId/Division (apply-templates)
    4. E1ADRM1[PARTNER_Q='Y1']/NAME1 → /OrderSync/DataArea/Order/OrderHead/OurReference (apply-templates)
  -->
  
  <!-- Root template - coordinates the transformation -->
  <xsl:template match="/">
    <root>
      <xsl:comment>Fixed value confirmation mapping using call-template</xsl:comment>
      <xsl:call-template name="generate-fixed-confirmation"/>
      
      <xsl:comment>Source field mappings using apply-templates</xsl:comment>
      <xsl:apply-templates select="//E1EDL20"/>
    </root>
  </xsl:template>
  
  <!-- Named template for fixed value mapping (Feature #1) -->
  <xsl:template name="generate-fixed-confirmation">
    <xsl:comment>Feature #1: Fixed value '2' → /PartSync/ControlArea/Sender/Confirmation</xsl:comment>
    <PartSync>
      <ControlArea>
        <Sender>
          <Confirmation>2</Confirmation>
        </Sender>
      </ControlArea>
    </PartSync>
  </xsl:template>
  
  <!-- Match template for VBELN field mapping (Feature #2) -->
  <xsl:template match="E1EDL20">
    <xsl:comment>Feature #2: VBELN → /OrderSync/DataArea/Order/OrderHead/OrderHeadId/Id</xsl:comment>
    <OrderSync>
      <DataArea>
        <Order>
          <OrderHead>
            <OrderHeadId>
              <Id>
                <xsl:value-of select="VBELN"/>
              </Id>
              <!-- Apply templates for nested E1EDL24 to handle WERKS mapping -->
              <xsl:apply-templates select="E1EDL24"/>
            </OrderHeadId>
            <!-- Apply templates for E1ADRM1 to handle partner mapping -->
            <xsl:apply-templates select="E1ADRM1[@PARTNER_Q='Y1']"/>
          </OrderHead>
        </Order>
      </DataArea>
    </OrderSync>
  </xsl:template>
  
  <!-- Match template for WERKS field mapping (Feature #3) -->
  <xsl:template match="E1EDL24">
    <xsl:comment>Feature #3: WERKS → /OrderSync/DataArea/Order/OrderHead/OrderHeadId/Division</xsl:comment>
    <Division>
      <xsl:value-of select="WERKS"/>
    </Division>
  </xsl:template>
  
  <!-- Match template for NAME1 with partner Y1 mapping (Feature #4) -->
  <xsl:template match="E1ADRM1[@PARTNER_Q='Y1']">
    <xsl:comment>Feature #4: E1ADRM1[PARTNER_Q='Y1']/NAME1 → /OrderSync/DataArea/Order/OrderHead/OurReference</xsl:comment>
    <OurReference>
      <xsl:value-of select="NAME1"/>
    </OurReference>
  </xsl:template>
  
</xsl:stylesheet>