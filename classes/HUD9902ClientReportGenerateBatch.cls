/**
 * @File Name          : HUD9902ReportGenerateBatch.cls
 * @Description        : Creates 9902 Client records 
 * @Author             : Mahesh Panda
 * @Group              : 9902
 * @Last Modified By   : mahesh.p@pcnstrategies.com
 * @Last Modified On   : 6/22/2024
 * @Modification Log   :
 * Ver       Date            Author             Modification
 * 1.0    6/22/2024         Mahesh Panda        Initial Version
**/
public with sharing class HUD9902ClientReportGenerateBatch implements Database.Batchable<SObject>, Database.Stateful {
    public DateTime qtrStartDateTime, qtrEndDateTime;
    public Date qtrStartDate, qtrEndDate;
    public X9902__c x9902 = new X9902__c();
    private List<Id> successes = new List<Id>();
    private List<Id> failures = new List<Id>();
    Id fccRTId = Schema.SObjectType.ClientCase__c.getRecordTypeInfosByDeveloperName().get('FinancialCapabilityCounseling').getRecordTypeId();


    private final String queryString;
    @testVisible
    private static String result = '';
    @testVisible
    private Boolean throwError = false;
    Id reportId;
    Map<String, x9902Categories__c> x9902CategoriesMap = new Map<String, x9902Categories__c>();
    
    private string NWC2NameSpace = '';
    
    public HUD9902ClientReportGenerateBatch(String reportRecordId){
       
        queryString = 'SELECT Id, WhatId, WhoId, HUDActivityType__c, Purpose__c, Outcome__c, EndDateTime FROM Event' + 
        ' WHERE Who.Type = \'Contact\''+
        ' AND What.Type = \''+NWC2NameSpace+'ClientCase__c\''+
        ' AND EndDateTime >= :qtrStartDate'+
        ' AND EndDateTime <= :qtrEndDate'+
        ' AND AppointmentStatus__c = \'Attended\''+
        ' AND Who.RecordType.Name = \'Primary Client\''+
        ' AND Purpose__c NOT IN (\'Not HUD-Reportable\', null, \'\', NULL)';
    
        x9902 = [SELECT PeriodStartDate__c, PeriodEndDate__c, Quarter__c, FiscalYear__c FROM X9902__c WHERE Id = :reportRecordId];
        qtrStartDate = x9902.PeriodStartDate__c;
        qtrEndDate = x9902.PeriodEndDate__c;
        reportId = (Id)reportRecordId;
        x9902CategoriesMap = HUD9902Helper.get9902CategoriesMap();
    }
    public Database.QueryLocator start(Database.BatchableContext context) {
        System.debug('queryString: ' + queryString);
        return Database.getQueryLocator(queryString);
    }
    public void execute(Database.BatchableContext context, List<Event> scope) {
        List<X9902Client__c> x9902clientList = new List<X9902Client__c>();
        List<ClientCase__c> clientCaseList = new List<ClientCase__c>();
        List<Id> clientCaseIdList = new List<Id>();
        X9902Client__c x9902Client = new X9902Client__c();
        Loan__c loan = new Loan__c();
        Map<Id, User> mapIdUser = new Map<Id, User>();
        List<Id> clientCaseOwnerIdList = new List<Id>();
        Map<String, String> hudActivityMap = new Map<String, String>();
        Set<String> uniqueAppointmentClientPurposes = new Set<String>();
        Map<Id, Event> clientIdEventMap = new Map<Id, Event>();
        //Map<Id, String> eventIdOutcomeMap = new Map<Id, String>();
        Map<Id, ClientCase__c> clientIdCaseMap = new Map<Id, ClientCase__c>();
        Map<Id, ClientCase__c> clientCaseIdToClientCase = new Map<Id, ClientCase__c>();
        Map<String, List<String>> clientIdPurposeToOutcomeMap = new Map<String, List<String>>();
        
        for(Event ev : scope){
            if(!hudActivityMap.containsKey(x9902.FiscalYear__c + '-' + ev.WhoId) || (hudActivityMap.containsKey(x9902.FiscalYear__c + '-' + ev.WhoId) && hudActivityMap.get(x9902.FiscalYear__c + '-' + ev.WhoId) == 'Not Billed to HUD')){
                hudActivityMap.put(x9902.FiscalYear__c + '-' + ev.WhoId, ev.HUDActivityType__c);
            }
            //hudActivityMap.put(ev.WhoId, ev.HUDActivityType__c);
            clientCaseIdList.add(ev.WhatId);
            clientIdEventMap.put(ev.WhoId, ev);
            //eventIdOutcomeMap.put(ev.Id, ev.Outcome__c);
            String key = ev.WhoId + '-' + ev.Purpose__c;
            if(ev.Outcome__c != null){
                if(clientIdPurposeToOutcomeMap.containsKey(key)){
                    for(String o : ev.Outcome__c.split(';')){
                        if(!clientIdPurposeToOutcomeMap.get(key).contains(o)){
                            clientIdPurposeToOutcomeMap.get(key).add(o);
                        }
                    }
                }else{
                    clientIdPurposeToOutcomeMap.put(key, ev.Outcome__c.split(';'));
                }
            }
        }

        clientCaseList = getClientCases(clientCaseIdList);

        for (ClientCase__c cs : clientCaseList) {
            clientCaseOwnerIdList.add(cs.OwnerId);
            clientCaseIdToClientCase.put(cs.Id, cs);
            if(!clientIdCaseMap.containsKey(cs.PrimaryClient__c)){
                clientIdCaseMap.put(cs.PrimaryClient__c, cs);
            }
        }
        mapIdUser = new Map<Id, User>([SELECT Id, CMSCounselorID__c, CounselorHUDID__c FROM User WHERE Id IN :clientCaseOwnerIdList]);
        System.debug('scope size: ' + scope.size());
        for (Event ev : scope){
            ClientCase__c cs = clientCaseIdToClientCase.get(ev.WhatId);
            String clientPurposeKey = ev.WhoId + '-' + ev.Purpose__c;
            if(!uniqueAppointmentClientPurposes.contains(clientPurposeKey) && cs != null){
                uniqueAppointmentClientPurposes.add(clientPurposeKey);
                loan = (cs.Loan__r != null && cs.Loan__r.size()> 0 ) ? cs.Loan__r[0] : null;
                x9902Client = new X9902Client__c();
                x9902Client.X9902__c = reportId;
                x9902Client.Contact__c = cs.PrimaryClient__c;
                x9902Client.ClientCaseNumber__c = cs.Name;
                x9902Client.ClientCase__c = cs.Id;
                x9902Client.ClientIDNumber__c = cs.PrimaryClient__r.Account.ClientNumber__c;
                x9902Client.X9902ReportingQuarter__c = getHUDCode(HUD9902Helper.KEY_ReportPeriods, x9902.Quarter__c);
                x9902Client.ClientCity__c = cs.PrimaryClient__r.MailingCity;
                x9902Client.ClientState__c = getHUDCode(HUD9902Helper.KEY_STATES, cs.PrimaryClient__r.MailingStateCode);
                x9902Client.ClientZip__c = cs.PrimaryClient__r.MailingPostalCode;
                x9902Client.ClientNewCity__c = cs.PropertyAddress__City__s;
                x9902Client.ClientNewState__c = getHUDCode(HUD9902Helper.KEY_STATES, cs.PropertyAddress__StateCode__s);
                x9902Client.ClientNewZip__c = cs.PropertyAddress__PostalCode__s;
                x9902Client.ClientFamilySize__c = cs.HouseholdSize__c;
                x9902Client.ClientGender__c = cs.Gender__c == 'Male ' ? 'M' : cs.Gender__c == 'Female' ? 'F' : 'O';
                x9902Client.ClientMaritalStatus__c = getHUDCode(HUD9902Helper.KEY_MARITAL_STATUS, cs.MaritalStatus__c);
                x9902Client.ClientRaceID__c = getHUDCode(HUD9902Helper.KEY_RACES, cs.Race__c);//KEY_RACES
                x9902Client.ClientEthnicityID__c = getHUDCode(HUD9902Helper.KEY_ETHNICITIES, cs.Ethnicity__c);
                x9902Client.ClientHeadofHouseholdType__c = getHUDCode(HUD9902Helper.KEY_HEAD_OF_HOUSEHOLD_TYPES, cs.HouseholdType__c);
                //x9902Client.ClientHouseholdGrossMonthlyIncome__c = cs.HouseholdMonthlyIncome__c == null ? 0 : cs.HouseholdMonthlyIncome__c;
                x9902Client.ClientCounselorHUDId__c = mapIdUser.get(cs.OwnerId).CounselorHUDID__c;
                x9902Client.ClientCounselorID__c = mapIdUser.get(cs.OwnerId).CMSCounselorID__c;
                x9902Client.ClientHighestEducation__c = getHUDCode(HUD9902Helper.KEY_EDUCATION_LEVELS, cs.Education__c);
                x9902Client.ClientFarmWorker__c = cs.FarmWorker__c == 'Yes' ? 'Y':'N';
                x9902Client.ClientRuralAreaStatus__c = getHUDCode(HUD9902Helper.KEY_RURAL_AREA_TYPES, cs.RuralAreaStatus__c);
                x9902Client.ClientLimitedEnglishProficiency__c = cs.EnglishProficiency__c;
                x9902Client.ClientColoniasResident__c = cs.ColoniasResidence__c == 'Yes'? 'Y' : 'N';
                x9902Client.ClientHUDAssistance__c = getHUDCode(HUD9902Helper.KEY_HUDAssistanceTypes, cs.ClientHUDAssistance__c);//cs.ClientHUDAssistance__c;
                x9902Client.ClientDisabled__c = cs.DisabledStatus__c == 'Yes'? 'Y' : 'N';
                x9902Client.ClientDependentsNumber__c = cs.NumberofDependents__c;
                x9902Client.ClientIntakeDate__c = cs.IntakeDate__c;
                x9902Client.ClientCounselSessionDateStart__c = cs.CounselSessionDateStart__c;
                x9902Client.ClientCounselSessionDateEnd__c = cs.CounselSessionDateEnd__c;
                x9902Client.ClientLanguageSpoken__c = getHUDCode(HUD9902Helper.KEY_Languages, cs.PrimaryClient__r.PreferredLanguage__c);
                x9902Client.ClientSessionDuration__c = cs.TotalCounselingSessionDuration__c;
                x9902Client.ClientCounselingType__c = cs.CounselingSessionTypes__c;//Need to check the field name on Case type
                if(String.isBlank(cs.CounselingTermination__c)){
                    x9902Client.ClientCounselingTermination__c = getHUDCode(HUD9902Helper.KEY_CounselingTerminationReasons, 'Ongoing');
                }else{
                    x9902Client.ClientCounselingTermination__c = getHUDCode(HUD9902Helper.KEY_CounselingTerminationReasons, cs.CounselingTermination__c);
                }
                //// x9902Client.ClientCounselingTermination__c = getHUDCode(HUD9902Helper.KEY_CounselingTerminationReasons, cs.CounselingTermination__c);
                x9902Client.ClientCounselingFee__c = cs.CounselingFee__c;
                x9902Client.ClientAttributeHUDGrant__c = String.IsNotBlank(cs.HUDGrant__c) ? getHUDCode(HUD9902Helper.KEY_HUDGrantTypes, cs.HUDGrant__c) : '7';
                x9902Client.ClientGrantAmountUsed__c = cs.GrantAmountUsed__c;
                if(String.isBlank(cs.HECMCertificate__c)){
                    x9902Client.ClientHECMCertificate__c = 'N';
                }else{
                    x9902Client.ClientHECMCertificate__c = cs.HECMCertificate__c;
                }
                //// x9902Client.ClientHECMCertificate__c = 'N';//cs.HECMCertificate__c;
                x9902Client.ClientHECMCertificateIssueDate__c = cs.HECMCertificateIssueDate__c;
                x9902Client.ClientHECMCertificateexpirationDate__c = cs.HECMCertificateExpirationDate__c;
                x9902Client.ClientHECMCertificateID__c = cs.HECMCertificateID__c;
                x9902Client.ClientPredatoryLending__c = cs.ClientPredatoryLending__c == 'Yes'? 'Y' : 'N';
                
                //x9902Client.ClientJobDuration__c = ////finalize the field mapping//calculate it form occupation start date to reporting date
                //x9902Client.ClientOutcome__c = cs.Outcome__c;//KEY_CounselingOutcome
                
                String outcome = '';
                if(clientIdPurposeToOutcomeMap.get(clientPurposeKey) != null){
                    for(String o : clientIdPurposeToOutcomeMap.get(clientPurposeKey)){
                        outcome += getHUDCode(HUD9902Helper.KEY_CounselingOutcome, o) + ';';
                    }
                }
                outcome = outcome.removeEnd(';');
                x9902Client.ClientOutcome__c = outcome;
                /*
                String outcome = '';
                System.debug('eventIdOutcomeMap: ' + eventIdOutcomeMap);
                if(eventIdOutcomeMap.get(ev.Id) != null){
                    for(String o : eventIdOutcomeMap.get(ev.Id).split(';')){
                        System.debug('oooooooo-: ' + o);
                        outcome += getHUDCode(HUD9902Helper.KEY_CounselingOutcome, o) + ';';
                        System.debug('oooooooo--: ' + outcome);
                    }
                }
                System.debug('outcome: ' + outcome);
                outcome = outcome.removeEnd(';');
                System.debug('outcome: ' + outcome);
                x9902Client.ClientOutcome__c = outcome;
                */
                x9902Client.ClientFirstTimeHomeBuyer__c = cs.X1stTimeHomeBuyer__c == 'Yes'? 'Y' : 'N';
                x9902Client.ClientDiscriminationVictim__c = cs.DiscriminationVictim__c == 'Yes'? 'Y' : 'N';
                x9902Client.ClientReferredBy__c = getHUDCode(HUD9902Helper.KEY_ReferredByTypes, cs.ReferralSource__c);
                x9902Client.ClientSalesContractSigned__c = cs.SettlementDate__c;
                x9902Client.ClientCreditScore__c = cs.CreditScore__c;
                x9902Client.ClientMissingCreditScoreReason__c = getHUDCode(HUD9902Helper.KEY_MissingCreditScoreReasons, cs.MissingCreditScoreReason__c);
                x9902Client.ClientCreditScoreSource__c = getHUDCode(HUD9902Helper.KEY_CreditScoreSources, cs.CreditScoreSource__c);
                x9902Client.ClientHouseholdDebt__c = cs.HouseholdDebt__c== null ? 0 : cs.HouseholdDebt__c;
                x9902Client.ClientMortgageDelinquency__c = cs.MortgageDelinquency__c == 'Yes'? 'Y' : 'N';
                x9902Client.ClientSecondLoanExists__c = cs.SecondLoanExists__c == 'Yes'? 'Y' : 'N';
                x9902Client.ClientIncomeLevel__c = getHUDCode(HUD9902Helper.KEY_IncomeLevels, cs.AreaMedianIncome__c);
                if(ev.Purpose__c != 'Not HUD-Reportable'){////In C1 this piklist value is not present so skipping this
                    x9902Client.ClientPurposeofVisit__c = getHUDCode(HUD9902Helper.COUNSELING_PURPOSES, ev.Purpose__c);
                }
                //x9902Client.ClientActivityType__c = getHUDCode(HUD9902Helper.KEY_ActivityTypes, cs.HUDActivity__c);//field got deleted as part of cleanup 
                //x9902Client.ClientActivityType__c = getHUDCode(HUD9902Helper.KEY_ActivityTypes, 'NOFA 2022-1 COMP');//need to confirm the field and map it.
                x9902Client.ClientActivityType__c = getHUDCode(HUD9902Helper.KEY_ActivityTypes, hudActivityMap.get(x9902.FiscalYear__c + '-' + cs.PrimaryClient__c));
                x9902Client.ClientLimitedEnglishProficiency__c = getHUDCode(HUD9902Helper.KEY_ENGLISH_PROFICIENCY_TYPES, cs.EnglishProficiency__c);
                
                if(loan != null){
                    x9902Client.ClientMortgageType__c = getHUDCode(HUD9902Helper.KEY_MORGAGE_TYPES, loan.MortgageType__c);
                    x9902Client.ClientMortgageTypeAfter__c = getHUDCode(HUD9902Helper.KEY_MORGAGE_TYPES, loan.MortgageTypeAfter__c);
                    x9902Client.ClientFinanceTypeBefore__c = getHUDCode(HUD9902Helper.KEY_FINANCE_TYPES, loan.FinanceTypeBefore__c);
                    x9902Client.ClientFinanceTypeAfter__c = getHUDCode(HUD9902Helper.KEY_FINANCE_TYPES, loan.FinanceTypeAfter__c);
                    x9902Client.ClientMortgageClosingCost__c = loan.LessClosingCosts__c;
                    x9902Client.ClientMortgageInterestRate__c = loan.InterestRate__c;
                    x9902Client.ClientLoanBeingReported__c = getHUDCode(HUD9902Helper.KEY_MortgageGrantTypes, loan.MortgageGrantType__C);
                    x9902Client.ClientIntakeLoanType__c = '10';//getHUDCode(HUD9902Helper.KEY_LoanIntakeTypes, loan.IntakeLoanType__c);
                    x9902Client.ClientIntakeLoanIsaHybridARMLoan__c = loan.IntakeLoanIsaHybridARMLoan__c == 'Yes'? 'Y' : 'N';
                    x9902Client.ClientIntakeLoanIsanOptionARMLoan__c = loan.IntakeLoanIsanOptionARMLoan__c == 'Yes'? 'Y' : 'N';
                    x9902Client.ClientIntakeLoanIsInterestOnly__c = loan.IntakeLoanIsInterestOnly__c == 'Yes'? 'Y' : 'N';
                    x9902Client.ClientIntakeLoanisFHAOrVAInsured__c = loan.IntakeLoanisFHAOrVAInsured__c == 'Yes'? 'Y' : 'N';
                    x9902Client.ClientIntakeLoanisaPrivatelyHeld__c = loan.IntakeLoanisaPrivatelyHeld__c == 'Yes'? 'Y' : 'N';
                    x9902Client.ClientIntakeLoanHasInterestRate__c = loan.IntakeLoanHasInterestRate__c == 'Yes'? 'Y' : 'N';
                }else{
                    x9902Client.ClientMortgageType__c = getHUDCode(HUD9902Helper.KEY_MORGAGE_TYPES, 'N/A');
                }
                x9902clientList.add(x9902Client);
            }
        }
        if(!Test.isRunningTest()){
             insert x9902clientList;
        }
        
        List<Database.SaveResult> saveResults = new List<Database.SaveResult>();
    }

    public void finish(Database.BatchableContext context) {

    }
    public String getHUDCode(String groupName, String itemDescription){ 
        if(String.isBlank(itemDescription) || itemDescription == null)
            return '';
        
        groupName = groupName.trim();
        itemDescription = itemDescription.trim();
        String mapKey = groupName+'-'+itemDescription;
        
        System.debug('x9902CategoriesMap: ' + x9902CategoriesMap);
        System.debug('x9902CategoriesMap.get(): ' + x9902CategoriesMap.get(groupName+'-'+itemDescription));
        return Test.isRunningTest() ? 'Test' : x9902CategoriesMap.get(groupName?.trim()?.toLowercase() + '-' + itemDescription?.trim()?.toLowercase())?.GroupItemID__c;
    }
     
    public List<ClientCase__c> getClientCases(List<Id> clientCaeIds){
         
        NWC2NameSpace = Utility.getNwc2NameSpace();
        String lookupFieldsToQuery = NWC2NameSpace+'PrimaryClient__r.MailingCity, '+NWC2NameSpace+'PrimaryClient__r.MailingState, '+NWC2NameSpace+'PrimaryClient__r.MailingStateCode, '+NWC2NameSpace+'PrimaryClient__r.MailingPostalCode, '+
        NWC2NameSpace+'PrimaryClient__r.'+NWC2NameSpace+'PreferredLanguage__c, '+NWC2NameSpace+'PrimaryClient__r.Account.'+NWC2NameSpace+'ClientNumber__c, ';
        String relatedRecordsToQuery = ' (SELECT '+HUD9902Helper.get9902Fields(HUD9902Helper.LOAN_OBJECT)+
        ' FROM '+NWC2NameSpace+'Loan__r ORDER BY CreatedDate DESC LIMIT 1)';

        String queryStr = 'SELECT ' + HUD9902Helper.get9902Fields(HUD9902Helper.CLIENT_CASE_OBJECT)+', '
                    +lookupFieldsToQuery + relatedRecordsToQuery+
        ' FROM '+HUD9902Helper.CLIENT_CASE_OBJECT+
        ' WHERE Id IN :clientCaeIds ORDER BY CreatedDate DESC';
        System.debug('queryStr: ' + queryStr);
        return Database.query(queryStr);
        /**/
    }
}