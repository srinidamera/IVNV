@IsTest
public class Hud9902SummaryDataControllerTest {

    @testSetup
    static void setup() {
        RecordType fccRT = [SELECT Id FROM RecordType WHERE DeveloperName = 'FinancialCapabilityCounseling'];
        Id primaryClientRecordTypeId = [SELECT Id FROM RecordType WHERE SObjectType = 'Contact' AND Name = 'Primary Client' LIMIT 1].Id;
        
        
        TestDataFactory.createX9902(1, True);
        Account acc = TestDataFactory.createAccounts(1, True)[0];
        
        List<Contact> conList = TestDataFactory.createContacts(acc.Id, 7, false);
        conList[0].Ethnicity__c = 'Hispanic';
        conList[0].Race__c = 'American Indian/Alaskan Native';
        conList[0].AreaMedianIncome__c = 'Below 30% of AMI';
        conList[0].RuralAreaStatus__c = 'Lives in a rural area';
        conList[0].EnglishProficiency__c = 'Limited English Proficient';
        conList[0].RecordTypeId = primaryClientRecordTypeId;
        
        conList[1].Ethnicity__c = 'Not Hispanic';
        conList[1].Race__c = 'Asian';
        conList[1].AreaMedianIncome__c = '30 - 49% of AMI';
        conList[1].RuralAreaStatus__c = 'Does not live in a rural area';
        conList[1].EnglishProficiency__c = 'Not Limited English Proficient';
        conList[1].RecordTypeId = primaryClientRecordTypeId;
        
        conList[2].Ethnicity__c = 'Hispanic';
        conList[2].Race__c = 'Black or African American';
        conList[2].AreaMedianIncome__c = '50 - 79% of AMI';
        conList[2].RuralAreaStatus__c = 'Lives in a rural area';
        conList[2].EnglishProficiency__c = 'Limited English Proficient';
        conList[2].RecordTypeId = primaryClientRecordTypeId;
        
        conList[3].Ethnicity__c = 'Hispanic';
        conList[3].Race__c = 'Native Hawaiian or Other Pacific Islander';
        conList[3].AreaMedianIncome__c = '80 - 100% of AMI';
        conList[3].RuralAreaStatus__c = 'Does not live in a rural area';
        conList[3].EnglishProficiency__c = 'Limited English Proficient';
        conList[3].RecordTypeId = primaryClientRecordTypeId;
        
        conList[4].Ethnicity__c = 'Not Hispanic';
        conList[4].Race__c = 'More than one race';
        conList[4].AreaMedianIncome__c = '101% - 120% of AMI';
        conList[4].RuralAreaStatus__c = 'Lives in a rural area';
        conList[4].EnglishProficiency__c = 'Limited English Proficient';
        conList[4].RecordTypeId = primaryClientRecordTypeId;
        
        conList[5].Ethnicity__c = 'Hispanic';
        conList[5].Race__c = 'White';
        conList[5].AreaMedianIncome__c = '101% - 120% of AMI';
        conList[5].RuralAreaStatus__c = 'Lives in a rural area';
        conList[5].EnglishProficiency__c = 'Not Limited English Proficient';
        conList[5].RecordTypeId = primaryClientRecordTypeId;
        
        conList[6].Ethnicity__c = 'Chose not to respond';
        conList[6].Race__c = 'Chose not to respond';
        conList[6].AreaMedianIncome__c = 'Chose not to respond';
        conList[6].RuralAreaStatus__c = 'Chose not to respond';
        conList[6].EnglishProficiency__c = 'Chose not to respond';
        conList[6].RecordTypeId = primaryClientRecordTypeId;
        
        insert conList;
        
        /*Contact con = TestDataFactory.createContacts(acc.Id, 1, false)[0];
        con.RecordTypeId = primaryClientRecordTypeId;
        insert con;*/
        
        
        List<User> adminUser = new List<User>();
        Profile adminProfile = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        String uniqueUserName = 'standarduser' + DateTime.now().getTime() + '@testorg.com';
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com',
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = adminProfile.Id,
                          TimeZoneSidKey='America/Los_Angeles',
                          UserName=uniqueUserName
                         );
        System.runAs(u) {
            adminUser = TestDataFactory.createUsers(adminProfile.Id,'', 2, false);
            
            adminUser[0].isActive = true;
            adminUser[0].IsCounselor__c = true;
            adminUser[0].CounselorHUDID__c = 'HUD451';
            adminUser[0].CMSCounselorID__c = '11111';
            adminUser[0].EmploymentEndDate__c = Date.today();
            adminUser[0].EmploymentStartDate__c = Date.today().addYears(-1);
            
            adminUser[1].isActive = true;
            adminUser[1].IsCounselor__c = true;
            adminUser[1].CounselorHUDID__c = 'HUD452';
            adminUser[1].CMSCounselorID__c = '22222';
            adminUser[1].EmploymentEndDate__c = Date.today();
            adminUser[1].EmploymentStartDate__c = Date.today().addYears(-1);
            
            insert adminUser;
        }
        
