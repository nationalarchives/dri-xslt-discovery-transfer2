<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.tessella.com/XIP/v4"
                xmlns:csf="http://catalogue/service/functions"
                xmlns:dcterms="http://purl.org/dc/terms/"
                xmlns:c="http://nationalarchives.gov.uk/dri/closure"
                xmlns:f="http://local/functions"
                xmlns:tna="http://nationalarchives.gov.uk/metadata/tna#"
                xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
                xmlns:xip="http://www.tessella.com/XIP/v4"

                xmlns:xsl="http://www.w3.org/1999/XSL/Transform" exclude-result-prefixes="dcterms f csf xip"
                version="2.0">
    <!--This xslt is used to create the input file for a xslt export to discovery
     The input file and closure xml can be obtained by running the transformations workflow text,
     with breakpoint in the after step def
     -->

    <xsl:param name="closure-xml-path" >file:///opt/preservica/JobQueue/temp/WF/81ffe4cc-3a08-4333-99c6-813db14d7252/9bafef55-0b2d-4cd0-b108-6667b2474b17/7358d9ba-94d5-4eda-9014-12b10ef45b46/content/closures.xml</xsl:param>


    <xsl:variable name="closuresFile">
        <xsl:choose>
            <xsl:when test="doc-available($closure-xml-path)">
                <xsl:copy-of select="doc($closure-xml-path)"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:message terminate="yes"
                             select="concat('Metadata CSV ''', $closure-xml-path,''' is not available!')"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>


    <xsl:template match="XIP">
        <xsl:apply-templates/>
    </xsl:template>


    <xsl:template match="xip:Manifestation">
    </xsl:template>

    <xsl:template match="xip:DeliverableUnit">

                   <xsl:choose>
            <xsl:when test="contains(./xip:CatalogueReference,'_')"></xsl:when>
            <xsl:otherwise>
                <xsl:element name="DeliverableUnit"><xsl:attribute name="status">new</xsl:attribute>
                <xsl:apply-templates></xsl:apply-templates>
                </xsl:element>
            </xsl:otherwise>
        </xsl:choose>

    </xsl:template>
    
    <xsl:template match="rdf:RDF">
        <xsl:copy-of select="."/>
        <xsl:variable name="duRef" select="../../../xip:DeliverableUnitRef/text()"/>
        <xsl:variable name="closureRow" select="$closuresFile//c:closure[c:uuid = $duRef]"/>
        <xsl:if test="exists($closureRow) and not (exists(../c:closure))">
            <xsl:element name="c:closure">
                <xsl:attribute name="resourceType" select="'DeliverableUnit'"/>
                <xsl:element name="c:uuid">
                    <xsl:value-of select="$closureRow/c:uuid"/>
                </xsl:element>
                <xsl:element name="c:documentClosureStatus">
                    <xsl:value-of select="$closureRow/c:documentClosureStatus"/>
                </xsl:element>
                <xsl:element name="c:descriptionClosureStatus">
                    <xsl:value-of select="$closureRow/c:descriptionClosureStatus"/>
                </xsl:element>
                <xsl:element name="c:closureType">
                    <xsl:value-of select="$closureRow/c:closureType"/>
                </xsl:element>
                <xsl:element name="c:closureCode">
                    <xsl:value-of select="$closureRow/c:closureCode"/>
                </xsl:element>
                <xsl:element name="c:openingDate">
                    <xsl:value-of select="'2014-03-16T01:00:00Z'"/>
                </xsl:element>
                <xsl:if test="$closureRow/c:retentionJustification != ''">
                    <xsl:element name="c:retentionJustification">
                        <xsl:value-of select="$closureRow/c:retentionJustificatio"/>
                    </xsl:element>
                </xsl:if>
                <xsl:if test="$closureRow/c:retentionReconsiderDate != ''">
                    <xsl:element name="c:retentionReconsiderDate">
                        <xsl:value-of select="$closureRow/c:retentionReconsiderDate"/>
                    </xsl:element>
                </xsl:if>
                <xsl:if test="$closureRow/c:RINumber != ''">
                    <xsl:element name="c:RINumber">
                        <xsl:value-of select="$closureRow/c:RINumber"/>
                    </xsl:element>
                </xsl:if>
                <xsl:if test="$closureRow/c:RISignedDate != ''">
                    <xsl:element name="c:RISignedDate">
                        <xsl:value-of select="$closureRow/c:RISignedDate"/>
                    </xsl:element>
                </xsl:if>
           </xsl:element>
        </xsl:if>
    </xsl:template>


    <xsl:template match="node()|@*">
        <xsl:copy>
            <xsl:apply-templates select="node()|@*"/>
        </xsl:copy>
    </xsl:template>

</xsl:stylesheet>
