Feature: On export we can filter the bia by series and parent Id

  Scenario: Use the bia-filter-by-parent.xslt to remove piece level information assets when used after the filter-by-series
    Filter by series will remove series and set ParentIAID to the piece
    Once piece has parentIAID as parent it is then removed
    When I apply XSLT export-adm158.xslt on src/test/resources/adm-158-sip.xml and output {workingDir}/bia.xml and parameters:
      | parent-id                     | 101aa1aa-11a1-411a-aaa1-aa1a11a1111a                  |
      | droid-signature-file          | ../../test/resources/DROID_SignatureFile_V73.xml      |
      | directories                   | ../../test/resources/directories.xml                  |
    Then I want to validate XML {workingDir}/bia.xml with xpath:
      | xpath                                                      | value    |
      | count(//InformationAsset)                                  |  34      |
      | count(//InformationAsset/Reference[. = 'ADM 158'])         |  1       |
      | //InformationAsset[Reference = 'ADM 158']/ParentIAID       |  101aa1aa-11a1-411a-aaa1-aa1a11a1111a   |
      | count(//InformationAsset/Reference[. = 'ADM 158/193'])     |  1       |
    And I apply XSLT bia-filter-series.xslt on {workingDir}/bia.xml and output {workingDir}/no-series-bia.xml and parameters:
      | parent-id                     | 101aa1aa-11a1-411a-aaa1-aa1a11a1111a                  |
    Then I want to validate XML {workingDir}/no-series-bia.xml with xpath:
      | xpath                                                      | value    |
      | count(//InformationAsset)                                  |  33      |
      | count(//InformationAsset/Reference[. = 'ADM 158'])         |  0       |
      | count(//InformationAsset/Reference[. = 'ADM 158/193'])     |  1       |
      | //InformationAsset[Reference = 'ADM 158/193']/ParentIAID   |  101aa1aa-11a1-411a-aaa1-aa1a11a1111a   |
    And I apply XSLT bia-filter-by-parent.xslt on {workingDir}/no-series-bia.xml and output {workingDir}/no-series-no-piece-bia.xml and parameters:
      | parent-id                     | 101aa1aa-11a1-411a-aaa1-aa1a11a1111a                  |
    Then I want to validate XML {workingDir}/no-series-no-piece-bia.xml with xpath:
      | xpath                                                                                | value    |
      | count(//InformationAsset)                                                            |  32      |
      | count(//InformationAsset/Reference[. = 'ADM 158'])                                   |  0       |
      | count(//InformationAsset/Reference[. = 'ADM 158/193'])                               |  0       |
      | count(//InformationAsset/ParentIAID[. = '101aa1aa-11a1-411a-aaa1-aa1a11a1111a'])     |  0       |