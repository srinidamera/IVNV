/**
 * @desc: Trigger for the ClientCase__c object to handle automation bypass and delegate operations to the handler.
 */
trigger ClientCaseTrigger on ClientCase__c (before insert, after insert, before update, after update, after delete) {
    
    // If automation is bypassed for the current user's profile, exit the trigger.
    AutomationBypass__c settings = AutomationBypass__c.getInstance(UserInfo.getUserId());

    // If client case automation is bypassed for the current user's profile, exit the trigger.
    if (settings != null && settings.ClientCaseAutomationBypass__c) {
        return;
    }

    if (Trigger.isBefore) {
        if (Trigger.isInsert) {
            /**
             * @desc: Executes before inserting a new ClientCase__c record.
             * @param Trigger.new: List of new ClientCase__c records being inserted.
             */
            ClientCaseTriggerHandler.beforeInsert(Trigger.new);
        }
        if (Trigger.isUpdate) {
            System.debug('Trigger.isUpdate');
            /**
             * @desc: Executes before updating an existing ClientCase__c record.
             * @param Trigger.new: List of new ClientCase__c records being updated.
             * @param Trigger.oldMap:
            /**
             * @desc: Executes before updating an existing ClientCase__c record.
             * @param Trigger.new: List of new ClientCase__c records being updated.
             * @param Trigger.oldMap: Map of old ClientCase__c records being updated.
             */
            ClientCaseTriggerHandler.beforeUpdate(Trigger.new, Trigger.oldMap);
        }
    }

}