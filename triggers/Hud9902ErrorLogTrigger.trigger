trigger Hud9902ErrorLogTrigger on HUD9902ErrorLog__c (before insert, before update, after insert, after update, after delete) {
  Hud9902ErrorLogTriggerHandler.handleTrigger(Trigger.new, Trigger.old, Trigger.operationType);
}