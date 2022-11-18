<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
        xmlns:ts="http://nationalarchives.gov.uk/xip-bia/functions/transcription-scope"
        xmlns:tnatrans="http://nationalarchives.gov.uk/dri/transcription"
        xmlns:xs="http://www.w3.org/2001/XMLSchema"
        xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
        xpath-default-namespace="http://www.tessella.com/XIP/v4"
        version="2.0">


    <xsl:template name="description-from-transcription">
        <xsl:param name="transcription" as="node()"/>
        <xsl:param name="description"/>
        <xsl:text>&lt;scopecontent&gt;</xsl:text>
        <xsl:call-template name="add-name">
            <xsl:with-param name="transcription" select="$transcription"/>
        </xsl:call-template>
        <xsl:call-template name="add-official-number">
            <xsl:with-param name="number" select="$transcription/tnatrans:officialNumber"/>
        </xsl:call-template>
        <xsl:call-template name="add-other-official-number">
            <xsl:with-param name="number" select="$transcription/tnatrans:otherOfficialNumber"/>
        </xsl:call-template>
        <xsl:call-template name="add-birthdate">
            <xsl:with-param name="transcription" select="$transcription"/>
        </xsl:call-template>
        <xsl:call-template name="add-birthplace">
            <xsl:with-param name="transcription" select="$transcription"/>
        </xsl:call-template>
        <xsl:call-template name="add-description">
            <xsl:with-param name="description" select="$description"/>
        </xsl:call-template>
        <xsl:text>&lt;/scopecontent&gt;</xsl:text>
    </xsl:template>

    <xsl:template name="add-birthdate">
        <xsl:param name="transcription"/>
        <xsl:variable name="date" select="ts:extract-birth-date($transcription)"/>
        <xsl:variable name="display-date">
            <xsl:choose>
                <xsl:when test="$date ne ''">
                    <xsl:value-of select="$date"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:copy-of select="'[unspecified]'"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:text>&lt;p&gt;Date of Birth: &lt;date type=&quot;dateOfBirth&quot;&gt;</xsl:text>
        <xsl:value-of select="$display-date"/>
        <xsl:text>&lt;/date&gt;.&lt;/p&gt;</xsl:text>
    </xsl:template>

    <xsl:template name="add-description">
        <xsl:param name="description"/>
        <xsl:if test="$description ne ''">
            <xsl:text>&lt;p&gt;</xsl:text>
            <xsl:value-of select="$description"/>
            <xsl:text>&lt;/p&gt;</xsl:text>
        </xsl:if>
    </xsl:template>

    <xsl:template name="add-birthplace">
        <xsl:param name="transcription"/>
        <xsl:variable name="place">
            <xsl:choose>
                <xsl:when test="ts:has-birthplace($transcription/tnatrans:placeOfBirth/text())">
                    <xsl:value-of select="$transcription/tnatrans:placeOfBirth"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:copy-of select="'[unspecified]'"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:text>&lt;p&gt;Place of Birth: &lt;geogname role=&quot;placeOfBirth&quot;&gt;</xsl:text>
        <xsl:value-of select="$place"/><xsl:text>&lt;/geogname&gt;.&lt;/p&gt;</xsl:text>
    </xsl:template>

    <xsl:function name="ts:has-birthplace">
        <xsl:param name="birthplace"/>
        <xsl:copy-of select="not(contains($birthplace,'*,'))"/>
    </xsl:function>

    <xsl:template name="add-name">
        <xsl:param name="transcription" as="node()"/>
        <xsl:variable name="forname" select="$transcription/tnatrans:forenames/text()"/>
        <xsl:variable name="surname" select="$transcription/tnatrans:surname/text()"/>
        <xsl:variable name="has-forename" select="$forname ne '' and $forname ne '*'"/>
        <xsl:variable name="has-surname" select="$surname ne '' and $surname ne '*'"/>
        <xsl:variable name="has-alias" select="ts:has-alias($transcription)"/>
        <xsl:text>&lt;p&gt;Name: </xsl:text>
        <xsl:choose>
            <xsl:when test="$has-alias or $has-forename or $has-surname">
                <xsl:text>&lt;persname&gt;</xsl:text>
                <xsl:if test="$has-forename">
                    <xsl:text>&lt;emph altrenderer=&quot;forenames&quot;&gt;</xsl:text>
                    <xsl:value-of select="$forname"/>
                    <xsl:text>&lt;/emph&gt;</xsl:text>
                </xsl:if>
                <xsl:if test="$has-surname">
                    <xsl:text>&lt;emph altrenderer=&quot;surname&quot;&gt;</xsl:text>
                    <xsl:value-of select="$surname"/>
                    <xsl:text>&lt;/emph&gt;</xsl:text>
                    <xsl:text>&lt;/persname&gt;</xsl:text>
                </xsl:if>
                <xsl:if test="$has-alias">
                     <xsl:call-template name="add-alias">
                         <xsl:with-param name="transcription" select="$transcription"/>
                    </xsl:call-template>
                </xsl:if>
                <xsl:text>.</xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text>[unspecified]</xsl:text>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:text>&lt;/p&gt;</xsl:text>
    </xsl:template>

    <xsl:template name="add-official-number">
        <xsl:param name="number"/>
        <xsl:if test="ts:has-official-number($number)">
            <xsl:text>&lt;p&gt;Official Number: &lt;num type=&quot;serviceNumber&quot;&gt;</xsl:text>
            <xsl:value-of select="$number"/>
            <xsl:text>&lt;/num&gt;.&lt;/p&gt;</xsl:text>
        </xsl:if>
    </xsl:template>

    <xsl:function name="ts:has-official-number" as="xs:boolean">
        <xsl:param name="number"/>
        <xsl:copy-of select="$number ne '' and $number ne '*'"/>
    </xsl:function>

    <xsl:template name="add-other-official-number">
        <xsl:param name="number"/>
        <xsl:if test="ts:has-other-official-number($number)">
            <xsl:text>&lt;p&gt;Other Official Number: &lt;num type=&quot;serviceNumber&quot;&gt;</xsl:text>
            <xsl:value-of select="$number"/>
            <xsl:text>&lt;/num&gt;.&lt;/p&gt;</xsl:text>
        </xsl:if>
    </xsl:template>

    <xsl:function name="ts:has-other-official-number" as="xs:boolean">
        <xsl:param name="number"/>
        <xsl:copy-of select="$number ne '' and $number ne '*'"/>
    </xsl:function>

    <xsl:template name="add-alias">
        <xsl:param name="transcription" as="node()"/>
        <xsl:variable name="forname" select="$transcription/tnatrans:forenames/text()"/>
        <xsl:variable name="surname" select="$transcription/tnatrans:surname/text()"/>
        <xsl:variable name="fornameOther" select="$transcription/tnatrans:forenamesOther/text()"/>
        <xsl:variable name="surnameOther" select="$transcription/tnatrans:surnameOther/text()"/>
        <xsl:variable name="fore">
            <xsl:choose>
                <xsl:when test="$fornameOther ne ''">
                    <xsl:value-of select="$fornameOther"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$forname"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="sur">
            <xsl:choose>
                <xsl:when test="$surnameOther ne ''">
                    <xsl:value-of select="$surnameOther"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$surname"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:text> alias </xsl:text>
        <xsl:text>&lt;persname altrenderer=&quot;alias&quot;&gt;</xsl:text>
        <xsl:text>&lt;emph altrenderer=&quot;forenames&quot;&gt;</xsl:text>
        <xsl:value-of select="$fore"/>
        <xsl:text>&lt;/emph&gt; </xsl:text>
        <xsl:text>&lt;emph altrenderer=&quot;surname&quot;&gt;</xsl:text>
        <xsl:value-of select="$sur"/>
        <xsl:text>&lt;/emph&gt;</xsl:text>
        <xsl:text>&lt;/persname&gt;</xsl:text>
    </xsl:template>

    <xsl:function name="ts:extract-birth-date">
        <xsl:param name="transcription" as="node()"/>
        <xsl:variable name="tday" select="$transcription/tnatrans:birthDateDay"/>
        <xsl:variable name="tmonth" select="$transcription/tnatrans:birthDateMonth"/>
        <xsl:variable name="tyear" select="$transcription/tnatrans:birthDateYear"/>
        <xsl:variable name="dday" select="$transcription/tnatrans:derivedBirthDateDay"/>
        <xsl:variable name="dmonth" select="$transcription/tnatrans:derivedBirthDateMonth"/>
        <xsl:variable name="dyear" select="$transcription/tnatrans:derivedBirthDateYear"/>
        <xsl:variable name="day">
            <xsl:choose>
                <xsl:when test="$dday ne ''">
                    <xsl:value-of select="concat('[',$dday,'] ')"/>
                </xsl:when>
                <xsl:when test="$tday castable as xs:double">
                    <xsl:value-of select="concat($tday,' ')"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:copy-of select="''"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="month">
            <xsl:choose>
                <xsl:when test="$dmonth ne ''">
                    <xsl:value-of select="concat('[',$dmonth,'] ')"/>
                </xsl:when>
                <xsl:when test="ts:is-month($tmonth)">
                    <xsl:value-of select="concat($tmonth,' ')"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:copy-of select="''"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="year">
            <xsl:choose>
                <xsl:when test="$dyear ne ''">
                    <xsl:value-of select="concat('[',$dyear,']')"/>
                </xsl:when>
                <xsl:when test="$tyear castable as xs:double">
                    <xsl:value-of select="$tyear"/>
                </xsl:when>
                <xsl:when test="$day ne '' or $month ne ''">
                    <xsl:copy-of select="'[remainder unspecified]'"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:copy-of select="''"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="$dday ne '' and  $dmonth ne '' and not($dyear)">
                <xsl:value-of select="concat('[', $dday, ' ', $dmonth, '] ', $year)"/>
            </xsl:when>
            <xsl:when test="not($dday) and  $dmonth ne '' and $dyear ne '' ">
                <xsl:value-of select="concat($day, '[',$dmonth, ' ', $dyear,']')"/>
            </xsl:when>
            <xsl:when test="$dday ne '' and  $dmonth ne '' and $dyear ne '' ">
                <xsl:value-of select="concat('[', $dday, ' ',$dmonth,' ', $dyear ,']')"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="concat($day,$month,$year)"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>

    <xsl:function name="ts:has-alias" as="xs:boolean">
        <xsl:param name="transcription" as="node()"/>
        <xsl:choose>
            <xsl:when test="$transcription/tnatrans:surnameOther ne '' or $transcription/tnatrans:forenamesOther ne ''">
                <xsl:value-of select="true()"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="false()"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>

    <xsl:function name="ts:is-month">
        <xsl:param name="mo"/>
        <xsl:variable name="month">
            <xsl:choose>
                <xsl:when test="$mo = 'Jan'">01</xsl:when>
                <xsl:when test="$mo = 'January'">01</xsl:when>
                <xsl:when test="$mo = 'Feb'">02</xsl:when>
                <xsl:when test="$mo = 'February'">02</xsl:when>
                <xsl:when test="$mo = 'Mar'">03</xsl:when>
                <xsl:when test="$mo = 'March'">03</xsl:when>
                <xsl:when test="$mo = 'Apr'">04</xsl:when>
                <xsl:when test="$mo = 'April'">04</xsl:when>
                <xsl:when test="$mo = 'May'">05</xsl:when>
                <xsl:when test="$mo = 'Jun'">06</xsl:when>
                <xsl:when test="$mo = 'June'">06</xsl:when>
                <xsl:when test="$mo = 'Jul'">07</xsl:when>
                <xsl:when test="$mo = 'July'">07</xsl:when>
                <xsl:when test="$mo = 'Aug'">08</xsl:when>
                <xsl:when test="$mo = 'August'">08</xsl:when>
                <xsl:when test="$mo = 'Sept'">09</xsl:when>
                <xsl:when test="$mo = 'September'">09</xsl:when>
                <xsl:when test="$mo = 'Oct'">10</xsl:when>
                <xsl:when test="$mo = 'October'">10</xsl:when>
                <xsl:when test="$mo = 'Nov'">11</xsl:when>
                <xsl:when test="$mo = 'November'">11</xsl:when>
                <xsl:when test="$mo = 'Dec'">12</xsl:when>
                <xsl:when test="$mo = 'December'">12</xsl:when>
                <xsl:otherwise>
                    <xsl:copy-of select="$mo"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:copy-of select="$month castable as xs:double"/>
    </xsl:function>
</xsl:stylesheet>