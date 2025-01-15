/*
* @author         Avilash Basu
* @description    Controller class containing methods for Intake Form Component
* @date           2024-01-24
* @group          Intake Form
*/
public with sharing class IntakeFormController {
    
    /*
* @description    This method is used to get the picklist values for corresponding object having api name of each
*/
    @AuraEnabled(cacheable=true)
    public static Map<String, List<PickListWrapper>> getPicklistValues(List<String> fieldNames, String objectApiName) {
        //String objectApiName='ClientCase__c';
        Map<String, List<PickListWrapper>> result = new Map<String, List<PickListWrapper>>();
        system.debug('fieldNames '+fieldNames);
        try{
            if(!fieldNames.isEmpty()) {
                for(String fieldName : fieldNames) {
                    system.debug('fieldName '+fieldName);
                    List<PickListWrapper> wrappers = new List<PickListWrapper>();
                    Schema.SObjectType objSobjectType = Schema.getGlobalDescribe().get(objectApiName) ;
                    Schema.DescribeSObjectResult objDescribeSobject = objSobjectType.getDescribe() ;
                    Map<String,Schema.SObjectField> fields = objDescribeSobject.fields.getMap() ;
                    System.debug('fields '+fields);
                    Schema.DescribeFieldResult fieldResult = fields.get(fieldName).getDescribe();
                    system.debug('fieldresult '+fieldResult);
                    List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
                    system.debug('values '+ple);
                    for( Schema.PicklistEntry pickListVal : ple){
                        PickListWrapper wrap = new PickListWrapper();
                        wrap.value=pickListVal.getValue();
                        
                        wrap.label=pickListVal.getLabel();
                        
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
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    /**********Task Reminders*******/
    
    
    
    
    @AuraEnabled
    public static List<Task> getTaskList(Id caseRecId){
        Date todaysDate = Date.today();
        Date tomDate = Date.today().addDays(1);
        List<Task> Alerts = new List<Task>();
        If(caseRecId!=NULL){
            //This query is for RecordPage
            Alerts = [Select id, Subject, Description from Task where WhatId=:caseRecId and Status=:'Open'];
        }
        else{
            //This query is for Homepage
            Alerts = [Select id, Subject, Description from Task where Status=:'Open'];
            //((SnoozeUntilDate != null and SnoozeUntilDate >: todaysDate and SnoozeUntilDate <: tomDate) OR (SnoozeUntilDate = null and EffectiveDate <: tomDate))
        }
        System.debug('### Alerts : '+Alerts.size());
        return Alerts;
    }
    
    
    /**********Task Reminders*******/
    
    
    
    
    
    
    
    
    
    
    
    /*
* @description    This method is used to get the case types.
*/
    @AuraEnabled(cacheable=true)
    public static List<CaseType__c> getCaseTypes() {
        List<CaseType__c> caseTypes = [Select id, Name,is_Reverse_Mortage__c from CaseType__c where IsClientLookup__c =true];
        return caseTypes;
    }
    
    /*
* @description     To store the values that are submitted over intake form
* 
*/
    @AuraEnabled
    public static IntakeResponseWrapper storeIntakeForm(IntakeSubmissionWrapper requestWrapper) {
        
        Savepoint sp = Database.setSavepoint();
        
        System.debug('Ids to Delete : '+requestWrapper.idsToDelete);
        
        IntakeResponseWrapper response = new IntakeResponseWrapper();
        try{
            
            Contact contact = requestWrapper.contact;
            //System.debug('requestWrapper.clientCase.clientCase: ' + requestWrapper.clientCase.clientCase);
            System.debug('County Registered : '+ requestWrapper.contact?.County__c);
            List<Intake__c> cases = new List<Intake__c>();
            List<Intake__c> clientCasesToCreate = new List<Intake__c>();
            Id recordTypeId = [SELECT Id, Name, DeveloperName FROM RecordType where SobjectType='Contact' AND DeveloperName='Prospect' LIMIT 1]?.ID;
            if(contact!=null && Schema.sObjectType.Contact.isCreateable() && contact.Id==null) {
                contact.recordTypeId = recordTypeId;
                insert contact;
                
            } else if(contact!=null && Schema.sObjectType.Contact.isUpdateable()) {
                if(!checkIfRecordTypePrimary(contact)) {
                    
                    contact.recordTypeId = recordTypeId;
                }
                update contact;
            } 
            Id accountID = [Select id,AccountID from Contact where id=:contact.Id WITH SECURITY_ENFORCED LIMIT 1]?.AccountID;
            
            //Deleting CoApplicants
            Set<Id> applicantsToIgnore = new Set<Id>();
            if(requestWrapper.idsToDelete!=null && !requestWrapper.idsToDelete.isEmpty()) {
                applicantsToIgnore = new Set<Id>(requestWrapper.idsToDelete);
            }
            
            
            
            
            //Inserting coapplicants
            List<Contact> coapplicants = requestWrapper.contacts;
            //System.debug('Co Applicants : '+ coapplicants);
            //System.debug('Co Applicants Middle Name : '+ coapplicants[0].MiddleName);
            if(coapplicants!=null && !coapplicants.isEmpty() && Schema.sObjectType.Contact.isCreateable()) {
                RecordType recType = [SELECT Id, Name, DeveloperName FROM RecordType where SobjectType='Contact' AND NAme='Co-Applicant' WITH SECURITY_ENFORCED];
                for(Contact con : coapplicants) {
                    con.AccountId=accountId;
                    
                    if(con.Id==null) {
                        con.RecordTypeId=recType.Id;   
                        con.isActive__c=true; 
                    }
                    
                    if(String.isNotEmpty(con.MailingAddressLine2__c)){
                        con.MailingStreet = con.MailingStreet + '\n' + con.MailingAddressLine2__c;
                    }
                }
                System.debug('Pre Update : '+coapplicants[0]?.Id);
                for(Database.UpsertResult result: Database.upsert(coapplicants,false, AccessLevel.USER_MODE)) {
                    if(!result.isSuccess()) {
                        System.debug('Errors : '+result.getErrors());
                        System.debug('Error Occured for Id : '+result.getId());
                        for(Database.Error err : result.getErrors()) {
                            System.debug('The following error has occurred.');                    
                            System.debug(err.getStatusCode() + ': ' + err.getMessage());
                            System.debug('Co Applicant fields that affected this error: ' + err.getFields());
                        }
                    }
                }
                System.debug('Co Applicants Middle Name : '+ coapplicants[0].MiddleName);
                System.debug('Post Update : '+coapplicants);
            }
            System.debug('requestWrapper.clientCase.recordType :::: '+requestWrapper.clientCase);
            System.debug('Schema.sObjectType.Intake__c.isCreateable() :::::'+Schema.sObjectType.Intake__c.isCreateable());
            if(requestWrapper.clientCase.recordType!=null && requestWrapper.clientCase!=null && requestWrapper.clientCase.clientCase!=null && Schema.sObjectType.Intake__c.isCreateable()) {
                Intake__c clientCase = requestWrapper.clientCase.clientCase;
                clientCase.PrimaryClient__c = contact.Id;
                clientCase.Household__c = accountID;
                clientCase.Status__c = 'Open Intake';
                clientCase.CaseType__c=requestWrapper?.clientCase?.recordType;
                Id newClientCase = Database.insert(clientCase)?.getId();
                
                //IntakeRequestProcessor.updateIntakeRequests(contact.Id, requestWrapper.clientCase.recordTypes, clientCase);
                
                cases = [Select id, IntakeRequestName__c from Intake__c where id=:newClientCase WITH SECURITY_ENFORCED];
            }
            System.debug('Account Id : '+accountId);
            List<Contact> coApplicantLst = [Select Id from Contact where RecordType.DeveloperName='CoApplicant' AND AccountID=:accountId AND AccountID!=null AND Id not in :applicantsToIgnore];
            System.Debug('Co ApplicantLst' + coApplicantLst);
            System.Debug('Co cases' + cases);
            if(coApplicants!=null && cases!=null && !coApplicants.IsEmpty() && !cases.isEmpty()) {
                List<CoApplicant__c> coapps = new List<CoApplicant__c>();
                for(Intake__c ic : cases) {
                    coapps.addAll(createCoApplicants(ic, coApplicantLst));
                    System.debug('Co Applicant Records : '+coapps);
                }
                insert coapps;
            }
            
            
            response.contact = contact;
            response.clientCases = cases;
        }catch(Exception ex) {
            String relatedId = 'intakeFormSubmit : '+DateTime.now().getTime();
            System.debug('Exception Occurred : at line '+ex.getLineNumber());
            LoggerClass.log(ex,relatedId);
            throw new AuraHandledException(ex.getMessage()+'\nLogger Related Id : '+relatedId);
        }
        
        return response; 
    }
    
    public static List<CoApplicant__c> createCoApplicants(Intake__c intakeCase, List<Contact> contactsToAdd) {
        List< CoApplicant__c > applicants = new List< CoApplicant__c >();
        for(Contact con : contactsToAdd){
            CoApplicant__c coApp = new CoApplicant__c();
            coApp.Contact__c=con.Id;
            coApp.IntakeRequest__c = intakeCase.Id;
            applicants.add(coApp);
            
        }
        return applicants;
    }
    
    /*
* @description     To retrieve the values that are submitted over intake form
* 
*/
    @AuraEnabled
    public static IntakeSubmissionWrapper getIntakeDetails(Id contactId) {
        IntakeSubmissionWrapper response = new IntakeSubmissionWrapper();
        
        Id AccountId = [Select AccountId from Contact where id=:contactId]?.AccountId;
        List<Contact> contacts = [Select 
                                  id,FirstName,MiddleName,Suffix,Besttimetocontact__c,LastName,SSN__c,Email,Phone,PreferredLanguage__c,Birthdate,MailingStreet,HouseholdType__c,MailingAddressLine2__c,MailingCity,MailingStateCode,MailingPostalCode,Race__c,Ethnicity__c,Gender__c,Education__c,MaritalStatus__c, EnglishProficiency__c,ActiveMilitary__c,Veteran__c,X1stTimeHomeBuyer__c,RecordType.DeveloperName,RelationshipToPrimaryApplicant__c,
                                  FarmWorker__c,ColoniasResidence__c,DisabledStatus__c,TotalMonthlyIncome__c,NumberOfDependents__c,ClientHUDAssistance__c,Occupation__c,OccupationStartDate__c,MonthlyCreditorsDebt__c,CreditScore__c,EmploymentStatus__c,CurrentResidence__c,HouseholdSize__c,RuralAreaStatus__c,County__c,Town__c,MarketingCommunicationsOptOut__c
                                  from Contact where AccountId=:accountId];
        
        List<Contact> coApplicants = new List<Contact>();
        Contact primaryApplicant = new Contact();
        
        for(Contact con : contacts) {
            if(con.RecordType.DeveloperName=='PrimaryClient' || con.RecordType.DeveloperName=='Lead' || con.RecordType.DeveloperName=='Prospect'){
                response.contact = con;
                /*if(con.Intake_Requests__r!=null && !con.Intake_Requests__r.isEmpty()) {
System.debug('Client Cases : '+con.Client_Cases__r);
ClientCaseWrapper wrappper = new ClientCaseWrapper();
wrappper.clientCase = con.Intake_Requests__r.get(0);
List<String> recordTypes = new List<String>();
for(Intake__c cc : con.Intake_Requests__r){
recordTypes.add(cc.CaseType__r.Name);
}
wrappper.recordTypes = recordTypes;
response.clientCase = wrappper;
}*/
                
                response.zipcodeData = HUDAMICalculationService.getCountyNamesBasedOnZip(con.MailingPostalCode);
            } else {
                coApplicants.add(con);
            }
            
        }
        
        response.contacts = coApplicants;
        
        
        
        return response;
    }
    
    /*
* @description     To check if record is primary
* 
*/
    @TestVisible
    private static boolean checkIfRecordTypePrimary(Contact con) {
        boolean isPrimary = false;
        if(con.Id!=null) {
            String developerName = [Select RecordType.DeveloperName from Contact where id =:con.Id]?.RecordType.DeveloperName;
            isPrimary = developerName!=null && (developerName=='PrimaryClient');
        }
        return isPrimary;
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
    
    public class IntakeSubmissionWrapper {
        @AuraEnabled
        public Contact contact{get;set;}
        
        @AuraEnabled
        public List<Contact> contacts{get;set;}
        
        @AuraEnabled
        public ClientCaseWrapper clientCase{get;set;}
        
        @AuraEnabled
        public List<Id> idsToDelete{get;set;}
        
        @AuraEnabled
        public Map<String, List<String>> zipcodeData{get;set;}
    }
    public class ClientCaseWrapper {
        @AuraEnabled
        public Intake__c clientCase{get;set;}
        
        @AuraEnabled
        public String recordType{get;set;}
    }
    
    public class IntakeResponseWrapper {
        @AuraEnabled
        public Contact contact{get;set;}
        
        @AuraEnabled
        public List<Intake__c> clientCases{get;set;}
    }
}