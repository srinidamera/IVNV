/**
*Desc: An apex class controller for ActivityTimelinePDF data retrieving 
*/
public with sharing class ActivityTimelineContactPDFController {
    public Contact ContactObj                                   { get; set; }
    public List<ContactManagementEntry> appointments            { get; set; }
    public List<ContactManagementEntry> caseManagementNotes     { get; set; }
    public List<ContactManagementEntry> Courses                 { get; set; }
    public String CurrentDate                                   { get; set; }
    public AgencyProfile__c footer                              { get; set; }

    
    public class ContactManagementEntry {
        public String DateTimeDuration                          { get; set; }
        public String Status                                    { get; set; }
        public String PurposeAndOutcome                         { get; set; }
        public String Subject                                   { get; set; }
        public String Notes                                     { get; set; }
        public String CourseName                                { get; set; }
        public String Description                               { get; set; }
        
        // Constructor for Appointments
        public ContactManagementEntry(String DateTimeDuration, String Status, String Purpose, String Outcome, String Subject, String Notes) {
            this.DateTimeDuration   = DateTimeDuration;
            this.Status             = Status;
            this.PurposeAndOutcome  = (Purpose != null ? Purpose +' - ' : '') + (Outcome != null ? Outcome : '');
            this.Subject            = Subject;
            this.Notes              = Notes;
        }
        
        // Constructor for Notes
        public ContactManagementEntry(String DateTimeDuration, String Subject, String Notes) {
            this.DateTimeDuration   = DateTimeDuration;
            this.Subject            = Subject;
            this.Notes              = Notes;
        }
        
        // Constructor for Courses
        public ContactManagementEntry(String DateTimeDuration, String Status, String CourseName, String Description) {
            this.DateTimeDuration   = DateTimeDuration;
            this.Status             = Status;
            this.CourseName         = CourseName;
            this.Description        = Description;
        }
    }
    
    /**
*Desc: An apex class constructor for the data retrieving functionality
*/
    public ActivityTimelineContactPDFController() {
        try{
            Id ContactId = ApexPages.currentPage().getParameters().get('id');
            Datetime now = Datetime.now();
            String formattedDate = now.format('MM/dd/yyyy');
            CurrentDate = 'Printed on ' + formattedDate;
            if(ContactId != NULL){   
                List<AgencyProfile__c> AgencyDetailList = [SELECT Id, Name, AgencyEmailAddress__c, AgencyAddress__Street__s, AgencyAddress__City__s, AgencyAddress__PostalCode__s, AgencyAddress__StateCode__s, AgencyAddress__CountryCode__s, 
                                                           AgencyAddress__Latitude__s, AgencyPhoneNumber__c 
                                                           FROM AgencyProfile__c WITH SECURITY_ENFORCED Limit 1];
                if(!AgencyDetailList.isEmpty()){
                    footer = AgencyDetailList[0];
                }

                List<Contact> ContactList = [SELECT id, HouseholdType__c,Name 
                                             FROM Contact WHERE id =:ContactId Limit 1];
                if(!ContactList.isEmpty()){
                    ContactObj = ContactList[0];

                    appointments = new List<ContactManagementEntry>();
                    List<Event> caseEventsList = [SELECT Id, Subject, Purpose__c, AppointmentDuration__c, Outcome__c, sumoapp__AdditionalInfo__r.Notes__c, AppointmentStatus__c, ActivityDate, Description 
                                                  FROM Event where WhoId =:ContactId AND recordType.DeveloperName= 'Appointment' WITH SECURITY_ENFORCED ORDER BY ActivityDate DESC];
                    for(Event event: caseEventsList){
                        ContactManagementEntry tle = new ContactManagementEntry(getFormattedStartDatetime(event.ActivityDate, event.AppointmentDuration__c), event.AppointmentStatus__c, event.Purpose__c, event.Outcome__c, event.Subject , event.sumoapp__AdditionalInfo__r.Notes__c);
                        appointments.add(tle);
                    }  

                    caseManagementNotes = new List<ContactManagementEntry>();
                    List<CounselorNote__c> caseManagementNotesList = [SELECT Id, StartDatetime__c, ClientCaseName__c, ClientCase__c, Subject__c, Notes__c, EndDateTime__c, Contact__c, Duration__c 
                                                                      FROM CounselorNote__c WHERE Contact__c =:ContactId WITH SECURITY_ENFORCED ORDER BY StartDatetime__c DESC];
                    String DateOnly;
                    for(CounselorNote__c note: caseManagementNotesList){
                        ContactManagementEntry tle = new ContactManagementEntry(getFormattedStartDatetime(note.StartDatetime__c, note.Duration__c), note.Subject__c, note.Notes__c);
                        caseManagementNotes.add(tle);
                    }
                    
                    //sumoapp__Attendee__c  , Attendance_Status__c
                    List<sumoapp__Attendee__c> AttendeeList = [Select id,sumoapp__SumoEvent__c,Attendance_Status__c, sumoapp__SumoEvent__r.RecordType.DeveloperName,sumoapp__SumoEvent__r.sumoapp__Parent__r.sumoapp__EventName__c,sumoapp__Status__c,
                                                               sumoapp__SumoEvent__r.Name,sumoapp__EventName__c,sumoapp__StartDatetime__c,sumoapp__EndDatetime__c 
                                                               from sumoapp__Attendee__c where sumoapp__ContactRelation__c =:ContactId WITH SECURITY_ENFORCED];  
                    
                    Map<Id, sumoapp__Attendee__c> attendeeMap = new Map<Id, sumoapp__Attendee__c>();
                    for(sumoapp__Attendee__c Att: AttendeeList){
                        attendeeMap.put(Att.sumoapp__SumoEvent__c, Att);
                    }
                    
                    List<id> IdsOfCourse = new List<id>(attendeeMap.keySet());
                    
                    Courses = new List<ContactManagementEntry>();
                    List<sumoapp__AdditionalInfo__c > CoursesLists = [SELECT id, sumoapp__DurationInMinutes__c, sumoapp__StartDatetime__c, sumoapp__EventName__c, CourseLanguage__c,  
                                                                      sumoapp__Description__c, sumoapp__LocationType__c 
                                                                      FROM sumoapp__AdditionalInfo__c WHERE id IN :IdsOfCourse and IsParent__c=false WITH SECURITY_ENFORCED ORDER BY sumoapp__StartDatetime__c DESC];
                    
                    for(sumoapp__AdditionalInfo__c course: CoursesLists){
                        sumoapp__Attendee__c relatedAttendee = attendeeMap.get(course.Id);
                        String attendeeStatus = relatedAttendee != null ? relatedAttendee.Attendance_Status__c : null;
                        ContactManagementEntry tle = new ContactManagementEntry(getFormattedStartDatetime(course.sumoapp__StartDatetime__c, course.sumoapp__DurationInMinutes__c), attendeeStatus, course.sumoapp__EventName__c, course.sumoapp__Description__c);
                        Courses.add(tle);
                    }
                    
                }  
            }
        }
        catch (Exception e) {
            System.debug('Error in Constructor: ' + e.getMessage() + '\n' + e.getStackTraceString());
            throw new AuraHandledException('Error in Constructor: ' + e.getMessage());
        }    
    }
    
  /**
*Desc: Function to get only the Date
*/
     public static String getFormattedStartDatetime(DateTime DateTimeVar, Decimal Duration ) {
    String DateVal = DateTimeVar != null ? DateTimeVar.format('MM/dd/yyyy') : '';
    String TimeVal = DateTimeVar != null ? DateTimeVar.format('hh:mm a') : '';
    return (Duration != NULL) ? (DateVal + ' - ' + TimeVal + ' - ' + Duration + 'min') : (DateVal + ' - ' + TimeVal);
}
}