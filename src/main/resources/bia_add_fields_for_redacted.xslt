<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                exclude-result-prefixes="xs xsl"
                version="2.0">

    <!-- removes the series level IA, and set's the ParentIAID of it's children to the the $parent-id -->

    <xsl:output indent="yes" encoding="UTF-8" omit-xml-declaration="no"/>
    <xsl:param name="parent-id" required="yes"/>


    <xsl:template match="InformationAsset">
        <xsl:variable name="currentIA" as="xs:string">
            <xsl:value-of select="IAID/text()"/>
        </xsl:variable>
        <xsl:variable name="related-ia"
                      select="/BIA/InformationAsset[matches(IAID/text() , concat($currentIA,'_\d'))]"/>

        <xsl:choose>
            <!-- Is this a redacted record  -->
            <xsl:when test="matches($currentIA,'.*_\d')">
                <xsl:copy>
                    <xsl:variable name="children" select="child::*" as="element()+"/>

                    <xsl:choose>
                        <xsl:when test="RelatedMaterials !=''">
                            <xsl:copy-of select="$children[position() le index-of($children/local-name(.), 'RelatedMaterials') -1]"/>
                            <xsl:element name="RelatedMaterials">
                            <xsl:copy-of select="RelatedMaterials/*"/>
                            <RelatedMaterial>
                                <xsl:choose>
                                    <xsl:when test="ClosureType eq 'F' ">
                                        <Description>This is a redacted record. The full record is retained. To make a Freedom of Information request for the full record contact the creating department.</Description>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <Description>This is a redacted record. To make a Freedom of Information request for the full record go to</Description>
                                    </xsl:otherwise>
                                </xsl:choose>
                                <IAID>
                                    <xsl:value-of select="tokenize($currentIA, '_')[1]"/>
                                </IAID>
                            </RelatedMaterial>
                            </xsl:element>
                            <xsl:copy-of select="$children[position() gt index-of($children/local-name(.), 'RelatedMaterials') ]"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:copy-of select="$children[position() le index-of($children/local-name(.), 'Arrangement') -1]"/>
                            <RelatedMaterials>
                                <RelatedMaterial>
                                    <xsl:choose>
                                        <xsl:when test="ClosureType eq 'F' ">
                                            <Description>This is a redacted record. The full record is retained. To make a Freedom of Information request for the full record contact the creating department.</Description>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <Description>This is a redacted record. To make a Freedom of Information request for the full record go to</Description>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                    <IAID>
                                        <xsl:value-of select="tokenize($currentIA, '_')[1]"/>
                                    </IAID>
                                </RelatedMaterial>
                            </RelatedMaterials>
                            <xsl:copy-of select="$children[position() gt index-of($children/local-name(.), 'Arrangement') -1]"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:copy>
             </xsl:when>
            <xsl:when test="$related-ia">
                <xsl:copy>
                    <xsl:variable name="children" select="child::*" as="element()+"/>

                    <xsl:choose>
                        <xsl:when test="RelatedMaterials !=''">
                             <xsl:copy-of select="$children[position() lt index-of($children/local-name(.), 'RelatedMaterials')]"/>
                              <xsl:element name="RelatedMaterials">
                                  <xsl:copy-of select="RelatedMaterials/*"/>
                                  <xsl:for-each select="$related-ia">
                                      <RelatedMaterial>
                                          <xsl:choose>
                                              <xsl:when test="ClosureType eq 'F' ">
                                                  <Description>To see a closed redacted version of this record go to</Description>
                                              </xsl:when>
                                              <xsl:otherwise>
                                                  <Description>To see an open redacted version of this record go to</Description>
                                              </xsl:otherwise>
                                          </xsl:choose>
                                          <IAID>
                                              <xsl:value-of select="IAID"/>
                                          </IAID>
                                      </RelatedMaterial>
                                  </xsl:for-each>
                              </xsl:element>
                           <xsl:copy-of select="$children[position() gt index-of($children/local-name(.), 'RelatedMaterials')]"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:copy-of select="$children[position() lt index-of($children/local-name(.), 'Arrangement')] "/>
                            <RelatedMaterials>
                                <xsl:for-each select="$related-ia">
                                    <RelatedMaterial>
                                        <xsl:choose>
                                            <xsl:when test="ClosureType eq 'F' ">
                                                <Description>To see a closed redacted version of this record go to</Description>
                                            </xsl:when>
                                            <xsl:otherwise>
                                                <Description>To see an open redacted version of this record go to</Description>
                                            </xsl:otherwise>
                                        </xsl:choose>
                                        <IAID>
                                            <xsl:value-of select="IAID"/>
                                        </IAID>
                                    </RelatedMaterial>
                                </xsl:for-each>
                            </RelatedMaterials>
                           <xsl:copy-of select="$children[position() ge index-of($children/local-name(.), 'Arrangement')]"/>
                        </xsl:otherwise>
                    </xsl:choose>
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