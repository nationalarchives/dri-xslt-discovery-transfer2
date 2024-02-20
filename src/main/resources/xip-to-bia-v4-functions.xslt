<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
        xmlns:c="http://nationalarchives.gov.uk/dri/closure"
        xmlns:dc="http://purl.org/dc/terms/"
        xmlns:dce="http://purl.org/dc/elements/1.1/"
        xmlns:fc="http://xip-bia/functions/common"
        xmlns:hg="http://nationalarchives.gov.uk/dataset/homeguard/metadata/"
        xmlns:tna="http://nationalarchives.gov.uk/metadata/tna#"
        xmlns:tnac="http://nationalarchives.gov.uk/catalogue/2007/"
        xmlns:tnacg="http://nationalarchives.gov.uk/catalogue/generated/2014/"
        xmlns:tnamp="http://nationalarchives.gov.uk/metadata/person/"
        xmlns:tnams="http://nationalarchives.gov.uk/metadata/spatial/"
        xmlns:tnaxm="http://nationalarchives.gov.uk/metadata/"
        xmlns:xip="http://www.tessella.com/XIP/v4"
        xmlns:xs="http://www.w3.org/2001/XMLSchema"
        xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
        xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
        xmlns:functx="http://www.functx.com"
        xmlns:fcd="http://xip-bia/functions/coverage-date"
        xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
        version="2.0">
    
    <!--
        Contains the common functions used by XIP-to-BIA transformation
        -->    
    
    <!--
        Requested by Emma Bayne on 2014-03-21
        - First Folder is at level 4
        - Everything else is 6+
    -->
    <xsl:include href="xip-to-bia-coverage-date-functions.xslt"/>

     <xsl:function name="fc:batch-id" as="xs:string">
        <xsl:param name="metadata" as="element(tnaxm:metadata)"/>
        <xsl:variable name="partIdentifier" select="$metadata/dc:isPartOf[@xsi:type eq 'tnaxmdc:partIdentifier']" as="element(dc:isPartOf)"/>
        <xsl:value-of select="concat($partIdentifier/tnaxm:part/tnaxm:unit, '/', $partIdentifier/tnaxm:part/tnaxm:series)"/>
    </xsl:function>
    
    <xsl:function name="fc:hg-batch-id" as="xs:string">
        <xsl:param name="metadata" as="element(tnaxm:metadata)"/>
        <xsl:value-of select="$metadata/dc:isPartOf[@xsi:type='tnacdc:batchIdentifier']"/>
    </xsl:function>
    
    <xsl:function name="fc:is-open-description" as="xs:boolean">
        <xsl:param name="metadata" as="element(tnaxm:metadata)"/>
        <xsl:value-of select="$metadata/c:closure/c:descriptionClosureStatus eq 'OPEN'"/>
    </xsl:function>
    
    <xsl:function name="fc:get-reference" as="xs:string">
        <xsl:param name="identifier" as="xs:string"/>
        <xsl:param name="reference" as="xs:string"/>
        <xsl:variable name="identifier"><xsl:value-of select="$identifier"/></xsl:variable>
        <xsl:choose>
            <!-- TODO must be changed for multiple manifestations -->
            <xsl:when test="ends-with($reference,'Z/1')">
                <xsl:value-of select="concat($identifier,'/Z/1')"/>        
            </xsl:when>
            <xsl:when test="ends-with($reference,'Z')">
                <xsl:value-of select="concat($identifier,'/Z')"/>        
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$identifier"/> 
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <xsl:function name="fc:get-digitized-identifier" as="element()">
        <xsl:param name="identifier" as="element()*"/>
        <xsl:copy-of select="$identifier[@xsi:type = ('tnacdc:pieceIdentifier', 'tnacdc:itemIdentifier')]"/>
    </xsl:function>
    
    <xsl:function name="fc:is-piece" as="xs:boolean">
        <xsl:param name="metadata" as="element(tnaxm:metadata)"/>
        <xsl:variable name="ident" select="fc:get-digitized-identifier($metadata/(dc:identifier|dce:identifier))"/>
        <xsl:value-of select="not(empty($ident[tnac:pieceCode][not(tnac:itemCode)]))"/>
    </xsl:function>
    
    <xsl:function name="fc:is-item" as="xs:boolean">
        <xsl:param name="metadata" as="element(tnaxm:metadata)"/>
        <xsl:variable name="ident" select="fc:get-digitized-identifier($metadata/(dc:identifier|dce:identifier))"/>
        <xsl:value-of select="not(empty($ident[tnac:pieceCode][tnac:itemCode]))"/>
    </xsl:function>
    
    <xsl:function name="fc:get-battalion" as="xs:string?">
        <xsl:param name="metadata" as="element(tnaxm:metadata)"/>
        <xsl:choose>
            <xsl:when test="fc:is-item($metadata)">
                <xsl:value-of select="$metadata/dc:references[@xsi:type='hgdc:battalion']"/>
            </xsl:when>
            <xsl:when test="fc:is-piece($metadata)">
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
    
    <xsl:function name="fc:born" as="xs:string">
        <xsl:param name="birth" as="element(tnamp:birth)"/>
        <xsl:value-of select="string-join((fc:born-dob($birth), fc:born-pob($birth/tnams:address))[string-length(.) gt 0], ', ')"/>
    </xsl:function>
    
    <xsl:function name="fc:born-pob" as="xs:string?">
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
    
    <xsl:function name="fc:born-dob" as="xs:string">
        <xsl:param name="birth" as="element(tnamp:birth)"/>
        <xsl:choose>
            <xsl:when test="not(empty($birth/tnamp:date))"><xsl:value-of select="concat(' - born ', fc:w3cdtf-to-uk-date($birth/tnamp:date))"/></xsl:when>
            <xsl:when test="not(empty($birth/tnamp:transcribedDateString))"><xsl:value-of select="concat(' - born ', $birth/tnamp:transcribedDateString)"/></xsl:when>
            <xsl:when test="not(empty($birth/tnamp:dateString))"><xsl:value-of select="concat(' - born ', $birth/tnamp:dateString)"/></xsl:when>
            <xsl:otherwise><xsl:value-of select="''"/></xsl:otherwise>
        </xsl:choose>
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
    
    <xsl:function name="fc:hg-title" as="xs:string">
        <xsl:param name="metadata" as="element(tnaxm:metadata)"/>
        <xsl:param name="catalogue-reference" as="element(xip:CatalogueReference)"/>
        
        <xsl:variable name="person" select="$metadata/dc:subject/hg:person" as="element(hg:person)?"/> <!-- TODO this is too home-guard specific -->
        <xsl:variable name="battalion" select="fc:get-battalion($metadata)"/>
        
        <xsl:choose>
            <xsl:when test="fc:is-piece($metadata)">
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
            <xsl:when test="fc:is-item($metadata)">
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
    
    <xsl:function name="fc:has-digitized-identifier" as="xs:boolean">
        <xsl:param name="identifier" as="element()*"/>
        <xsl:value-of select="$identifier/@xsi:type = ('tnacdc:pieceIdentifier', 'tnacdc:itemIdentifier')"/>
    </xsl:function>
    
    <xsl:function name="fc:hack-source-level-id" as="xs:integer">
        <xsl:param name="source-level-id" as="xs:integer"/>
        <xsl:choose>
            <xsl:when test="$source-level-id eq 2">3</xsl:when>
            <xsl:when test="$source-level-id eq 3">4</xsl:when>
            <xsl:when test="$source-level-id eq 4">6</xsl:when>
            <xsl:otherwise>
                6
                <!-- Removed after discussion with Aleks, 1.09.2014, discovery does not use the source level id from DRI. The classification above is only for paper collections -->
                <!-- <xsl:message terminate="yes" select="concat('Cannot hack source-level-id: ', $source-level-id)"/> -->
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <!--<xsl:function name="fc:get-digitized-identifier" as="element()">
        <xsl:param name="identifier" as="element()*"/>
        <xsl:copy-of select="$identifier[@xsi:type = ('tnacdc:pieceIdentifier', 'tnacdc:itemIdentifier')]"/>
    </xsl:function>-->
    
    <xsl:function name="fc:source-level-id" as="xs:integer?">
        <xsl:param name="catalogue-reference" as="element()"/>
        <xsl:choose>
            <xsl:when test="$catalogue-reference/tnac:itemCode">7</xsl:when>
            <xsl:when test="$catalogue-reference/tnac:pieceCode">6</xsl:when>
        </xsl:choose>
    </xsl:function>
    
    <xsl:function name="fc:get-source-level-id" as="xs:integer?">
        <xsl:param name="cataloguing" as="element()"/>
        <xsl:choose>
            <xsl:when test="$cataloguing/tna:itemIdentifier">7</xsl:when>
            <xsl:when test="$cataloguing/tna:pieceIdentifier">6</xsl:when>
            <xsl:when test="$cataloguing/tna:seriesIdentifier">3</xsl:when> <!-- TODO - this is a series but we need to check whether these should be transferred to Discovery -->
        </xsl:choose>
    </xsl:function>
    
    <xsl:function name="fc:to-discovery-closureStatus" as="xs:string">
        <xsl:param name="documentClosureStatus" as="element(c:documentClosureStatus)"/>
        <xsl:param name="descriptionClosureStatus" as="element(c:descriptionClosureStatus)*"/>
        <xsl:param name="titleClosureStatus" as="element(c:titleClosureStatus)*"/>
        <xsl:choose>
            <xsl:when test="$documentClosureStatus eq 'OPEN' and 
                ($descriptionClosureStatus eq 'OPEN' or string($descriptionClosureStatus) = '') and 
                ($titleClosureStatus eq 'OPEN'or string($titleClosureStatus) = '')">O</xsl:when>
            
            <xsl:when test="$documentClosureStatus eq 'CLOSED' and 
                ($descriptionClosureStatus eq 'OPEN' or $titleClosureStatus eq 'OPEN')">D</xsl:when>
            
            <xsl:when test="$documentClosureStatus eq 'CLOSED' and 
                ($descriptionClosureStatus eq 'CLOSED' or string($descriptionClosureStatus) = '') and
                ($titleClosureStatus eq 'CLOSED'or string($titleClosureStatus) = '')">C</xsl:when>
            <xsl:otherwise>UNKNOWN</xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <!-- <xsl:function name="fc:is-open-description" as="xs:boolean">
        <xsl:param name="metadata" as="element(tnaxm:metadata)"/>
        <xsl:value-of select="$metadata/c:closure/c:descriptionClosureStatus eq 'OPEN'"/>
    </xsl:function>-->
    
    <!-- converts xs:dateTime to format YYYYMMDD -->
    <xsl:function name="fc:dateTime-to-reverse-sequential-date" as="xs:string">
        <xsl:param name="date" as="xs:dateTime"/>
        <xsl:value-of select="format-dateTime($date, '[Y0001][M01][D01]')"/>
    </xsl:function>
    
    
    <xsl:function name="fc:zero-pad" as="xs:string">
        <xsl:param name="number"/>
        
        <xsl:choose>
            <xsl:when test="string-length($number) = 1">
                <xsl:value-of select="concat('0', $number)"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$number"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    
    <!-- converts a date that can be either iso or in a slash format or in a catalogue format like 1915, 1915 Jan, 1915 Jan 01 to a date-->
   
    <xsl:function name="fc:isoOrCatalogueDate-to-reverse-sequential-date-first" as="xs:string">
        <xsl:param name="isoOrCatalogueDate" as="xs:string"/>
         <xsl:choose>
             <xsl:when test ="($isoOrCatalogueDate  castable as xs:date )">
                 <xsl:value-of select="fc:dateTime-to-reverse-sequential-date(xs:dateTime($isoOrCatalogueDate))"/> 
            </xsl:when>
            <xsl:when test ="($isoOrCatalogueDate  castable as xs:dateTime )">
                <xsl:value-of select="fc:dateTime-to-reverse-sequential-date(xs:dateTime($isoOrCatalogueDate))"/>
            </xsl:when>
             <xsl:when test="fc:isSlashDate($isoOrCatalogueDate)">
                 <xsl:value-of select="fc:dateTime-to-reverse-sequential-date(fc:dateSlashToFormattedDateTime($isoOrCatalogueDate))"/>
             </xsl:when>
             
        <xsl:otherwise>
            <xsl:value-of select="fc:catalogueDate-to-reverse-sequential-date-start($isoOrCatalogueDate)"/>
        </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <!-- converts a catalogue date that can be either 1915, 1915 Jan, 1915 Jan 01 to a date-->
    <!--UKSC 25/11/2009-->
    <xsl:function name="fc:catalogueDate-to-reverse-sequential-date-start" as="xs:string">
        <xsl:param name="partial_date" as="xs:string"/>
        <xsl:variable name="date" select="fcd:standardise-date($partial_date)"/>
        <xsl:variable name="parts" select="tokenize($date, ' ')"/>
        <xsl:variable name="year" select="$parts[1]"/>
        <xsl:variable name="month" select="$parts[2]"/>
        <xsl:variable name="day" select="$parts[3]"/>
        <xsl:choose>
            <xsl:when test="string($day)">
                <xsl:value-of
                        select="format-date(fc:monthYearDay-to-date($year, $month, fc:zero-pad($day)), '[Y0001][M01][D01]')"/>
            </xsl:when>
            <xsl:when test="string($month)">
                <xsl:value-of select="format-date(fc:monthYearDay-to-date($year, $month, '01'), '[Y0001][M01][D01]')"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="format-date(fc:monthYearDay-to-date($year, 'Jan', '01'), '[Y0001][M01][D01]')"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>




   <xsl:function name="fc:isSlashDate" as="xs:boolean">
       <xsl:param name="date" as="xs:string"/>
       <xsl:value-of select="contains($date, '/')"/>
   </xsl:function>
    
   
    <xsl:function name="fc:dateSlashToFormattedDate" as="xs:string">
        <xsl:param name="partial_date" as="xs:string"/>
      <xsl:choose>
        <xsl:when test="contains($partial_date,'/')"> 
            <xsl:variable name="parts" select="tokenize($partial_date, '/')"/>
            <xsl:variable name="year" select="$parts[3]"/>
            <xsl:variable name="month" select="$parts[2]"/>
            <xsl:variable name="day" select="$parts[1]"/>
            
            <xsl:variable name = "full_date" as="xs:date">
                <xsl:value-of select="concat($year, '-', $month, '-', $day)"/>
            </xsl:variable>
            <xsl:value-of select="fc:date-to-pretty-reverse-sequential-date($full_date)"/>
        </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$partial_date"/>
            </xsl:otherwise>
      </xsl:choose>
    </xsl:function>

    <xsl:function name="fc:dateSlashToFormattedDateTime" as="xs:dateTime">
        <xsl:param name="partial_date" as="xs:string"/>
        <xsl:variable name="parts" select="tokenize($partial_date, '/')"/>
        <xsl:variable name="year" select="$parts[3]"/>
        <xsl:variable name="month" select="$parts[2]"/>
        <xsl:variable name="day" select="$parts[1]"/>
        <xsl:value-of select = "xs:dateTime(concat($year,'-',$month,'-', $day, 'T00:00:00'))"/>
    </xsl:function>
    
    <!-- converts a catalogue date that can be wither
    1915, 1915 Jan, 1915 Jan 01
    or Jan 1915, 01 Jan 1915
    or 01/Jan/1915 Jan/1915
    or an ISODate
    to a date-->
    <xsl:function name="fc:isoOrCatalogueDate-to-reverse-sequential-date-last" as="xs:string">
        <xsl:param name="isoOrCatalogueDate" as="xs:string"/>
        <xsl:choose>
            <xsl:when test ="($isoOrCatalogueDate  castable as xs:dateTime)">
                <xsl:value-of select="fc:dateTime-to-reverse-sequential-date(xs:dateTime($isoOrCatalogueDate))"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="fc:catalogueDate-to-reverse-sequential-date-last($isoOrCatalogueDate)"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <!-- converts a catalogue date that can be wither
    1915, 1915 Jan, 1915 Jan 01
    or Jan 1915, 01 Jan 1915
    or 01/Jan/1915 Jan/1915
    to a date-->
    <xsl:function name="fc:catalogueDate-to-reverse-sequential-date-last" as="xs:string">
        <xsl:param name="partial_date" as="xs:string"/>
        <xsl:variable name="date" select="fcd:standardise-date($partial_date)"/>
        <xsl:variable name="parts" select="tokenize($date, ' ')"/>
        <xsl:variable name="year" select="$parts[1]"/>
        <xsl:variable name="month" select="$parts[2]"/>
        <xsl:variable name="day" select="$parts[3]"/>
        
        <xsl:choose>
            <xsl:when test="string($day)">
                 <xsl:value-of select="format-date(fc:monthYearDay-to-date($year, $month, fc:zero-pad($day)), '[Y0001][M01][D01]')"/>
            </xsl:when>
            <xsl:when test="string($month)">
                <xsl:value-of select="format-date(functx:last-day-of-month(fc:monthYearDay-to-date($year, $month, '01')), '[Y0001][M01][D01]')"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="format-date(functx:last-day-of-month(fc:monthYearDay-to-date($year, 'Dec', '01')), '[Y0001][M01][D01]')"/>
            </xsl:otherwise>
        </xsl:choose>
     </xsl:function>
    
    
    <!-- converts month year (e.g. 1918 Jan) to format YYYYMMDD, last of the month -->
    <xsl:function name="fc:monthYear-to-reverse-sequential-date-last" as="xs:string">
        <xsl:param name="partial_date" as="xs:string"/>
        
        <xsl:variable name="parts" select="tokenize($partial_date, ' ')"/>
        <xsl:variable name="year" select="$parts[1]"/>
        <xsl:variable name="month" select="$parts[2]"/>
        <xsl:variable name="day" select="$parts[3]"/>
        
        <xsl:variable name="date" as="xs:date" select="fc:monthYearDay-to-date($year, $month, $day)"/>
        
        <xsl:variable name="last_date" as="xs:date" select="functx:last-day-of-month($date)"/>
        <xsl:value-of select="format-date($last_date, '[Y0001][M01][D01]')"/>
    </xsl:function>
   
    
    <!-- converts month year (e.g. 1918 Jan) to format YYYYMM01 -->  
    <xsl:function name="fc:monthYearDay-to-date" as="xs:date">
        <xsl:param name="year" as="xs:string"/>
        <xsl:param name="mo" as="xs:string"/>
        <xsl:param name="day" as="xs:string"/>
        <!--<xsl:variable name="mo">
            <xsl:value-of select="substring($partial_date, 6)"/>
        </xsl:variable>-->  
        <xsl:variable name="month" select="fcd:month-to-index($mo)"/>
            <xsl:variable name = "full_date">
            <xsl:value-of select="concat($year, '-', $month, '-', $day)"/>
        </xsl:variable>
        <xsl:value-of select="xs:date($full_date)"/>
    </xsl:function>
    
    <!-- converts xs:date to format YYYYMMDD -->
    <xsl:function name="fc:date-to-reverse-sequential-date" as="xs:string">
        <xsl:param name="date" as="xs:date"/>
        <xsl:value-of select="format-date($date, '[Y0001][M01][D01]')"/>
    </xsl:function>
    
    <!-- converts xs:dateTime to format YYYY Mmm DD -->       
     <xsl:function name="fc:dateTime-to-pretty-reverse-sequential-date" as="xs:string">
        <xsl:param name="date" as="xs:dateTime"/>
        <xsl:value-of select="fcd:three-letter-month-to-catalogue(format-dateTime($date, '[Y0001] [MNn,3-3] [D01]'))"/>
    </xsl:function>
    
    
    <xsl:function name="fc:date-to-pretty-reverse-sequential-date" as="xs:string">
        <xsl:param name="date" as="xs:date"/>
        <xsl:value-of select="fcd:three-letter-month-to-catalogue(format-date($date, '[Y0001] [MNn,3-3] [D01]'))"/>
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
    
    <xsl:function name="fc:has-born-digital-identifier" as="xs:boolean">
        <xsl:param name="identifier" as="element()*"/>
        <xsl:value-of select="$identifier/@xsi:type = 'tnacgdc:generatedReferenceIdentifier'"/>
    </xsl:function>
    
     <xsl:function name="fc:get-born-digital-identifier" as="element()">
        <xsl:param name="identifier" as="element()*"/>
        <xsl:copy-of select="$identifier[@xsi:type = 'tnacgdc:generatedReferenceIdentifier']"/>
    </xsl:function>
    
    <xsl:function name="fc:depth" as="xs:integer">
        <xsl:param name="deliverable-unit" as="element(xip:DeliverableUnit)?"/>
        <xsl:param name="depth" as="xs:integer"/>
        <xsl:choose>
            <xsl:when test="empty($deliverable-unit)">
                <xsl:value-of select="$depth"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:variable name="context" select="$deliverable-unit/parent::xip:DeliverableUnits"/>
                <xsl:variable name="parent-deliverable-unit" select="key('deliv-unit-by-deliverableunitref', $deliverable-unit/xip:ParentRef, $context)"/>
                <xsl:value-of select="fc:depth($parent-deliverable-unit, $depth + 1)"/>
            </xsl:otherwise>
        </xsl:choose>    
    </xsl:function>
    
    <xsl:function name="fc:reference" as="xs:string?">
        <xsl:param name="identifier" as="element()"/>
        <xsl:choose>
            <xsl:when test="$identifier[@xsi:type eq 'tnacgdc:generatedReferenceIdentifier']">
                <xsl:variable name="ident" select="$identifier[@xsi:type eq 'tnacgdc:generatedReferenceIdentifier']" as="element()"/>
                <!--
                    Alex Green requested on behalf of Emma Bayne
                    that the Z is prefixed with a '/'
                    for Generated Catalogue References
                    on 2014-04-04
                -->
                <!-- xsl:value-of select="string-join(($ident/tnacg:recordNumber, 'Z', $ident/tnacg:revisionNumber), ' ')"/ -->
                <xsl:value-of select="concat($ident/tnacg:recordNumber, '/', 'Z', $ident/tnacg:revisionNumber)"/>    
            </xsl:when>
            <xsl:when test="$identifier[@xsi:type = ('tnacdc:pieceIdentifier', 'tnacdc:itemIdentifier')]">
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
            </xsl:when>
        </xsl:choose>        
    </xsl:function>
    
    <xsl:function name="fc:title" as="xs:string">
        <xsl:param name="metadata" as="element(tnaxm:metadata)"/>
        <xsl:param name="fallback-title" as="element(xip:Title)"/>
        <xsl:choose>
            <xsl:when test="not(empty($metadata/dc:title)) and fc:is-open-description($metadata)"><xsl:value-of select="$metadata/dc:title"/></xsl:when>
            <xsl:otherwise><xsl:value-of select="$fallback-title"/></xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    
    <xsl:function name="fc:isBornDigitalReference" as="xs:boolean">
        <xsl:param name="reference" as="xs:string"/>
        <xsl:choose>
            <xsl:when test="ends-with($reference, '/Z') or contains($reference, '/Z/')">
                <xsl:value-of select="true()"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="false()"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>

    <xsl:function name="fc:legal-status-from-rdf">
        <xsl:param name="legal-status-resource" as="xs:string"/>
        <xsl:variable name="legal-status" select="lower-case($legal-status-resource)"/>
          <xsl:choose>
            <xsl:when test="contains($legal-status,'welsh_public_record(s)')">
                <xsl:value-of select="'Welsh Public Record(s)'"/>
            </xsl:when>
            <xsl:when test="contains($legal-status,'welsh_public_records')">
                <xsl:value-of select="'Welsh Public Records'"/>
            </xsl:when>
            <xsl:when test="contains($legal-status,'welsh_public_record')">
                <xsl:value-of select="'Welsh Public Record'"/>
            </xsl:when>
            <xsl:when test="contains($legal-status,'not_public_record(s)')">
                <xsl:value-of select="'Not Public Record(s)'"/>
            </xsl:when>
            <xsl:when test="contains($legal-status,'not_public_record')">
                <xsl:value-of select="'Not Public Record'"/>
            </xsl:when>
            <xsl:when test="contains($legal-status,'public_record(s)')">
                <xsl:value-of select="'Public Record(s)'"/>
            </xsl:when>
            <xsl:when test="contains($legal-status,'public_records')">
                <xsl:value-of select="'Public Records'"/>
            </xsl:when>
            <xsl:when test="contains($legal-status,'public_record')">
                <xsl:value-of select="'Public Record'"/>
            </xsl:when>
            <xsl:when test="contains($legal-status,'publicrecord')">
                <xsl:value-of select="'Public Record'"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:message select="concat('Invalid legal status',$legal-status-resource)" terminate="yes"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    
    <xsl:function name="fc:shouldHaveRestrictions" as="xs:boolean">
        <xsl:param name="restrictions" as="element()*"/>
        
        <xsl:variable name="restrictionsAttributesJoined">
            <xsl:value-of select="string-join($restrictions/@rdf:resource, '')"></xsl:value-of>
        </xsl:variable>
        <!-- for HomeGuard-->
        <xsl:variable name="restrictionsJoined">
            <xsl:value-of select="string-join($restrictions, '')"></xsl:value-of>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="lower-case(normalize-space($restrictionsAttributesJoined)) = 'http://datagov.nationalarchives.gov.uk/resource/crown_copyright'">
                <xsl:value-of select="false()"/>
            </xsl:when>
            <xsl:when test="lower-case(normalize-space($restrictionsJoined)) = 'crown copyright'">
                <xsl:value-of select="false()"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="true()"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
     
    <xsl:function name="fc:cataloguedFormattedDate" as="xs:string">
        <xsl:param name="date" as="xs:string"/>
        <xsl:choose>
            <xsl:when test="$date castable as xs:date">
                <xsl:value-of select= "fc:date-to-pretty-reverse-sequential-date(xs:date($date))"/>
            </xsl:when>
            <xsl:when test="fc:isSlashDate($date)">
                <xsl:value-of select="fc:dateSlashToFormattedDate($date)"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$date"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>

    <xsl:function name="fc:hasNoteText" as="xs:boolean">
        <xsl:param name="cataloguing" as="element()"/>
        <xsl:choose>
            <xsl:when test="$cataloguing/tna:note">
                <xsl:value-of select="true()"/>
            </xsl:when>
            <xsl:when test="$cataloguing/tna:curatedDateNote">
                <xsl:value-of select="true()"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="false()"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>

    <xsl:function name="fc:noteText" as="xs:string">
        <xsl:param name="cataloguing" as="element()"/>
        <xsl:variable name="note-text">
            <xsl:choose>
                <xsl:when test="$cataloguing/tna:note">
                    <xsl:value-of select="$cataloguing/tna:note"/>
                </xsl:when>
                <xsl:when test="$cataloguing/tna:curatedDateNote">
                    <xsl:value-of select="$cataloguing/tna:curatedDateNote"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="''"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:value-of select="$note-text"/>
    </xsl:function>

</xsl:stylesheet>