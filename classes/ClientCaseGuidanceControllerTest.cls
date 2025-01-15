/**
* @description    : Test Class for ClientCaseGuidanceController
**/
@IsTest
public with sharing class ClientCaseGuidanceControllerTest {
    @TestSetup
    static void makeData() {
        Account acc = TestDataFactory.createAccounts(1, true)[0];
        Contact con = TestDataFactory.createContacts(acc.Id, 1, true)[0];
        CaseType__c csType = new CaseType__c();
        insert csType;
        ClientCase__c clCase = TestDataFactory.createClientCases(1, true)[0];
        List<ClientCaseTask__c> clCaseTaskList = TestDataFactory.createClientCaseTasks(
            clCase,
            4,
            true
        );
    }
    
    @IsTest
    static void verifyStatusPicklist() {
        Test.startTest();
        List<Utility.PicklistOption> status = ClientCaseGuidanceController.getStatusPicklist();
        Test.stopTest();
        System.assert(status.size() > 0);
    }
    
    @IsTest
    static void verifyClientCaseTasks() {
        ClientCase__c clCase = [SELECT Id FROM ClientCase__c LIMIT 1];
        Test.startTest();
        List<ClientCaseTask__c> clCaseTasks = ClientCaseGuidanceController.getClientCaseTasks(
            clCase.Id
        );
        Test.stopTest();
        System.assertEquals(4, clCaseTasks.size());
    }
    
    @IsTest
    static void verifyUpdateClientCaseTask() {
        ClientCaseTask__c clCaseTask = [
            SELECT Id
            FROM ClientCaseTask__c
            WHERE Status__c = 'Not Started'
            LIMIT 1
        ];
        Test.startTest();
        ClientCaseGuidanceController.updateClientCaseTask(
            clCaseTask.Id,
            'Done',
            'Test to update Comment.'
        );
        Test.stopTest();
        List<ClientCaseTask__c> clCaseTaskList = [
            SELECT Id, Status__c, Comments__c
            FROM ClientCaseTask__c
            WHERE Id = :clCaseTask.Id
        ];
        System.assertEquals('Done', clCaseTaskList[0].Status__c);
        System.assertEquals(
            'Test to update Comment.',
            clCaseTaskList[0].Comments__c
        );
    }
    
    @IsTest
    static void verifyExceptionHandling() {
        Test.startTest();
        ClientCaseGuidanceController.updateClientCaseTask(
            'FAKE_ID',
            'Done',
            'Test to update Comment.'
        );
        Test.stopTest();
        List<Log__c> logs = [
            SELECT Id, ClassName__c, RelatedToRecord__c
            FROM Log__c
        ];
        System.assertEquals('FAKE_ID', logs[0].RelatedToRecord__c);
    }
    
    @IsTest
    static void verifyIsIntakeStaffUser() {
        Test.startTest();
        Boolean isIntakeStaffUser = ClientCaseGuidanceController.isIntakeStaffUser();
        Test.stopTest();
    }
}