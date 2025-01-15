@isTest
public class EnrollmentFormControllerTest {
    
    @testSetup
    static void setup() {
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
        
        List<sumoapp__AdditionalInfo__c> courses = TestDataFactory.createSumoEvent(2, false);
        sumoapp__AdditionalInfo__c course = courses[0];
        insert course;
        sumoapp__AdditionalInfo__c courseWithChild = courses[1]; 
        courseWithChild.sumoapp__Parent__c = course.Id;
        insert courseWithChild;
	
        List<CaseType__c> caseTypes = TestDataFactory.createCaseTypes(1, true);
        List<ClientCase__c> clientCase = TestDataFactory.createClientCases(1, false);
        clientCase[0].CounselingTermination__c = 'Completed';
        insert clientCase;
        Intake__c intake = TestDataFactory.createIntakes(coApplicant, portalAccounts[0].id, 1, false)[0];
        intake.Status__c='Open Intake';
        intake.CaseType__c = caseTypes[0].Id;
        insert intake;
        
        CoApplicant__c coApplicantRecord = new CoApplicant__c();
        coApplicantRecord.Contact__c = primaryContact.Id;
        coApplicantRecord.IntakeRequest__c = intake.Id;
        insert coApplicantRecord;
    }
    
    @isTest
    static void testGetPicklistValues() {
        Test.startTest();
        List<String> fields = new List<String>{'MailingStateCode'};
            Map<String, List<EnrollmentFormController.PickListWrapper>> result = EnrollmentFormController.getPicklistValues(fields, 'Contact');
        System.assertNotEquals(null, result);
        System.assertNotEquals(null, result.get('MailingStateCode'));
        Test.stopTest();
    }
    
    /*@isTest
    static void testGetCoApplicantContacts() {
        UserRole userrole = [Select Id, DeveloperName From UserRole Limit 1];
        
        User adminUser = [Select Id, UserRoleId From User Where Profile.Name='System Administrator' Limit 1];
        
        adminUser.UserRoleId = userRole.Id;
        adminUser.isActive = true;
        User communityUser;
        update adminUser;
        System.runAs(adminUser){
            Id profileId = [Select Id From Profile Where Name ='Customer Community Login User'].Id;
            List<Contact> contacts = [SELECT Id FROM Contact WHERE Email = 'testrecord@test.com1'];
            communityUser = TestDataFactory.createCommunityUser('Customer Community Login User','userTest0001@gmail.com', 'Lname', true);
            //    communityUser.ContactId = primaryContact[0].Id;
            update communityUser;
        }
        System.runAs(communityUser) {
            List<Contact> contacts = EnrollmentFormController.getCoApplicantContacts();
            System.assertEquals(0, contacts.size());
        }
        
    }*/
    
    @isTest
    static void testGetPrimaryContactInformation() {
        Test.startTest();
        Contact primaryContact = EnrollmentFormController.getPrimaryContactInformation();
        System.assertNotEquals(null, primaryContact);
        Test.stopTest();
    }
    
    @isTest
    static void testGetCourseName() {
        sumoapp__AdditionalInfo__c course = [SELECT Id FROM sumoapp__AdditionalInfo__c LIMIT 1];
        Test.startTest();
        Map<String, Object> result = EnrollmentFormController.getCourseName(course.Id);
        System.assertEquals(course.Id, ((sumoapp__AdditionalInfo__c)result.get('record')).Id);
        Test.stopTest();
    }
    
    @isTest
    static void testUpdateRecords() {
        List<Contact> applicants = [SELECT Id FROM Contact WHERE RecordType.Name = 'Co-Applicant'];
        Contact primaryContact = [SELECT Id, ChoseNottoProvideIncome__c FROM Contact WHERE FirstName = 'Primary' LIMIT 1];
        sumoapp__AdditionalInfo__c course = [SELECT Id,IsParent__c,(select id from sumoapp__ChildEvents__r) FROM sumoapp__AdditionalInfo__c WHERE sumoapp__Parent__c != null LIMIT 1];
        Test.startTest();
        List<Object> result = EnrollmentFormController.updateRecords(primaryContact, applicants, course.Id);
        System.assertEquals(3, result.size());
        Test.stopTest();
    }
    
    @isTest
    static void testUpdateRecordsWithChild() {
        List<Contact> applicants = [SELECT Id FROM Contact WHERE RecordType.Name = 'Co-Applicant'];
        Contact primaryContact = [SELECT Id, ChoseNottoProvideIncome__c FROM Contact WHERE FirstName = 'Primary' LIMIT 1];
        sumoapp__AdditionalInfo__c course = [SELECT Id,IsParent__c,(select id from sumoapp__ChildEvents__r) FROM sumoapp__AdditionalInfo__c WHERE sumoapp__Parent__c = null LIMIT 1];
        Test.startTest();
        List<Object> result = EnrollmentFormController.updateRecords(primaryContact, applicants, course.Id);
        System.assertEquals(3, result.size());
        Test.stopTest();
    }
    
    @isTest
    static void testFetchAllContactCoApplicants() {
        ClientCase__c clientCase = [SELECT Id FROM ClientCase__c LIMIT 1];
        Test.startTest();
        List<Object> result = EnrollmentFormController.fetchAllContactCoApplicants(clientCase.Id);
        Test.stopTest();
    }
    
    @isTest
    static void testInsertCoApplicant() {
        Intake__c intake = [SELECT Id FROM Intake__c LIMIT 1];
        Contact primaryContact = [SELECT Id FROM Contact WHERE Email = 'primary@example.com' LIMIT 1];
        Test.startTest();
        EnrollmentFormController.insertCoApplicant(intake.Id, primaryContact.Id);
        Test.stopTest();
    }
    
    @isTest
    static void testDeleteCoApplicant() {
        CoApplicant__c coApplicant = [SELECT Id FROM CoApplicant__c LIMIT 1];
        Test.startTest();
        EnrollmentFormController.deleteCoApplicant(coApplicant.Id);
        Test.stopTest();
    }
    
    @isTest
    static void testGetRecordStatusIntake() {
        String intakeId = [SELECT Id FROM Intake__c LIMIT 1].Id;
         System.debug('intakeId===>'+intakeId);
        Test.startTest();
        String status = EnrollmentFormController.getRecordStatus(intakeId);
        System.assertEquals('Open Intake', status);
        Test.stopTest();
    }
    
    @isTest
    static void testGetRecordStatusClientCase() {
        String clientCaseId = [SELECT Id FROM ClientCase__c LIMIT 1].Id;
        System.debug('clientCaseId===>'+clientCaseId);
        Test.startTest();
        String status = EnrollmentFormController.getRecordStatus(clientCaseId);
        System.assertEquals('Closed - Incomplete', status);
        Test.stopTest();
    }
}