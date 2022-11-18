<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:dc="http://purl.org/dc/terms/"
                xmlns:c="http://nationalarchives.gov.uk/dri/closure"
                xmlns:tna="http://nationalarchives.gov.uk/metadata/tna#"
                xmlns:tnaxm="http://nationalarchives.gov.uk/metadata/"
                xmlns:tnatrans="http://nationalarchives.gov.uk/dri/transcription"
                xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xip="http://www.tessella.com/XIP/v4"
                xpath-default-namespace="http://www.tessella.com/XIP/v4"
                exclude-result-prefixes="dc tna c tnaxm xip xsl" version="2.0">

    <xsl:import href="xip-to-bia-v4-base.xslt"/>
    <xsl:include href="xip-to-bia-deliverable-unit-top.xslt"/>
    <xsl:include href="xip-to-bia-deliverable-unit-bottom.xslt"/>

    <xsl:template match="XIP">
        <BIA>
            <xsl:message>
                <xsl:copy-of select="$directoriesDoc"/>
            </xsl:message>
            <xsl:apply-templates/>
        </BIA>
    </xsl:template>

    <xsl:template match="DeliverableUnit">
        <InformationAsset>
            <xsl:call-template name="deliverable-unit-top"/>
            <xsl:call-template name="deliverable-unit-scope-content"/>
            <xsl:call-template name="deliverable-unit-bottom"/>
        </InformationAsset>
        <xsl:call-template name="create-access-regulation">
            <xsl:with-param name="closure" select="Metadata/tna:metadata/c:closure"/>
            <xsl:with-param name="deliverable-unit-ref" select="DeliverableUnitRef"/>
        </xsl:call-template>
    </xsl:template>


    <xsl:template name="deliverable-unit-scope-content">
        <xsl:if test="exists(Metadata/tna:metadata/rdf:RDF/tna:DigitalFolder/tna:cataloguing)">
            <xsl:variable name="cataloguing" select="Metadata/tna:metadata/rdf:RDF/tna:DigitalFolder/tna:cataloguing"
                          as="node()"/>
            <xsl:variable name="is-sub-item" select="$cataloguing/tna:Cataloguing/tna:subItemIdentifier ne ''"/>
            <xsl:variable name="isItem"
                          select="$cataloguing/tna:Cataloguing/tna:itemIdentifier ne '' and not($is-sub-item)"/>
            <xsl:if test="$is-sub-item or $isItem">
                <xsl:element name="ScopeContent">
                    <xsl:element name="Description">
                        <xsl:choose>
                            <xsl:when test="$isItem">
                                <xsl:if test="$cataloguing/tna:Cataloguing/dc:description ne ''">
                                    <xsl:text>&lt;scopecontent&gt;</xsl:text>
                                    <xsl:text>&lt;p&gt;</xsl:text>
                                    <xsl:value-of select="$cataloguing/tna:Cataloguing/dc:description"/>
                                    <xsl:text>&lt;/p&gt;</xsl:text>
                                    <xsl:text>&lt;/scopecontent&gt;</xsl:text>
                                </xsl:if>
                            </xsl:when>
                            <xsl:when test="$is-sub-item">
                                <xsl:if test="Metadata/tna:metadata/rdf:RDF/tna:DigitalFolder/tna:transcription/tnatrans:Transcription">
                                    <xsl:variable name="transcription"
                                                  select="Metadata/tna:metadata/rdf:RDF/tna:DigitalFolder/tna:transcription/tnatrans:Transcription"/>
                                    <xsl:text>&lt;scopecontent&gt;</xsl:text>
                                    <xsl:call-template name="add-name">
                                        <xsl:with-param name="transcription" select="$transcription"/>
                                    </xsl:call-template>
                                    <xsl:call-template name="add-age">
                                        <xsl:with-param name="transcription" select="$transcription"/>
                                    </xsl:call-template>
                                    <xsl:call-template name="add-birth-location">
                                        <xsl:with-param name="transcription" select="$transcription"/>
                                    </xsl:call-template>
                                    <xsl:text>&lt;/scopecontent&gt;</xsl:text>
                                </xsl:if>
                            </xsl:when>
                        </xsl:choose>

                    </xsl:element>
                </xsl:element>
            </xsl:if>
        </xsl:if>

    </xsl:template>


    <xsl:template name="add-age">
        <xsl:param name="transcription" as="node()"/>
        <xsl:text>&lt;p&gt;</xsl:text>
        <xsl:text>Age: </xsl:text>
        <xsl:choose>
            <xsl:when test="$transcription/tnatrans:ageYears = '*'">
                <xsl:text>[unspecified].</xsl:text>
            </xsl:when>
            <xsl:when test="$transcription/tnatrans:ageMonths = '*'">
                <xsl:value-of select="$transcription/tnatrans:ageYears"/>
                <xsl:text> years.</xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$transcription/tnatrans:ageYears"/>
                <xsl:text> years </xsl:text>
                <xsl:value-of select="$transcription/tnatrans:ageMonths"/>
                <xsl:if test="$transcription/tnatrans:ageMonths = '1'">
                    <xsl:text> month.</xsl:text>
                </xsl:if>
                <xsl:if test="$transcription/tnatrans:ageMonths ne '1'">
                    <xsl:text> months.</xsl:text>
                </xsl:if>
           </xsl:otherwise>
        </xsl:choose>

        <xsl:text>&lt;/p&gt;</xsl:text>
    </xsl:template>


    <xsl:template name="add-birth-location">
        <xsl:param name="transcription"/>
        <xsl:variable name="parish">
            <xsl:choose>
                <xsl:when test="normalize-space($transcription/tnatrans:placeOfBirthParish) = ''">
                    <xsl:value-of select="'*'"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$transcription/tnatrans:placeOfBirthParish"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="town">
            <xsl:choose>
                <xsl:when test="normalize-space($transcription/tnatrans:placeOfBirthTown) = ''">
                    <xsl:value-of select="'*'"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$transcription/tnatrans:placeOfBirthTown"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="county">
            <xsl:choose>
                <xsl:when test="normalize-space($transcription/tnatrans:placeOfBirthCounty) = ''">
                    <xsl:value-of select="'*'"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$transcription/tnatrans:placeOfBirthCounty"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="country">
            <xsl:choose>
                <xsl:when test="normalize-space($transcription/tnatrans:placeOfBirthCountry) = ''">
                    <xsl:value-of select="'*'"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$transcription/tnatrans:placeOfBirthCountry"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="comments">
            <xsl:choose>
                <xsl:when test="normalize-space($transcription/tnatrans:comments) = ''">
                    <xsl:value-of select="'*'"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$transcription/tnatrans:comments"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <xsl:variable name="hasParish" select="$parish ne '*'"/>
        <xsl:variable name="hasTown" select="$town ne '*'"/>
        <xsl:variable name="hasCounty" select="$county ne '*'"/>
        <xsl:variable name="hasCountry" select="$country ne '*'"/>
        <xsl:variable name="hasComments" select="$comments  ne '*'"/>

        <xsl:text>&lt;p&gt;Place of birth: </xsl:text>
        <xsl:if test="$hasParish or $hasTown or $hasCountry or $hasCounty">
            <xsl:text>&lt;geogname role=&quot;placeOfBirth&quot;&gt;</xsl:text>
        </xsl:if>
        <xsl:if test="$hasParish">
            <xsl:value-of select="$parish"/>
        </xsl:if>
       <xsl:if test="$hasTown">
            <xsl:if test="$hasParish">
               <xsl:text>, </xsl:text>
            </xsl:if>
            <xsl:value-of select="$town"/>
        </xsl:if>
        <xsl:if test="$hasCounty">
            <xsl:if test="$hasParish or $hasTown">
                <xsl:text>, </xsl:text>
            </xsl:if>
            <xsl:value-of select="$county"/>
        </xsl:if>
        <xsl:if test="$hasCountry">
            <xsl:if test="$hasParish or $hasTown or $hasCounty">
                <xsl:text>, </xsl:text>
            </xsl:if>
            <xsl:value-of select="$country"/>
        </xsl:if>
        <xsl:if test="$hasParish or $hasTown or $hasCounty or $hasCountry ">
            <xsl:text>&lt;/geogname&gt;</xsl:text>
        </xsl:if>

        <xsl:if test="$hasComments">
            <xsl:if test="$hasParish or $hasTown or $hasCounty or $hasCountry">
                <xsl:text> </xsl:text>
            </xsl:if>
            <xsl:value-of select="$comments"/>
        </xsl:if>
        <xsl:if test="not($hasParish or $hasTown or $hasCounty or $hasCountry or $hasComments)">
            <xsl:text>[unspecified]</xsl:text>
        </xsl:if>
        <xsl:text>.</xsl:text>
        <xsl:text>&lt;/p&gt;</xsl:text>
     </xsl:template>


    <xsl:template name="add-name">
        <xsl:param name="transcription" as="node()"/>
         <xsl:variable name="forenames">
            <xsl:choose>
                <xsl:when test="normalize-space($transcription/tnatrans:forenames) = ''">
                    <xsl:value-of select="'*'"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$transcription/tnatrans:forenames/text()"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="surname">
            <xsl:choose>
                <xsl:when test="$transcription/tnatrans:surname/text() = ''">
                    <xsl:value-of select="'*'"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$transcription/tnatrans:surname/text()"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="forenamesOther">
            <xsl:choose>
                <xsl:when test="normalize-space($transcription/tnatrans:forenamesOther) = ''">
                    <xsl:value-of select="'*'"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$transcription/tnatrans:forenamesOther/text()"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="surnameOther">
            <xsl:choose>
                <xsl:when test="normalize-space($transcription/tnatrans:surnameOther) = ''">
                    <xsl:value-of select="'*'"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$transcription/tnatrans:surnameOther/text()"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <xsl:variable name="has-forename" select="$forenames ne '*'"/>
        <xsl:variable name="has-surname" select="$surname  ne '*'"/>
        <xsl:variable name="has-surname-other" select="$surnameOther  ne '*'"/>
        <xsl:variable name="has-forenames-other" select="$forenamesOther  ne '*'"/>

        <xsl:text>&lt;p&gt;Name: </xsl:text>

        <xsl:if test="$has-forename or $has-surname ">
            <xsl:text>&lt;persname&gt;</xsl:text>
            <xsl:if test="$has-forename">
                <xsl:text>&lt;emph altrenderer=&quot;forenames&quot;&gt;</xsl:text>
                <xsl:value-of select="$forenames"/>
                <xsl:text>&lt;/emph&gt;</xsl:text>
            </xsl:if>
            <xsl:if test="$has-surname">
                <xsl:if test="$has-forename">
                    <xsl:text> </xsl:text>
                </xsl:if>
                <xsl:text>&lt;emph altrenderer=&quot;surname&quot;&gt;</xsl:text>
                <xsl:value-of select="$surname"/>
                <xsl:text>&lt;/emph&gt;</xsl:text>
                <xsl:text>&lt;/persname&gt;</xsl:text>
            </xsl:if>
        </xsl:if>


        <xsl:if test="$has-forenames-other or $has-surname-other">
            <xsl:if test="$has-surname or $has-forename">
                <xsl:text> </xsl:text>
                <xsl:text>alias </xsl:text>
                <xsl:text>&lt;persname altrenderer=&quot;alias&quot;&gt;</xsl:text>

                <xsl:if test="$has-forenames-other or $has-forename">
                    <xsl:text>&lt;emph altrenderer=&quot;forenames&quot;&gt;</xsl:text>
                    <xsl:if test="$has-forenames-other">
                        <xsl:value-of select="$forenamesOther"/>
                    </xsl:if>
                    <xsl:if test="not($has-forenames-other) and $has-forename">
                        <xsl:value-of select="$forenames"/>
                    </xsl:if>
                    <xsl:text>&lt;/emph&gt;</xsl:text>
                </xsl:if>
            </xsl:if>

            <xsl:if test="$has-surname-other or $has-surname">
                <xsl:if test="$has-forenames-other or $has-forename">
                    <xsl:text> </xsl:text>
                </xsl:if>
                <xsl:text>&lt;emph altrenderer=&quot;surname&quot;&gt;</xsl:text>

                <xsl:if test="$has-surname-other">
                    <xsl:value-of select="$surnameOther"/>
                </xsl:if>
                <xsl:if test="not($has-surname-other) and $has-surname">
                    <xsl:value-of select="$surname"/>
                </xsl:if>
                <xsl:text>&lt;/emph&gt;</xsl:text>
             </xsl:if>
            <xsl:text>&lt;/persname&gt;</xsl:text>
        </xsl:if>

        <xsl:if test="not($has-surname or $has-forename or $has-forenames-other or $has-surname-other or $has-surname)">
            <xsl:text>[unspecified]</xsl:text>
        </xsl:if>

        <xsl:text>.&lt;/p&gt;</xsl:text>
    </xsl:template>


</xsl:stylesheet>