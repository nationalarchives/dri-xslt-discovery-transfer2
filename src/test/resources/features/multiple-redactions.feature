Feature: A record may have multiple redactions:
  These redactions need to sent to discovery with an IAID using the original record IAID suffixed with _1, _2 etc
  To allow transfer extra dus are added to the metadata for each redaction using the redacted_add_du_for_discovery.xslt
  After the metadata has been converted to a BIA (xip-to-bia-v4-a.xslt) related material information is added using bia_add_fields_for_redacted.xslt


  Scenario: A retained record with 2 redactions (one open and one closed) has been exported from Preservica:
    The retained record has IAID 987bf7ed-69e0-4058-ac59-b307ac3bb838
    The open redaction is the first redaction so has IAID 987bf7ed-69e0-4058-ac59-b307ac3bb838_1
    The closed redaction is the second redaction so has IAID 987bf7ed-69e0-4058-ac59-b307ac3bb838_2
    There are originally 8 DUs, (seven folders and single file) After transform there will be 10 DUs
    The new DUs will have DeliverableUnitRef appended with _1 and _2
    The manifestations for the redacted DUs will have DeliverableUnitRef appended with _1  and _2(referencing updated du duRef)
    The manifestations for redacted files have typeRef of 100
    Given I want to validate XML src/test/resources/metadata1ret2red.xml with xpath:
      | xpath                                                                                                  | value |
      | count(//DeliverableUnit)                                                                               |   8   |
      | count(//DeliverableUnit/DeliverableUnitRef[contains(.,'_1')])                                          |   0   |
      | count(//Manifestation[TypeRef = '100'])                                                                |   2   |
      | count(//Manifestation/DeliverableUnitRef[contains(.,'_1')])                                            |   0   |
      | count(//DeliverableUnit/DeliverableUnitRef[contains(.,'987bf7ed-69e0-4058-ac59-b307ac3bb838')] )       |   1   |
      | count(//DeliverableUnit/CatalogueReference[contains(.,'/1')] )                                         |   0   |
      | count(//DeliverableUnit/CatalogueReference[contains(.,'/2')] )                                         |   0   |
    Given I apply XSLT redacted_add_du_for_discovery.xslt on src/test/resources/metadata1ret2red.xml and output {workingDir}/redacted-du.xml and parameters:
      | parent-id            | 101aa1aa-11a1-411a-aaa1-aa1a11a1111a                  |
    Then I want to validate XML {workingDir}/redacted-du.xml with xpath:
      | xpath                                                                                                  | value |
      | count(//*[local-name() = 'DeliverableUnit'])                                                           |   10  |
      | count(//DeliverableUnit/DeliverableUnitRef[contains(.,'987bf7ed-69e0-4058-ac59-b307ac3bb838')] )       |   3   |
      | count(//DeliverableUnit/DeliverableUnitRef[. = '987bf7ed-69e0-4058-ac59-b307ac3bb838'])                |   1   |
      | count(//DeliverableUnit/DeliverableUnitRef[. = '987bf7ed-69e0-4058-ac59-b307ac3bb838_1'])              |   1   |
      | count(//DeliverableUnit/DeliverableUnitRef[. = '987bf7ed-69e0-4058-ac59-b307ac3bb838_2'])              |   1   |
      | count(//DeliverableUnit/CatalogueReference[contains(., '/2')])                                         |   1   |
      | count(//Manifestation[TypeRef  = '100'])                                                               |   2   |
      | count(//Manifestation/DeliverableUnitRef[ contains(.,'_1')])                                           |   1   |
      | count(//DeliverableUnit/CatalogueReference[contains(.,'/1')] )                                         |   1   |
      | count(//DeliverableUnit/CatalogueReference[contains(.,'/2')] )                                         |   1   |

  @blah
  Scenario: The information assets for redacted assets should have related material description:
  "This is a redacted record. To make a Freedom of Information request for the full record go to"
  For a closed redaction the description should be:
   "This is a redacted record. The full record is retained. To make a Freedom of Information request for the full record contact the creating department."
  The information for the non redacted version should have have related material description
  To see an open redacted version of this record go to
    Given I apply XSLT redacted_add_du_for_discovery.xslt on src/test/resources/metadata1ret2red.xml and output {workingDir}/redacted-du.xml and parameters:
      | parent-id            | 101aa1aa-11a1-411a-aaa1-aa1a11a1111a                  |
    And I apply XSLT xip-to-bia-v4-a.xslt on {workingDir}/redacted-du.xml and output {workingDir}/bia.xml and parameters:
      | parent-id            | 101aa1aa-11a1-411a-aaa1-aa1a11a1111a                  |
      | droid-signature-file | ../../test/resources/DROID_SignatureFile_V73.xml      |
      | directories          | ../../test/resources/directories.xml                  |
    When I apply XSLT bia_add_fields_for_redacted.xslt on {workingDir}/bia.xml and output {workingDir}/biaRedactedFields.xml and parameters:
      | parent-id            | 101aa1aa-11a1-411a-aaa1-aa1a11a1111a                  |
    Then I want to validate XML {workingDir}/biaRedactedFields.xml with xpath:
      | xpath                                                      | value    |
      | //InformationAsset[IAID = '987bf7ed-69e0-4058-ac59-b307ac3bb838_1']/RelatedMaterials/RelatedMaterial/Description | This is a redacted record. To make a Freedom of Information request for the full record go to |
      | //InformationAsset[IAID = '987bf7ed-69e0-4058-ac59-b307ac3bb838_1']/RelatedMaterials/RelatedMaterial/IAID        | 987bf7ed-69e0-4058-ac59-b307ac3bb838        |
      | //InformationAsset[IAID = '987bf7ed-69e0-4058-ac59-b307ac3bb838_2']/RelatedMaterials/RelatedMaterial/Description | This is a redacted record. The full record is retained. To make a Freedom of Information request for the full record contact the creating department. |
      | //InformationAsset[IAID = '987bf7ed-69e0-4058-ac59-b307ac3bb838_2']/RelatedMaterials/RelatedMaterial/IAID        | 987bf7ed-69e0-4058-ac59-b307ac3bb838        |
#    And I perform schema validation with bia.xsd on biaRedactedFields.xml


  Scenario: Multiple redacted collection export. The five transformations are executed in the following sequence
  All transformation must execute without errors
    When I apply XSLT redacted_add_du_for_discovery.xslt on src/test/resources/metadata1ret2red.xml and output {workingDir}/redacted-du.xml and parameters:
      | parent-id            | 101aa1aa-11a1-411a-aaa1-aa1a11a1111a                  |
    When I apply XSLT xip-to-bia-v4-a.xslt on {workingDir}/redacted-du.xml and output {workingDir}/bia.xml and parameters:
      | parent-id            | 101aa1aa-11a1-411a-aaa1-aa1a11a1111a                  |
      | droid-signature-file | ../../test/resources/DROID_SignatureFile_V73.xml      |
      | directories          | ../../test/resources/directories.xml                  |
    When I apply XSLT bia_add_fields_for_redacted.xslt on {workingDir}/bia.xml and output {workingDir}/biaRedactedFields.xml and parameters:
      | parent-id            | 101aa1aa-11a1-411a-aaa1-aa1a11a1111a                  |
    Then I want to validate XML {workingDir}/biaRedactedFields.xml with xpath:
      | xpath                     | value    |
      | count(//InformationAsset) | 10       |
      | count(//Replica)          | 3        |
    When I apply XSLT bia-filter-series.xslt on {workingDir}/biaRedactedFields.xml and output {workingDir}/filterseries.xml and parameters:
      | parent-id            | 101aa1aa-11a1-411a-aaa1-aa1a11a1111a                  |
    When I apply XSLT bia-filter-folders.xslt on {workingDir}/filterseries.xml and output {workingDir}/filterFolders.xml and parameters:
      | parent-id            | 101aa1aa-11a1-411a-aaa1-aa1a11a1111a                  |
    Then I want to validate XML {workingDir}/filterFolders.xml with xpath:
      | xpath                     | value    |
      | count(//InformationAsset) | 3        |
      | count(//Replica)          | 3        |
#    And I perform schema validation with bia.xsd on filterFolders.xml