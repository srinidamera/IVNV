@isTest
public class HUD9902SummaryReportGenerateBatchTest {    
    
    @testSetup
    static void setup() {
    
        List<User> adminUser = new List<User>();
        Profile adminProfile = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        String uniqueUserName = 'standarduser' + DateTime.now().getTime() + '@testorg.com';
        adminUser = TestDataFactory.createUsers(adminProfile.Id,'', 1, false);
        adminUser[0].isActive = true;
        adminUser[0].IsCounselor__c = true;
        adminUser[0].CounselorHUDID__c = 'HUD451';
        adminUser[0].CMSCounselorID__c = '17775';
        adminUser[0].EmploymentEndDate__c = Date.today();
        adminUser[0].EmploymentStartDate__c = Date.today().addYears(-1);
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
        
        RecordType fccRT = [SELECT Id FROM RecordType WHERE DeveloperName = 'FinancialCapabilityCounseling' AND SObjectType = :HUD9902Helper.CLIENT_CASE_OBJECT LIMIT 1];
        Id primaryClientRecordTypeId = [SELECT Id FROM RecordType WHERE SObjectType = 'Contact' AND Name = 'Primary Client' LIMIT 1].Id;
        
        System.runAs(adminUser[0]) {
        TestDataFactory.createX9902(1, True);
        Account acc = TestDataFactory.createAccounts(1, True)[0];
        Contact con = TestDataFactory.createContacts(acc.Id, 1, false)[0];
        con.RecordTypeId = primaryClientRecordTypeId;
        insert con;
        
        List<sumoapp__AdditionalInfo__c> SumoEvents = TestDataFactory.createSumoEvent(5, false);
        for (sumoapp__AdditionalInfo__c AdditionalInfo: SumoEvents) {
            AdditionalInfo.RecordTypeId = Schema.SObjectType.sumoapp__AdditionalInfo__c.getRecordTypeInfosByName().get('Course').getRecordTypeId();
            AdditionalInfo.sumoapp__EndDatetime__c = DateTime.now().addDays(5);
            AdditionalInfo.Facilitator__c = adminUser[0].Id;
            AdditionalInfo.sumoapp__StartDatetime__c =  Date.Today();
            AdditionalInfo.HUD_Purpose__c = 'Completed rental workshop';
            
        }
        insert SumoEvents;
        
        sumoapp__Attendee__c Attendee = TestDataFactory.createAttendee(con, SumoEvents[0].Id, 1, false)[0];
        Attendee.Attendance_Status__c = 'Course Complete';
        Attendee.ExcludeAttendeeFromHUD9902__c = false;      
        insert Attendee;
        
        Intake__c Intake = TestDataFactory.createIntakes(con, acc.Id, 1, True)[0];
        
        List<ClientCase__c> clientCases = TestDataFactory.createClientCases(5, false);
        for (Integer i = 0; i < 5; i++) {
            clientCases[i].IntakeDate__c = Date.newInstance(2023, 1, 15).addDays(i);
            clientCases[i].RecordTypeId = fccRT.Id; 
        }
        insert clientCases;
        
        List<Event> events = TestDataFactory.createEvent(con, SumoEvents[0].Id, 5, False);
        
        integer i=0;
        for (sumoapp__AdditionalInfo__c course : SumoEvents) {
            events[i].sumoapp__AdditionalInfo__c = course.Id;
            events[i].WhatId = clientCases[i].id;
            events[i].Purpose__c = 'Rental Topics';
            events[i].ActivityDateTime = Date.today();
            events[i].StartDateTime = Date.today();
            events[i].EndDateTime = Date.today();
            events[i].DurationInMinutes = 0;
            events[i].AppointmentStatus__c = 'Attended';
            i++;            
        }
        insert events;
        }
    }
    
    @isTest
    static void testBatchExecution() {
        X9902__c x9902 = [SELECT Id FROM X9902__c LIMIT 1];
        HUD9902SummaryReportGenerateBatch batch = new HUD9902SummaryReportGenerateBatch(x9902.Id);
        Test.startTest();
        Database.executeBatch(batch);
        Contact con = [SELECT Id, Ethnicity__c, Race__C, AreaMedianIncome__c, RuralAreaStatus__c, EnglishProficiency__c FROM Contact LIMIT 1];
        con.Ethnicity__c = 'Hispanic';
        con.Race__C = 'American Indian/Alaskan Native';
        con.AreaMedianIncome__c = 'Below 30% of AMI';
        con.RuralAreaStatus__c = 'Lives in a rural area';
        con.EnglishProficiency__c = 'Limited English Proficient';
        update con;
        Database.executeBatch(batch);
        Test.stopTest();
        
    }

