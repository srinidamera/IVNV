@isTest
public class BudgetDetailPageControllerTest {
    @isTest
    static void testGetBudgetId() {
        ClientCase__c clientCase = TestDataFactory.createClientCases(1, true)[0];
  
        Budget__c budget = new Budget__c(clientcase__c = clientCase.Id);
        insert budget;
        String budgetId = BudgetDetailPageController.getBudgetId(clientCase.Id);
        System.assertEquals(budget.Id, budgetId, 'Expected Budget Id does not match');
        
        String budgetId1 = BudgetDetailPageController.getBudgetId('');
        //System.assertEquals('a1JW4000003g6VVMAY', budgetId);
    }
    @isTest
    static void testGetCurrencyFieldsList() {
        // Call the controller method
        String currencyFields = BudgetDetailPageController.getCurrencyFieldsList();
        System.assertNotEquals(null, currencyFields, 'Currency fields list should not be null');
        System.assertNotEquals('', currencyFields, 'Currency fields list should not be empty');
    }

    @IsTest
    static void verifyIsIntakeStaffUser() {
        Test.startTest();
        Boolean isIntakeStaffUser = BudgetDetailPageController.isIntakeStaffUser();
        Test.stopTest();
    }
}