        List<sumoapp__AdditionalInfo__c> SumoEvents = TestDataFactory.createSumoEvent(5, false);
        for (sumoapp__AdditionalInfo__c AdditionalInfo: SumoEvents) {
            AdditionalInfo.RecordTypeId = Schema.SObjectType.sumoapp__AdditionalInfo__c.getRecordTypeInfosByName().get('Course').getRecordTypeId();
            AdditionalInfo.sumoapp__EndDatetime__c = DateTime.newInstance(2024, 1, 15).addDays(5);
            AdditionalInfo.Facilitator__c = adminUser[0].Id;
            AdditionalInfo.sumoapp__StartDatetime__c =  Date.Today();
            AdditionalInfo.HUD_Purpose__c = 'Completed rental workshop';
            
        }
        insert SumoEvents;
        
        List<sumoapp__Attendee__c> Attendees = TestDataFactory.createAttendee(conList[0], SumoEvents[0].Id, 7, false);
        
        
        integer i=0;
        for (sumoapp__Attendee__c att : Attendees) {
            att.Attendance_Status__c = 'Course Complete';
            att.sumoapp__ContactRelation__c = conList[i].Id;          
            i++;
        }
        
        insert Attendees;
        
        Intake__c Intake = TestDataFactory.createIntakes(conList[0], acc.Id, 1, True)[0];
        
        List<ClientCase__c> clientCases = TestDataFactory.createClientCases(5, false);
        for (Integer j = 0; i < 5; i++) {
            clientCases[j].IntakeDate__c = Date.newInstance(2023, 1, 15).addDays(j);
            clientCases[j].RecordTypeId = fccRT.Id; 
        }
        insert clientCases;
        
        List<Event> events = TestDataFactory.createEvent(conList[0], SumoEvents[0].Id, 7, False);
        
        i=0;
        for (sumoapp__AdditionalInfo__c course : SumoEvents) {
            events[i].sumoapp__AdditionalInfo__c = course.Id;
            events[i].WhatId = clientCases[i].id;
            events[i].WhoId = conList[i].Id;
            events[i].Purpose__c = 'Rental Topics';
            events[i].ActivityDateTime = Date.newInstance(2024, 2, 1);
            events[i].StartDateTime = Date.newInstance(2024, 2, 1);
            events[i].EndDateTime = Date.newInstance(2024, 2, 2);
            events[i].DurationInMinutes = 1440;
            events[i].AppointmentStatus__c = 'Attended';
            i++;            
        }
        insert events;
        
    }

    @IsTest
    static void testGetData() {
        X9902__c x9902Record = [SELECT Id FROM X9902__c LIMIT 1];

        // Call the method and assert results
        Hud9902SummaryDataController.RetrunWrapper result = Hud9902SummaryDataController.getData(x9902Record.Id);
        
        // Validate the result is not null
        System.assertNotEquals(null, result);

        System.assertNotEquals(NULL, result.recs);
        System.assertNotEquals(0, result.recs.size());
    }
}