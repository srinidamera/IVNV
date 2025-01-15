public abstract class ActivityTimelineService {
    
    public static final String UPCOMING_EVENTS_KEY = '999999';
    public static final String COURSE_RECORDTYPE_NAME='Course';
    
    /*
     * @description : To fetch all the events for a given record
     */
    public List<ResultWrapper> getAllEvents(Id recordId){
        Map<String, List<ActivityWrapper>> eventGroupBYMonth = new Map<String, List<ActivityWrapper>>();
        List<ActivityWrapper> result = new List<ActivityWrapper>();
        result.addAll(getAppointments(recordId));
        result.addAll(getCourses(recordId));
        result.addAll(getCounselorNotes(recordId));
        result.sort(new ResultWrapperComparator());
        
        for(ActivityWrapper wrap : result) {
            if(wrap.eventDate!=null) {
                String monthName = wrap.eventDate > System.now() ? UPCOMING_EVENTS_KEY : wrap.eventDate.format('yyyyMM');
                if(eventGroupBYMonth.containsKey(monthName)) {
                    List<ActivityWrapper> events = eventGroupBYMonth.get(monthName);
                    events.add(wrap);
                    eventGroupBYMonth.put(monthName, events);
                } else {
                    List<ActivityWrapper> events = new List<ActivityWrapper>();
                    events.add(wrap);
                    eventGroupBYMonth.put(monthName, events);
                }
                
            }
            
        } 
        
        //transform Map to ResultWrapper
        List<ResultWrapper> eventList = new List<ResultWrapper>();
        for(String key : eventGroupBYMonth.keySet()) {
            List<ActivityWrapper> events = eventGroupBYMonth.get(key);
            
            String monthName = key==UPCOMING_EVENTS_KEY ? 'Upcoming Events' : events.get(0).eventDate.format('MMMMM yyyy');
            ResultWrapper wrapper = new ResultWrapper();
            wrapper.title=key;
            wrapper.monthName=monthName;
            wrapper.eventList = events;
            eventList.add(wrapper);
        }
        eventList.sort(new EventWrapperComparator());
        for(ResultWrapper w : eventList) {
            System.debug(w.monthName);
            System.debug(w);
        }
        return eventList;
        
    }
    
    public abstract List<ActivityWrapper> getAppointments(Id recordId);
    
    public abstract List<ActivityWrapper> getCourses(Id recordId);
    
    public abstract List<ActivityWrapper> getCounselorNotes(Id recordId);
    
    /*
     * @description : To convent instance of an Event to ActivityWrapper
     */
    protected ActivityWrapper convertEventToWrapper(Event evt, ClientCase__c cc, String Purpose) {
        ActivityWrapper wrap = new ActivityWrapper();
        wrap.title=evt.Subject;
        wrap.type='Appointment';
        wrap.isAppointment=true;
        wrap.eventDate=evt.StartDateTime;
        wrap.recordId=evt.Id;
        wrap.relatedId=evt.sumoapp__AdditionalInfo__c;
        if(evt.purpose__c!=null) {
            wrap.purpose = evt.purpose__c;
        } else {
            wrap.purpose = Purpose;
        }
        wrap.caseTypePurposeApiValue = Purpose;
        Schema.DescribeFieldResult field = Event.purpose__c.getDescribe();
        for (Schema.PicklistEntry f : field.getPicklistValues()){
            if(f.getValue() == Purpose){
                wrap.caseTypePurposeLabel = f.getLabel();
                break;
            }
        }
        wrap.outcome = evt.Outcome__c;
        wrap.appointmentStatus = evt.AppointmentStatus__c;
        wrap.hudActivity=evt.HUDActivityType__c;
        
        
        if(evt.StartDateTime != null && evt.EndDateTime != null){
            wrap.notesDurationDate = evt.StartDateTime.format('MMM dd, hh:mm a')+' - '+evt.EndDateTime.format('hh:mm a');
        }
        if(!Test.isRunningTest()){
            wrap.contactName=evt.Who.Name;
        }
        if(evt.AppointmentDuration__c!=null) {
            wrap.durationInMin=Integer.valueOf(evt.AppointmentDuration__c);
        } else if(evt.StartDateTime != null && evt.EndDateTime != null){
            long start = evt.StartDateTime.getTime();
            long endTime = evt.EndDateTime.getTime();
            wrap.durationInMin = Integer.valueOf((endTime - start)/(1000*60));
        }
        
        
        wrap.notes=evt.sumoapp__AdditionalInfo__r.Notes__c;
        
        if(cc!=null) {
            ClientCaseWrapper clientCase = new ClientCaseWrapper();
            clientCase.recordId=cc.Id;
            clientCase.name = cc.ClientCaseName__c;
            //wrap.purpose=cc.Purpose__c;
            wrap.clientCase = clientCase;
        }
        return wrap;
    }
    
    /*
     * @description : To convent instance of a Course to ActivityWrapper
     */
    protected ActivityWrapper convertCourseToWrapper(sumoapp__Attendee__c attendee) {
        String recordTypeName = attendee?.sumoapp__SumoEvent__r?.RecordType?.DeveloperName;
        String relatedAdditionalName=attendee.sumoapp__EventName__c;
        ActivityWrapper wrap = new ActivityWrapper();
        wrap.title= (recordTypeName==COURSE_RECORDTYPE_NAME) ? attendee?.sumoapp__SumoEvent__r?.sumoapp__Parent__r?.sumoapp__EventName__c : relatedAdditionalName;
        wrap.description=relatedAdditionalName;
        wrap.type='Course';
        wrap.isCourse=true;
        wrap.eventDate=attendee.sumoapp__StartDatetime__c;
        wrap.recordId=attendee.Id;
        wrap.relatedId=attendee.sumoapp__SumoEvent__c;
        return wrap;
    }
    
    /*
     * @description : To convent instance of a Note to ActivityWrapper
     */
    protected ActivityWrapper convertNoteToWrapper(CounselorNote__c note) {
        ActivityWrapper wrapper = new ActivityWrapper();
        wrapper.title=note.Subject__c;
        wrapper.type='Note';
        wrapper.isNote=true;
        wrapper.eventDate = note.StartDatetime__c;
        wrapper.recordId=note.id;
        if(note.ClientCase__c!=null) {
            ClientCaseWrapper clientCase = new ClientCaseWrapper();
            clientCase.recordId=note.ClientCase__c;
            clientCase.name = note.ClientCase__r.ClientCaseName__c;
            wrapper.clientCase = clientCase;
        }
        return wrapper;
    }
    
    public class ClientCaseWrapper{
        @AuraENabled public String name{get;set;}
        @AuraEnabled public String recordId{get;set;}
    }
    
    public class ActivityWrapper{
        @AuraEnabled public String title{get;set;}
        @AuraEnabled public String description{get;set;}
        @AuraEnabled public String type{get;set;}
        @AuraEnabled public string recordId{get;set;}
        @AuraEnabled public string relatedId{get;set;}
        @AuraEnabled public DateTime eventDate{get;set;}
        @AuraEnabled public Boolean isCourse{get;set;}
        @AuraEnabled public Boolean isNote{get;set;}
        @AuraEnabled public Boolean isAppointment{get;set;}
        @AuraEnabled public String contactName{get;set;}
        @AuraEnabled public String funder{get;set;}
        @AuraEnabled public String outcome{get;set;}
        @AuraEnabled public String purpose{get;set;}
        @AuraEnabled public Integer durationInMin{get;set;}
        @AuraEnabled public String notesDurationDate{get;set;}
        @AuraEnabled public string notes{get;set;}
        @AuraEnabled public string hudActivity{get;set;}        
        @AuraEnabled public String appointmentStatus{get;set;}
        @AuraEnabled public List<String> participants{get;set;}
        @AuraEnabled public String caseTypePurposeLabel{get;set;}
        @AuraEnabled public String caseTypePurposeApiValue{get;set;}
        
        @AuraEnabled public String getDisplayDate() {
            return eventDate!=null ? eventDate.format('h:mm a | MM/dd/yyyy') : '';
        }
        @AuraEnabled public ClientCaseWrapper clientCase{get;set;}
        public ActivityWrapper() {
            this.isCourse = false;
            this.isNote = false;
            this.isAppointment = false;
        }
    }
    
    public class ResultWrapper {
        @AuraEnabled public String title{get;set;}
        @AuraEnabled public String monthName{get;set;}
        @AuraEnabled public List<ActivityWrapper> eventList{get;set;}
    }
    
    
    public class ResultWrapperComparator implements Comparator<ActivityWrapper> {
        
        public Integer compare(ActivityWrapper wrap1, ActivityWrapper wrap2) {
            if(wrap1.eventDate==wrap2.eventDate) {
                return 0;
            } else if(wrap1.eventDate < wrap2.eventDate) {
                return 1;
            }
            else {
                return -1;
            }
        }
    }
    
    public class EventWrapperComparator implements Comparator<ResultWrapper> {
        public Integer compare(ResultWrapper wrap1, ResultWrapper wrap2) {
            return wrap2.title.compareTo(wrap1.title);
        }
    }
    
}