/**
* @desc: Test Class for CourseManagementController.
*/
@isTest
public class CourseManagementControllerTest {
    /**
* @desc: Test Data Setup.
*/
    @testSetup 
    static void testSetup() {
        Account acc = TestDataFactory.createAccounts(1, true)[0];
        Contact con = TestDataFactory.createContacts(acc.Id, 1, true)[0];
        List<sumoapp__AdditionalInfo__c> courses = TestDataFactory.createSumoEventInfo(5, true);
        TestDataFactory.createAttendee(con, courses[0].id, 5, true);
    }
    
    /**
* @desc: Test Method to test getCourses method of the controller.
*/
    @isTest
    public static void testGetCourses() {
        Test.startTest();
        List<sumoapp__AdditionalInfo__c> courses = CourseManagementController.getCourses();
        Test.stopTest();
    }
    
    /**
* @desc: Test Method to test getContacts method of the controller.
*/
    @isTest
    public static void testGetContacts() {
        sumoapp__AdditionalInfo__c event = [SELECT Id FROM sumoapp__AdditionalInfo__c LIMIT 1];
        Test.startTest();
        List<Contact> contacts = CourseManagementController.getContacts(event.Id);
        Test.stopTest();
    }
    
    /**
* @desc: Test Method to test filterRows method of the controller.
*/
    @isTest
    public static void testFilterRows() {
        Test.startTest();
        List<sumoapp__AdditionalInfo__c> filteredCourses = CourseManagementController.filterRows('Test', Date.today(), Date.today().addDays(1));
        Test.stopTest();
    }
    
    /*
* @desc: Test Method to test createAttendees method of the controller.
*/
    
    @isTest
    public static void testCreateAttendees() {
        sumoapp__AdditionalInfo__c parentEvent = [SELECT Id FROM sumoapp__AdditionalInfo__c LIMIT 1];
        sumoapp__AdditionalInfo__c childEvent = new sumoapp__AdditionalInfo__c(
            sumoapp__EventName__c = 'Test Child Event',
            sumoapp__StartDatetime__c = Date.today(),
            sumoapp__EndDatetime__c = Date.today().addDays(1),
            sumoapp__Parent__c = parentEvent.Id
        );
        insert childEvent;
        Contact con = [SELECT Id FROM Contact LIMIT 1];
        Test.startTest();
        CourseManagementController.createAttendees(new List<Id>{con.Id}, parentEvent.Id, true);
        Test.stopTest();
    }
}