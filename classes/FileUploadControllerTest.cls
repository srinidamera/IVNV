/*
	@description    Test Class for  FileUploadController apex class 
*/
@isTest
public class FileUploadControllerTest {
    
    /*
	@description    This method is for setting up data for testing in the test class  	
	*/
	@TestSetup
    public static void dataSetup(){
        List<Account> lstAcc = TestDataFactory.createAccounts(1, true);
        List<Contact> con = TestDataFactory.createContacts(lstAcc[0].id, 1, true);
        DocumentStorageSetting__c setting = new DocumentStorageSetting__c();
        setting.AccountSharedKey__c = 'test';
        setting.ContainerName__c =  'test';
        setting.StorageName__c =  'test';
        setting.StorageInstanceURL__c =  'test';
        insert setting;
        
        TestDataFactory.createClientCases(1, true);
        TestDataFactory.createIntakes(con[0], lstAcc[0].id, 1, true);
    }
    
    /*
	@description    This method tests the uploadFilesToStorage method.
*/
    testMethod static void testUploadFilesToStorage(){
        Test.setMock(HttpCalloutMock.class, new FileUploadMock());
        List<Contact> lstCon = [SELECT Id FROM Contact LIMIT 1];
        Test.startTest();
        FileUploadWrapper.AzureFileUploadWrapper fileWrapper =new FileUploadWrapper.AzureFileUploadWrapper();
        fileWrapper =new FileUploadWrapper.AzureFileUploadWrapper();  
        fileWrapper.filename = 'ors12';
        fileWrapper.filecontent = '';
        fileWrapper.fileextension = 'pdf';
        fileWrapper.option = 'Other';
        fileWrapper.externalDoc = true;
        fileWrapper.isVerified = true;
        fileWrapper.filelength = '10000';
        fileWrapper.fileType = 'pdf';
        fileWrapper.uniqueId = lstCon[0].Id;
        fileWrapper.fileprefix = 'data:pdf;base64';
        FileUploadController.uploadFilesToStorage(fileWrapper);
        List<CloudDocument__c> cdList = [SELECT Id FROM CloudDocument__c];
        System.assertEquals(cdList.size(), 1);
        FileUploadController.uploadFilesToStorage(new FileUploadWrapper.AzureFileUploadWrapper());
        Test.stopTest();
    }
    
    testMethod static void testClientCase(){
        Test.setMock(HttpCalloutMock.class, new FileUploadMock());
        List<ClientCase__c> ClientCase = [SELECT Id FROM ClientCase__c LIMIT 1];
        Test.startTest();
        FileUploadWrapper.AzureFileUploadWrapper fileWrapper =new FileUploadWrapper.AzureFileUploadWrapper();
        fileWrapper =new FileUploadWrapper.AzureFileUploadWrapper();  
        fileWrapper.filename = 'ors12';
        fileWrapper.filecontent = '';
        fileWrapper.fileextension = 'pdf';
        fileWrapper.option = 'Other';
        fileWrapper.externalDoc = true;
        fileWrapper.isVerified = true;
        fileWrapper.filelength = '10000';
        fileWrapper.fileType = 'pdf';
        fileWrapper.uniqueId = ClientCase[0].Id;
        fileWrapper.fileprefix = 'data:pdf;base64';
        FileUploadController.uploadFilesToStorage(fileWrapper);
        List<CloudDocument__c> cdList = [SELECT Id FROM CloudDocument__c];
        FileUploadController.uploadFilesToStorage(new FileUploadWrapper.AzureFileUploadWrapper());
        Test.stopTest();
    }
    
    testMethod static void testIntake(){
        Test.setMock(HttpCalloutMock.class, new FileUploadMock());
        List<Intake__c> Intake = [SELECT Id FROM Intake__c LIMIT 1];
        Test.startTest();
        FileUploadWrapper.AzureFileUploadWrapper fileWrapper =new FileUploadWrapper.AzureFileUploadWrapper();
        fileWrapper =new FileUploadWrapper.AzureFileUploadWrapper();  
        fileWrapper.filename = 'ors12';
        fileWrapper.filecontent = '';
        fileWrapper.fileextension = 'pdf';
        fileWrapper.option = 'Other';
        fileWrapper.externalDoc = true;
        fileWrapper.isVerified = true;
        fileWrapper.filelength = '10000';
        fileWrapper.fileType = 'pdf';
        fileWrapper.uniqueId = Intake[0].Id;
        fileWrapper.fileprefix = 'data:pdf;base64';
        FileUploadController.uploadFilesToStorage(fileWrapper);
        List<CloudDocument__c> cdList = [SELECT Id FROM CloudDocument__c];
        FileUploadController.uploadFilesToStorage(new FileUploadWrapper.AzureFileUploadWrapper());
        Test.stopTest();
    }
    
    /*
	@description    This class returns mock response for file upload.
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
}