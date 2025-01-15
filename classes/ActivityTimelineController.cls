/*
* @description    Controller class containing methods for Activity Component
* @date           2024-06-01
* @group          Activity Timeline
*/
public abstract class ActivityTimelineController {
    /*
	* @description : To get related events 
	*/ 
    @AuraEnabled
    public static List<ActivityTimelineService.ResultWrapper> getEvents(Id recordId) {
        List<ActivityTimelineService.ResultWrapper> result = new List<ActivityTimelineService.ResultWrapper>();
        String sObjName = recordId.getSObjectType().getDescribe().getName();
        ActivityTimelineService service = null;
        if(sObjName=='Contact'){
            service = new ContactTimelineService();
        } else if(sObjName=='ClientCase__c') {
            service = new ClientCaseTimelineService();
        } else if(sObjName=='Intake__c') {
            service = new IntakeTimelineService();
        }
        if(service!=null){
            result =  service.getAllEvents(recordId);
        }
        System.debug('Result ::: '+result);
        return result;
    }
    
    /*
	* @description : To get related Participants for a given event
	*/ 
    @AuraEnabled(cacheable=true)
    public static List<String> getParticipants(Id eventId) {
        List<String> participantNames=new List<String>();
        for(EventRelation elt : [Select Relation.Name from EventRelation where EventId=:eventId AND Relation.Type='Contact']) {
            participantNames.add(elt.Relation.Name);
        }
        return participantNames;
    }
    
    /*
	* @description : To update Appointment Notes
	*/ 
    @AuraEnabled
    public static void updateAppointmentNotes(String eventId, String funder, String outcome, String purpose, String appointmentStatus, Integer durationInMin, String notes, String hudActivity) {
        if(String.isNotBlank(eventId)){
            List<Event> evtList = [select Id, DurationInMinutes,who.Name, WhatId,AppointmentStatus__c,what.Type,HUDActivityType__c, sumoapp__AdditionalInfo__c from Event where Id =:eventId];
            id RecordTypeId = [Select Id from Recordtype where sObjectType='Task' AND DeveloperName='Reminder']?.Id;
            if(evtList.size() > 0){
                Boolean isAppointmentAttended = !String.isBlank(appointmentStatus) && (evtList[0].AppointmentStatus__c != appointmentStatus) && (appointmentStatus=='Attended');
                System.debug(' Boolean Value set to : '+isAppointmentAttended+' Appointment Status ::: '+appointmentStatus);
                
                if(durationInMin != NULL){
                    evtList[0].AppointmentDuration__c = durationInMin;
                }
                if(appointmentStatus=='No Show') {
                    evtList[0].AppointmentDuration__c = 0;
                }
                evtList[0].Outcome__c = outcome;
                evtList[0].purpose__c = purpose;
                evtList[0].AppointmentStatus__c = appointmentStatus;
                
                evtList[0].HUDActivityType__c = hudActivity;
                
                System.debug('Event :: '+ evtList[0]);
                update evtList; 
                
                if(isAppointmentAttended) {
                    createReminders(new List<Id>{evtList[0].WhatId}, evtList[0].who.Name, RecordTypeId); 
                }
                
                List<sumoapp__AdditionalInfo__c > additionalInfo = [select Id, Notes__c from sumoapp__AdditionalInfo__c  where Id =:evtList[0].sumoapp__AdditionalInfo__c];
                
                if(additionalInfo.size() > 0){
                    additionalInfo[0].Notes__c = notes;
                    if(!Test.isRunningTest()){
                        update additionalInfo;
                    }
                }
            }
        }
    }
    
    /*
	* @description : To get related events 
	*/ 
    @AuraEnabled
    public static ActivityTimelineService.ActivityWrapper getEventWrapper(Id eventId) {
        if(!String.isEmpty(eventId)){
            Event evt = [Select id, purpose__c,Outcome__c,AppointmentDuration__c, sumoapp__AdditionalInfo__r.Notes__c,AppointmentStatus__c FROM Event where Id = :eventId];
            ActivityTimelineService.ActivityWrapper wrap = new ActivityTimelineService.ActivityWrapper();
            wrap.durationInMin = Integer.valueOf(evt.AppointmentDuration__c);
            wrap.notes = evt.sumoapp__AdditionalInfo__r.Notes__c;
            wrap.purpose = evt.purpose__c;
            wrap.outcome = evt.Outcome__c;
            wrap.participants = getParticipants(eventId);
            wrap.appointmentStatus = evt.AppointmentStatus__c;
            return wrap;
        }
        return null;
    }
    
    @AuraEnabled(cacheable=true)
    public static Id getAppointmentRecordTypeId() {
        return [Select Id, Name from RecordType where SobjectType='Event' And Name='Appointment']?.Id;
    }
    
    /*
	* @description : To create reminders
	*/
    public static void createReminders(List<Id> objectIds, String name, Id recordTypeId) {
         
        List<Task> taskstoUpdate = new List<Task>();
        for(Id recId : objectIds) {
            taskstoUpdate.addAll(createReminders(recId, name,recordTypeId));
        }
        insert taskstoUpdate;
    }
    
    public static List<Task> createReminders(Id objectId, String name, Id recordTypeId) {
        List<Task> existingTasks = [SELECT Id FROM Task 
                                WHERE WhatId = :objectId 
                                AND Subject IN ('30DayFollowUp', '60DayFollowUp', '90DayFollowUp')];
    	if (!existingTasks.isEmpty()) {
        	delete existingTasks;
    	}
        List<Task> reminderList = new List<Task>();
        Task tsk = new Task();
        tsk.OwnerId = UserInfo.getUserId();
        tsk.Subject='30DayFollowUp';
        tsk.Priority='Medium';
        tsk.WhatId=objectId;
        tsk.IsReminderSet=true;
        tsk.ReminderDateTime = System.today().addDays(30);
        if(recordTypeId!=null) {
            tsk.RecordTypeId = recordTypeId;
        }
        tsk.Description='Reminder regarding the upcoming 30-day follow-up for '+Name+'. Kindly review the client case and take appropriate actions.';
        
        reminderList.add(tsk);
        
        Task tsk1 = new Task();
        tsk1.OwnerId = UserInfo.getUserId();
        tsk1.Subject='60DayFollowUp';
        tsk1.Priority='Medium';
        tsk1.WhatId=objectId;
        tsk1.IsReminderSet=true;
        tsk1.ReminderDateTime = System.today().addDays(60);
        tsk1.Description='Reminder regarding the upcoming 60-day follow-up for '+Name+'.  Kindly review the client case and take appropriate actions.';
        if(recordTypeId!=null) {
            tsk1.RecordTypeId = recordTypeId;
        }
        reminderList.add(tsk1);
        
        Task task90 = new Task();
        task90.OwnerId = UserInfo.getUserId();
        task90.Subject='90DayFollowUp';
        task90.Priority='Medium';
        task90.WhatId=objectId;
        task90.IsReminderSet=true;
        task90.ReminderDateTime = System.today().addDays(90);
        task90.Description='Reminder regarding the upcoming 90-day follow-up for '+Name+'.  Kindly review the client case and take appropriate actions.';
        if(recordTypeId!=null) {
            task90.RecordTypeId = recordTypeId;
        }
        reminderList.add(task90);
        
        return reminderList;
    }

    /**
* @description       : Method to check that current logged in user is IntakeStaff or not.
**/
    @AuraEnabled
    public static Boolean isIntakeStaffUser(){
        return FeatureManagement.checkPermission('IntakeStaff');
    }
}