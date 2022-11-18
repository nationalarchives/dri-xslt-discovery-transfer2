<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:api="http://nationalarchives.gov.uk/dri/catalogue/api"
    xmlns:c="http://nationalarchives.gov.uk/dri/closure" xmlns:dc="http://purl.org/dc/terms/"
    xmlns:fc="http://xip-bia/functions/common"
    xmlns:fcd="http://xip-bia/functions/coverage-date"
    xmlns:sf="http://www.nationalarchives.gov.uk/pronom/SignatureFile"
    xmlns:tna="http://nationalarchives.gov.uk/metadata/tna#"
    xmlns:tnaxm="http://nationalarchives.gov.uk/metadata/"
    xmlns:xip="http://www.tessella.com/XIP/v4" xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
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

    <xsl:output indent="yes" encoding="UTF-8" omit-xml-declaration="no"/>
    <xsl:strip-space elements="BIA"/>

    <xsl:key name="deliv-unit-by-deliverableunitref" match="DeliverableUnit"
        use="DeliverableUnitRef"/>

    <xsl:include href="xip-to-bia-v4-b.xslt"/>

    <!-- stylesheet parameters -->
    <xsl:param name="parent-id" required="yes"/>
    <xsl:param name="droid-signature-file" required="yes"/>
    <!--<xsl:param name="parent-id">101aa1aa-11a1-411a-aaa1-aa1a11a1111a</xsl:param>-->
    <!--<xsl:param name="droid-signature-file">DROID_SignatureFile_V73.xml</xsl:param>-->
    
    <xsl:param name="record-opening-date">
        <xsl:if test="fc:isBornDigitalReference(xip:XIP/xip:DeliverableUnits/xip:DeliverableUnit[1]/xip:CatalogueReference)">
            <xsl:value-of select="current-date()"></xsl:value-of>
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

    <xsl:template match="XIP">
        <BIA>
           <xsl:apply-templates/>
        </BIA>
    </xsl:template>

    <xsl:template match="Collections">
        <!-- do nothing -->
    </xsl:template>

    <xsl:template match="Aggregations">
        <!-- do nothing -->
    </xsl:template>

    <xsl:template match="DeliverableUnits">
        <xsl:apply-templates/>
    </xsl:template>

    <xsl:template match="DeliverableUnit">
        <xsl:choose>
            <xsl:when test="Metadata/tnaxm:metadata">
                <xsl:call-template name="deliverable-unit">
                    <xsl:with-param name="parent-id" select="$parent-id"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="Metadata/tna:metadata">
                <xsl:variable name="metadata" select="Metadata/tna:metadata" as="node()"/>
                <xsl:variable name="cataloguing" select="Metadata/tna:metadata//tna:Cataloguing"
                    as="node()"/>
                <xsl:variable name="source-level-id" select="fc:get-source-level-id($cataloguing)"
                    as="xs:integer"/>
                <InformationAsset>
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
                        <Title><xsl:choose>
                            <xsl:when test="$metadata/c:closure/c:titleAlternate">
                                <xsl:value-of select="$metadata/c:closure/c:titleAlternate"/>
                            </xsl:when>
                           <xsl:when test="$cataloguing/tna:curatedTitle">
                                <xsl:value-of select="$cataloguing/tna:curatedTitle"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="$cataloguing/dc:title"/>
                            </xsl:otherwise>
                        </xsl:choose></Title>
                    </xsl:if>

                    <xsl:choose>
                        <xsl:when test="$cataloguing/tna:hearing_date and fc:isSlashDate($cataloguing/tna:hearing_date)" >
                            <CoveringDates>
                            <xsl:value-of select="fc:dateSlashToFormattedDate($cataloguing/tna:hearing_date)"/>
                            </CoveringDates>
                        </xsl:when>
                        <xsl:when test="$cataloguing/tna:curatedDate" >
                            <CoveringDates>
                                <xsl:choose>
                                    <xsl:when test="$cataloguing/tna:curatedDate castable as xs:dateTime">
                                        <xsl:value-of select= "fc:dateTime-to-pretty-reverse-sequential-date(xs:dateTime($cataloguing/tna:curatedDate))"/>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:value-of select="$cataloguing/tna:curatedDate"/>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </CoveringDates>
                        </xsl:when>
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
                                                <xsl:value-of select= "fc:dateTime-to-pretty-reverse-sequential-date(xs:dateTime($date))"/>
                                        </xsl:when>
                                        <xsl:when test="$date castable as xs:date">
                                            <xsl:value-of select= "fc:date-to-pretty-reverse-sequential-date(xs:date($date))"/>
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
                                    <xsl:variable name="date" select="$cataloguing/dc:coverage/tna:CoveringDates/tna:endDate"/>
                                    <xsl:choose>
                                        <xsl:when test="$date">
                                            <xsl:choose>
                                                <xsl:when test="$date castable as xs:dateTime">
                                                    <xsl:value-of select= "fc:dateTime-to-pretty-reverse-sequential-date(xs:dateTime($date))"/>
                                                </xsl:when>
                                                <xsl:when test="$date castable as xs:date">
                                                    <xsl:value-of select= "fc:date-to-pretty-reverse-sequential-date(xs:date($date))"/>
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
                                                    <xsl:value-of select= "fc:dateTime-to-pretty-reverse-sequential-date($metadata//dc:modified)"/>
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
                                        <xsl:value-of select="$start_date"/> - <xsl:value-of
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

                    <!-- Default: 1 (for a file) -->
                    <PhysicalDescriptionExtent>1</PhysicalDescriptionExtent>

                    <!-- Default: digital record (for a file) -->
                    <PhysicalDescriptionForm>digital record</PhysicalDescriptionForm>

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
                        <xsl:with-param name="closure" select="$metadata/c:closure"/>
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
                    


                    
                    <!-- SourceLevelId -->
                    <xsl:call-template name="ScopeContent">
                        <xsl:with-param name="metadata" select="$metadata"/>
                        <xsl:with-param name="cataloguing" select="$cataloguing"/>
                    </xsl:call-template>
                     <xsl:choose>
                        <xsl:when test="$cataloguing/tna:relatedMaterial">
                            <RelatedMaterials>
                                <RelatedMaterial>
                                    <Description>
                                        <xsl:value-of select="$cataloguing/tna:relatedMaterial"/>
                                    </Description>
                                </RelatedMaterial>
                            </RelatedMaterials>
                        </xsl:when>
                        <xsl:when test="$cataloguing/dc:relation">
                            <RelatedMaterials>
                                <RelatedMaterial>
                                    <Description>
                                        <xsl:value-of select="$cataloguing/dc:relation"/>
                                    </Description>
                                </RelatedMaterial>
                            </RelatedMaterials>
                        </xsl:when>
                    </xsl:choose>


                    <!-- Arrangement is here used for the working path, and it will be populated for all open born 
                        digital records - document closure status is OPEN and catalogue reference ends in Z -->

                    <xsl:variable name ="docClosureStatus" select="$metadata/c:closure/c:documentClosureStatus" />
                    <xsl:variable name ="catRef" select="CatalogueReference" />
                    <xsl:if test="ends-with($catRef, 'Z') or matches($catRef,'.*Z/\d')">
                        <Arrangement>This born digital record was arranged under the following file structure: </Arrangement>
                    </xsl:if>
                    
                    <xsl:if test="$cataloguing/tna:administrativeBackground">
                        <AdministrativeBackground>
                            <xsl:value-of select="$cataloguing/tna:administrativeBackground"/>
                        </AdministrativeBackground>
                    </xsl:if>

                    <xsl:if test="$cataloguing/tna:corporateBody">
                        <CorporateNames>
                            <CorporateName>
                                <Corporate_Body_Name_Text>
                                    <xsl:value-of select="$cataloguing/tna:corporateBody"/>
                                </Corporate_Body_Name_Text>
                            </CorporateName>
                         </CorporateNames>
                    </xsl:if>

                    <BatchId>
                        <xsl:value-of select="$cataloguing/tna:batchIdentifier"/>
                    </BatchId>

                     <xsl:choose>
                         
                         <xsl:when test="$cataloguing/tna:hearing_date and fc:isSlashDate($cataloguing/tna:hearing_date)" >
                             <xsl:variable name="formattedHearingDateTime" select="fc:dateSlashToFormattedDateTime($cataloguing/tna:hearing_date)"></xsl:variable>
                             <CoveringFromDate>
                                 <xsl:value-of select="fc:dateTime-to-reverse-sequential-date($formattedHearingDateTime)"/>
                             </CoveringFromDate>
                             <CoveringToDate>
                                 <xsl:value-of select="fc:dateTime-to-reverse-sequential-date($formattedHearingDateTime)"/>
                             </CoveringToDate> 
                             
                         </xsl:when>

                         <xsl:when test="$cataloguing/tna:curatedDate" >
                             <CoveringFromDate>
                                 <xsl:variable name="start-date" select="fcd:extract-full-start-date($cataloguing/tna:curatedDate)"/>
                                 <xsl:value-of select="fc:isoOrCatalogueDate-to-reverse-sequential-date-first($start-date)"/>
                             </CoveringFromDate>
                             <CoveringToDate>
                                 <xsl:variable name="end-date" select="fcd:extract-full-end-date($cataloguing/tna:curatedDate)"/>
                                 <xsl:value-of select="fc:isoOrCatalogueDate-to-reverse-sequential-date-last($end-date)"/>
                             </CoveringToDate>
                         </xsl:when>
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
                            <CoveringFromDate>
                                <xsl:variable name="start-date" select="fcd:extract-full-start-date($extracted-date)"/>
                                <xsl:value-of select="fc:catalogueDate-to-reverse-sequential-date-last($start-date)"/>
                            </CoveringFromDate>
                            <CoveringToDate>
                                <xsl:variable name="end-date" select="fcd:extract-full-end-date($extracted-date)"/>
                                <xsl:value-of select="fc:catalogueDate-to-reverse-sequential-date-last($end-date)"/>
                            </CoveringToDate>
                        </xsl:when>

                        <xsl:when test="$cataloguing/dc:coverage">
                            <!-- WO_95, or surrogate model, also Welsh-->
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

                </InformationAsset>

                <xsl:call-template name="create-access-regulation">
                    <xsl:with-param name="closure" select="$metadata/c:closure"/>
                    <xsl:with-param name="deliverable-unit-ref" select="DeliverableUnitRef"/>
                </xsl:call-template>


            </xsl:when>
        </xsl:choose>
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
    </xsl:template>

    <!-- suppress default with this template -->
    <xsl:template match="text()"/>

</xsl:stylesheet>
