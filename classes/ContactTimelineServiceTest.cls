@isTest
public class ContactTimelineServiceTest {
    
    @testSetup
    static void setupTestData() {
        
        List<ClientCase__c> clientCase = TestDataFactory.createClientCases(1, false);
        clientCase[0].CounselingTermination__c = 'Completed';
        insert clientCase;
        
        Account acc = TestDataFactory.createAccounts(1, true)[0];
        Contact con = TestDataFactory.createContacts(acc.id, 1, true)[0];
        
        
        sumoapp__AdditionalInfo__c sumoEvent = TestDataFactory.createSumoEvent(1, true)[0];
        TestDataFactory.createAttendee(con, sumoEvent.id, 1, true);
        //TestDataFactory.createCounselorNote(con, clientCase, 1, true);
        
        List<Event> evt = TestDataFactory.createEvent(con, sumoEvent.id, 1, true);
        
        EventRelation er = new EventRelation(EventId = evt[0].Id, RelationId = con.Id);
        //insert er;
        
    }

    @isTest
    static void testGetAppointments() {
        Contact testContact = [SELECT Id FROM Contact LIMIT 1];
        ContactTimelineService service = new ContactTimelineService();

        Test.startTest();
        service.getAppointments(testContact.Id);
        Test.stopTest();
    }

    @isTest
    static void testGetCourses() {
        Contact testContact = [SELECT Id FROM Contact LIMIT 1];
        ContactTimelineService service = new ContactTimelineService();

        Test.startTest();
        service.getCourses(testContact.Id);
        Test.stopTest();
    }

    @isTest
    static void testGetCounselorNotes() {
        Contact testContact = [SELECT Id FROM Contact LIMIT 1];
        ContactTimelineService service = new ContactTimelineService();

        Test.startTest();
        service.getCounselorNotes(testContact.Id);
        Test.stopTest();
    }
}