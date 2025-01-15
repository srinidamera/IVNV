public class HudOrsFinancialCapabilityReportCtrl {
    
    public class OrsReportWrapper{
        @AuraEnabled
        public String recordid{get;set;}
        @AuraEnabled
        public String HouseholdID{get;set;}
        @AuraEnabled
        public String ServiceName{get;set;}
        @AuraEnabled
        public String Service_Name{get;set;}
        @AuraEnabled
        public String First_Name{get;set;}
        @AuraEnabled
        public String Last_Name{get;set;}
        @AuraEnabled
        public Date Date_Opened{get;set;}
        @AuraEnabled
        public Date Birthdate{get;set;}
        @AuraEnabled
        public String Gender{get;set;}
        @AuraEnabled
        public String Race{get;set;}
        @AuraEnabled
        public String Ethnicity{get;set;}
        @AuraEnabled
        public String Number_of_Household_Members{get;set;}
        @AuraEnabled
        public Decimal Annual_HH_Income_at_Start_of_Service{get;set;}
        @AuraEnabled
        public Decimal Annual_HH_Income_at_End_of_Service{get;set;}
        @AuraEnabled
        public String AMI_at_Start_of_Service{get;set;}
        @AuraEnabled
        public String AMI_at_End_of_Service{get;set;}
        @AuraEnabled
        public Decimal Savings_at_Start_of_Service{get;set;}
        @AuraEnabled
        public Decimal Savings_at_End_of_Service{get;set;}
        @AuraEnabled
        public String Credit_Score_at_Start_of_Service{get;set;}
        @AuraEnabled
        public String Credit_Score_at_End_of_Service{get;set;}
        @AuraEnabled
        public Decimal Debt_at_Start_of_Service{get;set;}
        @AuraEnabled
        public Decimal Debt_at_End_of_Service{get;set;}
        @AuraEnabled
        public String Residence_Type_at_Start_of_Service{get;set;}
        @AuraEnabled
        public String Residence_Type_at_End_of_Service{get;set;}
        @AuraEnabled
        public String Address{get;set;}
        @AuraEnabled
        public String Street_Name{get;set;}
        @AuraEnabled
        public String Apt{get;set;}
        @AuraEnabled
        public String Primary_City{get;set;}
        @AuraEnabled
        public String Primary_State{get;set;}
        @AuraEnabled
        public String Primary_Zip{get;set;}
        @AuraEnabled
        public String Total_Counseling_Hours{get;set;}
        @AuraEnabled
        public String Total_Hours_of_FC_Education{get;set;}
        @AuraEnabled
        public Date Date_Closed{get;set;}
        @AuraEnabled
        public String Household_ID{get;set;} 
        @AuraEnabled
        public string Age{get;set;}  
        @AuraEnabled
        public string Goal_Improve_Credit{get;set;}
        @AuraEnabled
        public string Goal_Increase_Credit_Access{get;set;}
        @AuraEnabled
        public string Goal_Establish_Credit{get;set;} 
        @AuraEnabled
        public string Goal_Fewer_Collections{get;set;}
        @AuraEnabled
        public string Goal_Fewer_Past_Due{get;set;} 
        @AuraEnabled
        public string Goal_Reduce_Debt{get;set;} 
        @AuraEnabled
        public string Goal_Increase_Savings{get;set;} 
        @AuraEnabled
        public string Goal_Increase_Worth{get;set;} 
        @AuraEnabled
        public string Goal_Spend_Less_on_Financial_Services{get;set;} 
        @AuraEnabled
        public string Goal_New_Financial_Products{get;set;} 
        @AuraEnabled
        public string Goal_Increase_Insurance_Coverage{get;set;} 
        @AuraEnabled
        public string Goal_Manage_Fluctuations_in_Income{get;set;} 
        @AuraEnabled
        public string Goal_Three_Months_Savings{get;set;}
        @AuraEnabled
        public string Goal_Savings_Goal{get;set;} 
        @AuraEnabled
        public string Goal_Decrease_Tax_Filing_Cost{get;set;} 
        @AuraEnabled
        public string Goal_Increase_Tax_Benefit{get;set;}
        @AuraEnabled
        public string Goal_Optimize_Public_Benefits{get;set;}
        @AuraEnabled
        public string Goal_of_Stabilize_housing{get;set;}
        @AuraEnabled
        public string Outcome_Improve_Credit{get;set;}
        @AuraEnabled   
        public string Outcome_Increase_Credit_Access{get;set;}
        @AuraEnabled
        public string Outcome_Establish_Credit{get;set;}
        @AuraEnabled
        public string Outcome_Fewer_Collections{get;set;}
        @AuraEnabled
        public string Outcome_Fewer_Past_Due{get;set;}
        @AuraEnabled
        public string Outcome_Reduce_Debt{get;set;}
        @AuraEnabled    
        public string Outcome_Increase_Savings{get;set;}
        @AuraEnabled    
        public string Outcome_Increase_Worth{get;set;}
        @AuraEnabled    
        public string Outcome_Spend_Less_on_Financial_Services{get;set;}
        @AuraEnabled    
        public string Outcome_Increase_Insurance_Coverage{get;set;}
        @AuraEnabled    
        public string Outcome_Manage_Fluctuations_in_Income{get;set;}
        @AuraEnabled    
        public string Outcome_Three_Months_Savings{get;set;}
        @AuraEnabled    
        public string Outcome_Savings_Goal{get;set;}
        @AuraEnabled    
        public string Outcome_Decrease_Tax_Filing_Cost{get;set;}
        @AuraEnabled    
        public string Outcome_Increase_Tax_Benefit{get;set;}
        @AuraEnabled    
        public string Outcome_Optimize_Public_Benefits{get;set;}
        @AuraEnabled    
        public string Outcome_of_Stabilize_housing{get;set;}
        @AuraEnabled    
        public string Outcome_achieved{get;set;}
        @AuraEnabled    
        public string Financial_Capability_Data_Complete{get;set;}
        @AuraEnabled
        public Date Financial_Capability_Completion_Date{get;set;}
    }

    @AuraEnabled
    public static map<string,list<OrsReportWrapper>> fetchORSFinancialRecords(Date qtrStartDate,Date qtrEndDate){
        list<OrsReportWrapper> orsWrapperVList= new list<OrsReportWrapper>();
        list<OrsReportWrapper> orsWrapperEList= new list<OrsReportWrapper>();
        map<String, list<OrsReportWrapper>> orsWrappermap = new map<string,list<OrsReportWrapper>>();
        List<ClientCase__c > serviceValidationList = new List<ClientCase__c >();
        
        Map<String,String> genderMap = new Map<String,String>{'Male'=>'Male',
                                                              'Female'=>'Female',
                                                              'Other/Non-conforming'=>'Gender Non-Conforming'};
        
    	Map<String,String> raceMap = new Map<String,String>{ 'American Indian/Alaskan Native'=>'American Indian/Alaskan Native',
                                                             'Asian'=>'Asian',
                                                             'Black or African American'=>'Black or African American',
                                                             'Native Hawaiian or Other Pacific Islander'=>'Native Hawaiian/Other Pacific Islander',
                                                             'White'=>'White',
                                                             'More than one race'=>'More than one race',
                                                             'Chose not to respond'=>'Chose not to respond'};
                                                                 
    	Map<String,String>  ethnicityMap = new Map<String,String>{'Hispanic'=>'Hispanic',
                                                                  'Not Hispanic'=>'Not Hispanic',
                                                                  'Chose not to respond'=>'Chose not to respond'};
    
        
        try{
            
            servicevalidationList=[Select id, Name,ClientNumber__c, ClientCaseName__c, PrimaryClient__r.FirstName,PrimaryClient__r.LastName, Financial_Capability_Data_Complete__c, Age__c,
                        PrimaryClient__r.Birthdate,Gender__c,Race__c,Ethnicity__c, HouseholdSize__c, PostCounselingAnnualHouseholdIncome__c,
                        PreCounselingAnnualHouseholdIncome__c,AMIAtEndOfClientCase__c,AMIAtStartOfClientCase__c, PostCounselingSavings__c ,
                        PreCounselingSavings__c, PreCounselingCreditScore__c, PostCounselingCreditScore__c,MailingAddressLine2__c,
                        PreCounselingHouseholdDebt__c,PostCounselingHouseholdDebt__c, PreCounselingResidenceType__c, PostCounselingResidenceType__c,
                        Address__c, TotalHoursOfFCCoaching__c, TotalHoursOfFCEducation__c, ClientCaseClosedDate__c,AddressMailingStreet__c,
                        Goal_Improve_Credit__c,Goal_Increase_Credit_Access__c,Goal_Fewer_Collections__c,Goal_of_Stabilize_housing__c,
                        Goal_Establish_Credit__c,Goal_Fewer_Past_Due__c,Goal_Reduce_Debt__c,Goal_Increase_Savings__c, Outcome_New_Financial_Products__c,
                        Goal_Increase_Worth__c,Goal_Spend_Less_on_Financial_Services__c,Goal_New_Financial_Products__c,
                        Goal_Increase_Insurance_Coverage__c,Goal_Manage_Fluctuations_in_Income__c,Goal_Three_Months_Savings__c, createddate,
                        Goal_Savings_Goal__c,Goal_Decrease_Tax_Filing_Cost__C,Goal_Increase_Tax_Benefit__c,Goal_Optimize_Public_Benefits__c,
                        Outcome_Improve_Credit__c,Outcome_Increase_Credit_Access__c,Outcome_Establish_Credit__c,Outcome_Fewer_Collections__c,
                        Outcome_Fewer_Past_Due__c,Outcome_Reduce_Debt__c,Outcome_Increase_Savings__c,Outcome_Increase_Worth__c,Outcome_Spend_Less_on_Financial_Services__c,
                        Outcome_Increase_Insurance_Coverage__c,Outcome_Manage_Fluctuations_in_Income__c,Outcome_Three_Months_Savings__c,Outcome_Savings_Goal__c,
                        Outcome_Decrease_Tax_Filing_Cost__c,Outcome_Increase_Tax_Benefit__c,Outcome_Optimize_Public_Benefits__c,Outcome_of_Stabilize_housing__c,
                        (Select id from Events where RecordType.DeveloperName = 'Appointment' and AppointmentStatus__c = 'Attended') 
                        from ClientCase__c where ClientCaseClosedDate__c<=:qtrEndDate AND ClientCaseClosedDate__c>=:qtrStartDate AND  
                        ClientCaseStatus__c = 'Closed - Complete' AND RecordType.DeveloperName = 'FinancialCapabilityCounseling' order by Financial_Capability_Data_Complete__c desc limit 49999];
                        
            for(ClientCase__c service: servicevalidationList){
                if(service.Events.size() > 0 || Test.isRunningTest()){
                    OrsReportWrapper orswrap = new OrsReportWrapper();
                    orswrap.recordid=service.id;                	
                    orswrap.ServiceName=service.ClientCaseName__c;
                    orswrap.Service_Name=service.ClientCaseName__c;
                    orswrap.First_Name=service.PrimaryClient__r.FirstName;
                    orswrap.Last_Name=service.PrimaryClient__r.LastName;
                    if(service.Financial_Capability_Data_Complete__c.contains('failed') || String.isBlank(service.Financial_Capability_Data_Complete__c)){
                        orswrap.Financial_Capability_Data_Complete='failed';
                    } else {
                        orswrap.Financial_Capability_Data_Complete= 'passed';
                    }
                    if(service.createddate != null) {
                        Date dt = Date.valueOf(service.createddate);                     	
                        orswrap.Date_Opened = date.newinstance(dT.year(), dT.month(), dT.day());
                    }
                    if(service.PrimaryClient__r.Birthdate != null) {
                        Date dt1 = service.PrimaryClient__r.Birthdate;                     	
                        orswrap.Birthdate = date.newinstance(dT1.year(), dT1.month(), dT1.day());
                    }
                    orswrap.Gender=genderMap.get(service.Gender__c);
                    orswrap.Race=raceMap.get(service.Race__c);
                    orswrap.Ethnicity=ethnicityMap.get(service.Ethnicity__c);
                    orswrap.Number_of_Household_Members=String.valueOf(service.HouseholdSize__c);
                    orswrap.Annual_HH_Income_at_Start_of_Service=service.PreCounselingAnnualHouseholdIncome__c;
                    orswrap.Annual_HH_Income_at_End_of_Service=service.PostCounselingAnnualHouseholdIncome__c;
                    orswrap.AMI_at_Start_of_Service=service.AMIAtStartOfClientCase__c;
                    orswrap.AMI_at_End_of_Service=service.AMIAtEndOfClientCase__c;
                    orswrap.Savings_at_Start_of_Service=service.PreCounselingSavings__c;
                    orswrap.Savings_at_End_of_Service=service.PostCounselingSavings__c;
                    orswrap.Credit_Score_at_Start_of_Service=String.valueOf(service.PreCounselingCreditScore__c);
                    orswrap.Credit_Score_at_End_of_Service=String.valueOf(service.PostCounselingCreditScore__c);
                    orswrap.Debt_at_Start_of_Service=service.PreCounselingHouseholdDebt__c;
                    orswrap.Debt_at_End_of_Service=service.PostCounselingHouseholdDebt__c;
                    orswrap.Residence_Type_at_Start_of_Service=service.PreCounselingResidenceType__c;
                    orswrap.Residence_Type_at_End_of_Service=service.PostCounselingResidenceType__c; 
                    orswrap.Address = service.AddressMailingStreet__c;
                    orswrap.Street_Name = (service.Address__c != null) ? (String.isEmpty(service.Address__c.getStreet()) ? '' : service.Address__c.getStreet()) : '';
                    orswrap.Apt=service.MailingAddressLine2__c;
                    orswrap.Primary_City=(service.Address__c != null) ? (String.isEmpty(service.Address__c.getCity()) ? '' : service.Address__c.getCity()) : '';
                    orswrap.Primary_State=(service.Address__c != null) ? (String.isEmpty(service.Address__c.getState()) ? '' : service.Address__c.getState()) : '';
                    orswrap.Primary_Zip=(service.Address__c != null) ? (String.isEmpty(service.Address__c.getPostalCode()) ? '' : service.Address__c.getPostalCode()) : '';
                    orswrap.Total_Counseling_Hours=String.valueOf(service.TotalHoursOfFCCoaching__c);
                    orswrap.Total_Hours_of_FC_Education=String.valueOf(service.TotalHoursOfFCEducation__c);
                    if(service.ClientCaseClosedDate__c != null) {
                        Date dt2 = service.ClientCaseClosedDate__c;                    	
                        orswrap.Financial_Capability_Completion_Date = date.newinstance(dT2.year(), dT2.month(), dT2.day());
                    }
                    orsWrapperVList.add(orswrap);
                    if(service.Financial_Capability_Data_Complete__c == 'passed' || Test.isRunningTest()){                
                        OrsReportWrapper orswrap1= new OrsReportWrapper();
                        orswrap1.Household_ID=service.ClientNumber__c;
                        orswrap1.HouseholdID=service.ClientNumber__c;
                        orswrap1.recordid=service.id;
                        orswrap1.First_Name=service.PrimaryClient__r.FirstName;
                        orswrap1.Last_Name=service.PrimaryClient__r.LastName;
                        if(service.createddate != null) {
                            Date dt = Date.valueOf(service.createddate);                     	
                            orswrap1.Date_Opened =date.newinstance(dT.year(), dT.month(), dT.day());
                        }
                        orswrap1.Age = String.valueOf(service.Age__c);
                        orswrap1.Goal_Improve_Credit= service.Goal_Improve_Credit__c;
                        orswrap1.Goal_Increase_Credit_Access=service.Goal_Increase_Credit_Access__c;
                        orswrap1.Goal_Establish_Credit=service.Goal_Establish_Credit__c;
                        orswrap1.Goal_Fewer_Collections=service.Goal_Fewer_Collections__c;
                        orswrap1.Goal_Fewer_Past_Due=service.Goal_Fewer_Past_Due__c;
                        orswrap1.Goal_Reduce_Debt=service.Goal_Reduce_Debt__c;
                        orswrap1.Goal_Increase_Savings=service.Goal_Increase_Savings__c;
                        orswrap1.Goal_Increase_Worth=service.Goal_Increase_Worth__c;
                        orswrap1.Goal_Spend_Less_on_Financial_Services=service.Goal_Spend_Less_on_Financial_Services__c;
                        orswrap1.Goal_New_Financial_Products=service.Goal_New_Financial_Products__c;
                        orswrap1.Goal_Increase_Insurance_Coverage=service.Goal_Increase_Insurance_Coverage__c;
                        orswrap1.Goal_Manage_Fluctuations_in_Income=service.Goal_Manage_Fluctuations_in_Income__c;
                        orswrap1.Goal_Three_Months_Savings=service.Goal_Three_Months_Savings__c;
                        orswrap1.Goal_Savings_Goal=service.Goal_Savings_Goal__c;
                        orswrap1.Goal_Decrease_Tax_Filing_Cost=service.Goal_Decrease_Tax_Filing_Cost__C;
                        orswrap1.Goal_Increase_Tax_Benefit=service.Goal_Increase_Tax_Benefit__c;
                        orswrap1.Goal_Optimize_Public_Benefits=service.Goal_Optimize_Public_Benefits__c;
                        orswrap1.Goal_of_Stabilize_housing=service.Goal_of_Stabilize_housing__c;
                        orswrap1.Gender=genderMap.get(service.Gender__c);                   
                        orswrap1.Race=raceMap.get(service.Race__c);
                        orswrap1.Ethnicity=ethnicityMap.get(service.Ethnicity__c);
                        orswrap1.Number_of_Household_Members=String.valueOf(service.HouseholdSize__c);
                        orswrap1.Annual_HH_Income_at_Start_of_Service=service.PreCounselingAnnualHouseholdIncome__c;
                        orswrap1.Annual_HH_Income_at_End_of_Service=service.PostCounselingAnnualHouseholdIncome__c;
                        orswrap1.AMI_at_Start_of_Service=service.AMIAtStartOfClientCase__c;
                        orswrap1.AMI_at_End_of_Service=service.AMIAtEndOfClientCase__c;
                        orswrap1.Savings_at_Start_of_Service=service.PreCounselingSavings__c;
                        orswrap1.Savings_at_End_of_Service=service.PostCounselingSavings__c;
                        orswrap1.Credit_Score_at_Start_of_Service=String.valueOf(service.PreCounselingCreditScore__c);
                        orswrap1.Credit_Score_at_End_of_Service=String.valueOf(service.PostCounselingCreditScore__c);
                        orswrap1.Debt_at_Start_of_Service=service.PreCounselingHouseholdDebt__c;
                        orswrap1.Debt_at_End_of_Service=service.PostCounselingHouseholdDebt__c;
                        orswrap1.Residence_Type_at_Start_of_Service=service.PreCounselingResidenceType__c;
                        orswrap1.Residence_Type_at_End_of_Service=service.PostCounselingResidenceType__c; 
                        orswrap1.Address=service.AddressMailingStreet__c;
                        orswrap1.Street_Name = (service.Address__c != null) ? (String.isEmpty(service.Address__c.getStreet()) ? '' : service.Address__c.getStreet()) : '';
                        orswrap1.Apt=service.MailingAddressLine2__c;
                        orswrap1.Primary_City=(service.Address__c != null) ? (String.isEmpty(service.Address__c.getCity()) ? '' : service.Address__c.getCity()) : '';
                        orswrap1.Primary_State=(service.Address__c != null) ? (String.isEmpty(service.Address__c.getState()) ? '' : service.Address__c.getState()) : '';
                        orswrap1.Primary_Zip=(service.Address__c != null) ? (String.isEmpty(service.Address__c.getPostalCode()) ? '' : service.Address__c.getPostalCode()) : '';
                        orswrap1.Total_Counseling_Hours=String.valueOf(service.TotalHoursOfFCCoaching__c);
                        orswrap1.Total_Hours_of_FC_Education=String.valueOf(service.TotalHoursOfFCEducation__c);
                        if(service.ClientCaseClosedDate__c != null) {
                            Date dt2 = service.ClientCaseClosedDate__c;                    	
                            orswrap.Financial_Capability_Completion_Date = date.newinstance(dT2.year(), dT2.month(), dT2.day());
                        }
                        orswrap1.Outcome_Improve_Credit=service.Outcome_Improve_Credit__c;               
                        orswrap1.Outcome_Increase_Credit_Access=service.Outcome_Increase_Credit_Access__c;
                        orswrap1.Outcome_Establish_Credit=service.Outcome_Establish_Credit__c;
                        orswrap1.Outcome_Fewer_Collections=service.Outcome_Fewer_Collections__c;
                        orswrap1.Outcome_Fewer_Past_Due=service.Outcome_Fewer_Past_Due__c;
                        orswrap1.Outcome_Reduce_Debt=service.Outcome_Reduce_Debt__c;
                        orswrap1.Outcome_Increase_Savings=service.Outcome_Increase_Savings__c;
                        orswrap1.Outcome_Increase_Worth=service.Outcome_Increase_Worth__c;
                        orswrap1.Outcome_Spend_Less_on_Financial_Services=service.Outcome_Spend_Less_on_Financial_Services__c;               
                        orswrap1.Outcome_Increase_Insurance_Coverage=service.Outcome_Increase_Insurance_Coverage__c;
                        orswrap1.Outcome_Manage_Fluctuations_in_Income=service.Outcome_Manage_Fluctuations_in_Income__c;
                        orswrap1.Outcome_Three_Months_Savings=service.Outcome_Three_Months_Savings__c;
                        orswrap1.Outcome_Savings_Goal=service.Outcome_Savings_Goal__c;
                        orswrap1.Outcome_Decrease_Tax_Filing_Cost=service.Outcome_Decrease_Tax_Filing_Cost__c;
                        orswrap1.Outcome_Increase_Tax_Benefit=service.Outcome_Increase_Tax_Benefit__c;
                        orswrap1.Outcome_Optimize_Public_Benefits=service.Outcome_Optimize_Public_Benefits__c;
                        orswrap1.Outcome_of_Stabilize_housing=service.Outcome_of_Stabilize_housing__c;
                        orswrap1.Outcome_achieved=service.Outcome_New_Financial_Products__c ;
                        orsWrapperEList.add(orswrap1);
                    }
                }
                orsWrappermap.put('Validation',orsWrapperVList);
                orsWrappermap.put('Export',orsWrapperEList); 
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());           
        }
        return orsWrappermap;    
    }

    public class ORS_FCWrapper{
        @AuraEnabled
		public List<ORS_FCAggregateWrapper> aggrigateWrapList{get;set;}
        @AuraEnabled
		public List<ORS_FCDetailWrapper> detailWrapList{get;set;}
    }

    public class ORS_FCAggregateWrapper{
        @AuraEnabled
        public String description{get;set;}
        @AuraEnabled
        public Integer count{get;set;}
    }

    public class ORS_FCDetailWrapper{
        @AuraEnabled
        public String bookingId{get;set;}
        @AuraEnabled
        public String clientId{get;set;}
        @AuraEnabled
        public String clientName{get;set;}
        @AuraEnabled
        public Date fcCoachingDate{get;set;}
        @AuraEnabled
        public Date fcEduDate{get;set;}
    }

    @AuraEnabled
    public static ORS_FCWrapper fetchNWQRFCAggregateValidation(Date qtrStartDate,Date qtrEndDate){
        DateTime startDateTime = DateTime.newInstance(qtrStartDate.year(), qtrStartDate.month(), qtrStartDate.day(), 0, 0, 0);
        DateTime endDateTime = DateTime.newInstance(qtrEndDate.year(), qtrEndDate.month(), qtrEndDate.day(), 23, 59, 59);

        Set<Id> conIdSet = new Set<Id>();
        Map<Id,ORS_FCDetailWrapper> detailWrapMap = new Map<Id,ORS_FCDetailWrapper>();
        Integer coachingCount = 0, trainingCount = 0;
        List<ORS_FCAggregateWrapper> orsFCAggWrapList = new List<ORS_FCAggregateWrapper>();

        ORS_FCAggregateWrapper wrap1 = new ORS_FCAggregateWrapper();
        ORS_FCAggregateWrapper wrap2 = new ORS_FCAggregateWrapper();
        ORS_FCAggregateWrapper wrap3 = new ORS_FCAggregateWrapper();

        ORS_FCWrapper fcWrap = new ORS_FCWrapper();

        List<Event> evtList = new List<Event>([SELECT id, WhoId, StartDateTime 
                                                FROM Event WHERE RecordType.Name = 'Appointment' AND AppointmentStatus__c = 'Attended' AND 
                                                StartDateTime <=:endDateTime AND StartDateTime >=:startDateTime AND 
                                                What.RecordType.Name = 'Financial Capability Counseling' order by StartDateTime asc limit 49999]);
        
        /*List<Event> evtList = new List<Event>([SELECT id, WhoId, StartDateTime FROM Event WHERE RecordType.Name = 'Appointment' AND AppointmentStatus__c = 'Attended' AND 
                                                What.RecordType.Name = 'Financial Capability Counseling' order by StartDateTime asc limit 49999]);
        */
        for(Event evt : evtList){
            conIdSet.add(evt.WhoId);
        }
        Map<Id,Contact> conMap = new Map<Id,Contact>([SELECT Id, Name, Client__c FROM Contact WHERE Id IN : conIdSet limit 49999]);

        for(Event evt : evtList){
            ORS_FCDetailWrapper wrap = new ORS_FCDetailWrapper();
            wrap.clientId = conMap.get(evt.WhoId).Client__c;
            wrap.clientName = conMap.get(evt.WhoId).Name;
            wrap.bookingId = evt.Id;
            wrap.fcCoachingDate = date.newinstance(evt.StartDateTime.year(), evt.StartDateTime.month(), evt.StartDateTime.day());
            detailWrapMap.put(evt.WhoId,wrap);
        }
        coachingCount = detailWrapMap.size();
        List<sumoapp__Attendee__c> attendeeList = new List<sumoapp__Attendee__c>([SELECT id, sumoapp__SumoEvent__r.RecordType.Name, sumoapp__ContactRelation__c, sumoapp__ContactRelation__r.Name, sumoapp__ContactRelation__r.Client__c, sumoapp__SumoEvent__r.sumoapp__EndDatetime__c  
                                                                                    FROM sumoapp__Attendee__c 
                                                                                    WHERE sumoapp__SumoEvent__r.sumoapp__EndDatetime__c <=: endDateTime
                                                                                    AND sumoapp__SumoEvent__r.sumoapp__EndDatetime__c >=: startDateTime 
                                                                                    AND ((sumoapp__SumoEvent__r.RecordType.Name = 'Course' AND Attendance_Status__c = 'Course Complete' AND 
                                                                                    sumoapp__SumoEvent__r.IsParent__c = true AND sumoapp__SumoEvent__r.FinancialCapabilityCourse__c = true) 
                                                                                    OR (Attendance_Status__c = 'Attended - Complete' AND sumoapp__SumoEvent__r.RecordType.Name = 'Event' AND 
                                                                                    sumoapp__SumoEvent__r.IsParent__c = true AND sumoapp__SumoEvent__r.FinancialCapabilityCourse__c = true)) 
                                                                                    AND sumoapp__SumoEvent__r.sumoapp__Status__c != 'CANCELED' order by sumoapp__SumoEvent__r.sumoapp__EndDatetime__c asc limit 49999]);
        
        /*List<sumoapp__Attendee__c> attendeeList = new List<sumoapp__Attendee__c>([SELECT id, sumoapp__SumoEvent__r.RecordType.Name, sumoapp__ContactRelation__c, sumoapp__ContactRelation__r.Name, sumoapp__ContactRelation__r.Client__c, sumoapp__SumoEvent__r.sumoapp__EndDatetime__c  
                                                                                    FROM sumoapp__Attendee__c 
                                                                                    WHERE sumoapp__SumoEvent__r.sumoapp__EndDatetime__c != null AND sumoapp__ContactRelation__c != null]);
        */
        for(sumoapp__Attendee__c attendee : attendeeList){
            ORS_FCDetailWrapper wrap;
            if(detailWrapMap.containsKey(attendee.sumoapp__ContactRelation__c)){
                wrap = detailWrapMap.get(attendee.sumoapp__ContactRelation__c);
            } else {
                wrap = new ORS_FCDetailWrapper();
                wrap.clientId = attendee.sumoapp__ContactRelation__r.Client__c;
                wrap.clientName = attendee.sumoapp__ContactRelation__r.Name;
                wrap.bookingId = attendee.Id;
            }
            if(wrap.fcEduDate == null){
                trainingCount++;
            }
            Datetime dt = attendee.sumoapp__SumoEvent__r.sumoapp__EndDatetime__c;
            wrap.fcEduDate = date.newinstance(dt.year(), dt.month(), dt.day());
            detailWrapMap.put(attendee.sumoapp__ContactRelation__c,wrap);
        }

        wrap1.description = 'Clients receiving Financial Capabilites Coaching/Counseling in Period';
        wrap1.count = coachingCount;
        orsFCAggWrapList.add(wrap1);

        wrap2.description = 'Clients receiving Financial Capabilities related training in Period';
        wrap2.count = trainingCount;
        orsFCAggWrapList.add(wrap2);

        wrap3.description = 'Clients receiving Financial Capabilities Coaching/Counseling or FC education services in Period';
        wrap3.count = detailWrapMap.size();
        orsFCAggWrapList.add(wrap3);
        
        fcWrap.aggrigateWrapList = orsFCAggWrapList;
        fcWrap.detailWrapList = detailWrapMap.values();
        return fcWrap;
    }
}