<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
    xmlns:c="http://nationalarchives.gov.uk/dri/closure"
    xmlns:dc="http://purl.org/dc/terms/"
    xmlns:dce="http://purl.org/dc/elements/1.1/"
    xmlns:f="http://local/functions"
    xmlns:fbdx="http://xip-bia/functions/born-digital"
    xmlns:fc="http://xip-bia/functions/common"
    xmlns:fdx="http://xip-bia/functions/digitized"
    xmlns:l="http://local/names"
    xmlns:sf="http://www.nationalarchives.gov.uk/pronom/SignatureFile"
    xmlns:tnaxm="http://nationalarchives.gov.uk/metadata/"
    xmlns:xip="http://www.tessella.com/XIP/v4"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    exclude-result-prefixes="c dc dce f fc fbdx fdx l sf tnaxm xip xs xsi xsl">

    <!--
        The Catalogue References in LEV_2 and LEV_3
        accidentally used http://purl.org/dc/elements/1.1/#identifier
        and not http://purl.org/dc/terms/#identifier
    -->

    <xsl:key name="deliv-unit-by-deliverableunitref" match="xip:DeliverableUnit"
        use="xip:DeliverableUnitRef"/>
    <xsl:key name="file-by-fileref" match="xip:File" use="xip:FileRef"/>

    <!-- common functions -->
    <xsl:include href="xip-to-bia-common.xslt"/>

    <!-- Digitized Accession XIP to BIA transformation -->
    <xsl:include href="digitized-xip-to-bia.xslt"/>

    <!-- Digitized Accession XIP to BIA transformation -->
    <xsl:include href="born-digital-xip-to-bia.xslt"/>

    <xsl:output indent="yes" encoding="UTF-8" omit-xml-declaration="no"/>

    <!-- the IAID of the IA in Discovery to which our top-level DUs should be attached -->
    <xsl:param name="parent-id" required="yes"/>
    <xsl:param name="droid-signature-file" required="yes"/>

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

    <!--<xsl:template match="@* | node()">-->
    <!--<xsl:copy>-->
    <!--<xsl:apply-templates select="@*|node()"/>-->
    <!--</xsl:copy>-->
    <!--</xsl:template>-->

    <xsl:template match="xip:XIP">

        <BIA>
            <xsl:message> Directories param <xsl:value-of select="$directoriesDoc"/>
            </xsl:message>
            <xsl:apply-templates/>
        </BIA>
    </xsl:template>

    <xsl:template match="xip:Collections">
        <!-- do nothing -->
    </xsl:template>

    <xsl:template match="xip:Aggregations">
        <!-- do nothing -->
    </xsl:template>

    <xsl:template match="xip:DeliverableUnits">
        <xsl:apply-templates/>
    </xsl:template>

    <!--
        Requested by Emma Bayne on 2014-03-21
        - First Folder is at level 4
        - Everything else is 6+
    -->
    <xsl:function name="f:hack-source-level-id" as="xs:integer">
        <xsl:param name="source-level-id" as="xs:integer"/>
        <xsl:choose>
            <xsl:when test="$source-level-id eq 2">3</xsl:when>
            <xsl:when test="$source-level-id eq 3">4</xsl:when>
            <xsl:when test="$source-level-id eq 4">6</xsl:when>
            <xsl:otherwise> 6 <!-- Removed after discussion with Aleks, 1.09.2014, discovery does not use the source level id from DRI. The classification above is only for paper collections -->
                <!-- <xsl:message terminate="yes" select="concat('Cannot hack source-level-id: ', $source-level-id)"/> -->
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>

    <xsl:template match="xip:DeliverableUnit">

        <xsl:variable name="metadata" select="xip:Metadata/tnaxm:metadata"/>

        <!-- xsl:variable name="deliverable-unit-ref" select="xip:DeliverableUnitRef"/ -->
        <xsl:variable name="source-level-id" as="xs:integer?">
            <xsl:choose>
                <xsl:when test="fbdx:has-born-digital-identifier($metadata/(dc:identifier|dce:identifier))">
                    <!-- we start at depth=1 as we need to attach to a top-level series IA in Discovery (and that series IA is at level 1) -->
                    <xsl:value-of select="f:hack-source-level-id(fbdx:depth(., 1))"/>
                </xsl:when>
                <xsl:when test="fdx:has-digitized-identifier($metadata/(dc:identifier|dce:identifier))">
                    <xsl:value-of select="fdx:source-level-id($metadata/(dc:identifier|dce:identifier)[@xsi:type = ('tnacdc:pieceIdentifier', 'tnacdc:itemIdentifier')])"/>
                </xsl:when>
            </xsl:choose>
        </xsl:variable>

        <InformationAsset>
            <IAID>
                <xsl:value-of select="xip:DeliverableUnitRef"/>
            </IAID>

            <SourceLevelId>
                <xsl:choose>
                    <xsl:when test="not(empty($source-level-id))">
                        <xsl:value-of select="$source-level-id"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:message terminate="yes" select="concat('Could not calculate SourceLevelId for DU: ', xip:DeliverableUnitId)"/>
                    </xsl:otherwise>
                </xsl:choose>
            </SourceLevelId>

            <xsl:call-template name="parent-iaid">
                <xsl:with-param name="deliverable-unit" select="."/>
            </xsl:call-template>

            <xsl:call-template name="create-catalogue-reference">
                <xsl:with-param name="catalogue-reference" select="xip:CatalogueReference"/>
            </xsl:call-template>

            <CatalogueId>0</CatalogueId>
            <!-- this is always 0 according to original XSLT -->

            <xsl:call-template name="legal-status">
                <xsl:with-param name="metadata" select="$metadata"/>
            </xsl:call-template>


            <xsl:choose>
                <xsl:when test="fbdx:has-born-digital-identifier($metadata/(dc:identifier|dce:identifier))">

                    <!--
                        Title MUST NOT be sent at Catalogue Level 6 for Born Digital Records
                        Change requested by Emma Bayne on 2014-04-09
                    -->
                    <xsl:if test="$source-level-id ne 6">
                        <Title>
                            <xsl:value-of select="fbdx:title($metadata, xip:Title)"/>
                        </Title>
                    </xsl:if>

                </xsl:when>
                <xsl:when test="fdx:has-digitized-identifier($metadata/(dc:identifier|dce:identifier))">
                    <Title>
                        <xsl:value-of select="fdx:title($metadata, xip:CatalogueReference)"/>
                    </Title>
                </xsl:when>
                <xsl:otherwise>
                    <!-- xsl:message terminate="yes" select="concat('Could not calculate Title for DU: ', xip:DeliverableUnitId)"/ -->
                </xsl:otherwise>
            </xsl:choose>


            <xsl:call-template name="creator-name">
                <xsl:with-param name="metadata" select="$metadata"/>
            </xsl:call-template>

            <xsl:if test="fbdx:has-born-digital-identifier($metadata/(dc:identifier|dce:identifier))">
                <CoveringDates>
                    <xsl:value-of select="fc:dateTime-to-pretty-reverse-sequential-date($metadata/dc:modified)"/>
                </CoveringDates>
            </xsl:if>

            <!-- Default: 1 (for a file) -->
            <PhysicalDescriptionExtent>1</PhysicalDescriptionExtent>

            <!-- Default: digital record (for a file) -->
            <PhysicalDescriptionForm>digital record</PhysicalDescriptionForm>

            <xsl:call-template name="held-by">
                <xsl:with-param name="metadata" select="$metadata"/>
            </xsl:call-template>

            <xsl:call-template name="closure">
                <xsl:with-param name="metadata" select="$metadata"/>
            </xsl:call-template>

            <xsl:choose>
                <xsl:when test="fbdx:has-born-digital-identifier($metadata/(dc:identifier|dce:identifier))">
                    <xsl:call-template name="fbdx:scope-content">
                        <xsl:with-param name="source-level-id" select="$source-level-id"/>
                        <xsl:with-param name="metadata" select="$metadata"/>
                        <xsl:with-param name="fallback-description" select="xip:Title"/>
                    </xsl:call-template>
                </xsl:when>
                <xsl:when test="fdx:has-digitized-identifier($metadata/(dc:identifier|dce:identifier))">
                    <xsl:call-template name="fdx:scope-content">
                        <xsl:with-param name="metadata" select="$metadata"/>
                    </xsl:call-template>

                    <xsl:call-template name="fdx:personal-names">
                        <xsl:with-param name="metadata" select="$metadata"/>
                    </xsl:call-template>

                    <xsl:call-template name="fdx:places">
                        <xsl:with-param name="metadata" select="$metadata"/>
                    </xsl:call-template>
                </xsl:when>
                <xsl:otherwise>
                    <!-- xsl:message terminate="yes" select="concat('Could not calculate ScopeContent for DU: ', xip:DeliverableUnitId)"/ -->
                </xsl:otherwise>
            </xsl:choose>

            <BatchId>
                <xsl:choose>
                    <xsl:when test="fbdx:has-born-digital-identifier($metadata/(dc:identifier|dce:identifier))">
                        <xsl:value-of select="fbdx:batch-id($metadata)"/>
                    </xsl:when>
                    <xsl:when test="fdx:has-digitized-identifier($metadata/(dc:identifier|dce:identifier))">
                        <xsl:value-of select="fdx:batch-id($metadata)"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <!-- xsl:message terminate="yes" select="concat('Could not calculate BatchId for DU: ', xip:DeliverableUnitId)"/ -->
                    </xsl:otherwise>
                </xsl:choose>
            </BatchId>

            <xsl:choose>
                <xsl:when test="fbdx:has-born-digital-identifier($metadata/(dc:identifier|dce:identifier))">
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
                <xsl:when test="fbdx:has-born-digital-identifier($metadata/(dc:identifier|dce:identifier)) and $source-level-id eq 4">
                    <Digitized>false</Digitized>
                </xsl:when>
                <xsl:otherwise>
                    <Digitized>true</Digitized>
                    <!-- this is always true according to original XSLT -->
                </xsl:otherwise>
            </xsl:choose>

            <xsl:call-template name="replica-identities">
                <xsl:with-param name="deliverable-unit-ref" select="xip:DeliverableUnitRef"/>
            </xsl:call-template>

        </InformationAsset>

        <xsl:variable name="docClosureStatus" select="./xip:Metadata/tnaxm:metadata/c:closure/c:documentClosureStatus"/>
        <xsl:if test="$docClosureStatus eq 'CLOSED'">
            <AccessRegulation>
                <RelatedToIA>
                    <xsl:value-of select="xip:DeliverableUnitRef"/>
                </RelatedToIA>
                <ClosureCriterions>
                    <xsl:for-each select="./xip:Metadata/tnaxm:metadata/c:closure/c:exemptionCode">
                        <ClosureCriterion>
                            <ExemptionCodeId>
                                <xsl:value-of select="."/>
                            </ExemptionCodeId>
                        </ClosureCriterion>
                    </xsl:for-each>
                </ClosureCriterions>
                <SignedDate>
                    <xsl:value-of select="./xip:Metadata/tnaxm:metadata/c:closure/c:exemptionAsserted"/>
                </SignedDate>
                <ReviewDate/>
                <ReconsiderDueInDate/>
                <Explanation/>
                <ProcatTitle>Closure</ProcatTitle>
            </AccessRegulation>
        </xsl:if>
    </xsl:template>

    <xsl:template name="legal-status" as="element(LegalStatus)">
        <xsl:param name="metadata" as="element(tnaxm:metadata)" required="yes"/>
        <LegalStatus>Public Record</LegalStatus>
    </xsl:template>

    <xsl:template name="parent-iaid">
        <xsl:param name="deliverable-unit" as="element(xip:DeliverableUnit)" required="yes"/>
        <ParentIAID>
            <xsl:choose>
                <xsl:when test="$deliverable-unit/xip:ParentRef">
                    <xsl:value-of select="$deliverable-unit/xip:ParentRef"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$parent-id"/>
                </xsl:otherwise>
            </xsl:choose>
        </ParentIAID>
    </xsl:template>

    <xsl:template name="creator-name">
        <xsl:param name="metadata" as="element(tnaxm:metadata)" required="yes"/>
        <CreatorName>
            <CreatorName>
                <Corporate_Body_Name_Text/>
                <!-- removed at request of Discovery team 8/3/2013 -->
                <!--
                    <xsl:value-of select="$metadata/dc:creator"/></Corporate_Body_Name_Text>
                -->
            </CreatorName>
        </CreatorName>
    </xsl:template>

    <xsl:template name="held-by">
        <xsl:param name="metadata"/>
        <HeldBy>
            <HeldBy>
                <Corporate_Body_Name_Text>
                    <xsl:value-of select="$metadata/dc:publisher"/>
                </Corporate_Body_Name_Text>
            </HeldBy>
        </HeldBy>
    </xsl:template>

    <xsl:template name="closure">
        <xsl:param name="metadata" as="element(tnaxm:metadata)" required="yes"/>
        <ClosureType>
            <xsl:value-of select="$metadata/c:closure/c:closureType"/>
        </ClosureType>
        <ClosureCode>
            <xsl:value-of select="$metadata/c:closure/c:closureCode"/>
        </ClosureCode>
        <RecordOpeningDate>
            <xsl:value-of
                select="fc:dateTime-to-reverse-sequential-date($metadata/c:closure/c:openingDate)"/>
        </RecordOpeningDate>
        <ClosureStatus>
            <xsl:value-of select="f:to-discovery-closureStatus($metadata/c:closure/c:documentClosureStatus, $metadata/c:closure/c:descriptionClosureStatus)"/>
        </ClosureStatus>
    </xsl:template>

    <!-- TODO - this needs to change so that it is only put out if there is actually going to be a replica -->
    <xsl:template name="replica-identities">
        <xsl:param name="deliverable-unit-ref"/>
        <xsl:variable name="manifestation" select="ancestor::xip:XIP/xip:DeliverableUnits/xip:Manifestation[xip:DeliverableUnitRef = $deliverable-unit-ref]"/>

        <xsl:variable name="digital-files" select="key('file-by-fileref', $manifestation/xip:ManifestationFile/xip:FileRef)[xip:Directory = 'false']"/>

        <xsl:if test="not(empty($digital-files))">
            <ReplicaIdentities>
                <ReplicaIdentity>
                    <ReplicaId>
                        <xsl:value-of select="$manifestation/xip:ManifestationRef"/>
                    </ReplicaId>
                </ReplicaIdentity>
            </ReplicaIdentities>
        </xsl:if>
    </xsl:template>

    <xsl:template name="extract-path" as="node()*">
        <xsl:param name="current-path" as="xs:string"/>

        <!-- <debug_v> <xsl:value-of select="$current-path"/> </debug_v>

        <debug_y> <xsl:value-of select="$directories//Folder/Label"/> </debug_y>
        <debug_u> <xsl:value-of select="$directories//Folder/Label"/> </debug_u>
        <debug_a> <xsl:value-of select="$directories/Directories/Folder/Label"/> </debug_a>
