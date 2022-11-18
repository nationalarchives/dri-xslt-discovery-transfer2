<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:dc="http://purl.org/dc/terms/"
                xmlns:c="http://nationalarchives.gov.uk/dri/closure"
                xmlns:tna="http://nationalarchives.gov.uk/metadata/tna#"
                xmlns:tnaxm="http://nationalarchives.gov.uk/metadata/"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
                xmlns:xip="http://www.tessella.com/XIP/v4"
                xpath-default-namespace="http://www.tessella.com/XIP/v4"
                exclude-result-prefixes="dc c tna tnaxm xip xsl" version="2.0">

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

        <xsl:if test="Metadata/tna:metadata">
            <xsl:call-template name="create-access-regulation">
                <xsl:with-param name="closure" select="Metadata/tna:metadata/c:closure"/>
                <xsl:with-param name="deliverable-unit-ref" select="DeliverableUnitRef"/>
            </xsl:call-template>
        </xsl:if>
    </xsl:template>


    <!-- This is where collection specific scope content description is added -->
    <xsl:template name="deliverable-unit-scope-content">
        <xsl:if test="exists(Metadata/tna:metadata/rdf:RDF/tna:BornDigitalRecord/tna:cataloguing/tna:Cataloguing)">
            <xsl:variable name="cataloguing"
                          select="Metadata/tna:metadata/rdf:RDF/tna:BornDigitalRecord/tna:cataloguing/tna:Cataloguing"
                          as="node()"/>
            <ScopeContent>
                <Description>
                    <xsl:text>&lt;scopecontent&gt;</xsl:text>

                    <xsl:if test="$cataloguing/tna:filmName">
                        <xsl:text>&lt;p&gt;Film Name: </xsl:text>
                        <xsl:value-of select="$cataloguing/tna:filmName"/>
                        <xsl:text>&lt;/p&gt;</xsl:text>
                    </xsl:if>

                    <xsl:if test="$cataloguing/tna:summary">
                        <xsl:text>&lt;p&gt;</xsl:text>
                        <xsl:value-of select="$cataloguing/tna:summary"/>
                        <xsl:text>&lt;/p&gt;</xsl:text>
                    </xsl:if>

                    <xsl:if test="$cataloguing/tna:filmMaker">
                        <xsl:text>&lt;p&gt;Film Maker: </xsl:text>
                        <xsl:value-of select="$cataloguing/tna:filmMaker"/>
                        <xsl:text>&lt;/p&gt;</xsl:text>
                    </xsl:if>

                    <xsl:if test="$cataloguing/tna:internalDepartment">
                        <xsl:text>&lt;p&gt;Department: </xsl:text>
                        <xsl:value-of select="$cataloguing/tna:internalDepartment"/>
                        <xsl:text>&lt;/p&gt;</xsl:text>
                    </xsl:if>


                    <xsl:if test="$cataloguing/tna:classification">
                        <xsl:text>&lt;p&gt;</xsl:text>
                        <xsl:value-of select="$cataloguing/tna:classification"/>
                        <xsl:text>&lt;/p&gt;</xsl:text>
                    </xsl:if>

                    <xsl:text>&lt;/scopecontent&gt;</xsl:text>

                </Description>
            </ScopeContent>
        </xsl:if>
    </xsl:template>

</xsl:stylesheet>