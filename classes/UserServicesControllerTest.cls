@isTest
public class UserServicesControllerTest {
	@testSetup 
    static void testSetup() {
        TestDataFactory.createCaseTypes(5,true);
        AutomationBypass__c temp = new AutomationBypass__c ();
        temp.IntakeAutomationBypass__c =true;
        insert temp;
    }
    
    /**
     * @desc: Test Method to test retrieveClientCase method of controller.
     */
    public static testMethod void testRetrieveClientCase() {
        CaseType__c caseType = [SELECT id FROM CaseType__c LIMIT 1];
        UserServicesController.getDesiredServiceRecord(caseType.Id);
        Map<String, Object> desireServiceMap = UserServicesController.getDesiredServices();
        System.assert(desireServiceMap.containsKey('mapping'));
        System.assert(desireServiceMap.containsKey('records'));
        System.assertEquals(2, desireServiceMap.size());
    }
    
    /**
     * @desc: Test Method to test getDesiredServiceRecord method of controller.
     */
    public static testMethod void testGetDesiredServiceRecord() {
        CaseType__c caseType = [SELECT id FROM CaseType__c LIMIT 1];
        Map<String, Object> desireServiceMap = UserServicesController.getDesiredServiceRecord(caseType.Id);
        System.assert(desireServiceMap.containsKey('mapping'));
        System.assert(desireServiceMap.containsKey('records'));
        System.assertEquals(2, desireServiceMap.size());
        System.assertEquals(1, ((List<CaseType__c>)desireServiceMap.get('records')).size());
    }
    
    /**
     * @desc: Test Method to test getDesiredServiceRecord method of controller.
     */
    public static testMethod void testGetIntakeDetails() {
        CaseType__c caseType = [SELECT id FROM CaseType__c LIMIT 1];
        Intake__c intake = new Intake__c();
        intake.CaseType__c = caseType.Id;
        insert intake;
        
        ClientCase__c cc = new ClientCase__c();
        cc.IntakeCase__c = intake.Id;
        cc.ClientCaseStatus__c='In Progress';
        insert cc;
        
        UserServicesController.Wrapper result = UserServicesController.getIntakeDetails(intake.Id);
        System.assertNotEquals(NULL, result);
        System.assertEquals(cc.Id, result.caseClientId);
    }
    
    public static testMethod void testGetClientCaseDetails() {
        CaseType__c caseType = [SELECT id FROM CaseType__c LIMIT 1];
        Intake__c intake = new Intake__c();
        intake.CaseType__c = caseType.Id;
        insert intake;
        
        ClientCase__c cc = new ClientCase__c();
        cc.IntakeCase__c = intake.Id;
        cc.ClientCaseStatus__c='In Progress';
        insert cc;
        
        UserServicesController.Wrapper result = UserServicesController.getIntakeDetails(cc.Id);
        System.assertNotEquals(NULL, result);
        System.assertEquals(cc.Id, result.caseClientId);
    }
    
    @isTest
    static void testGetEnrolledServicesRecord() {
        Map<String, Object> result = new Map<String, Object>();
        Test.startTest();
        UserServicesController.getEnrolledServicesRecord();
        Test.stopTest();
    }
    
}