-->
        <!--  <xsl:copy-of select="$directories/Directories/Folder[Label eq $current-path]" copy-namespaces="no" /> <!-\- /directory[path/text() eq $current-path]"/> -\->-->


        <xsl:variable name="folder" select="$directoriesDoc/Directories/Folder[Label eq $current-path]"/>
        <!-- /directory[path/text() eq $current-path]"/> -->
        <xsl:variable name="short-path" select="fc:substring-after-last($current-path,'/')"/>
        <Folder>
            <Label>
                <xsl:value-of select="$short-path"/>
            </Label>
            <ID>
                <xsl:value-of select="$folder/ID"/>
            </ID>
            <xsl:if test="exists($folder/ParentID)">
                <ParentID>
                    <xsl:value-of select="$folder/ParentID"/>
                </ParentID>
            </xsl:if>
        </Folder>


        <xsl:variable name="short-path">
            <xsl:value-of select="fc:substring-after-last($current-path,'/')"/>
        </xsl:variable>


        <xsl:variable name="parent-path">
            <xsl:value-of select="fc:substring-before-last($current-path,'/')"/>
        </xsl:variable>
        <xsl:if test="$parent-path != ''">
            <xsl:call-template name="extract-path">
                <xsl:with-param name="current-path" select="$parent-path"/>
            </xsl:call-template>
        </xsl:if>

    </xsl:template>

    <xsl:template match="xip:Files">
        <!-- do nothing -->
    </xsl:template>

    <xsl:template match="xip:Manifestation">

        <xsl:variable name="digital-files" select="key('file-by-fileref', xip:ManifestationFile/xip:FileRef)[xip:Directory = 'false']"/>
        <xsl:variable name="open-digital-files" select="key('file-by-fileref', xip:ManifestationFile/xip:FileRef)[xip:Metadata/tnaxm:metadata/c:closure/c:documentClosureStatus eq 'OPEN']"/>

        <xsl:if test="not(empty($open-digital-files))">
            <Replica>
                <Id>
                    <xsl:value-of select="xip:ManifestationRef"/>
                </Id>
                <RelatedToIA>
                    <xsl:value-of select="xip:DeliverableUnitRef"/>
                </RelatedToIA>
                <Folios>
                    <Folio>
                        <xsl:variable name="this-DU" select="key('deliv-unit-by-deliverableunitref', xip:DeliverableUnitRef)" as="element()"/>
                        <xsl:variable name="metadata" select="$this-DU/xip:Metadata/tnaxm:metadata" as="element(tnaxm:metadata)"/>
                        <FolioId>
                            <xsl:value-of select="xip:DeliverableUnitRef"/>
                        </FolioId>
                        <DigitalFiles>
                            <xsl:for-each select="$digital-files">
                                <xsl:sort select="xip:FileName"/>
                                <xsl:variable name="docClosureStatus" select="./xip:Metadata/tnaxm:metadata/c:closure/c:documentClosureStatus"/>
                                <xsl:if test="$docClosureStatus eq 'OPEN'">
                                    <xsl:call-template name="digital-file">
                                        <xsl:with-param name="digital-file" select="."/>
                                        <xsl:with-param name="digital-file-count" select="count($digital-files)"/>
                                        <xsl:with-param name="position" select="position()"/>
                                        <xsl:with-param name="metadata" select="$metadata"/>
                                    </xsl:call-template>
                                </xsl:if>
                            </xsl:for-each>
                        </DigitalFiles>

                        <xsl:call-template name="closure">
                            <xsl:with-param name="metadata" select="$metadata"/>
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
        <xsl:param name="metadata" as="element(tnaxm:metadata)" required="yes"/>

        <xsl:variable name="puid" as="xs:string">
            <xsl:value-of select="xip:FormatInfo/xip:FormatPUID/text()"/>
        </xsl:variable>

        <DigitalFile>
            <DigitalFileName>
                <xsl:value-of select="xip:FileName"/>
            </DigitalFileName>
            <DigitalFileRef>
                <xsl:if test="string-length(xip:Metadata/tnaxm:metadata/dc:isFormatOf) gt 0">
                    <xsl:attribute name="isFormatOf" namespace="http://purl.org/dc/terms/" select="xip:Metadata/tnaxm:metadata/dc:isFormatOf"/>
                    <xsl:attribute name="format" namespace="http://purl.org/dc/terms/" select="$puid"/>
                </xsl:if>
                <xsl:value-of select="xip:FileRef"/>
            </DigitalFileRef>
            <DigitalFilePartNumber>
                <xsl:value-of select="$position"/>
            </DigitalFilePartNumber>
            <DigitalFileSize>
                <xsl:value-of select="number(xip:FileSize) idiv 1024"/>
            </DigitalFileSize>
            <!-- need in KB e.g. =866657/1024 -->
            <DigitalFileNumberOfPages>
                <xsl:value-of select="$digital-file-count"/>
            </DigitalFileNumberOfPages>
            <!-- this must be a count of the number of .jpeg images in the same cluster -->
            <DigitalFileFormat>
                <xsl:value-of select="doc($droid-signature-file)/sf:FFSignatureFile/sf:FileFormatCollection/sf:FileFormat[@PUID eq $puid]/@MIMEType"/>
            </DigitalFileFormat>
            <DigitalFileDirectory>
                <xsl:variable name="working-path" select="xip:WorkingPath/text()"/>

                <xsl:variable name="folders" as="node()*">
                    <xsl:call-template name="extract-path">
                        <xsl:with-param name="current-path" select="$working-path"/>
                    </xsl:call-template>
                </xsl:variable>


                <!--<xsl:variable name="sortedFolders" as="node()*">
                    <xsl:perform-sort select="$folders">
                        <xsl:sort select="Folder/Label" data-type="text" order="ascending"/>
                    </xsl:perform-sort>
                </xsl:variable>
