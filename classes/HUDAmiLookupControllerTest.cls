@isTest
public class HUDAmiLookupControllerTest {
    static string NWC2NameSpace = Utility.getNwc2NameSpace();
    @testSetup
    static void setupTestData() {
        
        Account acc = TestDataFactory.createAccounts(1, false)[0];
        Contact contactRecord = TestDataFactory.createContacts(acc.Id, 1, false)[0];
        contactRecord.FirstName = 'Test';
        contactRecord.LastName = 'Test';
        contactRecord.Email = 'tommy@dummy.com';
        contactRecord.HouseholdSize__c = 9;
        contactRecord.MailingPostalCode = '12345';
        contactRecord.HouseholdMonthlyIncome1__c = 4000;
        contactRecord.MetropolitanStatisticalArea__c = 'Some MSA';
        insert contactRecord;
        
        Intake__c intakeRecord = TestDataFactory.createIntakes(contactRecord, acc.Id, 1, false)[0];
        intakeRecord.HouseholdSize__c = 9;
        intakeRecord.Address__PostalCode__s = '12345';
        intakeRecord.HouseholdMonthlyIncome__c = 4000;
        intakeRecord.MetropolitanStatisticalArea__c = 'Some MSA';
        insert intakeRecord;
        
        ClientCase__c clientCaseRecord = TestDataFactory.createClientCases(1, false)[0];
        clientCaseRecord.HouseholdSize__c = 9;
        clientCaseRecord.Address__PostalCode__s = '12345';
        clientCaseRecord.HouseholdMonthlyIncome1__c = 4000;
        clientCaseRecord.MetropolitanStatisticalArea__c = 'Some MSA';
        clientCaseRecord.ClientCaseStatus__c = 'In Progress';
        insert clientCaseRecord;
        
        HUDAMIData__c hudamiData = TestDataFactory.createHUDAMIDataRecords(1, false)[0];
        hudamiData.Zipcode__c = '12345';
        hudamiData.CountyName__c = 'Some County';
        hudamiData.TownName__c = 'Some Town';
        hudamiData.MedianFamilyIncome__c = '60000';
        hudamiData.il_metro_name__c = 'SampleMetro';
        hudamiData.Areaname__c = 'SampleArea';
        hudamiData.il30p1__c = '20000';
        hudamiData.il30p2__c = '25000';
        hudamiData.il30p3__c = '30000';
        hudamiData.il50p1__c = '40000';
        hudamiData.il50p2__c = '45000';
        hudamiData.il50p3__c = '50000';
        hudamiData.il80p1__c = '60000';
        hudamiData.il80p2__c = '65000';
        hudamiData.il80p3__c = '70000';
        hudamiData.il30p4__c = '50000';
        hudamiData.il50p4__c = '60000';
        hudamiData.il80p4__c = '70000';
        insert hudamiData;
        
    }
    
    @isTest
    static void testValidAMI() {
        // Fetch a record to test
        Intake__c intakeRecord = [SELECT Id FROM Intake__c LIMIT 1];
        
        // Test validAMI method
        Test.startTest();
        Boolean result = HUDAmiLookupController.validAMI(intakeRecord.Id, NWC2NameSpace+'Intake__c');
        Test.stopTest();
        
    }
    
    @isTest
    static void testGetRecord() {
        // Fetch a record to test
        Intake__c intakeRecord = [SELECT Id FROM Intake__c LIMIT 1];
        
        // Test getRecord method
        Test.startTest();
        SObject result = HUDAmiLookupController.getRecord(intakeRecord.Id, NWC2NameSpace+'Intake__c');
        Test.stopTest();
    }
    
    @isTest
    static void testGetHudAmiUniqueCounty() {
        // Fetch a record to test
        Intake__c intakeRecord = [SELECT Id FROM Intake__c LIMIT 1];
        ClientCase__c clientCaseRecord = [SELECT Id FROM ClientCase__c LIMIT 1];
        // Test getHudAmiUniqueCounty method
        Test.startTest();
        List<String> result = HUDAmiLookupController.getHudAmiUniqueCounty(intakeRecord.Id, NWC2NameSpace+'Intake__c');
        HUDAmiLookupController.getHudAmiUniqueCounty(clientCaseRecord.Id, NWC2NameSpace+'ClientCase__c');
        Test.stopTest();
        
        System.assert(result != null && result.size() > 0, 'The list of unique counties should be retrieved successfully.');
    }
    
