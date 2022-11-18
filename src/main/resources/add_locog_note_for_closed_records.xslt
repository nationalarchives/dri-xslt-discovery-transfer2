<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="xs xsl"
    version="2.0">
  
    <xsl:output indent="yes" encoding="UTF-8" omit-xml-declaration="no"/>

    <!-- Add another text in front of a note if the record is closed -->
    <xsl:template match="HeldBy">
        <xsl:copy-of select="."/>

            <xsl:if test="../ClosureType/text() != 'A'">
                <xsl:element name="Note">
                    <xsl:text>&lt;p&gt;</xsl:text>
                    <xsl:text>These records were taken under special agreement with LOCOG and the British Olympic Authority (BOA) with a 15 year closure from 26 November 2012 (which was the date of transfer to The National Archives). Therefore the record opening date for these files is 27 November 2027.</xsl:text>
                    <xsl:text>&lt;/p&gt;</xsl:text>

                    <xsl:if test="../Note/text()  and ../Note/text() != ''">
                        <xsl:text>&lt;p&gt;</xsl:text>
                        <xsl:value-of select="../Note/text()"/>
                        <xsl:text>&lt;/p&gt;</xsl:text>    
                    </xsl:if>
                    
                </xsl:element>
            </xsl:if>
    </xsl:template>

    <!-- if the record is open, just copy the note unchanged. -->
    <xsl:template match="Note">
        <xsl:if test="../ClosureType/text() = 'A'">
            <xsl:element name="Note">
                <xsl:value-of select="text()"/>
            </xsl:element>
        </xsl:if>
    </xsl:template>

      
    <xsl:template match="node()|@*">
        <xsl:copy>
            <xsl:apply-templates select="node()|@*"/>
        </xsl:copy>
    </xsl:template>
    
    
</xsl:stylesheet>