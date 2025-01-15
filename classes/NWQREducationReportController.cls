/**
 * @description       : Controller of HudOrsEducationReport lwc for NWQR reporting
 * @group             : 
**/
public with sharing class NWQREducationReportController {
    
    public static DateTime GMTStartDate;
    public static DateTime GMTEndDate;
    
    public static void setUTCStartEndDateTime(Date qtrStartDate,Date qtrEndDate){
        DateTime qtrStartDateTime = DateTime.newInstance(qtrStartDate.year(), qtrStartDate.month(), qtrStartDate.day());
        DateTime qtrEndDateTime = DateTime.newInstance(qtrEndDate.year(), qtrEndDate.month(), qtrEndDate.day(),23,59,59);
    	GMTStartDate = qtrStartDateTime.addHours(-UserInfo.getTimeZone().getOffset(qtrStartDateTime) / 3600000);
        GMTEndDate = qtrEndDateTime.addHours(-UserInfo.getTimeZone().getOffset(qtrEndDateTime) / 3600000);
    }
    
    /*
    * @description : method to fetch Education records
    */
    @AuraEnabled
    public static List<OrsReportWrapper> fetchOrsEducationRecords(Date qtrStartDate,Date qtrEndDate){
        setUTCStartEndDateTime(qtrStartDate, qtrEndDate);
        String currentUserTimeZone = [select id,TimeZoneSidKey from user where id =: UserInfo.getUserId()].TimeZoneSidKey;
        system.debug('GMTStartDate = '+GMTStartDate);
        system.debug('GMTEndDate = '+GMTEndDate);
        
        List<OrsReportWrapper> orsWrapperList = new List<OrsReportWrapper>();
        String recordTypeIDEvent = Schema.getGlobalDescribe().get('sumoapp__AdditionalInfo__c').getDescribe().getRecordTypeInfosByName().get('Event').getRecordTypeId();
        String recordTypeIDCourse = Schema.getGlobalDescribe().get('sumoapp__AdditionalInfo__c').getDescribe().getRecordTypeInfosByName().get('Course').getRecordTypeId();
        String recordTypeIDPrimaryClient = Schema.getGlobalDescribe().get('Contact').getDescribe().getRecordTypeInfosByName().get('Primary Client').getRecordTypeId();

        List<sumoapp__Attendee__c> attendeeList = [select sumoapp__ContactRelation__r.Client__c, sumoapp__ContactRelation__r.Age__c, sumoapp__ContactRelation__r.Gender__c, sumoapp__ContactRelation__r.Race__c, sumoapp__ContactRelation__r.Ethnicity__c,
                                                   sumoapp__ContactRelation__r.DisabledStatus__c, sumoapp__ContactRelation__r.HouseholdType__c, sumoapp__ContactRelation__r.HouseholdSize__c, sumoapp__ContactRelation__r.HouseholdMonthlyIncome1__c, sumoapp__ContactRelation__r.AreaMedianIncome__c,
                                                   sumoapp__ContactRelation__r.PreferredLanguage__c, sumoapp__ContactRelation__r.MailingStreet, sumoapp__ContactRelation__r.MailingAddressLine2__c, sumoapp__ContactRelation__r.MailingCity, sumoapp__ContactRelation__r.MailingStateCode,
                                                   sumoapp__ContactRelation__r.MailingPostalCode, sumoapp__ContactRelation__r.RuralAreaStatus__c, sumoapp__SumoEvent__r.sumoapp__EndDatetime__c, Outcome__c
                                                   from sumoapp__Attendee__c
                                                   where sumoapp__SumoEvent__r.sumoapp__EndDatetime__c <=: GMTEndDate and sumoapp__SumoEvent__r.sumoapp__EndDatetime__c >=: GMTStartDate
                                                   and ((Attendance_Status__c = 'Course Complete' and sumoapp__SumoEvent__r.recordTypeId =: recordTypeIDCourse) or 
                                                        (Attendance_Status__c = 'Attended - Complete' and sumoapp__SumoEvent__r.recordTypeId =: recordTypeIDEvent))
                                                   and sumoapp__SumoEvent__r.IsParent__c = true and sumoapp__ContactRelation__r.recordTypeId =: recordTypeIDPrimaryClient 
                                                   and sumoapp__SumoEvent__r.ExcludeCourseFromHUD9902__c != true and Outcome__c != null
                                                   and sumoapp__SumoEvent__r.sumoapp__Status__c != 'CANCELED' WITH SECURITY_ENFORCED limit 49999];
        
        List<NWQR_Picklist_Mapping__mdt> pickListAdj = [select id, Label__c, Value__c from NWQR_Picklist_Mapping__mdt where (ObjectApiName__c = 'Contact' OR ObjectApiName__c = 'sumoapp__Attendee__c') And (FieldApiName__c = 'AreaMedianIncome__c' OR FieldApiName__c = 'Gender__c' OR FieldApiName__c = 'Outcome__c' OR FieldApiName__c = 'Race__c')];
        
        Map<String,String> labelValueMap = new Map<String,String>();
        for(NWQR_Picklist_Mapping__mdt mdt : pickListAdj){
            if(mdt.Value__c != null && mdt.Label__c != null){
                labelValueMap.put(mdt.Value__c,mdt.Label__c);
            }
        }
        system.debug('labelValueMap = '+labelValueMap);
        for(sumoapp__Attendee__c attendee : attendeeList){
            OrsReportWrapper orswrap = new OrsReportWrapper();
            orswrap.Client_ID = attendee.sumoapp__ContactRelation__r.Client__c;
            orswrap.Age = attendee.sumoapp__ContactRelation__r.Age__c;
            
            if(labelValueMap.containsKey(attendee.sumoapp__ContactRelation__r.Gender__c)){
                orswrap.Gender = labelValueMap.get(attendee.sumoapp__ContactRelation__r.Gender__c);
            }else{
                orswrap.Gender = attendee.sumoapp__ContactRelation__r.Gender__c;
            }

            if(labelValueMap.containsKey(attendee.sumoapp__ContactRelation__r.Race__c)){
                orswrap.Race = labelValueMap.get(attendee.sumoapp__ContactRelation__r.Race__c);
            }else{
                orswrap.Race = attendee.sumoapp__ContactRelation__r.Race__c;
            }
            orswrap.Ethnicity = attendee.sumoapp__ContactRelation__r.Ethnicity__c;
            if(attendee.sumoapp__ContactRelation__r.DisabledStatus__c == 'Yes'){
                orswrap.Disability = 'Disabled';
            }else if(attendee.sumoapp__ContactRelation__r.DisabledStatus__c == 'No'){
                orswrap.Disability = 'Not disabled';
            }
            orswrap.Household_Type = attendee.sumoapp__ContactRelation__r.HouseholdType__c;
            orswrap.Household_Size = attendee.sumoapp__ContactRelation__r.HouseholdSize__c;
            orswrap.Monthly_Household_Income = attendee.sumoapp__ContactRelation__r.HouseholdMonthlyIncome1__c;
            if(labelValueMap.containsKey(attendee.sumoapp__ContactRelation__r.AreaMedianIncome__c)){
                orswrap.Household_Income_Band = labelValueMap.get(attendee.sumoapp__ContactRelation__r.AreaMedianIncome__c);
            }else{
                orswrap.Household_Income_Band = attendee.sumoapp__ContactRelation__r.AreaMedianIncome__c;
            }
            orswrap.Primary_Language_Spoken = attendee.sumoapp__ContactRelation__r.PreferredLanguage__c;
            orswrap.House_Number_and_Street_Name = attendee.sumoapp__ContactRelation__r.MailingStreet;
            orswrap.Apartment_or_Unit_Number = attendee.sumoapp__ContactRelation__r.MailingAddressLine2__c;
            orswrap.City = attendee.sumoapp__ContactRelation__r.MailingCity;
            orswrap.State = attendee.sumoapp__ContactRelation__r.MailingStateCode;
            orswrap.Zip_Code = attendee.sumoapp__ContactRelation__r.MailingPostalCode;
            orswrap.Rural_Area_Status = attendee.sumoapp__ContactRelation__r.RuralAreaStatus__c;
            if(labelValueMap.containsKey(attendee.Outcome__c)){
                orswrap.Group_Education_Service_Completed = labelValueMap.get(attendee.Outcome__c);
            }else{
                orswrap.Group_Education_Service_Completed = attendee.Outcome__c;
            }
            orswrap.Series_End_date =  attendee.sumoapp__SumoEvent__r.sumoapp__EndDatetime__c.format('MM/dd/yyyy',currentUserTimeZone);
            orsWrapperList.add(orswrap);
        }
        
        
        return orsWrapperList;
        
    }
    
    public class OrsReportWrapper{
        @AuraEnabled
        public String Client_ID;
        @AuraEnabled
        public Decimal Age;
        @AuraEnabled
        public String Gender;
        @AuraEnabled
        public String Race;
        @AuraEnabled
        public String Ethnicity;
        @AuraEnabled
        public String Disability;
        @AuraEnabled
        public String Household_Type;
        @AuraEnabled
        public Decimal Household_Size;
        @AuraEnabled
        public Decimal Monthly_Household_Income;
        @AuraEnabled
        public String Household_Income_Band;
        @AuraEnabled
        public String Primary_Language_Spoken;
        @AuraEnabled
        public String House_Number_and_Street_Name;
        @AuraEnabled
        public String Apartment_or_Unit_Number;
        @AuraEnabled
        public String City;
        @AuraEnabled
        public String State;
        @AuraEnabled
        public String Zip_Code;
        @AuraEnabled
        public String Rural_Area_Status;
        @AuraEnabled
        public String Group_Education_Service_Completed;
        @AuraEnabled
        public String Series_End_date;
    }
    
    
}