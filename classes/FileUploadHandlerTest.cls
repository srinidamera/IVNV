/*
	@description    Test Class for  FileUploadHandler apex class 
*/
@isTest
public class FileUploadHandlerTest {
	@TestSetup
    public static void dataSetup(){
        List<Account> lstAcc = TestDataFactory.createAccounts(1, true);
        TestDataFactory.createContacts(lstAcc[0].Id, 20, true);
        DocumentStorageSetting__c dss = new DocumentStorageSetting__c();
        dss.AccountSharedKey__c = 'test';
        dss.ContainerName__c = 'test';
        dss.StorageName__c = 'test';
        dss.StorageInstanceURL__c = 'test';
        insert dss;
    }
    
    /*
	@description    This method tests the putfileInAzure method.
	*/
    testMethod static void testPutfileInAzure(){
        Test.setMock(HttpCalloutMock.class, new FileUploadMock());
        List<Contact> lstCon = [SELECT Id FROM Contact LIMIT 20];
        Test.startTest();
        for (Integer i=0; i< 20; i++){
            boolean fileUploaded = FileUploadHandler.putfileInAzure('ors14', '.pdf', '20', EncodingUtil.base64Decode(''), 'pdf', 'Tax Return', lstCon[i].Id);
            System.assertEquals(fileUploaded, true);
        }
        Test.stopTest();
    }
    
    /*
	@description    This method tests the createCloudDocument method.
	*/
    testMethod static void createCloudDocumentTest(){
        List<Contact> lstCon = [SELECT Id FROM Contact LIMIT 20];
        List<CloudDocument__c> cdList = TestDataFactory.createCloudDocument(lstCon[0].Id, 20, true);
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new FileUploadMock());
        for (Integer i=0; i< 20; i++){
            FileUploadWrapper.FileFetchWrapper fuw = FileUploadHandler.getFileById(cdList[i].Id);
            System.assertEquals(fuw.wasFileFound, true);
        }
        Test.stopTest();
    }
    
    /*
	@description    This method tests the getDelete method.
	*/
    testMethod static void getDeleteTest(){
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new FileDeleteMock());
        for (Integer i=0; i< 20; i++){
            boolean fileDeleted = FileUploadHandler.getDelete('filename');
            System.assertEquals(fileDeleted, true);
        }
        Test.stopTest();
    }
    
    /*
	@description    This method tests the negative scenarios in the methods and helps improving code coverage.
	*/
    testMethod static void allTest(){
        List<Contact> lstCon = [SELECT Id FROM Contact LIMIT 1];
        List<CloudDocument__c> cdList = TestDataFactory.createCloudDocument(lstCon[0].Id, 1, true);
        Test.startTest();
        boolean fileDeleted = FileUploadHandler.getDelete('filename');
        FileUploadWrapper.FileFetchWrapper fuw = FileUploadHandler.getFileById(cdList[0].Id);
        boolean fileUploaded = FileUploadHandler.putfileInAzure('ors14', '.pdf', '20', EncodingUtil.base64Decode(''), 'pdf', 'Tax Return', lstCon[0].Id);
        System.assertEquals(fileDeleted, false);
        System.assertEquals(fileUploaded, false);
        Test.stopTest();
    }
    
    /*
	@description    This class returns mock response for file upload and get file.
	*/
    public class FileUploadMock implements HttpCalloutMock {
    	public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"example":"test"}');
            res.setStatusCode(201);
            return res;
        }
    }
    /*
	@description    This class returns mock response for file delete.
	*/
    public class FileDeleteMock implements HttpCalloutMock {
    	public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"example":"test"}');
            res.setStatusCode(202);
            return res;
        }
    }
}