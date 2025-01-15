public with sharing class EmergencyTriageController {
    
    /**
     * @description : stores the respective records for triage form
	*/
    @AuraEnabled
    public static ResponseWrapper storeLeadIntake(IntakeWrapper requestWrapper) {
        SavePoint sp = Database.setSavePoint();
        ResponseWrapper response = new ResponseWrapper();
        try{

        	Id contactId=null;
			id accountId = null;
        	System.debug('Request Received : ' + requestWrapper);
            if(requestWrapper.contact!=null && Schema.sObjectType.Contact.isCreateable()) {
                Contact contact = requestWrapper.contact;
                //RecordType prospectRecordType = [SELECT Id, Name, DeveloperName FROM RecordType where SobjectType='Contact' AND NAme='Prospect' WITH SECURITY_ENFORCED];
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
                response.contactId = Database.upsert(contact, true, AccessLevel.USER_MODE)?.getId();
                contactId = contact?.Id;
                
                System.debug('Contact Created : '+contact);
                accountID = [Select id,AccountID from Contact where id=:contact.Id WITH SECURITY_ENFORCED LIMIT 1]?.AccountID;
            }
            if(requestWrapper.intakeCaseType!=null && Schema.sObjectType.Intake__c.isCreateable()) {
                Id caseTypeId = [Select Id from CaseType__c where Name=:requestWrapper.intakeCaseType LIMIT 1]?.Id ;
                Id intakeId = [Select id from Intake__c where PrimaryClient__c=:contactId AND CaseType__r.Name=:requestWrapper.intakeCaseType]?.Id;
            	Intake__c intake = new Intake__c();
                intake.id = intakeId;
                intake.PrimaryClient__c = contactId;
                intake.CaseType__c=caseTypeId;
                intake.Status__c='Open Intake';
                intake.Household__c = accountID;
                response.intakeId = Database.upsert(intake, true, AccessLevel.USER_MODE)?.getId();
                
            }
        	return response;
        } catch(Exception e) {
            Database.rollback(sp);
            LoggerClass.log(e,'educationFormSubmit');
            throw new AuraHandledException(e.getMessage());
        }
        
    }
    
    /**
     * @description : retrieves the respective records for emergency form
	*/
    @AuraEnabled
    public static IntakeWrapper getIntakeDetails(Id contactId) {
        IntakeWrapper wrapper = new IntakeWrapper();
        wrapper.contact = [Select id, FirstName, MiddleName, LastName, Suffix, SSN__c, Email, Phone, Besttimetocontact__c, PreferredLanguage__c, Birthdate, MailingStreet, MailingAddressLine2__c, MailingPostalCode, MailingCity, MailingStateCode from contact where id=:contactId LIMIT 1];
        
        wrapper.intakeCaseType = [Select id, CaseType__r.Name,IntakeRequestName__c from Intake__c where CaseType__r.isEmergencyTriage__c=true AND PrimaryClient__c=:contactID LIMIT 1]?.CaseType__r?.Name;
        
        return wrapper;
        
    }

    @AuraEnabled
    public static String getIntakeName(Id intakeId) {
        return [Select id,IntakeRequestName__c from Intake__c where id =: intakeId]?.IntakeRequestName__c;
    }
    
    @AuraEnabled(cacheable=true)
    public static List<CaseType__c> getCaseTypes() {
        List<CaseType__c> caseTypes = [Select id, Name from CaseType__c where isEmergencyTriage__c=true AND IsClientLookup__c=true];
        return caseTypes;
    }
    
    
    public class IntakeWrapper{
        @AuraEnabled
        public Contact contact{get;set;}
        
        @AuraEnabled
        public String intakeCaseType{get;set;}
    }
    
    public class ResponseWrapper{
        
        @AuraENabled
        public String contactId{get;set;}
        
        @AuraEnabled
        public String intakeId{get;set;}
        
        @AuraEnabled
        public String errorMessage{get;set;}
    }

}