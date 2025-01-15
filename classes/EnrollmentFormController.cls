/*
* @author         Soyab
* @description    Controller class containing methods for enrollment Form Component
* @date           2024-05-21
* @group          Enrollment
*/
public without sharing class EnrollmentFormController {    /*
* @description    This method is used to get the picklist values for corresponding object having api name of each
*/
    @AuraEnabled(cacheable=true)
    public static Map<String, List<PickListWrapper>> getPicklistValues(List<String> fieldNames, String objectApiName) {
        Map<String, List<PickListWrapper>> result = new Map<String, List<PickListWrapper>>();
        try{
            if(!fieldNames.isEmpty()) {
                for(String fieldName : fieldNames) {
                    List<PickListWrapper> wrappers = new List<PickListWrapper>();
                    Schema.SObjectType objSobjectType = Schema.getGlobalDescribe().get(objectApiName) ;
                    Schema.DescribeSObjectResult objDescribeSobject = objSobjectType.getDescribe() ;
                    Map<String,Schema.SObjectField> fields = objDescribeSobject.fields.getMap() ;
                    Schema.DescribeFieldResult fieldResult = fields.get(fieldName).getDescribe();
                    List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
                    for( Schema.PicklistEntry pickListVal : ple){
                        PickListWrapper wrap = new PickListWrapper();
                        wrap.value=pickListVal.getValue();
                        if(fieldName == 'MailingStateCode'){
                            wrap.label=pickListVal.getValue();
                        }else{
                            wrap.label=pickListVal.getLabel();
                        }
                        wrappers.add(wrap);
                    }
                    result.put(fieldName, wrappers);
                }
            }
        }
        catch(Exception ex){
            system.debug('Exception is '+ex.getMessage()+' at line '+ex.getLineNumber());
        }
        return result;
    }
    
    /*
* @description    Wrapper to hold values for Enum
*/
    public class PickListWrapper{
        @AuraEnabled
        public String label{get;set;}
        
        @AuraEnabled
        public String value{get;set;}
        
        
    }
    
    /**
* This method returns a list of Contact records with the RecordType name 'Co-Applicant'.
* 
* @return List<Contact> - A list of Contact records with the RecordType 'Co-Applicant'.
*/
    @AuraEnabled(cacheable=true)
    public static List<Contact> getCoApplicantContacts() {
        List<User> currUser = [SELECT Id, Contact.AccountId FROM User WHERE Id = :UserInfo.getUserId()];
        if(currUser.isEmpty() || currUser[0]?.Contact?.AccountId == null) {
            return new List<Contact>();
        }
        return [SELECT Id, Name, FirstName, MiddleName, LastName, Email, Phone, Suffix, MailingStreet, MailingAddressLine2__c,MailingCity, 
                MailingStateCode, MailingPostalCode, Ethnicity__c, Race__c, Gender__c, EnglishProficiency__c, HouseholdSize__c, 
                HouseholdMonthlyIncome1__c, X1stTimeHomeBuyer__c, RuralAreaStatus__c, Besttimetocontact__c, PreferredLanguage__c,
                RelationshipToPrimaryApplicant__c, Birthdate, MaritalStatus__c, Education__c, DisabledStatus__c,
                NumberOfDependents__c, EmploymentStatus__c, CreditScore__c, ActiveMilitary__c, Veteran__c, TotalMonthlyIncome__c FROM Contact 
                WHERE RecordType.Name = 'Co-Applicant' AND AccountId =:currUser[0].Contact.AccountId AND isActive__c = True];
    }
    
    @AuraEnabled(cacheable=true)
    public static Contact getPrimaryContactInformation() {
        List<User> users = [SELECT ContactId FROM User WHERE Id =:UserInfo.getUserId()  AND ContactId != NULL LIMIT 1]; // UserInfo.getUserId()    
        
        if(users.isEmpty()){
            return new Contact();
        }
        return [SELECT Id, Name, FirstName, LastName, Email, Phone, MailingStreet, MailingAddressLine2__c,MailingCity, 
                MailingStateCode, MailingPostalCode, MailingCountry, MailingCountryCode, Ethnicity__c, Race__c, EnglishProficiency__c, HouseholdSize__c, 
                RuralAreaStatus__c, Birthdate, Gender__c, X1stTimeHomeBuyer__c, DisabledStatus__c, HouseholdType__c, ActiveMilitary__c,
                NumberOfDependents__c, EmploymentStatus__c, CreditScore__c, TotalMonthlyIncome__c, Besttimetocontact__c, MaritalStatus__c, Education__c, Veteran__c, ChoseNottoProvideIncome__c FROM Contact WHERE Id=:users[0].ContactId LIMIT 1];
    }
    
    @AuraEnabled(cacheable=true)
    public static Map<String, Object> getCourseName(String recordId) {
        if(String.isBlank(recordId)){
            return new Map<String, String>();
        }
        Map<String, Object> desireServiceMap= new Map<String, Object>();
        sumoapp__AdditionalInfo__c sumoappAdditionalInfo = [SELECT Id, sumoapp__EventName__c, sumoapp__StartDatetime__c, sumoapp__Location__r.Name, ShortDescription__c, 
                                                            ShortDescriptionSpanish__c FROM sumoapp__AdditionalInfo__c WHERE ID =:recordId LIMIT 1];
        desireServiceMap.put('record', sumoappAdditionalInfo);
        desireServiceMap.put('mapping', getMultiLanguageFieldMappings());
        return desireServiceMap;
    }
    
    /*Returns mappings of language-specific field names (English and Spanish) for localization.*/
    private static Map<String, Map<String, String>> getMultiLanguageFieldMappings() {
        String NWC2NameSpace = Utility.getNwc2NameSpace();
        return new Map<String, Map<String, String>>{
            'English' => new Map<String, String>{'Name' => NWC2NameSpace+'sumoapp__EventName__c', 'Description' => NWC2NameSpace+'ShortDescription__c', 'StartDate' => NWC2NameSpace+'sumoapp__StartDatetime__c', 'Location' => 'Name'},
                'Spanish' => new Map<String, String>{'Name' => NWC2NameSpace+'sumoapp__EventName__c', 'Description' => NWC2NameSpace+'ShortDescriptionSpanish__c', 'StartDate' => NWC2NameSpace+'sumoapp__StartDatetime__c', 'Location' => 'Name'}
        };
            }
    
    @AuraEnabled
    public static List<object> updateRecords(Contact primaryContact, List<Contact> applicants, String courseId) {
        System.debug('in update records====>'+applicants);
        try{
            Id accountId = null;
            Id recordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CoApplicant').getRecordTypeId();
            if(primaryContact != null){
                primaryContact.MailingCountryCode = Constants.DEFAULT_COUNTRY;
                update primaryContact;
                accountId = [
                    SELECT AccountId 
                    FROM Contact 
                    WHERE Id = :primaryContact.Id 
                    LIMIT 1
                ].AccountId;
            }
            for(Contact con : applicants){
                con.RecordTypeId = recordTypeId;
                con.IsActive__c = true;
                con.AccountId = accountId;
                con.MailingCountryCode = Constants.DEFAULT_COUNTRY;
            }
            if(applicants != null){ 
                upsert applicants;
                applicants.add(primaryContact);
            }else{
                applicants = new List<Contact>{primaryContact};
                    }
            List<sumoapp__Attendee__c> attendees = createSumoAttendees(getCourses(courseId), applicants, primaryContact);
            return new List<object>{primaryContact, applicants, attendees};
                }catch (Exception e){ throw new LightningException(e.getMessage());    }
    }
    
    
    static sumoapp__AdditionalInfo__c getCourses(String courseId){
        System.debug('in getCourse');
        if(courseId == '' || courseId == null){
            return new sumoapp__AdditionalInfo__c();
        }
        sumoapp__AdditionalInfo__c course = [SELECT Id, sumoapp__EventName__c, 
                                             IsParent__c, sumoapp__Parent__c, 
                                             (select id from sumoapp__ChildEvents__r)
                                             FROM sumoapp__AdditionalInfo__c
                                             WHERE Id =:courseId LIMIT 1];
        return course;
    }
    
    static List<sumoapp__Attendee__c> createSumoAttendees(sumoapp__AdditionalInfo__c course, List<Contact> applicants, Contact primaryContact){
        List<sumoapp__Attendee__c> attendees = new List<sumoapp__Attendee__c>();
        if(applicants == null || applicants.isEmpty()){
            return new List<sumoapp__Attendee__c>();
        }
        for(Contact eachContact : applicants){
            for(sumoapp__AdditionalInfo__c innerCourse : course.sumoapp__ChildEvents__r){
                attendees.add(new sumoapp__Attendee__c(sumoapp__NumberOfSeats__c = 1, 
                                                       sumoapp__ContactRelation__c = eachContact.Id,
                                                       sumoapp__SumoEvent__c = innerCourse.Id,
                                                       sumoapp__Status__c = 'BOOKED',
                                                       ChoseNottoProvideIncome__c = primaryContact.ChoseNottoProvideIncome__c));
            }
            attendees.add(new sumoapp__Attendee__c(sumoapp__NumberOfSeats__c = 1, 
                                                   sumoapp__ContactRelation__c = eachContact.Id,
                                                   sumoapp__SumoEvent__c = course.Id,
                                                   sumoapp__Status__c = 'BOOKED',
                                                   ChoseNottoProvideIncome__c = primaryContact.ChoseNottoProvideIncome__c));
        }
        insert attendees; 
        return attendees;
    }
    
    @AuraEnabled(cacheable=true)
    public static String getRecordStatus(String recordId){
        String status;
        Id objectId = Id.valueOf(recordId);
        String objectName = objectId?.getSObjectType()?.getDescribe().getName();
        string NWC2NameSpace = Utility.getNwc2NameSpace();
        if(objectName==NWC2NameSpace+'Intake__c') {
            status = [SELECT Id, Status__c FROM Intake__c WHERE Id =: recordId LIMIT 1].Status__c;
            
        } else if(objectName==NWC2NameSpace+'ClientCase__c') {
            status = [Select Id, ClientCaseStatus__c from ClientCase__c where id =:recordId LIMIT 1].ClientCaseStatus__c;
        }
        return status;
    }
        
    @AuraEnabled(cacheable=true)
    public static List<Contact> fetchAllContactCoApplicants(String recordId) {
        System.debug('fetchAllContactCoApplicants===>'+recordId);
        Set<Id> existingIds = new Set<Id>();
        for(CoApplicant__c coApp : fetchAllCoApplicants(recordId)){
            existingIds.add(coApp.Contact__c);
        }
        if(String.isEmpty(recordId)){
            return new List<Contact>();
        }
        Id householdId;
        Id objectId = Id.valueOf(recordId);
        String objectName = objectId?.getSObjectType()?.getDescribe().getName();
        string NWC2NameSpace = Utility.getNwc2NameSpace();
        if(objectName==NWC2NameSpace+'Intake__c') {
            
            Intake__c intakeRec = [SELECT Household__c FROM Intake__c WHERE Id =: recordId LIMIT 1];
            houseHoldId = intakeRec.Household__c;
        }
        
        else if(objectName==NWC2NameSpace+'ClientCase__c') {
            ClientCase__c cc=[Select Household__c from ClientCase__c where id =:recordId LIMIT 1];
            houseHoldId = cc.Household__c;
        }
        
        
        List<Contact> conList = [SELECT Id,TotalMonthlyIncome__c,Name, FirstName, MiddleName, LastName, Email, Phone, Suffix,
                                 MailingStreet, MailingAddressLine2__c,MailingCity, 
                                 MailingStateCode, MailingPostalCode, Ethnicity__c, Race__c, Gender__c, EnglishProficiency__c, HouseholdSize__c, 
                                 RuralAreaStatus__c FROM Contact WHERE AccountId =: houseHoldId AND RecordType.Name = 'Co-Applicant'
                                 AND Id NOT In:existingIds];
        System.debug('co apps===>'+conList);
        return conList;
    }
    
    @AuraEnabled(cacheable=true)
    public static List<CoApplicant__c> fetchAllCoApplicants(String recordId) {
        System.debug('fetchAllCoApplicants===>'+recordId);
        if(String.isEmpty(recordId)){
            return new List<CoApplicant__c>();
        }
        
        
        List<CoApplicant__c> conAppList = [SELECT Id,Name, Contact__c, Contact__r.Name, Contact__r.Email, Contact__r.TotalMonthlyIncome__c, Contact__r.Phone, Contact__r.RecordType.Name FROM CoApplicant__c WHERE IntakeRequest__c =: recordId];
        Id objectId = Id.valueOf(recordId);
        String objectName = objectId?.getSObjectType()?.getDescribe().getName();
        string NWC2NameSpace = Utility.getNwc2NameSpace();
        if(objectName==NWC2NameSpace+'Intake__c') {
            
            return [SELECT Id,Name, Contact__c, Contact__r.Name, Contact__r.Email, Contact__r.Phone, Contact__r.TotalMonthlyIncome__c, Contact__r.RecordType.Name FROM CoApplicant__c WHERE IntakeRequest__c =: recordId];
        }
        
        else if(objectName==NWC2NameSpace+'ClientCase__c') {
            return [SELECT Id,Name, Contact__c, Contact__r.Name, Contact__r.Email, Contact__r.Phone, Contact__r.TotalMonthlyIncome__c, Contact__r.RecordType.Name FROM CoApplicant__c WHERE ClientCase__c  =: recordId];
        }
        System.debug('conAppList===>'+conAppList);
        return new List<CoApplicant__c>();
    }
    
    @AuraEnabled
    public static CoApplicant__c insertCoApplicant(String intakeId, String contactId) {
        Id objectId = Id.valueOf(intakeId);
        String objectName = objectId?.getSObjectType()?.getDescribe().getName();
        System.debug('insertCoApplicant called' + intakeId);
        System.debug('contactId' + contactId);
        CoApplicant__c coApplicant = new CoApplicant__c();
        string NWC2NameSpace = Utility.getNwc2NameSpace();
        if(objectName==NWC2NameSpace+'Intake__c'){
            coApplicant.IntakeRequest__c = intakeId;
        } else {
            coApplicant.ClientCase__c  = intakeId;
        }
        
        coApplicant.Contact__c = contactId;
        insert coApplicant;
        System.debug('coApplicant'+ coApplicant);
        return coApplicant;
    }
    
    @AuraEnabled
    public static CoApplicant__c deleteCoApplicant(String recordId) {
        if(String.isEmpty(recordId)){
            return new CoApplicant__c();
        }
        CoApplicant__c deleteCoApp = new CoApplicant__c(Id = recordId);
        delete deleteCoApp;
        return deleteCoApp;
    }
    
    public class LightningException extends Exception {}
    
    /**
* @description       : Method to check that current logged in user is IntakeStaff or not.
**/
    @AuraEnabled
    public static Boolean isIntakeStaffUser(){
        return FeatureManagement.checkPermission('IntakeStaff');
    } 
}