@isTest
public class BudgetControllerTest {

    @testSetup
    static void setup() {
        // Create sample HUDAMIData__c records for testing
        List<HUDAMIData__c> hudamiDataList = new List<HUDAMIData__c>();
        hudamiDataList.add(new HUDAMIData__c(
            CountyName__c = 'SampleCounty',
            TownName__c = 'SampleTown',
            Zipcode__c = '12345',
            StateCode__c = 'SC',
            StateName__c = 'SampleState',
            MedianFamilyIncome__c = '60000',
            il_metro_name__c = 'SampleMetro',
            Areaname__c = 'SampleArea',
            il30p1__c = '20000',
            il30p2__c = '25000',
            il30p3__c = '30000',
            il50p1__c = '40000',
            il50p2__c = '45000',
            il50p3__c = '50000',
            il80p1__c = '60000',
            il80p2__c = '65000',
            il80p3__c = '70000'
        ));
        insert hudamiDataList;
    }
    
    @isTest
    static void testBeforeInsert() {
        // Create a new ClientCase__c record
        ClientCase__c newClientCase = new ClientCase__c(
            Town__c = 'SampleTown',
            County__c = 'SampleCounty',
            Address__PostalCode__s = '12345',
            ClientCaseStatus__c = 'In Progress',
            MonthlyIncome__c = 3000,
            HouseholdSize__c = 4
        );
        insert newClientCase;
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