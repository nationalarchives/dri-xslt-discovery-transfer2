The application expects the following configuration to be provided by JNDI:

```xml

<Environment name="dipLocation" type="java.lang.String" value="/dri_export/open"/>
<Environment name="dipContent" type="java.lang.String" value="content"/>
<Environment name="xipFilename" type="java.lang.String" value="metadata.xml" description="Filename to use for the XIP XML input from the DIP"/>
<Environment name="biaFilename" type="java.lang.String" value="bia.xml" description="Filename to use for the BIA XML result"/>
<Environment name="fileSystemMonitorInitialDelay" type="java.lang.String" value="30 seconds"/>
<Environment name="fileSystemMonitorInterval" type="java.lang.String" value="1 minute"/>
<Environment name="fileSystemTransferFilenameExtension" type="java.lang.String" value="transfer"/>
<Environment name="transformationStylesheets" type="java.lang.String" value="xip-to-bia_v3.xslt,bia-for-hg.xslt"/>
<!--
    a ʃ indicates the absolute file path should be resolved from the classpath
    a § indicates the value is currently unknown but can be resolved somehow by the application
-->
<Environment name="transformationParameters" type="java.lang.String" value="droid-signature-file=ʃDROID_SignatureFile_V73.xml,parent-id=§101aa1aa-11a1-411a-aaa1-aa1a11a1111a"/>
<Environment name="transformationTemplatesCacheTimeout" type="java.lang.String" value="10 seconds"/>
<Environment name="schemaXmlSchemaFile" type="java.lang.String" value="bia.xsd" description="XML Schema to validate BIA"/>
<Environment name="schematronStylesheets" type="java.lang.String" value="common.sch.xslt,digitized.sch.xslt,home-guard.sch.xslt"/>
<Environment name="schematronTerminate" type="java.lang.Boolean" value="true"/>
<Environment name="reportingServiceServer" type="java.lang.String" value="dri-facts1.prd.dri.web.local" description="Name of the transfer reporting server"/>
<Environment name="reportingServicePort" type="java.lang.Integer" value="8082" description="Port number of the transfer reporting server"/>
<Environment name="reportingServiceBaseUri" type="java.lang.String" value="/dri-catalogue/resources/transfer/" description="URL root of the Elda instance being used by this server"/>
<Environment name="reportingServiceUsername" type="java.lang.String" value="my-username"/>
<Environment name="reportingServicePassword" type="java.lang.String" value="my-password"/>
<Environment name="discoveryMessageServiceServer" type="java.lang.String" value="wb-t-lobapp2.web.local" description="Name of the Discovery message destination server"/>
<Environment name="discoveryMessageServicePort" type="java.lang.Integer" value="80" description="Port number of the Discovery message destination server"/>
<Environment name="discoveryMessageServiceUri" type="java.lang.String" value="/MessageService/Message/" description="URL root of the Discovery message destination server"/>
<Environment name="discoveryFileServiceChecksumAlgorithm" type="java.lang.String" value="SHA-256"/>
<Environment name="discoveryFileServiceServer" type="java.lang.String" value="wb-t-lobapp2.web.local" description="Name of the Discovery file destination server"/>
<Environment name="discoveryFileServicePort" type="java.lang.Integer" value="80" description="Port number of the Discovery file destination server"/>
<Environment name="discoveryFileServiceBaseUri" type="java.lang.String" value="/StreamingService/Files/" description="URL root of the Discovery file destination server"/>

```
## Adding custom scope content for export
### Create xslt
Create a copy of the export-template.xslt and fill in below   
 This is where collection specific scope content description is added   
see export-cj4.xslt as an example of completed xslt
### Test
For born digital create a copy of a feature such as CJ_4_export.feature  
1. Update the fields below  "And csv fields in file .*metadata.*csv are updated in collection MUPT2Y17S001/MUPT_2:" using the csv headers  
2. update data below I want to validate XML bia.xml for collection MUPT2Y17S001/MUPT_2: to check the contains  
3.run mvn build from command line before trying tests from intellij



