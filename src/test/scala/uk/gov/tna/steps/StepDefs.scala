package uk.gov.tna.steps

import java.io.File

import cucumber.api.DataTable
import cucumber.api.scala.{EN, ScalaDsl}
import org.scalatest.Matchers
import scalax.file.Path
import transformations.csv.FilePattern
import transformations.matchers.XPathMatchers.haveXPath
import transformations.steps.{XSLTIntegrationSteps, XpathQuery}
import transformations.transform._

import scala.collection.JavaConverters._
import scala.reflect.io.Directory
import scala.util.{Failure, Success}


class StepDefs extends ScalaDsl with EN with Matchers {
  val xsltIntegrationSteps: XSLTIntegrationSteps = new XSLTIntegrationSteps
  val workingDir = s"${System.getProperty("java.io.tmpdir")}${File.separator}acceptance-tests"
  val workingDirSubstitution = "{workingDir}"

  Before { scenario =>
    xsltIntegrationSteps.beforeTest
    Directory(workingDir).createDirectory()
  }

  After { scenario =>
    val pathTmpDir = Path.fromString(workingDir)
    pathTmpDir.deleteRecursively(continueOnFailure = false)
    xsltIntegrationSteps.afterTest
  }

  Given("""^the example collection of type (.*) for collection (.*[\/]{1}.*):""") { (collectionType: String, collectionPath: String) =>
    xsltIntegrationSteps.theExampleCollection(collectionType, collectionPath)
  }

  When("""^I perform transformation (.*) for collection (.*[\/]{1}.*):""") { (operation: String, collectionPath: String) =>
    xsltIntegrationSteps.iPerformTransformationXForCollectionX(operation, collectionPath)
  }

  And("""^I perform the (.*) transformation for collection (.*[\/]{1}.*) using:""") { (transformation: String, collectionPath: String, dataTable: DataTable) =>
    xsltIntegrationSteps.iPerformTheXTransformationOnCollectionXUsing(transformation, collectionPath, dataTable)
  }

  Then("""^the result of the transformation (.*) for collection (.*[\/]{1}.*) has:""") { (operation: String, collectionPath: String, dataTable: DataTable) =>
    xsltIntegrationSteps.theResultOfTheTransformationXForCollectionXHas(operation, collectionPath, dataTable)
  }

  Then("""^the file (.*) for collection (.*[\/]{1}.*) has:""") { (transfer: String, collectionPath: String, dataTable: DataTable) =>
    xsltIntegrationSteps.theFileXForCollectionXHas(transfer, collectionPath, dataTable)
  }



  Then("""^I apply XSLT (.*) to (.*) in collection (.*) to output (.*) with parameters:$""") {
    (xslt: String, xmlInput: String, collection: String, xmlOutput: String, dataTable: DataTable) =>

      val xsltParametersMap = dataTable.asMap(classOf[String], classOf[String]).asScala.toMap

      xsltIntegrationSteps.applyExportTransformation(XSLTTransformData(XsltFile(xslt), InputFile(xmlInput),
        OutputFile(xmlOutput), XsltParameters(xsltParametersMap)), Some(Collection(collection)))
  }

  Then("""^I apply XSLT (.*) on (.*) and output (.*) and parameters:$""") { (xslt: String, xmlInput: String, xmlOutput: String, dataTable: DataTable) =>

    val xsltParametersMap = dataTable.asMap(classOf[String], classOf[String]).asScala.toMap

    val xsltFile = "src/main/resources" + "/" + xslt

    val transformation = TransformData(xsltFile,
      Option(Path.fromString(xmlInput.replace(workingDirSubstitution, workingDir))),
      Path.fromString(xmlOutput.replace(workingDirSubstitution, workingDir)),
      xsltParametersMap)

    Transformer.transform(List(transformation)) match {
      case Success(e) =>
      case Failure(e) => println(e)
    }
  }

  Then("""^I want to validate XML (.*) with xpath:$""") { (xmlFile: String, dataTable: DataTable) =>
    val data = dataTable.asList(classOf[XpathQuery]).asScala
    val output = Path.fromString(xmlFile.replace(workingDirSubstitution, workingDir)).toURI.toASCIIString
    for (query <- data) {
      output should haveXPath(query.xpath, query.value)
    }
  }


  And("""^csv fields in file (.*) are updated in collection (.*[\/]{1}.*):""") { (filePath: String, collectionPath: String, dataTable: DataTable) =>
    xsltIntegrationSteps.updateCSVFileInCollection(FilePattern(Some(filePath.r)), collectionPath, dataTable)
  }

