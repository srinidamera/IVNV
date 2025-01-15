@isTest
public class HUD9902ClientSubmissionBatchTest {
    
    @testSetup static void setup() {
        
        /*IntegrationSettings__c settings = new IntegrationSettings__c(
            Name = 'HUD Settings',
            EndpointURL__c = 'https://example.com/endpoint',
            AgencyID__c = '12345',
            AgencyName__c = 'Test Agency',
            VendorID__c = '67890',
            CMSPassword__c = 'password',
            Username__c = 'testuser',
            Password__c = 'testpassword'
        );
        insert settings;
        IntegrationSettings__c mc = new IntegrationSettings__c(
            Name = 'HUD Settings',
            AgencyID__c = '12345',
            AgencyName__c = 'Test Agency',
            VendorID__c = '67890',
            CMSPassword__c = 'password'
        );
        insert mc;*/
        IntegrationSettings__c settings = TestDataFactory.createIntegrationSettings(true);
        X9902__c x9902 = new X9902__c(
            PeriodEndDate__c = Date.newInstance(2028, 8, 1)
        );
        insert x9902;
        
        X9902Client__c x9902Client = new X9902Client__c(
            X9902__c = x9902.Id,
            ClientIDNumber__c = 'Client123'
        );
        insert x9902Client;
        
        HUD9902FiscalYear__c fiscalYear = new HUD9902FiscalYear__c(
            FiscalYearID__c = '28',
            Name = '2028'
        );
        insert fiscalYear;
        
    }
    @isTest
    static void testBatch() {
        X9902__c x9902 = [SELECT id FROM X9902__c Limit 1];
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        HUD9902ClientSubmissionBatch batch = new HUD9902ClientSubmissionBatch(x9902.Id);
        Database.executeBatch(batch);
        Test.stopTest();
    }
}