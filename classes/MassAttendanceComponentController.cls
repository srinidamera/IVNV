public with sharing class MassAttendanceComponentController {
    /*
    * @description : To get Attendee records
    */ 
    @AuraEnabled(cacheable=true)
    public static List<sumoapp__Attendee__c> getAttendees(String additionalInfoId) {
        String eventId = String.escapeSingleQuotes(additionalInfoId);
        return [SELECT Id, sumoapp__ContactRelation__r.Name ,sumoapp__ContactRelation__r.Account.Name, sumoapp__Status__c, Notes__c,sumoapp__IsNotArrived__c, Attendance_Status__c, sumoapp__ContactRelation__r.RecordTypeId, sumoapp__ContactRelation__r.RecordType.Name 
                FROM sumoapp__Attendee__c where sumoapp__ContactRelation__r.Name != null AND sumoapp__ContactRelation__r.AccountId != null AND sumoapp__ContactRelation__r.RecordTypeId!=null AND sumoapp__SumoEvent__c=:eventId WITH SECURITY_ENFORCED Order BY sumoapp__ContactRelation__r.AccountId, sumoapp__ContactRelation__r.RecordType.DeveloperName desc];
    }
    
    /*
    * @description : To get Attendee records and metrics
    */ 
    @AuraEnabled
    public static AttendeeWrapper getCourseSeries(String additionalInfoId) {
        String eventId = String.escapeSingleQuotes(additionalInfoId);
        AttendeeWrapper wrapper = new AttendeeWrapper();
        Map<Id, sumoapp__AdditionalInfo__c> sessions = new Map<Id, sumoapp__AdditionalInfo__c>([Select Id from sumoapp__AdditionalInfo__c where sumoapp__Parent__c=:eventId]);
        wrapper.attendees = [SELECT Id, sumoapp__ContactRelation__r.Name ,sumoapp__ContactRelation__r.AccountId, sumoapp__ContactRelation__r.Account.Name, sumoapp__Status__c, Notes__c,sumoapp__IsNotArrived__c, Attendance_Status__c, sumoapp__ContactRelation__r.RecordTypeId, sumoapp__ContactRelation__r.RecordType.Name 
                            FROM sumoapp__Attendee__c where sumoapp__ContactRelation__r.Name != null AND sumoapp__ContactRelation__r.AccountId != null AND sumoapp__ContactRelation__r.RecordTypeId!=null AND sumoapp__SumoEvent__c In:sessions.keyset() WITH SECURITY_ENFORCED Order BY sumoapp__ContactRelation__r.AccountId];
        wrapper.totalCourseComplete = [Select count() from sumoapp__Attendee__c where Attendance_Status__c='Course Complete' AND sumoapp__SumoEvent__c =:eventId WITH SECURITY_ENFORCED];
        wrapper.totalCourseIncomplete = [Select count() from sumoapp__Attendee__c where Attendance_Status__c='Course Incomplete' AND sumoapp__SumoEvent__c =:eventId WITH SECURITY_ENFORCED];
        return wrapper;
    }

    @AuraEnabled(cacheable=true)
    public static Contact getContactDetail(String contactId) {
        return [SELECT Id, Name, Email, Account.Name FROM COntact WHERE Id =:  contactId LIMIT 1];
    }
    
    @AuraEnabled(cacheable=true)
    public static List<sumoapp__Attendee__c> getAttendeeRecords(String contactId) {
        if(String.isBlank(contactId)){
            return new List<sumoapp__Attendee__c>();
        }
        return [SELECT Id, Name, sumoapp__SumoEvent__c FROM sumoapp__Attendee__c WHERE sumoapp__ContactRelation__c =: contactId ];
    }
    
    public class AttendeeWrapper{
        @AuraEnabled
        public List<sumoapp__Attendee__c> attendees{get;set;}
        @AuraEnabled
        public Integer totalCourseComplete{get;set;}
        @AuraEnabled
        public Integer totalCourseIncomplete{get;set;}
        
    }
}