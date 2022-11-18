<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
    xmlns:c="http://nationalarchives.gov.uk/dri/closure"
    xmlns:dc="http://purl.org/dc/terms/"
    xmlns:dce="http://purl.org/dc/elements/1.1/"
    xmlns:fc="http://xip-bia/functions/common"
    xmlns:tnaxm="http://nationalarchives.gov.uk/metadata/"
    xmlns:xip="http://www.tessella.com/XIP/v4"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xpath-default-namespace="http://www.tessella.com/XIP/v4"
    exclude-result-prefixes="c dc dce fc tnaxm xip xs xsi xsl"
    version="2.0">
    
    <!--
        This stylesheet contains one named template for processing DeliverableUnits
        that contain old style XML metadata as opposed to new style RDF/XML metadata.
        The rest of the processing is done through named templates in xip-to-bia-v4-templates.xslt
        and functions in xip-to-bia-v4-funcations.xslt
        -->

    <xsl:include href="xip-to-bia-v4-templates.xslt"/>

    <xsl:key name="deliv-unit-by-parentref" match="xip:DeliverableUnit" use="xip:ParentRef"/>

    <xsl:template name="deliverable-unit">
        <xsl:param name="parent-id" as="xs:string" required="yes"/>
        <xsl:variable name="metadata" select="Metadata/tnaxm:metadata"/>

        <!-- xsl:variable name="deliverable-unit-ref" select="DeliverableUnitRef"/ -->
        <xsl:variable name="source-level-id" as="xs:integer?">
            <xsl:choose>
                <xsl:when test="fc:has-born-digital-identifier($metadata/(dc:identifier|dce:identifier))">
                    <!-- we start at depth=1 as we need to attach to a top-level series IA in Discovery (and that series IA is at level 1) -->
                    <xsl:value-of select="fc:hack-source-level-id(fc:depth(., 1))"/>
                </xsl:when>
                <xsl:when test="fc:has-digitized-identifier($metadata/(dc:identifier|dce:identifier))">
                    <xsl:value-of select="fc:source-level-id($metadata/(dc:identifier|dce:identifier)[@xsi:type = ('tnacdc:pieceIdentifier', 'tnacdc:itemIdentifier')])"/>
                </xsl:when>
            </xsl:choose>
        </xsl:variable>

        <InformationAsset>
            <IAID><xsl:value-of select="DeliverableUnitRef"/></IAID>

            <!-- SourceLevelId -->
            <xsl:call-template name="source-level-id">
                <xsl:with-param name="source-level-id" select="$source-level-id"/>
            </xsl:call-template>

            <!-- ParentIAID -->
            <xsl:call-template name="parent-iaid">
                <xsl:with-param name="deliverable-unit" select="."/>
                <xsl:with-param name="parent-id" select="$parent-id"/>
                <xsl:with-param name="parent" select="key('deliv-unit-by-parentref',./ParentRef)"/>
            </xsl:call-template>


            <xsl:call-template name="create-catalogue-reference">
                <xsl:with-param name="catalogue-reference" select="CatalogueReference"/>
            </xsl:call-template>

            <CatalogueId>0</CatalogueId> <!-- this is always 0 according to original XSLT -->

            <LegalStatus>Public Record</LegalStatus> <!-- this information is not available in old style metadata so we have to use a static value -->

            <xsl:choose>
                <xsl:when test="fc:has-born-digital-identifier($metadata/(dc:identifier|dce:identifier))">

                    <!--
                        Title MUST NOT be sent at Catalogue Level 6 for Born Digital Records
                        Change requested by Emma Bayne on 2014-04-09
                    -->
                    <xsl:if test="$source-level-id ne 6">
                        <Title><xsl:value-of select="fc:title($metadata, Title)"/></Title>
                    </xsl:if>

                </xsl:when>
                <xsl:when test="fc:has-digitized-identifier($metadata/(dc:identifier|dce:identifier))">
                    <Title><xsl:value-of select="fc:hg-title($metadata, CatalogueReference)"/></Title>
                </xsl:when>
                <xsl:otherwise>
                    <!-- xsl:message terminate="yes" select="concat('Could not calculate Title for DU: ', DeliverableUnitId)"/ -->
                </xsl:otherwise>
            </xsl:choose>


            <xsl:if test="fc:has-born-digital-identifier($metadata/(dc:identifier|dce:identifier))">
                <CoveringDates>
                    <xsl:value-of select="fc:dateTime-to-pretty-reverse-sequential-date($metadata/dc:modified)"/>
                </CoveringDates>
            </xsl:if>

            <!-- Default: 1 (for a file) -->
            <PhysicalDescriptionExtent>1</PhysicalDescriptionExtent>

            <!-- Default: digital record (for a file) -->
            <PhysicalDescriptionForm>digital record</PhysicalDescriptionForm>

            <xsl:call-template name="held-by">
                <xsl:with-param name="held-by" select="$metadata/dc:publisher"/>
            </xsl:call-template>

            <xsl:call-template name="closure">
                <xsl:with-param name="closure" select="$metadata/c:closure"/>
                <xsl:with-param name="record-opening-date" select="$record-opening-date"/>
            </xsl:call-template>

            <xsl:choose>
                <xsl:when test="fc:has-born-digital-identifier($metadata/(dc:identifier|dce:identifier))">
                    <xsl:call-template name="scope-content">
                        <xsl:with-param name="source-level-id" select="$source-level-id"/>
                        <xsl:with-param name="metadata" select="$metadata"/>
                        <xsl:with-param name="fallback-description" select="Title"/>
                    </xsl:call-template>
                </xsl:when>
                <xsl:when test="fc:has-digitized-identifier($metadata/(dc:identifier|dce:identifier))">
                    <xsl:call-template name="hg-scope-content">
                        <xsl:with-param name="metadata" select="$metadata"/>
                    </xsl:call-template>

                    <xsl:call-template name="personal-names">
                        <xsl:with-param name="metadata" select="$metadata"/>
                    </xsl:call-template>

                    <xsl:call-template name="places">
                        <xsl:with-param name="metadata" select="$metadata"/>
                    </xsl:call-template>
                </xsl:when>
             </xsl:choose>

            <BatchId>
                <xsl:choose>
                    <xsl:when test="fc:has-born-digital-identifier($metadata/(dc:identifier|dce:identifier))">
                        <xsl:value-of select="fc:batch-id($metadata)"/>
                    </xsl:when>
                    <xsl:when test="fc:has-digitized-identifier($metadata/(dc:identifier|dce:identifier))">
                        <xsl:value-of select="fc:hg-batch-id($metadata)"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <!-- xsl:message terminate="yes" select="concat('Could not calculate BatchId for DU: ', DeliverableUnitId)"/ -->
                    </xsl:otherwise>
                </xsl:choose>
            </BatchId>

            <xsl:choose>
                <xsl:when test="fc:has-born-digital-identifier($metadata/(dc:identifier|dce:identifier))">
                    <!--
                        Alex Green requested on behalf of Emma Bayne
                        that the CoveringFromDate and CoveringToDate should
                        be the same for born-digital records
                        on 2014-04-04
                    -->
                    <xsl:variable name="covering-date" select="fc:dateTime-to-reverse-sequential-date($metadata/dc:modified)"/>
                    <CoveringFromDate>
                        <xsl:value-of select="$covering-date"/>
                    </CoveringFromDate>
                    <CoveringToDate>
                        <xsl:value-of select="$covering-date"/>
                    </CoveringToDate>
                </xsl:when>
            </xsl:choose>

            <LiveFlag>0</LiveFlag>
            <!-- this is always 0 according to original XSLT -->

            <!--
                Aleks Drozdov requested
                that we set Digitized to false
                for source-level-id 4
                on 2013-04-02
            -->
            <xsl:choose>
                <xsl:when test="fc:has-born-digital-identifier($metadata/(dc:identifier|dce:identifier)) and $source-level-id eq 4">
                    <Digitized>false</Digitized>
                </xsl:when>
                <xsl:otherwise>
                    <Digitized>true</Digitized> <!-- this is always true according to original XSLT -->
                </xsl:otherwise>
            </xsl:choose>

            <xsl:call-template name="replica-identities">
                <xsl:with-param name="deliverable-unit-ref" select="DeliverableUnitRef"/>
            </xsl:call-template>

        </InformationAsset>

        <xsl:variable name ="docClosureStatus" select="./Metadata/tnaxm:metadata/c:closure/c:documentClosureStatus" />
        <xsl:if test="$docClosureStatus eq 'CLOSED'">
            <AccessRegulation>
                <RelatedToIA><xsl:value-of select="DeliverableUnitRef"/></RelatedToIA>
                <ClosureCriterions>
                    <xsl:for-each select="./Metadata/tnaxm:metadata/c:closure/c:exemptionCode">
                        <ClosureCriterion>
                            <ExemptionCodeId>
                                <xsl:value-of select="."/>
                            </ExemptionCodeId>
                        </ClosureCriterion>
                    </xsl:for-each>
                </ClosureCriterions>
                <SignedDate><xsl:value-of select="./Metadata/tnaxm:metadata/c:closure/c:exemptionAsserted" /></SignedDate>
                <ReviewDate/>
                <ReconsiderDueInDate/>
                <Explanation></Explanation>
                <ProcatTitle>Exemption</ProcatTitle>
            </AccessRegulation>
        </xsl:if>
    </xsl:template>



</xsl:stylesheet>