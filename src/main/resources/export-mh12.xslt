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
            <xsl:message>
                <xsl:copy-of select="$directoriesDoc"/>
            </xsl:message>
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
        <xsl:variable name="metadata" select="Metadata/tna:metadata" as="node()"/>
            <ScopeContent>
                <Description>
                    <xsl:text>&lt;scopecontent&gt;&lt;p&gt;</xsl:text>
                        <xsl:copy-of select="$metadata/rdf:RDF/tna:DigitalFolder/tna:cataloguing/tna:Cataloguing/dc:description/text()"/>
                        <xsl:if test="$metadata/rdf:RDF/tna:DigitalFolder/tna:transcription/tnatrans:Transcription/tnatrans:paperNumber">
                            <xsl:text>&lt;/p&gt;&lt;p&gt;Paper Number: </xsl:text><xsl:value-of select="$metadata/rdf:RDF/tna:DigitalFolder/tna:transcription/tnatrans:Transcription/tnatrans:paperNumber/text()"/></xsl:if>
                        <xsl:if test="$metadata/rdf:RDF/tna:DigitalFolder/tna:transcription/tnatrans:Transcription/tnatrans:poorLawUnionNumber">
                            <xsl:text>&lt;/p&gt;&lt;p&gt;Poor Law Union Number: </xsl:text><xsl:value-of select="$metadata/rdf:RDF/tna:DigitalFolder/tna:transcription/tnatrans:Transcription/tnatrans:poorLawUnionNumber/text()"/>.</xsl:if>
                        <xsl:if test="$metadata/rdf:RDF/tna:DigitalFolder/tna:transcription/tnatrans:Transcription/tnatrans:counties">
                            <xsl:text>&lt;/p&gt;&lt;p&gt;Counties: </xsl:text><xsl:value-of select="$metadata/rdf:RDF/tna:DigitalFolder/tna:transcription/tnatrans:Transcription/tnatrans:counties/text()"/>.</xsl:if>
                    <xsl:text>&lt;/p&gt;&lt;/scopecontent&gt;</xsl:text>
                </Description>
            </ScopeContent>
     </xsl:template>



</xsl:stylesheet>