public class PrintRosterController {
    public sumoapp__AdditionalInfo__c courseDetails {get;set;}
    public integer noOfClasses {get;set;}
    public list<Course> courses {get;set;}
    
    public list<Integer> blankRowsExtraPage {get; set;}
    public map<string,list<Integer>> classtoBlankrowsMap {get; set;} 
    public map<string,Boolean> classtoExtraRowsMap {get; set;}
    
    public PrintRosterController(){
        
        Id recId        = ApexPages.currentPage().getParameters().get('Id');
        courses     = new list<Course>();
        
        blankRowsExtraPage = new list<Integer>{1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24};
            classtoBlankrowsMap = new map<string, list<integer>>();
        classtoExtraRowsMap = new map<string,Boolean>();
        courseDetails = [SELECT Name, sumoapp__EventName__c, sumoapp__Location__c, sumoapp__Location__r.Name, sumoapp__LocationDetails__c, Facilitator__c, Facilitator__r.Name, sumoapp__StartDatetime__c, sumoapp__EndDatetime__c, Presenter__c, Presenter__r.Name,
                         CourseLanguage__c, sumoapp__Capacity__c, sumoapp__RegisteredAttendeeCount__c, CourseNumber__c,
                         (Select Id, sumoapp__ContactRelation__r.Name, sumoapp__IsNotArrived__c, Attendance_Status__c, sumoapp__ContactRelation__r.RecordType.Name from sumoapp__EventAttendees__r where sumoapp__ContactRelation__c != NULL AND sumoapp__ContactRelation__r.Name != null AND sumoapp__ContactRelation__r.AccountId != null AND sumoapp__ContactRelation__r.RecordTypeId!=null order by sumoapp__ContactRelation__r.AccountId,  sumoapp__ContactRelation__r.RecordType.DeveloperName desc)
                         FROM sumoapp__AdditionalInfo__c
                         WHERE Id =: recId WITH User_Mode ];
        
        Course attn = new Course();
        attn.courseName = courseDetails.sumoapp__EventName__c != NULL ? (courseDetails.sumoapp__EventName__c).toUpperCase() : '';
        attn.courseNumber = courseDetails.CourseNumber__c;
        attn.classId = courseDetails.Id;
        attn.locationName = courseDetails.sumoapp__Location__c != null ? courseDetails.sumoapp__Location__r.Name : '';
        attn.counselorName = courseDetails.Facilitator__c != null ? courseDetails.Facilitator__r.Name : '';
        attn.counselorPresentator = courseDetails.Presenter__c != null ? courseDetails.Presenter__r.Name : '';
        attn.counselorFecilator = courseDetails.Facilitator__c != null ? courseDetails.Facilitator__r.Name : '';
        String dt = courseDetails.sumoapp__StartDatetime__c != null ? courseDetails.sumoapp__StartDatetime__c.format() : '';
        
        dt = (String.isNotBlank(dt) && courseDetails.sumoapp__EndDatetime__c != null ) ? (dt + ' - ' + courseDetails.sumoapp__EndDatetime__c.format().subString(10)) : dt;
        
        attn.apptDate = dt;
        attn.capacity = Integer.valueOf(courseDetails.sumoapp__Capacity__c);
        attn.language = courseDetails.CourseLanguage__c;
        attn.totalEnrolled = Integer.valueOf(courseDetails.sumoapp__RegisteredAttendeeCount__c);
        
        List<Attendee> attendees = new List<Attendee>();
        for(sumoapp__Attendee__c rec : courseDetails.sumoapp__EventAttendees__r){
            if(String.isNotBlank(rec.sumoapp__ContactRelation__c)){
                attendees.add(new Attendee(rec));
            }
        }
        
        attn.students = attendees;
        
        courses.add(attn);
        noOfClasses = 0;
    }
    
    public class Course{
        public string courseName {get; set;}
        public string courseNumber {get; set;}
        public string classId {get; set;}
        public string locationName {get; set;}
        public string counselorName {get; set;}
        public string counselorPresentator {get; set;}
        public string counselorFecilator {get; set;}
        public string apptDate {get; set;}
        public Integer capacity {get; set;}
        public Integer totalEnrolled {get; set;}
        public String language {get; set;}
        public List<Attendee> students {get; set;}
        
    }
    
    public class Attendee{
        public string attendeeName {get; set;}
        public Boolean isCoApp {get; set;}
        public Boolean noShow {get; set;}
        public Boolean attended {get; set;}
        public String attendance {get; set;}
        
        public Attendee(sumoapp__Attendee__c rec){
            String name = rec.sumoapp__ContactRelation__r.Name;
            
            if(String.isNotBlank(rec.sumoapp__ContactRelation__r.RecordTypeId) && rec.sumoapp__ContactRelation__r.RecordType.Name == 'Co-Applicant'){
                name = '**' + name;
                this.isCoApp = true;
            } else{
                this.isCoApp = false;
            }
            
            this.attendeeName = name;
            if(String.isNotBlank(rec.Attendance_Status__c) && rec.Attendance_Status__c == 'Attended - Complete'){
                this.attendance = 'Complete';
            } else if(String.isNotBlank(rec.Attendance_Status__c) && rec.Attendance_Status__c == 'Course Incomplete'){
                this.attendance = 'Incomplete';
            } else if(String.isNotBlank(rec.Attendance_Status__c) && rec.Attendance_Status__c == 'No Show'){
                this.attendance = 'No Show';
            }
            
        }
    }
    
    
}