public with sharing class EducationalIntakeController {
    
    
    
    public class EducationalIntakeWrapper {
        @AuraEnabled
        public Contact contact{get;set;}
        
        @AuraEnabled
        public List<Contact> contacts{get;set;}
        
        @AuraEnabled
        public Map<String, List<String>> zipcodeData{get;set;}
    }
    
    /**
     * @description : stores the respective records for education form
    */

    @AuraENabled
    public static Contact storeEducationIntake(EducationalIntakeWrapper requestWrapper) {
        Savepoint sp = Database.setSavepoint();
        try{
            Contact contact = requestWrapper.contact;
            RecordType prospectRecordType = [SELECT Id, Name, DeveloperName FROM RecordType where SobjectType='Contact' AND NAme='Prospect' WITH SECURITY_ENFORCED];
            if(contact!=null && Schema.sObjectType.Contact.isCreateable()) {
                //contact.RecordTypeId = prospectRecordType.Id;
                Id prospectRTId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Prospect').getRecordTypeId();
                Id primaryClientRTId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('PrimaryClient').getRecordTypeId();
                Contact con;
                if(contact.Id != null ){
                    con = [SELECT Id, RecordTypeId FROM Contact WHERE Id = :contact.Id WITH SECURITY_ENFORCED];
                    if(con.RecordTypeId != primaryClientRTId){
                        contact.RecordTypeId = prospectRTId;
                    }
                }else{
                    contact.RecordTypeId = prospectRTId;
                }
                Database.UpsertResult result = Database.upsert(contact,true,AccessLevel.USER_MODE);
                if(!result.isSuccess()) {
                    System.debug('Errors : '+ result.getErrors());
                }
                
                System.debug('Contact Inserted : '+contact);
            }
            
            Id accountID = [Select id,AccountID from Contact where id=:contact.Id WITH SECURITY_ENFORCED]?.AccountID;
            
            List<Contact> coapplicants = requestWrapper.contacts;
            if(coapplicants!=null && !coapplicants.isEmpty() && Schema.sObjectType.Contact.isCreateable()) {
                RecordType recType = [SELECT Id, Name, DeveloperName FROM RecordType where SobjectType='Contact' AND NAme='Co-Applicant' WITH SECURITY_ENFORCED];
                for(Contact con : coapplicants) {
                    con.AccountId=accountId;
                    con.RecordTypeId=recType.Id;
                    con.isActive__c = true;
                    if(String.isNotEmpty(con.MailingAddressLine2__c)){
                        con.MailingStreet = con.MailingStreet + '\n' + con.MailingAddressLine2__c;
                    }
                }
                for(Database.UpsertResult result: Database.upsert(coapplicants,false, AccessLevel.USER_MODE)) {
                    if(!result.isSuccess()) {
                        System.debug('Errors : '+result.getErrors());
                        System.debug('Error Occured for Id : '+result.getId());
                        for(Database.Error err : result.getErrors()) {
                            System.debug('The following error has occurred.');                    
                            System.debug(err.getStatusCode() + ': ' + err.getMessage());
                            System.debug('Co Applicant fields that affected this error: ' + err.getFields());
                        }
                        throw new AuraHandledException('Error Occurred while Updating co applicants');
                        
                    }
                }
                System.debug('Co Applicants Inserted : '+coapplicants);
                
            }
            return contact;
        }catch(Exception e) {
            System.debug('Exception Occurred : at line '+e.getLineNumber());
            System.debug('Exception Message : '+ e.getMessage());
            System.debug('Stack Traced : '+ e.getStackTraceString()) ;
            LoggerClass.log(e,'educationFormSubmit');
            Database.rollback(sp);
            
            throw new AuraHandledException(e.getMessage());
        }
        
        //return null;
        
    }
    
    
    /**
     * @description : retrieves the respective records for education form
    */
    @AuraEnabled
    public static EducationalIntakeWrapper getIntakeDetails(Id contactId) {
        EducationalIntakeWrapper response = new EducationalIntakeWrapper();
        Id accountID = [Select id,AccountID from Contact where id=:contactId WITH SECURITY_ENFORCED]?.AccountID;
        List<Contact> contacts = [Select 
                                  id,FirstName,MiddleName,Suffix,Besttimetocontact__c,LastName,SSN__c,Email,Phone,PreferredLanguage__c,Birthdate,MailingStreet,HouseholdType__c,MailingAddressLine2__c,MailingCity,MailingStateCode,MailingPostalCode,Race__c,Ethnicity__c,Gender__c,Education__c,MaritalStatus__c, EnglishProficiency__c,ActiveMilitary__c,Veteran__c,X1stTimeHomeBuyer__c,RecordType.DeveloperName,RelationshipToPrimaryApplicant__c,
                                  FarmWorker__c,ColoniasResidence__c,DisabledStatus__c,TotalMonthlyIncome__c,NumberOfDependents__c,ClientHUDAssistance__c,Occupation__c,OccupationStartDate__c,MonthlyCreditorsDebt__c,CreditScore__c,EmploymentStatus__c,CurrentResidence__c,HouseholdSize__c,RuralAreaStatus__c,County__c,Town__c,MarketingCommunicationsOptOut__c FROM Contact where AccountId=:accountID];
        List<Contact> coApplicants = new List<Contact>();
        for(Contact con: contacts) {
            if(con.RecordType.DeveloperName=='PrimaryClient' || con.RecordType.DeveloperName=='Lead' || con.RecordType.DeveloperName=='Prospect'){
                response.contact = con;
                response.zipcodeData=HUDAMICalculationService.getCountyNamesBasedOnZip(con.MailingPostalCode);
            } else {
                 coApplicants.add(con);
            }
        }
        response.contacts = coApplicants;
        return response;
    }
    
    
    
}