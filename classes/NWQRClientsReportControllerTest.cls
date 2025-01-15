@isTest
public class NWQRClientsReportControllerTest {
    //test
    @testSetup
    static void setupTestData() {
        TestDataFactory.createAutomationBypassCS(true);
        string NWC2NameSpace = Utility.getNwc2NameSpace();
        string objectName = NWC2NameSpace + 'ClientCase__c';

        // Create test data for the ClientCase__c object
        RecordType rt = [SELECT Id FROM RecordType WHERE DeveloperName = 'FinancialCapabilityCounseling' AND SObjectType =: objectName  LIMIT 1];

        Account acc = TestDataFactory.createAccounts(1, false)[0];
        acc.ClientNumber__c = '1234';
        insert acc;
        Contact con = TestDataFactory.createContacts(acc.Id, 1, true)[0];
        ClientCase__c case1 = TestDataFactory.createClientCases(1,false)[0];
		case1.ClientCaseClosedDate__c = Date.today().addDays(-1);       
      	case1.ClientCaseClosedDate__c = Date.today().addDays(-1);
        case1.ClientCaseStatus__c = 'Closed - Complete';
        case1.Household__c = acc.Id;
        case1.PrimaryClient__c = con.Id;
        case1.NWORole__c = 'NWO Constructs New Unit for New Home Owner';
        case1.ServicesProvidedToExistingHomeOwner__c = 'Not Applicable';
        case1.NWOProvidedLendingServices__c = 'Yes';
        case1.NWOProvidedCounselingEducation__c = 'Yes';
        case1.FormalPartneringOrgProvidedService__c = 'Yes';
        case1.ProvideRealEstateAgentServices__c = 'Yes';
        case1.Age__c = 10;
        case1.Gender__c = 'Male';
        case1.Race__c = 'Asian';
        case1.Ethnicity__c = 'Hispanic';
        case1.X1stTimeHomeBuyer__c = 'Yes';
        case1.Veteran__c = 'Yes';
        case1.RehabConstCostNotIncInPrice__c = 1000;
        case1.RehabConstrCostsincinPrice__c = 1000;
        case1.ActiveMilitary__c = 'Yes';
        case1.HouseholdSize__c = 2;
        case1.CounselingTermination__c = 'Completed';
        insert case1;
        Grant__c grant = new Grant__c();
        grant.FundingType__c = 'CDBG';
        grant.FundingSource__c = 'Government (Federal/State/Local)';
        grant.ClientCase__c = case1.Id;
        grant.FundingAmount__c = 100;
        grant.Grantor__c = 'test';
        grant.StatusType__c = 'Approved';
        insert grant;
    }

    @isTest
    static void testgetOrsClientsUniqueList() {
        // Set test dates
        Date qtrStartDate = Date.today().addMonths(-3);
        Date qtrEndDate = Date.today();

        Test.startTest();

        // Call the method to test
        map<string,list<NWQRClientsReportController.OrsReportWrapper>> result = NWQRClientsReportController.getOrsClientsUniqueList(qtrStartDate, qtrEndDate);
        //NWQRClientsReportController.getReportData(qtrStartDate, qtrEndDate);
        Test.stopTest();
		System.debug('### result : '+result.size()); 
        System.assertNotEquals(null, result);
    }
}