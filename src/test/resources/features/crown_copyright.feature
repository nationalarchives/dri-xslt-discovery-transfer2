Feature: Testing removal of crown copyright from RestrictionOnUse field

  Scenario: When dcterms:right is set to http://datagov.nationalarchives.gov.uk/resource/Crown_copyright
  RestrictionOnUse element
    Given I apply XSLT redacted_add_du_for_discovery.xslt on src/test/resources/metadata-ret-related.xml and output {workingDir}/redacted-du.xml and parameters:
      | parent-id | 101aa1aa-11a1-411a-aaa1-aa1a11a1111a |
    And I apply XSLT xip-to-bia-v4-a.xslt on {workingDir}/redacted-du.xml and output {workingDir}/bia.xml and parameters:
      | parent-id            | 101aa1aa-11a1-411a-aaa1-aa1a11a1111a             |
      | droid-signature-file | ../../test/resources/DROID_SignatureFile_V73.xml |
      | directories          | ../../test/resources/directories.xml             |
    Then I want to validate XML {workingDir}/bia.xml with xpath:
      | xpath                                                                                   | value                                                         |
      | count(//InformationAsset/RestrictionOnUse)                                              | 3                                                             |
      | count(//InformationAsset[IAID='aa44b4a3-dd27-4b0a-a6cc-231518c793b3']/RestrictionOnUse) | 0                                                             |
      | count(//InformationAsset[IAID='c7a9b67d-c8f2-44b2-ade9-5d6dce8d7c77']/RestrictionOnUse) | 0                                                             |
      | count(//InformationAsset[IAID='aa44b4a3-dd27-4b0a-a6cc-231518c793b3']/RestrictionOnUse) | 0                                                             |
      | //InformationAsset[IAID='883dc485-4e20-46e0-b79a-57779e7957e0']/RestrictionOnUse        | Copyright: Crown copyright and third party copyright material |
      | //InformationAsset[IAID='71937a58-8f72-47f4-a6e2-35b7b31c0b8c']/RestrictionOnUse        | Copyright: XML London                                         |
      | //InformationAsset[IAID='c9ba425e-2806-49d0-8d1a-0898e8435ba5']/RestrictionOnUse        | Copyright: Acme Limited                                       |
