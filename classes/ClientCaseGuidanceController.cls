/**
* @description       : Class for Client Case Guidance.
**/
public with sharing class ClientCaseGuidanceController {
    /**
* @description       : Method to get all the picklist field values.
**/
    @AuraEnabled(cacheable=true)
    public static List<Utility.PicklistOption> getStatusPicklist() {
        string NWC2NameSpace = Utility.getNwc2NameSpace();
        String objectApiName = NWC2NameSpace+'ClientCaseTask__c';
        String fieldApiName = NWC2NameSpace+'Status__c';
        return SObjectUtility.getPicklistLabelVal(objectApiName, fieldApiName);
    }
    
    /**
* @description       : Method to fetch all related client case tasks sorted by display order.
**/
    @AuraEnabled(cacheable=true)
    public static List<ClientCaseTask__c> getClientCaseTasks(
        String clientCaseId
    ) {
        return [
            SELECT Id, StepName__c, Status__c, StepDetails__c, Comments__c
            FROM ClientCaseTask__c
            WHERE ClientCase__c = :clientCaseId
            OR Intake__c = :clientCaseId
            ORDER BY Display_Order__c
        ];
    }
    
    /**
* @description       : Method to update client case task status and comment.
**/
    @AuraEnabled
    public static void updateClientCaseTask(
        String recordId,
        String status,
        String comments
    ) {
        try {
            Boolean hasUpdate = false;
            ClientCaseTask__c taskToUpdate = new ClientCaseTask__c();
            taskToUpdate.Id = recordId;
            if (!String.isEmpty(status)) {
                taskToUpdate.Status__c = status;
                hasUpdate = true;
            }
            if (!String.isEmpty(comments)) {
                taskToUpdate.Comments__c = comments;
                hasUpdate = true;
            }
            if (hasUpdate) {
                update taskToUpdate;
            }
        } catch (Exception e) {
            LoggerClass.log(e, recordId);
        }
    }
    
    /**
* @description       : Method to check that current logged in user is IntakeStaff or not.
**/
    @AuraEnabled
    public static Boolean isIntakeStaffUser(){
        return FeatureManagement.checkPermission('IntakeStaff');
    } 
}