/**
* @desc: Trigger for the CoApplicant__c to handle the delete and add logic
*/
trigger CoApplicantTrigger on CoApplicant__c (after insert, after delete, after update) {

  // If intake automation is bypassed for the current user's profile, exit the trigger.
    AutomationBypass__c settings = AutomationBypass__c.getInstance(UserInfo.getUserId());
    
    if (Trigger.isAfter) {
        if (Trigger.isInsert) {
            CoApplicantTriggerHandler.afterInsert(Trigger.new);
        }
        if (Trigger.isDelete) {
            CoApplicantTriggerHandler.afterDelete(Trigger.new, Trigger.oldMap);
        }
        if (Trigger.isUpdate) {
            CoApplicantTriggerHandler.afterUpdate(Trigger.new, Trigger.oldMap);
        }
    }
}