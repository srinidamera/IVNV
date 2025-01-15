/*
* @description: Provides test coverage to ClassesController and SObjectUtility.
*/
@IsTest
public with sharing class ClassesControllerTest {
    static final String LANG_ENGLISH = 'en-US';
    static final String LANG_SPANISH = 'es';
    @TestSetup
    static void makeData(){
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
        
        
        Id recTypeId = Schema.sObjectType.Sumoapp__AdditionalInfo__c.getRecordTypeInfosByName().get('Event').getRecordTypeId();
        system.runAs(adminUser[0]){
             User communityUser = TestDataFactory.createCommunityUser(Constants.NW_COMPASS_PORTAL_PROFILE_NAME, 'userTest0001@gmail.com', 'lName', true);
        
            Sumoapp__AdditionalInfo__c parent = TestDataFactory.createSumoEvent(1,false)[0];
            parent.sumoapp__StartDatetime__c = datetime.now();
            parent.RecordTypeId = recTypeId;
            parent.Public__c = true;
            insert parent;
            
            Sumoapp__AdditionalInfo__c child = TestDataFactory.createSumoEvent(1,false)[0];
            child.sumoapp__Parent__c = parent.Id;
            child.sumoapp__StartDatetime__c=datetime.now();
            child.RecordTypeId = recTypeId;
            child.Public__c = true;
            insert child;
            
            Contact con = [select id from Contact where id = : communityUser.ContactId];
            sumoapp__Attendee__c attendee = TestDataFactory.createAttendee(con, child.id, 1, true)[0];
        }
        
    }
    
    @isTest
    static void verifyGetAllParentClasses() {
        Test.startTest();
        List<ClassesController.ClassWrapper> parentClassesEng = ClassesController.getAllParentClasses(LANG_ENGLISH);
        List<ClassesController.ClassWrapper> parentClassesEs = ClassesController.getAllParentClasses(LANG_SPANISH);
        List<ClassesController.ClassWrapper> parentClassesOther = ClassesController.getAllParentClasses(' ');
        Test.stopTest();
        
        System.assert(parentClassesEng.size() > 0);
        System.assert(parentClassesEs.size() > 0);
        System.assert(parentClassesOther.size() == 0);
    }
    
    @isTest
    static void verifyGetClassesForLoggedInUser() {
        List<ClassesController.ClassWrapper> classesLoggedInEng;
        List<ClassesController.ClassWrapper> classesLoggedInEs;
        List<ClassesController.ClassWrapper> classesLoggedInOther;
        User communityUser = [SELECT Id FROM User WHERE Email = 'userTest0001@gmail.com' LIMIT 1];
        
        Test.startTest();
        System.runAs(communityUser) {
            classesLoggedInEng = ClassesController.getClassesForLoggedInUser(LANG_ENGLISH);
            classesLoggedInEs = ClassesController.getClassesForLoggedInUser(LANG_SPANISH);
            classesLoggedInOther = ClassesController.getClassesForLoggedInUser(' ');
        }
        Test.stopTest();
        
        System.assert(classesLoggedInEng.size() > 0);
        System.assert(classesLoggedInEs.size() > 0);
        System.assert(classesLoggedInOther.size() == 0);
    }
    
    @isTest
    static void verifyGetOptedClasses() {
        List<ClassesController.ClassWrapper> classesOptedInEng;
        List<ClassesController.ClassWrapper> classesOptedInEs;
        List<ClassesController.ClassWrapper> classesOptedInOther;
        
        User communityUser = [SELECT Id FROM User WHERE Email = 'userTest0001@gmail.com' LIMIT 1];
        
        Test.startTest();
        System.runAs(communityUser) {
            classesOptedInEng = ClassesController.getOptedClasses(LANG_ENGLISH);
            classesOptedInEs = ClassesController.getOptedClasses(LANG_SPANISH);
            classesOptedInOther = ClassesController.getOptedClasses(' ');
        }
        Test.stopTest();
        
        System.assert(classesOptedInEng.size() > 0);
        System.assert(classesOptedInEs.size() > 0);
        System.assert(classesOptedInOther.size() == 0);
    }
    
    @isTest
    static void verifyGetClassDetails() {
        ClassesController.ClassWrapper classesDetailsEng;
        ClassesController.ClassWrapper classesDetailsEs;
        ClassesController.ClassWrapper classesDetailsOther;
        Sumoapp__AdditionalInfo__c parentClass = [SELECT Id FROM Sumoapp__AdditionalInfo__c 
                                                  WHERE IsParent__c = true 
                                                  AND sumoapp__Parent__c = NULL
                                                  AND RecordType.DeveloperName IN ('Course', 'Event', 'EventClass')
                                                  LIMIT 1
                                                 ];
        User communityUser = [SELECT Id FROM User WHERE Email = 'userTest0001@gmail.com' LIMIT 1];
        
        Test.startTest();
        System.runAs(communityUser) {
            
            classesDetailsEng = ClassesController.getClassDetails(LANG_ENGLISH, parentClass.Id);
            classesDetailsEs = ClassesController.getClassDetails(LANG_SPANISH, parentClass.Id);
            classesDetailsOther = ClassesController.getClassDetails(' ', parentClass.Id);
        }
        Test.stopTest();
        
        System.assert(classesDetailsEng.id != null);
        System.assert(classesDetailsEs.id != null);
        System.assert(classesDetailsOther.id == null);
    }
}