Feature: Retained record export

  Scenario: CSV metadata is merged with the SIP, transformed as in a born-digital workflow then exported to Discovery
    Given the example collection of type born-digital for collection FCO37Y21HB010/FCO_37:
    And I perform transformation convert-csv-to-xml for collection FCO37Y21HB010/FCO_37:
    And I apply XSLT retained-generate-du.xslt to metadata.xml in collection FCO37Y21HB010/FCO_37 to output retained-du-xml with parameters:
      | closure-csv-xml-path                                     | ../.*closure.*xml      |
      | metadata-csv-xml-path                                    | ../.*metadata.*xml     |
    When I apply XSLT add-born-digital-metadata-to-sip_v2.2.xslt to retained-du-xml in collection FCO37Y21HB010/FCO_37 to output merged-metadata.xml with parameters:
      | metadata-csv-xml-path                     | ../metadata_v43_FCO37Y21HB002.csv.xml |
      | cs-part-schemas-uri                       | ../schemas.xml                        |
      | cs-series-uri                             | ../series.xml                         |
    And I apply XSLT modify-sip-metadata.xslt to merged-metadata.xml in collection FCO37Y21HB010/FCO_37 to output restructuredMetadata.xml with parameters:
      | contentLocation            | ../ |
    And I apply XSLT create-closure.xslt to restructuredMetadata.xml in collection FCO37Y21HB010/FCO_37 to output closures.xml with parameters:
      | closure-csv-xml-path                      | ../closure.csv.xml                 |
      | series                                    | FCO_37                             |
      | unit-id                                   | FCO37Y21HB010                      |
    And I apply XSLT add-empty-manifestation-topleveldu.xslt to restructuredMetadata.xml in collection FCO37Y21HB010/FCO_37 to output retained-redacted.xml with parameters:
      | closure-csv-xml-path                      | ../closure.csv.xml                 |
    And I add sample closures closure.csv.xml to retained-redacted.xml in collection FCO37Y21HB010/FCO_37 and output sipWithClosures.xml
    When I apply XSLT xip-to-bia-v4-a.xslt to sipWithClosures.xml in collection FCO37Y21HB010/FCO_37 to output bia.xml with parameters:
      | parent-id            | 123                                                                   |
      | droid-signature-file | ../DROID_SignatureFile_V73.xml                      |
      | directories          | ../directories.xml                                  |