    @isTest
    static void testGetHudAmiUniqueTowns() {
        // Fetch a record to test
        Intake__c intakeRecord = [SELECT Id FROM Intake__c LIMIT 1];
        
        // Test getHudAmiUniqueTowns method
        Test.startTest();
        List<HUDAMIData__c> result = HUDAmiLookupController.getHudAmiUniquetowns(intakeRecord.Id, NWC2NameSpace+'Intake__c', 'Some County');
        Test.stopTest();
        
        System.assert(result != null && result.size() > 0, 'The list of unique towns should be retrieved successfully.');
    }
    
    @isTest
    static void testCalculateAMIandCommit() {
        // Fetch records to test
        Intake__c intakeRecord = [SELECT Id FROM Intake__c LIMIT 1];
        HUDAMIData__c hudamiData = [SELECT Id FROM HUDAMIData__c LIMIT 1];
        
        // Test calculateAMIandCommit method
        Test.startTest();
        HUDAmiLookupController.calculateAMIandCommit(intakeRecord.Id, hudamiData.Id, NWC2NameSpace+'Intake__c');
        Test.stopTest();
        
    }
    
    @isTest
    static void testCalculateHouseholdAMI() {
        // Test calculateHouseholdAMI method
        Decimal hhsize = 4;
        Decimal annualIncome = 50000;
        Decimal averageIlincome = 60000;
        
        Decimal result = HUDAmiLookupController.calculateHouseholdAMI(hhsize, annualIncome, averageIlincome);
        
        System.assert(result != null, 'The household AMI should be calculated successfully.');
    }
    
    @isTest
    static void testGetPicklistValOnHami() {
        // Test getpicklistvalonHami method
        Decimal hhami = 50;
        
        String result = HUDAmiLookupController.getpicklistvalonHami(hhami);
    }
    
    @isTest
    static void testRoundUpToFifty() {
        // Test roundUptofifty method
        Integer modvalue = 20;
        Decimal halfincome = 100;
        
        Decimal result = HUDAmiLookupController.roundUptofifty(modvalue, halfincome);
        
        System.assert(result == 130, 'The value should be rounded up to the nearest fifty.');
    }
    
    @isTest
    static void testRoundDownToFifty() {
        // Test rounddowntofifty method
        Integer modvalue = 20;
        Decimal halfincome = 120;
        
        Decimal result = HUDAmiLookupController.rounddowntofifty(modvalue, halfincome);
        
        System.assert(result == 100, 'The value should be rounded down to the nearest fifty.');
    }
    
    @isTest
    static void TestAll() {
        HUDAmiLookupController.getpicklistvalonHami(25);
        HUDAmiLookupController.getpicklistvalonHami(35);
        HUDAmiLookupController.getpicklistvalonHami(60);
        HUDAmiLookupController.getpicklistvalonHami(90);
        HUDAmiLookupController.getpicklistvalonHami(200);
        HUDAmiLookupController.getpicklistvalonHami(-10);
        
        HUDAmiLookupController.calculateHouseholdAMI(1,1500,2500);
        HUDAmiLookupController.calculateHouseholdAMI(2,1500,2500);
        HUDAmiLookupController.calculateHouseholdAMI(3,1500,2500);
        HUDAmiLookupController.calculateHouseholdAMI(4,1500,2500);
        HUDAmiLookupController.calculateHouseholdAMI(5,1500,2500);
        
        
        
        
        HUDAMIData__c hudamiData = [SELECT id FROM HUDAMIData__c LIMIT 1];
        Contact contactRecord = [SELECT id FROM Contact LIMIT 1];
        HUDAmiLookupController.getRecord(contactRecord.id , 'Contact');
        ClientCase__c clientCaseRecord = [SELECT id FROM ClientCase__c LIMIT 1];
        
        string objectName = NWC2NameSpace + 'ClientCase__c';
        HUDAmiLookupController.getRecord(clientCaseRecord.id , objectName);
        
        
        /*  HUDAMIData__c hudamiData2 = new HUDAMIData__c(
Zipcode__c = '12345',
CountyName__c = 'Some County',
TownName__c = 'Some Town',
MedianFamilyIncome__c = '60000',
il50p4__c = '60000'
);
insert hudamiData;*/
        
        HUDAmiLookupController.calculateAMIandCommit(contactRecord.id, hudamiData.id, 'Contact');
        HUDAmiLookupController.calculateAMIandCommit(clientCaseRecord.id, hudamiData.id, objectName);
        
    }
}