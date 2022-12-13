Feature: For export a bia is created by applying an export xslt to the collection xip

  Scenario: Use the export-adm158.xslt to add the scope content age for discovery
    The csv contains two age fields age_years and age_months
    If both fileds have * then output Age: [unspecified].
    If only years Age: XX years.
    Else either Age: XX years 1 month. or Age: XX years X months.
    When I apply XSLT export-adm158.xslt on src/test/resources/adm-158-sip.xml and output {workingDir}/bia.xml and parameters:
      | parent-id            | 101aa1aa-11a1-411a-aaa1-aa1a11a1111a                  |
      | droid-signature-file | ../../test/resources/DROID_SignatureFile_V73.xml      |
      | directories          | ../../test/resources/directories.xml                  |
    Then I want to validate XML {workingDir}/bia.xml with xpath:
      | xpath                                                                                                                                                | value       |
      | contains(//InformationAsset[Reference = 'ADM 158/193/1/10']//Description,'p>Age: 18 years 6 months.<')                                               |  true       |
      | contains(//InformationAsset[Reference = 'ADM 158/193/2/2']//Description,'p>Age: 13 years 1 month.<')                                                 |  true       |
      | contains(//InformationAsset[Reference = 'ADM 158/193/2/8']//Description,'p>Age: 22 years.<')                                                         |  true       |
      | contains(//InformationAsset[Reference = 'ADM 158/193/2/11']//Description,'p>Age: [unspecified].<')                                                   |  true       |

  Scenario: Use the export-adm158.xslt to add the scope content place of birth for discovery
    The csv contains four place of birth fields pob_parish, pob_town, pob_county, pob_country and 'comments'
    If all fileds have * then output Place of birth: [unspecified].
    If some of the fields have * then ignore and  concat others Place of birth: Birmingham, Warwickshire.
    or Place of birth: Odiham, Odiham, Hampshire.
    If comments must be at end Place of birth: Odiham, Odiham, Hampshire [as recorded on the document].
    Will be tagged for discovery <geogname role="placeOfBirth">
    When I apply XSLT export-adm158.xslt on src/test/resources/adm-158-sip.xml and output {workingDir}/bia.xml and parameters:
      | parent-id            | 101aa1aa-11a1-411a-aaa1-aa1a11a1111a                  |
      | droid-signature-file | ../../test/resources/DROID_SignatureFile_V73.xml      |
      | directories          | ../../test/resources/directories.xml                  |
    Then I want to validate XML {workingDir}/bia.xml with xpath:
      | xpath                                                                                                                                                | value       |
      | contains(//InformationAsset[Reference = 'ADM 158/193/2/10']//Description,'Place of birth: [unspecified].<')                                          |  true       |
      | contains(//InformationAsset[Reference = 'ADM 158/193/2/9']//Description,'Name: [unspecified].<')                                                     |  true       |
      | contains(//InformationAsset[Reference = 'ADM 158/193/1/3']//Description,'>Putney, Surrey</geogname>.<')                                              |  true       |
      | contains(//InformationAsset[Reference = 'ADM 158/193/1/16']//Description,'placeOfBirth">Birmingham, Warwickshire</geogname>.</p>')                   |  true       |
      | contains(//InformationAsset[Reference = 'ADM 158/193/1/10']//Description,'South Petherton, Ilminster, Somerset</geogname>.<')                        |  true       |
      | contains(//InformationAsset[Reference = 'ADM 158/193/1/5']//Description,'Odiham, Odiham, Hampshire</geogname> [as recorded on the document].')       |  true       |
      | contains(//InformationAsset[Reference = 'ADM 158/193/2/8']//Description,'Yateley, Odiham, Hampshire, England</geogname>.<')                          |  true       |


  Scenario: Use the export-adm158.xslt to add the scope name for discovery
    The csv contains four name fields forenames, surname, forenames_other and surname_other
    If all fields have * then output Name: [unspecified].
    If has alias, alias will be added
    If alias only forename only use alias forename with surname
    If alias only surname use forename + alias surname
    When I apply XSLT export-adm158.xslt on src/test/resources/adm-158-sip.xml and output {workingDir}/bia.xml and parameters:
      | parent-id            | 101aa1aa-11a1-411a-aaa1-aa1a11a1111a                  |
      | droid-signature-file | ../../test/resources/DROID_SignatureFile_V73.xml      |
      | directories          | ../../test/resources/directories.xml                  |
    Then I want to validate XML {workingDir}/bia.xml with xpath:
      | xpath                                                                                                    | value       |
      | contains(//InformationAsset[Reference = 'ADM 158/193/2/9']//Description,'Name: [unspecified].<')         |  true       |
      | contains(//InformationAsset[Reference = 'ADM 158/193/1/8']//Description,'forenames">Josiah<')            |  true       |
      | contains(//InformationAsset[Reference = 'ADM 158/193/1/8']//Description,'surname">Vaux<')                |  true       |
      | contains(//InformationAsset[Reference = 'ADM 158/193/1/8']//Description,' alias ')                       |  true       |
      | contains(//InformationAsset[Reference = 'ADM 158/193/1/8']//Description,'forenames">John<')              |  true       |
      | contains(//InformationAsset[Reference = 'ADM 158/193/1/8']//Description,'surname">Nicholson<')           |  true       |
      | contains(//InformationAsset[Reference = 'ADM 158/193/1/6']//Description,'Name: <persname><emph altrenderer="forenames">James</emph> <emph altrenderer="surname">Valantine</emph></persname> alias <persname altrenderer="alias"><emph altrenderer="forenames">James</emph> <emph altrenderer="surname">Walantines</emph></persname>.')           |  true       |
      | contains(//InformationAsset[Reference = 'ADM 158/193/1/8']//Description,'Name: <persname><emph altrenderer="forenames">Josiah</emph> <emph altrenderer="surname">Vaux</emph></persname> alias <persname altrenderer="alias"><emph altrenderer="forenames">John</emph> <emph altrenderer="surname">Nicholson</emph></persname>.')         |  true       |
      | contains(//InformationAsset[Reference = 'ADM 158/193/1/7']//Description,'Name: <persname><emph altrenderer="forenames">David</emph> <emph altrenderer="surname">Varley</emph></persname> alias <persname altrenderer="alias"><emph altrenderer="forenames">John</emph> <emph altrenderer="surname">Varley</emph></persname>.')           |  true       |

  Scenario: Use the export-adm158.xslt to add held by and legal status outside scope content
    When I apply XSLT export-adm158.xslt on src/test/resources/adm-158-sip.xml and output {workingDir}/bia.xml and parameters:
      | parent-id            | 101aa1aa-11a1-411a-aaa1-aa1a11a1111a                  |
      | droid-signature-file | ../../test/resources/DROID_SignatureFile_V73.xml      |
      | directories          | ../../test/resources/directories.xml                  |
    Then I want to validate XML {workingDir}/bia.xml with xpath:
      | xpath                                                                                                           | value                            |
      | //InformationAsset[Reference = 'ADM 158/193/1/10']/CoveringDates                                                |  [1818-1859]                     |
      | //InformationAsset[Reference = 'ADM 158/193/1/10']/HeldBy/HeldBy/Corporate_Body_Name_Text                       |  The National Archives, Kew      |
      | //InformationAsset[Reference = 'ADM 158/193/1/10']/LegalStatus                                                  |  Public Record                   |

  Scenario: Use the export-adm158.xslt item scope content will use the description row from the csv file
    When I apply XSLT export-adm158.xslt on src/test/resources/adm-158-sip.xml and output {workingDir}/bia.xml and parameters:
      | parent-id            | 101aa1aa-11a1-411a-aaa1-aa1a11a1111a                  |
      | droid-signature-file | ../../test/resources/DROID_SignatureFile_V73.xml      |
      | directories          | ../../test/resources/directories.xml                  |
    Then I want to validate XML {workingDir}/bia.xml with xpath:
      | xpath                                                                                                           | value                            |
      | contains(//InformationAsset[Reference = 'ADM 158/193/2']//Description,'Page 2. (The individual entries on the page are described at a lower catalogue level).')   |  true       |

  Scenario: Use the bia-filter-series.xslt to remove series level information assets
    When I apply XSLT export-adm158.xslt on src/test/resources/adm-158-sip.xml and output {workingDir}/bia.xml and parameters:
      | parent-id                     | 101aa1aa-11a1-411a-aaa1-aa1a11a1111a                  |
      | droid-signature-file          | ../../test/resources/DROID_SignatureFile_V73.xml      |
      | directories                   | ../../test/resources/directories.xml                  |
    Then I want to validate XML {workingDir}/bia.xml with xpath:
      | xpath                         | value     |
      | count(//InformationAsset)     |  34       |
    And I apply XSLT bia-filter-series.xslt on {workingDir}/bia.xml and output {workingDir}/no-series-bia.xml and parameters:
      | parent-id                     | 101aa1aa-11a1-411a-aaa1-aa1a11a1111a                  |
    Then I want to validate XML {workingDir}/no-series-bia.xml with xpath:
      | xpath                         | value     |
      | count(//InformationAsset)     |  33       |

