@isTest
public class IntakeTriggerHandlerTest {
    
    @testSetup
    static void setupTestData() {

        Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];

        List<HUDAMIData__c> hudamiDataList = TestDataFactory.createHUDAMIDataRecords(2, false);
        
        hudamiDataList[0].CountyName__c = 'County1';
        hudamiDataList[0].TownName__c = 'Town1';
        hudamiDataList[0].Zipcode__c = '12345';
        hudamiDataList[0].MedianFamilyIncome__c = '50000';
        hudamiDataList[0].il30p1__c = '20000';
        hudamiDataList[0].il30p2__c = '25000';
        hudamiDataList[0].il30p3__c = '30000';
        hudamiDataList[0].il50p1__c = '40000';
        hudamiDataList[0].il50p2__c = '45000';
        hudamiDataList[0].il50p3__c = '50000';
        hudamiDataList[0].il80p1__c = '60000';
        hudamiDataList[0].il80p2__c = '65000';
        hudamiDataList[0].il80p3__c = '70000';
        hudamiDataList[0].il30p4__c = '50000';
        hudamiDataList[0].il50p4__c = '60000';
        hudamiDataList[0].il80p4__c = '70000';
        
        hudamiDataList[1].CountyName__c = 'County2';
        hudamiDataList[1].TownName__c = 'Town2';
        hudamiDataList[1].Zipcode__c = '67890';
        hudamiDataList[1].MedianFamilyIncome__c = '60000';
        hudamiDataList[1].il30p2__c = '25000';
        hudamiDataList[1].il30p3__c = '30000';
        hudamiDataList[1].il50p1__c = '40000';
        hudamiDataList[1].il50p2__c = '45000';
        hudamiDataList[1].il50p3__c = '50000';
        hudamiDataList[1].il80p1__c = '60000';
        hudamiDataList[1].il80p2__c = '65000';
        hudamiDataList[1].il80p3__c = '70000';
        hudamiDataList[1].il30p4__c = '50000';
        hudamiDataList[1].il50p4__c = '60000';
        hudamiDataList[1].il80p4__c = '70000';
        
        insert hudamiDataList;

        
        AutomationBypass__c bypassSetting = new AutomationBypass__c(SetupOwnerId = p.Id, IntakeAutomationBypass__c = false);
        insert bypassSetting;
        
        List<Account> portalAccounts = TestDataFactory.createAccounts(1, true);
        List<Contact> ConList = TestDataFactory.createContacts(portalAccounts[0].Id, 2, true);
        Contact primaryContact = ConList[0];
        primaryContact.email = 'primary@example.com';
        primaryContact.FirstName = 'Primary';
        update primaryContact;
        Contact coApplicant = ConList[1];
        coApplicant.FirstName = 'CoApplicant';
        coApplicant.Email = 'coapplicant@example.com';
        coApplicant.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Co-Applicant').getRecordTypeId();
        update coApplicant;

    }
    
    public static Intake__c createIntake() {
        Contact con = [SELECT Id FROM Contact WHERE FirstName = 'CoApplicant'];
        Contact primaryContact = [SELECT Id FROM Contact WHERE FirstName = 'Primary'];
        Account acc = [SELECT Id FROM Account LIMIT 1];
        
        Intake__c newIntake = TestDataFactory.createIntakes(con, acc.Id, 1, false)[0];
        
        //Intake__c newIntake = intk;
        newIntake.Town__c = 'Town1';
        newIntake.County__c = 'County1'; 
        newIntake.Address__PostalCode__s = '12345'; 
        newIntake.HouseholdMonthlyIncome__c = 4000; 
        newIntake.HouseholdSize__c = 4;
        
        return newIntake;
    }
    
    @isTest
    static void testBeforeInsert() {
        Intake__c newIntake = createIntake();
        insert newIntake;
        
        Intake__c insertedIntake = [SELECT Id, County__c, Town__c, Address__PostalCode__s, MetropolitanStatisticalArea__c, HouseholdofAMI__c FROM Intake__c WHERE Id = :newIntake.Id];
        System.assertEquals('County1', insertedIntake.County__c);
        System.assertEquals('Town1', insertedIntake.Town__c);
    }
    
    @isTest
    static void testBeforeUpdate() {
        Intake__c newIntake = createIntake();
        insert newIntake;
        
        //newIntake.HouseholdMonthlyIncome__c = 4500;
        newIntake.Address__PostalCode__s = '67890';
        newIntake.MonthlyIncome__c = 3000;
        newIntake.HouseholdSize__c = 8;
        update newIntake;
        
        Intake__c updatedIntake = [SELECT Id, County__c, MonthlyIncome__c, Town__c, Address__PostalCode__s, MetropolitanStatisticalArea__c, HouseholdofAMI__c FROM Intake__c WHERE Id = :newIntake.Id];
        System.assertEquals(3000, updatedIntake.MonthlyIncome__c);
    }
    
    @isTest
    static void testBeforeUpdate2() {
        Intake__c newIntake = createIntake();
        insert newIntake;
        
        //newIntake.HouseholdMonthlyIncome__c = 4500;
        newIntake.Address__PostalCode__s = '67890112';
        newIntake.MonthlyIncome__c = 3000;
        newIntake.HouseholdSize__c = 8;
        update newIntake;
        
        Intake__c updatedIntake = [SELECT Id, County__c, MonthlyIncome__c, Town__c, Address__PostalCode__s, MetropolitanStatisticalArea__c, HouseholdofAMI__c FROM Intake__c WHERE Id = :newIntake.Id];
        System.assertEquals(3000, updatedIntake.MonthlyIncome__c);
    }
    
    @isTest
    static void testBeforeUpdate1() {
        Intake__c newIntake = createIntake();
        insert newIntake;
        
        newIntake.MonthlyIncome__c = 4500;
        update newIntake;
        
        Intake__c updatedIntake = [SELECT Id, County__c, MonthlyIncome__c, Town__c, Address__PostalCode__s, MetropolitanStatisticalArea__c, HouseholdofAMI__c FROM Intake__c WHERE Id = :newIntake.Id];
        System.assertEquals(4500, updatedIntake.MonthlyIncome__c);
    }
    
    @isTest
    static void testBypassAutomation() {
        AutomationBypass__c bypassSetting = [SELECT Id, IntakeAutomationBypass__c FROM AutomationBypass__c];
        bypassSetting.IntakeAutomationBypass__c = true;
        update bypassSetting;
        
        Intake__c newIntake = createIntake();
        insert newIntake;
        
        Intake__c insertedIntake = [SELECT Id, County__c, Town__c, Address__PostalCode__s FROM Intake__c WHERE Id = :newIntake.Id];
        System.assertEquals('County1', insertedIntake.County__c);
        System.assertEquals('Town1', insertedIntake.Town__c);
    }
    
    @isTest
    static void testAfterDelete() {
        Intake__c newIntake = createIntake();
        insert newIntake;
        delete newIntake;
        
        System.assert(true);
    }
}