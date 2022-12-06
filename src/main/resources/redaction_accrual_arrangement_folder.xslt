<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:api="http://nationalarchives.gov.uk/dri/catalogue/api"
                xmlns:c="http://nationalarchives.gov.uk/dri/closure" xmlns:dc="http://purl.org/dc/terms/"
                xmlns:fc="http://xip-bia/functions/common"
                xmlns:sf="http://www.nationalarchives.gov.uk/pronom/SignatureFile"
                xmlns:tna="http://nationalarchives.gov.uk/metadata/tna#"
                xmlns:tnaxm="http://nationalarchives.gov.uk/metadata/"
                xmlns:xip="http://www.tessella.com/XIP/v4" xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:ext="http://tna/saxon-extension"
                exclude-result-prefixes="api c dc fc sf tna tnaxm xip xs xsl" version="2.0">

    <xsl:output indent="yes" encoding="UTF-8" omit-xml-declaration="no"/>
    <xsl:param name="content-base-path" select="'/home/ihoyle/arrangement'"/>
    <xsl:param name="production" select="'true'"/>


    <!--  Replace Path with that of original It is a redaction if there is also a Manifestation with
          A DeliverableUnitRef same before _
    -->
    <xsl:template match="xip:Manifestation/xip:ManifestationFile/xip:Path/text()">
        <xsl:variable name="manifestationDeliverableUnitRef" select="ancestor::xip:Manifestation/xip:DeliverableUnitRef"/>
        <xsl:variable name="originalDuRef" select="substring-before($manifestationDeliverableUnitRef,'_')"/>
        <xsl:choose>
            <xsl:when test="$originalDuRef">
                <xsl:value-of  select="//xip:Manifestation[xip:DeliverableUnitRef/text() = $originalDuRef]/xip:ManifestationFile/xip:Path/text()"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!-- If redacted file use WorkingPath of original and move the file to same content folder
         as the original. Redaction accruals will be in the redaction accrual folder-->
    <xsl:template match="xip:File/xip:WorkingPath/text()">
        <xsl:variable name="fileName" select="../../xip:FileName/text()"/>
        <xsl:variable name="fileRef" select="../../xip:FileRef/text()"/>
        <xsl:variable name="duRef"
                      select="//xip:Manifestation[xip:ManifestationFile/xip:FileRef/text() = $fileRef]/xip:DeliverableUnitRef/text()"/>
        <xsl:variable name="originalDuRef" select="substring-before($duRef,'_')"/>
        <xsl:choose>
            <xsl:when test="$originalDuRef">
                <xsl:variable name="originalManifestation" select="//xip:Manifestation[xip:DeliverableUnitRef/text() = $originalDuRef]"/>
                <xsl:variable name="originalFileRef" select="$originalManifestation/xip:ManifestationFile/xip:FileRef"/>
                <xsl:variable name="originalWorkingPath"  select="//xip:File[xip:FileRef = $originalFileRef]/xip:WorkingPath/text()"/>
                <xsl:variable name="toDestination" select="concat($originalWorkingPath,'/',$fileName)"/>
                <xsl:variable name="fromDestination" select="concat(.,'/',$fileName)"/>
                <xsl:if test="not($toDestination = $fromDestination) and $production = 'true'">
                    <xsl:message select="concat('moving file',$content-base-path,'/content/',$fromDestination, ' to ',$content-base-path,'/content/',$toDestination) "/>
                    <xsl:sequence  select="ext:move-file(concat($content-base-path,'/content/',$fromDestination), concat($content-base-path,'/content/',$toDestination))"/>
                </xsl:if>
                <xsl:copy-of select="//xip:File[xip:FileRef = $originalFileRef]/xip:WorkingPath/text()"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="node()|@*">
        <xsl:copy>
            <xsl:apply-templates select="node()|@*"/>
        </xsl:copy>
    </xsl:template>

</xsl:stylesheet>
