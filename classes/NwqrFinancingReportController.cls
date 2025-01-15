/**
* @description       : Controller of NwqrFinancingReport lwc for NWQR reporting
* @group             : 
**/
public with sharing class NwqrFinancingReportController {
    
    /*
    * @description : method to fetch Loan records
    */
    @AuraEnabled
    public static List<NwqrReportWrapper> fetchNWQRFinancingReports(Date qtrStartDate, Date qtrEndDate){
        List<ClientCase__c> clientsValidationList = NWQRClientsReportController.getNWQRClientLst(qtrStartDate, qtrEndDate);
        Map<String, list<NWQRClientsReportController.OrsReportWrapper>> orsWrappermap = NWQRClientsReportController.getOrsClientsUniqueList(qtrStartDate, qtrEndDate);
        Set<Id> validIdSet = new Set<Id>();
        Set<Id> validSummaryIdSet = new Set<Id>();

        List<NwqrReportWrapper> firstList = new List<NwqrReportWrapper>();
        List<NwqrReportWrapper> secondList = new List<NwqrReportWrapper>();
        List<NwqrReportWrapper> thirdList = new List<NwqrReportWrapper>();
        List<NwqrReportWrapper> fourthList = new List<NwqrReportWrapper>();
        List<NwqrReportWrapper> fifthList = new List<NwqrReportWrapper>();

        if(orsWrappermap != null && orsWrappermap.containsKey('Valid')){
            for(NWQRClientsReportController.OrsReportWrapper wrap : orsWrappermap.get('Valid')){
                validIdSet.add(wrap.recordid);
            }
        }
        if(orsWrappermap != null && orsWrappermap.containsKey('ValidSummary')){
            for(NWQRClientsReportController.OrsReportWrapper wrap : orsWrappermap.get('ValidSummary')){
                validSummaryIdSet.add(wrap.recordid);
            }
        }

        List<Id> ClientCaseIdList = new List<Id>();
        list<NwqrReportWrapper> nwqrWrapperVList= new list<NwqrReportWrapper>();
        
        
        List<Loan__c > loanList = [select id, ClientCase__r.PrimaryClient__r.Client__c, FundingType__c, YourRoleAsMortgageUnderwriter__c, YourRoleAsMortgageOriginator__c,
                                   InterestRate__c, TermType__c, DeferredTerm__c, Forgiveable__c, FundingSource__c, FinancingType__c, Amount__c,
                                   MissingLoanDetails__c, EquityandOutofPocketInfo__c, RLFInfo__c, Name, RecordType.DeveloperName,ClientCase__c, 
                                   ClientCase__r.RecordType.DeveloperName, ClientCase__r.CaseSubType__c, ClientCase__r.RehabCost__c, ClientCase__r.CaseResolution__c  from Loan__c
                                   where Status__c in ('Approved','Verified') AND ClientCase__c IN : clientsValidationList WITH SECURITY_ENFORCED
                                   order by MissingLoanDetails__c desc limit 49999];

        for(Loan__c loan: loanList){
            if((loan.ClientCase__r.RecordType.DeveloperName == 'HomeownerCounseling' && loan.ClientCase__r.CaseSubType__c == 'NW Rehab' && loan.ClientCase__r.RehabCost__c < 2000) || (loan.ClientCase__r.RecordType.DeveloperName == 'PrepurchaseHomebuyingCounseling' && loan.ClientCase__r.CaseResolution__c != 'Fulfilled (Purchased housing)')){
                continue;
            }
            NwqrReportWrapper nwqrwrap= new NwqrReportWrapper();
            nwqrwrap.In_Download = 'No';
            nwqrwrap.recordid=loan.id;
            nwqrwrap.recordTypeName = loan.RecordType.DeveloperName;
            nwqrwrap.Client_ID = loan.ClientCase__r.PrimaryClient__r.Client__c;
            nwqrwrap.Amount = loan.Amount__c;
            nwqrwrap.Client_Case_ID = loan.ClientCase__c; 
            nwqrwrap.NWO_role_as_mortgage_underwriter = loan.YourRoleAsMortgageUnderwriter__c;
            nwqrwrap.NWO_role_as_mortgage_originator = loan.YourRoleAsMortgageOriginator__c;
            if(loan.InterestRate__c != null){
                String val = String.valueOf(loan.InterestRate__c);
                val = val.removeEnd('0');
                val = val.removeEnd('0');
                val = val.removeEnd('0');
                val = val.removeEnd('.');
                nwqrwrap.Rate = val + '%';
                nwqrwrap.RateNumeric = (loan.InterestRate__c / 100);
            }
            if(loan.TermType__c != null){
                nwqrwrap.Term = loan.TermType__c.replaceAll('Yr', '');
            }
            nwqrwrap.Deferred_Term = loan.DeferredTerm__c;
            nwqrwrap.Missing_Loan_Details = loan.MissingLoanDetails__c;
            nwqrwrap.Equity_and_Out_of_Pocket_Info = loan.EquityandOutofPocketInfo__c;
            nwqrwrap.RLF_Info = loan.RLFInfo__c;
            nwqrwrap.Loan_Record_Number = loan.Name;
            if(loan.Forgiveable__c){
                nwqrwrap.Forgivable = 'Yes';
            }else{
                nwqrwrap.Forgivable = 'No';
            }
            nwqrwrap.Obj_Name = 'Loan';
            nwqrwrap.ClientCaseRecordType = loan.ClientCase__r.RecordType.DeveloperName;
            nwqrwrap.ClientCaseSubType = loan.ClientCase__r.CaseSubType__c;
            if(nwqrwrap.recordTypeName == 'OutOfPocket'){
                nwqrwrap.Funding_Type = 'Client portion (out-of-pocket)' ;
                nwqrwrap.Funding_Source = 'Not Applicable';
                nwqrwrap.Financing_Type = 'Client out of pocket (total)';
                nwqrwrap.Forgivable = '';
            }else{
                nwqrwrap.Funding_Type = loan.FundingType__c ;
                nwqrwrap.Funding_Source = loan.FundingSource__c;
                nwqrwrap.Financing_Type = loan.FinancingType__c;
            }

            if(validIdSet.contains(loan.ClientCase__c) && nwqrwrap.Missing_Loan_Details == 'Passed' && nwqrwrap.Equity_and_Out_of_Pocket_Info == 'Passed' && nwqrwrap.RLF_Info == 'Passed'){
                nwqrwrap.In_Download = 'Yes';
            }
            if(validSummaryIdSet.contains(loan.ClientCase__c)){
                nwqrwrap.In_Download = 'Yes (Summary)';
            }
            if(nwqrwrap.In_Download == 'Yes' && nwqrwrap.Missing_Loan_Details == 'Passed' && nwqrwrap.Equity_and_Out_of_Pocket_Info == 'Passed' && nwqrwrap.RLF_Info == 'Passed'){
                firstList.add(nwqrwrap);
            } else if(nwqrwrap.Missing_Loan_Details == 'Passed' && nwqrwrap.Equity_and_Out_of_Pocket_Info == 'Passed' && nwqrwrap.RLF_Info == 'Passed'){
                secondList.add(nwqrwrap);
            } else if(nwqrwrap.In_Download == 'Yes'){
                thirdList.add(nwqrwrap);
            } else {
                fourthList.add(nwqrwrap);
            }
        }

        List<Grant__c> grantLst = [select id, Name, ClientCase__c, ClientCase__r.PrimaryClient__r.Client__c, FundingType__c, FundingSource__c, GrantType__c, 
                                    FinancingType__c, FundingAmount__c, Forgiveable__c, ClientCase__r.RecordType.DeveloperName, ClientCase__r.CaseSubType__c, ClientCase__r.RehabCost__c, ClientCase__r.CaseResolution__c 
                                  from Grant__c 
                                  where StatusType__c = 'Approved' AND ClientCase__c IN : clientsValidationList WITH SECURITY_ENFORCED limit 49999];
        for(Grant__c grant : grantLst){
            if((grant.ClientCase__r.RecordType.DeveloperName == 'HomeownerCounseling' && grant.ClientCase__r.CaseSubType__c == 'NW Rehab' && grant.ClientCase__r.RehabCost__c < 2000) || (grant.ClientCase__r.RecordType.DeveloperName == 'PrepurchaseHomebuyingCounseling' && grant.ClientCase__r.CaseResolution__c != 'Fulfilled (Purchased housing)')){
                continue;
            }
            NwqrReportWrapper nwqrwrap= new NwqrReportWrapper();
            nwqrwrap.In_Download = 'No';
            nwqrwrap.recordid=grant.id;
            nwqrwrap.Client_ID = grant.ClientCase__r.PrimaryClient__r.Client__c;
            nwqrwrap.Amount = grant.FundingAmount__c; 
            nwqrwrap.Funding_Type = grant.FundingType__c ;
            nwqrwrap.Funding_Source = grant.FundingSource__c;
            nwqrwrap.Financing_Type = grant.FinancingType__c;
            nwqrwrap.Client_Case_ID = grant.ClientCase__c;
            nwqrwrap.Loan_Record_Number = grant.Name;
            nwqrwrap.ClientCaseRecordType = grant.ClientCase__r.RecordType.DeveloperName;
            nwqrwrap.ClientCaseSubType = grant.ClientCase__r.CaseSubType__c;
            if(grant.Forgiveable__c){
                nwqrwrap.Forgivable = 'Yes';
            }else{
                nwqrwrap.Forgivable = 'No';
            }

            if(nwqrwrap.Amount == null || nwqrwrap.Funding_Type == null || nwqrwrap.Financing_Type == null){
                nwqrwrap.Missing_Loan_Details = 'failed';
            }else{
                nwqrwrap.Missing_Loan_Details = 'Passed';
            }
            if(validIdSet.contains(grant.ClientCase__c) && nwqrwrap.Missing_Loan_Details == 'Passed'){
                nwqrwrap.In_Download = 'Yes';
            }
            if(validSummaryIdSet.contains(grant.ClientCase__c)){
                nwqrwrap.In_Download = 'Yes (Summary)';
            }
            nwqrwrap.Obj_Name = 'Grant';
            if(nwqrwrap.In_Download == 'Yes' && nwqrwrap.Missing_Loan_Details == 'Passed' && nwqrwrap.Equity_and_Out_of_Pocket_Info == 'Passed' && nwqrwrap.RLF_Info == 'Passed'){
                firstList.add(nwqrwrap);
            } else if(nwqrwrap.In_Download == 'Yes (Summary)' && nwqrwrap.Missing_Loan_Details == 'Passed' && nwqrwrap.Equity_and_Out_of_Pocket_Info == 'Passed' && nwqrwrap.RLF_Info == 'Passed'){
                secondList.add(nwqrwrap);
            } else if(nwqrwrap.Missing_Loan_Details == 'Passed' && nwqrwrap.Equity_and_Out_of_Pocket_Info == 'Passed' && nwqrwrap.RLF_Info == 'Passed'){
                thirdList.add(nwqrwrap);
            } else if(nwqrwrap.In_Download == 'Yes'){
                fourthList.add(nwqrwrap);
            } else {
                fifthList.add(nwqrwrap);
            }
        }
        nwqrWrapperVList.addAll(firstList);
        nwqrWrapperVList.addAll(secondList);
        nwqrWrapperVList.addAll(thirdList);
        nwqrWrapperVList.addAll(fourthList);
        nwqrWrapperVList.addAll(fifthList);
        return nwqrWrapperVList;
    }
    
    public class NwqrReportWrapper{
        @AuraEnabled 
        public String In_Download;
        @AuraEnabled 
        public String recordid;
        @AuraEnabled 
        public String recordTypeName;
        @AuraEnabled 
        public String Missing_Required_Data;
        @AuraEnabled 
        public String Loan_Record_Number;
        @AuraEnabled 
        public String Client_ID;
        @AuraEnabled 
        public String Funding_Type;
        @AuraEnabled 
        public String Funding_Source;
        @AuraEnabled 
        public String Financing_Type;        
        @AuraEnabled
        public Decimal Amount;
        @AuraEnabled
        public String NWO_role_as_mortgage_underwriter; 
        @AuraEnabled
        public String NWO_role_as_mortgage_originator;
        @AuraEnabled
        public String Rate;
        @AuraEnabled
        public Decimal RateNumeric; 
        @AuraEnabled
        public String Term;
        @AuraEnabled
        public String Deferred_Term;
        @AuraEnabled
        public String Forgivable; 
        @AuraEnabled
        public String ORS_Clients_Financing; 
        @AuraEnabled
        public String ORS_id; 
        @AuraEnabled
        public String Equity_and_Out_of_Pocket_Info;  
        @AuraEnabled
        public String RLF_Info;  
        @AuraEnabled
        public String Missing_Loan_Details;
        @AuraEnabled
        public String Obj_Name; 
        @AuraEnabled
        public String ClientCaseRecordType; 
        @AuraEnabled
        public String ClientCaseSubType;  
        @AuraEnabled
        public String Client_Case_ID;
    }
    
}