@IsTest
public class HUD9902CounselorSubmitBatchTest {
	@testSetup 
    static void setup() {
        IntegrationSettings__c settings = TestDataFactory.createIntegrationSettings(true);
        List<X9902__c> x9902recs = TestDataFactory.createX9902(1, true);
        
        List<X9902Counselor__c> counselorRecs = new List<X9902Counselor__c>();
        
        List<X9902Counselor__c> counselor1 = TestDataFactory.createX9902Counselor(1, false, x9902recs[0].Id, 'Profile');
        List<X9902Counselor__c> counselor2 = TestDataFactory.createX9902Counselor(1, false, x9902recs[0].Id, 'Training Course');
        List<X9902Counselor__c> counselor3 = TestDataFactory.createX9902Counselor(1, false, x9902recs[0].Id, 'Training');
        
        counselorRecs.add(counselor1[0]);
        counselorRecs.add(counselor2[0]);
        counselorRecs.add(counselor3[0]);
        
        insert counselorRecs;
        
        String currentYear = String.valueOf(System.now().year());
        List<HUD9902FiscalYear__c> fiscalYear = TestDataFactory.createHUD9902FiscalYear(currentYear.subString(2), currentYear, 1, true);
    }
    
    @isTest
    static void testBatch() {
        X9902__c x9902 = [SELECT id FROM X9902__c Limit 1];
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        HUD9902CounselorSubmitBatch batch = new HUD9902CounselorSubmitBatch(x9902.Id);
        Database.executeBatch(batch);
        Test.stopTest();
    }
}