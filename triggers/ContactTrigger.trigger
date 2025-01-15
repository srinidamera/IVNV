/**
* @desc: Trigger for the Contact object to handle automation bypass and delegate operations to the handler.
*/
trigger ContactTrigger on Contact (after insert,before insert, after update, before update, after delete) {
    
    // If intake automation is bypassed for the current user's profile, exit the trigger.
    AutomationBypass__c settings = AutomationBypass__c.getInstance(UserInfo.getUserId());
    
    if (settings != null) {
        if (settings.ContactAutomationBypass__c) {
            return;
        }
    }
    
    if(Trigger.isBefore){
        if (Trigger.isInsert) {
            ContactTriggerHandler.beforeInsert(Trigger.new);
        }
        if (Trigger.isUpdate) {
            ContactTriggerHandler.beforeUpdate(Trigger.new, Trigger.oldMap);
        }
    }
    
    if (Trigger.isAfter) {
        
        if (Trigger.isInsert) {
            ContactTriggerHandler.afterInsert(Trigger.new);
        }
        if (Trigger.isUpdate) {
            if(ContactTriggerHandler.flag) {
                ContactTriggerHandler.afterUpdate(Trigger.new, Trigger.oldMap);
                ContactTriggerHandler.flag = false;
            }
        }
    }
}