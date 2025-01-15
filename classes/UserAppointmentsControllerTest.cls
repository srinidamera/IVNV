@isTest
public class UserAppointmentsControllerTest {
    
    @TestSetup
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
            TestDataFactory.createCommunityUser(Constants.NW_COMPASS_PORTAL_PROFILE_NAME, 'test@UserAppointmentsControllerTest.com', 'Testing', true);
            List<sumoapp__AdditionalInfo__c> sumoEvents = TestDataFactory.createSumoEventInfo(1,true);
            Contact con = [Select Id from Contact where lastName='Testing' LIMIT 1];
            List<Event> events = new List<Event>();
            List<ClientCase__c> clientCase = TestDataFactory.createClientCases(1, true);
            for(Event evt : TestDataFactory.createEvent(con, sumoEvents[0].Id, 1, false)) {
                evt.WhatId=clientCase[0].Id;
                evt.StartDateTime = Date.today().addDays(2);
                events.add(evt);
            }
            insert events;
            /*System.debug('evt ==>'+events);
Event evt1 = [SELECT Id, What.Type FROM Event LIMIT 1]; 
System.debug('evt1 ==>'+evt1);
System.debug('type ==>'+evt1.What.Type);*/
            
            /*User user = [SELECT Id, ContactId FROM User WHERE LastName = 'Testing' LIMIT 1];
System.debug('user ==>'+user);*/
            EventRelation er = new EventRelation();
            er.RelationId = con.Id;//user.ContactId;
            er.EventId = events[0].Id;
            // Ensure no existing EventRelation with the same EventId and RelationId
            delete [SELECT Id FROM EventRelation WHERE EventId = :er.EventId AND RelationId = :er.RelationId];
            insert er;
        }
    }
    
    testmethod static void testGetUserAppointments() {
        User user = [Select Id from User where email='test@UserAppointmentsControllerTest.com'];
        System.runAs(user) {
            UserAppointmentsController.getUserAppointments('en-US');            
        }
        UserAppointmentsController.getPicklistValuesOfSubject();
    }
}