/**
 * @desc: Trigger for the Intake__c object to handle automation bypass and delegate operations to the handler.
 */
trigger IntakeTrigger on Intake__c (before insert, after insert, before update, after update, after delete) {

 // If automation is bypassed for the current user's profile, exit the trigger.
    AutomationBypass__c settings = AutomationBypass__c.getInstance(UserInfo.getUserId());
    
  
    // If intake automation is bypassed for the current user's profile, exit the trigger.
    if (settings != null && settings.IntakeAutomationBypass__c) {
        return;
    }

    if (Trigger.isBefore) {
        if (Trigger.isInsert) {
            /**
             * @desc: Executes before inserting a new Intake__c record.
             * @param Trigger.new: List of new Intake__c records being inserted.
             */
            IntakeTriggerHandler.beforeInsert(Trigger.new);
        }
        if (Trigger.isUpdate) {
            /**
             * @desc: Executes before updating an existing Intake__c record.
             * @param Trigger.new: List of new Intake__c records being updated.
             * @param Trigger.oldMap: Map of old Intake__c records being updated.
             */
            // System.debug('Trigger.isUpdate');
            IntakeTriggerHandler.beforeUpdate(Trigger.new, Trigger.oldMap);
        }
    }

}