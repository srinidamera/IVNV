@istest
public class ContactTriggerTest {
    @testSetup 
    static void testSetup() {
        Account acc = new Account(Name='Test Account');
        insert acc;
        
        Contact con = new Contact(FirstName='Test First', LastName='Last Test',Phone='9999999999',AccountId=acc.Id, TotalMonthlyIncome__c=1000);
        insert con;
        
    }
    
    @istest
    static void reCalculateTotalHouseholdIncomeonUpdate() {
        Contact con = [Select Id, TotalMonthlyIncome__c, AccountId from Contact limit 1];
        con.TotalMonthlyIncome__c = 2000;
        Test.startTest();
        update con;
        Test.stopTest();
        
    }
    
    @istest
    static void reCalculateTotalHouseholdIncomeonDelete() {
        Contact con = [Select Id, TotalMonthlyIncome__c, AccountId from Contact limit 1];
        Test.startTest();
        delete con;
        Test.stopTest();
        
    }
    
    
}