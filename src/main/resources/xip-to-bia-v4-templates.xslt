<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
        xmlns:api="http://nationalarchives.gov.uk/dri/catalogue/api"
        xmlns:c="http://nationalarchives.gov.uk/dri/closure"
        xmlns:dc="http://purl.org/dc/terms/"
        xmlns:dce="http://purl.org/dc/elements/1.1/"
        xmlns:fc="http://xip-bia/functions/common"
        xmlns:hg="http://nationalarchives.gov.uk/dataset/homeguard/metadata/"
        xmlns:sf="http://www.nationalarchives.gov.uk/pronom/SignatureFile"
        xmlns:tna="http://nationalarchives.gov.uk/metadata/tna#"
        xmlns:tnac="http://nationalarchives.gov.uk/catalogue/2007/"
        xmlns:tnacg="http://nationalarchives.gov.uk/catalogue/generated/2014/"
        xmlns:tnaxm="http://nationalarchives.gov.uk/metadata/"
        xmlns:tnamp="http://nationalarchives.gov.uk/metadata/person/"
        xmlns:tnatrans="http://nationalarchives.gov.uk/dri/transcription"
        xmlns:tnams="http://nationalarchives.gov.uk/metadata/spatial/"
        xmlns:xip="http://www.tessella.com/XIP/v4"
        xmlns:xs="http://www.w3.org/2001/XMLSchema"
        xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
        xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
        xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
        xpath-default-namespace="http://www.tessella.com/XIP/v4"
        exclude-result-prefixes="api c dc dce fc hg sf tna tnac tnacg tnamp tnams tnaxm xip xs xsi xsl tnatrans"
        version="2.0">

    <!--
        Contains the common templates used by XIP-to-BIA transformation
        -->

    <xsl:include href="xip-to-bia-v4-functions.xslt"/>
    <xsl:include href="xip-to-bia-v4-transcription-scope-template.xslt"/>


    <xsl:template name="places">
        <xsl:param name="metadata" as="element(tnaxm:metadata)" required="yes"/>

        <xsl:variable name="person" select="$metadata/dc:subject/hg:person" as="element(hg:person)?"/> <!-- TODO this is too home-guard specific -->

        <Places>
            <xsl:choose>
                <xsl:when test="fc:is-piece($metadata)">
                    <Place>
                        <county_text><xsl:value-of select="$metadata/dc:spatial[@xsi:type='tnaxmdc:spatial']/tnams:postalAddress/tnams:county"/></county_text>
                    </Place>
                </xsl:when>
                <xsl:when test="fc:is-item($metadata)">
                    <xsl:if test="fc:is-open-description($metadata)">
                        <Place>
                            <county_text><xsl:value-of select="$metadata/dc:spatial[@xsi:type='tnaxmdc:spatial']/tnams:postalAddress/tnams:county"/></county_text>
                        </Place>
                        <xsl:if test="not(empty($person/tnams:address/tnams:addressString[string-length(.) gt 0]))">
                            <Place>
                                <Description><xsl:value-of select="$person/tnams:address/tnams:addressString"/></Description>
                            </Place>
                        </xsl:if>
                        <xsl:variable name="pob" select="fc:born-pob($person/tnamp:birth/tnams:address)"/>
                        <xsl:if test="not(empty($pob)) and string-length($pob) gt 0">
                            <Place>
                                <Description><xsl:value-of select="$pob"/></Description>
                            </Place>
                        </xsl:if>
                    </xsl:if>
                </xsl:when>
            </xsl:choose>
        </Places>
    </xsl:template>

    <xsl:template name="personal-names">
        <xsl:param name="metadata" as="element(tnaxm:metadata)" required="yes"/>

        <xsl:variable name="person" select="$metadata/dc:subject/hg:person" as="element(hg:person)?"/> <!-- TODO this is too home-guard specific -->

        <xsl:if test="not(empty($person))">
            <PersonalNames>
                <Person>
                    <Surname_Text><xsl:value-of select="$person/tnamp:name/tnamp:namePart[@type = 'familyName']"/></Surname_Text>
                    <Forename_Text><xsl:value-of select="$person/tnamp:name/tnamp:namePart[@type = 'given']"/></Forename_Text>
                    <xsl:if test="not(empty($person/tnamp:birth/tnamp:date)) and string-length($person/tnamp:birth/tnamp:date) != 0 and $person/tnamp:birth/tnamp:date castable as xs:date">
                        <Birth_Date><xsl:value-of select="$person/tnamp:birth/fc:date-to-reverse-sequential-date(tnamp:date)"/></Birth_Date>
                    </xsl:if>
                </Person>
            </PersonalNames>
        </xsl:if>
    </xsl:template>

    <xsl:template name="scope-content" exclude-result-prefixes="#all">
        <xsl:param name="source-level-id" as="xs:integer" required="yes"/>
        <xsl:param name="metadata" as="element(tnaxm:metadata)" required="yes"/>
        <xsl:param name="fallback-description" as="element(xip:Title)" required="yes"/>
        <ScopeContent>
            <xsl:if test="$source-level-id ne 4">
                <!--
                    Description MUST NOT be sent at Catalogue Level 4 for Born Digital Records
                    Change requested by Emma Bayne on 2014-04-09
                -->
                <Description><xsl:value-of select="fc:title($metadata, $fallback-description)"/></Description>
            </xsl:if>
        </ScopeContent>
    </xsl:template>


    <xsl:template name="hg-scope-content">
        <xsl:param name="metadata" as="element(tnaxm:metadata)" required="yes"/>

        <xsl:variable name="person" select="$metadata/dc:subject/hg:person" as="element(hg:person)?"/> <!-- TODO this is too home-guard specific -->
        <xsl:variable name="battalion" select="fc:get-battalion($metadata)"/>

        <ScopeContent>
            <xsl:choose>

                <xsl:when test="fc:is-piece($metadata)">
                    <xsl:choose>
                        <xsl:when test="empty($battalion) or string-length($battalion) eq 0">
                            <Organizations>
                                <string>Home Guard</string>
                            </Organizations>
                            <Description>Home Guard</Description>
                        </xsl:when>
                        <xsl:otherwise>
                            <Organizations>
                                <string><xsl:value-of select="concat('Home Guard, ', $battalion, ' Battalion')"/></string>
                            </Organizations>
                            <Description><xsl:value-of select="concat('Home Guard, ', $battalion, ' Battalion')"/></Description>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>

                <xsl:when test="fc:is-item($metadata)">
                    <xsl:if test="fc:is-open-description($metadata)">
                        <PersonName>
                            <string><xsl:value-of select="$person/tnamp:name/concat(tnamp:namePart[@type = 'given'], ' ', tnamp:namePart[@type = 'familyName'])"/></string>
                        </PersonName>
                        <PlaceName>
                            <string><xsl:value-of select="$metadata/dc:spatial[@xsi:type='tnaxmdc:spatial']/tnams:postalAddress/tnams:county"/></string>
                        </PlaceName>
                        <Organizations>
                            <string><xsl:value-of select="concat('Home Guard, ', $battalion, ' Battalion')"/></string>
                        </Organizations>
                        <Description><xsl:value-of select="$person/tnamp:name/concat(tnamp:namePart[@type = 'given'], ' ', tnamp:namePart[@type = 'familyName'], fc:born($person/tnamp:birth), ' - ', $metadata/dc:spatial[@xsi:type='tnaxmdc:spatial']/tnams:postalAddress/tnams:county, ' Home Guard, ', $battalion, ' Battalion')"/></Description>
                    </xsl:if>
                </xsl:when>
            </xsl:choose>
        </ScopeContent>
    </xsl:template>

    <xsl:template name="source-level-id">
        <xsl:param name="source-level-id"/>
        <SourceLevelId>
            <xsl:choose>
                <xsl:when test="not(empty($source-level-id))">
                    <xsl:value-of select="$source-level-id"/>
                </xsl:when>
                <xsl:otherwise>
                    <!-- xsl:message terminate="yes" select="concat('Could not calculate SourceLevelId for DU: ', DeliverableUnitId)"/ -->
                </xsl:otherwise>
            </xsl:choose>
        </SourceLevelId>
    </xsl:template>
    <xsl:template name="parent-iaid">
        <xsl:param name="deliverable-unit" as="element(DeliverableUnit)" required="yes"/>
        <xsl:param name="parent-id" as="xs:string" required="yes"/>
        <xsl:param name="parent" as="node()*"/>
        <ParentIAID>
             <xsl:choose>
                <xsl:when test="$parent">
                    <xsl:choose>
                        <xsl:when test="$parent/Metadata/tna:metadata/rdf:RDF/tna:DigitalFolder/tna:cataloguing/tna:Cataloguing/tna:iaid">
                            <xsl:value-of select="$parent/Metadata/tna:metadata/rdf:RDF/tna:DigitalFolder/tna:cataloguing/tna:Cataloguing/tna:iaid"/>
                        </xsl:when>
                        <xsl:otherwise>
                             <xsl:value-of select="$deliverable-unit/ParentRef"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$parent-id"/>
                </xsl:otherwise>
            </xsl:choose>
        </ParentIAID>
    </xsl:template>

   <xsl:template name="held-by">
        <xsl:param name="held-by"/>
        <HeldBy>
            <HeldBy>
                <Corporate_Body_Name_Text><xsl:value-of select="$held-by"/></Corporate_Body_Name_Text>
            </HeldBy>
        </HeldBy>
    </xsl:template>

    <xsl:template name="closure">
        <xsl:param name="closure" as="element(c:closure)" required="yes"/>
        <xsl:param name="record-opening-date" required="no"/>
        <ClosureType>
            <xsl:value-of select="$closure/c:closureType"/>
        </ClosureType>
        <ClosureCode>
            <xsl:value-of select="$closure/c:closureCode"/>
        </ClosureCode>
        <!-- for open files, the opening date should be the transfer date-->


            <xsl:choose>
                <xsl:when test="$closure/c:closureType/text()[.='A'] and $closure/c:closureCode/text()[.='0']">
                    <RecordOpeningDate>
                    <xsl:choose>
                        <xsl:when test="($record-opening-date castable as xs:date)">
                            <xsl:value-of select="fc:date-to-reverse-sequential-date($record-opening-date)"/>
                        </xsl:when>
                        <xsl:when test="($closure/c:openingDate castable as xs:dateTime)">
                            <xsl:value-of select="fc:dateTime-to-reverse-sequential-date($closure/c:openingDate)"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <!-- if the date is not in the map, put the current date. -->
                            <xsl:value-of select="fc:dateTime-to-reverse-sequential-date(current-dateTime())"/>
                        </xsl:otherwise>
                    </xsl:choose>
                    </RecordOpeningDate>
                </xsl:when>
                <!-- FIX THIS UP when it has been decided what to send for retained-->
                <xsl:when test="$closure/c:closureType/text()[.='R'] ">
