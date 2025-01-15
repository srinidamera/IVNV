@isTest
public class ActivityTimelineCasePDFControllerTest {
    @testSetup
    static void setup() {
        Account acc = TestDataFactory.createAccounts(1, true)[0];
        Contact testContact = TestDataFactory.createContacts(acc.id,1, true)[0];

        List<ClientCase__c> ClientCaseList = TestDataFactory.createClientCases(1,false);
        ClientCaseList[0].PrimaryClient__c = testContact.Id;
        ClientCaseList[0].ClientCaseStatus__c = '	In Progress';
        ClientCaseList[0].CounselingTermination__c = 'Ongoing';
        ClientCaseList[0].CounselSessionDateStart__c = Datetime.now()+2;
        ClientCaseList[0].HouseholdDebt__c = 2500;
        ClientCaseList[0].HUDGrant__c  = 'MMMSA';
        ClientCaseList[0].Repository__c = 'Experian';
        insert ClientCaseList;

        CounselorNote__c counselorNote1 = TestDataFactory.createCounselorNote(ClientCaseList[0].Id, testContact.id, 1, true)[0];
        
        CounselorNote__c counselorNote2 = TestDataFactory.createCounselorNote(ClientCaseList[0].Id, testContact.id, 1, false)[0];
        counselorNote2.StartDatetime__c = DateTime.now()+3;
        counselorNote2.Notes__c = 'Test Note 2';
        counselorNote2.Duration__c = 45;
        insert counselorNote2;

        Event event1 = TestDataFactory.createEvent(testContact, NULL, 1, FALSE)[0];
        event1.WhatId = ClientCaseList[0].Id;
        event1.ActivityDate = Date.today().addDays(-1);
        event1.ActivityDateTime = Date.today().addDays(3);
        INSERT event1;
        
        Event event2 = TestDataFactory.createEvent(testContact, NULL, 1, FALSE)[0];
        event2.WhatId = ClientCaseList[0].Id;
        event2.ActivityDate = Date.today().addDays(-1);
        event2.DurationInMinutes = 90;
        event2.ActivityDateTime = Date.today().addDays(3);
        insert event2;
    }

    @isTest
    static void testActivityTimelineCasePDFController() {
        Test.setCurrentPage(Page.ActivityTimelineCasePDF); 
        ApexPages.currentPage().getParameters().put('id', [SELECT Id FROM ClientCase__c LIMIT 1].Id);
        ActivityTimelineCasePDFController controller = new ActivityTimelineCasePDFController();

    }
    
    @isTest
    static void Test1() {
        ActivityTimelineCasePDFController.caseManagementEntry cme = new ActivityTimelineCasePDFController.caseManagementEntry('DateTimeDuration', 'Status', 'Purpose', 'Outcome', 'Subject', 'Notes');
    }
}