    static void testBatchExecution1() {
        X9902__c x9902 = [SELECT Id FROM X9902__c LIMIT 1];
        HUD9902SummaryReportGenerateBatch batch = new HUD9902SummaryReportGenerateBatch(x9902.Id);
        Test.startTest();
        Contact con = [SELECT Id, Ethnicity__c, Race__C, AreaMedianIncome__c, RuralAreaStatus__c, EnglishProficiency__c FROM Contact LIMIT 1];
        con.Ethnicity__c = 'Not Hispanic';
        con.RuralAreaStatus__c = 'Does not live in a rural area';
        con.Race__C = 'Black or African American';
        con.AreaMedianIncome__c = '50 - 79% of AMI';
        con.EnglishProficiency__c = 'Not Limited English Proficient';
        update con;
        Database.executeBatch(batch);
        Test.stopTest();
    }
    static void testBatchExecution2() {
        X9902__c x9902 = [SELECT Id FROM X9902__c LIMIT 1];
        HUD9902SummaryReportGenerateBatch batch = new HUD9902SummaryReportGenerateBatch(x9902.Id);
        Test.startTest();
        Contact con = [SELECT Id, Ethnicity__c, Race__C, AreaMedianIncome__c, RuralAreaStatus__c, EnglishProficiency__c FROM Contact LIMIT 1];
        con.Ethnicity__c = 'Not Hispanic';
        con.RuralAreaStatus__c = 'Does not live in a rural area';
        con.EnglishProficiency__c = 'Not Limited English Proficient';
        con.Race__C = 'Native Hawaiian or Other Pacific Islander';
        con.AreaMedianIncome__c = '80 - 100% of AMI';
        update con;
        Database.executeBatch(batch);
        Test.stopTest();
    }
    static void testBatchExecution3() {
        X9902__c x9902 = [SELECT Id FROM X9902__c LIMIT 1];
        HUD9902SummaryReportGenerateBatch batch = new HUD9902SummaryReportGenerateBatch(x9902.Id);
        Test.startTest();
        Contact con = [SELECT Id, Ethnicity__c, Race__C, AreaMedianIncome__c, RuralAreaStatus__c, EnglishProficiency__c FROM Contact LIMIT 1];
        con.Ethnicity__c = 'Not Hispanic';
        con.RuralAreaStatus__c = 'Does not live in a rural area';
        con.EnglishProficiency__c = 'Not Limited English Proficient';
        con.Race__C = 'White';
        con.AreaMedianIncome__c = '101% - 120% of AMI';
        update con;
        Database.executeBatch(batch);
        Test.stopTest();
    }
    static void testBatchExecution4() {
        X9902__c x9902 = [SELECT Id FROM X9902__c LIMIT 1];
        HUD9902SummaryReportGenerateBatch batch = new HUD9902SummaryReportGenerateBatch(x9902.Id);
        Test.startTest();
        Contact con = [SELECT Id, Ethnicity__c, Race__C, AreaMedianIncome__c, RuralAreaStatus__c, EnglishProficiency__c FROM Contact LIMIT 1];
        con.Ethnicity__c = 'Not Hispanic';
        con.RuralAreaStatus__c = 'Does not live in a rural area';
        con.EnglishProficiency__c = 'Not Limited English Proficient';
        con.Race__C = 'More than one race';
        con.AreaMedianIncome__c = '101% - 120% of AMI';
        update con;
        Database.executeBatch(batch);
        Test.stopTest();
    }
    
    @isTest
    static void testNoClientCases() {
        X9902__c x9902 = [SELECT Id FROM X9902__c LIMIT 1];
        delete [SELECT Id FROM ClientCase__c];
        HUD9902SummaryReportGenerateBatch batch = new HUD9902SummaryReportGenerateBatch(x9902.Id);
        Test.startTest();
        Database.executeBatch(batch);
        Test.stopTest();
    }
    
    @isTest
    static void testBatchWithNoCourses() {
        X9902__c x9902Record = new X9902__c(
            PeriodStartDate__c = Date.today().addDays(-30),
            PeriodEndDate__c = Date.today(),
            Quarter__c = 'Quarter 1'
        );
        insert x9902Record;
        List<ClientCase__c> clientCases = TestDataFactory.createClientCases(2, true);
        Test.startTest();
        HUD9902SummaryReportGenerateBatch batch = new HUD9902SummaryReportGenerateBatch(x9902Record.Id);
        Database.executeBatch(batch);
        Test.stopTest();
    }
    
    @IsTest
    static void testUpdateCount_HudActivityTypeNotBilled() {
        X9902__c x9902Record = new X9902__c(
            PeriodStartDate__c = Date.today().addDays(-30),
            PeriodEndDate__c = Date.today(),
            Quarter__c = 'Quarter 1'
        );
        insert x9902Record;
        String hudActivityType = 'Not Billed to HUD';
        String key = 'SomeKey';
        Map<String, Integer> picklistToActivityCount = new Map<String, Integer>{ key => 2 };
            
            HUD9902SummaryReportGenerateBatch instance = new HUD9902SummaryReportGenerateBatch(x9902Record.Id);
        instance.updateCount(hudActivityType, key, picklistToActivityCount);
    }
    
    @IsTest
    static void testUpdateCount_HudActivityTypeOther() {
        X9902__c x9902Record = new X9902__c(
            PeriodStartDate__c = Date.today().addDays(-30),
            PeriodEndDate__c = Date.today(),
            Quarter__c = 'Quarter 1'
        );
        insert x9902Record;
        
        String hudActivityType = 'Picklist Value'; 
        String key = 'SomeKey';
        Map<String, Integer> picklistToActivityCount = new Map<String, Integer>{ key => 2 };       
            HUD9902SummaryReportGenerateBatch instance = new HUD9902SummaryReportGenerateBatch(x9902Record.Id);
        instance.updateCount(hudActivityType, key, picklistToActivityCount);
    }
    
}