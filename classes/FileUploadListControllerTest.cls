/*
	@description    Test class for FileUploadListController
*/
@IsTest
public class FileUploadListControllerTest {
    
    @TestSetup
    public static void dataSetup(){
		DocumentStorageSetting__c setting = new DocumentStorageSetting__c();
        setting.AccountSharedKey__c = 'test';
        setting.ContainerName__c =  'test';
        setting.StorageName__c =  'test';
        setting.StorageInstanceURL__c =  'test';
        insert setting;        
    }
    /*
	@description    Test method for getRelatedCloudDocuments when Cloud Document records available
	*/
    @IsTest
    private static void test_getRelatedCloudDocuments_success(){
        List<Account> accList = TestDataFactory.createAccounts(1, true);
        List<Contact> conList = TestDataFactory.createContacts(accList[0].Id, 1, true);
        
        List<CloudDocument__c> cloudDocList = TestDataFactory.createCloudDocument(conList[0].Id, 1, true);
        
        FileUploadWrapper.DocumentLisWrapper result = FileUploadListController.getRelatedCloudDocuments(conList[0].Id, false);
        
        System.assertNotEquals(null, result);
        System.assertNotEquals(null, result.documents);
        System.assertEquals(1, result.documents.size());
    }
    
    /*
	@description    Test method for getRelatedCloudDocuments when no matching records available
	*/
    @IsTest
    private static void test_getRelatedCloudDocuments_noRecordsFound(){
        
        List<Account> accList = TestDataFactory.createAccounts(1, true);
        List<Contact> conList = TestDataFactory.createContacts(accList[0].Id, 1, true);
        
        
        FileUploadWrapper.DocumentLisWrapper result = FileUploadListController.getRelatedCloudDocuments(conList[0].Id, true);
        
        System.assertNotEquals(null, result);
        System.assertNotEquals(null, result.documents);
        System.assertEquals(0, result.documents.size());
    }
    
    /*
	@description    Test method for changeFileType when uploading a new file and update its related information
	*/
    @IsTest
    private static void test_changeFileType(){
        
        List<Account> accList = TestDataFactory.createAccounts(1, true);
        List<Contact> conList = TestDataFactory.createContacts(accList[0].Id, 1, true);
        
        List<CloudDocument__c> cloudDocList = TestDataFactory.createCloudDocument(conList[0].Id, 1, true);
        
        FileUploadWrapper.AzureFileUploadWrapper fileWrapper = new FileUploadWrapper.AzureFileUploadWrapper();
        fileWrapper.filename = 'test file name';
        fileWrapper.option = 'new folder';
        fileWrapper.filecontent = 'test content';
        fileWrapper.fileprefix = 'NW';
        fileWrapper.fileextension = 'pdf';
        fileWrapper.fileType = 'statement';
        fileWrapper.uniqueId = cloudDocList[0].Id;
        fileWrapper.filelength = '23';
        fileWrapper.externalDoc = true;
        fileWrapper.isVerified = true;
        
        CloudDocument__c cloudDoc2 = [Select Id, DecodedFileLocation__c, Filetype__c, FolderName__c, fileName__c, FileContentPrefix__c, IsVerified__c, ExternalDocument__c from CloudDocument__c where Id =: cloudDocList[0].Id];
        
        System.assertNotEquals(null, cloudDoc2);
        System.assertEquals('test folder 1', cloudDoc2.FolderName__c);
        System.assertEquals('test filte type 1', cloudDoc2.fileName__c);
        System.assertEquals(false, cloudDoc2.IsVerified__c);
        System.assertEquals(false, cloudDoc2.ExternalDocument__c);
            
            
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new AzureCalloutMock());
        
        FileUploadListController.changeFileType(cloudDocList[0].Id, 'new folder', 'test file name', true, true, fileWrapper);
        
        CloudDocument__c updatedDoc = [Select Id, DecodedFileLocation__c, Filetype__c, FolderName__c, fileName__c, FileContentPrefix__c, IsVerified__c, ExternalDocument__c from CloudDocument__c where Id =: cloudDocList[0].Id];
        
        System.assertNotEquals(null, updatedDoc);
        System.assertEquals('new folder', updatedDoc.FolderName__c);
        System.assertEquals('test file name.pdf', updatedDoc.fileName__c);
        System.assertEquals(true, updatedDoc.IsVerified__c);
        System.assertEquals(true, updatedDoc.ExternalDocument__c);
        
