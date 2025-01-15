/**
 * @description       : 
 * @author            : Soyab
 * @group             : 
 * @last modified on  : 07-15-2024
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public without sharing class ServiceEnrollmentFormController {
    @AuraEnabled(cacheable=true)
    public static Map<String, Object> getService(String recordId) {
        if(String.isBlank(recordId)){
            return new Map<String, String>();
        }
        Map<String, Object> desireServiceMap= new Map<String, Object>();
        CaseType__c service = [SELECT Id, Name, NameSpanish__c, is_Reverse_Mortage__c FROM CaseType__c  WHERE ID =:recordId LIMIT 1];
        desireServiceMap.put('record', service);
        desireServiceMap.put('mapping', getMultiLanguageFieldMappings());
        return desireServiceMap;
    }
    
    private static Map<String, Map<String, String>> getMultiLanguageFieldMappings() {
        return new Map<String, Map<String, String>>{
            'English' => new Map<String, String>{'Name' => 'Name'},
            'Spanish' => new Map<String, String>{'Name' => 'NameSpanish__c'}
        };
    }
    

    /*Enrolls a primary contact and applicants into a specified service. Updates the primary contact's, 
    upserts applicants, creates an intake record, and links co-applicants. */
    @AuraEnabled
    public static String enrolledToService(Contact primaryContact, List<Contact> applicants, String serviceId) {
        //Contact primeCon = [SELECT Id, AccountId FROM Contact WHERE Id =: primaryContact.Id];
        try{
            System.debug('primaryContact=>'+ primaryContact);
            System.debug('applicants=>'+ applicants);
            Id accountId = null;
            Id recordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CoApplicant').getRecordTypeId();
            Intake__c intRecord = new Intake__c();
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
            }
            
            if(serviceId != null){
                intRecord.CaseType__c = serviceId;  
                intRecord.PrimaryClient__c = primaryContact.Id;  
                intRecord.Household__c = accountId;
                intRecord.Address__Street__s = primaryContact.MailingStreet;
                intRecord.AddressLine2__c = primaryContact.MailingAddressLine2__c;
                intRecord.Address__City__s  = primaryContact.MailingCity;
                intRecord.Address__StateCode__s  = primaryContact.MailingState;
                intRecord.Address__PostalCode__s = primaryContact.MailingPostalCode;
                intRecord.Race__c = primaryContact.Race__c;
                intRecord.Ethnicity__c = primaryContact.Ethnicity__c;
                intRecord.Gender__c = primaryContact.Gender__c;
                intRecord.Education__c = primaryContact.Education__c;
                intRecord.MaritalStatus__c = primaryContact.MaritalStatus__c;
                intRecord.EnglishProficiency__c = primaryContact.EnglishProficiency__c;
                intRecord.ActiveMilitary__c = primaryContact.ActiveMilitary__c;
                intRecord.DisabledStatus__c = primaryContact.DisabledStatus__c;
                intRecord.X1stTimeHomeBuyer__c = primaryContact.X1stTimeHomeBuyer__c;
                intRecord.RuralAreaStatus__c = primaryContact.RuralAreaStatus__c;
                intRecord.HouseholdType__c = primaryContact.HouseholdType__c;
                intRecord.HouseholdSize__c = primaryContact.HouseholdSize__c;
                intRecord.MonthlyIncome__c = primaryContact.TotalMonthlyIncome__c;
                intRecord.NumberOfDependents__c = primaryContact.NumberOfDependents__c;
                intRecord.CreditScore__c = primaryContact.CreditScore__c;
                intRecord.Employment_Status__c = primaryContact.EmploymentStatus__c;
                intRecord.PortalIntake__c = true;
                intRecord.ChoseNottoProvideIncome__c = primaryContact.ChoseNottoProvideIncome__c;
                insert intRecord;
                List<CoApplicant__c> coApplicants = new List<CoApplicant__c>();
                for(Contact con : applicants){
                    coApplicants.add(
                        new CoApplicant__c(
                            IntakeRequest__c = intRecord.Id,
                            Contact__c = con.Id//primaryContact.Id
                        )
                    );
                }
                if(!coApplicants.isEmpty()){
                    insert coApplicants;
                }
            }
            return intRecord.Id;
        }catch (Exception e){ throw new LightningException(e.getMessage() + e.getLineNumber());}
    }
    
    
    @AuraEnabled(cacheable=true)
        public static Map<String,Object> getEnrolledServiceDetails(String recordId){
        System.debug('getEnrolledServiceDetails recordId'+ recordId);
        Map<String,Object> enrolledDetails = new Map<String,Object>{'PrimaryContact' => null, 'CoApplicants' => null};
        Set<Id> coApplicantIds = new Set<Id>();
        List<Intake__c> intakes = [SELECT Id,CreatedDate, PrimaryClient__c from Intake__c WHERE Id = :recordId AND
                                   PrimaryClient__c != NULL LIMIT 1 ];
        if(intakes.isEmpty()){
            return enrolledDetails;
        }
        enrolledDetails.put('SubmittedDate', intakes[0].CreatedDate);
        for(CoApplicant__c applicant : [SELECT Id, Contact__c FROM CoApplicant__c WHERE IntakeRequest__c =:recordId ]){
            coApplicantIds.add(applicant.Contact__c);
        }
        
        enrolledDetails.put('PrimaryContact', EnrollmentFormController.getPrimaryContactInformation());
        enrolledDetails.put('CoApplicants', [SELECT Id, Name, FirstName, MiddleName, LastName, Email, Phone, Suffix, MailingStreet, MailingAddressLine2__c,MailingCity, 
                MailingStateCode, MailingPostalCode, Ethnicity__c, Race__c, Gender__c, EnglishProficiency__c, HouseholdSize__c, 
                HouseholdMonthlyIncome1__c, X1stTimeHomeBuyer__c, RuralAreaStatus__c, Besttimetocontact__c, PreferredLanguage__c,
                RelationshipToPrimaryApplicant__c, Birthdate, MaritalStatus__c, Education__c, DisabledStatus__c,
                NumberOfDependents__c, EmploymentStatus__c, CreditScore__c, ActiveMilitary__c, TotalMonthlyIncome__c, Veteran__c FROM Contact 
                WHERE Id IN:coApplicantIds]);
        return enrolledDetails;
    }
    
    public class LightningException extends Exception {}
}