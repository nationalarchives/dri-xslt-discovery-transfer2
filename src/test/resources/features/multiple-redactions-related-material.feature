Feature: Related Materials. Records can have redactions and relatedMaterial in their metadata (catalogue ref string).
 <DeliverableUnit status="same">
   <DeliverableUnitRef>c9ba425e-2806-49d0-8d1a-0898e8435ba5</DeliverableUnitRef>
   ...
   <Metadata schemaURI="http://nationalarchives.gov.uk/metadata/tna#">
     <tna:metadata>
       <rdf:RDF>
          <tna:BornDigitalRecord rdf:about="http://datagov.nationalarchives.gov.uk/66/FCO/37/TFX/Z">
             <tna:cataloguing>
               <tna:Cataloguing>
                 <tna:collectionIdentifier rdf:datatype="xs:string">FOCOM</tna:collectionIdentifier>
                  ....
                 <tna:heldBy rdf:datatype="xs:string">The National Archives, Kew</tna:heldBy>
                 <tna:relatedMaterial rdf:datatype="xs:string">FCO 37/AA1</tna:relatedMaterial>
                 <tna:session_date rdf:datatype="xs:string"/>
               </tna:Cataloguing></tna:cataloguing>
  These need to be referenced in <RelatedMaterial><RelatedMaterial> elements when transferred to Discovery:
  Redactions need to sent to discovery with an IAID using the original record IAID suffixed with _1, _2 etc
  To allow transfer extra dus are added to the metadata for each redaction using the redacted_add_du_for_discovery.xslt
  The xip-to-bia-v4-a.xslt (XIP -> BIA) will add metadata relatedMaterial
  The bia_add_fields_for_redacted.xslt will add redaction related material

   Scenario: xip-to-bia-v4-a.xslt (XIP -> BIA) will add DU metadata related material to the BIA
     Two Dus have relatedMaterial DU metadata so RelatedMaterials will be added to the BIA
     One DU has two redactions and each redaction will have the same RelatedMaterials as the original
     There will be four related Materials in the BIA
     When I apply XSLT redacted_add_du_for_discovery.xslt on src/test/resources/metadata-ret-related.xml and output {workingDir}/redacted-du.xml and parameters:
       | parent-id            | 101aa1aa-11a1-411a-aaa1-aa1a11a1111a                  |
     And I apply XSLT xip-to-bia-v4-a.xslt on {workingDir}/redacted-du.xml and output {workingDir}/bia.xml and parameters:
       | parent-id            | 101aa1aa-11a1-411a-aaa1-aa1a11a1111a                  |
       | droid-signature-file | ../../test/resources/DROID_SignatureFile_V73.xml      |
       | directories          | ../../test/resources/directories.xml                  |
     Then I want to validate XML {workingDir}/bia.xml with xpath:
       | xpath                                                                                                            | value                     |
       | count(//RelatedMaterials)                                                                                        | 4                         |
       | //InformationAsset[IAID = 'c9ba425e-2806-49d0-8d1a-0898e8435ba5']/RelatedMaterials/RelatedMaterial/Description   | FCO 37/AA1                |
       | count(//InformationAsset[IAID = 'c9ba425e-2806-49d0-8d1a-0898e8435ba5']/RelatedMaterials/RelatedMaterial)        | 1                         |
       | count(//InformationAsset[IAID = 'c9ba425e-2806-49d0-8d1a-0898e8435ba5']/*)                                       | 23                        |
       | //InformationAsset[IAID = '987bf7ed-69e0-4058-ac59-b307ac3bb838']/RelatedMaterials/RelatedMaterial/Description   | FCO 37/6258, FCO 37/6259  |
       | count(//InformationAsset[IAID = '987bf7ed-69e0-4058-ac59-b307ac3bb838']/RelatedMaterials/RelatedMaterial)        | 1                         |
       | count(//InformationAsset[IAID = '987bf7ed-69e0-4058-ac59-b307ac3bb838']/*)                                       | 24                        |
       | //InformationAsset[IAID = '987bf7ed-69e0-4058-ac59-b307ac3bb838_1']/RelatedMaterials/RelatedMaterial/Description | FCO 37/6258, FCO 37/6259  |
       | count(//InformationAsset[IAID = '987bf7ed-69e0-4058-ac59-b307ac3bb838_1']/RelatedMaterials/RelatedMaterial)      | 1                         |
       | //InformationAsset[IAID = '987bf7ed-69e0-4058-ac59-b307ac3bb838_2']/RelatedMaterials/RelatedMaterial/Description | FCO 37/6258, FCO 37/6259  |
       | count(//InformationAsset[IAID = '987bf7ed-69e0-4058-ac59-b307ac3bb838_2']/RelatedMaterials/RelatedMaterial)      | 1                         |
       # This asset b6581e9f-655a-4205-a673-ce9e70828a2a does not have metadata  relatedMaterial
       | count(//InformationAsset[IAID = 'b6581e9f-655a-4205-a673-ce9e70828a2a']/RelatedMaterials)                        | 0                         |
       | count(//InformationAsset[IAID = 'b6581e9f-655a-4205-a673-ce9e70828a2a']/*)                                       | 23                        |
#     And I perform schema validation with bia.xsd on bia.xml

  Scenario: RelatedMaterial added for redactions with bia_add_fields_for_redacted.xslt:
  For the redacted record relatedMaterial
  "This is a redacted record. To make a Freedom of Information request for the full record go to"
  For a closed redaction the description should be:
   "This is a redacted record. The full record is retained. To make a Freedom of Information request for the full record contact the creating department."
  The information for the non redacted version should have have related material description
  To see an open redacted version of this record go to
    Given I apply XSLT redacted_add_du_for_discovery.xslt on src/test/resources/metadata-ret-related.xml and output {workingDir}/redacted-du.xml and parameters:
      | parent-id            | 101aa1aa-11a1-411a-aaa1-aa1a11a1111a                  |
    And I apply XSLT xip-to-bia-v4-a.xslt on {workingDir}/redacted-du.xml and output {workingDir}/bia.xml and parameters:
      | parent-id            | 101aa1aa-11a1-411a-aaa1-aa1a11a1111a                  |
      | droid-signature-file | ../../test/resources/DROID_SignatureFile_V73.xml      |
      | directories          | ../../test/resources/directories.xml                  |
    When I apply XSLT bia_add_fields_for_redacted.xslt on {workingDir}/bia.xml and output {workingDir}/biaRedactedFields.xml and parameters:
      | parent-id            | 101aa1aa-11a1-411a-aaa1-aa1a11a1111a                  |
    Then I want to validate XML {workingDir}/biaRedactedFields.xml with xpath:
      | xpath                                                      | value    |
      # This asset b6581e9f-655a-4205-a673-ce9e70828a2a only has redacted relatedMaterial
      | //InformationAsset[IAID = 'b6581e9f-655a-4205-a673-ce9e70828a2a']/RelatedMaterials/RelatedMaterial/Description | To see an open redacted version of this record go to |
      | //InformationAsset[IAID = 'b6581e9f-655a-4205-a673-ce9e70828a2a']/RelatedMaterials/RelatedMaterial/IAID        | b6581e9f-655a-4205-a673-ce9e70828a2a_1               |
      | count(//InformationAsset[IAID = 'b6581e9f-655a-4205-a673-ce9e70828a2a']/RelatedMaterials/RelatedMaterial)      | 1                                                    |
      # asset 987bf7ed-69e0-4058-ac59-b307ac3bb838 now has three RelatedMaterial (One from metadata two redactions
      | count(//InformationAsset[IAID = '987bf7ed-69e0-4058-ac59-b307ac3bb838']/RelatedMaterials/RelatedMaterial)      | 3                                                    |
      | count(//InformationAsset[IAID = '987bf7ed-69e0-4058-ac59-b307ac3bb838']/RelatedMaterials/RelatedMaterial/Description[. = 'FCO 37/6258, FCO 37/6259'] )                                | 1           |
      | count(//InformationAsset[IAID = '987bf7ed-69e0-4058-ac59-b307ac3bb838']/RelatedMaterials/RelatedMaterial/Description[. = 'To see an open redacted version of this record go to'])     | 1           |
      | count(//InformationAsset[IAID = '987bf7ed-69e0-4058-ac59-b307ac3bb838']/RelatedMaterials/RelatedMaterial/Description[. = 'To see a closed redacted version of this record go to'])    | 1           |
      | count(//InformationAsset[IAID = '987bf7ed-69e0-4058-ac59-b307ac3bb838']/*)                                                                                                            | 24          |
      # RelatedMaterials now added to ce9e70828a2a (count +1)
      | count(//InformationAsset[IAID = 'b6581e9f-655a-4205-a673-ce9e70828a2a']/*)                                                                                                            | 24          |
      | count(//InformationAsset[IAID = 'c9ba425e-2806-49d0-8d1a-0898e8435ba5']/*)                                                                                                            | 23          |
      | count(//InformationAsset[IAID = '987bf7ed-69e0-4058-ac59-b307ac3bb838_2']/RelatedMaterials/RelatedMaterial)                                                                           | 2           |
      | count(//InformationAsset[IAID = '987bf7ed-69e0-4058-ac59-b307ac3bb838_2']/RelatedMaterials/RelatedMaterial/Description[ . = 'This is a redacted record. The full record is retained. To make a Freedom of Information request for the full record contact the creating department.']) | 1 |
      | //InformationAsset[IAID = '987bf7ed-69e0-4058-ac59-b307ac3bb838_2']/RelatedMaterials/RelatedMaterial/IAID        | 987bf7ed-69e0-4058-ac59-b307ac3bb838        |
#    And I perform schema validation with bia.xsd on biaRedactedFields.xml


  Scenario: Multiple redacted record and relatedMaterial. The five transformations are executed in the following sequence
  All transformation must execute without errors
    When I apply XSLT redacted_add_du_for_discovery.xslt on src/test/resources/metadata-ret-related.xml and output {workingDir}/redacted-du.xml and parameters:
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
#    And I perform schema validation with bia.xsd on filterFolders.xml