<!--                    <xsl:message>No opening date for Closure R</xsl:message>-->
                </xsl:when>
                <xsl:when test="$closure/c:closureType/text()[.='S'] ">
<!--                    <xsl:message>No opening date for Closure S</xsl:message>-->
                </xsl:when>
                <xsl:when test="$closure/c:closureType/text()[.='T'] ">
<!--                    <xsl:message>No opening date for Closure T</xsl:message>-->
                </xsl:when>
                <xsl:otherwise>
                    <xsl:if test="$closure/c:openingDate ne ''">
                        <RecordOpeningDate>
                            <xsl:value-of select="fc:dateTime-to-reverse-sequential-date($closure/c:openingDate)"/>
                        </RecordOpeningDate>
                    </xsl:if>
                </xsl:otherwise>
            </xsl:choose>

        <ClosureStatus>
            <xsl:value-of
                    select="fc:to-discovery-closureStatus($closure/c:documentClosureStatus, $closure/c:descriptionClosureStatus, $closure/c:titleClosureStatus)"/>
        </ClosureStatus>
    </xsl:template>

    <xsl:template name="create-catalogue-reference">
        <xsl:param name="catalogue-reference"/>
        <Reference>
            <xsl:value-of select="replace($catalogue-reference, concat('(^.*?)', '/'), concat('$1',' '))"/>
        </Reference>
    </xsl:template>

    <xsl:template name="create-access-regulation">
        <xsl:param name="closure" as="node()" required="yes"/>
        <xsl:param name="deliverable-unit-ref" required="yes"/>
        <xsl:variable name="docClosureStatus" select="$closure/c:documentClosureStatus"/>
        <!-- IS THIS CORRECT -->
        <xsl:if test="$docClosureStatus eq 'CLOSED' ">
            <!--        <xsl:if test="$docClosureStatus eq 'CLOSED'">-->
            <AccessRegulation>
                <RelatedToIA>
                    <xsl:value-of select="$deliverable-unit-ref"/>
                </RelatedToIA>
                <ClosureCriterions>
                    <xsl:choose>
                        <xsl:when test="$closure/c:retentionJustification/text() != ''">
                            <ClosureCriterion>
                                <ExemptionCodeId>
                                    <xsl:value-of select="$closure/c:retentionJustification"/>
                                </ExemptionCodeId>
                            </ClosureCriterion>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:for-each select="$closure/c:exemptionCode">
                                <ClosureCriterion>
                                    <ExemptionCodeId>
                                        <xsl:value-of select="."/>
                                    </ExemptionCodeId>
                                </ClosureCriterion>
                            </xsl:for-each>
                        </xsl:otherwise>
                    </xsl:choose>
                </ClosureCriterions>
                <SignedDate><xsl:value-of select="$closure/c:exemptionAsserted"/></SignedDate>
                <ReviewDate/>
                <ReconsiderDueInDate><xsl:value-of select="$closure/c:retentionReconsiderDate"/></ReconsiderDueInDate>
                <Explanation/>
                <ProcatTitle>Exemption</ProcatTitle>
            </AccessRegulation>
        </xsl:if>
    </xsl:template>

    <!-- TODO - this needs to change so that it is only put out if there is actually going to be a replica -->
    <xsl:template name="replica-identities">
        <xsl:param name="deliverable-unit-ref"/>
        <xsl:variable name="manifestation" select="ancestor::XIP/DeliverableUnits/Manifestation[DeliverableUnitRef = $deliverable-unit-ref]"/>

        <xsl:variable name="digital-files" select="key('file-by-fileref', $manifestation/ManifestationFile/FileRef)[Directory = 'false']"/>

        <xsl:if test="not(empty($digital-files))">
            <ReplicaIdentities>
                <ReplicaIdentity>
                    <ReplicaId>
                        <xsl:value-of select="$manifestation/ManifestationRef"/>
                    </ReplicaId>
                </ReplicaIdentity>
            </ReplicaIdentities>
        </xsl:if>
    </xsl:template>

    <xsl:template name="manifestation">
        <xsl:param name="manifestation" as="element(Manifestation)" required="yes"/>
        <xsl:param name="droid-signature-file" as="xs:string" required="yes"/>
        <xsl:param name="directories" as="node()" required="yes"/>
        <xsl:param name="record-opening-date" required="no"/>
        <xsl:variable name="digital-files" select="key('file-by-fileref', $manifestation/ManifestationFile/FileRef)[Directory = 'false']"/>
        <xsl:variable name="du" select="key('deliv-unit-by-deliverableunitref',$manifestation/DeliverableUnitRef)"/>
        <xsl:variable name="iaid">
            <xsl:choose>
                <xsl:when test="$du/Metadata/tna:metadata/rdf:RDF/tna:DigitalFolder/tna:cataloguing/tna:Cataloguing/tna:iaid  ne ''">
                    <xsl:value-of select="$du/Metadata/tna:metadata/rdf:RDF/tna:DigitalFolder/tna:cataloguing/tna:Cataloguing/tna:iaid"/>
                </xsl:when>
                <xsl:when test="$du/Metadata/tna:metadata/rdf:RDF/tna:BornDigitalRecord/tna:cataloguing/tna:Cataloguing/tna:iaid  ne ''">
                    <xsl:value-of select="$du/Metadata/tna:metadata/rdf:RDF/tna:BornDigitalRecord/tna:cataloguing/tna:Cataloguing/tna:iaid"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$manifestation/DeliverableUnitRef"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="curatedTitle">
            <xsl:if test="$du/Metadata/tna:metadata/rdf:RDF/tna:BornDigitalRecord/tna:cataloguing/tna:Cataloguing/tna:curatedTitle  ne ''">
                <xsl:value-of select="$du/Metadata/tna:metadata/rdf:RDF/tna:BornDigitalRecord/tna:cataloguing/tna:Cataloguing/tna:curatedTitle"/>
            </xsl:if>
        </xsl:variable>
        <xsl:if test="not(empty($digital-files))">
            <Replica>
                <Id><xsl:value-of select="$manifestation/ManifestationRef"/></Id>
                <RelatedToIA><xsl:value-of select="$iaid"/></RelatedToIA>
                <Folios>
                    <Folio>
                        <xsl:variable name="this-DU" select="key('deliv-unit-by-deliverableunitref', $manifestation/DeliverableUnitRef)" as="element()"/>
                        <xsl:variable name="metadata" select="$this-DU/Metadata" as="element(Metadata)"/>
                        <FolioId><xsl:value-of select="$iaid"/></FolioId>
                        <DigitalFiles>
                            <xsl:for-each select="$digital-files">
                                <xsl:sort select="FileName"/>
                                <!--<xsl:variable name ="docClosureStatus" select="./Metadata//c:closure/c:documentClosureStatus" />-->
                                <!--<xsl:if test="$docClosureStatus eq 'OPEN'">-->
                                    <xsl:call-template name="digital-file">
                                        <xsl:with-param name="digital-file" select="."/>
                                        <xsl:with-param name="digital-file-count" select="count($digital-files)"/>
                                        <xsl:with-param name="position" select="position()"/>
                                        <xsl:with-param name="metadata" select="$metadata"/>
                                        <xsl:with-param name="droid-signature-file" select="$droid-signature-file"/>
                                        <xsl:with-param name="directories" select="$directories"/>
                                        <xsl:with-param name="record-opening-date" select="$record-opening-date"/>
                                        <xsl:with-param name="curated-title" select="$curatedTitle"/>
                                    </xsl:call-template>
                                <!--</xsl:if>-->
                            </xsl:for-each>
                        </DigitalFiles>
                        <xsl:call-template name="closure">
                            <xsl:with-param name="closure" select="$metadata//c:closure"/>
                            <xsl:with-param name="record-opening-date" select="$record-opening-date"/>
                        </xsl:call-template>
                    </Folio>
                </Folios>
            </Replica>
        </xsl:if>
    </xsl:template>

    <xsl:template name="digital-file">
        <xsl:param name="digital-file" required="yes"/>
        <xsl:param name="digital-file-count" as="xs:integer" required="yes"/>
        <xsl:param name="position" as="xs:integer" required="yes"/>
        <xsl:param name="metadata" as="element(Metadata)" required="yes"/>
        <xsl:param name="droid-signature-file" as="xs:string" required="yes"/>
        <xsl:param name="directories" as="node()" required="yes"/>
        <xsl:param name="record-opening-date"  required="no"/>
        <xsl:param name="curated-title"  required="no"/>
        <xsl:variable name="puid" as="xs:string">
            <xsl:value-of select="FormatInfo/FormatPUID/text()"/>
        </xsl:variable>
        <DigitalFile>
            <DigitalFileName>
                <xsl:choose>
                    <xsl:when test="$curated-title!=''">
                        <xsl:attribute name="originalName" select="FileName"/>
                        <xsl:value-of select="$curated-title"></xsl:value-of>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="FileName"/>
                    </xsl:otherwise>
                </xsl:choose>
            </DigitalFileName>
            <DigitalFileRef>
                <xsl:choose>
                    <xsl:when test="$digital-file/Metadata/tna:metadata/rdf:RDF/tna:DigitalRecord/tna:digitalFile/tna:DigitalFile/tna:discoveryFileId">
                        <xsl:value-of select="$digital-file/Metadata/tna:metadata/rdf:RDF/tna:DigitalRecord/tna:digitalFile/tna:DigitalFile/tna:discoveryFileId"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="FileRef"/>
                    </xsl:otherwise>
                </xsl:choose>
             </DigitalFileRef>
            <DigitalFilePartNumber>
                <xsl:value-of select="$position"/></DigitalFilePartNumber>
            <DigitalFileSize><xsl:value-of select="number(FileSize) idiv 1024"/></DigitalFileSize> <!-- need in KB e.g. =866657/1024 -->
            <DigitalFileNumberOfPages><xsl:value-of select="$digital-file-count"/></DigitalFileNumberOfPages> <!-- this must be a count of the number of .jpeg images in the same cluster -->
            <DigitalFileFormat><xsl:value-of select="doc($droid-signature-file)/sf:FFSignatureFile/sf:FileFormatCollection/sf:FileFormat[@PUID eq $puid]/@MIMEType"/></DigitalFileFormat>
            <DigitalFilePUID><xsl:value-of select="$puid"/></DigitalFilePUID>
            <DigitalFileDirectory>
               <xsl:variable name="working-path" select="WorkingPath/text()"/>
                <xsl:variable name="folders" as="node()*">
                <xsl:attribute name="completePath" select="$working-path"/>
                    <xsl:call-template name="extract-path" >
                        <xsl:with-param name="current-path" select="$working-path"/>
                        <xsl:with-param name="directories" select="$directories"/>
                    </xsl:call-template>
                </xsl:variable>
                <xsl:sequence select="$folders"/>
            </DigitalFileDirectory>
            <xsl:call-template name="closure">
                <xsl:with-param name="closure" select="$metadata//c:closure"/>
                <xsl:with-param name="record-opening-date" select="$record-opening-date"/>
            </xsl:call-template>
        </DigitalFile>
    </xsl:template>

    <xsl:template name="extract-path" as="node()*">
        <xsl:param name="current-path" as="xs:string"/>
        <xsl:param name="directories" as="node()" required="yes"/>
        <xsl:variable name="directory" select="$directories/api:Directories/api:Directory[api:Label eq $current-path]"/>
        <xsl:variable name="short-path" select="fc:substring-after-last($current-path,'/')" />

        <Folder>
            <Label>
                <xsl:choose>
                    <xsl:when test="$directory/api:AlternateLabel != ''">
                        <xsl:value-of select="$directory/api:AlternateLabel"/>
                    </xsl:when>
                    <xsl:when test="$directory/api:CuratedLabel != ''">
                        <xsl:value-of select="$directory/api:CuratedLabel"/>
                    </xsl:when>
                     <xsl:otherwise>
                         <xsl:value-of select="$short-path"/>
                    </xsl:otherwise>
                </xsl:choose>
            </Label>
            <ID><xsl:value-of select="$directory/api:ID"/></ID>
            <xsl:if test="exists($directory/api:ParentID)">
                <ParentID><xsl:value-of select="$directory/api:ParentID"/></ParentID>
            </xsl:if>
        </Folder>
        <xsl:variable name="short-path">
            <xsl:value-of select="fc:substring-after-last($current-path,'/')" />
        </xsl:variable>
        <xsl:variable name="parent-path">
            <xsl:value-of select="fc:substring-before-last($current-path,'/')" />
        </xsl:variable>
        <xsl:if test="$parent-path != ''">
            <xsl:call-template name="extract-path">
                <xsl:with-param name="current-path" select="$parent-path"/>
                <xsl:with-param name="directories" select="$directories"/>
            </xsl:call-template>
        </xsl:if>
    </xsl:template>

    <xsl:template name="ScopeContent">
        <xsl:param name="metadata" as="node()"/>
        <xsl:param name="cataloguing" as="node()"/>
    <ScopeContent>
        <Description>
            <xsl:choose>
                <xsl:when test="$metadata/rdf:RDF/tna:DigitalFolder/tna:transcription/tnatrans:Transcription">
                    <xsl:call-template name="description-from-transcription">
                        <xsl:with-param name="transcription" select="$metadata/rdf:RDF/tna:DigitalFolder/tna:transcription/tnatrans:Transcription"/>
                        <xsl:with-param name="description" select="$metadata/rdf:RDF/tna:DigitalFolder/tna:cataloguing/tna:Cataloguing/dc:description/text()"/>
                    </xsl:call-template>
                </xsl:when>
                <xsl:when test="$metadata/c:closure/c:descriptionClosureStatus/text() = 'CLOSED'">
                    <xsl:if test="not($metadata/c:closure/c:descriptionAlternate)">
                        <!--                                        <xsl:message terminate="yes" select="concat('Could not find description alternate for: ', $metadata)"/>-->
                        Alternate Description for item missing! Item: <xsl:value-of select="$metadata"/>
                    </xsl:if>
                    <xsl:value-of select="$metadata/c:closure/c:descriptionAlternate"/>
                </xsl:when>
                <xsl:when test="$cataloguing/tna:itemDescription">
                    <xsl:value-of select="$cataloguing/tna:itemDescription"/>
                </xsl:when>
                <xsl:when test="$cataloguing/tna:session">&lt;p&gt;Session: <xsl:value-of select= "$cataloguing/tna:session"/>&lt;lb/&gt;
                    <xsl:if test="$cataloguing/tna:session_date">
                        <xsl:text>Session date: </xsl:text><xsl:variable name="session_date" select="fc:cataloguedFormattedDate($cataloguing/tna:session_date)"/>
                        <xsl:value-of select="$session_date"/>&lt;/p&gt;
                    </xsl:if>

                    <xsl:if test="$cataloguing/tna:hearing_date">
                         <xsl:variable name="hearing_date" select="fc:cataloguedFormattedDate($cataloguing/tna:hearing_date)"/>
                        <xsl:text>Hearing date: </xsl:text><xsl:value-of select="$hearing_date"/>&lt;/p&gt;
                        <xsl:text>&lt;p&gt;The transcript is held within the &lt;extref href=&quot;</xsl:text>
                        <xsl:value-of select = "$cataloguing/tna:webArchiveUrl"/>
                        <xsl:text>&quot;&gt; archived inquiry webpage &lt;/extref&gt; &lt;/p&gt;</xsl:text>
                    </xsl:if>

                    <xsl:if test="$cataloguing/tna:witness_list_1">
                        &lt;p&gt; Witness(es):&lt;lb/&gt;
                    </xsl:if>

                    <xsl:call-template name="selects">
                        <xsl:with-param name="i">1</xsl:with-param>
                        <xsl:with-param name="count">5</xsl:with-param>
                        <xsl:with-param name="cataloguing" select="$cataloguing"/>
                    </xsl:call-template>

                    <xsl:if test="$cataloguing/tna:witness_list_1">
                        &lt;/p&gt;
                    </xsl:if>

                </xsl:when>


                <xsl:when test="$cataloguing/dc:description">
                     <xsl:value-of select="$cataloguing/dc:description"/>
                     <xsl:if test="$cataloguing/tna:internalGovernmentDepartment">&lt;lb/&gt;
                          Department: <xsl:value-of select="$cataloguing/tna:internalGovernmentDepartment"/>
                      </xsl:if>
                    <xsl:if test="$cataloguing/tna:category">&lt;lb/&gt;
                          Category: <xsl:value-of select="$cataloguing/tna:category"/>
                    </xsl:if>
                </xsl:when>
                <!--TODO read param and do it once for all langs-->
                <xsl:when test="$cataloguing/dc:title[@xml:lang='English']"
                    >&lt;scopecontent&gt;<xsl:if
                        test="$cataloguing/dc:title[@xml:lang='English']">&lt;language name=&quot;English&quot;&gt; &lt;filename&gt;<xsl:value-of select="$cataloguing/dc:title[@xml:lang='English']"/>&lt;/filename&gt;&lt;/language&gt; </xsl:if>
                    <xsl:if test="$cataloguing/dc:title[@xml:lang='Welsh']">&lt;language name=&quot;Welsh&quot;&gt;&lt;filename&gt;<xsl:value-of select="$cataloguing/dc:title[@xml:lang='Welsh']"/>&lt;/filename&gt;&lt;/language&gt; </xsl:if> &lt;/scopecontent&gt;</xsl:when>