  Then("""^I want to validate XML (.*) for collection (.*[\/]{1}.*):$""") { (xmlFile: String, collectionPath: String, dataTable: DataTable) =>
    xsltIntegrationSteps.iWantToValidateXMLXForCollectionX(xmlFile, collectionPath, dataTable);
  }

  Then("""^I perform schema validation using (.*) on (.*) in collection (.*[\/]{1}.*)""") { (schema:String ,file: String, collectionPath:String) =>
    xsltIntegrationSteps.performSchemaValidationForCollection(ValidationFile(file),SchemaFile(schema), Some(Collection(collectionPath)))
  }

   And("""^I process the sip series (.*) unit (.*) with xslt (.*) metadata (.*) closure (.*)""") { (series: String, unit: String, xslt:String ,metadata: String, closure: String) =>

    createMetadata(series, unit, xslt, metadata, closure)

    val createClosureParametersA = Map("parent-id" -> "123",
       "droid-signature-file" -> "../DROID_SignatureFile_V73.xml",
       "directories" -> "../directories.xml"
     )
     xsltIntegrationSteps.applyExportTransformation(XSLTTransformData(XsltFile("xip-to-bia-v4-a.xslt"), InputFile("metadata-with-closure.xml"),
       OutputFile("bia.xml"), XsltParameters(createClosureParametersA)), Some(Collection(s"$unit/$series")))

  }

  And("""^I create metadata xip for series (.*) unit (.*) with xslt (.*) metadata (.*) closure (.*)""") { (series: String, unit: String, xslt:String ,metadata: String, closure: String) =>
    createMetadata(series, unit, xslt, metadata, closure)
  }

  And("""^I create the metadata with series (.*) unit (.*) with xslt (.*) metadata (.*) closure (.*)""") { (series: String, unit: String, xslt:String ,metadata: String, closure: String) =>
    createMetadata(series, unit, xslt, metadata, closure)
  }


  private def createMetadata(series: String, unit: String, xslt: String, metadata: String, closure: String) = {
    val collectionPath = s"$unit/$series"

    //Convert csv to xml
    xsltIntegrationSteps.iPerformTransformationXForCollectionX("convert-csv-to-xml", collectionPath)
    //Add born-digital metadata to sip


    val retainedParameters = Map("series" -> series,
      "closure-csv-xml-path" -> s"../$closure.xml",
      "metadata-csv-xml-path" -> s"../$metadata.xml"
    )
    xsltIntegrationSteps.applyTransformationForCollection(XSLTTransformData(XsltFile("retained-generate-du.xslt"), InputFile("metadata.xml"),
      OutputFile("metadataWithRetained.xml"), XsltParameters(retainedParameters)), Some(Collection(collectionPath)))

    val metadataToSipParameters = Map("metadata-csv-xml-path" -> s"../$metadata.xml",
      "cs-part-schemas-uri" -> "../schemas.xml",
      "cs-series-uri" -> "../series.xml"
    )
    xsltIntegrationSteps.applyExportTransformation(XSLTTransformData(XsltFile(xslt), InputFile("metadataWithRetained.xml"),
      OutputFile("merged-metadata.xml"), XsltParameters(metadataToSipParameters)), Some(Collection(collectionPath)))

    //Modify sip
    val modifySipParameters = Map("contentLocation" -> "../")
    xsltIntegrationSteps.applyExportTransformation(XSLTTransformData(XsltFile("modify-sip-metadata.xslt"), InputFile("merged-metadata.xml"),
      OutputFile("restructuredMetadata.xml"), XsltParameters(modifySipParameters)), Some(Collection(collectionPath)))

    //Create closure
    val createClosureParameters = Map("series" -> series,
      "closure-csv-xml-path" -> s"../$closure.xml",
      "unit-id" -> unit
    )
    xsltIntegrationSteps.applyExportTransformation(XSLTTransformData(XsltFile("create-closure.xslt"), InputFile("restructuredMetadata.xml"),
      OutputFile("closed.xml"), XsltParameters(createClosureParameters)), Some(Collection(collectionPath)))

    //Add closure to sip - this is used to test only. Closure info is obtained form Catalogue in production
    val addClosuresParameters = Map("closure-xml-path" -> "../closed.xml")
    xsltIntegrationSteps.applyExportTransformation(XSLTTransformData(XsltFile("test-closure.xslt"), InputFile("restructuredMetadata.xml"),
      OutputFile("added-closures.xml"), XsltParameters(addClosuresParameters)), Some(Collection(collectionPath)))

    //remove dus with closure - the test xip has all the other dus such as closure dus etc
    val result: Unit =  xsltIntegrationSteps.applyExportTransformation(XSLTTransformData(XsltFile("test-du-cleaner.xslt"), InputFile("added-closures.xml"),
      OutputFile("metadata-with-closure.xml"), XsltParameters(Map[String,String]())), Some(Collection(collectionPath)))

  }

