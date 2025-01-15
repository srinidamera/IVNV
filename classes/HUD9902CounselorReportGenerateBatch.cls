public with sharing class HUD9902CounselorReportGenerateBatch  implements Database.Batchable<SObject>, Database.Stateful {
    private List<Id> successes = new List<Id>();
    private List<Id> failures = new List<Id>();
    private string NWC2NameSpace = Utility.getNwc2NameSpace();
    private final String queryString = 'SELECT Id, '+NWC2NameSpace+'CounselorHUDID__c, '+NWC2NameSpace+'CMSCounselorID__c, Email, FirstName, MiddleName, LastName, '+NWC2NameSpace+'EmploymentEndDate__c, '+NWC2NameSpace+'EmploymentStartDate__c, '+NWC2NameSpace+'CounselorBillingRate__c, '+NWC2NameSpace+'CounselorBillingMethod__c, Phone, '+NWC2NameSpace+'Languages__c, '+NWC2NameSpace+'CounselorServiceTypes__c, Name, '+
        '(Select Id, '+NWC2NameSpace+'Counselor__c, '+NWC2NameSpace+'TrainingCourseID__c, '+NWC2NameSpace+'TrainingCourseEndDate__c,'+
        NWC2NameSpace+'HUDTrainingOrganizationOther__c, '+NWC2NameSpace+'HUDTrainingSponsorOther__c, '+NWC2NameSpace+'TrainingCertificate__c,'+
        NWC2NameSpace+'TrainingDuration__c, '+NWC2NameSpace+'TrainingOrganization__c, '+NWC2NameSpace+'TrainingOrganizationOther__c, '+NWC2NameSpace+'TrainingSponsor__c,'+
        NWC2NameSpace+'TrainingSponsorOther__c, '+NWC2NameSpace+'TrainingTitle__c, '+NWC2NameSpace+'ValidationCombined__c from '+NWC2NameSpace+'Counselor_Training__r) from User WHERE '+NWC2NameSpace+'CMSCounselorID__c != null AND '+NWC2NameSpace+'IsCounselor__C = true';
    @testVisible
    private static String result = '';
    @testVisible
    private Boolean throwError = false;
    Id reportId;
    
    public HUD9902CounselorReportGenerateBatch(String reportRecordId){
        reportId = (Id)reportRecordId;
    }
    public Database.QueryLocator start(Database.BatchableContext context) {
        return Database.getQueryLocator(queryString);
    }
    public void execute(Database.BatchableContext context, List<User> scope) {
        List<X9902Counselor__c> counselor9902List = new List<X9902Counselor__c>();
        Map<Id, CounselorTraining__c> counselorIdCTMap = new Map<Id, CounselorTraining__c>();
        X9902Counselor__c x9902Counselor = new X9902Counselor__c();
        CounselorTraining__c counselorTraining = new CounselorTraining__c();
        
        System.debug('reportId::: ' + reportId);
        counselorIdCTMap = getCounselorTrainingMap(scope);
        X9902__c x9902 = [SELECT PeriodStartDate__c, PeriodEndDate__c, Quarter__c FROM X9902__c WHERE Id = :reportId];

        Set<Id> userIdSet = getvalidCounselor(x9902.PeriodStartDate__c,x9902.PeriodEndDate__c);
        for (User u : scope) {
            if(userIdSet.contains(u.Id)){
                x9902Counselor = new X9902Counselor__c();
                x9902Counselor.X9902__c = reportId;
                x9902Counselor.User__c = u.Id;
                x9902Counselor.ElementType__c = 'Profile';
                x9902Counselor.CounselorHUDID__c = u.CounselorHUDID__c;
                x9902Counselor.CMSCounselorID__c = u.CMSCounselorID__c;  
                x9902Counselor.CounselorEmailAddress__c = u.Email; 
                x9902Counselor.CounselorFirstName__c = u.FirstName;
                x9902Counselor.CounselorLastName__c = u.LastName;
                x9902Counselor.CounselorMiddleName__c = u.MiddleName;
                x9902Counselor.CounselorEmpEndDate__c = u.EmploymentEndDate__c;
                x9902Counselor.CounselorEmpStartDate__c = u.EmploymentStartDate__c;
                x9902Counselor.CounselorRate__c = u.CounselorBillingRate__c;
                x9902Counselor.CounselorBillingMethod__c = u.CounselorBillingMethod__c;
                x9902Counselor.CounselorPhone__c = HUD9902Helper.formatPhone(u.Phone);
                x9902Counselor.CounselorLanguages__c = u.Languages__c;
                x9902Counselor.CounselorServiceTypes__c =  u.CounselorServiceTypes__c;
                
                counselor9902List.add(x9902Counselor);
                
                Set<String> trainingCourseIds = new Set<String>();
                
                for (CounselorTraining__c stRec : u.Counselor_Training__r) {
                    //Counselor Training
                    X9902Counselor__c x9902CounselorTraining = new X9902Counselor__c();
                    x9902CounselorTraining.X9902__c = reportId;
                    x9902CounselorTraining.User__c = u.Id;
                    x9902CounselorTraining.ElementType__c = 'Training';
                    x9902CounselorTraining.StaffTrainingAttendance__c = stRec.Id;
                    x9902CounselorTraining.CMSCounselorID__c = u.CMSCounselorID__c;
                    x9902CounselorTraining.CounselorTrainingCertificate__c = stRec.TrainingCertificate__c;
                    x9902CounselorTraining.CounselorTrainingCourseID__c = stRec.TrainingCourseID__c;
                    
                    counselor9902List.add(x9902CounselorTraining);
                    
                    if(!trainingCourseIds.contains('')){
                        //Counselor Training Course
                        X9902Counselor__c x9902CounselorTrainingCourse = new X9902Counselor__c();
                        x9902CounselorTrainingCourse.X9902__c = reportId;
                        x9902CounselorTrainingCourse.User__c = u.Id;
                        x9902CounselorTrainingCourse.ElementType__c = 'Training Course';
                        x9902CounselorTrainingCourse.StaffTrainingAttendance__c = stRec.Id;
                        x9902CounselorTrainingCourse.CounselorMiddleName__c = u.MiddleName;
                        x9902CounselorTrainingCourse.CounselorTrainingCourseID__c = stRec.TrainingCourseID__c;
                        x9902CounselorTrainingCourse.CounselorTrainingTitle__c = stRec.TrainingTitle__c;
                        x9902CounselorTrainingCourse.CounselorTrainingDate__c = stRec.TrainingCourseEndDate__c;
                        x9902CounselorTrainingCourse.CounselorTrainingOrganization__c = stRec.TrainingOrganization__c;
                        x9902CounselorTrainingCourse.CounselorTrainingOrganizationOther__c = stRec.TrainingOrganizationOther__c;
                        x9902CounselorTrainingCourse.CounselorTrainingSponsor__c = stRec.TrainingSponsor__c;
                        x9902CounselorTrainingCourse.CounselorTrainingSponsorOther__c = stRec.TrainingSponsorOther__c;
                        x9902CounselorTrainingCourse.CounselorTrainingDuration__c = stRec.TrainingDuration__c;
                        x9902CounselorTrainingCourse.CounselorTrainingCertificate__c = stRec.TrainingCertificate__c;
                        
                        counselor9902List.add(x9902CounselorTrainingCourse);
                        trainingCourseIds.add(stRec.TrainingCourseID__c);
                    }
                    
                }
            }
        }
        
        if(counselor9902List.size() > 0){
            insert counselor9902List;
        }
        
        List<Database.SaveResult> saveResults = new List<Database.SaveResult>();
    }
    
    public void finish(Database.BatchableContext context) {
        
    }
    
    public Set<Id> getvalidCounselor(Date qtrStartDate, Date qtrEndDate){
        Set<Id> userIdSet = new Set<Id>();
        List<Event> appointmentList = [SELECT Id, OwnerId
                                       FROM Event 
                                       WHERE Who.Type = 'Contact'
                                       AND What.Type = 'ClientCase__C'
                                       AND EndDateTime >= :qtrStartDate 
                                       AND EndDateTime <= :qtrEndDate
                                       AND AppointmentStatus__c = 'Attended'
                                       AND Who.RecordType.Name = 'Primary Client'
                                       AND RecordType.Name = 'Appointment'
                                       AND Purpose__c NOT IN ('Not HUD-Reportable', null, '', NULL)
                                      ];
        
        for(Event ev : appointmentList){
            userIdSet.add(ev.OwnerId);
        }
        
        List<sumoapp__AdditionalInfo__c> courseList = [SELECT Id, Facilitator__c
                                                       FROM sumoapp__AdditionalInfo__c
                                                       WHERE RecordType.Name IN ('Course', 'Event')
                                                       AND IsParent__c = true
                                                       AND sumoapp__StartDatetime__c >= :qtrStartDate
                                                       AND sumoapp__EndDatetime__c <= :qtrEndDate
                                                       AND HUD_Purpose__c NOT IN (null, '', NULL)
                                                       AND sumoapp__Status__c != 'CANCELED'
                                                      ];        
        for(sumoapp__AdditionalInfo__c course : courseList){
            userIdSet.add(course.Facilitator__c);
        }
        
        return userIdSet;
        
    }
    
     public Map<Id, CounselorTraining__c> getCounselorTrainingMap(List<User> counselorList){
        Map<Id, CounselorTraining__c> counselorIdCTMap = new Map<Id, CounselorTraining__c>();
        List<CounselorTraining__c> ctList = new List<CounselorTraining__c>();
        List<Id> counselorIdList = new List<Id>();
        for (User u : counselorList) {
            counselorIdList.add(u.Id);
        }
        ctList= [SELECT Id, Counselor__c, TrainingCourseID__c, TrainingCourseEndDate__c,
            HUDTrainingOrganizationOther__c, HUDTrainingSponsorOther__c, TrainingCertificate__c,
            TrainingDuration__c, TrainingOrganization__c, TrainingOrganizationOther__c, TrainingSponsor__c,
            TrainingSponsorOther__c, TrainingTitle__c, ValidationCombined__c
            FROM CounselorTraining__c WHERE Counselor__c IN :counselorIdList];

        for(CounselorTraining__c ct : ctList){
            counselorIdCTMap.put(ct.Counselor__c, ct);
        }

        return counselorIdCTMap;
    }
}