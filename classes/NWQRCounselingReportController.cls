/**
 * @description       : Controller of HudOrsCounselingReport lwc for NWQR reporting
 * @group             : 
**/
public with sharing class NWQRCounselingReportController {
    
    /*
    * @description : method to fetch Client Case records
    */
    @AuraEnabled
    public static List<OrsReportWrapper> fetchOrsCounselingRecords(Date dtStartdateClosed, Date dtEnddateClosed){
        List<OrsReportWrapper> orsWrapperList = new List<OrsReportWrapper>();

        List<String> purposeList = new List<String>{'Homeless Assistance','Pre-purchase/Homebuying','Rental Topics','Non-Delinquency Post-Purchase',
        'Reverse Mortgage','Resolving or Preventing Forward Mortgage Delinquency or Default','Resolving or Preventing Reverse Mortgage Delinquency or Default',
        'Disaster Preparedness Assistance','Disaster Recovery Assistance'};

        List<Id> clientCaseIdLst = new List<Id>();
        for(Event ob : [SELECT WhatId FROM Event where AppointmentStatus__c = 'Attended' and What.Type = 'ClientCase__c']){
            clientCaseIdLst.add(ob.WhatId);
        }

        List<ClientCase__c> clientCaseList = [select id, PrimaryClient__r.Client__c ,IntakeDate__c, Age__c, Gender__c, Race__c, 
                                              Ethnicity__c, DisabledStatus__c, HouseholdType__c, HouseholdSize__c, HouseholdMonthlyIncome1__c, 
                                              AreaMedianIncome__c, PrimaryClient__r.PreferredLanguage__c, PrimaryClient__r.RuralAreaStatus__c, ClientCaseClosedDate__c,
                                              Address__c, MailingAddressLine2__c, Purpose__c, LastEventDate__c,
                                              One_on_One_Disaster_Preparedness_Assista__c, One_on_One_Disaster_Recovery_Assistance__c, One_on_One_Forward_Mortgage_Delinquency__c, 
                                              One_on_One_Homeless_Assistance__c, One_on_One_Non_Delinquency_Post_Purchase__c, One_on_One_Pre_purchase_Homebuying__c,
                                              One_on_One_Rental_Topics__c, One_on_One_Reverse_Mortgage__c, One_on_One_Reverse_Mortgage_Delinquency__c 
                                              from ClientCase__c
                                              where ClientCaseClosedDate__c <=: dtEnddateClosed and ClientCaseClosedDate__c >=: dtStartdateClosed
                                              and ClientCaseStatus__c = 'Closed - Complete' and Purpose__c != null and id IN : clientCaseIdLst and Purpose__c IN : purposeList
                                              WITH SECURITY_ENFORCED limit 49999];

        List<NWQR_Picklist_Mapping__mdt> pickListAdj = [select id, Label__c, Value__c from NWQR_Picklist_Mapping__mdt where ObjectApiName__c = 'ClientCase__c' And (FieldApiName__c = 'AreaMedianIncome__c' OR FieldApiName__c = 'Gender__c' OR FieldApiName__c = 'Race__c')];
        Map<String,String> labelValueMap = new Map<String,String>();
        for(NWQR_Picklist_Mapping__mdt mdt : pickListAdj){
            if(mdt.Value__c != null && mdt.Label__c != null){
                labelValueMap.put(mdt.Value__c,mdt.Label__c);
            }
        }
        
        for(ClientCase__c clientCase : clientCaseList){
            if(clientCase.LastEventDate__c == null || clientCase.LastEventDate__c <= clientCase.ClientCaseClosedDate__c){
                OrsReportWrapper orswrap = new OrsReportWrapper();
            
                orswrap.Household_Number = clientCase.PrimaryClient__r.Client__c;
                orswrap.Date_Opened = clientCase.IntakeDate__c.format();
                orswrap.Current_Age = clientCase.Age__c;
                if(labelValueMap.containsKey(clientCase.Gender__c)){
                    orswrap.Head_of_Household_Gender = labelValueMap.get(clientCase.Gender__c);
                }else{
                    orswrap.Head_of_Household_Gender = clientCase.Gender__c;
                }

                if(labelValueMap.containsKey(clientCase.Race__c)){
                    orswrap.Head_of_Household_Race = labelValueMap.get(clientCase.Race__c);
                }else{
                    orswrap.Head_of_Household_Race = clientCase.Race__c;
                }
                orswrap.Head_of_Household_Ethnicity = clientCase.Ethnicity__c;
                if(clientCase.DisabledStatus__c == 'Yes'){
                    orswrap.Disabled = 'Disabled';
                }else if(clientCase.DisabledStatus__c == 'No'){
                    orswrap.Disabled = 'Not disabled';
                }
                orswrap.Household_Type = clientCase.HouseholdType__c;
                orswrap.Total_Household_Members = clientCase.HouseholdSize__c;
                orswrap.Household_Gross_Monthly_Income = clientCase.HouseholdMonthlyIncome1__c;
                if(labelValueMap.containsKey(clientCase.AreaMedianIncome__c)){
                    orswrap.Household_AMI = labelValueMap.get(clientCase.AreaMedianIncome__c);
                }else{
                    orswrap.Household_AMI = clientCase.AreaMedianIncome__c;
                }
                orswrap.Preferred_Language = clientCase.PrimaryClient__r.PreferredLanguage__c;
                if(clientCase.Address__c != null){
                    orswrap.BillingStreet = clientCase.Address__c.getstreet();
                    orswrap.BillingCity = clientCase.Address__c.getcity();
                    orswrap.BillingState = clientCase.address__c.getStateCode();
                    orswrap.BillingPostalCode = clientCase.Address__c.getpostalCode();
                }
                orswrap.Apt = clientCase.MailingAddressLine2__c;
                orswrap.ORS_Rural_Area_Status = clientCase.PrimaryClient__r.RuralAreaStatus__c;
                orswrap.One_on_One_Homeless_Assistance = clientCase.One_on_One_Homeless_Assistance__c;
                orswrap.One_on_One_Rental_Topics = clientCase.One_on_One_Rental_Topics__c;
                orswrap.One_on_One_Pre_purchase_Homebuying = clientCase.One_on_One_Pre_purchase_Homebuying__c;
                orswrap.One_on_One_Non_Delinquency_Post_Purchase = clientCase.One_on_One_Non_Delinquency_Post_Purchase__c;
                orswrap.One_on_One_Reverse_Mortgage = clientCase.One_on_One_Reverse_Mortgage__c;
                orswrap.One_on_One_Forward_Mortgage_Delinquency = clientCase.One_on_One_Forward_Mortgage_Delinquency__c;
                orswrap.One_on_One_Reverse_Mortgage_Delinquency = clientCase.One_on_One_Reverse_Mortgage_Delinquency__c;
                orswrap.One_on_One_Disaster_Preparedness_Assista = clientCase.One_on_One_Disaster_Preparedness_Assista__c;
                orswrap.One_on_One_Disaster_Recovery_Assistance = clientCase.One_on_One_Disaster_Recovery_Assistance__c;
                orswrap.Date_Closed = clientCase.ClientCaseClosedDate__c.format();
                orsWrapperList.add(orswrap);
            }
        }
        return orsWrapperList;
    }
    
    public class OrsReportWrapper{
        @AuraEnabled
        public String Household_Number;
        @AuraEnabled
        public String Date_Opened;
        @AuraEnabled
        public Decimal Current_Age;
        @AuraEnabled
        public String Head_of_Household_Gender;
        @AuraEnabled
        public String Head_of_Household_Race;
        @AuraEnabled
        public String Head_of_Household_Ethnicity;
        @AuraEnabled
        public String Disabled;
        @AuraEnabled
        public String Household_Type;
        @AuraEnabled
        public Decimal Total_Household_Members;
        @AuraEnabled
        public Decimal Household_Gross_Monthly_Income;
        @AuraEnabled
        public String Household_AMI;
        @AuraEnabled
        public String Preferred_Language;
        @AuraEnabled
        public String BillingStreet;
        @AuraEnabled
        public String Apt;
        @AuraEnabled
        public String BillingCity;
        @AuraEnabled
        public String BillingState;
        @AuraEnabled
        public String BillingPostalCode;
        @AuraEnabled
        public String ORS_Rural_Area_Status;
        @AuraEnabled
        public String One_on_One_Homeless_Assistance;
        @AuraEnabled
        public String One_on_One_Rental_Topics;
        @AuraEnabled
        public String One_on_One_Pre_purchase_Homebuying;
        @AuraEnabled
        public String One_on_One_Non_Delinquency_Post_Purchase;
        @AuraEnabled
        public String One_on_One_Reverse_Mortgage;
        @AuraEnabled
        public String One_on_One_Forward_Mortgage_Delinquency;
        @AuraEnabled
        public String One_on_One_Reverse_Mortgage_Delinquency;
        @AuraEnabled
        public String One_on_One_Disaster_Preparedness_Assista;
        @AuraEnabled
        public String One_on_One_Disaster_Recovery_Assistance;
        @AuraEnabled
        public String Date_Closed;
    }
    
}