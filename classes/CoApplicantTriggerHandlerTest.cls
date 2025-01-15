@isTest
public class CoApplicantTriggerHandlerTest {
    
    @testSetup
    static void setupTestData() {
        // Create test data for Intake and ClientCase records
        List<Intake__c> intakes = new List<Intake__c>();
        List<String> values = new List<String>{'Education','Homeless Assistance','Rental Topics','Prepurchase/Homebuying','Non-delinquency Post-Purchase','Reverse Mortgage','Resolving or Preventing Forward Mortgage Delinquency or Default','Resolving or Preventing Reverse Mortgage Delinquency or Default','Disaster Preparedness Assistance','Disaster Recovery Assistance','Financial Capability','Housing Stability Capability Program'};
            List<CaseType__c> CaseTypes = new List<CaseType__c>();
        for(String elt : values) {
            CaseType__c ct = new CaseType__c();
            ct.Name=elt;
            CaseTypes.add(ct);
        }
        
        Account acc = TestDataFactory.createAccounts(1, true)[0];
        Contact con = TestDataFactory.createContacts(acc.id,1, false)[0];
        con.FirstName='Test';
        con.LastName='Test';
        con.Email='tommy@dummy.com'; 
        con.TotalMonthlyIncome__c = 500; 
        con.Phone='9898989898'; 
        con.MailingStreet='Test Street'; 
        con.MailingCity='Test City'; 
        con.MailingState='New York';
        con.MailingPostalCode='777777';
        con.MailingCountry='United States';
        insert con;
        insert CaseTypes;
        
        List<Intake__c> newIntakes = TestDataFactory.createIntakes(con, acc.Id, 5, false);
       
        for (Integer i = 0; i < newIntakes.size(); i++) {
            Intake__c newIntk = newIntakes[i];
            newIntk.Town__c = 'Town' + i;
            newIntk.County__c = 'County' + i;
            newIntk.Address__PostalCode__s = '12345' + i;
            newIntk.HouseholdMonthlyIncome__c = 4000 + (1000 * i); 
            newIntk.HouseholdSize__c = 4 + i;
            intakes.add(newIntk);
        }
        insert intakes;
        
        List<ClientCase__c> cases = TestDataFactory.createClientCases(1, false);
        cases[0].Race__c='Asian';
        cases[0].Ethnicity__c='Not Hispanic';
        cases[0].Gender__c='Female';
        cases[0].HouseholdType__c='Other';
        cases[0].Education__c='Junior College';
        cases[0].MaritalStatus__c='Divorced';
        cases[0].HouseholdSize__c=2;
        cases[0].X1stTimeHomeBuyer__c='Yes';
        cases[0].ClientCaseStatus__c = 'In Progress'; 
        insert cases;
        TestDataFactory.createCoApplicants( intakes[0].Id, con.id, cases[0].Id, 1, true);
        
    }
    
    
    @isTest
    static void testAfterInsert() {
        Contact con = [SELECT id FROM Contact LIMIT 1];
        CoApplicant__c newCoApplicants = new CoApplicant__c(
            Contact__c = con.id,
            IntakeRequest__c = [SELECT Id FROM Intake__c LIMIT 1].Id,
            ClientCase__c = [SELECT Id FROM ClientCase__c LIMIT 1].Id
        );
        
        Test.startTest();
        insert newCoApplicants;
        Test.stopTest();
        
    }
    
    @isTest
    static void testAfterDelete() {
        List<CoApplicant__c> coApplicantsToDelete = [SELECT Id FROM CoApplicant__c LIMIT 5];
        
        Test.startTest();
        delete coApplicantsToDelete;
        Test.stopTest();
        
    }
    
    @isTest
    static void testCalculateHouseholdIncome() {
        List<CoApplicant__c> coApplicants = [SELECT Id, IntakeRequest__c, ClientCase__c,Contact__r.TotalMonthlyIncome__c FROM CoApplicant__c];
        
        Test.startTest();
        CoApplicantTriggerHandler.calculateHouseholdIncome(coApplicants, null);
        Test.stopTest();
    }
}