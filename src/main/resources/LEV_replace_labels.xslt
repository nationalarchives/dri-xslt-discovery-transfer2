<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:api="http://nationalarchives.gov.uk/dri/catalogue/api"
    version="2.0">
       
    <!-- Replace labels-->
    <xsl:template match="BIA/Replica/Folios/Folio/DigitalFiles/DigitalFile/DigitalFileDirectory/Folder/Label/text()[.='MOD1']">Module 1</xsl:template>
    <xsl:template match="BIA/Replica/Folios/Folio/DigitalFiles/DigitalFile/DigitalFileDirectory/Folder/Label/text()[.='MOD2']">Module 2</xsl:template>
    <xsl:template match="BIA/Replica/Folios/Folio/DigitalFiles/DigitalFile/DigitalFileDirectory/Folder/Label/text()[.='MOD3']">Module 3</xsl:template>
    <xsl:template match="BIA/Replica/Folios/Folio/DigitalFiles/DigitalFile/DigitalFileDirectory/Folder/Label/text()[.='MOD4']">Module 4</xsl:template>
    <xsl:template match="BIA/Replica/Folios/Folio/DigitalFiles/DigitalFile/DigitalFileDirectory/Folder/Label/text()[.='PROP1']">Proprietors</xsl:template>
    <xsl:template match="BIA/Replica/Folios/Folio/DigitalFiles/DigitalFile/DigitalFileDirectory/Folder/Label/text()[.='SUB']">Submissions</xsl:template>
    
    
    
    <xsl:template match="node()|@*">
        <xsl:copy>
            <xsl:apply-templates select="node()|@*"/>
        </xsl:copy>
    </xsl:template>
    
</xsl:stylesheet>