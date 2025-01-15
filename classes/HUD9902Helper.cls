public with sharing class HUD9902Helper {
    public static final String NWC2NameSpace = Utility.getNwc2NameSpace();
    public static final String X9902_AGENCY_OBJECT = NWC2NameSpace + 'X9902Agency__c';
    public static final String X9902_AGENCY_PROFILE_OBJECT = NWC2NameSpace + 'AgencyProfile__c';
    public static final String X9902_CLIENT_OBJECT = NWC2NameSpace + 'X9902Client__c';
    public static final String X9902_COUNSELOR_OBJECT = NWC2NameSpace + 'X9902Counselor__c';
    public static final String X9902_SUMMARY_OBJECT = NWC2NameSpace + 'X9902Summary__c';
    public static final String CLIENT_CASE_OBJECT = NWC2NameSpace + 'ClientCase__c';
    public static final String LOAN_OBJECT = NWC2NameSpace + 'Loan__c';
    
    
    public static final String KEY_ENGLISH_PROFICIENCY_TYPES = 'Limited English Proficiency Types';
    public static final String KEY_RURAL_AREA_TYPES = 'Rural Area Types';
    public static final String KEY_HUDAssistanceTypes= 'HUD Assistance Types';
    public static final String KEY_ReferredByTypes = 'Referred By Types';
    public static final String KEY_IncomeLevels = 'Income Levels';
    public static final String KEY_ActivityTypes = 'Activity Types';
    public static final String KEY_CounselingTerminationReasons = 'Counseling Termination Reasons';
    public static final String KEY_HUDGrantTypes = 'HUD Grant Types';
    public static final String KEY_ReportPeriods = 'Report Periods';
    public static final String KEY_RACES = 'Races';
    public static final String KEY_SESSION_TYPES = 'Session Types';
    public static final String KEY_ETHNICITIES = 'Ethnicities';
    public static final String KEY_STATES = 'States';
    public static final String KEY_MARITAL_STATUS = 'Marital Statuses';
    public static final String KEY_HEAD_OF_HOUSEHOLD_TYPES = 'Head of Household Types';
    public static final String KEY_EDUCATION_LEVELS = 'Education Levels';
    public static final String COUNSELING_PURPOSES = 'Counseling Purposes';
    public static final String KEY_Languages = 'Languages';
    public static final String KEY_MORGAGE_TYPES = 'Mortgage Types';
    public static final String KEY_FINANCE_TYPES = 'Finance Types';
    public static final String KEY_CreditScoreSources = 'Credit Score Sources';
    public static final String KEY_LoanIntakeTypes = 'Loan Intake Types';
    public static final String KEY_CounselingOutcome = 'Counseling outcome';
    public static final String KEY_MissingCreditScoreReasons = 'Missing Credit Score Reasons';
    public static final String KEY_MortgageGrantTypes = 'Mortgage Grant Types';
    

/*
    public static List<X9902FieldMapping__mdt> getMetadataFieldsMap(String x9902Object){
        Map<String, X9902FieldMapping__mdt> mdtMap = X9902FieldMapping__mdt.getAll();
        List<X9902FieldMapping__mdt> fieldMappings = new List<X9902FieldMapping__mdt>(); 
        
        for(X9902FieldMapping__mdt mdt :  mdtMap.values()){
            if(mdt.IsActive__c && mdt.X9902Object__c == x9902Object){
                fieldMappings.add(mdt);
            }
        }
        return fieldMappings;
    }
*/
    public static String get9902Fields(String x9902Object){
        
        String fields = '';
        Map<String, Schema.SObjectField> fieldMap = Schema.getGlobalDescribe().get(x9902Object).getDescribe().fields.getMap();
        for(String fieldName : fieldMap.keySet()){
            Schema.DescribeFieldResult field = fieldMap.get(fieldName).getDescribe();
            fields += field.getName() + ',';    
        }
        System.debug('fields: '+fields); 
        fields = fields.removeEnd(',');
        System.debug('fields: '+fields); 
        return fields;
    }
    /*
    public static String getMappingFields(String x9902Object){
        Map<String, X9902FieldMapping__mdt> mdtMap = X9902FieldMapping__mdt.getAll();
        System.debug('mdtMap: ' + mdtMap);
        String mappingfields = '';
        for(X9902FieldMapping__mdt mdt :  mdtMap.values()){
            System.debug('LOOPmdt: ' + mdt);
            if(mdt.IsActive__c && mdt.X9902Object__c == x9902Object && mdt.X9902Field__c != null){
                
                System.debug('mdt.MappingFieldAPIName__c: ' + mdt.MappingFieldAPIName__c);        
                mappingfields += mdt.MappingFieldAPIName__c + ','; 
            }
        }
        mappingfields = mappingfields.removeEnd(',');
        System.debug('mappingfields: ' + mappingfields);
        return mappingfields;
    }
    */
    
    public static String generateXMLtoSubmit(List<X9902FieldMapping__mdt> metadataList, SObject x9902Obj){
        String xmlStr = '';
        
        System.debug('metadataList: ' + metadataList);
        System.debug('x9902Obj: ' + x9902Obj);
        
        return xmlStr;
    }
    
    
    public static String  getHUDSbiCode(String hudGroupName, String itemDesc) {
        String hudCode;
        List<x9902Categories__c> hudCatgList = x9902Categories__c.getAll().values();
        for (x9902Categories__c cRec : hudCatgList) {
            hudCode = '';
            if (cRec.GroupName__c == hudGroupName && cRec.SBIItemDescription__c == itemDesc) {
                hudCode = cRec.GroupItemID__c;
                break;
            }
        }
        return hudCode;
    }
    
    public static String  generateHUDSbiArrayCode(String hudGroupName, String itemsDescs) {
        
        String hudCode;
        if (itemsDescs != null) {
            List<x9902Categories__c> hudCatgList = x9902Categories__c.getAll().values();
            
            List<String> itemAryDesc = itemsDescs.split(';');
            hudCode = '';
            
            for (String itm : itemAryDesc) {
                for (x9902Categories__c cRec : hudCatgList) {
                    if (cRec.GroupName__c == hudGroupName && cRec.SBIItemDescription__c == itm) {
                        if (hudCode == '') {
                            hudCode = cRec.GroupItemID__c;
                        } else {
                            hudCode += ';' + cRec.GroupItemID__c;
                        }
                        break;
                    }
                }
            }
        }
        return hudCode;
    }
    
    /*Returns a map fromt 9902 Categories custom setting, these values are used for getting the HUD accepted codes for the data being submitted*/
    public static Map<String, x9902Categories__c> get9902CategoriesMap() {
        List<x9902Categories__c> hudCatgList = x9902Categories__c.getAll().values();
        Map<String, x9902Categories__c> hudCatgMap = new Map<String, x9902Categories__c>();
        for (x9902Categories__c cRec : hudCatgList) {
            hudCatgMap.put(cRec.GroupName__c?.trim()?.toLowercase()+'-'+cRec.ItemDescription__c?.trim()?.toLowercase(), cRec);
        }
        return hudCatgMap;
    }
    
    public static String formatPhone(String phone) {
        if (phone <> null) {
            string nondigits = '[^0-9]';
            string phoneDigits;
            phoneDigits = phone.replaceAll(nondigits, '');
            if (phoneDigits.length() == 10)
                return phoneDigits.substring(0, 3) + '-' +
                phoneDigits.substring(3, 6) + '-' +
                phoneDigits.substring(6, 10);
            
            if (phoneDigits.length() == 11) {
                if (phoneDigits.substring(0, 1) == '1') {
                    return  phoneDigits.substring(1, 4) + '-' +
                        phoneDigits.substring(4, 7) + '-' +
                        phoneDigits.substring(7, 11);
                }
            }
        }
        return phone;
    }
    
    public static String formatDate(Date dt) {
        if (dt <> null) {
            String formattedDate = DateTime.newInstance(dt.year(), dt.month(), dt.day()).format('MM-dd-yyyy');
            return formattedDate;
        }
        return null;
    }
    
    public static String getStringValueOf(Object fieldValue){
        if(fieldValue == null){
            return '';
        }else{
            return String.valueOf(fieldValue);
        }
    }

    public static String getHudCategoryCode(String groupName, String itemDescription, Map<String,x9902Categories__c> x9902CategoriesMap){
        if(String.isBlank(itemDescription))
            return '';
        
        groupName = groupName?.trim()?.toLowerCase();
        itemDescription = itemDescription?.trim()?.toLowerCase();
        return x9902CategoriesMap.get(groupName?.trim()?.toLowerCase()+'-'+itemDescription.trim()?.toLowerCase())?.GroupItemID__c;
    }

    public static String getFormattedDate(Date dt){
        if(dt == null)
            return '';
        return String.valueOf(DateTime.newInstance(dt.year(),dt.month(),dt.day()).format('MM-dd-yyyy'));
    }
}