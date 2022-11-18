<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:api="http://nationalarchives.gov.uk/dri/catalogue/api"
                xmlns:c="http://nationalarchives.gov.uk/dri/closure" xmlns:dc="http://purl.org/dc/terms/"
                xmlns:fc="http://xip-bia/functions/common"
                xmlns:fcd="http://xip-bia/functions/coverage-date"
                xmlns:sf="http://www.nationalarchives.gov.uk/pronom/SignatureFile"
                xmlns:tna="http://nationalarchives.gov.uk/metadata/tna#"
                xmlns:tnaxm="http://nationalarchives.gov.uk/metadata/"
                xmlns:xip="http://www.tessella.com/XIP/v4" xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
                xpath-default-namespace="http://www.tessella.com/XIP/v4"
                exclude-result-prefixes="api c dc fc sf tna tnaxm xip xs xsl" version="2.0">
    

    <xsl:output indent="yes" encoding="UTF-8" omit-xml-declaration="no"/>

    <xsl:key name="du-by-parent-ref" match="/xip:XIP/xip:DeliverableUnits/xip:DeliverableUnit"
             use="string(xip:ParentRef/text())"/>

    <xsl:template match="@* | node()">
        <xsl:copy>
            <xsl:apply-templates select="@*, node()"/>
        </xsl:copy>
    </xsl:template>

    <!-- When matching folders check that they have referring children, and copy  only if they have -->
    <xsl:template match="DeliverableUnit[.//tna:DigitalFolder]">
        <xsl:variable name="currentDU" as="xs:string"><xsl:value-of select = "DeliverableUnitRef/text()"/></xsl:variable>
        <xsl:variable name="childDU" select="key('du-by-parent-ref' , $currentDU)"/>

        <xsl:if test="count($childDU) &gt; 0">
            <xsl:copy>
                <xsl:apply-templates select="@*, node()"/>
            </xsl:copy>
        </xsl:if>
   </xsl:template>

</xsl:stylesheet>