@isTest
public class ActivityTimelineContactPDFControllerTest {
    @testSetup
    static void setup() {
        Account acc = TestDataFactory.createAccounts(1, true)[0];
        Contact testContact = TestDataFactory.createContacts(acc.id,1, false)[0];
        
        RecordType rt = [SELECT Id, DeveloperName FROM RecordType WHERE DeveloperName = 'Prospect' LIMIT 1];
        testContact.RecordTypeId = rt.Id;
        insert testContact;
        
        TestDataFactory.createSumoEvent(1, true);
        TestDataFactory.createAttendee(testContact, TestDataFactory.createSumoEvent(1, true)[0].id, 1, True);
        
        ClientCase__c clientCase = TestDataFactory.createClientCases(1, false)[0];
        clientCase.PrimaryClient__c = testContact.Id;
        insert clientCase;
     //   system.debug('clientCase '+clientCase);

        TestDataFactory.createCounselorNote(testContact, clientCase, 2,true) ;
 
        Event event1 = TestDataFactory.createEvent(testContact, NULL, 1, FALSE)[0];
        event1.WhatId = clientCase.Id;
        event1.ActivityDate = Date.today().addDays(-1);
        event1.ActivityDateTime = Date.today().addDays(3);
        INSERT event1;
        
        Event event2 = TestDataFactory.createEvent(testContact, NULL, 1, FALSE)[0];
        event2.WhatId = clientCase.Id;
        event2.ActivityDate = Date.today().addDays(-1);
        event2.DurationInMinutes = 90;
        event2.ActivityDateTime = Date.today().addDays(3);
        insert event2;
                                
        TestDataFactory.createSumoEvent(2 , true);
        TestDataFactory.InsertAgencyRecord(true);
    }
    
    @isTest
    static void testActivityTimelineContactPDFController() {
        Test.startTest();
        ApexPages.currentPage().getParameters().put('id', [SELECT Id FROM Contact LIMIT 1].Id);
        
        ActivityTimelineContactPDFController controller = new ActivityTimelineContactPDFController();
        Test.stopTest();
        
        System.assertNotEquals(null, controller.ContactObj, 'Contact object should be initialized');
        System.assertNotEquals(null, controller.CurrentDate, 'CurrentDate should be set');
        System.assertNotEquals(null, controller.appointments, 'Appointments should be populated');
        System.assertNotEquals(null, controller.caseManagementNotes, 'Case Management Notes should be populated');
        System.assertNotEquals(null, controller.Courses, 'Courses should be populated');
    }
    
    @isTest
    static void testContactManagementEntryConstructors() {
        ActivityTimelineContactPDFController.ContactManagementEntry appointment = new ActivityTimelineContactPDFController.ContactManagementEntry(
            '2023/07/01 - 10:00 AM - 60min', 
            'Confirmed', 
            'Initial Meeting', 
            'Discussed project scope',
            'Confirmed', 
            'Initial Meeting'
        );
        System.assertEquals('2023/07/01 - 10:00 AM - 60min', appointment.DateTimeDuration);
        System.assertEquals('Confirmed', appointment.Status);
        
        ActivityTimelineContactPDFController.ContactManagementEntry note = new ActivityTimelineContactPDFController.ContactManagementEntry(
            '2023/07/01 - 10:00 AM', 
            'Follow-up', 
            'Reviewed action items'
        );
        System.assertEquals('2023/07/01 - 10:00 AM', note.DateTimeDuration);
        System.assertEquals('Follow-up', note.Subject);
        
        ActivityTimelineContactPDFController.ContactManagementEntry course = new ActivityTimelineContactPDFController.ContactManagementEntry(
            '2023/07/01 - 10:00 AM', 
            'Attended', 
            'Salesforce Basics', 
            'Introduction to Salesforce'
        );
        System.assertEquals('2023/07/01 - 10:00 AM', course.DateTimeDuration);
        System.assertEquals('Attended', course.Status);
    }
    
    
    @isTest
    static void testGetFormattedStartDatetime() {
        DateTime dt = DateTime.newInstance(2023, 7, 1, 10, 0, 0);
        Decimal duration = 60;
        String result = ActivityTimelineContactPDFController.getFormattedStartDatetime(dt, duration);
        System.assertEquals('07/01/2023 - 10:00 AM - 60min', result, 'The datetime format should match the expected output');
        
        result = ActivityTimelineContactPDFController.getFormattedStartDatetime(dt, null);
        System.assertEquals('07/01/2023 - 10:00 AM', result, 'The datetime format should match the expected output when duration is null');
    }
}