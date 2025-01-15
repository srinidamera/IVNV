@isTest(SeeAllData=false)
public class HUD9902CounselorReportGenerateBatchTest {
    
    @testSetup
    static void setupData() {
        Profile adminProfile = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        List<User> adminUser = new List<User>();
        adminUser = TestDataFactory.createUsers(adminProfile.Id, '', 2, false);
        
        // Generate unique CMSCounselorID__c dynamically with leading zeros
        adminUser[0].isActive = true;
        adminUser[0].IsCounselor__c = true;
        adminUser[0].CounselorHUDID__c = '123401';
        adminUser[0].CMSCounselorID__c = String.valueOf(Math.round(Math.random() * 99999));  
        if (adminUser[0].CMSCounselorID__c.length() < 5) {
            adminUser[0].CMSCounselorID__c = '0'.repeat(5 - adminUser[0].CMSCounselorID__c.length()) + adminUser[0].CMSCounselorID__c;
        }
        adminUser[0].EmploymentEndDate__c = Date.today();
        adminUser[0].EmploymentStartDate__c = Date.today().addYears(-1);
        
        adminUser[1].isActive = true;
        adminUser[1].IsCounselor__c = true;
        adminUser[1].CounselorHUDID__c = '123402';
        adminUser[1].CMSCounselorID__c = String.valueOf(Math.round(Math.random() * 99999)); 
        if (adminUser[1].CMSCounselorID__c.length() < 5) {
            adminUser[1].CMSCounselorID__c = '0'.repeat(5 - adminUser[1].CMSCounselorID__c.length()) + adminUser[1].CMSCounselorID__c;
        }
        adminUser[1].EmploymentEndDate__c = Date.today();
        adminUser[1].EmploymentStartDate__c = Date.today().addYears(-1);
        
        insert adminUser;
    }
    
    @isTest
    static void testBatch() {
        // Use the CMSCounselorID__c values generated in the test setup
        List<User> adminUser = [Select Id from User where CounselorHUDID__c in ('123401', '123402') limit 2];
        
        // Create Counselor Training records associated with Users
        List<CounselorTraining__c> trainingRecords = new List<CounselorTraining__c>();
        for (User u : adminUser) {
            List<CounselorTraining__c> rec = TestDataFactory.createCounselorTraining(1, false, u.Id);
            trainingRecords.add(rec[0]);
        }
        insert trainingRecords;
        
        List<X9902__c> x9902recs = TestDataFactory.createX9902(1, true);
        sumoapp__AdditionalInfo__c AdditionalInfo = TestDataFactory.createSumoEvent(1, false)[0];
        
        AdditionalInfo.RecordTypeId = Schema.SObjectType.sumoapp__AdditionalInfo__c.getRecordTypeInfosByName().get('Course').getRecordTypeId();
        AdditionalInfo.sumoapp__EndDatetime__c = DateTime.newInstance(2024, 1, 15).addDays(5);
        AdditionalInfo.Facilitator__c = adminUser[0].Id;
        AdditionalInfo.sumoapp__StartDatetime__c =  Date.Today();
        AdditionalInfo.sumoapp__EndDatetime__c =  Date.Today() + 3;
        AdditionalInfo.HUD_Purpose__c = 'Completed rental workshop';
        insert AdditionalInfo;

        
        // Initialize the batch class
        HUD9902CounselorReportGenerateBatch batch = new HUD9902CounselorReportGenerateBatch(x9902recs[0].Id);
        
        // Execute the batch
        Test.startTest();
        Database.executeBatch(batch);
        Test.stopTest();
        
        // Assert that X9902Counselor__c records were created
        Integer counselorCount = [SELECT COUNT() FROM X9902Counselor__c WHERE X9902__c = :x9902recs[0].Id];
        System.assertNotEquals(0, counselorCount);  // Ensure records are created
    }
}