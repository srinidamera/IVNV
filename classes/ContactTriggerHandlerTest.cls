@isTest
private class ContactTriggerHandlerTest {
    static Id coappRecTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName()
        .get('CoApplicant')
        .getRecordTypeId();
    static Id primaryClientRecTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName()
        .get('PrimaryClient')
        .getRecordTypeId();
    static Id prospectRecTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName()
        .get('Prospect')
        .getRecordTypeId();
    
    @testSetup
    static void setupTestData() {
        List<HUDAMIData__c> hudamiDataList = new List<HUDAMIData__c>{
            new HUDAMIData__c(CountyName__c = 'County1', TownName__c = 'Town1', 
                              Zipcode__c = '12345', MedianFamilyIncome__c = '50000', il30p1__c = '20000', il30p2__c = '25000', il30p3__c = '30000', il50p1__c = '40000', il50p2__c = '45000', il50p3__c = '50000', il80p1__c = '60000', il80p2__c = '65000', il80p3__c = '70000', il30p4__c = '50000', il50p4__c = '60000', il80p4__c = '70000'),
            new HUDAMIData__c(CountyName__c = 'County2', TownName__c = 'Town2', 
                              Zipcode__c = '67890', MedianFamilyIncome__c = '60000', il30p2__c = '25000', il30p3__c = '30000', il50p1__c = '40000', il50p2__c = '45000', il50p3__c = '50000', il80p1__c = '60000', il80p2__c = '65000', il80p3__c = '70000', il30p4__c = '50000', il50p4__c = '60000', il80p4__c = '70000')
        };
        insert hudamiDataList;
    }
    
    @isTest
    static void Test1() {
        
        Account acc = TestDataFactory.createAccounts(1, true)[0];
        Contact coappContact = TestDataFactory.createContacts(acc.id,1, false)[0];
        coappContact.FirstName = 'Jhon';
        coappContact.LastName = 'Jordan';
        coappContact.Email = 'Jhon@Jordan.com';
        coappContact.AccountId = acc.Id;
        coappContact.TotalMonthlyIncome__c = 5555;
        coappContact.RecordTypeId = coappRecTypeId;
        coappContact.MailingPostalCode = '12345';
        coappContact.isActive__c = true;  
        insert coappContact;

        coappContact.FirstName = 'Updaed';
        coappContact.isActive__c = true;
        coappContact.TotalMonthlyIncome__c = 55345;
        update coappContact;
    }

@isTest
    static void Test10() {
        Account acc = TestDataFactory.createAccounts(1, true)[0];
        Contact coappContact = TestDataFactory.createContacts(acc.id,1, false)[0];
        coappContact.AccountId = acc.Id;
        coappContact.TotalMonthlyIncome__c = 5555;
        coappContact.RecordTypeId = coappRecTypeId;
        coappContact.MailingPostalCode = '12345';
        coappContact.isActive__c = true;  
        insert coappContact;
        
        coappContact.MailingPostalCode = '5525';
        update coappContact;
    }    
    @isTest
    static void Test2() {
        Account acc = TestDataFactory.createAccounts(1, true)[0];
        Contact coappContact = TestDataFactory.createContacts(acc.id,1, false)[0];
        coappContact.AccountId = acc.Id;
        coappContact.TotalMonthlyIncome__c = 5555;
        coappContact.RecordTypeId = coappRecTypeId;
        coappContact.MailingPostalCode = '12345';
        coappContact.isActive__c = true;
        coappContact.County__c = 'County1';
        coappContact.Town__c = 'Town1';
        coappContact.HouseholdSize__c = 3;
        insert coappContact;
        
        Contact primaryClientContact = TestDataFactory.createContacts(acc.id,1, false)[0];
        primaryClientContact.FirstName = 'Asad';
        primaryClientContact.LastName = 'Ali';
        primaryClientContact.Email = 'Asad.hr@Ali.com';
        primaryClientContact.AccountId = acc.Id;
        primaryClientContact.TotalMonthlyIncome__c = 5555;
        primaryClientContact.RecordTypeId = primaryClientRecTypeId;
        primaryClientContact.MailingPostalCode = '12345';
        primaryClientContact.isActive__c = true;
        primaryClientContact.County__c = 'County1';
        primaryClientContact.Town__c = 'Town1';
        primaryClientContact.HouseholdSize__c = 3;
        primaryClientContact.SSN__c = '999999999';
        
        Test.startTest();  
        insert primaryClientContact;
        primaryClientContact.MailingPostalCode = '67890';
        primaryClientContact.County__c = 'County2';
        primaryClientContact.Town__c = 'Town2';
        primaryClientContact.HouseholdSize__c = 4;
        primaryClientContact.TotalMonthlyIncome__c = 5555;
        primaryClientContact.SSN__c = '888888888';
        update primaryClientContact;
        Test.stopTest();
    }
    
    @isTest
    static void Test3() {
        
        Account acc = TestDataFactory.createAccounts(1, true)[0];
        Contact primaryClientContact = TestDataFactory.createContacts(acc.id,1, false)[0];
        primaryClientContact.FirstName = 'Asad';
        primaryClientContact.LastName = 'Ali';
        primaryClientContact.Email = 'Asad.hr@Ali.com';
        primaryClientContact.AccountId = acc.Id;
        primaryClientContact.TotalMonthlyIncome__c = 5555;
        primaryClientContact.RecordTypeId = prospectRecTypeId;
        primaryClientContact.MailingPostalCode = '12345';
        primaryClientContact.isActive__c = true;
        primaryClientContact.County__c = 'County';
        primaryClientContact.Town__c = 'Town';
        primaryClientContact.HouseholdSize__c = 3;
        
        Test.startTest();  
        insert primaryClientContact;
        primaryClientContact.isActive__c = False;
        primaryClientContact.MailingPostalCode = '6782290';
        update primaryClientContact;
        Test.stopTest();
    }
}