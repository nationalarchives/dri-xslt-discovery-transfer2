<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
    xmlns:api="http://nationalarchives.gov.uk/dri/catalogue/api"
    xmlns:c="http://nationalarchives.gov.uk/dri/closure"
    xmlns:dc="http://purl.org/dc/terms/"
    xmlns:dce="http://purl.org/dc/elements/1.1/"
    xmlns:fc="http://xip-bia/functions/common"
    xmlns:sf="http://www.nationalarchives.gov.uk/pronom/SignatureFile"
    xmlns:tna="http://nationalarchives.gov.uk/metadata/tna#"
    xmlns:xip="http://www.tessella.com/XIP/v4"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
    xpath-default-namespace="http://www.tessella.com/XIP/v4"
    exclude-result-prefixes="api c dc dce fc sf tna  xip xs xsi xsl"
    version="2.0">
   
    <!--
        Contains the common templates used by XIP-to-BIA transformation
        -->
   


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
        <xsl:variable name ="docClosureStatus" select="$closure/c:documentClosureStatus" />
        <xsl:if test="$docClosureStatus eq 'CLOSED' ">
<!--        <xsl:if test="$docClosureStatus eq 'CLOSED'">-->
            <AccessRegulation>
                <RelatedToIA><xsl:value-of select="$deliverable-unit-ref"/></RelatedToIA>
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
        <xsl:param name="curated-title" required="no"/>
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