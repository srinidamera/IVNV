trigger AccountTrigger on Account (before insert) {
    // If automation is bypassed for the current user's profile, exit the trigger.
    AutomationBypass__c settings = AutomationBypass__c.getInstance(UserInfo.getUserId());
    
  
    // If intake automation is bypassed for the current user's profile, exit the trigger.
    if (settings != null && settings.AccountAutomationBypass__c) {
        return;
    }
    AccountTriggerHandler.populateUniqueClientId((List<Account>)Trigger.New);
}