<!--                <xsl:otherwise>
                    Description for item missing! Item: <xsl:value-of select="ScopeAndContent"/>
                </xsl:otherwise>-->
            </xsl:choose></Description>
    </ScopeContent>
    </xsl:template>


    <xsl:template name="selects">
        <xsl:param name="i" />
        <xsl:param name="count" />
        <xsl:param name="cataloguing" as="node()"/>

        <xsl:if test="$i &lt;= $count">
            <!--for uksc-->
            <xsl:call-template name="select_case_details" >
                <xsl:with-param name="cataloguing" select="$cataloguing"/>
                <xsl:with-param name="i" select="$i"/>
            </xsl:call-template>

            <!--for chilcot -->
            <xsl:call-template name="select_witness_details" >
                <xsl:with-param name="cataloguing" select="$cataloguing"/>
                <xsl:with-param name="i" select="$i"/>
            </xsl:call-template>
        </xsl:if>

        <!--begin_: RepeatTheLoopUntilFinished-->
        <xsl:if test="$i &lt;= $count">
            <xsl:call-template name="selects">
                <xsl:with-param name="i">
                    <xsl:value-of select="$i + 1"/>
                </xsl:with-param>
                <xsl:with-param name="cataloguing" select="$cataloguing"/>
                <xsl:with-param name="count">
                    <xsl:value-of select="$count"/>
                </xsl:with-param>
            </xsl:call-template>
        </xsl:if>

    </xsl:template>

    <xsl:template name="select_case_details">
        <xsl:param name="i"/>
        <xsl:param name="cataloguing" as="node()"/>
        <xsl:variable name="case_id" select = "concat('case_id_', $i)"></xsl:variable>
        <xsl:variable name="case_name" select = "concat('case_name_', $i)"></xsl:variable>
        <xsl:variable name="case_summary" select = "concat('case_summary_', $i)"></xsl:variable>

        <xsl:variable name="case_summary_judgment" select = "concat('case_summary_', $i, '_judgment')"></xsl:variable>
        <xsl:variable name="case_summary_reasons_for_judgment" select = "concat('case_summary_', $i, '_reasons_for_judgment')"></xsl:variable>

        <xsl:variable name="hearing_start_date_i" select = "concat('hearing_start_date_', $i)"></xsl:variable>
        <xsl:variable name="hearing_end_date_i" select = "concat('hearing_end_date_', $i)"></xsl:variable>
        <xsl:if test="$cataloguing/*[local-name() = $case_id] and string($cataloguing/*[local-name() = $case_id])">
        &lt;p&gt;CASE ID: <xsl:value-of select="$cataloguing/*[local-name() = $case_id]"/>&lt;lb/&gt;
        Case name: <xsl:value-of select="$cataloguing/*[local-name() = /$case_name]"/>&lt;lb/&gt;
        Case summary: <xsl:value-of select="$cataloguing/*[local-name() = /$case_summary]"/>&lt;lb/&gt;

        <xsl:value-of select="$cataloguing/*[local-name() = /$case_summary_judgment]"/>&lt;lb/&gt;
        <xsl:value-of select="$cataloguing/*[local-name() = /$case_summary_reasons_for_judgment]"/>&lt;lb/&gt;

        <xsl:variable name="hearing_start_date">
                <xsl:variable name="date"
                    select="$cataloguing/*[local-name() = /$hearing_start_date_i]"/>
                <xsl:choose>
                    <xsl:when test="$date castable as xs:date">
                        Hearing start date:  <xsl:value-of select= "fc:date-to-pretty-reverse-sequential-date(xs:date($date))"/> &lt;lb/&gt;
                    </xsl:when>
                    <xsl:when test="$date != '' and fc:isSlashDate($date)">
                        Hearing start date: <xsl:value-of select="fc:dateSlashToFormattedDate($date)"/> &lt;lb/&gt;
                    </xsl:when>
                    <xsl:otherwise/>
                </xsl:choose>
            </xsl:variable>

            <xsl:value-of select="$hearing_start_date"/>
            <xsl:variable name="hearing_end_date">
                <xsl:variable name="date"
                    select="$cataloguing/*[local-name() = /$hearing_end_date_i]"/>
                <xsl:choose>
                    <xsl:when test="$date castable as xs:date">
                        Hearing end date: <xsl:value-of select= "fc:date-to-pretty-reverse-sequential-date(xs:date($date))"/>
                    </xsl:when>
                    <xsl:when test="$date != '' and fc:isSlashDate($date)">
                        Hearing end date: <xsl:value-of select="fc:dateSlashToFormattedDate($date)"/>
                    </xsl:when>
                    <xsl:otherwise/>

                </xsl:choose>
            </xsl:variable>
            <xsl:value-of select="$hearing_end_date"/>&lt;/p&gt;
        </xsl:if>
    </xsl:template>

    <xsl:template name="select_witness_details">
        <xsl:param name="i"/>
        <xsl:param name="cataloguing" as="node()"/>
        <xsl:variable name="witness_list" select = "concat('witness_list_', $i)"></xsl:variable>
        <xsl:variable name="subject_role" select = "concat('subject_role_', $i)"></xsl:variable>
        <xsl:if test="$cataloguing/*[local-name() = $witness_list] and string($cataloguing/*[local-name() = $witness_list])">
            <xsl:value-of select="$cataloguing/*[local-name() = $witness_list]"/><xsl:text>&lt;lb/&gt;</xsl:text>
            <xsl:text>Subject/Role: </xsl:text><xsl:value-of select="$cataloguing/*[local-name() = $subject_role]"/><xsl:text>&lt;lb/&gt;</xsl:text>
        </xsl:if>
    </xsl:template>


    <xsl:template name="restrictions" match="dc:rights">
        <xsl:param name="cataloguing" as="node()"/>
        <xsl:if test="$cataloguing/dc:rights">
            <xsl:for-each select="$cataloguing/dc:rights">
                <xsl:value-of select="replace(substring-after(./@rdf:resource,'http://datagov.nationalarchives.gov.uk/resource/'), '_' , ' ')"/>
                <xsl:if test="position() != last()">
                    <xsl:text>, </xsl:text>
                </xsl:if>
            </xsl:for-each>
        </xsl:if>
    </xsl:template>


</xsl:stylesheet>