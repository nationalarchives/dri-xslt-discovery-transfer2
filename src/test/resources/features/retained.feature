Feature: Exporting retained files:
  Retained records are provided with specific metadata values in the closure csv file
  retention_type - text such as 'retained_under_3.4' which are mapped to a ClosureType (on ingest)
      retained_until       D
      retained_under       S
      temporarily_retained T
  retention_justification  - code such as 6  that map to dri https://github.com/digital-preservation/dri-vocabulary/blob/master/terms/dri_terminology.ttl
       <http://nationalarchives.gov.uk/dri/catalogue/retentionjustification#6>
             a dri:RetentionJustificationType ;
             rdfs:comment "Records retained in departments on security or other specified grounds" ;
             rdfs:label "6"
  RI_Number (aka Lord Chancellor's Instrument)
  RI_signed_date (aka LCI signed dat)
  retention_reconsider_date
  These values (except RI_Number and RI_signed_date) are mapped to different elements in the transfer message for Discovery

  Scenario: A retained record with two redactions (one open and one closed) has been exported from Preservica:
    The retained record has IAID 987bf7ed-69e0-4058-ac59-b307ac3bb838
    The open redaction is the first redaction so has IAID 987bf7ed-69e0-4058-ac59-b307ac3bb838_1
    The closed redaction is the second redaction so has IAID 987bf7ed-69e0-4058-ac59-b307ac3bb838_2
    As the export contains redactions the redaction specific xslt will be run
  #Add a DU for the redacted files so it is regarded as distinct asset for Discovery
  Given I apply XSLT redacted_add_du_for_discovery.xslt on src/test/resources/metadata1ret2red.xml and output {workingDir}/redacted-du.xml and parameters:
      | parent-id            | 101aa1aa-11a1-411a-aaa1-aa1a11a1111a                  |
    #transform from sip metadata.xml to BIA
    And I apply XSLT xip-to-bia-v4-a.xslt on {workingDir}/redacted-du.xml and output {workingDir}/bia.xml and parameters:
      | parent-id            | 101aa1aa-11a1-411a-aaa1-aa1a11a1111a                  |
      | droid-signature-file | ../../test/resources/DROID_SignatureFile_V73.xml      |
      | directories          | ../../test/resources/directories.xml                  |
    #add fields for redacted assets
    When I apply XSLT bia_add_fields_for_redacted.xslt on {workingDir}/bia.xml and output {workingDir}/biaRedactedFields.xml and parameters:
      | parent-id            | 101aa1aa-11a1-411a-aaa1-aa1a11a1111a                  |
    Then I want to validate XML {workingDir}/biaRedactedFields.xml with xpath:
      | xpath                | value                                                 |
      | //InformationAsset[contains(IAID,'_1')]//RelatedMaterial/Description         |   This is a redacted record. To make a Freedom of Information request for the full record go to |
      | count(//Description[text() = 'To see an open redacted version of this record go to'])       | 1        |
    # Closure type
    # retention_type in csv file is converted to closureType on ingest Type S = retained by department under section 3.4
    # retained records have no closure_type in the csv only retention_type csvs 'closure_type: if($retention_type/notEmpty,empty'
    # opened redacted version closureType   A open on transfer
    # closed redacted version is closureType F closed for
    Then I want to validate XML {workingDir}/biaRedactedFields.xml with xpath:
      | xpath                                                                                        | value    |
      | //InformationAsset[IAID = '987bf7ed-69e0-4058-ac59-b307ac3bb838']/ClosureType                | S        |
      | //InformationAsset[IAID = '987bf7ed-69e0-4058-ac59-b307ac3bb838_1']/ClosureType              | A        |
      | //InformationAsset[IAID = '987bf7ed-69e0-4058-ac59-b307ac3bb838_2']/ClosureType              | F        |
    # Closure status see https://narnia/display/DIG/Closure+status
    # This can be one of three values and is determined document/description status and if retained
    # Open Document, Open Description
    # Closed Or Retained Document, Open Description
    # Closed Or Retained Document, Closed Description
    # Retained record has ClosureStatus D  (closed or retained)
    # Redacted open version has closureStatus 0 (open)
    # Redacted closed version has ClosureStatus D  (closed or retained)
    Then I want to validate XML {workingDir}/biaRedactedFields.xml with xpath:
      | xpath                                                                                        | value    |
      | //InformationAsset[IAID = '987bf7ed-69e0-4058-ac59-b307ac3bb838']/ClosureStatus              | D        |
      | //InformationAsset[IAID = '987bf7ed-69e0-4058-ac59-b307ac3bb838_1']/ClosureStatus            | O        |
      | //InformationAsset[IAID = '987bf7ed-69e0-4058-ac59-b307ac3bb838_2']/ClosureStatus            | D        |
    # retention_justification mapped to ExemptionCodeId for retained
    # redacted versions as expected - no exemption code for open file
    # exemption code 27(1) for closed redaction
    Then I want to validate XML {workingDir}/biaRedactedFields.xml with xpath:
      | xpath                                                                                                                                |  value  |
      | //AccessRegulation[RelatedToIA = '987bf7ed-69e0-4058-ac59-b307ac3bb838']/ClosureCriterions/ClosureCriterion/ExemptionCodeId          |  6      |
      | count(//AccessRegulation[RelatedToIA = '987bf7ed-69e0-4058-ac59-b307ac3bb838_1']/ClosureCriterions/ClosureCriterion/ExemptionCodeId) |  0      |
      | //AccessRegulation[RelatedToIA = '987bf7ed-69e0-4058-ac59-b307ac3bb838_2']/ClosureCriterions/ClosureCriterion/ExemptionCodeId        |  27(1)  |
    # For retained records retentionReconsiderDate will be mapped to ReconsiderDueInDate
    Then I want to validate XML {workingDir}/biaRedactedFields.xml with xpath:
      | xpath                                                                                          |  value                |
      | //AccessRegulation[RelatedToIA = '987bf7ed-69e0-4058-ac59-b307ac3bb838']/ReconsiderDueInDate   |  2031-12-31T00:00:00  |
     # For retained records the SignedDate element will be empty
    Then I want to validate XML {workingDir}/biaRedactedFields.xml with xpath:
      | xpath                                                                                          |  value                |
      | //AccessRegulation[RelatedToIA = '987bf7ed-69e0-4058-ac59-b307ac3bb838']/SignedDate            |                       |
    # the retained record will be held by the retaining office (actual text in csv held_by) but the redactions will be at The National Archives, Kew
    Then I want to validate XML {workingDir}/biaRedactedFields.xml with xpath:
      | xpath                                                                                                      |  value                          |
      | //InformationAsset[IAID = '987bf7ed-69e0-4058-ac59-b307ac3bb838']/HeldBy/HeldBy/Corporate_Body_Name_Text   |  Retaining Office               |
      | //InformationAsset[IAID = '987bf7ed-69e0-4058-ac59-b307ac3bb838_1']/HeldBy/HeldBy/Corporate_Body_Name_Text |  The National Archives, Kew     |
      | //InformationAsset[IAID = '987bf7ed-69e0-4058-ac59-b307ac3bb838_2']/HeldBy/HeldBy/Corporate_Body_Name_Text |  The National Archives, Kew     |
#    And I perform schema validation with bia.xsd on biaRedactedFields.xml

  Scenario: Redacted collection export. The five transformations are executed in the following sequence
  All transformation must execute without errors
    When I apply XSLT redacted_add_du_for_discovery.xslt on src/test/resources/metadata1ret2red.xml and output {workingDir}/redacted-du.xml and parameters:
      | parent-id            | 101aa1aa-11a1-411a-aaa1-aa1a11a1111a                  |
    When I apply XSLT xip-to-bia-v4-a.xslt on {workingDir}/redacted-du.xml and output {workingDir}/bia.xml and parameters:
      | parent-id            | 101aa1aa-11a1-411a-aaa1-aa1a11a1111a                  |
      | droid-signature-file | ../../test/resources/DROID_SignatureFile_V73.xml      |
      | directories          | ../../test/resources/directories.xml                  |
    When I apply XSLT bia_add_fields_for_redacted.xslt on {workingDir}/bia.xml and output {workingDir}/biaRedactedFields.xml and parameters:
      | parent-id            | 101aa1aa-11a1-411a-aaa1-aa1a11a1111a                  |
    When I apply XSLT bia-filter-series.xslt on {workingDir}/biaRedactedFields.xml and output {workingDir}/filterseries.xml and parameters:
      | parent-id            | 101aa1aa-11a1-411a-aaa1-aa1a11a1111a                  |
    When I apply XSLT bia-filter-folders.xslt on {workingDir}/filterseries.xml and output {workingDir}/filterFolders.xml and parameters:
      | parent-id            | 101aa1aa-11a1-411a-aaa1-aa1a11a1111a                  |
    Then I want to validate XML {workingDir}/filterFolders.xml with xpath:
      | xpath                     | value    |
      | count(//InformationAsset) | 3        |
      | count(//Replica)          | 3        |
#    And I perform schema validation with bia.xsd on filterFolders.xml
