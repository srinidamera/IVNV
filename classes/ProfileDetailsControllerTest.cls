@IsTest(SeeAllData=false)
public class ProfileDetailsControllerTest {
	@TestSetup
    static void makeData(){
        Profile adminProfile = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        UserRole ur = new UserRole(Name = 'Admin');
        insert ur;
        //UserRole role = [Select Id , name from UserRole limit 1]; //[Select Id , name from UserRole where Name='Admin'];
        
        Id profileId = [SELECT Id, Name FROM Profile WHERE Name LIKE '%Community%' LIMIT 1].Id;
        
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
        
        system.runAs(adminUser[0]){
            List<Account> portalAccounts = TestDataFactory.createAccounts(1, false);
            insert portalAccounts;
            
        	List<Contact> contacts = TestDataFactory.createContacts(portalAccounts[0].Id, 1, false);
            contacts[0].AccountId = portalAccounts[0].Id;
            insert contacts;
            
            List<User> userList = TestDataFactory.createUsers(profileId,'', 1, false);
            userList[0].UserName = 'utst123@test.com';
            userList[0].ContactId = contacts[0].Id;
            userList[0].UserRoleId = null;
            insert userList;
            
            PermissionSet pst = [SELECT Id FROM PermissionSet WHERE Name = 'NWCompassPortalPermissions'];
			insert new PermissionSetAssignment(AssigneeId = userList[0].Id, PermissionSetId = pst.Id);
        }
        
    }
    
    @isTest
    public static void testGetProfileDetails(){        
        
        List<Contact> contacts = [SELECT Id, AccountId FROM Contact WHERE Email = 'test@test.com1'];
        
        
        List<User> userList = [Select Id from User where UserName= 'utst123@test.com'];
		        
        Test.startTest();
        System.runAs(userList[0]){
            
        	ProfileDetailsController.ResultWrapper result = ProfileDetailsController.getProfileDetails();
            System.assertNotEquals(NULL, result);
            System.assertNotEquals(NULL, result.primaryContact);
            System.assertNotEquals(NULL, result.coApplicants);
        }
        Test.stopTest();
        //System.assertEquals(true, isReset);
    }
}