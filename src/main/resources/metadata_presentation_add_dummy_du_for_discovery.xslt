<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:api="http://nationalarchives.gov.uk/dri/catalogue/api"
    xmlns:c="http://nationalarchives.gov.uk/dri/closure" xmlns:dc="http://purl.org/dc/terms/"
    xmlns:fc="http://xip-bia/functions/common"
    xmlns:sf="http://www.nationalarchives.gov.uk/pronom/SignatureFile"
    xmlns:tna="http://nationalarchives.gov.uk/metadata/tna#"
    xmlns:tnaxm="http://nationalarchives.gov.uk/metadata/"
    xmlns:xip="http://www.tessella.com/XIP/v4" xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
       
    exclude-result-prefixes="api c dc fc sf tna tnaxm xip xs xsl" version="2.0">
<!--    xpath-default-namespace="http://www.tessella.com/XIP/v4"-->
    <!--
        This stylesheet is based completely on template matching and is designed to separate out those
        SIPs that contain new style RDF/XML metdata from those that contain old style XML metadata.
        The old style metadata will only appear in Home Guard records and possibly Leveson Inquiry records.
        The separation occurs in the DeliverableUnit match template and if old style metadata is detected
        processing is passed off to xip-to-bia-v4-b.xslt. Otherwise named templates in
        xip-to-bia-v4-templates.xslt or functions in xip-to-bia-v4-functions.xslt
        -->

    <xsl:output indent="yes" encoding="UTF-8" omit-xml-declaration="no"/>
       

 
    <xsl:template match="xip:DeliverableUnit">
        <xsl:if test="xip:Metadata/tna:metadata/rdf:RDF/tna:BornDigitalRecord/tna:digitalFile/tna:DigitalFile/tna:hasPresentationManifestationFile">
            <!-- I have to duplicate the DU, with the new reference that has _1, the updated Catalogue reference and the updated closure info-->
            <xsl:variable name="filename" select="tokenize(xip:Metadata/tna:metadata/rdf:RDF/tna:BornDigitalRecord/tna:digitalFile/tna:DigitalFile/tna:hasPresentationManifestationFile, '/')[last()]"></xsl:variable>
            <xsl:variable name="redactedpath" select="replace(replace(xip:Metadata/tna:metadata/rdf:RDF/tna:BornDigitalRecord/tna:digitalFile/tna:DigitalFile/tna:hasPresentationManifestationFile/text(), '_', ' '),'content/','')"/>
            
            <xsl:variable name="decoded-filename" select="replace($filename, '%20', ' ')"/>
            <xsl:variable name="decoded-redactedpath" select="replace($redactedpath, '%20', ' ')"/>
            
                <xsl:copy>
                    <xsl:element name="DeliverableUnitRef" namespace="http://www.tessella.com/XIP/v4">
                        <xsl:value-of select = "concat(xip:DeliverableUnitRef,'_1')"></xsl:value-of>
                    </xsl:element>
                    <xsl:variable name="children" select="child::xip:*[position() gt 1]" as="element()+"/>
                    <xsl:copy-of select="$children[position() le index-of($children/local-name(.), 'DigitalSurrogate')]"/>
                    <xsl:element name="CatalogueReference" namespace="http://www.tessella.com/XIP/v4">
                        <xsl:value-of select = "concat(xip:CatalogueReference,'/1')"></xsl:value-of>
                    </xsl:element>
                    <xsl:copy-of select="$children[position() lt index-of($children/local-name(.), 'Metadata') and (position() gt index-of($children/local-name(.), 'CatalogueReference'))]"/>
                    <!-- copy Metadata, but change the closure, copying it from file-->
                    
                    <xsl:variable name="metadata" select="$children[position() eq index-of($children/local-name(.), 'Metadata')]/*/*" as="element()+"/>

                    <xsl:element name="Metadata" namespace="http://www.tessella.com/XIP/v4">
                        <xsl:attribute name="schemaURI">http://nationalarchives.gov.uk/metadata/tna#</xsl:attribute>
                        <xsl:element name = "tna:metadata" namespace="http://nationalarchives.gov.uk/metadata/tna#" >
                            <xsl:copy-of select="$metadata[position() lt index-of($metadata/local-name(.), 'closure')]"/>
                            <!--get the right closure-->
                            <xsl:variable name ="closure" select = "ancestor::xip:XIP/xip:Files/xip:File[xip:FileName=$decoded-filename and contains($decoded-redactedpath,xip:WorkingPath/text())]/xip:Metadata/tna:metadata/c:closure" as="element()"/>
                            <xsl:copy-of select="$closure"/>    
                       </xsl:element>
                    </xsl:element>
                    <xsl:copy-of select="$children[position() lt last() and (position() gt index-of($children/local-name(.), 'Metadata') )]"/>
                </xsl:copy>
            </xsl:if>
        <xsl:copy>
            <xsl:apply-templates select="node()|@*"/>
        </xsl:copy>
    </xsl:template>
    
    <!-- the presentation manifesation should point to the modified du-->
    <!-- it will only work for one extra manifestation-->
    
    <xsl:template match="xip:Manifestation/xip:DeliverableUnitRef/text()">
        <xsl:choose>
            <xsl:when test="ancestor::xip:Manifestation/xip:TypeRef=101">
                <xsl:value-of select = "concat(.,'_1')"></xsl:value-of>
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy>
                    <xsl:apply-templates/>
                </xsl:copy>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="node()|@*">
        <xsl:copy>
            <xsl:apply-templates select="node()|@*"/>
        </xsl:copy>
    </xsl:template>    
    
</xsl:stylesheet>
