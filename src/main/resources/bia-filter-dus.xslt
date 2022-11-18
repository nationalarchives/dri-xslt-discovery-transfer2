<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:api="http://nationalarchives.gov.uk/dri/catalogue/api"
    version="2.0">
    
    <xsl:strip-space elements="*"/>
    
    <!-- removes the series level IA, and set's the ParentIAID of it's children to the the $parent-id -->
    <xsl:output indent="yes" encoding="UTF-8" omit-xml-declaration="no"/>
  
<!--     <xsl:param name="pieces" as="node()" required="yes"/>-->
     <xsl:param name="pieces" as="node()">
         <xsl:document>
         <Pieces xmlns="http://nationalarchives.gov.uk/dri/catalogue/api">
             <Piece>
                 <DeliverableUnitRef>5eb56b10-bd47-4e2f-b8f3-b9738868d3c7</DeliverableUnitRef>
                 <IAID>C14568299</IAID>
             </Piece>
         </Pieces>
         </xsl:document>
     </xsl:param> 


    <!-- This template matches the InformationAssets that have the IAID equal to DeliverableUnitID in Pieces 
          and drops them
    -->
    
    <xsl:template match="InformationAsset">
        <xsl:variable name="IAIDtext" select="IAID/text()"/>
        <xsl:variable name="piece" select="$pieces/api:Pieces/api:Piece[api:DeliverableUnitRef eq $IAIDtext]"/>
        <xsl:message><xsl:value-of select="$piece"/></xsl:message>
        <xsl:choose>
            <xsl:when test="exists($piece)"/> 
            <xsl:otherwise>
                <xsl:copy>
                    <xsl:apply-templates/>
                </xsl:copy>
            </xsl:otherwise>
        </xsl:choose>        
    </xsl:template>
    
    <!-- Remove PhysicalDescription fields-->
<!--    <xsl:template match="PhysicalDescriptionExtent"/>
    <xsl:template match="PhysicalDescriptionForm"/>
    
    <xsl:template match="ClosureType/text()[.='A']">N</xsl:template>
    <xsl:template match="ClosureCode/text()[.='0']">30</xsl:template>
    <xsl:template match="RecordOpeningDate"/>
    
    <!-\- Add note -\->
    <xsl:template match="HeldBy">
        <xsl:copy-of select="."/>
        <xsl:element name="Note">The pages in this item are part of a larger record (piece). The record has been split into smaller parts during the digitisation process.</xsl:element>
    </xsl:template>
    -->
    <!-- This template matches ParentIAID and if it's equal to DeliverableUnitID, it means that the entity was 
          dropped and the ParentIAID must be replaced with the corresponding DiscoveryIAID 
    -->
    <xsl:template match="ParentIAID">
        <xsl:variable name="ParentIAIDtext" select="text()"/>
        <xsl:variable name="piece" select="$pieces/api:Pieces/api:Piece[api:DeliverableUnitRef eq $ParentIAIDtext]"/>
        <xsl:message><xsl:value-of select="$piece"/></xsl:message>
        <xsl:choose>
            <xsl:when test="exists($piece)">
                <xsl:copy>
                    <xsl:value-of select="$piece/api:IAID"/>
                </xsl:copy>
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy>
                    <xsl:apply-templates/>
                </xsl:copy>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
       
    <xsl:template match="node()|@*">
        <xsl:copy>
            <xsl:apply-templates select="node()|@*"/>
        </xsl:copy>
    </xsl:template>
    
</xsl:stylesheet>