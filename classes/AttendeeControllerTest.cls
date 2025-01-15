@isTest
private class AttendeeControllerTest {
    
    @testSetup 
    static void testSetup() {
        Account acc = TestDataFactory.createAccounts(1, true)[0];
        Contact con = TestDataFactory.createContacts(acc.Id, 1, true)[0];
        sumoapp__AdditionalInfo__c parent = new sumoapp__AdditionalInfo__c(sumoapp__StartDatetime__c=datetime.now());
        insert parent;
        sumoapp__AdditionalInfo__c child = new sumoapp__AdditionalInfo__c(sumoapp__Parent__c = parent.Id, sumoapp__StartDatetime__c=datetime.now());
        insert child;
        TestDataFactory.createAttendee(con, child.Id, 1, true);
	}

    @isTest
    static void getAttendeesTest() {
        Account acc = [Select Id, Name from Account limit 1];
        Contact con = [Select Id, Name, RecordTypeId from Contact limit 1];
        sumoapp__AdditionalInfo__c parent = [Select Id from sumoapp__AdditionalInfo__c where sumoapp__Parent__c=null limit 1];
        sumoapp__AdditionalInfo__c child = [Select Id from sumoapp__AdditionalInfo__c where sumoapp__Parent__c!=null limit 1];
        Test.startTest();
        List<sumoapp__Attendee__c> attendees =  AttendeeController.getAttendees(child.Id);
        Test.stopTest();
    }
    
    @isTest
    static void getCourseSeriesTest() {
        Account acc = [Select Id, Name from Account limit 1];
        Contact con = [Select Id, Name, RecordTypeId from Contact limit 1];
        sumoapp__AdditionalInfo__c parent = [Select Id from sumoapp__AdditionalInfo__c where sumoapp__Parent__c=null limit 1];
        sumoapp__AdditionalInfo__c child = [Select Id from sumoapp__AdditionalInfo__c where sumoapp__Parent__c!=null limit 1];
        Test.startTest();
        AttendeeController.AttendeeWrapper attendees =  AttendeeController.getCourseSeries(parent.Id);
        Test.stopTest();
    }
    
    @isTest
    static void updateAttendeeAttendanceTest() {
        Account acc = TestDataFactory.createAccounts(1, true)[0];
        List<Contact> ConList = TestDataFactory.createContacts(acc.id, 2, false);
        Contact prospect = ConList[0];
        prospect.RecordTypeId = [Select Id from RecordType where DeveloperName = 'Prospect' and SObjectType = 'Contact' limit 1].Id;
        prospect.FirstName = 'prospect';
        prospect.LastName = 'Contact';
        prospect.Email = 'prospect@prospect.com';
        insert prospect;
        
        Contact primaryClient = ConList[1];
        primaryClient.RecordTypeId = [Select Id from RecordType where DeveloperName = 'PrimaryClient' and SObjectType = 'Contact' limit 1].Id;
        prospect.FirstName = 'primaryClient';
        prospect.LastName = 'Contact';
        prospect.Email = 'primaryClient@prospect.com';
        insert primaryClient;
        
        sumoapp__Attendee__c attendee = [Select Id from sumoapp__Attendee__c limit 1];
        
        Test.startTest();
        AttendeeController.updateAttendeeAttendance(
            new List<Id>{attendee.Id},
            'Course Complete',
            true,
            new List<Id>{prospect.Id},
            new List<Id>{prospect.Id, primaryClient.Id}
        );
        Test.stopTest();

    }
    
}