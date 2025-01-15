/**
* @description  : Test class for ForgotUserPasswordController
**/

@isTest
public with sharing class ForgotUserPasswordControllerTest {
    @TestSetup
    static void makeData(){
        List<Account> portalAccounts = TestDataFactory.createAccounts(1, true);
        List<Contact> contacts = TestDataFactory.createContacts(portalAccounts[0].Id, 1, true);
    }
    
    @isTest
    public static void testResetPortalPasswordSuccess(){ 
         Profile adminProfile = [SELECT Id FROM Profile WHERE Name='System Administrator'];
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
            Id profileId = [Select Id From Profile Where Name ='Customer Community Login User'].Id;
            List<Contact> contacts = [SELECT Id FROM Contact WHERE Email = 'testrecord@test.com1'];
            User userList = TestDataFactory.createCommunityUser('Customer Community Login User','testrecord@test.com1', 'Lname', true);
            Test.startTest();
            Boolean isReset = ForgotUserPasswordController.resetCommunityUserPassword(userList.Email);
            Test.stopTest();
            
        }
    }
    
    @isTest
    public static void testResetPortalPasswordFailure(){        
        Test.startTest();
        Boolean isReset = ForgotUserPasswordController.resetCommunityUserPassword('abc@Test.com');
        Test.stopTest();
        System.assertEquals(false, isReset);
    }
}