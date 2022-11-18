<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:api="http://nationalarchives.gov.uk/dri/catalogue/api"
                xmlns:c="http://nationalarchives.gov.uk/dri/closure" xmlns:dc="http://purl.org/dc/terms/"
                xmlns:fc="http://xip-bia/functions/common"
                xmlns:sf="http://www.nationalarchives.gov.uk/pronom/SignatureFile"
                xmlns:tna="http://nationalarchives.gov.uk/metadata/tna#"
                xmlns:tnaxm="http://nationalarchives.gov.uk/metadata/"
                xmlns:tnatrans="http://nationalarchives.gov.uk/dri/transcription"
                xmlns:xip="http://www.tessella.com/XIP/v4" xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
                xpath-default-namespace="http://www.tessella.com/XIP/v4"
                exclude-result-prefixes="api c dc fc sf tna tnaxm tnatrans xip xs xsl" version="2.0">


    <xsl:include href="xip-to-bia-v4-functions.xslt"/>

    <xsl:template name="deliverable-unit-top">
        <xsl:choose>
            <xsl:when test="Metadata/tna:metadata">
                <xsl:variable name="metadata" as="node()">
                    <xsl:choose>
                        <xsl:when test="Metadata/tna:metadata/rdf:RDF/tna:DigitalFolder">
                            <xsl:copy-of select="Metadata/tna:metadata/rdf:RDF/tna:DigitalFolder"/>
                        </xsl:when>
                        <xsl:when test="Metadata/tna:metadata/rdf:RDF/tna:BornDigitalRecord">
                            <xsl:copy-of select="Metadata/tna:metadata/rdf:RDF/tna:BornDigitalRecord"/>
                        </xsl:when>
                    </xsl:choose>
                </xsl:variable>
                <xsl:variable name="cataloguing" select="Metadata/tna:metadata//tna:Cataloguing"
                              as="node()"/>
                <xsl:variable name="source-level-id" select="fc:get-source-level-id($cataloguing)"
                              as="xs:integer"/>
                <!-- TODO - move above choose -->
                <IAID>
                    <xsl:choose>
                        <xsl:when test="$cataloguing/tna:iaid ne ''">
                            <xsl:value-of select="$cataloguing/tna:iaid"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="DeliverableUnitRef"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </IAID>

                <!-- SourceLevelId -->
                <xsl:call-template name="source-level-id">
                    <xsl:with-param name="source-level-id" select="$source-level-id"/>
                </xsl:call-template>

                <!-- ParentIAID -->
                <xsl:call-template name="parent-iaid">
                    <xsl:with-param name="deliverable-unit" select="."/>
                    <xsl:with-param name="parent-id" select="$parent-id"/>
                    <xsl:with-param name="parent" select="key('deliv-unit-by-deliverableunitref',./ParentRef)"/>
                </xsl:call-template>


                <xsl:call-template name="create-catalogue-reference">
                    <xsl:with-param name="catalogue-reference" select="CatalogueReference"/>
                </xsl:call-template>

                <CatalogueId>0</CatalogueId>
                <!-- this is always 0 according to original XSLT -->

                <xsl:if test="$cataloguing/dc:language">
                    <Language>
                        <xsl:value-of select="$cataloguing/dc:language"></xsl:value-of>
                    </Language>
                </xsl:if>

                <LegalStatus>
                    <xsl:value-of select="fc:legal-status-from-rdf($cataloguing/tna:legalStatus/@rdf:resource)"/>
                </LegalStatus>

                <xsl:if test="$cataloguing/tna:formerReferenceDepartment">
                    <FormerReferenceDep>
                        <xsl:value-of select="$cataloguing/tna:formerReferenceDepartment"></xsl:value-of>
                    </FormerReferenceDep>
                </xsl:if>

                <xsl:if test="$cataloguing/tna:formerReferenceTNA">
                    <FormerReferencePro>
                        <xsl:value-of select="$cataloguing/tna:formerReferenceTNA"></xsl:value-of>
                    </FormerReferencePro>
                </xsl:if>

                <!--<xsl:value-of select="fc:substring-after-last($cataloguing/tna:legalStatus/@rdf:resource, '/')"/>-->

                <!-- Title will not be sent, it appears as label in Discovery, but it's not needed -->
                <!--                    <Title>
                    <xsl:value-of select="CatalogueReference"/>
                </Title>-->

                <xsl:if test="$cataloguing/dc:title">
                    <Title>
                        <xsl:choose>
                            <xsl:when test="$metadata/c:closure/c:titleAlternate">
                                <xsl:value-of select="$metadata/c:closure/c:titleAlternate"/>
                            </xsl:when>
                            <xsl:when test="$cataloguing/tna:curatedTitle">
                                <xsl:value-of select="$cataloguing/tna:curatedTitle"/>
                            </xsl:when>
                            <xsl:when test="count($cataloguing/dc:title) &gt; 1">
                                 <xsl:value-of select="$cataloguing/dc:title[1]/text()"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="$cataloguing/dc:title"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </Title>
                </xsl:if>

                <xsl:choose>
                    <xsl:when
                            test="$cataloguing/dc:coverage/tna:dateRange or $cataloguing/dc:coverage/tna:CoveringDates/tna:fullDate">
                        <xsl:variable name="extracted-date">
                            <xsl:choose>
                                <xsl:when test="$cataloguing/dc:coverage/tna:dateRange">
                                    <xsl:value-of select="$cataloguing/dc:coverage/tna:dateRange"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:value-of select="$cataloguing/dc:coverage/tna:CoveringDates/tna:fullDate"/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:variable>
                        <CoveringDates>
                            <xsl:value-of select="$extracted-date"/>
                        </CoveringDates>
                    </xsl:when>
                    <xsl:when test="$cataloguing/dc:coverage">
                        <!-- WO_95-->
                        <CoveringDates>
                            <xsl:variable name="start_date">
                                <xsl:variable name="date"
                                              select="$cataloguing/dc:coverage/tna:CoveringDates/tna:startDate"/>
                                <xsl:choose>
                                    <xsl:when test="$date castable as xs:dateTime">
                                        <xsl:value-of
                                                select="fc:dateTime-to-pretty-reverse-sequential-date(xs:dateTime($date))"/>
                                    </xsl:when>
                                    <xsl:when test="$date castable as xs:date">
                                        <xsl:value-of
                                                select="fc:date-to-pretty-reverse-sequential-date(xs:date($date))"/>
                                    </xsl:when>
                                    <xsl:when test="fc:isSlashDate($date)">
                                        <xsl:value-of select="fc:dateSlashToFormattedDate($date)"/>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:value-of select="$date"/>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:variable>
                            <xsl:variable name="end_date">
                                <xsl:variable name="date"
                                              select="$cataloguing/dc:coverage/tna:CoveringDates/tna:endDate"/>
                                <xsl:choose>
                                    <xsl:when test="$date">
                                        <xsl:choose>
                                            <xsl:when test="$date castable as xs:dateTime">
                                                <xsl:value-of
                                                        select="fc:dateTime-to-pretty-reverse-sequential-date(xs:dateTime($date))"/>
                                            </xsl:when>
                                            <xsl:when test="$date castable as xs:date">
                                                <xsl:value-of
                                                        select="fc:date-to-pretty-reverse-sequential-date(xs:date($date))"/>
                                            </xsl:when>
                                            <xsl:when test="fc:isSlashDate($date)">
                                                <xsl:value-of select="fc:dateSlashToFormattedDate($date)"/>
                                            </xsl:when>
                                            <xsl:otherwise>
                                                <xsl:value-of select="$date"/>
                                            </xsl:otherwise>
                                        </xsl:choose>
                                    </xsl:when>
                                    <xsl:when test="$metadata//dc:modified">
                                        <xsl:choose>
                                            <xsl:when
                                                    test="$metadata//dc:modified castable as xs:dateTime">
                                                <xsl:value-of
                                                        select="fc:dateTime-to-pretty-reverse-sequential-date($metadata//dc:modified)"/>
                                            </xsl:when>
                                            <xsl:otherwise>
                                                <xsl:value-of select="$metadata//dc:modified"/>
                                            </xsl:otherwise>
                                        </xsl:choose>

                                    </xsl:when>
                                </xsl:choose>
                            </xsl:variable>


                            <xsl:choose>
                                <xsl:when test="($start_date=$end_date)">
                                    <xsl:value-of select="$start_date"/>
                                </xsl:when>
                                <xsl:when test="(string($end_date))">
                                    <xsl:value-of select="$start_date"/> -
                                    <xsl:value-of
                                            select="$end_date"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:value-of select="$start_date"/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </CoveringDates>
                    </xsl:when>
                    <xsl:when test="$metadata//dc:modified">
                        <!-- RF_5, or born digital model-->
                        <CoveringDates>
                            <xsl:value-of
                                    select="fc:dateTime-to-pretty-reverse-sequential-date($metadata//dc:modified)"
                            />
                        </CoveringDates>
                    </xsl:when>
                </xsl:choose>

                <xsl:if test="not(SecurityTag/text() eq 'Surrogate')">
                    <!-- Default: 1 (for a file) -->
                    <PhysicalDescriptionExtent>1</PhysicalDescriptionExtent>
                    <!-- Default: digital record (for a file) -->
                    <PhysicalDescriptionForm>digital record</PhysicalDescriptionForm>
                </xsl:if>

                <xsl:if test="$metadata/tna:transcription/tnatrans:Transcription/tnatrans:dimensions">
                    <Dimensions>
                        <xsl:value-of
                                select="$metadata/tna:transcription/tnatrans:Transcription/tnatrans:dimensions"></xsl:value-of>
                    </Dimensions>
                </xsl:if>


                <xsl:if test="$cataloguing/tna:physicalCondition">
                    <PhysicalCondition>
                        <xsl:value-of select="$cataloguing/tna:physicalCondition"/>
                    </PhysicalCondition>
                </xsl:if>

                <!-- HeldBy -->
                <xsl:call-template name="held-by">
                    <xsl:with-param name="held-by" select="$cataloguing/tna:heldBy"/>
                </xsl:call-template>


                <xsl:if test="fc:hasNoteText($cataloguing)">
                    <Note>
                        <xsl:value-of select="fc:noteText($cataloguing)"/>
                    </Note>
                </xsl:if>
                <xsl:call-template name="closure">
                    <xsl:with-param name="closure" select="Metadata/tna:metadata/c:closure"/>
                    <xsl:with-param name="record-opening-date" select="$record-opening-date"/>
                </xsl:call-template>

                <xsl:choose>
                    <xsl:when test="$cataloguing/tna:restrictionOnUse">
                        <RestrictionOnUse>
                            <xsl:value-of select="$cataloguing/tna:restrictionOnUse"/>
                        </RestrictionOnUse>
                    </xsl:when>
                    <xsl:when test="$cataloguing/dc:rights and fc:shouldHaveRestrictions($cataloguing/dc:rights)">
                        <RestrictionOnUse>
                            <xsl:text>Copyright: </xsl:text>
                            <!--<xsl:value-of select="concat('Copyright: ',$cataloguing/dc:rights)"/>-->
                            <xsl:call-template name="restrictions">
                                <xsl:with-param name="cataloguing" select="$cataloguing"/>
                            </xsl:call-template>
                        </RestrictionOnUse>
                    </xsl:when>
                </xsl:choose>

            </xsl:when>
        </xsl:choose>
    </xsl:template>

</xsl:stylesheet>