<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:api="http://nationalarchives.gov.uk/dri/catalogue/api"
                xmlns:c="http://nationalarchives.gov.uk/dri/closure" xmlns:dc="http://purl.org/dc/terms/"
                xmlns:fc="http://xip-bia/functions/common"
                xmlns:fcd="http://xip-bia/functions/coverage-date"
                xmlns:sf="http://www.nationalarchives.gov.uk/pronom/SignatureFile"
                xmlns:tna="http://nationalarchives.gov.uk/metadata/tna#"
                xmlns:tnaxm="http://nationalarchives.gov.uk/metadata/"
                xmlns:tnatrans="http://nationalarchives.gov.uk/dri/transcription"
                xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
                xmlns:xip="http://www.tessella.com/XIP/v4" xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xpath-default-namespace="http://www.tessella.com/XIP/v4"
                exclude-result-prefixes="api c dc fc sf tna tnatrans tnaxm xip xs xsl fcd rdf" version="2.0">

    <xsl:template name="deliverable-unit-bottom">
        <xsl:choose>
            <xsl:when test="not(Metadata/tnaxm:metadata) and Metadata/tna:metadata">
                <xsl:variable name="metadata"  as="node()">
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

                    <xsl:choose>
                        <xsl:when test="$cataloguing/dc:relation">
                            <RelatedMaterials>
                                <RelatedMaterial>
                                    <Description>
                                        <xsl:value-of select="$cataloguing/dc:relation"/>
                                    </Description>
                                </RelatedMaterial>
                            </RelatedMaterials>
                        </xsl:when>
                        <xsl:when test="$metadata/tna:transcription/tnatrans:Transcription/tnatrans:relatedMaterial">
                            <RelatedMaterials>
                                <RelatedMaterial>
                                    <Description>
                                        <xsl:value-of select="$metadata/tna:transcription/tnatrans:Transcription/tnatrans:relatedMaterial"/>
                                    </Description>
                                    <xsl:if test="$cataloguing/tna:relatedIaid">
                                        <IAID><xsl:value-of select="$cataloguing/tna:relatedIaid"/></IAID>
                                    </xsl:if>
                                </RelatedMaterial>
                            </RelatedMaterials>
                        </xsl:when>
                    </xsl:choose>

                    <xsl:if test="$cataloguing/tna:separatedMaterial">
                        <SeparatedMaterials>
                            <SeparatedMaterial>
                                <Description>
                                    <xsl:value-of select="$cataloguing/tna:separatedMaterial"/>
                                </Description>
                            </SeparatedMaterial>
                        </SeparatedMaterials>
                    </xsl:if>
                    <!-- Arrangement is here used for the working path, and it will be populated for all open born
                        digital records - document closure status is OPEN and catalogue reference ends in Z -->

                    <xsl:variable name ="docClosureStatus" select="$metadata/c:closure/c:documentClosureStatus" />
                    <xsl:variable name ="catRef" select="CatalogueReference" />
                    <xsl:if test="ends-with($catRef, 'Z') or ends-with($catRef, 'Z/1')">
                        <Arrangement>This born digital record was arranged under the following file structure: </Arrangement>
                    </xsl:if>

                    <xsl:if test="$cataloguing/tna:administrativeBackground">
                        <AdministrativeBackground>
                            <xsl:value-of select="$cataloguing/tna:administrativeBackground"/>
                        </AdministrativeBackground>
                    </xsl:if>

                    <BatchId>
                        <xsl:value-of select="$cataloguing/tna:batchIdentifier"/>
                    </BatchId>

                    <xsl:choose>
                        <xsl:when test="$cataloguing/dc:coverage/tna:dateRange or $cataloguing/dc:coverage/tna:CoveringDates/tna:fullDate">
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
                            <xsl:choose>
                                <xsl:when test="$cataloguing/dc:coverage/tna:CoveringDates/tna:startDate ne ''">
                                    <CoveringFromDate>
                                        <xsl:variable name="start-date" select="fcd:extract-full-start-date($cataloguing/dc:coverage/tna:CoveringDates/tna:startDate)"/>
                                        <xsl:value-of select="fc:catalogueDate-to-reverse-sequential-date-start($start-date)"/>
                                    </CoveringFromDate>
                                    <CoveringToDate>
                                        <xsl:variable name="end-date" select="fcd:extract-full-end-date($cataloguing/dc:coverage/tna:CoveringDates/tna:endDate)"/>
                                        <xsl:value-of select="fc:catalogueDate-to-reverse-sequential-date-last($end-date)"/>
                                    </CoveringToDate>
                                </xsl:when>
                                <xsl:otherwise>
                                    <CoveringFromDate>
                                        <xsl:variable name="start-date" select="fcd:extract-full-start-date($extracted-date)"/>
                                        <xsl:value-of select="fc:catalogueDate-to-reverse-sequential-date-start($start-date)"/>
                                    </CoveringFromDate>
                                    <CoveringToDate>
                                        <xsl:variable name="end-date" select="fcd:extract-full-end-date($extracted-date)"/>
                                        <xsl:value-of select="fc:catalogueDate-to-reverse-sequential-date-last($end-date)"/>
                                    </CoveringToDate>
                                </xsl:otherwise>
                            </xsl:choose>

                        </xsl:when>

                        <xsl:when test="$cataloguing/dc:coverage">
                            <!-- WO_95, or surrogate model, also Welsh-->
                            <xsl:message
                                    select="$cataloguing/dc:coverage/tna:CoveringDates/tna:startDate"/>
                            <xsl:variable name="covering-start-date"
                                          select="fc:isoOrCatalogueDate-to-reverse-sequential-date-first($cataloguing/dc:coverage/tna:CoveringDates/tna:startDate)"/>
                            <xsl:variable name="end_date">
                                <xsl:choose>
                                    <xsl:when
                                            test="string(($cataloguing/dc:coverage/tna:CoveringDates/tna:endDate))">
                                        <xsl:value-of
                                                select="fc:isoOrCatalogueDate-to-reverse-sequential-date-last($cataloguing/dc:coverage/tna:CoveringDates/tna:endDate)"/>
                                    </xsl:when>
                                    <xsl:when test="$metadata//dc:modified">
                                        <xsl:value-of
                                                select="fc:dateTime-to-reverse-sequential-date($metadata//dc:modified)"
                                        />
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:value-of
                                                select="fc:catalogueDate-to-reverse-sequential-date-last($cataloguing/dc:coverage/tna:CoveringDates/tna:startDate)"
                                        />
                                    </xsl:otherwise>
                                </xsl:choose>

                            </xsl:variable>
                            <xsl:variable name="covering-end-date" select="$end_date"/>
                            <CoveringFromDate>
                                <xsl:value-of select="$covering-start-date"/>
                            </CoveringFromDate>
                            <CoveringToDate>
                                <xsl:value-of select="$covering-end-date"/>
                            </CoveringToDate>
                        </xsl:when>

                        <xsl:when test="$metadata//dc:modified and not($cataloguing/dc:coverage)">
                            <!-- RF_5, or born digital model-->
                            <xsl:variable name="covering-start-date"
                                          select="fc:dateTime-to-reverse-sequential-date($metadata//dc:modified)"/>
                            <xsl:variable name="covering-end-date"
                                          select="fc:dateTime-to-reverse-sequential-date($metadata//dc:modified)"/>
                            <CoveringFromDate>
                                <xsl:value-of select="$covering-start-date"/>
                            </CoveringFromDate>
                            <CoveringToDate>
                                <xsl:value-of select="$covering-end-date"/>
                            </CoveringToDate>
                        </xsl:when>

                        <xsl:otherwise>
                            <!--xsl:message terminate="yes" select="concat('Could not calculate Reference for DU: ', DeliverableUnitId)"/ -->
                        </xsl:otherwise>
                    </xsl:choose>



                    <LiveFlag>0</LiveFlag>
                    <!-- this is always 0 according to original XSLT -->

                    <Digitized>true</Digitized>
                    <!-- TODO - neeed to find a way to distinguish born digital records in new metadata format -->

                    <xsl:call-template name="replica-identities">
                        <xsl:with-param name="deliverable-unit-ref" select="DeliverableUnitRef"/>
                   </xsl:call-template>
            </xsl:when>
        </xsl:choose>
    </xsl:template>

</xsl:stylesheet>