  And("""^I process a digitised sip series (.*) unit (.*) with xslt (.*) metadata (.*) closure (.*)""") { (series: String, unit: String, xslt:String, metadata: String, closure: String) =>

    val collectionPath = s"$unit/$series"
    //Convert csv to xml
    xsltIntegrationSteps.iPerformTransformationXForCollectionX("convert-csv-to-xml", collectionPath)
    xsltIntegrationSteps.iPerformTransformationXForCollectionX("merge-tech-acq-with-transcription", collectionPath)
    xsltIntegrationSteps.iPerformTransformationXForCollectionX("merge-digitised-to-sip", collectionPath)

    //Modify sip
    val modifySipParameters = Map("contentLocation" -> "../")
    xsltIntegrationSteps.applyExportTransformation(XSLTTransformData(XsltFile("modify-sip-metadata.xslt"), InputFile("merge-sip.xml"),
      OutputFile("restructuredMetadata.xml"), XsltParameters(modifySipParameters)), Some(Collection(collectionPath)))

    //Create closure
    val createClosureParameters: Map[String, String] = Map("series" -> series,
      "closure-csv-xml-path" -> s"../$closure.xml",
      "unit-id" -> unit
    )
    xsltIntegrationSteps.applyExportTransformation(XSLTTransformData(XsltFile("create-closure.xslt"), InputFile("restructuredMetadata.xml"),
      OutputFile("closed.xml"), XsltParameters(createClosureParameters)), Some(Collection(collectionPath)))

    //Add closure to sip - this is used to test only. Closure info is obtained form Catalogue in production
    val addClosuresParameters = Map("closure-xml-path" -> "../closed.xml")
    xsltIntegrationSteps.applyExportTransformation(XSLTTransformData(XsltFile("test-closure.xslt"), InputFile("restructuredMetadata.xml"),
      OutputFile("metadata-with-closure.xml"), XsltParameters(addClosuresParameters)), Some(Collection(collectionPath)))

    //remove dus with closure - the test xip has all the other dus such as closure dus etc
    xsltIntegrationSteps.applyExportTransformation(XSLTTransformData(XsltFile("test-du-cleaner.xslt"), InputFile("metadata-with-closure.xml"),
      OutputFile("metadatatmp.xml"), XsltParameters(Map[String,String]())), Some(Collection(collectionPath)))

  }

  Then("""^I perform schema validation with (.*) on (.*)$""") { (schema:String ,file: String) =>
    xsltIntegrationSteps.performSchemaValidation(ValidationFile(file),SchemaFile(schema), Some(WorkingDir(workingDir)),None,None)
  }

  Then("""^I add sample closures (.*) to (.*) in collection (.*) and output (.*)$""") { (closures:String, sipData:String, collection:String, output:String) =>

    val createClosureParameters = Map("series" -> collection.split('/').tail.head,
      "closure-csv-xml-path" -> s"../$closures",
      "unit-id" -> collection.split('/').head
    )
    xsltIntegrationSteps.applyExportTransformation(XSLTTransformData(XsltFile("create-closure.xslt"), InputFile(sipData),
      OutputFile("closed.xml"), XsltParameters(createClosureParameters)), Some(Collection(collection)))

    //Add closure to sip - this is used to test only. Closure info is obtained form Catalogue in production
    val addClosuresParameters = Map("closure-xml-path" -> s"../closed.xml")

    xsltIntegrationSteps.applyExportTransformation(XSLTTransformData(XsltFile("test-closure.xslt"), InputFile(sipData),
      OutputFile("added-closures.xml"), XsltParameters(addClosuresParameters)), Some(Collection(collection)))

    //remove dus with closure - the test xip has all the other dus such as closure dus etc
    val result: Unit =  xsltIntegrationSteps.applyExportTransformation(XSLTTransformData(XsltFile("test-du-cleaner.xslt"), InputFile("added-closures.xml"),
      OutputFile(output), XsltParameters(Map[String,String]())), Some(Collection(collection)))

  }
}