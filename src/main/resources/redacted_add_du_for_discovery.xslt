<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:api="http://nationalarchives.gov.uk/dri/catalogue/api"
                xmlns:c="http://nationalarchives.gov.uk/dri/closure" xmlns:dc="http://purl.org/dc/terms/"
                xmlns:fc="http://xip-bia/functions/common"
                xmlns:sf="http://www.nationalarchives.gov.uk/pronom/SignatureFile"
                xmlns:tna="http://nationalarchives.gov.uk/metadata/tna#"
                xmlns:tnaxm="http://nationalarchives.gov.uk/metadata/"
                xmlns:xip="http://www.tessella.com/XIP/v4" xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:f="http://local/functions"
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

    <xsl:variable name="main-root" select="/"/>
    <xsl:template match="xip:DeliverableUnit">
        <xsl:if test="xip:Metadata/tna:metadata/rdf:RDF/tna:BornDigitalRecord/tna:digitalFile/tna:DigitalFile/tna:hasRedactedFile">
            <!-- I have to duplicate the DU, with the new reference that has _1, the updated Catalogue reference and the updated closure info-->
            <xsl:variable name="redactedFileNames" select="f:redacted-file-names(.)"/>
            <xsl:variable name="redactedFilePaths" select="f:redacted-file-paths(.)"/>
            <xsl:variable name="du" select="."/>
            <xsl:for-each select="$redactedFileNames">
                <xsl:variable name="index" select="position()"/>
                <xsl:variable name="redactedFilePath" select ="$redactedFilePaths[$index]"/>
                <xsl:variable name="redactedFileName" select ="$redactedFileNames[$index]"/>
                <xsl:variable name="redacted2" select="replace(replace($redactedFilePath, concat('(^.*?)', '_'), concat('$1',' ')),'content/','')"/>
                <xsl:variable name="decoded-filename" select="replace($redactedFileName, '%20', ' ')"/>
                <xsl:variable name="decoded-redactedpath" select="replace($redacted2, '%20', ' ')"/>
                <xsl:element name="DeliverableUnit" namespace="http://www.tessella.com/XIP/v4">
                    <xsl:element name="DeliverableUnitRef" namespace="http://www.tessella.com/XIP/v4">
                        <xsl:value-of select = "concat($du/xip:DeliverableUnitRef,'_',$index)"></xsl:value-of>
                    </xsl:element>
                    <xsl:variable name="children" select="$du/xip:*[position() gt 1]" as="element()+"/>
                    <xsl:copy-of select="$children[position() le index-of($children/local-name(.), 'DigitalSurrogate')]"/>
                    <xsl:element name="CatalogueReference" namespace="http://www.tessella.com/XIP/v4">
                        <xsl:value-of select = "concat($du/xip:CatalogueReference,'/',$index)"></xsl:value-of>
                    </xsl:element>

                    <xsl:copy-of select="$children[position() lt index-of($children/local-name(.), 'Metadata') and (position() gt index-of($children/local-name(.), 'CatalogueReference'))]"/>

                    <xsl:variable name="metadata" select="$children[position() eq index-of($children/local-name(.), 'Metadata')]/*/*" as="element()+"/>

                    <xsl:element name="Metadata" namespace="http://www.tessella.com/XIP/v4">
                        <xsl:attribute name="schemaURI">http://nationalarchives.gov.uk/metadata/tna#</xsl:attribute>
                        <xsl:element name = "tna:metadata" namespace="http://nationalarchives.gov.uk/metadata/tna#" >
                            <xsl:message select="$metadata/c/*"/>
                            <xsl:element name="rdf:RDF">
                                  <xsl:variable name="BDR" select="$metadata/*[local-name(.) = 'BornDigitalRecord']"/>
                                  <xsl:element name="tna:BornDigitalRecord">
                                      <xsl:copy-of select="$BDR/@*" />
                                      <xsl:element name="tna:cataloguing">
                                          <xsl:element name="tna:Cataloguing">
                                              <xsl:variable name="Cataloguing" select="$BDR/*/*[local-name(.) = 'Cataloguing']"  as="element()+"/>
                                              <xsl:copy-of select="$Cataloguing/*[position() lt index-of($Cataloguing/*/local-name(.), 'heldBy')]"/>
                                               <xsl:element name="tna:heldBy">
                                                      <xsl:text>The National Archives, Kew</xsl:text>
                                               </xsl:element>
                                               <xsl:copy-of select="$Cataloguing/*[position() gt index-of($Cataloguing/*/local-name(.), 'heldBy')]"/>
                                          </xsl:element>
                                      </xsl:element>
                                   </xsl:element>
                            </xsl:element>
                             <!--get the right closure-->
                            <xsl:variable name ="closure" select="$main-root/xip:XIP/xip:Files/xip:File[xip:FileName=$decoded-filename and contains($decoded-redactedpath,xip:WorkingPath/text())]/xip:Metadata/tna:metadata/c:closure" as="element()"/>
                            <xsl:copy-of select="$closure"/>
                        </xsl:element>
                    </xsl:element>
                   <xsl:copy-of select="$children[position() lt last() and (position() gt index-of($children/local-name(.), 'Metadata') )]"/>
                </xsl:element>
            </xsl:for-each>
         </xsl:if>
        <xsl:copy>
            <xsl:apply-templates select="node()|@*"/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="xip:Manifestation/xip:DeliverableUnitRef/text()">
        <xsl:choose>
            <xsl:when test="ancestor::xip:Manifestation/xip:TypeRef=100">
                <xsl:variable name="relRef" select="ancestor::xip:Manifestation/xip:ManifestationRelRef/text()"/>
                <xsl:variable name="ref" select="$relRef -1"/>
                <xsl:value-of select = "concat(.,'_',$ref)"></xsl:value-of>
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy/>
             </xsl:otherwise>
        </xsl:choose>
    </xsl:template>


    <xsl:function name="f:redacted-file-names">
        <xsl:param name="du" />
        <xsl:for-each select="$du/xip:Metadata/tna:metadata/rdf:RDF/tna:BornDigitalRecord/tna:digitalFile/tna:DigitalFile/tna:hasRedactedFile">
            <xsl:value-of select="tokenize(., '/')[last()]"/>
        </xsl:for-each>

    </xsl:function>

    <xsl:function name="f:redacted-file-paths">
        <xsl:param name="du" />
        <xsl:for-each select="$du/xip:Metadata/tna:metadata/rdf:RDF/tna:BornDigitalRecord/tna:digitalFile/tna:DigitalFile/tna:hasRedactedFile">
            <xsl:value-of select="."/>
        </xsl:for-each>
    </xsl:function>


    <xsl:template match="node()|@*">
        <xsl:copy>
            <xsl:apply-templates select="node()|@*"/>
        </xsl:copy>
    </xsl:template>

</xsl:stylesheet>