        Test.stopTest();
    }
    
    /*
	@description    Test method for changeFileType when not uploading a new file and only updating its related information
	*/
    @IsTest
    private static void test_changeFileType_onlyFileDetailsUploaded(){
        
        List<Account> accList = TestDataFactory.createAccounts(1, true);
        List<Contact> conList = TestDataFactory.createContacts(accList[0].Id, 1, true);
        
        List<CloudDocument__c> cloudDocList = TestDataFactory.createCloudDocument(conList[0].Id, 1, true);
        
        CloudDocument__c cloudDoc2 = [Select Id, DecodedFileLocation__c, Filetype__c, FolderName__c, fileName__c, FileContentPrefix__c, IsVerified__c, ExternalDocument__c from CloudDocument__c where Id =: cloudDocList[0].Id];
        
        System.assertNotEquals(null, cloudDoc2);
        System.assertEquals('test folder 1', cloudDoc2.FolderName__c);
        System.assertEquals('test filte type 1', cloudDoc2.fileName__c);
        System.assertEquals(false, cloudDoc2.IsVerified__c);
        System.assertEquals(false, cloudDoc2.ExternalDocument__c);
            
            
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new AzureCalloutMock());
        
        FileUploadListController.changeFileType(cloudDocList[0].Id, 'new folder', 'test file name', true, true, null);
        
        CloudDocument__c updatedDoc = [Select Id, DecodedFileLocation__c, Filetype__c, FolderName__c, fileName__c, FileContentPrefix__c, IsVerified__c, ExternalDocument__c from CloudDocument__c where Id =: cloudDocList[0].Id];
        
        System.assertNotEquals(null, updatedDoc);
        System.assertEquals('new folder', updatedDoc.FolderName__c);
        System.assertEquals('test file name', updatedDoc.fileName__c);
        System.assertEquals(true, updatedDoc.IsVerified__c);
        System.assertEquals(true, updatedDoc.ExternalDocument__c);
        
        Test.stopTest();
    }
    
    /*
	@description    Test method for getFileById which returns file blob and its body
	*/
    @IsTest
    private static void test_getFileById(){
        
        List<Account> accList = TestDataFactory.createAccounts(1, true);
        List<Contact> conList = TestDataFactory.createContacts(accList[0].Id, 1, true);
        
        List<CloudDocument__c> cloudDocList = TestDataFactory.createCloudDocument(conList[0].Id, 1, true);

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new AzureCalloutMock());
        
        FileUploadWrapper.FileFetchWrapper result = FileUploadListController.getFileById(cloudDocList[0].Id);
        
        String fileContent = EncodingUtil.base64Encode(Blob.valueof('test content body'));
        System.assertNotEquals(null, result);
        System.assertEquals(true, result.wasFileFound);
        System.assertEquals('NW', result.filePrefix);
        System.assertEquals('test filte type 1', result.filename);
        System.assertEquals(fileContent, result.fileContent);
        
        Test.stopTest();
    }
    
    /*
	@description    Test method for getFileTypes which retrun Document file type options from metadata record
	*/
    @IsTest
    private static void test_getFileTypes(){
        
        List<Utility.PicklistOption> result = FileUploadListController.getFileTypes();
        
        System.assertNotEquals(null, result);
    }
    
    /*
	@description    Test method for getFileTypes which retrun Document file type options from metadata record
	*/
    @IsTest
    private static void test_getFileTypesSpanish(){
        
        List<Utility.PicklistOption> result = FileUploadListController.getFileTypesSpanish();
        
        System.assertNotEquals(null, result);
    }
    
    /*
	@description    Test method for deleteRecord which deletes document details from salesforce and Azure system
	*/
    @IsTest
    private static void test_deleteRecord_success(){
        List<Account> accList = TestDataFactory.createAccounts(1, true);
        List<Contact> conList = TestDataFactory.createContacts(accList[0].Id, 1, true);
        List<CloudDocument__c> cloudDocList = TestDataFactory.createCloudDocument(conList[0].Id, 1, true);
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new AzureCalloutDeleteMock());
        FileUploadListController.deleteRecord(cloudDocList[0].Id);
        List<CloudDocument__c> cdList = [SELECT Id FROM CloudDocument__c];
        System.assertEquals(cdList.size(), 0);
        Test.stopTest();
    }
    
    /*
	@description    Mock Class for Upload Dcoument to Azure
	*/
    public class AzureCalloutMock implements HttpCalloutMock{
        public HttpResponse respond(HttpRequest req){
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type','application/json');
            res.setBody('test content body');
            res.setStatusCode(201);
            return res;
        }
    }
    
    /*
	@description    Mock Class for Delete Dcoument from Azure
	*/
    public class AzureCalloutDeleteMock implements HttpCalloutMock{
        public HttpResponse respond(HttpRequest req){
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type','application/json');
            res.setBody('test content body');
            res.setStatusCode(202);
            return res;
        }
    }
    
    @IsTest
    static void verifyIsDeleteAccess() {
        Test.startTest();
        Boolean isDeleteAccess = FileUploadListController.isDeleteAccess();
        Test.stopTest();
    }
}