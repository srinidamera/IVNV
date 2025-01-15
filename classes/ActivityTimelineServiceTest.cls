@IsTest
public class ActivityTimelineServiceTest {
    
    
    @testSetup static void setup() {
        Account acc = TestDataFactory.createAccounts(1, true)[0];
        Contact con = TestDataFactory.createContacts(acc.id,2, true)[0];
        
        sumoapp__AdditionalInfo__c AdditionalInfo = TestDataFactory.createSumoEvent( 1, true)[0];
        TestDataFactory.createEvent(con, NULL, 1, true);
        TestDataFactory.createAttendee(con,AdditionalInfo.id, 1, true);
        List<ClientCase__c> clientCaseList = TestDataFactory.createClientCases(1, true);
        //TestDataFactory.createCounselorNote(con, clientCaseList[0], 1, true);
        
    }
    
    private class TestActivityTimelineService extends ActivityTimelineService {
        
        public override List<ActivityWrapper> getAppointments(Id recordId) {
            List<ActivityWrapper> appointments = new List<ActivityWrapper>();
            Event evt = [SELECT Id, WhoId, WhatId, Location, Subject, IsAllDayEvent, EndDateTime, OwnerId, IsGroupEvent, SystemModstamp, RecurrenceTimeZoneSidKey, RecurrenceDayOfMonth, Recurrence2PatternText, sumoapp__AdditionalInfo__c,
                         sumoapp__SumoId__c, sumoapp__StartDateTimeTimezone__c, AppointmentStatus__c, sumoapp__WhoIdIsNotArrived__c, sumoapp__OrganizerFullName__c, StartDateTime, AppointmentDuration__c, sumoapp__AdditionalInfo__r.Notes__c,
                         sumoapp__OrganizerTitle__c, Outcome__c, HUDActivityType__c, Purpose__c, Solution__c, ActionType__c, IsRecurrence2 FROM Event Limit 1];
            appointments.add(convertEventToWrapper(evt, null,null));
            return appointments;
        }
        
        public override List<ActivityWrapper> getCourses(Id recordId) {
            List<ActivityWrapper> courses = new List<ActivityWrapper>();
            sumoapp__Attendee__c attendee = [SELECT id, sumoapp__SumoEvent__c, sumoapp__EventName__c, sumoapp__StartDatetime__c, sumoapp__SumoEvent__r.RecordType.DeveloperName  FROM sumoapp__Attendee__c Limit 1];
            courses.add(convertCourseToWrapper(attendee));
            return courses;
        }
        
        public override List<ActivityWrapper> getCounselorNotes(Id recordId) {
            List<ActivityWrapper> notes = new List<ActivityWrapper>();
            ClientCase__c cc= [Select id, Name from ClientCase__c limit 1];
            Contact con = [Select Id From Contact LIMIT 1];
            notes.add(convertNoteToWrapper(TestDataFactory.createCounselorNote(con, cc, 1, false).get(0)));
            return notes;
        }
    } 
    
    @IsTest
    static void testGetAllEvents() {
        TestActivityTimelineService service = new TestActivityTimelineService();
        Id recordId = [SELECT id FROM Contact Limit 1].id;
        List<ActivityTimelineService.ResultWrapper> results = service.getAllEvents(recordId);
    }
}