@isTest
public class HudOrsFinancialCapabilityReportCtrlTest {
    @testSetup
    static void setupTestData() {
        string NWC2NameSpace = Utility.getNwc2NameSpace();
        string objectName = NWC2NameSpace + 'ClientCase__c';
        // Create test data for the ClientCase__c object
        RecordType rt = [SELECT Id FROM RecordType WHERE DeveloperName = 'FinancialCapabilityCounseling' AND SObjectType =: objectName LIMIT 1];

        ClientCase__c case1 = TestDataFactory.createClientCases(1,false)[0];
		case1.ClientCaseClosedDate__c = Date.today().addDays(-1);       
      	case1.ClientCaseClosedDate__c = Date.today().addDays(-1);
        case1.ClientCaseStatus__c = 'Closed - Complete';
        insert case1;
    }

    @isTest
    static void testFetchORSFinancialRecords() {
        // Set test dates
        Date qtrStartDate = Date.today().addMonths(-3);
        Date qtrEndDate = Date.today();

        Test.startTest();

        // Call the method to test
        Map<String, List<HudOrsFinancialCapabilityReportCtrl.OrsReportWrapper>> result = HudOrsFinancialCapabilityReportCtrl.fetchORSFinancialRecords(qtrStartDate, qtrEndDate);
		HudOrsFinancialCapabilityReportCtrl.ORS_FCWrapper result2 = HudOrsFinancialCapabilityReportCtrl.fetchNWQRFCAggregateValidation(qtrStartDate, qtrEndDate);
        Test.stopTest();
		System.debug('### result : '+result.size()); 
        System.assertNotEquals(null, result);
    }
}