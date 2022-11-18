<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:functx="http://www.functx.com"
    version="2.0">
    
    <!--
        Contains functions in functx
        -->    
    
    <xsl:function name="functx:last-day-of-month" as="xs:date?"
        xmlns:functx="http://www.functx.com">
        <xsl:param name="date" as="xs:anyAtomicType?"/>
        
        <xsl:sequence select="
            functx:date(year-from-date(xs:date($date)),
            month-from-date(xs:date($date)),
            functx:days-in-month($date))
            "/>
        
    </xsl:function>
    
    <xsl:function name="functx:date" as="xs:date"
        xmlns:functx="http://www.functx.com">
        <xsl:param name="year" as="xs:anyAtomicType"/>
        <xsl:param name="month" as="xs:anyAtomicType"/>
        <xsl:param name="day" as="xs:anyAtomicType"/>
        
        <xsl:sequence select="
            xs:date(
            concat(
            functx:pad-integer-to-length(xs:integer($year),4),'-',
            functx:pad-integer-to-length(xs:integer($month),2),'-',
            functx:pad-integer-to-length(xs:integer($day),2)))
            "/>
        
    </xsl:function>
    

    
    
    <xsl:function name="functx:repeat-string" as="xs:string"
        xmlns:functx="http://www.functx.com">
        <xsl:param name="stringToRepeat" as="xs:string?"/>
        <xsl:param name="count" as="xs:integer"/>
        
        <xsl:sequence select="
            string-join((for $i in 1 to $count return $stringToRepeat),
            '')
            "/>
        
    </xsl:function>
    
    <xsl:function name="functx:pad-string-to-length" as="xs:string"
        xmlns:functx="http://www.functx.com">
        <xsl:param name="stringToPad" as="xs:string?"/>
        <xsl:param name="padChar" as="xs:string"/>
        <xsl:param name="length" as="xs:integer"/>
        
        <xsl:sequence select="
            substring(
            string-join (
            ($stringToPad, for $i in (1 to $length) return $padChar)
            ,'')
            ,1,$length)
            "/>
        
    </xsl:function>
    
    <xsl:function name="functx:pad-integer-to-length" as="xs:string"
        xmlns:functx="http://www.functx.com">
        <xsl:param name="integerToPad" as="xs:anyAtomicType?"/>
        <xsl:param name="length" as="xs:integer"/>
        
        <xsl:sequence select="
            if ($length &lt; string-length(string($integerToPad)))
            then error(xs:QName('functx:Integer_Longer_Than_Length'))
            else concat
            (functx:repeat-string(
            '0',$length - string-length(string($integerToPad))),
            string($integerToPad))
            "/>
        
    </xsl:function>
    
    
    <xsl:function name="functx:days-in-month" as="xs:integer?"
        xmlns:functx="http://www.functx.com">
        <xsl:param name="date" as="xs:anyAtomicType?"/>
        
        <xsl:sequence select="
            if (month-from-date(xs:date($date)) = 2 and
            functx:is-leap-year($date))
            then 29
            else
            (31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31)
            [month-from-date(xs:date($date))]
            "/>
        
    </xsl:function>
    
    
    <xsl:function name="functx:is-leap-year" as="xs:boolean"
        xmlns:functx="http://www.functx.com">
        <xsl:param name="date" as="xs:anyAtomicType?"/>
        
        <xsl:sequence select="
            for $year in xs:integer(substring(string($date),1,4))
            return ($year mod 4 = 0 and
            $year mod 100 != 0) or
            $year mod 400 = 0
            "/>
        
    </xsl:function>

</xsl:stylesheet>