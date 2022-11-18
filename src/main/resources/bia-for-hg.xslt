<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    version="2.0">
    
    <xsl:output indent="yes"/>
    
    <!-- This XSLT removes InformationAssets created from Manifestations and connects their parent InformationAssets
        directly to the Replicas for the DigitalFiles which the Manifestations represented -->
    
    <xsl:template match="BIA">
        <xsl:copy>
            <xsl:apply-templates/>
        </xsl:copy>        
    </xsl:template>
    
    <xsl:template match="InformationAsset">
        <xsl:variable name="iaid" select="IAID"/>
        <xsl:variable name="replica" select="parent::BIA/Replica[RelatedToIA = $iaid]"/>
        <xsl:variable name="child" select="parent::BIA/InformationAsset[ParentIAID = $iaid]"/>
        <xsl:variable name="child-replica" select="parent::BIA/Replica[RelatedToIA = $child/IAID]"/>
        <!-- only copy the IA if it has not been generated from a manifestation - the easiest way to test this
            is to check whether it has associated digital files - only manifestation based IAs will have these -->
        <xsl:if test="not($replica/Folios/Folio/DigitalFiles)">
            <xsl:choose>
                <!-- when the child IA has replica jpegs pass the replica-id param -->
                <xsl:when test="$child-replica/Folios/Folio/DigitalFiles/DigitalFile/DigitalFileFormat[.='image/jpeg']">
                    <xsl:call-template name="information-asset">
                        <xsl:with-param name="current-ia" select="."/>
                        <xsl:with-param name="child-replica-id" select="$child-replica/Id"/>
                    </xsl:call-template>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:call-template name="information-asset">
                        <xsl:with-param name="current-ia" select="."/>
                    </xsl:call-template>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:if>
    </xsl:template>
    
    <xsl:template name="information-asset">        
        <xsl:param name="current-ia" as="element()"/>
        <xsl:param name="child-replica-id" as="element()*"/>
        <InformationAsset>
            <IAID><xsl:value-of select="$current-ia/IAID"/></IAID>
            <SourceLevelId><xsl:value-of select="$current-ia/SourceLevelId"/></SourceLevelId>
            <ParentIAID><xsl:value-of select="$current-ia/ParentIAID"/></ParentIAID>
            <!--<Reference><xsl:value-of select="$current-ia/Reference"/></Reference>-->
            <!-- complicated logic for Discovery mapping -->
            <!-- e.g. from WO 16/409/27_34/412 to WO 409/27/34/412 -->
            <Reference>
                <xsl:variable name="refWithout16" select="replace($current-ia/Reference/text(), concat('(^.*?)', ' 16/'), concat('$1',' '))"/>
                <xsl:value-of select="replace($refWithout16, concat('(^.*?)', '_'), concat('$1','/'))"/>
            </Reference>

            <CatalogueId><xsl:value-of select="$current-ia/CatalogueId"/></CatalogueId>
            <LegalStatus><xsl:value-of select="$current-ia/LegalStatus"/></LegalStatus>
            <Title><xsl:value-of select="$current-ia/Title"/></Title>
            <xsl:if test="$current-ia/CreatorName">
                <xsl:copy-of select="$current-ia/CreatorName"/>
            </xsl:if>
            <CoveringDates>1940-1945</CoveringDates>
            <xsl:if test="$current-ia/HeldBy">
                <xsl:copy-of select="$current-ia/HeldBy"/>
            </xsl:if>
            <ClosureType><xsl:value-of select="$current-ia/ClosureType"/></ClosureType>
            <ClosureCode><xsl:value-of select="$current-ia/ClosureCode"/></ClosureCode>
            <RecordOpeningDate><xsl:value-of select="$current-ia/RecordOpeningDate"/></RecordOpeningDate>
            <ClosureStatus><xsl:value-of select="$current-ia/ClosureStatus"/></ClosureStatus>
            <xsl:if test="$current-ia/ScopeContent">
                <xsl:copy-of select="$current-ia/ScopeContent"/>
            </xsl:if>
            <xsl:if test="$current-ia/PersonalNames">
                <xsl:copy-of select="$current-ia/PersonalNames"/>
            </xsl:if>
            <xsl:if test="$current-ia/Places">
                <xsl:copy-of select="$current-ia/Places"/>
            </xsl:if>
            <BatchId><xsl:value-of select="$current-ia/BatchId"/></BatchId>
            <CoveringFromDate>19400514</CoveringFromDate>
            <CoveringToDate>19451231</CoveringToDate>
            <LiveFlag><xsl:value-of select="$current-ia/LiveFlag"/></LiveFlag>
            <Digitized><xsl:value-of select="$current-ia/Digitized"/></Digitized>
            
            <xsl:if test="not(empty($child-replica-id))">
                <ReplicaIdentities>
                    <xsl:for-each select="$child-replica-id">
                        <ReplicaIdentity>
                            <ReplicaId><xsl:value-of select="."/></ReplicaId>
                        </ReplicaIdentity>
                    </xsl:for-each>                   
                </ReplicaIdentities>
            </xsl:if>
            
        </InformationAsset>        
    </xsl:template>
    
    <xsl:template match="Replica">
        <xsl:choose>
            <xsl:when test="Folios/Folio/DigitalFiles/DigitalFile/DigitalFileFormat[.='image/jpeg']">
                <xsl:copy>
                    <xsl:apply-templates/>
                </xsl:copy>
            </xsl:when>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="Id">
        <xsl:copy-of select="."/>
    </xsl:template>

    <xsl:template match="AccessRegulation"/>
     
    <!-- replace the RelatedToIA value with the related-to's parent IAID --> 
    <xsl:template match="RelatedToIA">
        <xsl:variable name="parent-ia" select="."/>
        <xsl:variable name="grandparent-ia" select="ancestor::BIA/InformationAsset[IAID = $parent-ia]/ParentIAID"/>
        <xsl:copy>
            <xsl:value-of select="$grandparent-ia"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="Folios">
        <xsl:copy-of select="."/>
    </xsl:template>
    
    <xsl:template match="text()"/>
    
</xsl:stylesheet>