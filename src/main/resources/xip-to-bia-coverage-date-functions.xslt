<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:functx="http://www.functx.com"
                xmlns:fcd="http://xip-bia/functions/coverage-date"   >

    <xsl:include href="functx.xslt"/>

    <xsl:function name="fcd:extract-full-start-date">
        <xsl:param name="date"/>
        <xsl:choose>
            <xsl:when test="$date castable as xs:dateTime">
                <xsl:value-of select="$date"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:variable name="trimmed" select="fcd:trim-coverage-date($date)"/>
                <xsl:choose>
                    <xsl:when test="contains($trimmed,'-')">
                        <xsl:copy-of select="fcd:expand-to-full-date(fcd:standardise-date(substring-before($trimmed, '-')), true())"></xsl:copy-of>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:copy-of select="fcd:expand-to-full-date(fcd:standardise-date($trimmed), true())"></xsl:copy-of>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>

    <xsl:function name="fcd:extract-full-end-date">
        <xsl:param name="date"/>
        <xsl:choose>
        <xsl:when test="$date castable as xs:dateTime">
            <xsl:value-of select="$date"/>
        </xsl:when>
        <xsl:otherwise>
        <xsl:variable name="trimmed" select="fcd:trim-coverage-date($date)"/>
        <xsl:choose>
            <xsl:when test="contains($trimmed,'-')">
                <xsl:copy-of select="fcd:expand-to-full-date(fcd:standardise-date(substring-after($trimmed, '-')), false())"></xsl:copy-of>
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy-of select="fcd:expand-to-full-date(fcd:standardise-date($trimmed), false())"></xsl:copy-of>
            </xsl:otherwise>
        </xsl:choose>
        </xsl:otherwise>
        </xsl:choose>

    </xsl:function>

    <xsl:function name="fcd:expand-to-full-date">
        <xsl:param name="date"/>
        <xsl:param name="start"/>
        <xsl:choose>
            <xsl:when test="contains($date,' ')">
                <xsl:variable name="month-day" select="fcd:add-day-if-not-present(substring-after($date,' '),
                 substring-before($date,' '),$start)"/>
                <xsl:copy-of select="concat(concat(substring-before($date,' '),' '),$month-day)"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:choose>
                    <xsl:when test="$start">
                        <xsl:sequence select="concat($date,' Jan 01')"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:sequence select="concat($date,' Dec 31')"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>


    <xsl:function name="fcd:add-day-if-not-present">
        <xsl:param name="month-and-day"/>
        <xsl:param name="year"/>
        <xsl:param name="start"/>
        <xsl:choose>
            <xsl:when test="contains($month-and-day,' ')">
                <xsl:sequence select="concat(concat(substring-before($month-and-day,' '),' '),
                  substring-after($month-and-day,' '))"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:choose>
                    <xsl:when test="$start">
                        <xsl:sequence
                                select="concat($month-and-day,' 01')"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:variable name="last-day" select="fcd:last-day($year,$month-and-day)"/>
                        <xsl:copy-of select="concat(concat($month-and-day,' '),$last-day)"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>

    <xsl:function name="fcd:trim-coverage-date">
        <xsl:param name="input"/>
        <xsl:variable name="trimmed-date">
            <xsl:choose>
                <xsl:when test="contains($input, '[')">
                    <xsl:copy-of select="fcd:trim-derive-and-estimate-characters($input)"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:copy-of select="$input"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:value-of select="fcd:three-letter-month-to-catalogue($trimmed-date)"/>
    </xsl:function>

    <xsl:function name="fcd:trim-derive-and-estimate-characters">
        <xsl:param name="input"/>
        <xsl:choose>
            <xsl:when test="contains($input,'[')">
                <xsl:choose>
                    <xsl:when test="fcd:contains-any($input,'[c,[? ',',')">
                        <xsl:copy-of select="replace(substring($input,4),'\]','')"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:copy-of select="replace(substring($input,2),'\]','')"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy-of select="$input"/>
            </xsl:otherwise>
        </xsl:choose>

    </xsl:function>


    <xsl:function name="fcd:last-day">
        <xsl:param name="year"/>
        <xsl:param name="month"/>
        <xsl:variable name="date" select="xs:date(concat(concat(concat($year,'-'),fcd:month-to-index($month)),'-01'))"/>
        <xsl:variable name="last-day" select="functx:days-in-month($date)"/>
        <xsl:copy-of select="functx:pad-integer-to-length($last-day, 2)"/>
    </xsl:function>


    <xsl:function name="fcd:month-to-index">
        <xsl:param name="mo"></xsl:param>
        <xsl:variable name="month">
            <xsl:choose>
                <xsl:when test="$mo = 'Jan'">01</xsl:when>
                <xsl:when test="$mo = 'Feb'">02</xsl:when>
                <xsl:when test="$mo = 'Mar'">03</xsl:when>
                <xsl:when test="$mo = 'Apr'">04</xsl:when>
                <xsl:when test="$mo = 'May'">05</xsl:when>
                <xsl:when test="$mo = 'Jun'">06</xsl:when>
                <xsl:when test="$mo = 'June'">06</xsl:when>
                <xsl:when test="$mo = 'Jul'">07</xsl:when>
                <xsl:when test="$mo = 'July'">07</xsl:when>
                <xsl:when test="$mo = 'Aug'">08</xsl:when>
                <xsl:when test="$mo = 'Sept'">09</xsl:when>
                <xsl:when test="$mo = 'Oct'">10</xsl:when>
                <xsl:when test="$mo = 'Nov'">11</xsl:when>
                <xsl:when test="$mo = 'Dec'">12</xsl:when>
                <xsl:otherwise>
                    <xsl:message terminate="yes" select="concat('Cannot determine month from: ', $mo)"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:value-of select="$month"/>
    </xsl:function>

    <xsl:function name="fcd:contains-any">
        <xsl:param name="input"/>
        <xsl:param name="compare-string"></xsl:param>
        <xsl:param name="separator"/>
        <xsl:variable name="next" select="substring-after($compare-string,$separator)"/>
        <xsl:choose>
            <xsl:when test="string-length($next) = 0">
                <xsl:sequence select="contains($input, $compare-string)"/>
            </xsl:when>
            <xsl:when test="contains($input, substring-after($compare-string,$separator))">
                <xsl:sequence select="true()"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence
                        select="fcd:contains-any($input,substring-before($compare-string,$separator),$separator)"></xsl:sequence>
            </xsl:otherwise>
        </xsl:choose>

    </xsl:function>


    <!-- converts a catalogue date that can be
    1915, 1915 Jan, 1915 Jan 01
    or Jan 1915, 01 Jan 1915
    or 01/Jan/1915 Jan/1915
    to a YYYY MM DD,  YYYY MM , YYYY-->
    <xsl:function name="fcd:standardise-date">
        <xsl:param name="partial_date" as="xs:string"/>
        <xsl:variable name="date" select="replace($partial_date,'/', ' ')"/>
        <xsl:variable name="date_segments" select="tokenize($date, ' ')"/>
        <xsl:variable name="has-day" select="count($date_segments) = 3"/>
        <xsl:variable name="has-month" select="count($date_segments) gt  1"/>
        <xsl:variable name="year-index" >
            <xsl:choose>
                <xsl:when test="string-length($date_segments[3]) = 4 and number($date_segments[3])" >
                    <xsl:value-of select="3"/>
                </xsl:when>
                <xsl:when test="string-length($date_segments[1]) = 4 and number($date_segments[1])">
                    <xsl:value-of select="1"/>
                </xsl:when>
                <xsl:when test="string-length($date_segments[2]) = 4 and number($date_segments[2])" >
                    <xsl:value-of select="2"/>
                </xsl:when>
            </xsl:choose>
        </xsl:variable>

        <xsl:variable name="year" select="$date_segments[number($year-index)]"/>


        <xsl:variable name="day">
            <xsl:choose>
                <xsl:when test="number($year-index)= 3">
                    <xsl:value-of select="$date_segments[1]"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$date_segments[3]"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="month">
            <xsl:choose>
                <xsl:when test="number($year-index)= 2">
                    <xsl:value-of select="fcd:three-letter-month-to-catalogue($date_segments[1])"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="fcd:three-letter-month-to-catalogue($date_segments[2])"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <xsl:variable name="date-with-month">
            <xsl:choose>
                <xsl:when test="$has-month">
                    <xsl:value-of select="concat($year ,' ',$month)"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$year"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <xsl:variable name="full-date">
            <xsl:choose>
                <xsl:when test="$has-day">
                    <xsl:value-of select="concat($date-with-month,' ',$day)"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$date-with-month"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:value-of select="$full-date"/>
    </xsl:function>

    <xsl:function name="fcd:three-letter-month-to-catalogue">
         <xsl:param name="mo"/>
          <xsl:variable name="jun-updated">
            <xsl:choose>
                <xsl:when test="contains($mo,'Jun') and not(contains($mo, 'June'))">
                    <xsl:value-of select="replace($mo,'Jun','June')"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$mo"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="jul-updated">
            <xsl:choose>
                <xsl:when test="contains($jun-updated,'Jul') and not(contains($jun-updated, 'July'))">
                    <xsl:value-of select="replace($jun-updated,'Jul','July')"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$jun-updated"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="sep-updated">
            <xsl:choose>
                <xsl:when test="contains($jul-updated,'Sep') and not(contains($jul-updated, 'Sept'))">
                    <xsl:value-of select="replace($jul-updated,'Sep','Sept')"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$jul-updated"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:value-of select="$sep-updated"/>
    </xsl:function>


</xsl:stylesheet>