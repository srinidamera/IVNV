public class NWQRClientsReportController {

    public class OrsReportWrapper{
        @AuraEnabled 
        public String recordid{get;set;} 
        @AuraEnabled 
        public String ClientID{get;set;}
        @AuraEnabled
        public Decimal Total_Cost{get;set;}
        @AuraEnabled
        public Decimal TotalCostsQCCheck{get;set;} 
        @AuraEnabled
        public String Settlement_Date{get;set;} 
        @AuraEnabled
        public String ORS_Clients_Financing{get;set;} 
        @AuraEnabled
        public String ORS_Name{get;set;} 
        @AuraEnabled
        public String Total_Costs_Match{get;set;}
        @AuraEnabled
        public String Total_Costs_Match_Excel{get;set;}
        @AuraEnabled
        public String Age_Check{get;set;}   
        @AuraEnabled
        public String Household_Income_Band_Missing{get;set;}
        @AuraEnabled
        public String Property_Check{get;set;}
        @AuraEnabled
        public String New_Homeowner_Counseling_Provided{get;set;} 
        @AuraEnabled
        public String Client_ID{get;set;} 
        @AuraEnabled
        public String Privacy_Notice_Opt_Out{get;set;} 
        @AuraEnabled
        public String NWO_Role{get;set;}
        @AuraEnabled
        public String Services_Provided_to_Existing_Home_Owner{get;set;}
        @AuraEnabled
        public String NWO_Provided_Lending_Services{get;set;} 
        @AuraEnabled
        public String NWO_Provided_Counseling_Education{get;set;}
        @AuraEnabled
        public String Formal_Partnering_Org_Provided_Service{get;set;}
        @AuraEnabled
        public String Service_Provided_by_Formal_Partner_Org{get;set;}
        @AuraEnabled
        public String PCode_of_Partner_Org{get;set;}
        @AuraEnabled
        public String Provide_Real_Estate_Agent_Services{get;set;}
        @AuraEnabled
        public String RehaborReplacementNat{get;set;}
        @AuraEnabled
        public String Last_Name{get;set;}
        @AuraEnabled
        public String First_Name{get;set;}
        @AuraEnabled
        public String Middle_Name{get;set;}
        @AuraEnabled
        public String Age{get;set;}
        @AuraEnabled
        public String Gender{get;set;}
        @AuraEnabled
        public String Race{get;set;}
        @AuraEnabled
        public String Ethnicity_Latino{get;set;}
        @AuraEnabled
        public String X1st_Time_Buyer{get;set;}
        @AuraEnabled
        public String Veteran{get;set;}
        @AuraEnabled
        public String Active_Military{get;set;}
        @AuraEnabled
        public String Household_Family_Size{get;set;}
        @AuraEnabled
        public Decimal Household_Annual_Family_Income{get;set;}
        @AuraEnabled
        public String Household_Income_Band{get;set;}
        @AuraEnabled
        public Date Intake_Date{get;set;}
        @AuraEnabled
        public String Individual_Counseling_Hours_by_Org{get;set;}
        @AuraEnabled
        public String Group_Ed_total_Hours_In_Person{get;set;}
        @AuraEnabled
        public String Group_Ed_Total_Hours_Online{get;set;}
        @AuraEnabled
        public String Other_Org_Group_Counseling_Hours{get;set;}
        @AuraEnabled
        public String First_Credit_Score{get;set;}
        @AuraEnabled
        public String Address{get;set;}
        @AuraEnabled
        public Decimal Closing_cost{get;set;}
        @AuraEnabled
        public Decimal Rehab_Cost{get;set;}
        @AuraEnabled
        public Decimal Primary_Cost{get;set;}
        @AuraEnabled
        public String Foreclosure_Counseling_Outcome{get;set;}
        @AuraEnabled
        public String of_Units{get;set;}
        @AuraEnabled
        public String Zip{get;set;}
        @AuraEnabled
        public String State{get;set;}
        @AuraEnabled
        public String City{get;set;}
        @AuraEnabled
        public String Unit{get;set;}
        @AuraEnabled
        public String Street_Name{get;set;}
        @AuraEnabled
        public Decimal Other_Cost{get;set;}
        @AuraEnabled
        public String Mortgage_Insurance_Type{get;set;}
        @AuraEnabled
        public Decimal Monthly_mortgage_insurance_amount{get;set;}
        @AuraEnabled
        public Decimal Total_Monthly_Payment{get;set;}
        @AuraEnabled
        public String HBE_Provided_by_Other_Agency{get;set;}
        @AuraEnabled
        public String HBE_Provided_by_Other_Agency_Date{get;set;}
        @AuraEnabled
        public String Date_HBE_Provided_Check{get;set;}
        @AuraEnabled 
        public String Head_Of_Household_Type{get;set;}
        @AuraEnabled 
        public String RecordTypeName{get;set;}
        @AuraEnabled 
        public String In_Download{get;set;}
        @AuraEnabled 
        public String CaseSubType{get;set;}
    }

    public static List<ClientCase__c> getNWQRClientLst(Date qtrStartDate,Date qtrEndDate){
        Map<Id,ClientCase__c> firstClientCaseMap, secondClientCaseMap, finalMap = new Map<Id,ClientCase__c>();
        
        firstClientCaseMap = new Map<Id,ClientCase__c>([select id, Name, ClientCaseName__c, ClientNumber__c, TotalCostsMatch__c, SettlementDate__c, AgeCheck__c, HouseholdIncomeBandMissing__c, PropertyCheck__c, CounselingAndEduHoursByOtherAgency__c, 
            NewHomeownerCounselingProvided__c, DateHBEProvidedCheck__c, HBEProvidedByOtherAgency__c, PrimaryClient__r.PrivacyNoticeOptOut1__c, NWORole__c, Gender__c, 
            ServicesProvidedToExistingHomeOwner__c, NWOProvidedLendingServices__c, NWOProvidedCounselingEducation__c, FormalPartneringOrgProvidedService__c, Age__c, ServiceProvidedbyFormalPartnerOrg__c,
            PCODEPartnerOrgProvidedService__c, ProvideRealEstateAgentServices__c, HealthCrisisNatDisasClimateResil__c, Race__c, Ethnicity__c, X1stTimeHomeBuyer__c, 
            Veteran__c, ActiveMilitary__c, HouseholdSize__c, HBECertDate__c, AnnualHouseholdIncome__c, CreatedDate, PrimaryClient__r.OnlineGroupEducationHours__c, HouseholdType__c, 
            PrimaryClient__r.InPersonGroupEducationHours__c, IndividualCounselingHoursByAgency__c, CreditScore__c, ClosingCosts__c, RehabCost__c, RehabAmount__c,
            PurchasePrice__c, RehabConstCostNotincinPrice__c, RehabConstrCostsincinPrice__c, CaseResolution__c, Units__c, RecordType.DeveloperName, OtherCost__c, CaseSubType__c, ClientCaseClosedDate__c,
            PrimaryClient__r.LastName, PrimaryClient__r.FirstName, PrimaryClient__r.MiddleName, AddressMailingStreet__c, Address__c, AreaMedianIncome__c ,TotalMonthlyPayment__c, ServiceCost__c,
            (Select id, MortgageInsuranceType__c, MonthlyMortgageInsuranceAmount__c, MonthlyPI__c, TotalMonthlyPayment__c from Loan__r where RecordType.DeveloperName = 'Loan' order by LienPosition__c asc) 
            from ClientCase__c where SettlementDate__c<=:qtrEndDate and SettlementDate__c>=:qtrStartDate and ClientCaseStatus__c = 'Closed - Complete' order by createddate desc limit 49999]);
        
        secondClientCaseMap = new Map<Id,ClientCase__c>([select id, Name, ClientCaseName__c, ClientNumber__c, TotalCostsMatch__c, ClientCaseClosedDate__c, AgeCheck__c, HouseholdIncomeBandMissing__c, PropertyCheck__c, CounselingAndEduHoursByOtherAgency__c, 
            NewHomeownerCounselingProvided__c, DateHBEProvidedCheck__c, HBEProvidedByOtherAgency__c, PrimaryClient__r.PrivacyNoticeOptOut1__c, NWORole__c, Gender__c, 
            ServicesProvidedToExistingHomeOwner__c, NWOProvidedLendingServices__c, NWOProvidedCounselingEducation__c, FormalPartneringOrgProvidedService__c, Age__c, ServiceProvidedbyFormalPartnerOrg__c,
            PCODEPartnerOrgProvidedService__c, ProvideRealEstateAgentServices__c, HealthCrisisNatDisasClimateResil__c, Race__c, Ethnicity__c, X1stTimeHomeBuyer__c, 
            Veteran__c, RehabConstCostNotincinPrice__c, RehabConstrCostsincinPrice__c, ActiveMilitary__c, HouseholdSize__c, HBECertDate__c, AnnualHouseholdIncome__c, CreatedDate, PrimaryClient__r.OnlineGroupEducationHours__c, HouseholdType__c, 
            PrimaryClient__r.InPersonGroupEducationHours__c, IndividualCounselingHoursByAgency__c, CreditScore__c, ClosingCosts__c, RehabCost__c, RehabAmount__c,
            PurchasePrice__c, CaseResolution__c, Units__c, RecordType.DeveloperName, OtherCost__c, CaseSubType__c, SettlementDate__c,
            PrimaryClient__r.LastName, PrimaryClient__r.FirstName, PrimaryClient__r.MiddleName, AddressMailingStreet__c, Address__c, AreaMedianIncome__c , TotalMonthlyPayment__c, ServiceCost__c, 
            (Select id, MortgageInsuranceType__c, MonthlyMortgageInsuranceAmount__c, MonthlyPI__c, TotalMonthlyPayment__c from Loan__r where RecordType.DeveloperName = 'Loan' order by LienPosition__c asc) 
            from ClientCase__c where ClientCaseClosedDate__c<=:qtrEndDate and ClientCaseClosedDate__c>=:qtrStartDate and ClientCaseStatus__c = 'Closed - Complete' AND ((RecordType.DeveloperName = 'HomeownerCounseling' AND CaseSubType__c = 'NW Client Other Based Services') OR RecordType.DeveloperName = 'MortgageDelinquencyAssistanceCounseling') order by createddate desc limit 49999]);
        
        finalMap.putAll(firstClientCaseMap); 
        finalMap.putAll(secondClientCaseMap);
            
        return finalMap.values();
    }

    @AuraEnabled
    public static map<string,list<OrsReportWrapper>> getOrsClientsUniqueList(Date qtrStartDate,Date qtrEndDate){
        map<String, list<OrsReportWrapper>> orsWrappermap = new map<string,list<OrsReportWrapper>>();
        list<OrsReportWrapper> orsWrapperList= new list<OrsReportWrapper>();
        list<OrsReportWrapper> orsWrapperFirstList= new list<OrsReportWrapper>();
        list<OrsReportWrapper> orsWrapperSecondList= new list<OrsReportWrapper>();
        list<OrsReportWrapper> orsWrapperThirdList= new list<OrsReportWrapper>();
        list<OrsReportWrapper> orsWrapperFourthList= new list<OrsReportWrapper>();
        list<OrsReportWrapper> orsWrapperEList= new list<OrsReportWrapper>();
        List<ClientCase__c > clientsValidationList = new List<ClientCase__c >();
        List<ClientCase__c > clientsExportList = new List<ClientCase__c >();


        try{
            clientsValidationList = getNWQRClientLst(qtrStartDate, qtrEndDate);
            List<NWQR_Picklist_Mapping__mdt> pickListAdj = [select id, Label__c, Value__c from NWQR_Picklist_Mapping__mdt 
                                                            where ObjectApiName__c = 'ClientCase__c' And  
                                                            (FieldApiName__c = 'Gender__c' OR FieldApiName__c = 'AreaMedianIncome__c' OR FieldApiName__c = 'Veteran__c' 
                                                            OR FieldApiName__c = 'ActiveMilitary__c' OR FieldApiName__c = 'X1stTimeHomeBuyer__c' OR FieldApiName__c = 'Race__c')];
            Map<String,String> labelValueMap = new Map<String,String>();
            for(NWQR_Picklist_Mapping__mdt mdt : pickListAdj){
                if(mdt.Value__c != null && mdt.Label__c != null){
                    labelValueMap.put(mdt.Value__c,mdt.Label__c);
                }
            }

            for(ClientCase__c client: clientsValidationList) {
                if((client.RecordType.DeveloperName == 'HomeownerCounseling' && client.CaseSubType__c == 'NW Rehab' && client.RehabCost__c < 2000) || (client.RecordType.DeveloperName == 'PrepurchaseHomebuyingCounseling' && client.CaseResolution__c != 'Fulfilled (Purchased housing)')){
                    continue;
                }
                OrsReportWrapper orswrap= new OrsReportWrapper();
                orswrap.recordid=client.id;
                orswrap.RecordTypeName = client.RecordType.DeveloperName;
                orswrap.ClientID=client.ClientNumber__c;
                orswrap.CaseSubType=client.CaseSubType__c;
                orswrap.Total_Costs_Match = client.TotalCostsMatch__c; 
                if((client.RecordType.DeveloperName == 'HomeownerCounseling' && client.CaseSubType__c == 'NW Client Other Based Services') || client.RecordType.DeveloperName == 'MortgageDelinquencyAssistanceCounseling'){
                    orswrap.Settlement_Date = client.ClientCaseClosedDate__c.month() + '/' + client.ClientCaseClosedDate__c.day() + '/' + client.ClientCaseClosedDate__c.year();
                }else{
                    orswrap.Settlement_Date = client.SettlementDate__c.month() + '/' + client.SettlementDate__c.day() + '/' + client.SettlementDate__c.year();
                }
                
                orswrap.ORS_Clients_Financing=client.ClientCaseName__c;
                orswrap.ORS_Name=client.ClientCaseName__c;
                orswrap.Age_Check=client.AgeCheck__c;
                orswrap.Household_Income_Band_Missing=client.HouseholdIncomeBandMissing__c;
                orswrap.Property_Check = client.PropertyCheck__c;
                orswrap.New_Homeowner_Counseling_Provided = client.NewHomeownerCounselingProvided__c;
                orswrap.Date_HBE_Provided_Check = client.DateHBEProvidedCheck__c;         
                orswrap.HBE_Provided_by_Other_Agency=client.HBEProvidedByOtherAgency__c;
                orswrap.HBE_Provided_by_Other_Agency_Date=String.valueOf(client.HBECertDate__c);
                orswrap.Client_ID=client.ClientNumber__c;
                orswrap.In_Download = 'No';
                if(client.PrimaryClient__r.PrivacyNoticeOptOut1__c){
                    orswrap.Privacy_Notice_Opt_Out = 'Yes';
                }else{
                    orswrap.Privacy_Notice_Opt_Out = 'No';
                }
                orswrap.NWO_Role=client.NWORole__c;
                orswrap.Services_Provided_to_Existing_Home_Owner=client.ServicesProvidedToExistingHomeOwner__c;
                orswrap.NWO_Provided_Lending_Services=client.NWOProvidedLendingServices__c;
                orswrap.NWO_Provided_Counseling_Education=client.NWOProvidedCounselingEducation__c;
                orswrap.Formal_Partnering_Org_Provided_Service=client.FormalPartneringOrgProvidedService__c;
                orswrap.Service_Provided_by_Formal_Partner_Org=client.ServiceProvidedbyFormalPartnerOrg__c;
                if(client.PCODEPartnerOrgProvidedService__c != null){
                    orswrap.PCode_of_Partner_Org=client.PCODEPartnerOrgProvidedService__c.substringAfter('-');    
                }
                orswrap.Provide_Real_Estate_Agent_Services=client.ProvideRealEstateAgentServices__c;
                orswrap.RehaborReplacementNat=(String.isEmpty(client.HealthCrisisNatDisasClimateResil__c) ? 'No Response' : client.HealthCrisisNatDisasClimateResil__c);
                orswrap.Age=string.valueof(client.Age__c);
                if(labelValueMap.containsKey(client.Gender__c)){
                    orswrap.Gender = labelValueMap.get(client.Gender__c);
                }else{
                    orswrap.Gender=client.Gender__c;
                }
                
                
                if(labelValueMap.containsKey(client.Race__c)){
                    orswrap.Race = labelValueMap.get(client.Race__c);
                }else{
                    orswrap.Race=client.Race__c;
                }
                orswrap.Ethnicity_Latino=client.Ethnicity__c;
                
                if(labelValueMap.containsKey(client.X1stTimeHomeBuyer__c)){
                    orswrap.X1st_Time_Buyer = labelValueMap.get(client.X1stTimeHomeBuyer__c);
                }else{
                    orswrap.X1st_Time_Buyer=client.X1stTimeHomeBuyer__c;
                }

                if(labelValueMap.containsKey(client.Veteran__c)){
                    orswrap.Veteran = labelValueMap.get(client.Veteran__c);
                }else{
                    orswrap.Veteran=client.Veteran__c;
                }

                if(labelValueMap.containsKey(client.ActiveMilitary__c)){
                    orswrap.Active_Military = labelValueMap.get(client.ActiveMilitary__c);
                }else{
                    orswrap.Active_Military=client.ActiveMilitary__c;
                }
                
                
                orswrap.Household_Family_Size=string.valueof(client.HouseholdSize__c);
                orswrap.Household_Annual_Family_Income=client.AnnualHouseholdIncome__c;
                if(labelValueMap.containsKey(client.AreaMedianIncome__c)){
                    orswrap.Household_Income_Band = labelValueMap.get(client.AreaMedianIncome__c);
                }else{
                    orswrap.Household_Income_Band=client.AreaMedianIncome__c; 
                }
                                
                orswrap.Intake_Date = client.CreatedDate.date();
                orswrap.Individual_Counseling_Hours_by_Org=client.IndividualCounselingHoursByAgency__c;
                if(client.PrimaryClient__r.OnlineGroupEducationHours__c == null)
                    orswrap.Group_Ed_Total_Hours_Online='0';
                else
                    orswrap.Group_Ed_Total_Hours_Online=string.valueof(client.PrimaryClient__r.OnlineGroupEducationHours__c);
                if(client.PrimaryClient__r.InPersonGroupEducationHours__c==null)
                    orswrap.Group_Ed_total_Hours_In_Person='0';
                else
                    orswrap.Group_Ed_total_Hours_In_Person=string.valueof(client.PrimaryClient__r.InPersonGroupEducationHours__c);
                orswrap.Other_Org_Group_Counseling_Hours = String.valueOf(client.CounselingAndEduHoursByOtherAgency__c != null ? client.CounselingAndEduHoursByOtherAgency__c : 0);
                orswrap.First_Credit_Score=string.valueof(client.CreditScore__c);
                orswrap.Closing_cost = client.ClosingCosts__c == null ? 0 : client.ClosingCosts__c;
                orswrap.Rehab_Cost = client.RehabAmount__c;
                if(client.CaseSubType__c == 'NW Rehab' && client.RecordType.DeveloperName != 'MortgageDelinquencyAssistanceCounseling'){
                    orswrap.Primary_Cost=client.RehabCost__c != null ? client.RehabCost__c : 0;
                } else if(client.CaseSubType__c == 'NW Client Other Based Services' && client.RecordType.DeveloperName == 'HomeownerCounseling'){
                    orswrap.Primary_Cost = client.ServiceCost__c;
                    orswrap.Rehab_Cost = 0;
                }else {
                    orswrap.Primary_Cost = client.PurchasePrice__c == null ? 0 : client.PurchasePrice__c;
                }
                
                if(client.RecordType.DeveloperName == 'MortgageDelinquencyAssistanceCounseling'){
                    orswrap.Foreclosure_Counseling_Outcome=client.CaseResolution__c;
                } else {
                    orswrap.Foreclosure_Counseling_Outcome = '';
                }
                
                orswrap.of_Units=string.valueof(client.Units__c);
                orswrap.Unit=string.valueof(client.Units__c);
                if(client.OtherCost__c == null){
                    orswrap.Other_Cost = 0;
                }else{
                    orswrap.Other_Cost=client.OtherCost__c;
                }
                if(client.Loan__r.size() > 0){
                    orswrap.Mortgage_Insurance_Type=client.Loan__r[0].MortgageInsuranceType__c;
                } else {
                    orswrap.Mortgage_Insurance_Type='';
                }
                if(client.Loan__r.size() > 0 && client.Loan__r[0].MonthlyMortgageInsuranceAmount__c != null && client.Loan__r[0].MonthlyMortgageInsuranceAmount__c > 0){
                    orswrap.Monthly_mortgage_insurance_amount = client.Loan__r[0].MonthlyMortgageInsuranceAmount__c;
                } else {
                    orswrap.Monthly_mortgage_insurance_amount = 0.00;
                }
                orswrap.Total_Monthly_Payment = client.TotalMonthlyPayment__c;
                orswrap.NWO_Provided_Counseling_Education=client.NWOProvidedCounselingEducation__c;
                orswrap.Head_Of_Household_Type = String.isNotBlank(client.HouseholdType__c) ? client.HouseholdType__c : 'Head of Household Type missing';
                orswrap.Last_Name=client.PrimaryClient__r.LastName;
                orswrap.First_Name=client.PrimaryClient__r.FirstName;
                orswrap.Middle_Name=client.PrimaryClient__r.MiddleName;
                orswrap.Address=client.AddressMailingStreet__c;
                if(client.Address__c != null){
                    orswrap.Zip=client.Address__c.getpostalCode();
                    orswrap.State=client.Address__c.getStateCode();
                    orswrap.City=client.Address__c.getcity();
                    orswrap.Street_Name=client.Address__c.getstreet();
                }
                if (orswrap.ClientID != null && String.isNotBlank(orswrap.ClientID.toString()) &&
                    orswrap.Privacy_Notice_Opt_Out != null && String.isNotBlank(orswrap.Privacy_Notice_Opt_Out.toString()) &&
                    orswrap.NWO_Role != null && String.isNotBlank(orswrap.NWO_Role.toString()) &&
                    orswrap.Services_Provided_to_Existing_Home_Owner != null && String.isNotBlank(orswrap.Services_Provided_to_Existing_Home_Owner.toString()) &&
                    orswrap.NWO_Provided_Lending_Services != null && String.isNotBlank(orswrap.NWO_Provided_Lending_Services.toString()) &&
                    orswrap.NWO_Provided_Counseling_Education != null && String.isNotBlank(orswrap.NWO_Provided_Counseling_Education.toString()) &&
                    orswrap.Formal_Partnering_Org_Provided_Service != null && String.isNotBlank(orswrap.Formal_Partnering_Org_Provided_Service.toString()) &&
                    ((orswrap.Provide_Real_Estate_Agent_Services != null && String.isNotBlank(orswrap.Provide_Real_Estate_Agent_Services.toString())) || 
                    (orswrap.NWO_Role == 'NWO Provides Services to an Existing Home Owner' || orswrap.NWO_Role == 'Foreclosure Mitigation Counseling')) &&
                    orswrap.Last_Name != null && String.isNotBlank(orswrap.Last_Name.toString()) &&
                    orswrap.First_Name != null && String.isNotBlank(orswrap.First_Name.toString()) &&
                    orswrap.Age != null && String.isNotBlank(orswrap.Age.toString()) &&
                    orswrap.Gender != null && String.isNotBlank(orswrap.Gender.toString()) &&
                    orswrap.Race != null && String.isNotBlank(orswrap.Race.toString()) &&
                    orswrap.Ethnicity_Latino != null && String.isNotBlank(orswrap.Ethnicity_Latino.toString()) &&
                    orswrap.X1st_Time_Buyer != null && String.isNotBlank(orswrap.X1st_Time_Buyer.toString()) &&
                    orswrap.Veteran != null && String.isNotBlank(orswrap.Veteran.toString()) &&
                    orswrap.Active_Military != null && String.isNotBlank(orswrap.Active_Military.toString()) &&
                    orswrap.Household_Family_Size != null && String.isNotBlank(orswrap.Household_Family_Size.toString()) &&
                    orswrap.Household_Income_Band != null && String.isNotBlank(orswrap.Household_Income_Band.toString()) &&
                    orswrap.Intake_Date != null && String.isNotBlank(orswrap.Intake_Date.toString()) &&
                    orswrap.Individual_Counseling_Hours_by_Org != null && String.isNotBlank(orswrap.Individual_Counseling_Hours_by_Org.toString()) &&
                    orswrap.Group_Ed_total_Hours_In_Person != null && String.isNotBlank(orswrap.Group_Ed_total_Hours_In_Person.toString()) &&
                    orswrap.Group_Ed_Total_Hours_Online != null && String.isNotBlank(orswrap.Group_Ed_Total_Hours_Online.toString()) &&
                    orswrap.Address != null && String.isNotBlank(orswrap.Address.toString()) &&
                    orswrap.Street_Name != null && String.isNotBlank(orswrap.Street_Name.toString()) &&
                    orswrap.City != null && String.isNotBlank(orswrap.City.toString()) &&
                    orswrap.State != null && String.isNotBlank(orswrap.State.toString()) &&
                    orswrap.Zip != null && String.isNotBlank(orswrap.Zip.toString()) &&
                    orswrap.of_Units != null && String.isNotBlank(orswrap.of_Units.toString()) &&
                    ((!(orswrap.RecordTypeName == 'HomeownerCounseling')) || (orswrap.Primary_Cost != null && orswrap.Primary_Cost.toString().length() > 0)) && 
                    ((!(orswrap.RecordTypeName == 'HomeownerCounseling')) || (orswrap.Rehab_Cost != null && orswrap.Rehab_Cost.toString().length() > 0)) && 
                    ((!(orswrap.RecordTypeName == 'HomeownerCounseling')) || (orswrap.Closing_cost != null && orswrap.Closing_cost.toString().length() > 0)) && 
                    ((!(orswrap.RecordTypeName == 'HomeownerCounseling')) || (orswrap.Other_Cost != null && orswrap.Other_Cost.toString().length() > 0)) && 
                    ((!(orswrap.RecordTypeName == 'HomeownerCounseling')) || (orswrap.Mortgage_Insurance_Type != null && orswrap.Mortgage_Insurance_Type.toString().length() > 0)) && 
                    ((!(orswrap.RecordTypeName == 'HomeownerCounseling')) || (orswrap.Monthly_mortgage_insurance_amount != null && orswrap.Monthly_mortgage_insurance_amount.toString().length() > 0)) && 
                    ((!(orswrap.RecordTypeName == 'HomeownerCounseling')) || (orswrap.Total_Monthly_Payment != null && orswrap.Total_Monthly_Payment.toString().length() > 0)) && 
                    orswrap.Settlement_Date != null && String.isNotBlank(orswrap.Settlement_Date)){
                    if(orswrap.Total_Costs_Match != 'Passed' || orswrap.Age_Check != 'Passed' || orswrap.Household_Income_Band_Missing != 'Passed' || 
                    orswrap.Property_Check != 'Passed' || orswrap.New_Homeowner_Counseling_Provided != 'Passed' || 
                    orswrap.Date_HBE_Provided_Check != 'Passed' || orswrap.HBE_Provided_by_Other_Agency == ''){
                        orsWrapperSecondList.add(orswrap);
                    } else {
                        if(client.RecordType.DeveloperName == 'HomeownerCounseling' && client.CaseSubType__c == 'NW Client Other Based Services'){
                            orswrap.In_Download = 'Yes (Summary)';
                            orsWrapperFourthList.add(orswrap);
                        } else {
                            orswrap.In_Download = 'Yes';
                            orsWrapperFirstList.add(orswrap);
                        }
                    }
                } else {
                    orsWrapperThirdList.add(orswrap);
                }
                
                
            }
            orsWrapperList = new list<OrsReportWrapper>();
            orsWrapperList.addAll(orsWrapperFirstList);
            orsWrapperList.addAll(orsWrapperFourthList);
            orsWrapperList.addAll(orsWrapperSecondList);
            orsWrapperList.addAll(orsWrapperThirdList);
            orsWrappermap.put('Valid',orsWrapperFirstList);
            orsWrappermap.put('ValidSummary',orsWrapperFourthList);
            orsWrappermap.put('Validation',orsWrapperList);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());           
        }
        return orsWrappermap;
    }
}