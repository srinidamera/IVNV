public with sharing class Hud9902ErrorLogTriggerHandler {
    public static void handleTrigger(List<HUD9902ErrorLog__c> newRecords, List<HUD9902ErrorLog__c> oldRecords, TriggerOperation operationType) {
        switch on operationType {
            when BEFORE_INSERT {
                handleBeforeInsert(newRecords);
            }
            when BEFORE_UPDATE {
                handleBeforeUpdate(newRecords, oldRecords);
            }
        }
    }

    private static void handleBeforeInsert(List<HUD9902ErrorLog__c> newRecords) {
        for (HUD9902ErrorLog__c errLog: newRecords) {
            if (String.isNotBlank(errLog.RecordID__c)) {
                errLog.RecordType__c = getSObjectLabelById(errLog.RecordID__c);
            }
        }
    }

    private static void handleBeforeUpdate(List<HUD9902ErrorLog__c> newRecords, List<HUD9902ErrorLog__c> oldRecords) {
        for (HUD9902ErrorLog__c errLog: newRecords) {
            if (String.isNotBlank(errLog.RecordID__c)) {
                errLog.RecordType__c = getSObjectLabelById(errLog.RecordID__c);
            }
        }
    }

    public static String getSObjectLabelById(String sObjectId) {
        if (String.isBlank(sObjectId)) {
            return '';
        }
        return Id.valueOf(sObjectId).getSObjectType().getDescribe().getLabel();
    }
}