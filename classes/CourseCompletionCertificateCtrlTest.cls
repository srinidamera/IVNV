@IsTest
public class CourseCompletionCertificateCtrlTest {
	@testSetup 
    static void testSetup() {
        Profile adminProfile = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        
        List<User> usr = TestDataFactory.createUsers(adminProfile.Id,'', 1, false);
        usr[0].CounselorHUDID__c = 'test12';
        insert usr;
	}
    
    @isTest
    static void getCourseDetailsTest() {
        User usr = [Select Id, Name from User limit 1];
        Account acc = TestDataFactory.createAccounts(1, true)[0];
        Contact con = TestDataFactory.createContacts(acc.Id, 1, true)[0];
        sumoapp__AdditionalInfo__c parent = new sumoapp__AdditionalInfo__c(sumoapp__EventName__c = 'EventNAme', sumoapp__StartDatetime__c=datetime.now(), Facilitator__c = usr.Id);
        insert parent;
        sumoapp__AdditionalInfo__c child = new sumoapp__AdditionalInfo__c(sumoapp__EventName__c='test', sumoapp__Parent__c = parent.Id, sumoapp__StartDatetime__c=datetime.now(), Facilitator__c = usr.Id);
        insert child;
        sumoapp__Attendee__c attendee = new sumoapp__Attendee__c(sumoapp__ContactRelation__c = con.Id,sumoapp__Status__c='BOOKED', Notes__c='Test',sumoapp__IsNotArrived__c=true,Attendance_Status__c='No Show',sumoapp__SumoEvent__c=child.Id);
        insert attendee;
        AgencyProfile__c ag = new AgencyProfile__c(Name='Test');
        insert ag;
        
        Test.startTest();
            PageReference pageRef = Page.CourseCompletionCertificate;
            Test.setCurrentPage(pageRef);
            pageRef.getParameters().put('Ids',parent.Id);
        	pageRef.getParameters().put('attendeeId',attendee.Id);
            CourseCompletionCertificateController objCtrl = new CourseCompletionCertificateController();
        	System.assertNotEquals(NULL, objCtrl.courseName);
        	System.assertNotEquals(NULL, objCtrl.participantName);
        Test.stopTest();
    }
}