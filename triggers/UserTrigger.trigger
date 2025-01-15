trigger UserTrigger on User (after insert, before insert, before update) {
    
    
    // If automation is bypassed for the current user's profile, exit the trigger.
    AutomationBypass__c settings = AutomationBypass__c.getInstance(UserInfo.getUserId());
    
  
    // If intake automation is bypassed for the current user's profile, exit the trigger.
    if (settings != null && settings.UserAutomationBypass__c) {
        return;
    }
    
    if(Trigger.isAfter) {
        if (Trigger.isInsert) {
            UserTriggerHandler.afterInsert(Trigger.new);
        }
    } else{
        if(Trigger.IsInsert){
            UserTriggerHandler.beforeInsert(Trigger.new);
        }
        if(Trigger.IsUpdate){
            UserTriggerHandler.beforeUpdate(Trigger.new);
        }
    }
}