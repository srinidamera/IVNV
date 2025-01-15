@isTest
public class HudGenerateAndSubmitControllerTest {
    @testSetup static void dataSetup() {
        IntegrationSettings__c mc   = new IntegrationSettings__c();
        mc.Name = 'HUD Settings';
        mc.AgencyID__c = '123123';
        mc.EndpointURL__c = 'www.google.com'; 
        mc.VendorID__c = '123123';
        mc.AgencyName__c = 'TEST';
        mc.CMSPassword__c = 'test';
        mc.Username__c = 'test';
        mc.Password__c = 'test';
        insert mc;
        
        String currentYear = String.valueOf(Date.today().adddays(365).year());
        List<HUD9902FiscalYear__c> fiscalYear = TestDataFactory.createHUD9902FiscalYear(currentYear.subString(2), currentYear, 1, true);
        TestDataFactory.createHUD9902FiscalYear(currentYear.subString(2), String.valueOf(Date.today().year()), 1, true);
    
    }
    @isTest
    static void testExecuteSubmissionBatch1() {
        // Setup test data
        X9902__c x9902 = TestDataFactory.createX9902(1, false)[0];
        x9902.PeriodEndDate__c = Date.today().adddays(365);
        insert x9902;
        TestDataFactory.createX9902Agency(1,true,x9902.Id,'Profile');
        TestDataFactory.createX9902Agency(1,true,x9902.Id,'Contact');
        String reportId = x9902.Id;
        Map<String, Boolean> batchChecks = new Map<String, Boolean>{
            HudGenerateAndSubmitController.JOBKEY_AGENCY => true,
            HudGenerateAndSubmitController.JOBKEY_CLIENT => false,
            HudGenerateAndSubmitController.JOBKEY_COUNSELOR => false,
            HudGenerateAndSubmitController.JOBKEY_SUMMARY => false
        };
        
        // Call the method
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        Map<String, String> result = HudGenerateAndSubmitController.executeSubmissionBatch(reportId, batchChecks);
        Test.stopTest();
        
        // Assert results
        //System.assertNotEquals(null, result.get(HudGenerateAndSubmitController.JOBKEY_AGENCY));
    }
    @isTest
    static void testExecuteSubmissionBatch2() {
        // Setup test data
        X9902__c x9902 = TestDataFactory.createX9902(1, false)[0];
        insert x9902;
        String reportId = x9902.Id;
        Map<String, Boolean> batchChecks = new Map<String, Boolean>{
            HudGenerateAndSubmitController.JOBKEY_AGENCY => false,
            HudGenerateAndSubmitController.JOBKEY_CLIENT => true,
            HudGenerateAndSubmitController.JOBKEY_COUNSELOR => false,
            HudGenerateAndSubmitController.JOBKEY_SUMMARY => false
        };
        
        // Call the method
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        Map<String, String> result = HudGenerateAndSubmitController.executeSubmissionBatch(reportId, batchChecks);
        Test.stopTest();
        
        // Assert results
        //System.assertNotEquals(null, result.get(HudGenerateAndSubmitController.JOBKEY_AGENCY));
    }
    @isTest
    static void testExecuteSubmissionBatch3() {
        // Setup test data
        X9902__c x9902 = TestDataFactory.createX9902(1, false)[0];
        x9902.PeriodEndDate__c = Date.today();
        insert x9902;
        String reportId = x9902.Id;
        Map<String, Boolean> batchChecks = new Map<String, Boolean>{
            HudGenerateAndSubmitController.JOBKEY_AGENCY => false,
            HudGenerateAndSubmitController.JOBKEY_CLIENT => false,
            HudGenerateAndSubmitController.JOBKEY_COUNSELOR => true,
            HudGenerateAndSubmitController.JOBKEY_SUMMARY => false
        };
        
        // Call the method
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        Map<String, String> result = HudGenerateAndSubmitController.executeSubmissionBatch(reportId, batchChecks);
        Test.stopTest();
        
        // Assert results
        //System.assertNotEquals(null, result.get(HudGenerateAndSubmitController.JOBKEY_AGENCY));
    }
    @isTest
    static void testExecuteSubmissionBatch4() {
        // Setup test data
        X9902__c x9902 = TestDataFactory.createX9902(1, false)[0];
        insert x9902;
        String reportId = x9902.Id;
        Map<String, Boolean> batchChecks = new Map<String, Boolean>{
            HudGenerateAndSubmitController.JOBKEY_AGENCY => false,
            HudGenerateAndSubmitController.JOBKEY_CLIENT => false,
            HudGenerateAndSubmitController.JOBKEY_COUNSELOR => false,
            HudGenerateAndSubmitController.JOBKEY_SUMMARY => true
        };
        
        // Call the method
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        Map<String, String> result = HudGenerateAndSubmitController.executeSubmissionBatch(reportId, batchChecks);
        Test.stopTest();
        
        // Assert results
        //System.assertNotEquals(null, result.get(HudGenerateAndSubmitController.JOBKEY_AGENCY));
    }

