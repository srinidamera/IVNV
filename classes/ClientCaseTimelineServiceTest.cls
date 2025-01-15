@IsTest
public class ClientCaseTimelineServiceTest {
    
    @TestSetup
    static void setupTestData() {
        List<ClientCase__c> clientCases = TestDataFactory.createClientCases(1, false);
        clientCases[0].CounselingTermination__c = 'Completed';
        insert clientCases;
        
        Account acc = TestDataFactory.createAccounts(1, true)[0];
        Contact con = TestDataFactory.createContacts(acc.id, 1, true)[0];
        ClientCase__c clientCase = [SELECT Id FROM ClientCase__c LIMIT 1];
        Id recordTypeId = [SELECT Id FROM RecordType WHERE DeveloperName = 'Event' AND SobjectType = 'sumoapp__AdditionalInfo__c' LIMIT 1]?.Id;
        sumoapp__AdditionalInfo__c info = TestDataFactory.createSumoEventInfo(1, true)[0];
        
        Event evt = TestDataFactory.createEvent(con, info.Id, 1, false)[0];
        evt.whatId = clientCase.id;
        insert evt;
    }
    
    @IsTest
    static void testGetAppointments() {
        ClientCase__c clientCase = [SELECT Id FROM ClientCase__c LIMIT 1];
        ClientCaseTimelineService service = new ClientCaseTimelineService();
        service.getAppointments(clientCase.Id);
    }
    
    @IsTest
    static void testGetCounselorNotes() {
        ClientCase__c clientCase = [SELECT Id FROM ClientCase__c LIMIT 1];
        ClientCaseTimelineService service = new ClientCaseTimelineService(); 
        service.getCounselorNotes(clientCase.Id);
    }
    
    @IsTest
    static void testGetCourses() {
        ClientCase__c clientCase = [SELECT Id FROM ClientCase__c LIMIT 1];
        ClientCaseTimelineService service = new ClientCaseTimelineService();
        service.getCourses(clientCase.Id);
    }
}