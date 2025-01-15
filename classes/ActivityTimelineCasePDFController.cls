/**
*Desc: An apex class controller for ActivityTimelinePDF data retrieving 
*/

public with sharing class ActivityTimelineCasePDFController {
    public ClientCase__c caseObj 							{ get; set; }
    public List<caseManagementEntry > appointments 			{ get; set; }
    public List<caseManagementEntry > caseManagementNotes 	{ get; set; }
    public AgencyProfile__c footer 							{ get; set; }
    public String CurrentDate                               { get; set; }
    
    public class caseManagementEntry {
        public String DateTimeDuration 						{ get; set; }
        public String Status 								{ get; set; }
        public String PurposeAndOutcome 					{ get; set; }
        public String Subject 								{ get; set; }
        public String Notes 								{ get; set; }
        
        // Constructor for Appointments
        public caseManagementEntry(String DateTimeDuration, String Status, String Purpose, String Outcome, String Subject, String Notes) {
            this.DateTimeDuration 	= DateTimeDuration;
            this.Status				= Status;
            this.PurposeAndOutcome  = (Purpose != null ? Purpose : '') + ' - ' + (Outcome != null ? Outcome : '');
            this.Subject 			= Subject;
            this.Notes 				= Notes;
        }
        // Constructor for Notes
        public caseManagementEntry(String DateTimeDuration, String Subject, String Notes) {
            this.DateTimeDuration 	= DateTimeDuration;
            this.Subject 			= Subject;
            this.Notes 				= Notes;
        }
    }
    
    /**
*Desc: An apex class constructor for the data retrieving functionality
*/
    public ActivityTimelineCasePDFController() {
        try{
            Datetime now = Datetime.now();
            String formattedDate = now.format('MM/dd/yy');
            CurrentDate = 'Printed on ' + formattedDate;
            Id ClientCaseId = ApexPages.currentPage().getParameters().get('id');          
            List<AgencyProfile__c> AgencyDetailList = [SELECT Id, Name, AgencyEmailAddress__c, AgencyAddress__Street__s, AgencyAddress__City__s, AgencyAddress__PostalCode__s, AgencyAddress__StateCode__s, AgencyAddress__CountryCode__s, AgencyAddress__Latitude__s,  AgencyPhoneNumber__c FROM AgencyProfile__c WITH SECURITY_ENFORCED Limit 1];
            if(!AgencyDetailList.isEmpty()){
                footer = AgencyDetailList[0];
            }
            
            if(ClientCaseId != NULL){
                List<ClientCase__c> ClientCaseList = [SELECT id,CaseTypeName__c,ClientCaseStatus__c, PrimaryClient__r.Name, ReferralSource__c, AnnualHouseholdIncome__c FROM ClientCase__c WHERE id =:ClientCaseId WITH SECURITY_ENFORCED Limit 1];
                if(!ClientCaseList.isEmpty()){
                    caseObj = ClientCaseList[0];
                    
                    appointments = new List<caseManagementEntry>();
                    String DateOnly;
                    List<Event> caseEventsList = [SELECT Id, Subject, Purpose__c, Outcome__c, AppointmentStatus__c, sumoapp__AdditionalInfo__r.Notes__c, ActivityDate, AppointmentDuration__c, Description FROM Event where WhatId =:ClientCaseId AND recordType.DeveloperName= 'Appointment' WITH SECURITY_ENFORCED ORDER BY ActivityDate DESC];
                    for(Event event: caseEventsList){
                        caseManagementEntry tle = new caseManagementEntry(getFormattedStartDatetime(event.ActivityDate, event.AppointmentDuration__c), event.AppointmentStatus__c, event.Purpose__c, event.Outcome__c, event.Subject , event.sumoapp__AdditionalInfo__r.Notes__c);
                        appointments.add(tle);
                    } 
                    
                    caseManagementNotes = new List<caseManagementEntry>();
                    List<CounselorNote__c> caseManagementNotesList = [SELECT Id, StartDatetime__c, ClientCaseName__c, ClientCase__c, Subject__c, Notes__c, EndDateTime__c, Contact__c, Duration__c FROM CounselorNote__c WHERE ClientCase__c =:ClientCaseId WITH SECURITY_ENFORCED];            
                    for(CounselorNote__c note: caseManagementNotesList){
                        caseManagementEntry tle = new caseManagementEntry(getFormattedStartDatetime(note.StartDatetime__c, note.Duration__c), note.Subject__c, note.Notes__c);
                        caseManagementNotes.add(tle);
                    }
                }        
            }
        }catch (Exception e) {
            System.debug('Error in Constructor: ' + e.getMessage());
            throw new AuraHandledException('Error in Constructor: ' + e.getMessage());
        }    
    }
    
    /**
*Desc: Function to get only the Date
*/
    public static String getFormattedStartDatetime(DateTime DateTimeVar, Decimal Duration ) {
        String DateVal = DateTimeVar != null ? DateTimeVar.format('yyyy/MM/dd').substring(0, 10) : '';
        String TimeVal = DateTimeVar != null ? DateTimeVar.format('hh:mm a') : '';
        return (Duration != NULL) ? (DateVal + ' - ' + TimeVal + ' - ' + Duration + 'min') : (DateVal + ' - ' + TimeVal);
    } 
}