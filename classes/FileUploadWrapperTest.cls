/*
	@description    Test Class for  FileUploadWrapper apex class 
*/
@isTest
public class FileUploadWrapperTest {
    /*
    @description    This method is used for code coverage of the apex class - FileUploadWrapper
    */
    testMethod static void wrapperTest(){
        FileUploadWrapper.FileFetchWrapper fuw = new FileUploadWrapper.FileFetchWrapper();
        fuw.filePrefix = 'test';
        fuw.fileContent = 'test';
        fuw.wasFileFound = true;
        fuw.fileName = 'test';
        
        FileUploadWrapper.DocumentWrapper dw = new FileUploadWrapper.DocumentWrapper();
        dw.id = 'test';
        dw.fileName = 'test';
        dw.fileType = 'test';
        dw.isVerified = true;
        dw.externalDocument = false;
        dw.folderName = 'test';
        dw.timestamp = 50;
        dw.extDocumentIcon = 'test';
        dw.isVerifiedIcon = 'test';
        dw.uploadedByDetails = 'test';
        
        FileUploadWrapper.DocumentLisWrapper dlw = new FileUploadWrapper.DocumentLisWrapper();
        dlw.documents = new List<FileUploadWrapper.DocumentWrapper>();
        
        FileUploadWrapper.AzureFileUploadWrapper afuw = new FileUploadWrapper.AzureFileUploadWrapper();
        afuw.filename = 'test';
        afuw.option = 'test';
        afuw.filecontent = 'test';
        afuw.fileprefix = 'test';
        afuw.fileextension = 'test';
        afuw.filelength = 'test';
        afuw.fileType = 'test';
        afuw.uniqueId = 'test';
        afuw.externalDoc = true;
        afuw.isVerified = true;
        
        FileUploadWrapper.AuthContentWrapper acw = new FileUploadWrapper.AuthContentWrapper();
        acw.accountSharedKey	= 'test';
        acw.containerName		= 'test';
        acw.storageInstanceUrl	= 'test';
        acw.storageName			= 'test';
    }
}