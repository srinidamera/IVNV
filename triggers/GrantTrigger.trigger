trigger GrantTrigger on Grant__c (before insert, before update) {
    GrantTriggerHandler.recomputeGrantFinancing((List<Grant__c>)Trigger.New, true);
}