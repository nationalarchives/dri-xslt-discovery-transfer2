<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:fc="http://xip-bia/functions/common"
    xmlns:fbdx = "http://xip-bia/functions/born-digital"
    xmlns:xip="http://www.tessella.com/XIP/v4"
    xmlns:dc="http://purl.org/dc/terms/"
    xmlns:tnaxm="http://nationalarchives.gov.uk/metadata/"
    xmlns:tnacg="http://nationalarchives.gov.uk/catalogue/generated/2014/"
    version="2.0">
    
    <!-- This XSLT is included into xip-to-bia_v3.xslt -->
    
    <xsl:output indent="yes" encoding="UTF-8" omit-xml-declaration="no"/>
    
    <xsl:function name="fbdx:has-born-digital-identifier" as="xs:boolean">
        <xsl:param name="identifier" as="element()*"/>
        <xsl:value-of select="$identifier/@xsi:type = 'tnacgdc:generatedReferenceIdentifier'"/>
    </xsl:function>
    
    <xsl:function name="fbdx:get-born-digital-identifier" as="element()">
        <xsl:param name="identifier" as="element()*"/>
        <xsl:copy-of select="$identifier[@xsi:type = 'tnacgdc:generatedReferenceIdentifier']"/>
    </xsl:function>
    
    <xsl:function name="fbdx:depth" as="xs:integer">
        <xsl:param name="deliverable-unit" as="element(xip:DeliverableUnit)?"/>
        <xsl:param name="depth" as="xs:integer"/>
        <xsl:choose>
            <xsl:when test="empty($deliverable-unit)">
                <xsl:value-of select="$depth"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:variable name="context" select="$deliverable-unit/parent::xip:DeliverableUnits"/>
                <xsl:variable name="parent-deliverable-unit" select="key('deliv-unit-by-deliverableunitref', $deliverable-unit/xip:ParentRef, $context)"/>
                <xsl:value-of select="fbdx:depth($parent-deliverable-unit, $depth + 1)"/>
            </xsl:otherwise>
        </xsl:choose>    
    </xsl:function>
    
    <xsl:function name="fbdx:reference" as="xs:string">
        <xsl:param name="identifier" as="element()"/>
        <xsl:variable name="ident" select="$identifier[@xsi:type eq 'tnacgdc:generatedReferenceIdentifier']" as="element()"/>
        <!--
            Alex Green requested on behalf of Emma Bayne
            that the Z is prefixed with a '/'
            for Generated Catalogue References
            on 2014-04-04
        -->
        <!-- xsl:value-of select="string-join(($ident/tnacg:recordNumber, 'Z', $ident/tnacg:revisionNumber), ' ')"/ -->
        <xsl:value-of select="concat($ident/tnacg:recordNumber, '/', 'Z', $ident/tnacg:revisionNumber)"/>
    </xsl:function>
    
    <xsl:function name="fbdx:title" as="xs:string">
        <xsl:param name="metadata" as="element(tnaxm:metadata)"/>
        <xsl:param name="fallback-title" as="element(xip:Title)"/>
        <xsl:choose>
            <xsl:when test="not(empty($metadata/dc:title)) and fc:is-open-description($metadata)"><xsl:value-of select="$metadata/dc:title"/></xsl:when>
            <xsl:otherwise><xsl:value-of select="$fallback-title"/></xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <xsl:template name="fbdx:scope-content" exclude-result-prefixes="#all">
        <xsl:param name="source-level-id" as="xs:integer" required="yes"/>
        <xsl:param name="metadata" as="element(tnaxm:metadata)" required="yes"/>
        <xsl:param name="fallback-description" as="element(xip:Title)" required="yes"/>
        <ScopeContent>
            <xsl:if test="$source-level-id ne 4">
                <!--
                    Description MUST NOT be sent at Catalogue Level 4 for Born Digital Records
                    Change requested by Emma Bayne on 2014-04-09
                -->
                <Description><xsl:value-of select="fbdx:title($metadata, $fallback-description)"/></Description>
            </xsl:if>
        </ScopeContent>
    </xsl:template>
    
    <xsl:function name="fbdx:batch-id" as="xs:string">
        <xsl:param name="metadata" as="element(tnaxm:metadata)"/>
        <xsl:variable name="partIdentifier" select="$metadata/dc:isPartOf[@xsi:type eq 'tnaxmdc:partIdentifier']" as="element(dc:isPartOf)"/>
        <xsl:value-of select="concat($partIdentifier/tnaxm:part/tnaxm:unit, '/', $partIdentifier/tnaxm:part/tnaxm:series)"/>
    </xsl:function>
    
</xsl:stylesheet>