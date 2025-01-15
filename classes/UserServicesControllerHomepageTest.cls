@isTest
public class UserServicesControllerHomepageTest {
    
    @testSetup static void setup() {
        Profile adminProfile = [Select id from Profile where name = 'System Administrator' limit 1];
        UserRole ur = new UserRole(Name = 'Admin');
        insert ur;
        
        User adminUser = TestDataFactory.createUsers(adminProfile.Id, '', 1, true)[0];
        
        adminUser.UserRoleId = ur.Id;
        update adminUser;
        
        PermissionSet ps = [SELECT Id, Name FROM PermissionSet WHERE Name = 'SUMOPlatformAdmin' LIMIT 1];
        PermissionSet ps1 = [SELECT Id, Name FROM PermissionSet WHERE Name = 'NWCompassHUDReportingPermissions' LIMIT 1];
        PermissionSet ps2 = [SELECT Id, Name FROM PermissionSet WHERE Name = 'NWCompassQuarterlyReportingPermissions' LIMIT 1];
        PermissionSet ps3 = [SELECT Id, Name FROM PermissionSet WHERE Name = 'NWCompassSystemAdminPermissions' LIMIT 1];
        PermissionSet ps4 = [SELECT Id, Name FROM PermissionSet WHERE Name = 'NWCompassStandardPermissions' LIMIT 1];
        //SELECT Id, PermissionSetId, AssigneeId, Assignee.Name FROM PermissionSetAssignment WHERE PermissionSetId =  '0PSHF0000007qyB4AQ'
        List<PermissionSetAssignment> psaList = new List<PermissionSetAssignment>();
        //insert psa;
        PermissionSetAssignment psa = new PermissionSetAssignment(AssigneeId = adminUser.Id, PermissionSetId = ps.Id);
        PermissionSetAssignment psa1 = new PermissionSetAssignment(AssigneeId = adminUser.Id, PermissionSetId = ps1.Id);
        PermissionSetAssignment psa2 = new PermissionSetAssignment(AssigneeId = adminUser.Id, PermissionSetId = ps2.Id);
        PermissionSetAssignment psa3 = new PermissionSetAssignment(AssigneeId = adminUser.Id, PermissionSetId = ps3.Id);
        PermissionSetAssignment psa4 = new PermissionSetAssignment(AssigneeId = adminUser.Id, PermissionSetId = ps4.Id);
        
        
        psaList.add(psa);
        psaList.add(psa1);
        psaList.add(psa2);
        psaList.add(psa3);
        psaList.add(psa4);
        insert psaList;
        
        System.runAs(adminUser){
            TestDataFactory.createCommunityUser(Constants.NW_COMPASS_PORTAL_PROFILE_NAME, 'test@UserServicesControllerHomepageTest.com', 'Testing', true);
            TestDataFactory.createCaseTypes(5,true);
            List<Contact> contacts = [Select Id, AccountId from Contact where LastName='Testing' LIMIT 1];
            List<Intake__C> intakes = TestDataFactory.createIntakes(contacts[0], contacts[0].AccountId, 5, true);
            List<ClientCase__c> cases = TestDataFactory.createClientCases(1,false);
            cases[0].IntakeCase__c =intakes[0].Id;
            insert cases;
        }
    }
    
    testMethod static void TestGetUserServices() {
        User user = [Select id from User where email='test@UserServicesControllerHomepageTest.com'];
        System.runAs(user) {
            UserServicesControllerHomepage.getUserServices();            
        }
    }
}