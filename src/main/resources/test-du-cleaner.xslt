<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:dc="http://purl.org/dc/terms/"
                xmlns:c="http://nationalarchives.gov.uk/dri/closure"
                xmlns:tna="http://nationalarchives.gov.uk/metadata/tna#"
                xmlns:tnaxm="http://nationalarchives.gov.uk/metadata/"
                xmlns:tnatrans="http://nationalarchives.gov.uk/dri/transcription"
                xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xip="http://www.tessella.com/XIP/v4"
                xpath-default-namespace="http://www.tessella.com/XIP/v4"
                version="2.0">


    <xsl:template match="/">
        <xsl:apply-templates/>
    </xsl:template>


    <xsl:template match="xip:DeliverableUnit">
         <xsl:if test="xip:Metadata">
             <xsl:element name="xip:DeliverableUnit">
             <xsl:apply-templates/>
             </xsl:element>
        </xsl:if>
    </xsl:template>


    <xsl:template match="node()|@*">
        <xsl:copy>
            <xsl:apply-templates select="node()|@*"/>
        </xsl:copy>
    </xsl:template>

</xsl:stylesheet>