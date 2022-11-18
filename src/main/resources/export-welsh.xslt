<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:dc="http://purl.org/dc/terms/"
                xmlns:c="http://nationalarchives.gov.uk/dri/closure"
                xmlns:tna="http://nationalarchives.gov.uk/metadata/tna#"
                xmlns:tnaxm="http://nationalarchives.gov.uk/metadata/"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xip="http://www.tessella.com/XIP/v4"
                xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
                xpath-default-namespace="http://www.tessella.com/XIP/v4"
                exclude-result-prefixes="dc c tna tnaxm xip xsl" version="2.0">

    <xsl:import href="xip-to-bia-v4-base.xslt"/>
    <xsl:include href="xip-to-bia-deliverable-unit-top.xslt"/>
    <xsl:include href="xip-to-bia-deliverable-unit-bottom.xslt"/>

    <xsl:template match="XIP">
        <BIA>
            <xsl:apply-templates/>
        </BIA>
    </xsl:template>

    <xsl:template match="DeliverableUnit">
        <InformationAsset>
            <xsl:call-template name="deliverable-unit-top"/>
            <xsl:call-template name="deliverable-unit-scope-content"/>
            <xsl:call-template name="deliverable-unit-bottom"/>
        </InformationAsset>
        <xsl:if test="Metadata/tna:metadata">
            <xsl:call-template name="create-access-regulation">
                <xsl:with-param name="closure" select="Metadata/tna:metadata/c:closure"/>
                <xsl:with-param name="deliverable-unit-ref" select="DeliverableUnitRef"/>
            </xsl:call-template>
        </xsl:if>
    </xsl:template>


    <!-- This is where collection specific scope content description is added -->
    <xsl:template name="deliverable-unit-scope-content">
       <xsl:if test="count(Metadata/tna:metadata/rdf:RDF/tna:BornDigitalRecord/tna:cataloguing/tna:Cataloguing/dc:title) &gt; 1">
            <xsl:variable name="title" select="Metadata/tna:metadata/rdf:RDF/tna:BornDigitalRecord/tna:cataloguing/tna:Cataloguing/dc:title[2]/text()"/>
            <ScopeContent>
                <Description>
                    <xsl:text>&lt;scopecontent&gt;</xsl:text>
                        <xsl:text>English translation of file name: </xsl:text>
                        <xsl:value-of select="$title"/>
                    <xsl:text>&lt;/scopecontent&gt;</xsl:text>
                </Description>
            </ScopeContent>
        </xsl:if>
    </xsl:template>

</xsl:stylesheet>