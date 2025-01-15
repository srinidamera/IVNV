public class ContactTimelineService extends ActivityTimelineService{
	
    /*
     * @description : To get Appointments for the corresponding Contact Record
     */
    public override List<ActivityWrapper> getAppointments(Id recordId){
        
        List<ActivityWrapper> result = new List<ActivityWrapper>();
        List<Id> eventIDs = new List<Id>();
        for(EventRelation elt : [Select EventId from EventRelation where RelationId=:recordId AND Relation.Type='Contact']) {
            eventIDs.add(elt.EventId);
        }
        Set<ID> clientCaseIds= new Set<Id>();
        Set<ID> intakeIds = new Set<ID>();
        Map<id, Event> eventMap = new Map<id,Event>();
        for(Event evt : [Select id,what.Type,Subject,Purpose__c,AppointmentStatus__c,Outcome__c,Who.Name,AppointmentDuration__c, StartDateTime,EndDateTime,sumoapp__AdditionalInfo__c,sumoapp__AdditionalInfo__r.Notes__c,sumoapp__AdditionalInfo__r.sumoapp__Service__r.Name, HUDActivityType__c  from Event where ID in :eventIDs AND RecordType.Name = 'Appointment' WITH USER_MODE]) {
            String NWC2NameSpace = Utility.getNwc2NameSpace();
            if(evt.what.Type!=null && NWC2NameSpace+'ClientCase__c'==evt.what.Type) {
           		clientCaseIds.add(evt.WhatId);
            } else if(evt.what.Type!=null && NWC2NameSpace+'Intake__c'==evt.what.Type) {
                intakeIds.add(evt.WhatId);
            }
            eventMap.put(evt.id, evt);
            //result.add(convertEventToWrapper(evt));
        }
        
        Map<Id,CLientCase__c> clientCaseMap = new Map<Id,ClientCase__c>();
        Map<Id,Intake__c> intakeMap = new Map<Id,Intake__c>();
        if(!eventMap.isEmpty()) {
            clientCaseMap = new Map<Id, ClientCase__c>([Select Id,ClientCaseName__c,Purpose__c,CaseType__r.HUDPurpose__c from ClientCase__c where id in :clientCaseIds]);
            intakeMap = new Map<Id,Intake__c>([Select Id,CaseType__r.HUDPurpose__c from Intake__c where id in :intakeIds]);
        }
        
        for(Id eventId : eventMap.keySet()) {
            String Purpose;
           Event evt = eventMap.get(eventId);
            if(clientCaseMap.get(evt.WhatId)!=null) {
                Purpose = clientCaseMap.get(evt.WhatId).CaseType__r?.HUDPurpose__c;
            } else if(intakeMap.get(evt.whatId)!=null) {
                Purpose = intakeMap.get(evt.WhatId).CaseType__r?.HUDPurpose__c;
            }
           result.add(convertEventToWrapper(evt,clientCaseMap.get(evt.WhatId),Purpose)); 
        }
        
        
        
        return result;
    }
    
    /*
     * @description : To get Courses for the corresponding Contact Record
     */
    public override List<ActivityWrapper> getCourses(Id recordId){
        List<ActivityWrapper> result = new List<ActivityWrapper>();
        for(sumoapp__Attendee__c attendee : [Select id,sumoapp__SumoEvent__c,sumoapp__SumoEvent__r.RecordType.DeveloperName,sumoapp__SumoEvent__r.sumoapp__Parent__c,sumoapp__SumoEvent__r.sumoapp__Parent__r.sumoapp__EventName__c,sumoapp__SumoEvent__r.Name,sumoapp__EventName__c,sumoapp__StartDatetime__c,sumoapp__EndDatetime__c from sumoapp__Attendee__c where sumoapp__ContactRelation__c=:recordId WITH SECURITY_ENFORCED]) {
            if((attendee.sumoapp__SumoEvent__r.sumoapp__Parent__c==null && attendee.sumoapp__SumoEvent__r.RecordType.DeveloperName=='Course') ) {
                continue;
            }
            result.add(convertCourseToWrapper(attendee));
        }
        return result;
    }
    
    /*
     * @description : To get Counselor Notes  for the corresponding Contact Record
     */
    public override List<ActivityWrapper> getCounselorNotes(Id recordId){
        List<ActivityWrapper> counselingNotes = new List<ActivityWrapper>();
        for(CounselorNote__c note : [Select id,Name,StartDatetime__c,Subject__c,Notes__c,ClientCase__c,ClientCase__r.ClientCaseName__c,Contact__c from CounselorNote__c where Contact__c=:recordId WITH SECURITY_ENFORCED]) {
            counselingNotes.add(convertNoteToWrapper(note));
        }
        
        return counselingNotes;
    }

}