public class CourseCompletionCertificateController {
    public String agencyName { get; set; }
    public String courseName { get; set; }
    public String completionDate { get; set; }
    public String participantName {get;set;}
    public String hudCounselourId {get;set;}
    public String certificateNumber {get;set;}
    public List<String> contactIds {get;set;}

    public CourseCompletionCertificateController() {
        String recIds = ApexPages.currentPage().getParameters().get('Ids');
        String attendeeId = ApexPages.currentPage().getParameters().get('attendeeId');
        
        if(recIds != NULL){
            participantName = '';
            List<String> ids = recIds.split(';;;;');
            contactIds = ids;
            List<Contact> conRec = [Select Id, Name from Contact where Id  IN :ids];
            for(Contact con : conRec){
                participantName += con.Name + ', ';
            }
            participantName = participantName.removeEndIgnoreCase(', ');
        }
        
        List<AgencyProfile__c> agencyRec = [Select id, name from AgencyProfile__c limit 1];
        
        if(agencyRec.size() > 0){
            agencyName = agencyRec[0].Name;
        }
        
        List<sumoapp__Attendee__c> attendeeRec = [Select Id, CertificateNumber__c, sumoapp__SumoEvent__c, sumoapp__SumoEvent__r.sumoapp__RecurringEndDate__c, sumoapp__SumoEvent__r.sumoapp__EndDatetime__c, sumoapp__SumoEvent__r.sumoapp__EventName__c, sumoapp__SumoEvent__r.Facilitator__r.CounselorHUDID__c from sumoapp__Attendee__c where Id =:attendeeId limit 1];
        
        if(attendeeRec.size() > 0 && attendeeRec[0].sumoapp__SumoEvent__c != NULL){
            courseName = attendeeRec[0].sumoapp__SumoEvent__r.sumoapp__EventName__c;
            certificateNumber = attendeeRec[0].CertificateNumber__c;
            hudCounselourId = (attendeeRec[0].sumoapp__SumoEvent__r.Facilitator__c != NULL && attendeeRec[0].sumoapp__SumoEvent__r.Facilitator__r.CounselorHUDID__c != NULL) ? 
                				attendeeRec[0].sumoapp__SumoEvent__r.Facilitator__r.CounselorHUDID__c : '';
            
            if(attendeeRec[0].sumoapp__SumoEvent__r.sumoapp__RecurringEndDate__c != NULL){
                completionDate = attendeeRec[0].sumoapp__SumoEvent__r.sumoapp__RecurringEndDate__c.format();
            } else if(attendeeRec[0].sumoapp__SumoEvent__r.sumoapp__EndDatetime__c != NULL){
                completionDate = Date.valueOf(attendeeRec[0].sumoapp__SumoEvent__r.sumoapp__EndDatetime__c).format();
            }
            
        }
    }
}