Feature: Discovery export requires fields from CSV metadata to be processed during an ingest and then used in the BIA.xml that
  contains a collection of Information assets to be transferred.
  There are 8  rows in the metadata that can be updated
    rowId     xpath for InformationAsset related to that row
    -----     ---------------------------------------------
    d1f1     //InformationAsset[Title = 'd1f1.tif']
    d1f2     //InformationAsset[Title = 'd1f2.tif']
    d1f3     //InformationAsset[Title = 'd1f3.tif']
    d2f1     //InformationAsset[Title = 'd2f1.tif']
    d2f2     //InformationAsset[Title = 'd2f2.tif']
    d2f3     //InformationAsset[Title = 'd2f2.tif']
    dir1     //InformationAsset[Title = 'dir1']
    dir2     //InformationAsset[Title = 'dir2']

  Scenario: CSV metadata is merged with the SIP, transformed as in a digitised workflow then exported to Discovery
    Given the example collection of type born-digital for collection TEST1Y19HS002/TEST_1:
    And csv fields in file .*metadata.*csv are updated in collection TEST1Y19HS002/TEST_1:
      | rowId                 | column                                | value                        |
      | d1f1                  | description                           | Give me a description        |
      | d1f1                  | curated_date_note                     | Curated Note                 |
      | d1f1                  | curated_date                          | 1993-2005                    |
      | d1f2                  | corporate_body                        | Inveresk                     |
      | d1f3                  | description                           | d1f3 description             |
      | d2f1                  | description                           | d2f1 description             |
      | d2f2                  | description                           | d2f2 description             |
      | d2f3                  | description                           | d2f3 description             |
      | dir1                  | description                           | dir1 description             |
      | dir2                  | description                           | dir2 description             |

    And I process the sip series TEST_1 unit TEST1Y19HS002 with xslt add-born-digital-metadata-to-sip_v2.2.xslt metadata metadata_TEST1Y19HS001.csv closure closure.csv
    When I apply XSLT xip-to-bia-v4-a.xslt to metadata-with-closure.xml in collection TEST1Y19HS002/TEST_1 to output bia.xml with parameters:
      | parent-id            | 123                                                 |
      | droid-signature-file | ../DROID_SignatureFile_V73.xml                      |
      | directories          | ../directories.xml                                  |
    Then I want to validate XML bia.xml for collection TEST1Y19HS002/TEST_1:
      | xpath                                                                                        | value                  |
      | //InformationAsset[Title = 'd1f1.tif']/ScopeContent/Description                              | Give me a description  |
      | //InformationAsset[Title = 'd1f1.tif']/Note                                                  | Curated Note           |
      | //InformationAsset[Title = 'd1f1.tif']/CoveringDates                                         | 1993-2005              |
      | //InformationAsset[Title = 'd1f2.tif']/CorporateNames/CorporateName/Corporate_Body_Name_Text | Inveresk               |
      | //InformationAsset[Title = 'd1f3.tif']/ScopeContent/Description                              | d1f3 description       |
      | //InformationAsset[Title = 'd2f1.tif']/ScopeContent/Description                              | d2f1 description       |
      | //InformationAsset[Title = 'd2f2.tif']/ScopeContent/Description                              | d2f2 description       |
      | //InformationAsset[Title = 'd2f3.tif']/ScopeContent/Description                              | d2f3 description       |
      | //InformationAsset[Title = 'dir1']/ScopeContent/Description                                  | dir1 description       |
      | //InformationAsset[Title = 'dir2']/ScopeContent/Description                                  | dir2 description       |
