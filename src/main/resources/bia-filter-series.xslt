<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    version="2.0">
    
    <!-- removes the series level IA, and set's the ParentIAID of it's children to the the $parent-id -->
    
    <xsl:output indent="yes" encoding="UTF-8" omit-xml-declaration="no"/>
    
    <xsl:param name="parent-id" required="yes"/>
    
    <xsl:variable name="series-ia" select="/BIA/InformationAsset[ParentIAID eq $parent-id]"/>
    
    <xsl:template match="InformationAsset">
        <xsl:choose>
            <xsl:when test="IAID eq $series-ia/IAID"/> <!-- drop the series IA -->
            <xsl:otherwise>
                <xsl:copy>
                    <xsl:apply-templates/>
                </xsl:copy>
            </xsl:otherwise>
        </xsl:choose>        
    </xsl:template>
    
    <xsl:template match="ParentIAID">
        <xsl:choose>
            <xsl:when test=". = $series-ia/IAID">
                <xsl:copy>
                    <xsl:value-of select="$parent-id"/>
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