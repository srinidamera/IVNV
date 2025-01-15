/*
* @author         Mahesh Panda
* @description    Controller class containing methods for Course Management
* @date           2024-04-12
* @group          Course Management
*/
public with sharing class CourseManagementController {
    
    /*
* @description    This method is used to get the courses on load of the course management screen
*/
    @AuraEnabled(cacheable=true)
    public static List<sumoapp__AdditionalInfo__c> getCourses() {
        if(Schema.sObjectType.sumoapp__AdditionalInfo__c.isAccessible()){
            return [Select Id,RecordType.DeveloperName,sumoapp__EventName__c, sumoapp__StartDatetime__c, sumoapp__EndDatetime__c, sumoapp__VirtualEventType__c,  
                     sumoapp__DurationInMinutes__c,sumoapp__Price__c, sumoapp__TotalRegisteredAttendee__c, sumoapp__Capacity__c, sumoapp__LocationType__c, Total_Duration_In_Minutes__c, sumoapp__Status__c,
                     Open_Seats__c, TotalEnrolled__c, sumoapp__Category__r.sumoapp__Label__c, Facilitator__c, Facilitator__r.Name, sumoapp__Organizer__r.Name, sumoapp__PricePerSeat__c,  
                    (Select Id,sumoapp__EventName__c, sumoapp__StartDatetime__c, sumoapp__EndDatetime__c, sumoapp__VirtualEventType__c, 
                     sumoapp__DurationInMinutes__c,sumoapp__Price__c, sumoapp__TotalRegisteredAttendee__c, sumoapp__Capacity__c, sumoapp__LocationType__c, sumoapp__Status__c,
                     Open_Seats__c, TotalEnrolled__c, sumoapp__Category__r.sumoapp__Label__c, Facilitator__c, Facilitator__r.Name, sumoapp__Organizer__r.Name, sumoapp__PricePerSeat__c    
                     from sumoapp__ChildEvents__r order by sumoapp__StartDatetime__c DESC) 
                    FROM sumoapp__AdditionalInfo__c 
                    where (sumoapp__StartDatetime__c = THIS_YEAR OR sumoapp__EndDatetime__c = THIS_YEAR) 
                    AND (RecordType.DeveloperName = 'Course' or RecordType.DeveloperName = 'Event') 
                    and sumoapp__Parent__c=null WITH SECURITY_ENFORCED order by sumoapp__StartDatetime__c DESC];
        }
        return null;
    }
    
    /*
* @description    This method is used to get the contact related to enrollment related functionality
*/
    @AuraEnabled(cacheable=true)
    public static List<Contact> getContacts(Id eventId) {
        Set<Id> contactIds = new Set<Id>();

        for(sumoapp__Attendee__c attendee:[SELECT Id, sumoapp__ContactRelation__c from sumoapp__Attendee__c where sumoapp__SumoEvent__c=:eventId]){
            contactIds.add(attendee.sumoapp__ContactRelation__c);
        }
        if(Schema.sObjectType.Contact.isAccessible()){
            return [Select id, LastName, FirstName, Phone, RecordType.Name, Email FROM Contact where Id Not In:contactIds and RecordType.DeveloperName IN ('CoApplicant', 'PrimaryClient', 'Prospect') WITH SECURITY_ENFORCED order by createddate desc];
        }
        return null;
    }
    
    /*
* @description    This method is used to filter courses based on start date and end date
*/
    @AuraEnabled(cacheable=true)
    public static List<sumoapp__AdditionalInfo__c> filterRows(String searchKeyword, Date startDate, Date endDate) {
        searchKeyword = String.escapeSingleQuotes(searchKeyword);
        searchKeyword = '%'+searchKeyword+'%';
        if(Schema.sObjectType.sumoapp__AdditionalInfo__c.isAccessible()){
            List<sumoapp__AdditionalInfo__c> recList = [Select id,RecordType.DeveloperName,sumoapp__Price__c, sumoapp__EndDatetime__c, sumoapp__EventName__c, sumoapp__RecurringCount__c, sumoapp__StartDatetime__c, sumoapp__LocationType__c,
                                                         sumoapp__DurationInMinutes__c, sumoapp__TotalRegisteredAttendee__c, sumoapp__Capacity__c, sumoapp__VirtualEventType__c,Total_Duration_In_Minutes__c, sumoapp__Status__c,
                                                         Open_Seats__c, TotalEnrolled__c, sumoapp__Category__r.sumoapp__Label__c, Facilitator__c, Facilitator__r.Name, sumoapp__Organizer__r.Name, sumoapp__PricePerSeat__c , 
                                                        (Select Id,sumoapp__EventName__c,sumoapp__Price__c, sumoapp__StartDatetime__c, sumoapp__EndDatetime__c, sumoapp__LocationType__c, sumoapp__Status__c,
                                                         sumoapp__DurationInMinutes__c,Total_Duration_In_Minutes__c, sumoapp__TotalRegisteredAttendee__c, sumoapp__Capacity__c, sumoapp__VirtualEventType__c,
                                                         Open_Seats__c, TotalEnrolled__c, sumoapp__Category__r.sumoapp__Label__c, Facilitator__c, Facilitator__r.Name, sumoapp__Organizer__r.Name, sumoapp__PricePerSeat__c
                                                         FROM sumoapp__ChildEvents__r WHERE (sumoapp__EventName__c like :searchKeyword or 
                                                                                             sumoapp__Organizer__r.Name like :searchKeyword or 
                                                                                             sumoapp__Category__r.sumoapp__Label__c like :searchKeyword or 
                                                                                             sumoapp__LocationType__c like :searchKeyword)) 
                                                        FROM sumoapp__AdditionalInfo__c 
                                                        WHERE (RecordType.DeveloperName = 'Course' or RecordType.DeveloperName = 'Event') 
                                                        AND sumoapp__Parent__c = null
                                                        AND ((sumoapp__StartDatetime__c >= :startDate AND sumoapp__StartDatetime__c <= :endDate) 
                                                             OR (sumoapp__EndDatetime__c >= :startDate AND sumoapp__EndDatetime__c <= :endDate))
                                                        WITH SECURITY_ENFORCED
                                                        ORDER BY sumoapp__StartDatetime__c DESC];
            List<sumoapp__AdditionalInfo__c> finalRecList = new List<sumoapp__AdditionalInfo__c>();
            searchKeyword = searchKeyword.remove('%');
            for(sumoapp__AdditionalInfo__c rec : recList){
                if(rec.sumoapp__ChildEvents__r.size() > 0 || (string.isNotBlank(rec.sumoapp__EventName__c) && rec.sumoapp__EventName__c.containsIgnoreCase(searchKeyword))){
                    finalRecList.add(rec);
                }
            }
            return finalRecList;
        }
        return null;
    }

    @AuraEnabled
      public static void createAttendees(List<Id> contactIds, Id eventId, boolean isParent) {
          Set<Id> existingAttendeeIds = new Set<Id>();
          List<sumoapp__Attendee__c> attendees = new List<sumoapp__Attendee__c>();
          Map<Id, sumoapp__AdditionalInfo__c> eventMap = isParent?new Map<Id, sumoapp__AdditionalInfo__c>([Select Id, sumoapp__Parent__c, RecordType.DeveloperName from sumoapp__AdditionalInfo__c where sumoapp__Parent__c=:eventId ]):new Map<Id, sumoapp__AdditionalInfo__c>([Select Id, sumoapp__Parent__c,RecordType.DeveloperName from sumoapp__AdditionalInfo__c where Id=:eventId ]);
          Map<Id,Contact> conMap = new Map<Id,Contact>([Select id, HouseholdofAMI__c, AreaMedianIncome__c, RuralAreaStatus__c, Race__c, Ethnicity__c, EnglishProficiency__c, X1stTimeHomeBuyer__c,
                                                        MailingStreet, MailingCity, MailingStateCode, MailingCountryCode, MailingPostalCode, ChoseNottoProvideIncome__c from Contact where id in:contactIds WITH SECURITY_ENFORCED]);
          Map<Id, sumoapp__Attendee__c> attendeeMap = new Map<Id, sumoapp__Attendee__c>([Select Id, sumoapp__SumoEvent__c, sumoapp__ContactRelation__c from sumoapp__Attendee__c where sumoapp__SumoEvent__c IN: eventMap.keyset()]);
          for(sumoapp__Attendee__c attendee: attendeeMap.values()){
                if(contactIds.contains(attendee.sumoapp__ContactRelation__c)){

                 existingAttendeeIds.add(attendee.sumoapp__ContactRelation__c);
                }
          }
          
          for (Id contactId : contactIds) {
            if(!existingAttendeeIds.contains(contactId)){
            boolean isParentCreated = false;
            for(sumoapp__AdditionalInfo__c event:eventMap.values()){
                if(!isParentCreated && event.RecordType.DeveloperName!='Event'){
                    sumoapp__Attendee__c attendee = new sumoapp__Attendee__c();
                    attendee.sumoapp__ContactRelation__c = contactId;
                    attendee.sumoapp__SumoEvent__c = event.sumoapp__Parent__c;
                    attendee.HouseholdofAMI__c = conMap.get(contactId).HouseholdofAMI__c;
                    attendee.AreaMedianIncome__c = conMap.get(contactId).AreaMedianIncome__c;
                    attendee.RuralAreaStatus__c = conMap.get(contactId).RuralAreaStatus__c;
                    attendee.Race__c = conMap.get(contactId).Race__c;
                    attendee.Ethnicity__c = conMap.get(contactId).Ethnicity__c;
                    attendee.X1stTimeHomeBuyer__c = conMap.get(contactId).X1stTimeHomeBuyer__c;
                    attendee.EnglishProficiency__c = conMap.get(contactId).EnglishProficiency__c;
                    attendee.MailingAddress__Street__s = conMap.get(contactId).MailingStreet;
                    attendee.MailingAddress__City__s = conMap.get(contactId).MailingCity;
                    attendee.MailingAddress__StateCode__s = conMap.get(contactId).MailingStateCode;
                    attendee.MailingAddress__CountryCode__s = conMap.get(contactId).MailingCountryCode;
                    attendee.MailingAddress__PostalCode__s = conMap.get(contactId).MailingPostalCode;
                    attendee.ChoseNottoProvideIncome__c = conMap.get(contactId).ChoseNottoProvideIncome__c;
                    attendee.sumoapp__NumberOfSeats__c = 1;
                    attendees.add(attendee);
                    isParentCreated = true;
                }
                sumoapp__Attendee__c attendee = new sumoapp__Attendee__c();
                attendee.sumoapp__ContactRelation__c = contactId;
                attendee.sumoapp__SumoEvent__c = event.Id;
                attendee.HouseholdofAMI__c = conMap.get(contactId).HouseholdofAMI__c;
                attendee.AreaMedianIncome__c = conMap.get(contactId).AreaMedianIncome__c;
                attendee.RuralAreaStatus__c = conMap.get(contactId).RuralAreaStatus__c;
                attendee.Race__c = conMap.get(contactId).Race__c;
                attendee.Ethnicity__c = conMap.get(contactId).Ethnicity__c;
                attendee.X1stTimeHomeBuyer__c = conMap.get(contactId).X1stTimeHomeBuyer__c;
                attendee.EnglishProficiency__c = conMap.get(contactId).EnglishProficiency__c;
                attendee.MailingAddress__Street__s = conMap.get(contactId).MailingStreet;
                attendee.MailingAddress__City__s = conMap.get(contactId).MailingCity;
                attendee.MailingAddress__StateCode__s = conMap.get(contactId).MailingStateCode;
                attendee.MailingAddress__CountryCode__s = conMap.get(contactId).MailingCountryCode;
                attendee.MailingAddress__PostalCode__s = conMap.get(contactId).MailingPostalCode;
                attendee.ChoseNottoProvideIncome__c = conMap.get(contactId).ChoseNottoProvideIncome__c;
                attendee.sumoapp__NumberOfSeats__c = 1;
                attendees.add(attendee);
            }
          }
        }
          system.debug('attendees '+attendees);
        if(!attendees.isempty()){
          insert attendees;
        }
      }
}