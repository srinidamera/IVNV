/**
* @desc: Controller for intakeClientCase LWC component.
* Test class: IntakeCaseControllerTest
*/
public with sharing class IntakeCaseController {
    public static final String COURSE_RECORDTYPE_NAME='Course';
    /**
* @desc: Method to retrieve client cases related to contact Ids provided as an input.
*/
    @AuraEnabled(cacheable = true)
    public static List<ClientCase__c> retrieveClientCase(List<String> contactIds){
        List<String> newConList = new List<String>();
        for(String conId : contactIds){
            if(string.IsNotBlank(conId)){
                newConList.add(String.escapeSingleQuotes(conId));
            }
        }
        List<ClientCase__c> clientCase = [SELECT Id, ClientCaseName__c, OwnerId, Owner.Name, CaseType__c, CaseType__r.Name, ClientCaseStatus__c, LastModifiedDate FROM ClientCase__c Where PrimaryClient__c IN:newConList WITH SECURITY_ENFORCED];
        return clientCase;
    }
    
    
    @AuraEnabled(cacheable = true)
    public static List<Intake__c> retrieveIntakeRequests(List<String> contactIds){
        List<String> newConList = new List<String>();
        for(String conId : contactIds){
            if(string.IsNotBlank(conId)){
                newConList.add(String.escapeSingleQuotes(conId));
            }
            
        }
        List<Intake__c> clientCase = [SELECT Id, IntakeRequestName__c, OwnerId, Owner.Name, CaseType__c, CaseType__r.Name, Status__c, LastModifiedDate FROM Intake__c Where PrimaryClient__c IN:newConList WITH SECURITY_ENFORCED];
        return clientCase;
    }
    
    @AuraEnabled(cacheable=true)
    public static List<CourseWrapper> getCourses(List<String> contactIds) {
        List<CourseWrapper> courses = new List<CourseWrapper>();
        List<Id> parentIds = new List<Id>();
        Map<id,sumoapp__Attendee__c> attendeeToEventMap = new Map<id,sumoapp__Attendee__c>();
        Map<Id, CourseWrapper> parentWrapperMap = new Map<id, CourseWrapper>();
        List<sumoapp__Attendee__c> attendeeList = new List<sumoapp__Attendee__c>([Select sumoapp__SumoEvent__r.sumoapp__Parent__c,Attendance_Status__c,Notes__c,sumoapp__Status__c,sumoapp__ContactRelation__r.Name,id,sumoapp__SumoEvent__c,sumoapp__SumoEvent__r.sumoapp__LocationType__c,sumoapp__SumoEvent__r.RecordType.DeveloperName,sumoapp__SumoEvent__r.sumoapp__Parent__r.sumoapp__EventName__c,sumoapp__SumoEvent__r.Name,sumoapp__EventName__c,sumoapp__StartDatetime__c,sumoapp__SumoEvent__r.Facilitator__r.Name from sumoapp__Attendee__c where sumoapp__ContactRelation__c in :contactIds order by sumoapp__StartDatetime__c]);
        Map<Id, sumoapp__Attendee__c> parentAttendanceStatusMap = getParentAttendanceStatusMap(attendeeList);
        for(sumoapp__Attendee__c attendee : attendeeList) {
            attendeeToEventMap.put(attendee.sumoapp__SumoEvent__c, attendee);
            if(attendee.sumoapp__SumoEvent__r.sumoapp__Parent__c==null && attendee.sumoapp__SumoEvent__r.RecordType.DeveloperName=='Event') {
                courses.add(storeAttendee(attendee));   
            } else if(attendee.sumoapp__SumoEvent__r.sumoapp__Parent__c!=null && attendee.sumoapp__SumoEvent__r.RecordType.DeveloperName=='Course') {
                if(parentWrapperMap.containsKey(attendee.sumoapp__SumoEvent__r.sumoapp__Parent__c)) {
                    CourseWrapper parentWrapper = parentWrapperMap.get(attendee.sumoapp__SumoEvent__r.sumoapp__Parent__c);
                    parentWrapper.children.add(storeAttendee(attendee));
                    if(attendee.sumoapp__StartDatetime__c!=null && parentWrapper.startDate>attendee.sumoapp__StartDatetime__c) {
                        parentWrapper.startDate = attendee.sumoapp__StartDatetime__c;
                    }
                } else {
                    CourseWrapper parentWrapper = new CourseWrapper();
                    parentWrapper.courseName = attendee.sumoapp__SumoEvent__r.sumoapp__Parent__r.sumoapp__EventName__c;
                    parentWrapper.startDate = attendee.sumoapp__StartDatetime__c;
                    parentWrapper.children = new list<CourseWrapper>{storeAttendee(attendee)};
                    parentWrapper.courseLink = '/'+attendee.sumoapp__SumoEvent__r.sumoapp__Parent__c;
                    parentWrapper.recordId = attendee.sumoapp__SumoEvent__r.sumoapp__Parent__c;
                    parentWrapper.status = parentAttendanceStatusMap.get(attendee.sumoapp__SumoEvent__r.sumoapp__Parent__c)?.Attendance_Status__c;
                    parentWrapper.notes=parentAttendanceStatusMap.get(attendee.sumoapp__SumoEvent__r.sumoapp__Parent__c)?.NOtes__c;
                    courses.add(parentWrapper);
                    parentWrapperMap.put(attendee.sumoapp__SumoEvent__r.sumoapp__Parent__c, parentWrapper);
                }
            }
            
        }
        
        System.debug('Key Set : '+parentWrapperMap.keySet());
        return courses;
    }
    
    public static CourseWrapper storeAttendee(sumoapp__Attendee__c attendee) {
        String recordTypeName = attendee?.sumoapp__SumoEvent__r?.RecordType?.DeveloperName;
        String relatedAdditionalName=attendee.sumoapp__EventName__c;
        CourseWrapper wrapper = new CourseWrapper();
        
        wrapper.courseName= (recordTypeName==COURSE_RECORDTYPE_NAME) ? attendee?.sumoapp__SumoEvent__r?.sumoapp__Parent__r?.sumoapp__EventName__c : relatedAdditionalName;
        if(String.isEmpty(wrapper.courseName)){
            wrapper.courseName = relatedAdditionalName;
        }
        wrapper.startDate = attendee.sumoapp__StartDatetime__c;
        wrapper.facilitator = attendee.sumoapp__SumoEvent__r?.Facilitator__r?.Name;
        wrapper.DeliveryType = attendee.sumoapp__SumoEvent__r?.sumoapp__LocationType__c;
        wrapper.courseLink = '/'+attendee.sumoapp__SumoEvent__c;
        wrapper.recordId = attendee.sumoapp__SumoEvent__c;
        wrapper.status = attendee.Attendance_Status__c;  //attendee.sumoapp__Status__c;
        wrapper.notes=attendee.Notes__c;
        return wrapper;
    }
    
    public static Map<ID, sumoapp__Attendee__c> getParentAttendanceStatusMap(List<sumoapp__Attendee__c> attendeeList) {
        Map<ID, sumoapp__Attendee__c> parentAttendeeMap = new Map<Id, sumoapp__Attendee__c>();
        for(sumoapp__Attendee__c attendee : attendeeList) {
            if(attendee.sumoapp__SumoEvent__r.sumoapp__Parent__c==null && attendee.sumoapp__SumoEvent__r.RecordType.DeveloperName=='Course') {
                parentAttendeeMap.put(attendee.sumoapp__SumoEvent__c, attendee);
            }
        }
        
        return parentAttendeeMap;
    }
    
    public class CourseWrapper{
        @AuraEnabled
        public String courseName{get;set;}
        @AuraENabled
        public DateTime startDate{get;set;}
        @AuraEnabled
        public String status{get;set;}
        @AuraEnabled
        public String notes{get;set;}
        @AuraEnabled
        public String facilitator{get;set;}
        @AuraENabled
        public String deliveryType{get;set;}
        @AuraEnabled
        public String courseLink{get;set;}
        @AuraEnabled
        public String recordId{get;set;}
        
        @AuraEnabled
        public List<CourseWrapper> children{get;set;}
    }
}