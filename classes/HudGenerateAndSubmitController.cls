public with sharing class HudGenerateAndSubmitController {
    public static final Integer CHUNK_SIZE = 1;
    public static final String JOBKEY_AGENCY = 'Agency';
    public static final String JOBKEY_CLIENT = 'Client';
    public static final String JOBKEY_COUNSELOR = 'Counselor';
    public static final String JOBKEY_SUMMARY = 'Summary';
    
    @AuraEnabled
    public static Map<String, String> executeSubmissionBatch(String reportId, Object batchChecks){
        try {
            Map<String, String> batchJobIdMap = new Map<String, String>();
            String batchChecksString = JSON.serialize(batchChecks);
            Map<String, Boolean> batchChecksMap = (Map<String, Boolean>)JSON.deserialize(batchChecksString, Map<String, Boolean>.class);
            if(batchChecksMap.get(JOBKEY_AGENCY)){
                HUD9902AgencySubmitBatch agencySubmitBatch = new HUD9902AgencySubmitBatch(reportId);
                batchJobIdMap.put(JOBKEY_AGENCY,Database.executeBatch(agencySubmitBatch, CHUNK_SIZE));
            }
            if(batchChecksMap.get(JOBKEY_CLIENT)){
                HUD9902ClientSubmissionBatch clientSubmitBatch = new HUD9902ClientSubmissionBatch(reportId);
                batchJobIdMap.put(JOBKEY_CLIENT, Database.executeBatch(clientSubmitBatch, 4000));
            }
            if(batchChecksMap.get(JOBKEY_COUNSELOR)){
                HUD9902CounselorSubmitBatch counselorBatch = new HUD9902CounselorSubmitBatch(reportId);//Client Batch
                batchJobIdMap.put(JOBKEY_COUNSELOR, Database.executeBatch(counselorBatch, CHUNK_SIZE));
            }
            if(batchChecksMap.get(JOBKEY_SUMMARY)){
                HUD9902SummarySubmitBatch summaryBatch = new HUD9902SummarySubmitBatch(reportId);//Client Batch
                batchJobIdMap.put(JOBKEY_SUMMARY, Database.executeBatch(summaryBatch, CHUNK_SIZE));
            }
            return batchJobIdMap;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static Map<String, String> executeBatch(String reportId, Object batchChecks){
        try {
            Map<String, String> batchJobIdMap = new Map<String, String>();
            String batchChecksString = JSON.serialize(batchChecks);
            Map<String, Boolean> batchChecksMap = (Map<String, Boolean>)JSON.deserialize(batchChecksString, Map<String, Boolean>.class);
            
            if(batchChecksMap.get(JOBKEY_AGENCY)){
                List<X9902Agency__c> x9902agencies = [SELECT Id FROM X9902Agency__c WHERE X9902__c = :reportId];
                Database.delete(x9902agencies);
                generate9902AgencyRecords(reportId);
                batchJobIdMap.put(JOBKEY_AGENCY,'');
            }
            if(batchChecksMap.get(JOBKEY_CLIENT)){
                List<X9902Client__c> x9902Clients = [SELECT Id FROM X9902Client__c	WHERE X9902__c = :reportId];
                Database.delete(x9902Clients);
                HUD9902ClientReportGenerateBatch batch = new HUD9902ClientReportGenerateBatch(reportId);
                batchJobIdMap.put(JOBKEY_CLIENT, Database.executeBatch(batch, 2000));
            }
            if(batchChecksMap.get(JOBKEY_COUNSELOR)){
                List<X9902Counselor__c> x9902Counselor = [SELECT Id FROM X9902Counselor__c WHERE X9902__c = :reportId];
                Database.delete(x9902Counselor);
                HUD9902CounselorReportGenerateBatch counselorbatch = new HUD9902CounselorReportGenerateBatch(reportId);
                batchJobIdMap.put(JOBKEY_COUNSELOR, Database.executeBatch(counselorbatch, CHUNK_SIZE));
            }
            if(batchChecksMap.get(JOBKEY_SUMMARY)){
                List<X9902Summary__c> x9902Summary = [SELECT Id FROM X9902Summary__c WHERE X9902__c = :reportId LIMIT 10000];
                Database.delete(x9902Summary);
                HUD9902SummaryReportGenerateBatch batch = new HUD9902SummaryReportGenerateBatch(reportId);
                batchJobIdMap.put(JOBKEY_SUMMARY, Database.executeBatch(batch, CHUNK_SIZE));
            }
            return batchJobIdMap;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    @AuraEnabled
    public static Map<String, AsyncApexJob> getJobDetails(Object batchJobtoIdsMap, Object batchChecks ){
        try {
            Map<String, AsyncApexJob> batchTypeStatusMap = new Map<String, AsyncApexJob>();
            String batchChecksString = JSON.serialize(batchChecks);
            Map<String, Boolean> batchChecksMap = (Map<String, Boolean>)JSON.deserialize(batchChecksString, Map<String, Boolean>.class);
            
            String batchJobMapString = JSON.serialize(batchJobtoIdsMap);
            Map<String, String> batchJobMap = (Map<String, String>)JSON.deserialize(batchJobMapString, Map<String, String>.class);
            if(batchChecksMap.get(JOBKEY_AGENCY)){
                if(batchJobMap.get(JOBKEY_AGENCY) != null && batchJobMap.get(JOBKEY_AGENCY) != ''){//will work for submission only
                    batchTypeStatusMap.put(JOBKEY_AGENCY,[SELECT Id, Status, JobItemsProcessed, TotalJobItems, ExtendedStatus,
                    NumberOfErrors FROM AsyncApexJob where Id =: batchJobMap.get(JOBKEY_AGENCY) ]);
                }else{
                    //As 9902 agency generation is not done using batch it will not have any AsyncApexJob id creating a dummy object for it. 
                    String jsonStr= '{"Id": null, "Status": "Completed", "JobItemsProcessed": 1, "TotalJobItems": 1, "NumberOfErrors": 0, "ExtendedStatus":""}';
                    AsyncApexJob obj = (AsyncApexJob)JSON.deserialize(jsonStr, AsyncApexJob.class);
                    batchTypeStatusMap.put(JOBKEY_AGENCY,obj);
                }
            }
            if(batchChecksMap.get(JOBKEY_CLIENT) && batchJobMap.get(JOBKEY_CLIENT) != null){
                batchTypeStatusMap.put(JOBKEY_CLIENT,[SELECT Id, Status, JobItemsProcessed, TotalJobItems, ExtendedStatus,
                NumberOfErrors FROM AsyncApexJob where Id =: batchJobMap.get(JOBKEY_CLIENT) ]);
            }
            if(batchChecksMap.get(JOBKEY_COUNSELOR) && batchJobMap.get(JOBKEY_COUNSELOR) != null){
                batchTypeStatusMap.put(JOBKEY_COUNSELOR,[SELECT Id, Status, JobItemsProcessed, TotalJobItems, ExtendedStatus,
                NumberOfErrors FROM AsyncApexJob where Id =: batchJobMap.get(JOBKEY_COUNSELOR) ]);
            }
            if(batchChecksMap.get(JOBKEY_SUMMARY) && batchJobMap.get(JOBKEY_SUMMARY) != null){
                batchTypeStatusMap.put(JOBKEY_SUMMARY,[SELECT Id, Status, JobItemsProcessed, TotalJobItems, ExtendedStatus,
                NumberOfErrors FROM AsyncApexJob where Id =: batchJobMap.get(JOBKEY_SUMMARY) ]);
            }
            
            return batchTypeStatusMap;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    //Returns the records with validation error
    @AuraEnabled(cacheable=true)
    public static Map<String, List<SObject>> getValidationErrors(String sobjectName, String recordId){
        List<Id> courseIdList = new List<Id>();
        Map<String, List<SObject>> sobjNameRecordsMap = new Map<String, List<SObject>>();
        Id primaryClientRTId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('PrimaryClient').getRecordTypeId();
        String x9902ClientQueryStr = 'SELECT Id, X9902__c, Contact__c, ClientCase__c FROM X9902Client__c WHERE X9902__c= \''+recordId+'\'';
        String x9902CounselorQueryStr = 'SELECT Id, X9902__c, User__c, StaffTrainingAttendance__c FROM X9902Counselor__c WHERE X9902__c= \''+recordId+'\'';
        
        
        //TODO: Add summary related errors - Course Session, and Attendees
        List<Id> contactIdList = new List<Id>();
        List<Id> caseIdList = new List<Id>();
        List<Id> userIdList = new List<Id>();
        List<Id> counselorTrainingIdList = new List<Id>();
        
        X9902__c x9902 = [SELECT Id, PeriodStartDate__c, PeriodEndDate__c, Quarter__c FROM X9902__c WHERE Id = :recordId];
        
        Date qtrStartDate = x9902.PeriodStartDate__c;
        Date qtrEndDate = x9902.PeriodEndDate__c;
        
        List<X9902Client__c> x9902ClientList = Database.query(x9902ClientQueryStr);
        List<X9902Counselor__c> x9902CounselorList = Database.query(x9902CounselorQueryStr);
        
        for(X9902Client__c x9902client : x9902ClientList){
            contactIdList.add(x9902client.Contact__c);
            caseIdList.add(x9902client.ClientCase__c);
        }
        
        for(X9902Counselor__c x9902counselor : x9902CounselorList){
            userIdList.add(x9902counselor.User__c);
            counselorTrainingIdList.add(x9902counselor.StaffTrainingAttendance__c);
        }
        
        for(X9902Summary__c summary : [select id,Course__c from X9902Summary__c 
                                        where X9902__c =: recordId AND ElementType__c = 'Group Session']){
                courseIdList.add(summary.Course__c);
        }
        
        sobjNameRecordsMap.put('AgencyProfile__c', [SELECT Id, Name, ValidationCombined__c FROM AgencyProfile__c Limit 1]);
        sobjNameRecordsMap.put('Contact', [SELECT Id, Name, ValidationCombined__c FROM Contact WHERE Id IN :contactIdList]);
        sobjNameRecordsMap.put('User', [SELECT Id, Name, ValidationCombined__c FROM User WHERE Id IN :userIdList]);
        sobjNameRecordsMap.put('ClientCase__c', [SELECT Id, Name, ValidationCombined__c FROM ClientCase__c WHERE Id IN :caseIdList]);
        sobjNameRecordsMap.put('CounselorTraining__c', [SELECT Id, Name, ValidationCombined__c FROM CounselorTraining__c WHERE Id IN :counselorTrainingIdList]);
        sobjNameRecordsMap.put('sumoapp__AdditionalInfo__c', [
            SELECT Id, Name, ValidationCombined__c
            FROM sumoapp__AdditionalInfo__c
            WHERE Id IN :courseIdList
        ]);
        sobjNameRecordsMap.put('sumoapp__Attendee__c', [
            SELECT Id, Name, ValidationCombined__c 
            FROM sumoapp__Attendee__c 
            WHERE sumoapp__SumoEvent__c IN :courseIdList
            AND sumoapp__SumoEvent__r.IsParent__c = true
            AND sumoapp__ContactRelation__r.RecordtypeId =:primaryClientRTId 
            AND sumoapp__SumoEvent__r.RecordType.Name IN ('Course', 'Event')
            AND Attendance_Status__c IN ('Attended - Complete', 'Course Complete')
            AND ExcludeAttendeeFromHUD9902__c = False
            ORDER BY LastModifiedDate ASC
        ]);
        return sobjNameRecordsMap;
    }

    //TODO: This method might not be needed - Assess and remove if needed
    //Fetches the comma seperated formula fields used for validation errors
    public static String getSObjectField(String sObjName){
        String fieldsToQuery = '';//only validation formula fields
        Map<String, Schema.SObjectField> fieldMap = Schema.getGlobalDescribe().get(sObjName).getDescribe().fields.getMap();
        for(String fieldName : fieldMap.keySet()){
            Schema.DescribeFieldResult field = fieldMap.get(fieldName).getDescribe();
            if(field.getName().startsWith('Validation')){
                fieldsToQuery = fieldsToQuery + field.getName() +',';
            }
        }
        fieldsToQuery = fieldsToQuery.removeEnd(',');
        return fieldsToQuery;
    }
    
    //Fetches the comma seperated formula fields used for validation errors
    public static String getSObjectAllFields(String sObjName){
        Map<String, Schema.SObjectField> fieldMap = Schema.getGlobalDescribe().get(sObjName).getDescribe().fields.getMap();
        String fieldsToQuery = String.join( fieldMap.keySet(), ',' );
        fieldsToQuery = fieldsToQuery.removeEnd(',');
        return fieldsToQuery;
    }

    public static void generate9902AgencyRecords(String reportId){
        List<X9902Agency__c> x9902AgencyList = new List<X9902Agency__c>();
        String agencyProfileFields = getSObjectAllFields('AgencyProfile__c');
        String queryStr = 'SELECT ' + agencyProfileFields + ' FROM AgencyProfile__c LIMIT 1';
        AgencyProfile__c agencyProfile = (AgencyProfile__c) Database.query(queryStr);
        
        List<X9902Agency__c> x9902AgencyRecs = new List<X9902Agency__c>();
        
        X9902Agency__c x9902AgencyProfile = new X9902Agency__c();
        x9902AgencyProfile.X9902__c = reportId;
        x9902AgencyProfile.ElementType__c = 'Profile';
        x9902AgencyProfile.AgencyName__c = agencyProfile.Name;
        x9902AgencyProfile.AgencysDunnsNumber__c = agencyProfile.AgencyDunnsNumber__c;
        x9902AgencyProfile.AgencyWebSite__c = agencyProfile.AgencyWebsite__c;
        if(agencyProfile.AgencyWebsite__c != null && !agencyProfile.AgencyWebsite__c.startsWithIgnoreCase('http://') && !agencyProfile.AgencyWebsite__c.startsWithIgnoreCase('https://') ){
            x9902AgencyProfile.AgencyWebSite__c = 'http://'+agencyProfile.AgencyWebsite__c;
        }
        x9902AgencyProfile.AgencysOfficePhoneNumber__c = HUD9902Helper.formatPhone(agencyProfile.AgencyPhoneNumber__c);
        x9902AgencyProfile.AgencysOfficeEmailAddress__c = agencyProfile.AgencyEmailAddress__c;
        x9902AgencyProfile.AgencyTollFreePhoneNumber__c = HUD9902Helper.formatPhone(agencyProfile.AgencyTollFreePhone__c);
        x9902AgencyProfile.AgencysFAXnumber__c = HUD9902Helper.formatPhone(agencyProfile.AgencyFAXNumber__c);
        x9902AgencyProfile.AgencyEIN__c = agencyProfile.AgencyEIN__c;
        x9902AgencyProfile.AgencyUEI__c = agencyProfile.AgencyUEI__c;
        x9902AgencyProfile.AgencyColonias__c = agencyProfile.AgencyColonias__c;
        x9902AgencyProfile.AgencyCounselingMethods__c	= agencyProfile.AgencyCounselingMethods__c;
        x9902AgencyProfile.AgencyLanguages__c = agencyProfile.AgencyLanguages__c;
        x9902AgencyProfile.AgencyCounselingBudget__c = agencyProfile.AgencyCounselingBudget__c;
        x9902AgencyProfile.AgencyFaithBase__c	= agencyProfile.AgencyFaithBase__c;
        x9902AgencyProfile.AgencyUrban__c	= agencyProfile.AgencyUrbanArea__c;
        x9902AgencyProfile.AgencyRural__c = agencyProfile.AgencyRuralArea__c;
        x9902AgencyProfile.AgencyMigrantFarmWorkers__c	 = agencyProfile.AgencyMigrantFarmWorkers__c;
        x9902AgencyProfile.AgencyPhysicalAddressLine1__c = agencyProfile.AgencyAddress__Street__s;
        x9902AgencyProfile.AgencyPhysicalAddressCity__c = agencyProfile.AgencyAddress__City__s;
        x9902AgencyProfile.AgencyPhysicalAddressState__c = agencyProfile.AgencyAddress__StateCode__s;
        x9902AgencyProfile.AgencyPhysicalAddressZipCode__c = agencyProfile.AgencyAddress__PostalCode__s;
        x9902AgencyProfile.AgencyMailingAddressLine1__c = agencyProfile.AgencyMailingAddress__c;
        x9902AgencyProfile.AgencyMailingAddressLine2__c = agencyProfile.AgencyMailingAddress__c;
        x9902AgencyProfile.AgencyMailingAddressCity__c = agencyProfile.AgencyMailingCity__c;
        x9902AgencyProfile.AgencyMailingAddressState__c = agencyProfile.AgencyMailingState__c;
        x9902AgencyProfile.AgencyMailingAddressZipCode__c = agencyProfile.AgencyMailingPostalCode__c;
        
        x9902AgencyRecs.add(x9902AgencyProfile);
        
        Map<String, String> stateCodeNumByStateCode = new Map<String, String>();
        
        Schema.DescribeFieldResult fieldResult = X9902Agency__c.ContactState__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry f : ple)
        {
            stateCodeNumByStateCode.put(f.getLabel(), f.getValue());
        }
        
        Map<String, x9902Categories__c> categoriesByGroupNameAndDesc = HUD9902Helper.get9902CategoriesMap();
        
        X9902Agency__c x9902Agency1 = new X9902Agency__c();
        x9902Agency1.X9902__c = reportId;
        x9902Agency1.ElementType__c = 'Contact';
        x9902Agency1.AgencyName__c = agencyProfile.Name;
        x9902Agency1.AgencyEIN__c = agencyProfile.AgencyEIN__c;
        x9902Agency1.AgencyUEI__c = agencyProfile.AgencyUEI__c;
        x9902Agency1.ContactType__c = categoriesByGroupNameAndDesc.containsKey('Contact Types-Agency Senior Executive'.trim().toLowercase()) ? categoriesByGroupNameAndDesc.get('Contact Types-Agency Senior Executive'.trim().toLowercase()).GroupItemID__c : '';
        x9902Agency1.ContactTitle__c = categoriesByGroupNameAndDesc.containsKey('Contact Titles-Office Executive'.trim().toLowercase()) ? categoriesByGroupNameAndDesc.get('Contact Titles-Office Executive'.trim().toLowercase()).GroupItemID__c : '';
        x9902Agency1.ContactFirstName__c = agencyProfile.HUDContactFirstName__c;
        x9902Agency1.ContactMiddleName__c = agencyProfile.HUDContactMiddleName__c;
        x9902Agency1.ContactLastName__c = agencyProfile.HUDContactLastName__c;
        x9902Agency1.ContactEmail__c = agencyProfile.HUDContactEmail__c;
        x9902Agency1.ContactMobileNumber__c = agencyProfile.HUDContactMobileNumber__c;
        x9902Agency1.ContactPhoneNumber__c = agencyProfile.HUDContactPhone__c;
        x9902Agency1.ContactExtensionNumber__c = agencyProfile.HUDOfficeExecutivePhoneExtension__c ;
        x9902Agency1.ContactFAXNumber__c = agencyProfile.HUDContactFaxNumber__c;
        x9902Agency1.ContactAddress1__c = agencyProfile.HUDContactAddress__Street__s;
        x9902Agency1.ContactAddress2__c = agencyProfile.HUDContactAddressLine2__c;
        x9902Agency1.ContactCity__c = agencyProfile.HUDContactAddress__City__s;
        if(stateCodeNumByStateCode != NULL && agencyProfile.HUDContactAddress__StateCode__s != NULL && stateCodeNumByStateCode.containsKey(agencyProfile.HUDContactAddress__StateCode__s)){
            x9902Agency1.ContactState__c = stateCodeNumByStateCode.get(agencyProfile.HUDContactAddress__StateCode__s);
        }
        x9902Agency1.ContactZipCode__c = agencyProfile.HUDContactAddress__PostalCode__s;
        
        x9902AgencyRecs.add(x9902Agency1);
        
        X9902Agency__c x9902Agency2 = new X9902Agency__c();
        x9902Agency2.X9902__c = reportId;
        x9902Agency2.ElementType__c = 'Contact';
        x9902Agency2.AgencyName__c = agencyProfile.Name;
        x9902Agency2.AgencyEIN__c = agencyProfile.AgencyEIN__c;
        x9902Agency2.AgencyUEI__c = agencyProfile.AgencyUEI__c;
        x9902Agency2.ContactType__c = categoriesByGroupNameAndDesc.containsKey('Contact Types-Agency Manager'.trim().toLowercase()) ? categoriesByGroupNameAndDesc.get('Contact Types-Agency Manager'.trim().toLowercase()).GroupItemID__c : '';
        x9902Agency2.ContactTitle__c = categoriesByGroupNameAndDesc.containsKey('Contact Titles-Office Manager'.trim().toLowercase()) ? categoriesByGroupNameAndDesc.get('Contact Titles-Office Manager'.trim().toLowercase()).GroupItemID__c : '';
        x9902Agency2.ContactFirstName__c = agencyProfile.HUDOfficeExecutiveFirstName__c;
        x9902Agency2.ContactMiddleName__c = agencyProfile.HUDOfficeExecutiveMiddleName__c;
        x9902Agency2.ContactLastName__c = agencyProfile.HUDOfficeExecutiveLastName__c;
        x9902Agency2.ContactEmail__c = agencyProfile.HUDOfficeExecutiveEmail__c;
        x9902Agency2.ContactMobileNumber__c = agencyProfile.HUDOfficeExecutiveMobileNumber__c;
        x9902Agency2.ContactPhoneNumber__c = agencyProfile.HUDOfficeExecutivePhone__c;
        x9902Agency2.ContactExtensionNumber__c = agencyProfile.HUDOfficeManagerPhoneExtension__c;
        x9902Agency2.ContactFAXNumber__c = agencyProfile.HUDOfficeExecutiveFaxNumber__c;
        x9902Agency2.ContactAddress1__c = agencyProfile.HUDOfficeExecutiveAddress__Street__s;
        x9902Agency2.ContactAddress2__c = agencyProfile.HUDOfficeExecutiveAddressLine2__c;
        x9902Agency2.ContactCity__c = agencyProfile.HUDOfficeExecutiveAddress__City__s;
        if(stateCodeNumByStateCode != NULL && agencyProfile.HUDOfficeExecutiveAddress__StateCode__s != NULL && stateCodeNumByStateCode.containsKey(agencyProfile.HUDOfficeExecutiveAddress__StateCode__s)){
            x9902Agency2.ContactState__c = stateCodeNumByStateCode.get(agencyProfile.HUDOfficeExecutiveAddress__StateCode__s);
        }

        x9902Agency2.ContactZipCode__c = agencyProfile.HUDOfficeExecutiveAddress__PostalCode__s;
        
        x9902AgencyRecs.add(x9902Agency2);
        
        X9902Agency__c x9902Agency3 = new X9902Agency__c();
        x9902Agency3.X9902__c = reportId;
        x9902Agency3.ElementType__c = 'Contact';
        x9902Agency3.AgencyName__c = agencyProfile.Name;
        x9902Agency3.AgencyEIN__c = agencyProfile.AgencyEIN__c;
        x9902Agency3.AgencyUEI__c = agencyProfile.AgencyUEI__c;
        x9902Agency3.ContactType__c = categoriesByGroupNameAndDesc.containsKey('Contact Types-Agency Contact for HUD Use'.trim().toLowercase()) ? categoriesByGroupNameAndDesc.get('Contact Types-Agency Contact for HUD Use'.trim().toLowercase()).GroupItemID__c : '';
        x9902Agency3.ContactTitle__c = categoriesByGroupNameAndDesc.containsKey('Contact Titles-HUD Contact'.trim().toLowercase()) ? categoriesByGroupNameAndDesc.get('Contact Titles-HUD Contact'.trim().toLowercase()).GroupItemID__c : '';
        x9902Agency3.ContactFirstName__c = agencyProfile.HUDOfficeManagerFirstName__c;
        x9902Agency3.ContactMiddleName__c = agencyProfile.HUDOfficeManagerMiddleName__c;
        x9902Agency3.ContactLastName__c = agencyProfile.HUDOfficeManagerLastName__c;
        x9902Agency3.ContactEmail__c = agencyProfile.HUDOfficeManagerEmail__c;
        x9902Agency3.ContactMobileNumber__c = agencyProfile.HUDOfficeManagerMobileNumber__c;
        x9902Agency3.ContactPhoneNumber__c = agencyProfile.HUDOfficeManagerPhone__c;
        x9902Agency3.ContactExtensionNumber__c = agencyProfile.HUDContactPhoneExtension__c;
        x9902Agency3.ContactFAXNumber__c = agencyProfile.HUDOfficeManagerFaxNumber__c;
        x9902Agency3.ContactAddress1__c = agencyProfile.HUDOfficeManagerAddress__Street__s;
        x9902Agency3.ContactAddress2__c = agencyProfile.HUDOfficeManagerAddressLine2__c;
        x9902Agency3.ContactCity__c = agencyProfile.HUDOfficeManagerAddress__City__s;
        if(stateCodeNumByStateCode != NULL && agencyProfile.HUDOfficeManagerAddress__StateCode__s != NULL && stateCodeNumByStateCode.containsKey(agencyProfile.HUDOfficeManagerAddress__StateCode__s)){
            x9902Agency3.ContactState__c = stateCodeNumByStateCode.get(agencyProfile.HUDOfficeManagerAddress__StateCode__s);
        }
        
        x9902Agency3.ContactZipCode__c = agencyProfile.HUDOfficeManagerAddress__PostalCode__s;
        
        x9902AgencyRecs.add(x9902Agency3);
        
        insert x9902AgencyRecs;
    }
    
    @AuraEnabled
    public static void update9902Status(Object batchJobStatusMap, Object batchChecks, Id reportId){
        try {
            String batchChecksString = JSON.serialize(batchChecks);
            Map<String, Boolean> batchChecksMap = (Map<String, Boolean>)JSON.deserialize(batchChecksString, Map<String, Boolean>.class);
            String batchJobStatusString = JSON.serialize(batchJobStatusMap);
            Map<String, String> batchJobStatus = (Map<String, String>)JSON.deserialize(batchJobStatusString, Map<String, String>.class);
            X9902__c x9902 = new X9902__c();
            x9902.Id = reportId;
            if(batchChecksMap.get(JOBKEY_AGENCY)){
                x9902.AgencyGenerationStatus__c = batchJobStatus.get(JOBKEY_AGENCY);
            }
            if(batchChecksMap.get(JOBKEY_CLIENT)){
                x9902.ClientGenerationStatus__c = batchJobStatus.get(JOBKEY_CLIENT);
            }
            if(batchChecksMap.get(JOBKEY_COUNSELOR)){
                x9902.CounselorGenerationStatus__c = batchJobStatus.get(JOBKEY_COUNSELOR);
            }
            if(batchChecksMap.get(JOBKEY_SUMMARY)){
                x9902.Summary9902GenerationStatus__c = batchJobStatus.get(JOBKEY_SUMMARY);
            }
            update x9902;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}