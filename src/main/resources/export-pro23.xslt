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
        <xsl:choose>
            <xsl:when test="exists(Metadata/tna:metadata/rdf:RDF/tna:DigitalFolder/tna:transcription/tnatrans:Transcription)">
            <xsl:variable name="metadata"
                          select="Metadata/tna:metadata/rdf:RDF/tna:DigitalFolder/tna:transcription/tnatrans:Transcription"
                          as="node()"/>
            <xsl:element name="ScopeContent">
                <xsl:element name="Description">
                    <xsl:text>&lt;scopecontent&gt;</xsl:text>
                    <xsl:if test="$metadata/tnatrans:typeOfSeal">
                        <xsl:text>&lt;p&gt;Type of seal: </xsl:text>
                        <xsl:value-of select="$metadata/tnatrans:typeOfSeal/text()"/>
                        <xsl:text>.&lt;/p&gt;</xsl:text>
                    </xsl:if>
                    <xsl:if test="$metadata/tnatrans:sealOwner">
                        <xsl:text>&lt;p&gt;Seal owner: </xsl:text>
                        <xsl:value-of select="$metadata/tnatrans:sealOwner/text()"/>
                        <xsl:text>.&lt;/p&gt;</xsl:text>
                    </xsl:if>
                    <xsl:if test="$metadata/tnatrans:dateOfOriginalSeal">
                        <xsl:text>&lt;p&gt;Date of original seal: </xsl:text>
                        <xsl:value-of select="$metadata/tnatrans:dateOfOriginalSeal/text()"/>
                        <xsl:text>.&lt;/p&gt;</xsl:text>
                    </xsl:if>
                    <xsl:if test="$metadata/tnatrans:colourOfOriginalSeal">
                        <xsl:text>&lt;p&gt;Colour of original seal: </xsl:text>
                        <xsl:value-of select="$metadata/tnatrans:colourOfOriginalSeal/text()"/>
                        <xsl:text>.&lt;/p&gt;</xsl:text>
                    </xsl:if>
                    <xsl:if test="$metadata/tnatrans:physicalFormat">
                        <xsl:text>&lt;p&gt;Physical format: </xsl:text>
                        <xsl:value-of select="$metadata/tnatrans:physicalFormat/text()"/>
                        <xsl:text>&lt;/p&gt;</xsl:text>
                    </xsl:if>
                    <xsl:if test="$metadata/tnatrans:additionalInformation">
                        <xsl:text>&lt;p&gt;Additional information: </xsl:text>
                        <xsl:value-of select="$metadata/tnatrans:additionalInformation/text()"/>
                        <xsl:text>&lt;/p&gt;</xsl:text>
                    </xsl:if>
                    <xsl:text>&lt;/scopecontent&gt;</xsl:text>
                </xsl:element>
            </xsl:element>
            </xsl:when>
            <xsl:when test="not(normalize-space(Metadata/tna:metadata/rdf:RDF/tna:DigitalFolder/tna:cataloguing/tna:Cataloguing/dc:description)= '')">
                <xsl:element name="ScopeContent">
                   <xsl:element name="Description">
                      <xsl:text>&lt;scopecontent&gt;</xsl:text>
                      <xsl:value-of select="Metadata/tna:metadata/rdf:RDF/tna:DigitalFolder/tna:cataloguing/tna:Cataloguing/dc:description"/>
                      <xsl:text>&lt;/scopecontent&gt;</xsl:text>
                    </xsl:element>
                </xsl:element>
            </xsl:when>
        </xsl:choose>
     </xsl:template>

</xsl:stylesheet>