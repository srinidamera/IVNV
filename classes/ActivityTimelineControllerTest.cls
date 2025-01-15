@isTest
public class ActivityTimelineControllerTest {
    
    @testSetup static void setup() {
        
        Account acc = TestDataFactory.createAccounts(1, true)[0];
        List<Contact> testContacts = TestDataFactory.createContacts(acc.id,2, true);
        
        Contact con = testContacts[0];
        con.LastName = 'Test';
        update con;
        Contact con2 = testContacts[1];
        
        Id recordTypeId = [SELECT Id FROM RecordType WHERE DeveloperName = 'Event' AND SobjectType = 'sumoapp__AdditionalInfo__c' LIMIT 1]?.Id;
        sumoapp__AdditionalInfo__c info = TestDataFactory.createSumoEvent(1 , false)[0];
        info.sumoapp__StartDatetime__c = System.now().addMinutes(-30);
        info.RecordTypeId = recordTypeId;
        insert info;
        
        sumoapp__Attendee__c attendee = TestDataFactory.createAttendee(con, info.id, 1,  true)[0]; 
        sumoapp__Service__c service = new sumoapp__Service__c();
        service.Name = 'Appointment';
        insert service;
        
        sumoapp__AdditionalInfo__c info1 = TestDataFactory.createSumoEvent(1, false)[0];
        info1.RecordTypeId = recordTypeId;
        info1.sumoapp__Service__c = service.Id;
        insert info1;
        
        List<ClientCase__c> clientCaseList = TestDataFactory.createClientCases(1, true);
        
        Event evt = TestDataFactory.createEvent(con, NULL, 1, FALSE)[0];
        evt.sumoapp__AdditionalInfo__c = info.Id;
        insert evt;
        
        Event evt1 = TestDataFactory.createEvent(con, NULL, 1, FALSE)[0];
        evt1.sumoapp__AdditionalInfo__c = info.Id;
        insert evt1;
        
        Event evt2 = TestDataFactory.createEvent(con, NULL, 1, FALSE)[0];
        evt2.sumoapp__AdditionalInfo__c = info.Id;
        insert evt2;
        
        List<ClientCase__c> cases = TestDataFactory.createClientCases(1, true);
        //TestDataFactory.createCounselorNote(cases.get(0).Id, con.Id, 3, true);
        
        EventRelation er = new EventRelation();
        er.RelationId = con2.Id;
        er.EventId = evt.Id;
        insert er;
    }
    
    @isTest static void testGetEvents() {
        Contact con = [SELECT Id FROM Contact WHERE LastName = 'Test' LIMIT 1];
        List<ActivityTimelineService.ResultWrapper> result = ActivityTimelineController.getEvents(con.Id);
        System.assertNotEquals(null, result, 'Result should not be null');
        System.assertNotEquals(0, result.size(), 'Result list should not be empty');
    }
    
    @isTest static void testGetEventsSecond() {
        ClientCase__c clientCase = [SELECT Id FROM ClientCase__c LIMIT 1];
        List<ActivityTimelineService.ResultWrapper> result = ActivityTimelineController.getEvents(clientCase.Id);
        System.assertNotEquals(null, result, 'Result should not be null');
        // Add assertions based on expected results
    }
    
    @isTest static void testGetParticipants() {
        Id eventId = [SELECT EventId FROM EventRelation LIMIT 1]?.EventId;
        List<String> participants = ActivityTimelineController.getParticipants(eventId);
        System.assertNotEquals(null, participants, 'Participants list should not be null');
        System.assertNotEquals(0, participants.size(), 'Participants list should not be empty');
    }
    
    @isTest static void testUpdateAppointmentNotes() {
        Event evt = [SELECT Id, sumoapp__AdditionalInfo__c FROM Event LIMIT 1];
        
        // Replace with an actual valid picklist value
        String validOutcome = 'Households that received one-on-one counseling that also received education services.'; // Make sure this value exists in your picklist
        
        ActivityTimelineController.updateAppointmentNotes(
            evt.Id, 
            'Households that received one-on-one counseling that also received education services.', 
            validOutcome, 
            'Rental Topics', 
            'Attended', 
            60, 
            'Test notes',
            'NOFA 2015-1 COMP'
        );
        
        Event updatedEvent = [SELECT Id, Outcome__c, purpose__c, AppointmentDuration__c, AppointmentStatus__c, sumoapp__AdditionalInfo__c FROM Event WHERE Id = :evt.Id];
        sumoapp__AdditionalInfo__c additionalInfo = [SELECT Id, Notes__c FROM sumoapp__AdditionalInfo__c WHERE Id = :updatedEvent.sumoapp__AdditionalInfo__c];
    }
    
    @isTest static void testGetEventWrapper() {
        Event evt = [SELECT Id, sumoapp__AdditionalInfo__c FROM Event LIMIT 1];
        ActivityTimelineService.ActivityWrapper wrapper = ActivityTimelineController.getEventWrapper(evt.Id);
        System.assertNotEquals(null, wrapper, 'Wrapper should not be null');
        // Add additional assertions based on the expected results
        System.assertNotEquals(0, wrapper.participants.size(), 'Participants list should not be empty');
    }
    
    @isTest static void testGetAppointmentRecordTypeId() {
        Id recordTypeId = ActivityTimelineController.getAppointmentRecordTypeId();
        System.assertNotEquals(null, recordTypeId, 'Record Type Id should not be null');
        System.assertEquals('Appointment', [SELECT Name FROM RecordType WHERE Id = :recordTypeId].Name, 'Record Type Name should be Appointment');
    }

    @IsTest
    static void verifyIsIntakeStaffUser() {
        Test.startTest();
        Boolean isIntakeStaffUser = ActivityTimelineController.isIntakeStaffUser();
        Test.stopTest();
    }
}