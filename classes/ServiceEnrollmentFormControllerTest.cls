@isTest
public class ServiceEnrollmentFormControllerTest {
    @testSetup
    static void setup() {
        
         Profile adminProfile = [Select id from Profile where name = 'System Administrator' limit 1];
         UserRole ur = new UserRole(Name = 'Admin');
         insert ur;
        
        List<User> adminUser = TestDataFactory.createUsers(adminProfile.Id,ur.Id, 1, false);
        insert adminUser;
        
        PermissionSet ps = [SELECT Id, Name FROM PermissionSet WHERE Name = 'SUMOPlatformAdmin' LIMIT 1];
        PermissionSet ps1 = [SELECT Id, Name FROM PermissionSet WHERE Name = 'NWCompassHUDReportingPermissions' LIMIT 1];
        PermissionSet ps2 = [SELECT Id, Name FROM PermissionSet WHERE Name = 'NWCompassQuarterlyReportingPermissions' LIMIT 1];
        PermissionSet ps3 = [SELECT Id, Name FROM PermissionSet WHERE Name = 'NWCompassSystemAdminPermissions' LIMIT 1];
        PermissionSet ps4 = [SELECT Id, Name FROM PermissionSet WHERE Name = 'NWCompassStandardPermissions' LIMIT 1];
        //SELECT Id, PermissionSetId, AssigneeId, Assignee.Name FROM PermissionSetAssignment WHERE PermissionSetId =  '0PSHF0000007qyB4AQ'
        List<PermissionSetAssignment> psaList = new List<PermissionSetAssignment>();
        //insert psa;
        PermissionSetAssignment psa = new PermissionSetAssignment(AssigneeId = adminUser[0].Id, PermissionSetId = ps.Id);
        PermissionSetAssignment psa1 = new PermissionSetAssignment(AssigneeId = adminUser[0].Id, PermissionSetId = ps1.Id);
        PermissionSetAssignment psa2 = new PermissionSetAssignment(AssigneeId = adminUser[0].Id, PermissionSetId = ps2.Id);
        PermissionSetAssignment psa3 = new PermissionSetAssignment(AssigneeId = adminUser[0].Id, PermissionSetId = ps3.Id);
        PermissionSetAssignment psa4 = new PermissionSetAssignment(AssigneeId = adminUser[0].Id, PermissionSetId = ps4.Id);
        
        
        psaList.add(psa);
        psaList.add(psa1);
        psaList.add(psa2);
        psaList.add(psa3);
        psaList.add(psa4);
        insert psaList;
        
        System.runAs(adminUser[0]){
            TestDataFactory.createCaseTypes(1, true);
            
            Account acc = new Account();
            acc.Name = 'test';
            insert acc;
            RecordType rt = [Select Id, DeveloperName from RecordType where DeveloperName='Prospect' limit 1];
            // Create test contacts
            Contact primaryContact = new Contact(
                FirstName = 'Primary',
                LastName = 'Contact',
                Email = 'primary@example.com',
                Phone = '1234567890',
                MailingStreet = '123 Test St',
                MailingCity = 'Testville',
                MailingStateCode = 'AL',
                MailingPostalCode = '12345',
                Ethnicity__c = 'Hispanic',
                Race__c = 'More than one race',
                Gender__c = 'Male',
                EnglishProficiency__c = 'Limited English Proficient',
                HouseholdSize__c = 3,
                TotalMonthlyIncome__c = 5000,
               // X1stTimeHomeBuyer__c = true,
                RuralAreaStatus__c = 'Lives in a rural area',
                AccountId = acc.Id,
                RecordTypeId = rt.Id
            );
            System.debug('user ===>'+primaryContact);
            insert primaryContact; 
            
            Contact coApplicant = new Contact(
                FirstName = 'CoApplicant',
                LastName = 'Contact',
                Email = 'coapplicant@example.com',
                Phone = '0987654321',
                RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Co-Applicant').getRecordTypeId(),
                MailingStreet = '456 Test Ave',
                MailingCity = 'Sampleton',
                MailingStateCode = 'CA',
                MailingPostalCode = '67890',
                Ethnicity__c = 'Hispanic',
                Race__c = 'More than one race',
                Gender__c = 'Male',
                EnglishProficiency__c = 'Limited English Proficient',
                HouseholdSize__c = 2,
                TotalMonthlyIncome__c = 4000,
                RuralAreaStatus__c = 'Lives in a rural area'
            );
            insert coApplicant;
            
            Intake__c intake = new Intake__c();
            intake.Household__c = primaryContact.AccountId;
            intake.PrimaryClient__c = primaryContact.Id;
            insert intake;
            
            CoApplicant__c coApplicantRecord = new CoApplicant__c();
            coApplicantRecord.Contact__c = primaryContact.Id;
            coApplicantRecord.IntakeRequest__c = intake.Id;
            insert coApplicantRecord;
        }
    }
    
    @isTest
    static void testGetService() {
        Map<String, Object> result = new Map<String, Object>();
        CaseType__c caseType = [SELECT Id FROM CaseType__c LIMIT 1];
        Test.startTest();
        result = ServiceEnrollmentFormController.getService(caseType.Id);
        CaseType__c serviceRecord = (CaseType__c) result.get('record');
        System.assertEquals('Test1', serviceRecord.Name);
        Test.stopTest();
    }
    
    
    @isTest
    static void testEnrolledToService() {
        String result;
        CaseType__c caseType = [SELECT Id FROM CaseType__c LIMIT 1];
        Contact primaryContact = [SELECT Id, MailingState, MailingStateCode, MailingStreet, MailingCity, MailingPostalCode, Race__c, Ethnicity__c, Gender__c, Education__c,MaritalStatus__c,
                                  EnglishProficiency__c, ActiveMilitary__c, DisabledStatus__c, X1stTimeHomeBuyer__c , RuralAreaStatus__c, HouseholdType__c,
                                  HouseholdSize__c, TotalMonthlyIncome__c, NumberOfDependents__c, CreditScore__c, EmploymentStatus__c, MailingAddressLine2__c FROM Contact WHERE Email = 'primary@example.com' LIMIT 1];
        primaryContact.MailingState = null;
        update primaryContact;
        List <Contact> applicants = [SELECT Id FROM Contact WHERE Email = 'coapplicant@example.com' LIMIT 1];
        result = ServiceEnrollmentFormController.enrolledToService(primaryContact, applicants, caseType.Id);
        System.assert(!String.isEmpty(result));
    }
    
    
    @isTest
    static void testGetEnrolledServiceDetails() {
        Map<String, Object> result = new Map<String, Object>();
        Intake__c intake = [SELECT Id FROM Intake__c LIMIT 1];
        Test.startTest();
        result = ServiceEnrollmentFormController.getEnrolledServiceDetails(intake.Id);
        List<Contact> coApplicants = (List<Contact>) result.get('CoApplicants');
        Test.stopTest();
    }
}