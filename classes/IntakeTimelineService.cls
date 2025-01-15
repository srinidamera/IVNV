public class IntakeTimelineService extends ActivityTimelineService{
    /*
     * @description : To get Appointments for the corresponding client case
     */
    public override List<ActivityWrapper> getAppointments(Id recordId){
        Intake__c intake = [Select CaseType__r.HUDPurpose__c from Intake__c where id=:recordId LIMIT 1];
        List<ActivityWrapper> result = new List<ActivityWrapper>();
        for(Event evt : [Select id,Subject,sumoapp__AdditionalInfo__r.ClientCase__c,sumoapp__AdditionalInfo__r.ClientCase__r.ClientCaseName__c, StartDateTime,EndDateTime,sumoapp__AdditionalInfo__c,sumoapp__AdditionalInfo__r.sumoapp__Service__r.Name,
                         Who.name, DurationInMinutes, Outcome__c ,Purpose__c , sumoapp__AdditionalInfo__r.Notes__c, AppointmentDuration__c	,AppointmentStatus__c,HUDActivityType__c
                         from Event where whatId=:recordId AND RecordType.Name = 'Appointment']) {
            result.add(convertEventToWrapper(evt,null,intake?.CaseType__r?.HUDPurpose__c));
        }
        
        return result;
    }
    
    /*
     * @description : To get Counselor Notes for the corresponding client case
     */
    public override List<ActivityWrapper> getCounselorNotes(Id recordId){
        List<ActivityWrapper> counselingNotes = new List<ActivityWrapper>();
        /*for(CounselorNote__c note : [Select id,Name,StartDatetime__c,Subject__c,Notes__c,ClientCase__c,ClientCase__r.ClientCaseName__c,Contact__c from CounselorNote__c where ClientCase__c=:recordId WITH SECURITY_ENFORCED]) {
            counselingNotes.add(convertNoteToWrapper(note));
        }*/
        
        return counselingNotes;
    }
    
    /*
     * @description : To get Courses for the corresponding contact from client case
     */
    public override List<ActivityWrapper> getCourses(Id recordId){
        List<ActivityWrapper> result = new List<ActivityWrapper>();
       
        for(sumoapp__Attendee__c attendee : [Select id, sumoapp__SumoEvent__r.sumoapp__Parent__c,sumoapp__SumoEvent__c, sumoapp__SumoEvent__r.RecordType.DeveloperName, sumoapp__SumoEvent__r.sumoapp__Parent__r.sumoapp__EventName__c, sumoapp__SumoEvent__r.Name, sumoapp__EventName__c, sumoapp__StartDatetime__c, sumoapp__EndDatetime__c from sumoapp__Attendee__c where sumoapp__ContactRelation__c IN (Select PrimaryClient__c from Intake__c where Id=:recordId) WITH SECURITY_ENFORCED]) {
            if(attendee.sumoapp__SumoEvent__r.sumoapp__Parent__c==null && attendee.sumoapp__SumoEvent__r.RecordType.DeveloperName=='Course') {
                continue;
            }
            result.add(convertCourseToWrapper(attendee));
        }
        
        return result;
    }
}