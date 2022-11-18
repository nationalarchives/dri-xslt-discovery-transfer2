<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="xs xsl"
    version="2.0">
    
    <!-- removes the series level IA, and set's the ParentIAID of it's children to the the $parent-id -->
    
    <xsl:output indent="yes" encoding="UTF-8" omit-xml-declaration="no"/>
    <xsl:param name="parent-id" required="yes"/>
    
    <xsl:variable name="series-ia" select="/BIA/InformationAsset[ParentIAID eq $parent-id]"/>
    
    <xsl:template match="InformationAsset">
        <xsl:variable name="currentIA" as="xs:string"><xsl:value-of select = "IAID/text()"/></xsl:variable>
        <xsl:variable name="child-ia" select="/BIA/InformationAsset[ParentIAID/text() eq $currentIA]"/>
       <xsl:choose>
            <xsl:when test="count($child-ia) &gt; 0"/>
            <xsl:otherwise>
                <xsl:copy>
                    <xsl:apply-templates/>
                </xsl:copy>
            </xsl:otherwise>
        </xsl:choose>    
    </xsl:template>
        
    <xsl:template match = "AccessRegulation" >
        <xsl:variable name="currentIA" as="xs:string"><xsl:value-of select = "RelatedToIA/text()"/></xsl:variable>
        <xsl:variable name="child-ia" select="/BIA/InformationAsset[ParentIAID/text() eq $currentIA]"/>
        
        <xsl:choose>
            <xsl:when test="count($child-ia) &gt; 0">
            </xsl:when> 
            <xsl:otherwise>
                <xsl:copy>
                    <xsl:apply-templates/>
                </xsl:copy>
            </xsl:otherwise>
        </xsl:choose>    
    </xsl:template>
    
    
    <xsl:template match="ParentIAID">
        <ParentIAID>
            <xsl:value-of select="$parent-id"/>
        </ParentIAID>
       
   </xsl:template>
    
    <xsl:template match="node()|@*">
        <xsl:copy>
            <xsl:apply-templates select="node()|@*"/>
        </xsl:copy>
    </xsl:template>
    
    <!-- Replace labels-->
    <xsl:template match="BIA/Replica/Folios/Folio/DigitalFiles/DigitalFile/DigitalFileDirectory/Folder/Label/text()[.='MOD1']">Module 1</xsl:template>
    <xsl:template match="BIA/Replica/Folios/Folio/DigitalFiles/DigitalFile/DigitalFileDirectory/Folder/Label/text()[.='MOD2']">Module 2</xsl:template>
    <xsl:template match="BIA/Replica/Folios/Folio/DigitalFiles/DigitalFile/DigitalFileDirectory/Folder/Label/text()[.='MOD3']">Module 3</xsl:template>
    <xsl:template match="BIA/Replica/Folios/Folio/DigitalFiles/DigitalFile/DigitalFileDirectory/Folder/Label/text()[.='MOD4']">Module 4</xsl:template>
    <xsl:template match="BIA/Replica/Folios/Folio/DigitalFiles/DigitalFile/DigitalFileDirectory/Folder/Label/text()[.='PROP1']">Proprietors</xsl:template>
    <xsl:template match="BIA/Replica/Folios/Folio/DigitalFiles/DigitalFile/DigitalFileDirectory/Folder/Label/text()[.='SUB']">Submissions</xsl:template>
    
</xsl:stylesheet>