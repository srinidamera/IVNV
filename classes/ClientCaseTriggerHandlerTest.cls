@isTest
public class ClientCaseTriggerHandlerTest {
    
    @testSetup
    static void setup() {
        
        List<HUDAMIData__c> hudamiDataList = TestDataFactory.createHUDAMIDataRecords(3, false);
        
        // Modify all values for each record
        hudamiDataList[0] = new HUDAMIData__c(
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
            il80p3__c = '70000',
            il30p4__c = '50000',
            il50p4__c = '60000',
            il80p4__c = '70000'
        );
        
        hudamiDataList[1] = new HUDAMIData__c(
            CountyName__c = 'SampleCounty',
            TownName__c = 'SampleTown',
            Zipcode__c = '54321',
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
            il80p3__c = '70000',
            il30p4__c = '50000',
            il50p4__c = '60000',
            il80p4__c = '70000'
        );
        
        hudamiDataList[2] = new HUDAMIData__c(
            CountyName__c = 'Sample1County',
            TownName__c = 'Sample1Town',
            Zipcode__c = '54321',
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
            il80p3__c = '70000',
            il30p4__c = '50000',
            il50p4__c = '60000',
            il80p4__c = '70000'
        );
        
        // Insert the records
        insert hudamiDataList;
        
        
    }
    
    @isTest
    static void testBeforeInsert() {
        // Create a new ClientCase__c record
        List<HUDAMIData__c> hudamiDataList = [SELECT Id, CountyName__c, TownName__c, Zipcode__c, MedianFamilyIncome__c , il30p1__c, il30p2__c FROM HUDAMIData__c];
        List<ClientCase__c> cases = TestDataFactory.createClientCases(1, false);
        cases[0].Town__c = 'SampleTown';
        cases[0].County__c = 'SampleCounty';
        cases[0].Address__PostalCode__s = '54321';
        cases[0].MonthlyIncome__c = 1000;
        cases[0].HouseholdSize__c = 9;
        cases[0].ClientCaseStatus__c = 'In Progress';
        
        Test.startTest();
        insert cases;
        Test.stopTest();
        
    }
    
    @isTest
    static void testBeforeUpdate() {
        // Create and insert an initial ClientCase__c record
        List<HUDAMIData__c> hudamiDataList = [SELECT Id, CountyName__c, TownName__c, Zipcode__c, MedianFamilyIncome__c , il30p1__c, il30p2__c FROM HUDAMIData__c];
        List<ClientCase__c> cases = TestDataFactory.createClientCases(1, false);
        cases[0].Town__c = 'SampleTown';
        cases[0].County__c = 'SampleCounty';
        cases[0].Address__PostalCode__s = '54321';
        cases[0].MonthlyIncome__c = 2000;
        cases[0].HouseholdSize__c = 9;
        
        insert cases;
        
        // Update the record
        //cases[0].Town__c = 'SampleTown';
        //cases[0].County__c = 'SampleCounty';
        cases[0].Address__PostalCode__s = '12345';
        cases[0].MonthlyIncome__c = 3000;
        //cases[0].HouseholdSize__c = 8;
        cases[0].ClientCaseStatus__c = 'In Progress';
        
        Test.startTest();
        update cases[0];
        Test.stopTest();
    }
    
    @isTest
    static void testBeforeUpdate2() {
        // Create and insert an initial ClientCase__c record
        List<HUDAMIData__c> hudamiDataList = [SELECT Id, CountyName__c, TownName__c, Zipcode__c, MedianFamilyIncome__c , il30p1__c, il30p2__c FROM HUDAMIData__c];
        List<ClientCase__c> cases = TestDataFactory.createClientCases(1, false);
        cases[0].Town__c = 'SampleTown';
        cases[0].County__c = 'SampleCounty';
        cases[0].Address__PostalCode__s = '12345';
        cases[0].MonthlyIncome__c = 2000;
        cases[0].HouseholdSize__c = 9;
        
        insert cases;
        
        // Update the record
        cases[0].Town__c = 'Sample1Town';
        cases[0].County__c = 'Sample1County';
        cases[0].Address__PostalCode__s = '54321';
        cases[0].MonthlyIncome__c = 3000;
        //cases[0].HouseholdSize__c = 8;
        cases[0].ClientCaseStatus__c = 'In Progress';
        
        Test.startTest();
        update cases[0];
        Test.stopTest();
    }
    
    @isTest
    static void Test3() {
        // Create test data for Intake and ClientCase records
        List<HUDAMIData__c> hudamiDataList = [SELECT Id, CountyName__c, TownName__c, Zipcode__c, MedianFamilyIncome__c , il30p1__c, il30p2__c FROM HUDAMIData__c];
        List<Intake__c> intakes = new List<Intake__c>();
        List<String> values = new List<String>{'Education','Homeless Assistance','Rental Topics','Prepurchase/Homebuying','Non-delinquency Post-Purchase','Reverse Mortgage','Resolving or Preventing Forward Mortgage Delinquency or Default','Resolving or Preventing Reverse Mortgage Delinquency or Default','Disaster Preparedness Assistance','Disaster Recovery Assistance','Financial Capability','Housing Stability Capability Program'};
            List<CaseType__c> CaseTypes = new List<CaseType__c>();
        for(String elt : values) {
            CaseType__c ct = new CaseType__c();
            ct.Name=elt;
            CaseTypes.add(ct);
        }
        
        Contact con = new Contact(FirstName='Test', LastName='Test',Email='tommy@dummy.com', TotalMonthlyIncome__c = 500, Phone='9898989898', MailingStreet='Test Street', MailingCity='Test City', MailingState='New York', MailingPostalCode='777777', MailingCountry='United States');
        insert con;
        insert CaseTypes;
        
        for (Integer i = 0; i < 5; i++) {
            Intake__c newIntake = new Intake__c(
                Town__c = 'Town' + i, 
                County__c = 'County' + i, 
                Address__PostalCode__s = '12345' + i, 
                HouseholdMonthlyIncome__c = 4000 + (1000 * i), 
                HouseholdSize__c = 4 + i
            );
            intakes.add(newIntake);
        }
        
        insert intakes;
        
        List<ClientCase__c> cases = TestDataFactory.createClientCases(1, false);
        
        cases[0].Race__c='Asian';
        cases[0].Ethnicity__c='Not Hispanic';
        cases[0].Gender__c='Female';
        cases[0].HouseholdType__c='Single adult';
        cases[0].Education__c='Junior College';
        cases[0].MaritalStatus__c='Divorced';
        cases[0].HouseholdSize__c=9;
        cases[0].HouseholdMonthlyIncome1__c=2000;
        cases[0].MonthlyIncome__c = 11000;
        cases[0].X1stTimeHomeBuyer__c='Yes';
        cases[0].ClientCaseStatus__c = 'In Progress';
        insert cases[0];
        
        CoApplicant__c CoApplicant =  new CoApplicant__c(
            IntakeRequest__c = intakes[0].Id,
            Contact__c = con.id ,
            ClientCase__c = cases[0].Id
        );
        insert CoApplicant;
    }
}