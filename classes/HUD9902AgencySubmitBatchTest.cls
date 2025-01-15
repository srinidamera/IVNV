@IsTest
public class HUD9902AgencySubmitBatchTest {
    
    @testSetup 
    static void setup() {
        
        IntegrationSettings__c settings = TestDataFactory.createIntegrationSettings(true);
        List<X9902__c> x9902recs = TestDataFactory.createX9902(1, true);
        String currentYear = String.valueOf(Date.today().adddays(365).year());
        List<HUD9902FiscalYear__c> fiscalYear = TestDataFactory.createHUD9902FiscalYear(currentYear.subString(2), currentYear, 1, true);
        
        List<X9902Agency__c> agencyRecs = new List<X9902Agency__c>();
        
        List<X9902Agency__c> x9902Agency1 = TestDataFactory.createX9902Agency(1, false, x9902recs[0].Id, 'Profile');
        List<X9902Agency__c> x9902Agency2 = TestDataFactory.createX9902Agency(1, false, x9902recs[0].Id, 'Contact');
        
        agencyRecs.add(x9902Agency1[0]);
        agencyRecs.add(x9902Agency2[0]);
        
        insert agencyRecs;
        
        
    }
    
    @isTest
    static void testBatch() {
        X9902__c x9902 = [SELECT id FROM X9902__c Limit 1];
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        HUD9902AgencySubmitBatch batch = new HUD9902AgencySubmitBatch(x9902.Id);
        Database.executeBatch(batch);
        Test.stopTest();
    }

}