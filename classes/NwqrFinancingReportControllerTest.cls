@istest
public class NwqrFinancingReportControllerTest {
    
    @TestSetup
    static void setupData() {
        User adminUser = GrantTriggerHandlerTest.createAdminUserWithAllPermission();
        System.runAs(adminUser){
            RecordType rtCon = [Select Id, DeveloperName from RecordType where SobjectType='Contact' And developerName = 'Affiliate'];
            Account acc = TestDataFactory.createAccounts(1, true)[0];
            Contact con = TestDataFactory.createContacts(acc.Id, 1, false)[0];
            con.recordTypeId = rtCon.Id;
            insert con;
            
            ClientCase__c cc = TestDataFactory.createClientCases(1,false)[0];
            cc.ClientCaseStatus__c = 'Closed - Complete';
            cc.CounselingTermination__c = 'Completed';
            cc.CaseResolution__c = 'Increase access to credit';
        	cc.CaseResolutionDate__c = Date.Today();
            insert cc;
            
            Loan__c loan = TestDataFactory.createLoan(con, 1, false)[0];
            loan.ClientCase__c = cc.Id;
            loan.Status__c = 'Approved';
            insert loan;
            
            ClientCase__c cc2 = TestDataFactory.createClientCases(1,false)[0];
            cc2.ClientCaseStatus__c = 'Closed - Complete';
            cc2.CounselingTermination__c = 'Completed';
            cc2.CaseResolution__c = 'Increase access to credit';
        	cc2.CaseResolutionDate__c = Date.Today();
            insert cc2;
            
            Grant__c grant = new Grant__c();
            grant.FundingType__c = 'CDBG';
            grant.FundingSource__c = 'Government (Federal/State/Local)';
            grant.ClientCase__c = cc2.Id;
            grant.FundingAmount__c = 100;
            grant.Grantor__c = 'test';
            grant.StatusType__c = 'Approved';
            insert grant;
        }
    }
    
    static testMethod void testEetchNWQRFinancingReports(){
        User adminUser = [Select id, IsActive from User where userName = 'utst@test.com1' limit 1];
        System.runAs(adminUser){
            Test.startTest();
            List<NwqrFinancingReportController.NwqrReportWrapper> orsoutput = NwqrFinancingReportController.fetchNWQRFinancingReports(System.Today() - 1,System.Today() + 1);
            Test.StopTest();
            
            System.assertEquals(2,orsoutput.size());
        }
    }
    
}