Feature: CJ_4  Export
  Fields in Scope/Content(description) field in discovery
  Content management system container: Metadata taken from csv Content_management_system_container followed by a new line
  Business area: Metadata taken from csv Business_area followed by a new line
  Check CoveringDates is derived from endDate

  Scenario:CJ_4 fields exported to discovery
      Content management system container: BC3 Emergency Planning
      Business area: SPG
    Given the example collection of type born-digital for collection MUPT2Y17S001/MUPT_2:
    And csv fields in file .*metadata.*csv are updated in collection MUPT2Y17S001/MUPT_2:
      | rowId | column                              | value                  |
      | file1 | Content_management_system_container | BC3 Emergency Planning |
      | file1 | Business_area                       | SPG                    |
      | file1 | end_date                            | 1994-10-26T00:00:00    |
    And I create metadata xip for series MUPT_2 unit MUPT2Y17S001 with xslt add-born-digital-metadata-to-sip_v2.2.xslt metadata metadata_v9_MUPT2Y17HS001.csv closure closure_v7.csv
    When I apply XSLT export-cj4.xslt to metadata-with-closure.xml in collection MUPT2Y17S001/MUPT_2 to output bia.xml with parameters:
      | parent-id            | 123                                                                   |
      | droid-signature-file | ../DROID_SignatureFile_V73.xml                                        |
      | directories          | ../directories.xml                                                    |
    Then I want to validate XML bia.xml for collection MUPT2Y17S001/MUPT_2:
      | xpath                                                                                                                                    | value        |
      | contains(//InformationAsset[Title = 'FOZZIE.pdf']/ScopeContent/Description,'Business area: SPG')                                         | true         |
      | contains(//InformationAsset[Title = 'FOZZIE.pdf']/ScopeContent/Description,'Content management system container: BC3 Emergency Planning')| true         |
      | //InformationAsset[Title = 'FOZZIE.pdf']/CoveringDates                                                                                   | 1994 Oct 26  |

