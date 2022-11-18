<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:tnaxm="http://nationalarchives.gov.uk/metadata/"
    xmlns:fc="http://xip-bia/functions/common"
    xmlns:c="http://nationalarchives.gov.uk/dri/closure"
    version="2.0">
    
    <xsl:function name="fc:is-open-description" as="xs:boolean">
        <xsl:param name="metadata" as="element(tnaxm:metadata)"/>
        <xsl:value-of select="$metadata/c:closure/c:descriptionClosureStatus eq 'OPEN'"/>
    </xsl:function>
    
    <!-- converts xs:dateTime to format YYYYMMDD -->
    <xsl:function name="fc:dateTime-to-reverse-sequential-date" as="xs:string">
        <xsl:param name="date" as="xs:dateTime"/>
        <xsl:value-of select="format-dateTime($date, '[Y0001][M01][D01]')"/>
    </xsl:function>
    
    <!-- converts xs:date to format YYYYMMDD -->
    <xsl:function name="fc:date-to-reverse-sequential-date" as="xs:string">
        <xsl:param name="date" as="xs:date"/>
        <xsl:value-of select="format-date($date, '[Y0001][M01][D01]')"/>
    </xsl:function>
    
    <!-- converts xs:dateTime to format YYYY Mmm DD -->       
    <xsl:function name="fc:dateTime-to-pretty-reverse-sequential-date" as="xs:string">
        <xsl:param name="date" as="xs:dateTime"/>
        <xsl:value-of select="format-dateTime($date, '[Y0001] [MNn,3-3] [D01]')"/>
    </xsl:function>
    
    <xsl:function name="fc:w3cdtf-to-uk-date" as="xs:string">
        <xsl:param name="date" as="xs:string"/>
        <xsl:choose>
            <xsl:when test="$date castable as xs:dateTime"><xsl:value-of select="format-dateTime(xs:dateTime($date), '[D01]/[M01]/[Y0001]')"/></xsl:when>
            <xsl:when test="$date castable as xs:date"><xsl:value-of select="fc:date-to-uk-date(xs:date($date))"/></xsl:when>
            <xsl:when test="$date castable as xs:gYearMonth"><xsl:value-of select="concat(substring-after($date, '-'), '/', substring-before($date, '-'))"/></xsl:when>
            <xsl:when test="$date castable as xs:gYear"><xsl:value-of select="$date"/></xsl:when>
            <xsl:otherwise><xsl:value-of select="$date"/></xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <xsl:function name="fc:date-to-uk-date" as="xs:string">
        <xsl:param name="date" as="xs:date"/>
        <xsl:value-of select="format-date($date, '[D01]/[M01]/[Y0001]')"/>
    </xsl:function>
    
    <!-- from http://www.xsltfunctions.com/xsl/functx_escape-for-regex.html -->
    <xsl:function name="fc:escape-for-regex" as="xs:string">
        <xsl:param name="arg" as="xs:string?"/>        
        <xsl:sequence select="replace($arg,'(\.|\[|\]|\\|\||\-|\^|\$|\?|\*|\+|\{|\}|\(|\))','\\$1')"/>
    </xsl:function>
    
    <!-- http://www.xsltfunctions.com/xsl/functx_substring-before-last.html -->
    <xsl:function name="fc:substring-before-last" as="xs:string">
        <xsl:param name="arg" as="xs:string?"/>
        <xsl:param name="delim" as="xs:string"/>
        <xsl:sequence select="if(matches($arg, fc:escape-for-regex($delim))) then replace($arg,concat('^(.*)', fc:escape-for-regex($delim),'.*'),'$1') else ''"/>
    </xsl:function>

    <!--http://www.xsltfunctions.com/xsl/functx_substring-after-last.html-->
    <xsl:function name="fc:substring-after-last" as="xs:string">
        <xsl:param name="arg" as="xs:string?"/>
        <xsl:param name="delim" as="xs:string"/>
        <xsl:sequence select="replace ($arg,concat('^.*',fc:escape-for-regex($delim)),'') "/>
    </xsl:function>
    
</xsl:stylesheet>