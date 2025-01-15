@istest
public class NWQREducationReportControllerTest {
    
    @testSetup 
    static void testSetup() {
        RecordType rtCon = [Select Id, DeveloperName from RecordType where SobjectType='Contact' And developerName = 'PrimaryClient'];

        Account acc = TestDataFactory.createAccounts(1, true)[0];
        Contact con = TestDataFactory.createContacts(acc.Id, 1, false)[0];
        con.recordTypeId = rtCon.Id;
        insert con;
        
        RecordType rtCourse = [Select Id, DeveloperName from RecordType where SobjectType='sumoapp__AdditionalInfo__c' And developerName = 'Event'];
        sumoapp__AdditionalInfo__c course = new sumoapp__AdditionalInfo__c(sumoapp__StartDatetime__c=datetime.now() - 1, sumoapp__EndDatetime__c=datetime.now(), RecordTypeId = rtCourse.Id, HUD_Purpose__c = 'Completed disaster recovery assistance workshop');
        insert course;
        sumoapp__Attendee__c attendee = new sumoapp__Attendee__c(sumoapp__ContactRelation__c = con.Id,sumoapp__Status__c='BOOKED', Notes__c='Test',sumoapp__IsNotArrived__c=true,Attendance_Status__c='Attended - Complete',sumoapp__SumoEvent__c=course.Id);
        insert attendee;
	}
    
    static testMethod void testEducationFetch(){
        Test.startTest();
        List<NWQREducationReportController.OrsReportWrapper> NWQRoutput = NWQREducationReportController.fetchOrsEducationRecords(System.Today() - 1,System.Today() + 1);
        Test.StopTest();
        
        System.assertEquals(1,NWQRoutput.size());
    }

}