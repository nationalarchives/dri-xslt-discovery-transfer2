Feature: LOC 5 Export
  Fields in Scope/Content(description) field in discovery
  Film Name:
  Summary:
  Film Maker:
  Department:
  Classification:
  rules for Film Name:
  Metadata taken from film_name – add Film Name: followed by the data from the field. followed by a new line
  rules for Summary:
  Metadata taken from summary – add Summary: followed by the data from the field. followed by a new line
  rules for Film Maker:
  Metadata taken from film_maker – add Film Maker: followed by the data from the field. followed by a new line
  rules for Department:
  Metadata taken from internal_department – add Department: followed by the data from the field. followed by a new line
  rules for Classification:
  Metadata taken from classification – add Classification: followed by the data from the field.

  Scenario: LOC 5 fields exported to discovery
            Closed files should be added a special note. If a note already exists, it should be appended to it
            The note should not be changed for open files.
    Given the example collection of type born-digital for collection TEST1Y19HS001/TEST_1:
    And csv fields in file .*metadata.*csv are updated in collection TEST1Y19HS001/TEST_1:
      | rowId                 | column                                | value                        |
      | d1f1                  | film_name                             | Inspire programme promo      |
      | d1f1                  | summary                               | Promo film                   |
      | d1f1                  | film_maker                            | McCann.                      |
      | d1f1                  | internal_department                   | Marketing.                   |
      | d1f1                  | classification                        | Olympic Paralympic           |
      | d1f1                  | rights_copyright                      | Rights CR...                 |
      | d1f2                  | note                                  | Note About Something         |
      | d1f1                  | note                                  | Note About Something         |
    And csv fields in file .*closure.*csv are updated in collection TEST1Y19HS001/TEST_1:
      | rowId                 | column                                | value                        |
      | d1f2                  | closure_type                          | open_on_transfer             |
      | d2f1                  | closure_type                          | open_on_transfer             |
    And I process the sip series TEST_1 unit TEST1Y19HS001 with xslt add-born-digital-metadata-to-sip_v2.2.xslt metadata metadata_TEST1Y19HS001.csv closure closure.csv
    When I apply XSLT export-loc5.xslt to metadata-with-closure.xml in collection TEST1Y19HS001/TEST_1 to output bia.xml with parameters:
      | parent-id            | 123                                                                   |
      | droid-signature-file | ../DROID_SignatureFile_V73.xml                                        |
      | directories          | ../directories.xml                                                    |
    And I apply XSLT add_locog_note_for_closed_records.xslt to bia.xml in collection TEST1Y19HS001/TEST_1 to output bia2.xml with parameters:
      | parent-id            | 123                                                                   |
    Then I want to validate XML bia2.xml for collection TEST1Y19HS001/TEST_1:
      | xpath                                                                                                               | value        |
      | contains(//InformationAsset[Title = 'd1f1.tif']/ScopeContent/Description,'Film Name: Inspire programme promo')      | true         |
      | contains(//InformationAsset[Title = 'd1f1.tif']/ScopeContent/Description,'Promo film')                              | true         |
      | contains(//InformationAsset[Title = 'd1f1.tif']/ScopeContent/Description,'Film Maker: McCann.')                     | true         |
      | contains(//InformationAsset[Title = 'd1f1.tif']/ScopeContent/Description,'Department: Marketing.')                  | true         |
      | contains(//InformationAsset[Title = 'd1f1.tif']/ScopeContent/Description,'Olympic Paralympic')                      | true         |
      | //InformationAsset[Title = 'd1f1.tif']/RestrictionOnUse                                                             | Copyright: Rights CR...                                                                                                                                                                                                                                                                                              |
      | //InformationAsset[Title = 'd1f1.tif']/Note                                                                         | <p>These records were taken under special agreement with LOCOG and the British Olympic Authority (BOA) with a 15 year closure from 26 November 2012 (which was the date of transfer to The National Archives). Therefore the record opening date for these files is 27 November 2027.</p><p>Note About Something</p> |
      | //InformationAsset[Title = 'd1f2.tif']/Note                                                                         | Note About Something                                                                                                                                                                                                                                                                                                 |
      | //InformationAsset[Title = 'd1f3.tif']/Note                                                                         |<p>These records were taken under special agreement with LOCOG and the British Olympic Authority (BOA) with a 15 year closure from 26 November 2012 (which was the date of transfer to The National Archives). Therefore the record opening date for these files is 27 November 2027.</p>                             |
      | count(//InformationAsset[Title = 'd1f1.tif']/Note)                                                                  | 1 |
      | count(//InformationAsset[Title = 'd1f2.tif']/Note)                                                                  | 1 |
      | count(//InformationAsset[Title = 'd1f3.tif']/Note)                                                                  | 1 |
      | count(//InformationAsset[Title = 'd2f1.tif']/Note)                                                                  | 0 |