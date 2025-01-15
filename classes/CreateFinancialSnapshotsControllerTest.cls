@istest
public class CreateFinancialSnapshotsControllerTest {
    
    @testSetup 
    static void testSetup() {
        ClientCase__c cc = TestDataFactory.createClientCases(1,true)[0];
        ClientAsset__c ca = new ClientAsset__c(AccountBalance__c=1000, CashDeposit__c=200, PresentMarketValue__c =1100, Value__c=800,CashValue__c=900,ClientCase__c=cc.Id);
        insert ca;
        Liability__c l = new Liability__c(AccountBalance__c=1000, MinimumMonthlyPayment__c=700,ClientCase__c=cc.Id);
        insert l;
        Income__c i = new Income__c(MonthlyGrossIncome__c=10000, MonthlyNetIncome__c=800,ClientCase__c=cc.Id);
        insert i;
        FinancialSnapshot__c fss = new FinancialSnapshot__c(ClientCase__c=cc.Id);
        insert fss;
    }
    
    static testMethod void testcreateFinancialSnapshot(){
        Test.startTest();
        String s = CreateFinancialSnapshotsController.createFinancialSnapshot(new FinancialSnapshot__c(NetMonthlyIncome__c=1000));
        System.assertEquals('success',s);
        
        String s1 = CreateFinancialSnapshotsController.createFinancialSnapshot(null);
        System.assertEquals(null,s1);
        Test.StopTest();
    }
    
    static testMethod void testFetchFinancialSnapshots(){
        ClientCase__c cc = [select id from ClientCase__c];
        Test.startTest();
        CreateFinancialSnapshotsController.FinancialSnapshotDetailsWrapper output = CreateFinancialSnapshotsController.fetchFinancialSnapshots(cc.Id);
		CreateFinancialSnapshotsController.FinancialSnapshotDetailsWrapper output1 = CreateFinancialSnapshotsController.fetchFinancialSnapshots(null);
        System.assertEquals(null,output1.financialSnapshotRecords);
        Test.StopTest();
    }
    
    static testMethod void testGetFinacialMetricsDetails(){
        ClientCase__c cc = [select id from ClientCase__c];
        Test.startTest();
        CreateFinancialSnapshotsController.FinancialMetricsDetailWrapper output = CreateFinancialSnapshotsController.getFinacialMetricsDetails(cc.Id);
        System.assertEquals(cc,output.goal);
       
        Test.StopTest();
    }
    
}