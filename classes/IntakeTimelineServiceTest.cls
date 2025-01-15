@isTest
public class IntakeTimelineServiceTest {
	
    @TestSetup
    static void setupTestData() {
       	
        Account acc = TestDataFactory.createAccounts(1, true)[0];
        Contact con = TestDataFactory.createContacts(acc.id, 1, true)[0];
        //ClientCase__c clientCase = [SELECT Id FROM ClientCase__c LIMIT 1];
        List<Intake__c> intake = TestDataFactory.createIntakes(con, acc.Id, 1, true);
        Id recordTypeId = [SELECT Id FROM RecordType WHERE DeveloperName = 'Event' AND SobjectType = 'sumoapp__AdditionalInfo__c' LIMIT 1]?.Id;
        sumoapp__AdditionalInfo__c info = TestDataFactory.createSumoEventInfo(1, true)[0];
        
        Event evt = TestDataFactory.createEvent(con, info.Id, 1, false)[0];
        evt.whatId = intake.get(0).id;
        insert evt;
    }
    
    
    @IsTest
    static void testGetAppointments() {
        Intake__c  intake = [SELECT Id FROM Intake__c LIMIT 1];
        IntakeTimelineService service = new IntakeTimelineService();
        service.getAppointments(intake.Id);
    }
    
    @IsTest
    static void testGetCounselorNotes() {
        Intake__c  intake = [SELECT Id FROM Intake__c LIMIT 1];
        IntakeTimelineService service = new IntakeTimelineService();
        service.getCounselorNotes(intake.Id);
    }
    
    @IsTest
    static void testGetCourses() {
        Intake__c  intake = [SELECT Id FROM Intake__c LIMIT 1];
        IntakeTimelineService service = new IntakeTimelineService();
        service.getCourses(intake.Id);
    }
}