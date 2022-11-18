<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:api="http://nationalarchives.gov.uk/dri/catalogue/api"
                xmlns:c="http://nationalarchives.gov.uk/dri/closure" xmlns:dc="http://purl.org/dc/terms/"
                xmlns:fc="http://xip-bia/functions/common"
                xmlns:sf="http://www.nationalarchives.gov.uk/pronom/SignatureFile"
                xmlns:tna="http://nationalarchives.gov.uk/metadata/tna#"
                xmlns:tnaxm="http://nationalarchives.gov.uk/metadata/"
                xmlns:xip="http://www.tessella.com/XIP/v4" xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xpath-default-namespace="http://www.tessella.com/XIP/v4"
                exclude-result-prefixes="api c dc fc sf tna tnaxm xip xs xsl" version="2.0">

    <!--
        This stylesheet is based completely on template matching and is designed to separate out those
        SIPs that contain new style RDF/XML metdata from those that contain old style XML metadata.
        The old style metadata will only appear in Home Guard records and possibly Leveson Inquiry records.
        The separation occurs in the DeliverableUnit match template and if old style metadata is detected
        processing is passed off to xip-to-bia-v4-b.xslt. Otherwise named templates in
        xip-to-bia-v4-templates.xslt or functions in xip-to-bia-v4-functions.xslt
        -->

    <xsl:include href="xip-to-bia-v5-templates.xslt"/>

    <xsl:output indent="yes" encoding="UTF-8" omit-xml-declaration="no"/>
    <xsl:strip-space elements="BIA"/>

    <xsl:key name="deliv-unit-by-deliverableunitref" match="DeliverableUnit"
             use="DeliverableUnitRef"/>
    <xsl:key name="deliv-unit-by-parentref" match="xip:DeliverableUnit" use="xip:ParentRef"/>
    <!-- stylesheet parameters -->
    <xsl:param name="parent-id" required="yes"/>
    <xsl:param name="droid-signature-file" required="yes"/>

    <xsl:param name="record-opening-date">
        <xsl:if test="fc:isBornDigitalReference(xip:XIP/xip:DeliverableUnits/xip:DeliverableUnit[1]/xip:CatalogueReference)">
            <xsl:value-of select="current-date()"/>
        </xsl:if>
    </xsl:param>

    <xsl:param name="directories" required="yes"/>

    <xsl:variable name="directoriesDoc">
        <xsl:choose>
            <xsl:when test="doc-available($directories)">
                <xsl:copy-of select="doc($directories)"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:message terminate="yes"
                             select="concat('Directories ''', $directories,''' is not available!')"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>

    <xsl:key name="file-by-fileref" match="File" use="FileRef"/>

    <xsl:template match="Collections">
        <!-- do nothing -->
    </xsl:template>

    <xsl:template match="Aggregations">
        <!-- do nothing -->
    </xsl:template>

    <xsl:template match="DeliverableUnits">
        <xsl:apply-templates/>
    </xsl:template>

    <xsl:template match="Files">
        <!-- do nothing -->
    </xsl:template>

    <xsl:template match="Manifestation">
        <xsl:call-template name="manifestation">
            <xsl:with-param name="manifestation" select="." as="element(Manifestation)"/>
            <xsl:with-param name="droid-signature-file" select="$droid-signature-file"/>
            <xsl:with-param name="directories" select="$directoriesDoc"/>
            <xsl:with-param name="record-opening-date" select="$record-opening-date"/>
        </xsl:call-template>
        <xsl:apply-templates/>
    </xsl:template>

    <!-- suppress default with this template -->
    <xsl:template match="text()"/>

</xsl:stylesheet>
