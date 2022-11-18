<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:fdx = "http://xip-bia/functions/digitized"
    xmlns:fc="http://xip-bia/functions/common"    
    xmlns:dc="http://purl.org/dc/terms/"
    xmlns:dce="http://purl.org/dc/elements/1.1/"
    xmlns:hg="http://nationalarchives.gov.uk/dataset/homeguard/metadata/"
    xmlns:tnac="http://nationalarchives.gov.uk/catalogue/2007/"
    xmlns:tnamp="http://nationalarchives.gov.uk/metadata/person/"
    xmlns:tnams="http://nationalarchives.gov.uk/metadata/spatial/"
    xmlns:tnaxm="http://nationalarchives.gov.uk/metadata/"
    xmlns:xip="http://www.tessella.com/XIP/v4"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    exclude-result-prefixes="dc dce fc fdx hg tnac tnamp tnams tnaxm xip xs xsi"
    version="2.0">
    
    
    <xsl:key name="deliv-unit-by-parentref" match="xip:DeliverableUnit" use="xip:ParentRef"/>
    
    <!-- This XSLT is included into xip-to-bia_v3.xslt -->
    
    <xsl:output indent="yes" encoding="UTF-8" omit-xml-declaration="no"/>
    
    
    <xsl:function name="fdx:has-digitized-identifier" as="xs:boolean">
        <xsl:param name="identifier" as="element()*"/>
        <xsl:value-of select="$identifier/@xsi:type = ('tnacdc:pieceIdentifier', 'tnacdc:itemIdentifier')"/>
    </xsl:function>
    
    <xsl:function name="fdx:get-digitized-identifier" as="element()">
        <xsl:param name="identifier" as="element()*"/>
        <xsl:copy-of select="$identifier[@xsi:type = ('tnacdc:pieceIdentifier', 'tnacdc:itemIdentifier')]"/>
    </xsl:function>
    
    <xsl:function name="fdx:source-level-id" as="xs:integer?">
        <xsl:param name="catalogue-reference" as="element()"/>
        <xsl:choose>
            <xsl:when test="$catalogue-reference/tnac:itemCode">7</xsl:when>
            <xsl:when test="$catalogue-reference/tnac:pieceCode">6</xsl:when>
        </xsl:choose>
    </xsl:function>
    
    <xsl:function name="fdx:reference" as="xs:string">
        <xsl:param name="identifier" as="element()"/>
        <xsl:variable name="ident" select="$identifier[@xsi:type = ('tnacdc:pieceIdentifier', 'tnacdc:itemIdentifier')]" as="element()"/>
        <xsl:variable name="ref" as="xs:string">
            <xsl:choose>
                <xsl:when test="$ident/tnac:itemCode">
                    <xsl:value-of select="$ident/tnac:itemCode"/>
                </xsl:when>
                <xsl:when test="$ident/tnac:pieceCode">
                    <xsl:value-of select="$ident/tnac:pieceCode"/>
                </xsl:when>
                <xsl:otherwise>
                   <xsl:text>failed</xsl:text> 
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:value-of select="replace($ref, '_', '/')"/>
    </xsl:function>
    
    <xsl:function name="fdx:title" as="xs:string">
        <xsl:param name="metadata" as="element(tnaxm:metadata)"/>
        <xsl:param name="catalogue-reference" as="element(xip:CatalogueReference)"/>
        
        <xsl:variable name="person" select="$metadata/dc:subject/hg:person" as="element(hg:person)?"/> <!-- TODO this is too home-guard specific -->
        <xsl:variable name="battalion" select="fdx:get-battalion($metadata)"/>
        
        <xsl:choose>
            <xsl:when test="fdx:is-piece($metadata)">
                <xsl:choose>
                    <xsl:when test="empty($battalion) or string-length($battalion) eq 0">
                        <xsl:value-of select="$metadata/dc:spatial[@xsi:type='tnaxmdc:spatial']/tnams:postalAddress/tnams:county"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <!-- TODO this is Home Guard / war records specific - move to specific XSLT -->
                        <xsl:value-of select="concat($metadata/dc:spatial[@xsi:type='tnaxmdc:spatial']/tnams:postalAddress/tnams:county, ' ', $battalion, ' Battalion')"/>
                    </xsl:otherwise>
                    
                </xsl:choose>                    
            </xsl:when>
            <xsl:when test="fdx:is-item($metadata)">
                <xsl:choose>
                    <xsl:when test="fc:is-open-description($metadata)">
                        <xsl:value-of select="concat($person/tnamp:name/tnamp:namePart[@type = 'given'], ' ', $person/tnamp:name/tnamp:namePart[@type = 'familyName'])"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="$catalogue-reference"/>                        
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text>failed</xsl:text> 
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <xsl:template name="fdx:scope-content">
        <xsl:param name="metadata" as="element(tnaxm:metadata)" required="yes"/>
        
        <xsl:variable name="person" select="$metadata/dc:subject/hg:person" as="element(hg:person)?"/> <!-- TODO this is too home-guard specific -->
        <xsl:variable name="battalion" select="fdx:get-battalion($metadata)"/>
        
        <ScopeContent>
            <xsl:choose>
                
                <xsl:when test="fdx:is-piece($metadata)">
                    <xsl:choose>
                        <xsl:when test="empty($battalion) or string-length($battalion) eq 0">
                            <Organizations>
                                <string>Home Guard</string>
                            </Organizations>
                            <Description>Home Guard</Description>        
                        </xsl:when>
                        <xsl:otherwise>
                            <Organizations>
                                <string><xsl:value-of select="concat('Home Guard, ', $battalion, ' Battalion')"/></string>
                            </Organizations>
                            <Description><xsl:value-of select="concat('Home Guard, ', $battalion, ' Battalion')"/></Description>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                
                <xsl:when test="fdx:is-item($metadata)">
                    <xsl:if test="fc:is-open-description($metadata)">
                        <PersonName>
                            <string><xsl:value-of select="$person/tnamp:name/concat(tnamp:namePart[@type = 'given'], ' ', tnamp:namePart[@type = 'familyName'])"/></string>
                        </PersonName>
                        <PlaceName>
                            <string><xsl:value-of select="$metadata/dc:spatial[@xsi:type='tnaxmdc:spatial']/tnams:postalAddress/tnams:county"/></string>
                        </PlaceName>
                        <Organizations>
                            <string><xsl:value-of select="concat('Home Guard, ', $battalion, ' Battalion')"/></string>
                        </Organizations>
                        <Description><xsl:value-of select="$person/tnamp:name/concat(tnamp:namePart[@type = 'given'], ' ', tnamp:namePart[@type = 'familyName'], fdx:born($person/tnamp:birth), ' - ', $metadata/dc:spatial[@xsi:type='tnaxmdc:spatial']/tnams:postalAddress/tnams:county, ' Home Guard, ', $battalion, ' Battalion')"/></Description>
                    </xsl:if>
                </xsl:when>
            </xsl:choose>
        </ScopeContent>       
    </xsl:template>

    <xsl:template name="fdx:personal-names">
        <xsl:param name="metadata" as="element(tnaxm:metadata)" required="yes"/>
        
        <xsl:variable name="person" select="$metadata/dc:subject/hg:person" as="element(hg:person)?"/> <!-- TODO this is too home-guard specific -->
        
        <xsl:if test="not(empty($person))">
            <PersonalNames>
                <Person>
                    <Surname_Text><xsl:value-of select="$person/tnamp:name/tnamp:namePart[@type = 'familyName']"/></Surname_Text>
                    <Forename_Text><xsl:value-of select="$person/tnamp:name/tnamp:namePart[@type = 'given']"/></Forename_Text>
                    <xsl:if test="not(empty($person/tnamp:birth/tnamp:date)) and string-length($person/tnamp:birth/tnamp:date) != 0 and $person/tnamp:birth/tnamp:date castable as xs:date">
                        <Birth_Date><xsl:value-of select="$person/tnamp:birth/fc:date-to-reverse-sequential-date(tnamp:date)"/></Birth_Date>
                    </xsl:if>
                </Person>
            </PersonalNames>
        </xsl:if>
    </xsl:template>
    
    <xsl:template name="fdx:places">
        <xsl:param name="metadata" as="element(tnaxm:metadata)" required="yes"/>
        
        <xsl:variable name="person" select="$metadata/dc:subject/hg:person" as="element(hg:person)?"/> <!-- TODO this is too home-guard specific -->
        
        <Places>
            <xsl:choose>
                <xsl:when test="fdx:is-piece($metadata)">
                    <Place>
                        <county_text><xsl:value-of select="$metadata/dc:spatial[@xsi:type='tnaxmdc:spatial']/tnams:postalAddress/tnams:county"/></county_text>
                    </Place>
                </xsl:when>
                <xsl:when test="fdx:is-item($metadata)">
                    <xsl:if test="fc:is-open-description($metadata)">
                        <Place>
                            <county_text><xsl:value-of select="$metadata/dc:spatial[@xsi:type='tnaxmdc:spatial']/tnams:postalAddress/tnams:county"/></county_text>
                        </Place>
                        <xsl:if test="not(empty($person/tnams:address/tnams:addressString[string-length(.) gt 0]))">
                            <Place>
                                <Description><xsl:value-of select="$person/tnams:address/tnams:addressString"/></Description>
                            </Place>
                        </xsl:if>
                        <xsl:variable name="pob" select="fdx:born-pob($person/tnamp:birth/tnams:address)"/>
                        <xsl:if test="not(empty($pob)) and string-length($pob) gt 0">
                            <Place>
                                <Description><xsl:value-of select="$pob"/></Description>
                            </Place>
                        </xsl:if>
                    </xsl:if>
                </xsl:when>
            </xsl:choose>
        </Places>
    </xsl:template>
    
    <xsl:function name="fdx:batch-id" as="xs:string">
        <xsl:param name="metadata" as="element(tnaxm:metadata)"/>
        <xsl:value-of select="$metadata/dc:isPartOf[@xsi:type='tnacdc:batchIdentifier']"/>
    </xsl:function>
    
    <xsl:function name="fdx:is-piece" as="xs:boolean">
        <xsl:param name="metadata" as="element(tnaxm:metadata)"/>
        <xsl:variable name="ident" select="fdx:get-digitized-identifier($metadata/(dc:identifier|dce:identifier))"/>
        <xsl:value-of select="not(empty($ident[tnac:pieceCode][not(tnac:itemCode)]))"/>
    </xsl:function>
    
    <xsl:function name="fdx:is-item" as="xs:boolean">
        <xsl:param name="metadata" as="element(tnaxm:metadata)"/>
        <xsl:variable name="ident" select="fdx:get-digitized-identifier($metadata/(dc:identifier|dce:identifier))"/>
        <xsl:value-of select="not(empty($ident[tnac:pieceCode][tnac:itemCode]))"/>
    </xsl:function>
    
    <xsl:function name="fdx:get-battalion" as="xs:string?">
        <xsl:param name="metadata" as="element(tnaxm:metadata)"/>
        <xsl:choose>
            <xsl:when test="fdx:is-item($metadata)">
                <xsl:value-of select="$metadata/dc:references[@xsi:type='hgdc:battalion']"/>
            </xsl:when>
            <xsl:when test="fdx:is-piece($metadata)">
                <xsl:variable name="context" select="$metadata/ancestor::xip:DeliverableUnits"/>
                <xsl:choose>
                    <xsl:when test="not(empty($context))">
                        <xsl:value-of select="(key('deliv-unit-by-parentref', $metadata/ancestor::xip:DeliverableUnit/xip:DeliverableUnitRef, $context)/xip:Metadata/tnaxm:metadata/dc:references[@xsi:type eq 'hgdc:battalion'])[1]"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:message select="concat('Could not determine context for key() when attempting to find battalion for piece: ', $metadata/ancestor::xip:DeliverableUnit/xip:CatalogueReference)"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
        </xsl:choose>
    </xsl:function>
    
    <xsl:function name="fdx:born" as="xs:string">
        <xsl:param name="birth" as="element(tnamp:birth)"/>
        <xsl:value-of select="string-join((fdx:born-dob($birth), fdx:born-pob($birth/tnams:address))[string-length(.) gt 0], ', ')"/>
    </xsl:function>
    
    <xsl:function name="fdx:born-dob" as="xs:string">
        <xsl:param name="birth" as="element(tnamp:birth)"/>
        <xsl:choose>
            <xsl:when test="not(empty($birth/tnamp:date))"><xsl:value-of select="concat(' - born ', fc:w3cdtf-to-uk-date($birth/tnamp:date))"/></xsl:when>
            <xsl:when test="not(empty($birth/tnamp:transcribedDateString))"><xsl:value-of select="concat(' - born ', $birth/tnamp:transcribedDateString)"/></xsl:when>
            <xsl:when test="not(empty($birth/tnamp:dateString))"><xsl:value-of select="concat(' - born ', $birth/tnamp:dateString)"/></xsl:when>
            <xsl:otherwise><xsl:value-of select="''"/></xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <xsl:function name="fdx:born-pob" as="xs:string?">
        <xsl:param name="address" as="element(tnams:address)?"/>
        <xsl:if test="not(empty($address))">
            <xsl:choose>
                <xsl:when test="not(empty($address/tnams:addressString)) and string-length($address/tnams:addressString) gt 0">
                    <xsl:value-of select="$address/tnams:addressString"/>
                </xsl:when>
                <xsl:when test="not(empty($address/tnams:postalAddress))">
                    <xsl:value-of select="string-join($address/tnams:postalAddress, ', ')[string-length(.) gt 0]"/>
                </xsl:when>    
                <xsl:otherwise><xsl:value-of select="''"/></xsl:otherwise>
            </xsl:choose>
        </xsl:if>
    </xsl:function>

</xsl:stylesheet>