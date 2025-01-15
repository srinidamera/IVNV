/**
* @desc: Trigger for the sumoapp__AdditionalInfo__c object to handle automation bypass and delegate operations to the handler.
*/
trigger CourseTrigger on sumoapp__AdditionalInfo__c (before insert, after insert, after update) {
    
   // If automation is bypassed for the current user's profile, exit the trigger.
    AutomationBypass__c settings = AutomationBypass__c.getInstance(UserInfo.getUserId());
    
    // If course automation is bypassed for the current user's profile, exit the trigger.
    if (settings != null && settings.CourseAutomationBypass__c) {
        return;
    }
    
    if (Trigger.isBefore && Trigger.isInsert) {
        CourseTriggerHandler.beforeInsert(Trigger.new);
    }
    
    if (Trigger.isAfter) {
        if (Trigger.isInsert) {
            /**
             * @desc: Executes after inserting a new sumoapp__AdditionalInfo__c record.
             * @param Trigger.new: List of new sumoapp__AdditionalInfo__c records being inserted.
             */
            CourseTriggerHandler.afterInsert(Trigger.new);
        }
        
        if (Trigger.isUpdate) {
            /**
             * @desc: Executes after updating an existing sumoapp__AdditionalInfo__c record.
             * @param Trigger.new: List of new sumoapp__AdditionalInfo__c records being updated.
             * @param Trigger.oldMap: Map of old sumoapp__AdditionalInfo__c records being updated.
             */
            CourseTriggerHandler.afterUpdate(Trigger.new, Trigger.oldMap);
        }
    }
    
}