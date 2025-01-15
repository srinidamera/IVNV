public with sharing class AttendeeController {

    public static Id primaryclientRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('PrimaryClient').getRecordTypeId();
    /*
    * @description : To get Attendee records
    */ 
    @AuraEnabled(cacheable=true)
    public static List<sumoapp__Attendee__c> getAttendees(String additionalInfoId) {
        return [SELECT Id, sumoapp__ContactRelation__r.Name ,sumoapp__ContactRelation__r.Account.Name, sumoapp__Status__c, Notes__c,sumoapp__IsNotArrived__c, Attendance_Status__c, sumoapp__ContactRelation__r.RecordTypeId, sumoapp__ContactRelation__r.RecordType.Name 
                FROM sumoapp__Attendee__c where sumoapp__ContactRelation__r.Name != null AND sumoapp__ContactRelation__r.AccountId != null AND sumoapp__ContactRelation__r.RecordTypeId!=null AND sumoapp__SumoEvent__c=:additionalInfoId WITH SECURITY_ENFORCED Order BY sumoapp__ContactRelation__r.AccountId];
    }
    
    /*
    * @description : To get Attendee records and metrics
    */ 
    @AuraEnabled
    public static AttendeeWrapper getCourseSeries(String additionalInfoId) {
        AttendeeWrapper wrapper = new AttendeeWrapper();
        Map<Id, sumoapp__AdditionalInfo__c> sessions = new Map<Id, sumoapp__AdditionalInfo__c>([Select Id from sumoapp__AdditionalInfo__c where sumoapp__Parent__c=:additionalInfoId]);
        wrapper.attendees = [SELECT Id, sumoapp__ContactRelation__r.Name ,sumoapp__ContactRelation__r.Account.Name, sumoapp__Status__c, Notes__c,sumoapp__IsNotArrived__c, Attendance_Status__c, sumoapp__ContactRelation__r.RecordTypeId, sumoapp__ContactRelation__r.RecordType.Name 
                            FROM sumoapp__Attendee__c where sumoapp__ContactRelation__r.Name != null AND sumoapp__ContactRelation__r.AccountId != null AND sumoapp__ContactRelation__r.RecordTypeId!=null AND sumoapp__SumoEvent__c In:sessions.keyset() WITH SECURITY_ENFORCED Order BY sumoapp__ContactRelation__r.AccountId];
        wrapper.totalCourseComplete = [Select count() from sumoapp__Attendee__c where Attendance_Status__c='Course Complete' AND sumoapp__SumoEvent__c In:sessions.keyset() WITH SECURITY_ENFORCED];
        wrapper.totalCourseIncomplete = [Select count() from sumoapp__Attendee__c where Attendance_Status__c='Course Incomplete' AND sumoapp__SumoEvent__c In:sessions.keyset() WITH SECURITY_ENFORCED];
        return wrapper;
    }

    @AuraEnabled
    public static void updateAttendeeAttendance(List<Id> attendeeIds, String status, boolean convertProspect, List<Id> prospectContactIds, 
                                                List<Id> prospectAndPrimaryClientContactIds) {
        Map<Id,Contact> conMap = new Map<Id,Contact>();
        if(convertProspect != null && convertProspect == true && prospectContactIds != null ){
            List<Contact> conToUpdate = new List<Contact>();
            for (Id conId : prospectContactIds) {
                conToUpdate.add(new Contact(
                    Id = conId, RecordTypeId = primaryclientRecordTypeId
                ));
            }
            update conToUpdate;
        }
        if(prospectAndPrimaryClientContactIds != null){
            conMap = new Map<Id,Contact>([Select id, RuralAreaStatus__c, HouseholdofAMI__c, AreaMedianIncome__c, ReferralSource__c, MailingCity, MailingState, MailingStateCode, MailingCountryCode, MailingPostalCode, X1stTimeHomeBuyer__c, EnglishProficiency__c, Race__c, Ethnicity__c from Contact where Id in : prospectAndPrimaryClientContactIds]);
        }
        if(attendeeIds.size() > 0){
            List<sumoapp__Attendee__c> attendeesToUpdate = new List<sumoapp__Attendee__c>();
            Map<Id,sumoapp__Attendee__c> attMap = new Map<Id,sumoapp__Attendee__c>([Select id, sumoapp__ContactRelation__c from sumoapp__Attendee__c where id in : attendeeIds]);
            for (Id attendeeId : attendeeIds) {
                sumoapp__Attendee__c att = new sumoapp__Attendee__c();
                att.Id = attendeeId;
                att.Attendance_Status__c = status;
                att.RuralAreaStatus__c = conMap.containskey(attMap.get(attendeeId).sumoapp__ContactRelation__c) ? conMap.get(attMap.get(attendeeId).sumoapp__ContactRelation__c).RuralAreaStatus__c : '';
                att.HouseholdofAMI__c = conMap.containskey(attMap.get(attendeeId).sumoapp__ContactRelation__c) ? conMap.get(attMap.get(attendeeId).sumoapp__ContactRelation__c).HouseholdofAMI__c : 0;
                att.AreaMedianIncome__c = conMap.containskey(attMap.get(attendeeId).sumoapp__ContactRelation__c) ? conMap.get(attMap.get(attendeeId).sumoapp__ContactRelation__c).AreaMedianIncome__c : '';
                
                if(status == 'Course Complete'){
                    att.ReferralSource__c = conMap.containskey(attMap.get(attendeeId).sumoapp__ContactRelation__c) ? conMap.get(attMap.get(attendeeId).sumoapp__ContactRelation__c).ReferralSource__c : '';
                    att.MailingAddress__City__s = conMap.containskey(attMap.get(attendeeId).sumoapp__ContactRelation__c) ? conMap.get(attMap.get(attendeeId).sumoapp__ContactRelation__c).MailingCity : '';
                    att.MailingAddress__StateCode__s = conMap.containskey(attMap.get(attendeeId).sumoapp__ContactRelation__c) ? conMap.get(attMap.get(attendeeId).sumoapp__ContactRelation__c).MailingStateCode : '';
                    att.MailingAddress__CountryCode__s = conMap.containskey(attMap.get(attendeeId).sumoapp__ContactRelation__c) ? conMap.get(attMap.get(attendeeId).sumoapp__ContactRelation__c).MailingCountryCode : '';
                    att.MailingAddress__PostalCode__s = conMap.containskey(attMap.get(attendeeId).sumoapp__ContactRelation__c) ? conMap.get(attMap.get(attendeeId).sumoapp__ContactRelation__c).MailingPostalCode : '';
                    att.X1stTimeHomeBuyer__c = conMap.containskey(attMap.get(attendeeId).sumoapp__ContactRelation__c) ? conMap.get(attMap.get(attendeeId).sumoapp__ContactRelation__c).X1stTimeHomeBuyer__c : '';
                    att.EnglishProficiency__c = conMap.containskey(attMap.get(attendeeId).sumoapp__ContactRelation__c) ? conMap.get(attMap.get(attendeeId).sumoapp__ContactRelation__c).EnglishProficiency__c : '';
                    att.Race__c = conMap.containskey(attMap.get(attendeeId).sumoapp__ContactRelation__c) ? conMap.get(attMap.get(attendeeId).sumoapp__ContactRelation__c).Race__c : '';
                    att.Ethnicity__c = conMap.containskey(attMap.get(attendeeId).sumoapp__ContactRelation__c) ? conMap.get(attMap.get(attendeeId).sumoapp__ContactRelation__c).Ethnicity__c : '';
                }
                
                attendeesToUpdate.add(att);
            }
            update attendeesToUpdate;
        }
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