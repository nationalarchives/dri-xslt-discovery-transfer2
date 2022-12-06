Feature: Redaction accruals export require the redacted files to be moved from their ingest folder
  to the original du folder so the export allows the correct arrangement for discovery:

  Scenario: Testing redaction accrual file move:
    One redaction is an accrual so has been ingested using the accrual single folder WorkingPath and Path
    After applying the redaction_accrual_arrangement_folder.xslt the accrual redaction will have the same
    WorkingPath and path of the original
    The tests show before the transformation there are two working paths TNA 37/FS/92/P/026/105/TNA37-FSP026.105.92
    the original and redaction ingested at the same time and one RED 1 which is the accrual redaction.
    After the transform there are three working paths TNA 37/FS/92/P/026/105/TNA37-FSP026.105.92 and no RED 1
    RED 1 has been replaced by TNA 37/FS/92/P/026/105/TNA37-FSP026.105.92
    Given I apply XSLT redacted_add_du_for_discovery.xslt on src/test/resources/metadata2red1accrual.xml and output {workingDir}/redacted-du.xml and parameters:
      | parent-id            | 101aa1aa-11a1-411a-aaa1-aa1a11a1111a                  |
    # WorkingPath and Path of RED 1 before. Two TNA 37/FS/92/P/026/105/TNA37-FSP026.105.92
    And I want to validate XML {workingDir}/redacted-du.xml with xpath:
      | xpath                                                                                                  | value |
      | count(//WorkingPath[. = 'RED 1'])                                                                      |   1   |
      | count(//WorkingPath[. = 'TNA 37/FS/92/P/026/105/TNA37-FSP026.105.92'])                                 |   2   |
      | count(//Manifestation/ManifestationFile[Path = "RED 1"])                                               |   1   |
      | count(//Manifestation/ManifestationFile[Path = "TNA 37/FS/92/P/026/105/TNA37-FSP026.105.92"])          |   2   |
    And I apply XSLT redaction_accrual_arrangement_folder.xslt on {workingDir}/redacted-du.xml and output {workingDir}/redacted-accrual.xml and parameters:
      | content-base-path            | /pre_accession/batch/series                  |
      | production                   | false                                        |
    # No WorkingPath and Path RED 1  after. Three TNA 37/FS/92/P/026/105/TNA37-FSP026.105.92
    And I want to validate XML {workingDir}/redacted-accrual.xml with xpath:
      | xpath                                                                                                  | value |
      | count(//WorkingPath[. = 'RED 1'])                                                                      |   0   |
      | count(//Manifestation/ManifestationFile[Path = "RED 1"])                                               |   0   |
      | count(//WorkingPath[. = 'TNA 37/FS/92/P/026/105/TNA37-FSP026.105.92'])                                 |   3   |
      | count(//Manifestation/ManifestationFile[Path = "TNA 37/FS/92/P/026/105/TNA37-FSP026.105.92"])          |   3   |
    And I apply XSLT xip-to-bia-v4-a.xslt on {workingDir}/redacted-accrual.xml and output {workingDir}/bia.xml and parameters:
      | parent-id            | 101aa1aa-11a1-411a-aaa1-aa1a11a1111a                  |
      | droid-signature-file | ../../test/resources/DROID_SignatureFile_V73.xml      |
      | directories          | ../../test/resources/directories.xml                  |
    # All three replicas, original file and both redactions should have same completePath and number of folders
    And I want to validate XML {workingDir}/bia.xml with xpath:
      | xpath                                                      | value    |
      | //Replica[RelatedToIA = '987bf7ed-69e0-4058-ac59-b307ac3bb838_2']/Folios/Folio/DigitalFiles/DigitalFile/DigitalFileDirectory/@completePath | TNA 37/FS/92/P/026/105/TNA37-FSP026.105.92|
      | //Replica[RelatedToIA = '987bf7ed-69e0-4058-ac59-b307ac3bb838_1']/Folios/Folio/DigitalFiles/DigitalFile/DigitalFileDirectory/@completePath | TNA 37/FS/92/P/026/105/TNA37-FSP026.105.92|
      | //Replica[RelatedToIA = '987bf7ed-69e0-4058-ac59-b307ac3bb838']/Folios/Folio/DigitalFiles/DigitalFile/DigitalFileDirectory/@completePath   | TNA 37/FS/92/P/026/105/TNA37-FSP026.105.92|
      | count(//Replica[RelatedToIA = '987bf7ed-69e0-4058-ac59-b307ac3bb838_2']/Folios/Folio/DigitalFiles/DigitalFile/DigitalFileDirectory/Folder) | 7 |
      | count(//Replica[RelatedToIA = '987bf7ed-69e0-4058-ac59-b307ac3bb838_1']/Folios/Folio/DigitalFiles/DigitalFile/DigitalFileDirectory/Folder) | 7 |
      | count(//Replica[RelatedToIA = '987bf7ed-69e0-4058-ac59-b307ac3bb838']/Folios/Folio/DigitalFiles/DigitalFile/DigitalFileDirectory/Folder)   | 7 |
    When I apply XSLT bia_add_fields_for_redacted.xslt on {workingDir}/bia.xml and output {workingDir}/biaRedactedFields.xml and parameters:
      | parent-id            | 101aa1aa-11a1-411a-aaa1-aa1a11a1111a                  |
    Then I want to validate XML {workingDir}/biaRedactedFields.xml with xpath:
      | xpath                                                      | value    |
      | //InformationAsset[IAID = '987bf7ed-69e0-4058-ac59-b307ac3bb838_1']/RelatedMaterials/RelatedMaterial/Description | This is a redacted record. To make a Freedom of Information request for the full record go to |
      | //InformationAsset[IAID = '987bf7ed-69e0-4058-ac59-b307ac3bb838_1']/RelatedMaterials/RelatedMaterial/IAID        | 987bf7ed-69e0-4058-ac59-b307ac3bb838        |
      | //InformationAsset[IAID = '987bf7ed-69e0-4058-ac59-b307ac3bb838_2']/RelatedMaterials/RelatedMaterial/Description | This is a redacted record. The full record is retained. To make a Freedom of Information request for the full record contact the creating department. |
      | //InformationAsset[IAID = '987bf7ed-69e0-4058-ac59-b307ac3bb838_2']/RelatedMaterials/RelatedMaterial/IAID        | 987bf7ed-69e0-4058-ac59-b307ac3bb838        |
#    And I perform schema validation with bia.xsd on biaRedactedFields.xml


