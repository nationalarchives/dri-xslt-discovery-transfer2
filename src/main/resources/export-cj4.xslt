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
                exclude-result-prefixes="dc tna c tnaxm xip xsl" version="2.0">

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
        <xsl:call-template name="create-access-regulation">
            <xsl:with-param name="closure" select="Metadata/tna:metadata/c:closure"/>
            <xsl:with-param name="deliverable-unit-ref" select="DeliverableUnitRef"/>
        </xsl:call-template>
    </xsl:template>


    <xsl:template name="deliverable-unit-scope-content">
        <xsl:if test="exists(Metadata/tna:metadata/rdf:RDF/tna:BornDigitalRecord/tna:cataloguing/tna:Cataloguing)">
            <xsl:variable name="cataloguing"
                          select="Metadata/tna:metadata/rdf:RDF/tna:BornDigitalRecord/tna:cataloguing/tna:Cataloguing"
                          as="node()"/>
            <xsl:if test="exists($cataloguing/tna:businessArea) or exists($cataloguing/tna:contentManagementSystemContainer)">
                <xsl:element name="ScopeContent">
                    <xsl:element name="Description">
                        <xsl:text>&lt;scopecontent&gt;</xsl:text>
                        <xsl:if test="exists($cataloguing/tna:contentManagementSystemContainer)">
                            <xsl:text>&lt;p&gt;Content management system container: </xsl:text>
                            <xsl:value-of select="$cataloguing/tna:contentManagementSystemContainer/text()"/>
                            <xsl:text>&lt;/p&gt;</xsl:text>
                        </xsl:if>

                        <xsl:if test="exists($cataloguing/tna:businessArea)">
                            <xsl:text>&lt;p&gt;Business area: </xsl:text>
                            <xsl:value-of select="$cataloguing/tna:businessArea/text()"/>
                            <xsl:text>&lt;/p&gt;</xsl:text>
                        </xsl:if>
                        <xsl:text>&lt;/scopecontent&gt;</xsl:text>
                    </xsl:element>
                </xsl:element>
            </xsl:if>
        </xsl:if>

    </xsl:template>

</xsl:stylesheet>