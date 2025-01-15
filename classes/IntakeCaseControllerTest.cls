@isTest
public class IntakeCaseControllerTest {
    
    @testSetup static void setup() {
        TestDataFactory.createCaseTypes(2, true);
    }
    
    @isTest
    static void testRetrieveClientCase() {
        // Create test data
        Contact testContact = new Contact(FirstName = 'Test', LastName = 'Contact');
        insert testContact;
        
        Id caseTypeId = [Select Id from CaseType__c LIMIT 1]?.Id;
        ClientCase__c testClientCase = new ClientCase__c(
            PrimaryClient__c = testContact.Id,
            OwnerId = UserInfo.getUserId(),
            CaseType__c = caseTypeId,
            ClientCaseStatus__c = 'In Progress'
        );
        insert testClientCase;
        
        Test.startTest();
        // Call the method
        List<ClientCase__c> result = IntakeCaseController.retrieveClientCase(new List<String>{testContact.Id});
        Test.stopTest();
        
    }
    
    @isTest
    static void testRetrieveIntakeRequests() {
        // Create test data
        Contact testContact = new Contact(FirstName = 'Test', LastName = 'Contact');
        insert testContact;
        
        
        Id caseTypeId = [Select Id from CaseType__c LIMIT 1]?.Id;
        
        Intake__c testIntake = new Intake__c(
            PrimaryClient__c = testContact.Id,
            OwnerId = UserInfo.getUserId(),
            CaseType__c = caseTypeId,
            Status__c = 'Open Intake'
        );
        insert testIntake;
        
        Test.startTest();
        // Call the method
        List<Intake__c> result = IntakeCaseController.retrieveIntakeRequests(new List<String>{testContact.Id});
        Test.stopTest();
        
        
    }
    
    @isTest
    static void testGetCoursesAppointmentRecords() {
        // Create test data
        Contact testContact = new Contact(FirstName = 'Test', LastName = 'Contact');
        insert testContact;
        
        Id caseTypeId = [Select Id from CaseType__c LIMIT 1]?.Id;
        // Check if the RecordType exists before querying
        
        Id courseRecordTypeId,eventRecordType = null;
        
        for(Schema.RecordTypeInfo info : Schema.getGlobalDescribe().get('sumoapp__additionalinfo__c').getDescribe().getRecordTypeInfos()) {
            SYstem.debug('Info : ' + info);
            if(info.getDeveloperName()=='Course') {
                courseRecordTypeId=info.getRecordTypeId();
            } else if(info.getDeveloperName()=='Event') {
                eventRecordType = info.getRecordTypeId();
            }
        }
        
        List<sumoapp__AdditionalInfo__c> addInfos = new List<sumoapp__AdditionalInfo__c>();
        for(sumoapp__AdditionalInfo__c addInfo : TestDataFactory.createSumoEvent(2,false)) {
            addInfo.RecordTypeId=eventRecordType;
            addInfo.Facilitator__c =UserInfo.getUserId();
            addInfos.add(addInfo);
        }
        insert addInfos;
        TestDataFactory.createAttendee(testContact, addInfos.get(0)?.Id, 2, true);
        
        
        Test.startTest();
        // Call the method
        List<IntakeCaseController.CourseWrapper> result = IntakeCaseController.getCourses(new List<String>{testContact.Id});
        Test.stopTest();
        
        
    }
    
    @isTest
    static void testGetCoursesRecords() {
        // Create test data
        Contact testContact = new Contact(FirstName = 'Test', LastName = 'Contact');
        insert testContact;
        
        
        Id courseRecordTypeId,eventRecordType = null;
        
        for(Schema.RecordTypeInfo info : Schema.getGlobalDescribe().get('sumoapp__additionalinfo__c').getDescribe().getRecordTypeInfos()) {
            SYstem.debug('Info : ' + info);
            if(info.getDeveloperName()=='Course') {
                courseRecordTypeId=info.getRecordTypeId();
            } else if(info.getDeveloperName()=='Event') {
                eventRecordType = info.getRecordTypeId();
            }
        }
        
        List<sumoapp__AdditionalInfo__c> addInfos = TestDataFactory.createSumoEvent(3,true);
        
        addInfos.get(0).sumoapp__Parent__c = addInfos.get(1)?.Id;
        addInfos.get(2).sumoapp__Parent__c = addInfos.get(1)?.Id;
        addInfos.get(0).RecordTypeId = courseRecordTypeId;
        addInfos.get(0).sumoapp__StartDatetime__c  = System.now();
        addInfos.get(1).RecordTypeId = courseRecordTypeId;
        addInfos.get(1).sumoapp__StartDatetime__c  = System.now();
        addInfos.get(2).RecordTypeId = courseRecordTypeId;
        addInfos.get(2).sumoapp__StartDatetime__c  = System.now();
        update addInfos;
        
        
        sumoapp__Attendee__c childAttendee = TestDataFactory.createAttendee(testContact, addInfos.get(1)?.Id, 1, true).get(0);
        sumoapp__Attendee__c parentAttendee = TestDataFactory.createAttendee(testContact, addInfos.get(0)?.Id, 1, true).get(0);
        TestDataFactory.createAttendee(testContact, addInfos.get(2)?.Id, 1, true);
        SYstem.debug('From Testclass : Child '+childAttendee);
        SYstem.debug('From Testclass : parent '+parentAttendee);
        SYstem.debug('From Testclass : Parent : Parent__c '+parentAttendee.sumoapp__SumoEvent__r.sumoapp__Parent__c);
        SYstem.debug('From Testclass : Parent : DeveloperName '+parentAttendee.sumoapp__SumoEvent__r.RecordType.DeveloperName);
        SYstem.debug('From Testclass : Child : Parent__c '+childAttendee.sumoapp__SumoEvent__r.sumoapp__Parent__c);
        SYstem.debug('From Testclass : Child : DeveloperName '+childAttendee.sumoapp__SumoEvent__r.RecordType.DeveloperName);
        
        
        Test.startTest();
        // Call the method
        List<IntakeCaseController.CourseWrapper> result = IntakeCaseController.getCourses(new List<String>{testContact.Id});
        Test.stopTest();
        
        
    }
}