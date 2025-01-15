@istest
public class AccountTriggerHandlerTest {
    
    static testMethod void testEetchNWQRFinancingReports(){
        List<Account> accLst = TestDataFactory.createAccounts(3, true);
        Test.startTest();
        List<Account> accList = AccountTriggerHandler.populateUniqueClientId(accLst);
        Test.StopTest();
    }

}