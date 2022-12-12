Feature: Discovery export requires fields from CSV metadata to be processed during an ingest and then used in the BIA.xml that
  contains a collection of Information assets to be transferred.
  There are 8  rows in the metadata that can be updated
    rowId     xpath for InformationAsset related to that row
    -----     ---------------------------------------------
  pieceRow1     //InformationAsset[IAID = 'pieceRow1']
  itemRow1      //InformationAsset[IAID = 'itemRow1']
  pieceRow2
  itemRow2
  itemRow3
  pieceRow3
  itemRow4

  Scenario: CSV metadata is merged with the SIP, transformed as in a digitised workflow then exported to Discovery.
    If Seal_owner in transcription csv transcripion element added to metadata
    For pro-23 transfer will use transcription data for discovery scope content if present or the description
    Given the example collection of type digitised for collection DD1S001/DDD_1:
    And csv fields in file .*nscription_metadata.*csv are updated in collection DD1S001/DDD_1:
      | rowId      | column                             | value                          |
      | itemRow1   | Type_of_seal                       | England and Wales: Monastic    |
      | itemRow1   | description                        | describe item                  |
      | itemRow1   | Seal_owner                         | Priory of Saint Mary           |
      | pieceRow1  | description                        | describe piece                 |
      | pieceRow1  | Type_of_seal                       | England and Wales: Monastic    |
    And I process a digitised sip series DDD_1 unit DD1S001 with xslt add-digitised-record-metadata-to-sip-v2.xslt metadata transcription_metadata_v2_DD1S001.csv closure closure_v8.csv
    And I perform the export-pro23.xslt transformation for collection DD1S001/DDD_1 using:
      | inputFile             | metadatatmp.xml   |
      | outputFile            | transfer.xml                          |
      | parent-id             | 101aa1aa-11a1-411a-aaa1-aa1a11a1111a  |
      | droid-signature-file  | DROID_SignatureFile_V73.xml           |
      | directories           | directories.xml                       |
    Then the file transfer.xml for collection DD1S001/DDD_1 has:
      | xpath                                                                                                                    | value |
      | contains(//InformationAsset[IAID = 'itemRow1']//ScopeContent/Description, 'Type of seal: England and Wales: Monastic')   | true  |
      | not(contains(//InformationAsset[IAID = 'itemRow1']//ScopeContent/Description, 'describe piece'))                         | true  |
      | contains(//InformationAsset[IAID = 'pieceRow1']//ScopeContent/Description, 'describe piece')                             | true  |



