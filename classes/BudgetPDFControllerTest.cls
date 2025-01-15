@isTest
public class BudgetPDFControllerTest {

    @testSetup
    static void setup() {
        // Create sample HUDAMIData__c records for testing
        TestDataFactory.createHUDAMIDataRecords(5, true);
        TestDataFactory.createClientCases(1, true);
    }
    
    @isTest
    static void testBeforeInsert() {
        // Create a new ClientCase__c record
        ClientCase__c newClientCase = [
            SELECT Id, Town__c, County__c, Address__PostalCode__s, ClientCaseStatus__c, MonthlyIncome__c, HouseholdSize__c 
            FROM ClientCase__c 
            LIMIT 1
        ];

        Budget__c budget = new Budget__c(clientcase__c = newClientCase.Id);
        insert budget;
        Test.startTest();
        Test.setCurrentPageReference(new PageReference('/apex/BudgetPage'));
        ApexPages.currentPage().getParameters().put('id', newClientCase.Id);
        
        // Instantiate the controller
        BudgetPDFController controller = new BudgetPDFController();
        Test.stopTest();

    }
}