    @isTest
    static void testExecuteBatch() {
        // Setup test data
        X9902__c x9902 = TestDataFactory.createX9902(1, false)[0];
        insert x9902;
        String reportId = x9902.id;
        
        AgencyProfile__c agencyProfile = new AgencyProfile__c();
        
        agencyProfile.Name = 'testAgency';
        agencyProfile.AgencyPhoneNumber__c = '1231231231';
        agencyProfile.AgencyTollFreePhone__c = '1231231231';
        agencyProfile.AgencyFAXNumber__c = '1231231231';
        agencyProfile.AgencyWebsite__c = 'http://www.google.com';
        insert agencyProfile;
        
        Map<String, Boolean> batchChecks = new Map<String, Boolean>{
            HudGenerateAndSubmitController.JOBKEY_AGENCY => true,
            HudGenerateAndSubmitController.JOBKEY_CLIENT => false,
            HudGenerateAndSubmitController.JOBKEY_COUNSELOR => false,
            HudGenerateAndSubmitController.JOBKEY_SUMMARY => false
        };
        
        // Call the method
        Test.startTest();
        Map<String, String> result = HudGenerateAndSubmitController.executeBatch(reportId, batchChecks);
        Test.stopTest();
        
        // Assert results
        //System.assertNotEquals(null, result.get(HudGenerateAndSubmitController.JOBKEY_CLIENT));
    }

    @isTest
    static void testGetJobDetails() {
        // Setup test data
        X9902__c x9902 = TestDataFactory.createX9902(1, false)[0];
        insert x9902;
        String reportId = x9902.Id;
        
        TestDataFactory.createX9902Agency(1,true,x9902.Id,'Profile');
        TestDataFactory.createX9902Agency(1,true,x9902.Id,'Contact');
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        HUD9902AgencySubmitBatch agencySubmitBatch = new HUD9902AgencySubmitBatch(reportId);
        String batchId = Database.executeBatch(agencySubmitBatch, 1);
        Map<String, String> batchJobMap = new Map<String, String>{
            HudGenerateAndSubmitController.JOBKEY_AGENCY => batchId,
            HudGenerateAndSubmitController.JOBKEY_CLIENT => batchId,
            HudGenerateAndSubmitController.JOBKEY_COUNSELOR => batchId,
            HudGenerateAndSubmitController.JOBKEY_SUMMARY => batchId
        };
        Map<String, Boolean> batchChecks = new Map<String, Boolean>{
            HudGenerateAndSubmitController.JOBKEY_AGENCY => true,
            HudGenerateAndSubmitController.JOBKEY_CLIENT => true,
            HudGenerateAndSubmitController.JOBKEY_COUNSELOR => true,
            HudGenerateAndSubmitController.JOBKEY_SUMMARY => true
        };
        
        // Call the method
        Test.startTest();
        Map<String, AsyncApexJob> result = HudGenerateAndSubmitController.getJobDetails(batchJobMap, batchChecks);
        Test.stopTest();
        
        // Assert results
        System.assertNotEquals(null, result.get(HudGenerateAndSubmitController.JOBKEY_AGENCY));
    }

    @isTest
    static void testGetValidationErrors() {
        // Setup test data
        String sobjectName = 'Contact';
        X9902__c x9902 = TestDataFactory.createX9902(1, false)[0];
        insert x9902;
        String reportId = x9902.Id;
        
        // Call the method
        Test.startTest();
        Map<String, List<SObject>> result = HudGenerateAndSubmitController.getValidationErrors(sobjectName, reportId);
        Test.stopTest();
        
        // Assert results
        System.assertNotEquals(null, result.get('Contact'));
    }
    
     @isTest
    static void testUpdate9902Status() {
        // Step 1: Create a test X9902__c record
        X9902__c x9902 = TestDataFactory.createX9902(1, false)[0];
        insert x9902;

        // Prepare the batchJobStatusMap and batchChecks
        Map<String, String> batchJobStatusMap = new Map<String, String>{
            'Agency' => 'Completed',
            'Client' => 'Failed',
            'Counselor' => 'Completed',
            'Summary' => 'In Progress'
        };
        Map<String, Boolean> batchChecks = new Map<String, Boolean>{
            'Agency' => true,
            'Client' => true,
            'Counselor' => true,
            'Summary' => true
        };

        // Serialize and Deserialize the Maps
        String batchJobStatusString = JSON.serialize(batchJobStatusMap);
        Map<String, String> deserializedBatchJobStatusMap = (Map<String, String>)JSON.deserialize(batchJobStatusString, Map<String, String>.class);

        String batchChecksString = JSON.serialize(batchChecks);
        Map<String, Boolean> deserializedBatchChecksMap = (Map<String, Boolean>)JSON.deserialize(batchChecksString, Map<String, Boolean>.class);

        Test.startTest();
        HudGenerateAndSubmitController.update9902Status(deserializedBatchJobStatusMap, deserializedBatchChecksMap, x9902.Id);
        Test.stopTest();
        x9902 = [SELECT Id, AgencyGenerationStatus__c, ClientGenerationStatus__c, CounselorGenerationStatus__c, Summary9902GenerationStatus__c FROM X9902__c WHERE Id = :x9902.Id];
        System.debug('Updated X9902__c record: ' + x9902);

        System.assertEquals('Completed', x9902.AgencyGenerationStatus__c);
    }
    
    
}