Feature: DRI-161 Welsh collections contain file titles in English and Welsh. It is assumed the second title will be the English(translated version)

  Scenario: an item with an English language title will show in scope content. Welsh language will show in title
  Given the example collection of type born-digital for collection TEST1Y19HS002/TEST_1:
    And csv fields in file .*metadata.*csv are updated in collection TEST1Y19HS002/TEST_1:
      | rowId                 | column                                | value                                  |
      | d1f1                  | file_name                             | caerdydd editted.wma                   |
      | d1f1                  | file_name_translation                 | cardiff editted.wma                    |
    And I create the metadata with series TEST_1 unit TEST1Y19HS002 with xslt add-born-digital-metadata-to-sip_v2.2.xslt metadata metadata_TEST1Y19HS001.csv closure closure.csv
    When I apply XSLT export-welsh.xslt to metadata-with-closure.xml in collection TEST1Y19HS002/TEST_1 to output bia.xml with parameters:
      | parent-id            | 123                                                                             |
      | droid-signature-file | ../DROID_SignatureFile_V73.xml                                                  |
      | directories          | ../directories.xml                                                              |
    Then I want to validate XML bia.xml for collection TEST1Y19HS002/TEST_1:
      | xpath                | value                                                                           |
      | //InformationAsset[IAID = '1c8ee531-fd93-40f2-9862-906d01c2fd77']/Title      |  caerdydd editted.wma   |
      | //InformationAsset[IAID = '1c8ee531-fd93-40f2-9862-906d01c2fd77']/ScopeContent/Description    | <scopecontent>English translation of file name: cardiff editted.wma</scopecontent>    |
