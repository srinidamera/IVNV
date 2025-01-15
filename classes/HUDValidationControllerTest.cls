@IsTest
public class HUDValidationControllerTest {
	@TestSetup
    static void makeData(){
        List<Account> portalAccounts = TestDataFactory.createAccounts(1, false);
        insert portalAccounts;
        
        List<Contact> contacts = TestDataFactory.createContacts(portalAccounts[0].Id, 3, false);
        contacts[0].AccountId = portalAccounts[0].Id;
        contacts[0].LastName = 'Con 1';
        
        contacts[1].LastName = 'Con 2';
        contacts[1].MailingCity = 'JP';
        contacts[1].MailingStateCode = 'CA';
        contacts[1].MailingCountryCode = 'US';
        contacts[1].MailingPostalCode = '12345';
        contacts[1].MaritalStatus__c = 'Single';
        //contacts[1].Education__c = 'None';
        contacts[1].FarmWorker__c = 'NO';
        contacts[1].ColoniasResidence__c = 'NO';
        contacts[1].DisabledStatus__c = 'No';
        contacts[1].NumberOfDependents__c = 1;
        contacts[1].PreferredLanguage__c = 'Hindi';
        contacts[1].isInvalidZip__c = false;
        contacts[1].EvaluateHUDAMI__c = false;
        
        contacts[2].LastName = 'Con 3';
        contacts[2].Race__c = 'American Indian/Alaskan Native';
        contacts[2].Ethnicity__c = 'Hispanic';
        contacts[2].MaritalStatus__c = 'Single';
        //contacts[2].HouseholdType__c = 'Female-headed single parent household';
        contacts[2].HouseholdSize__c = 1;
        contacts[2].ActiveMilitary__c = 'No';
        contacts[2].Veteran__c = 'No';
        contacts[2].RuralAreaStatus__c = 'Lives in a rural area';
        contacts[2].EnglishProficiency__c = 'Limited English Proficient';
        contacts[2].HouseholdMonthlyIncome1__c = 12345;
        contacts[2].CurrentResidence__c = 'Own';
        
        
        insert contacts;
        
        List<Intake__c> intake = TestDataFactory.createIntakes(contacts[0], portalAccounts[0].Id, 1, true);
        
    }
    
    @isTest
    public static void testGetValidationErrors1(){        
        
        List<Contact> contacts = [SELECT Id, AccountId FROM Contact where LastName = 'Con 1' limit 1];
        
        
         
        	Test.startTest();
        
        	String result = HUDValidationController.getValidationErrors('contact', contacts[0].Id);
            System.assertNotEquals(NULL, result);
        
        Test.stopTest();
        //System.assertEquals(true, isReset);
    }
    
    @isTest
    public static void testGetValidationErrors2(){        
        
        List<Contact> contacts = [SELECT Id, AccountId FROM Contact where LastName = 'Con 2' limit 1];
        
        
         
        	Test.startTest();
        
        	String result = HUDValidationController.getValidationErrors('contact', contacts[0].Id);
            System.assertNotEquals(NULL, result);
        
        Test.stopTest();
        //System.assertEquals(true, isReset);
    }
    
    @isTest
    public static void testGetValidationErrors3(){        
        
        List<Contact> contacts = [SELECT Id, AccountId FROM Contact where LastName = 'Con 3' limit 1];
        
        
         
        	Test.startTest();
        
        	String result = HUDValidationController.getValidationErrors('contact', contacts[0].Id);
            System.assertNotEquals(NULL, result);
        
        Test.stopTest();
        //System.assertEquals(true, isReset);
    }
    
    @isTest
    public static void testGetValidationErrors4(){        
        
        List<Intake__c> intake = [SELECT Id FROM Intake__c limit 1];
        
        
         
        	Test.startTest();
        
        	String result = HUDValidationController.getValidationErrors('Intake__c', intake[0].Id);
            System.assertNotEquals(NULL, result);
        
        Test.stopTest();
        //System.assertEquals(true, isReset);
    }
}