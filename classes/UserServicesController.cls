/**
 * @description  : Manages user services for the Compass Portal Site, offering methods to retrieve desired services and language field mappings for localization.
**/
public without sharing class UserServicesController {
    /*Retrieves a list of desired services with their descriptions and highlights.*/
    @AuraEnabled(cacheable=true)
    public static Map<String, Object> getDesiredServices() {
        User user = [SELECT Id, ContactId FROM User WHERE Id =: UserInfo.getUserId() LIMIT 1];
        Set<Id> caseIds = new Set<Id>();
        for(Intake__c intake : [SELECT Id, CaseType__c FROM Intake__c WHERE PrimaryClient__c  =: user.ContactId]){
                caseIds.add(intake.CaseType__c);
        }
        Map<String, Object> desireServiceMap= new Map<String, Object>();
        desireServiceMap.put('records', [SELECT id, Name,NameSpanish__c,ShortDescription__c,ShortDescriptionSpanish__c,// DescriptionEnglish__c, 
            Highlights__c,HighlightsSpanish__c, RequiredDocuments__c FROM CaseType__c WHERE Id NOT IN : caseIds AND IsPortal__c = true LIMIT 2000]);
        desireServiceMap.put('mapping', getMultiLanguageFieldMappings());
        return desireServiceMap;
    }
    
    /*Retrieves desired service with their descriptions and highlights.*/
    @AuraEnabled(cacheable=true)
    public static Map<String, Object> getDesiredServiceRecord(String recordId) {
        Map<String, Object> desireServiceMap= new Map<String, Object>();
        desireServiceMap.put('records', [SELECT Id, Name,NameSpanish__c,ShortDescription__c,ShortDescriptionSpanish__c,DescriptionEnglish__c,DescriptionSpanish__c,
            FrequentlyAskedQuestionsEnglish__c, FrequentlyAskedQuestionsSpanish__c, Highlights__c,HighlightsSpanish__c, RequiredDocuments__c, RequiredDocumentsSpanish__c FROM CaseType__c WHERE ID =:recordId]);
        desireServiceMap.put('mapping', getMultiLanguageFieldMappings());
        return desireServiceMap;
    }

        /*Returns mappings of language-specific field names (English and Spanish) for localization.*/
    private static Map<String, Map<String, String>> getMultiLanguageFieldMappings() {
        return new Map<String, Map<String, String>>{
            'English' => new Map<String, String>{'Name' => 'Name', 'ShortDescription' => 'ShortDescription__c', 'Description' => 'DescriptionEnglish__c', 'Highlights' => 'Highlights__c', 'FAQ' => 'FrequentlyAskedQuestionsEnglish__c', 'RequiredDocuments' => 'RequiredDocuments__c'},
            'Spanish' => new Map<String, String>{'Name' => 'NameSpanish__c', 'ShortDescription' => 'ShortDescriptionSpanish__c', 'Description' => 'DescriptionSpanish__c', 'Highlights' => 'HighlightsSpanish__c', 'FAQ' => 'FrequentlyAskedQuestionsSpanish__c', 'RequiredDocuments' => 'RequiredDocumentsSpanish__c'}
        };
    }
    
    @AuraEnabled(cacheable=true)
    public static Map<String, Object> getEnrolledServicesRecord() {
        Map<String, Wrapper> enrolledServiceDetails = new Map<String, Wrapper>();
        Map<String, Object> desireServiceMap= new Map<String, Object>();
        User user = [SELECT Id, ContactId FROM User WHERE Id =: UserInfo.getUserId() LIMIT 1];
        Set<Id> caseIds = new Set<Id>();
        for(Intake__c intake : [SELECT Id, CaseType__c, Status__c, (SELECT id, ClientCaseStatus__c FROM Client_Cases__r) 
                                FROM Intake__c WHERE PrimaryClient__c  =: user.ContactId AND PrimaryClient__c  != null]){
                                    System.debug('intake==>'+ intake);
            Wrapper wr = new Wrapper();
            wr.intakeId = intake.Id;
			wr.isEnrolled = true;                                    
            caseIds.add(intake.CaseType__c);
            if(!intake.Client_Cases__r.isEmpty()){
                wr.caseClientId = intake.Client_Cases__r[0].Id;
                wr.status = intake.Client_Cases__r[0].ClientCaseStatus__c;
            }else{
                wr.status = intake.Status__c;
            }
            enrolledServiceDetails.put(intake.CaseType__c, wr);
        }
        desireServiceMap.put('records', [SELECT Id, Name,NameSpanish__c,ShortDescription__c,ShortDescriptionSpanish__c,DescriptionEnglish__c,DescriptionSpanish__c,
            FrequentlyAskedQuestionsEnglish__c, FrequentlyAskedQuestionsSpanish__c, Highlights__c,HighlightsSpanish__c FROM CaseType__c WHERE ID IN : caseIds]);
        desireServiceMap.put('mapping', getMultiLanguageFieldMappings());
        desireServiceMap.put('enrolledServiceDetails', enrolledServiceDetails);
        return desireServiceMap;
    }
    
    @AuraEnabled(cacheable=true)
    public static Wrapper getIntakeDetails(String recordId){
        if(String.isBlank(recordId)){
            return NULL;
        }
        
        ID recId = recordId; 
        String sObjectName = recId.getSObjectType().getDescribe().getName();
		string NWC2NameSpace = Utility.getNwc2NameSpace();
        if(sobjectName == NWC2NameSpace+'Intake__c'){
            List<Intake__c> intakeList = [SELECT Id, CaseType__c, Status__c, (SELECT id, ClientCaseStatus__c FROM Client_Cases__r) FROM Intake__c WHERE Id  =:recId WITH USER_MODE LIMIT 1];
            
            if(intakeList.size() > 0){
                Wrapper result = new Wrapper();
                if(intakeList[0].Client_Cases__r.size() > 0){
                    result.status = intakeList[0].Client_Cases__r[0].ClientCaseStatus__c;
                    result.caseClientId = intakeList[0].Client_Cases__r[0].Id;
                } else{
                    result.status = intakeList[0].Status__c;
                }
                result.serviceId = intakeList[0].CaseType__c;
                result.intakeId = intakeList[0].Id;
                
                return result;
            }
        } else if(sobjectName == NWC2NameSpace+'ClientCase__c'){
            List<ClientCase__c> clientCaseList = [SELECT Id, IntakeCase__c, IntakeCase__r.CaseType__c, IntakeCase__r.Status__c, ClientCaseStatus__c FROM ClientCase__c WHERE Id  =:recId WITH USER_MODE LIMIT 1];
            
            if(clientCaseList.size() > 0){
                Wrapper result = new Wrapper();
                result.status = clientCaseList[0].ClientCaseStatus__c;
                result.caseClientId = clientCaseList[0].Id;
                result.serviceId = clientCaseList[0].IntakeCase__r.CaseType__c;
                result.intakeId = clientCaseList[0].IntakeCase__c;
                
                return result;
            }
        }
        return null;
    }
  
    public class Wrapper{
        @AuraEnabled
        public String caseClientId {get; set;}
        @AuraEnabled
        public String intakeId {get; set;}
        @AuraEnabled
        public String status {get; set;}
        @AuraEnabled
        public String serviceId{get;set;}
        @AuraEnabled
        public Boolean isEnrolled {get; set;}
    }
   
}