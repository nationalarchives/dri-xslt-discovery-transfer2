<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="xs xsl"
    version="2.0">
    
    <!-- removes the series level IA, and set's the ParentIAID of it's children to the the $parent-id -->
    
    <xsl:output indent="yes" encoding="UTF-8" omit-xml-declaration="no"/>
    <xsl:param name="parent-id" required="yes"/>
    
      
    <xsl:template match="InformationAsset">
        <xsl:variable name="currentIA" as="xs:string"><xsl:value-of select = "IAID/text()"/></xsl:variable>
        <xsl:variable name="relatedIA" as="xs:string"><xsl:value-of select = "concat(IAID/text(),'_1')"/></xsl:variable>
        
        <xsl:message select="$relatedIA"></xsl:message>
        <xsl:variable name="related-ia" select="/BIA/InformationAsset[IAID/text() eq $relatedIA]"/>
        <xsl:choose>
            <xsl:when test="ends-with($currentIA, '_1')">
                <xsl:copy>
                     <xsl:variable name="children" select="child::*" as="element()+"/>
                    <xsl:copy-of select="$children[position() lt index-of($children/local-name(.), 'PhysicalCondition')]"/>
                    <xsl:copy-of select="$children[position() gt index-of($children/local-name(.), 'PhysicalCondition') and position() le index-of($children/local-name(.), 'Arrangement')]"/>
                     <RelatedMaterials>
                         <RelatedMaterial>
                             <Description>This is a repaired version of a corrupt record. To make a Freedom of Information request for the original record go to</Description>
                             <IAID><xsl:value-of select="tokenize($currentIA, '_')[1]"/></IAID>
                         </RelatedMaterial>
                     </RelatedMaterials>
                     <xsl:copy-of select="$children[position() gt index-of($children/local-name(.), 'Arrangement')]"/>
                 </xsl:copy>
            </xsl:when>
            <xsl:when test="$related-ia">
                <xsl:copy>
                    <xsl:variable name="children" select="child::*" as="element()+"/>
                    <xsl:copy-of select="$children[position() lt index-of($children/local-name(.), 'BatchId')]"/>
                    <RelatedMaterials>
                        <RelatedMaterial>
                            <Description>To see a repaired version of this record go to</Description>
                            <IAID><xsl:value-of select="$related-ia/IAID/text()"/></IAID>
                        </RelatedMaterial>
                    </RelatedMaterials>
                    <xsl:copy-of select="$children[position() ge index-of($children/local-name(.), 'BatchId')]"/>
                </xsl:copy>
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