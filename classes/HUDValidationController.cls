public with sharing class HUDValidationController {

    @AuraEnabled(cacheable=true)
    public static String getValidationErrors(String sobjectName, String recordId){
        String NWC2NameSpace = Utility.getNwc2NameSpace();
        String errorString = '';
        if(String.isNotBlank(sobjectName) && String.isNotBlank(recordId)){
            String queryStr = '';
            
            if(sobjectName == 'Contact'){
                queryStr = 'SELECT Id, '+NWC2NameSpace+'ValidationCombined__c, '+NWC2NameSpace+'ValidationCombined1__c FROM ' + sobjectName + ' WHERE Id = \''+ recordId+'\'';
            } else if(sobjectName == NWC2NameSpace+'ClientCase__c' || sobjectName == NWC2NameSpace+'AgencyProfile__c'){
                queryStr = 'SELECT Id, '+NWC2NameSpace+'ValidationCombined__c, '+NWC2NameSpace+'ValidationCombined1__c FROM ' + sobjectName + ' WHERE Id = \''+ recordId+'\'';
            } else {
                queryStr = 'SELECT Id, '+NWC2NameSpace+'ValidationCombined__c FROM ' + sobjectName + ' WHERE Id = \''+ recordId+'\'';
            }
            
            List<SObject> rec = Database.query(queryStr);
            
            if(!rec.isEmpty() && (sobjectName == NWC2NameSpace+'ClientCase__c' || sobjectName == 'Contact' || sobjectName == NWC2NameSpace+'AgencyProfile__c')){
                if(String.isNotBlank(String.valueOf(rec[0].get(NWC2NameSpace+'ValidationCombined__c'))) && rec[0].get(NWC2NameSpace+'ValidationCombined1__c') != 'NO ERROR'){
                    errorString = String.valueOf(rec[0].get(NWC2NameSpace+'ValidationCombined__c')) + String.valueOf(rec[0].get(NWC2NameSpace+'ValidationCombined1__c'));
                } else if(String.isNotBlank(String.valueOf(rec[0].get(NWC2NameSpace+'ValidationCombined__c'))) && rec[0].get(NWC2NameSpace+'ValidationCombined1__c') == 'NO ERROR'){
                    errorString = String.valueOf(rec[0].get(NWC2NameSpace+'ValidationCombined__c'));
                } else if(String.isBlank(String.valueOf(rec[0].get(NWC2NameSpace+'ValidationCombined__c'))) && rec[0].get(NWC2NameSpace+'ValidationCombined1__c') != 'NO ERROR'){
                    errorString = 'Required field(s) missing: ' + String.valueOf(rec[0].get(NWC2NameSpace+'ValidationCombined1__c'));
                } else if(String.isBlank(String.valueOf(rec[0].get(NWC2NameSpace+'ValidationCombined__c'))) && rec[0].get(NWC2NameSpace+'ValidationCombined1__c') == 'NO ERROR'){
                    errorString = String.valueOf(rec[0].get(NWC2NameSpace+'ValidationCombined1__c'));
                }
            } else{
                errorString = String.valueOf(rec[0].get(NWC2NameSpace+'ValidationCombined__c'));
            }
            
            //return Database.query(queryStr);
        }
        
        return String.isNotBlank(errorString) ? errorString.removeEnd(',') : 'NO ERROR';
    }
}