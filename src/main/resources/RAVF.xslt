<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                 version="2.0">

    <xsl:strip-space elements="*"/>

    <xsl:output indent="yes" encoding="UTF-8" omit-xml-declaration="no"/>

    <xsl:param name="formats-to-exclude">fmt/5,fmt/133,fmt/199,fmt/200,fmt/425,fmt/441,x-fmt/384,x-fmt/385,x-fmt/386</xsl:param>
    <xsl:variable name="formatArray" select="tokenize($formats-to-exclude,',')"/>

<!--    <xsl:param name="mime-types-to-exclude">video/x-msvideo:video/x-ms-wmv:application/mp4, video/mp4:application/mxf:Video Object File (MPEG-2 subset):Windows Media Video 9 Advanced Profile (WVC1):video/quicktime:-->
<!--        video/mpeg:video/mpeg</xsl:param>-->
<!--    <xsl:variable name="mimeArray" select="tokenize($mime-types-to-exclude,':')"/>-->

    <xsl:template match="/">
         <xsl:apply-templates/>
    </xsl:template>

    <xsl:template match="Replica">
        <xsl:choose>
            <xsl:when test="count(Folios/Folio/DigitalFiles/DigitalFile) = 1">
                <xsl:if test="not(Folios/Folio/DigitalFiles/DigitalFile[1]/DigitalFilePUID = $formatArray)">
                    <xsl:element name="Replica">
                        <xsl:apply-templates/>
                    </xsl:element>
                </xsl:if>
            </xsl:when>
            <xsl:otherwise>
                <xsl:element name="Replica">
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="DigitalFile">
        <xsl:if test="not(DigitalFilePUID = $formatArray)">
            <xsl:element name="DigitalFile">
                <xsl:apply-templates/>
            </xsl:element>
        </xsl:if>
    </xsl:template>


    <xsl:template match="node()|@*" >
        <xsl:copy>
            <xsl:apply-templates select="node()|@*"/>
        </xsl:copy>
    </xsl:template>

</xsl:stylesheet>