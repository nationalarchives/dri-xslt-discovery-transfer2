<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    version="2.0">
    
    <xsl:output indent="yes" encoding="UTF-8" omit-xml-declaration="no"/>
    
    <xsl:param name="parent-id" required="yes"/>
    
    <xsl:template match="InformationAsset">
        <xsl:choose>
            <xsl:when test="ParentIAID eq $parent-id"/> <!-- drop the series IA -->
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