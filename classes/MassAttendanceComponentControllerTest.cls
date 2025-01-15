@isTest
private class MassAttendanceComponentControllerTest {
    
    @testSetup 
    static void testSetup() {
        Account acc = TestDataFactory.createAccounts(1, true)[0];
        Contact con = TestDataFactory.createContacts(acc.Id, 1, true)[0];
        sumoapp__AdditionalInfo__c parent = new sumoapp__AdditionalInfo__c(sumoapp__StartDatetime__c=datetime.now());
        insert parent;
        sumoapp__AdditionalInfo__c child = new sumoapp__AdditionalInfo__c(sumoapp__Parent__c = parent.Id, sumoapp__StartDatetime__c=datetime.now());
        insert child;
        sumoapp__Attendee__c attendee = new sumoapp__Attendee__c(sumoapp__ContactRelation__c = con.Id,sumoapp__Status__c='BOOKED', Notes__c='Test',sumoapp__IsNotArrived__c=true,Attendance_Status__c='No Show',sumoapp__SumoEvent__c=child.Id);
        insert attendee;
	}

    @isTest
    static void getAttendeesTest() {
        Account acc = [Select Id, Name from Account limit 1];
        Contact con = [Select Id, Name, RecordTypeId from Contact limit 1];
        sumoapp__AdditionalInfo__c parent = [Select Id from sumoapp__AdditionalInfo__c where sumoapp__Parent__c=null limit 1];
        sumoapp__AdditionalInfo__c child = [Select Id from sumoapp__AdditionalInfo__c where sumoapp__Parent__c!=null limit 1];
        Test.startTest();
        List<sumoapp__Attendee__c> attendees =  MassAttendanceComponentController.getAttendees(child.Id);
        Test.stopTest();
    }
    
    @isTest
    static void getCourseSeriesTest() {
        Account acc = [Select Id, Name from Account limit 1];
        Contact con = [Select Id, Name, RecordTypeId from Contact limit 1];
        sumoapp__AdditionalInfo__c parent = [Select Id from sumoapp__AdditionalInfo__c where sumoapp__Parent__c=null limit 1];
        sumoapp__AdditionalInfo__c child = [Select Id from sumoapp__AdditionalInfo__c where sumoapp__Parent__c!=null limit 1];
        Test.startTest();
        MassAttendanceComponentController.AttendeeWrapper attendees =  MassAttendanceComponentController.getCourseSeries(parent.Id);
        Test.stopTest();
    }
    
    @isTest
    static void getContactDetailTest() {
        Contact con = [Select Id, Name, RecordTypeId from Contact limit 1];
        Test.startTest();
        Contact contact =  MassAttendanceComponentController.getContactDetail(con.Id);
        Test.stopTest();
    }
    
    @isTest
    static void getAttendeeRecordsTest() {
        Contact con = [Select Id, Name, RecordTypeId from Contact limit 1];
        Test.startTest();
        List<sumoapp__Attendee__c> attendees =  MassAttendanceComponentController.getAttendeeRecords(con.Id);
        Test.stopTest();
    }
}