-->
                <xsl:sequence select="$folders"/>


            </DigitalFileDirectory>

            <xsl:call-template name="closure">
                <xsl:with-param name="metadata" select="$metadata"/>
            </xsl:call-template>

        </DigitalFile>
    </xsl:template>


    <xsl:template name="create-catalogue-reference">
        <xsl:param name="catalogue-reference"/>
        <Reference>
            <xsl:value-of select="replace($catalogue-reference, concat('(^.*?)', '/'), concat('$1',' '))"/>
        </Reference>
    </xsl:template>

    <!-- suppress default with this template -->
    <xsl:template match="text()"/>

    <xsl:function name="f:to-discovery-closureStatus" as="xs:string">
        <xsl:param name="documentClosureStatus" as="element(c:documentClosureStatus)"/>
        <xsl:param name="descriptionClosureStatus" as="element(c:descriptionClosureStatus)"/>
        <xsl:choose>
            <xsl:when test="$documentClosureStatus eq 'OPEN' and $descriptionClosureStatus eq 'OPEN'">O</xsl:when>
            <xsl:when test="$documentClosureStatus eq 'CLOSED' and $descriptionClosureStatus eq 'OPEN'">D</xsl:when>
            <xsl:when test="$documentClosureStatus eq 'CLOSED' and $descriptionClosureStatus eq 'CLOSED'">C</xsl:when>
            <xsl:otherwise>UNKNOWN</xsl:otherwise>
        </xsl:choose>
    </xsl:function>



</xsl:stylesheet>
