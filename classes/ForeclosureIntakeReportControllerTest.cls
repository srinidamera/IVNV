@istest
public class ForeclosureIntakeReportControllerTest {
    
    @TestSetup
    static void setupData() {
        string NWC2NameSpace = Utility.getNwc2NameSpace();
        string objectName = NWC2NameSpace + 'ClientCase__c';
        RecordType rtCase = [Select Id, DeveloperName from RecordType where SobjectType=:objectName And developerName = 'HomeownerCounseling'];
		
        CaseType__c ct = TestDataFactory.createCaseTypes(1,false)[0];
        ct.HUDPurpose__c = 'Non-Delinquency Post-Purchase';
        insert ct;
        
        ClientCase__c cc = TestDataFactory.createClientCases(1,false)[0];
        cc.RehabCost__c = 2000;
        cc.RecordTypeId = rtCase.Id;
        cc.CaseResolution__c = 'Obtained a HECM';
        cc.Age__c = 69;
        cc.Units__c = 1;
        cc.NWORole__c = 'NWO Provides Services to an Existing Home Owner';
        cc.HealthCrisisNatDisasClimateResil__c = 'Increase or improve climate resilience';
        cc.ClientCaseStatus__c = 'Closed - Complete';
        cc.Purpose__c = 'Non-Delinquency Post-Purchase';
        cc.CounselingTermination__c = 'Completed';
        cc.ClientCaseClosedDate__c = Date.today();
        cc.CaseSubType__c = 'NW Rehab';
        cc.CaseType__c = ct.Id;
        insert cc;
    }
    
    static testMethod void testFetchNWQRFinancingReports(){
        ClientCase__c cc1 = [select id,CaseResolution__c from ClientCase__c limit 1];
        Test.startTest();
        ForeclosureIntakeReportController.AllTableDataWrapper orsoutput = ForeclosureIntakeReportController.fetchAllTableData(System.Today() - 1,System.Today() + 1);
        List<ForeclosureIntakeReportController.DetailReportWrapper> orsoutput1 = ForeclosureIntakeReportController.fetchTable1Data(System.Today() - 1,System.Today() + 1,0);
        List<ForeclosureIntakeReportController.DetailReportWrapper> orsoutput2 = ForeclosureIntakeReportController.fetchTable2Data(System.Today() - 1,System.Today() + 1,0);
        List<ForeclosureIntakeReportController.DetailReportWrapper> orsoutput3 = ForeclosureIntakeReportController.fetchTable3Data(System.Today() - 1,System.Today() + 1,0);
        List<ForeclosureIntakeReportController.DetailReportWrapper> orsoutput4 = ForeclosureIntakeReportController.fetchTable4Data(System.Today() - 1,System.Today() + 1,0);
        Test.StopTest();
    }
    
    static testMethod void testFetchReports(){
        Test.startTest();
        List<ForeclosureIntakeReportController.ExportReportWrapper> orsoutput = ForeclosureIntakeReportController.fetchReport(System.Today() - 1,System.Today() + 1);
        Test.StopTest();
    }

}