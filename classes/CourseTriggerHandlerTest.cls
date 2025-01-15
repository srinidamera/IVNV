@isTest
public class CourseTriggerHandlerTest {
    
    @isTest
    static void testAfterInsert() {
        // Create a new sumoapp__AdditionalInfo__c record
        Test.startTest();
        sumoapp__AdditionalInfo__c parent = new sumoapp__AdditionalInfo__c(sumoapp__StartDatetime__c=datetime.now());
        insert parent;
        sumoapp__AdditionalInfo__c child = new sumoapp__AdditionalInfo__c(sumoapp__Parent__c = parent.Id, sumoapp__StartDatetime__c=datetime.now(), sumoapp__EndDatetime__c=dateTime.now() + 1);
        insert child;
        sumoapp__AdditionalInfo__c child2 = new sumoapp__AdditionalInfo__c(sumoapp__Parent__c = parent.Id, sumoapp__StartDatetime__c=datetime.now(), sumoapp__EndDatetime__c=dateTime.now() + 1);
        insert child2;
        Test.stopTest();

    }
    
    @isTest
    static void testAfterUpdate() {
        sumoapp__AdditionalInfo__c parent = new sumoapp__AdditionalInfo__c(sumoapp__StartDatetime__c=datetime.now());
        insert parent;
        sumoapp__AdditionalInfo__c child = new sumoapp__AdditionalInfo__c(sumoapp__Parent__c = parent.Id, sumoapp__StartDatetime__c=datetime.now(), sumoapp__EndDatetime__c=dateTime.now() + 1);
        insert child;
        
        Test.startTest();
        child.sumoapp__EndDatetime__c = dateTime.now() + 2;
        update child;
        Test.stopTest();
    }
    
   
}