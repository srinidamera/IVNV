public with sharing class HUD9902ClientSubmissionBatch implements Database.Batchable<SObject>, Database.Stateful, Database.AllowsCallouts {
    Id reportId;
    private string NWC2NameSpace = '';
    // private Integer xmlPartNumber;
    String requestXml;

    public HUD9902ClientSubmissionBatch(String reportRecordId){
        reportId = (Id)reportRecordId;
        NWC2NameSpace = Utility.getNwc2NameSpace();
        X9902__c x9902Rec = new X9902__c();
        x9902Rec.Id = reportId;
        x9902Rec.ClientXml__c = '';
        x9902Rec.ClientSubmissionID__c = '';
        x9902Rec.ClientSubmissionStatus__c = 'In Progress';
        update x9902Rec;
    }
    public Database.QueryLocator start(Database.BatchableContext context) {
        String queryString = 'SELECT ' + 
                                HUD9902Helper.get9902Fields(HUD9902Helper.X9902_CLIENT_OBJECT) +
                             ' FROM '+NWC2NameSpace+'X9902Client__c' +
                             ' WHERE '+NWC2NameSpace+'X9902__c =: reportId';
        return Database.getQueryLocator(queryString);
    }
    public void execute(Database.BatchableContext context, List<X9902Client__c> x9902Clients) {
        String submissionStatus;
        IntegrationSettings__c mc   = IntegrationSettings__c.getValues('HUD Settings');
        
        Integer agencyid   = integer.valueOf(mc.AgencyID__c);
        String agencyName  = mc.AgencyName__c;
        String vendorid    = mc.VendorID__c;
        String pw = mc.CMSPassword__c;
        
        X9902__c x9902 = [SELECT Id, PeriodEndDate__c FROM X9902__c WHERE Id =:reportId ];
        Map<String, HUD9902FiscalYear__c> fiscalYearCodeMap = HUD9902FiscalYear__c.getAll();
        String fiscalYear = fiscalYearCodeMap.get(getStringValueOf(x9902.PeriodEndDate__c.year())).FiscalYearID__c;
        String reportedMOnth = getStringValueOf(x9902.PeriodEndDate__c.month());
        
        
        // if (xmlPartNumber == 1) {
            requestXml = getStartRequestXml(x9902Clients);
        // } else if (xmlPartNumber == 2) {
        //     requestXml += getRequestXml(x9902Clients);
        // }
        String submissionId = HTTPCalloutService.postHUDReport(
            buildRequestBody(requestXml, agencyid, agencyName, vendorid, pw, fiscalYear)
            );
        Boolean chkStatus = true;
        System.debug('submissionId: ' + submissionId);
        x9902 = [SELECT Id, ClientXml__c, ClientSubmissionID__c, ClientSubmissionStatus__c FROM X9902__c WHERE Id = :reportId];
        x9902.Id = reportId;
        x9902.ClientSubmissionID__c = x9902.ClientSubmissionID__c != null ? x9902.ClientSubmissionID__c + ', ' + submissionId : submissionId;
        update x9902;

        ID jobID1 = System.enqueueJob(new HudSubmissionStatusCheck(blob.valueOf(requestXml), submissionId, reportId, 'Client_Summary'));
    }

    public void finish(Database.BatchableContext context) {
        // Hud9902StatusCheckBatch.scheduleForClientCase(this.reportId);
    }

    public static String getStringValueOf(Object fieldValue){
        if(fieldValue == null){
            return '';
        }else{
            return String.valueOf(fieldValue);
        }
    }

    public static String getStartRequestXml(List<X9902Client__c> x9902Clients) {
        XmlStreamWriter writer = new XmlStreamWriter();
        PrettyXmlStreamWriter w = new PrettyXmlStreamWriter(writer, 4);
        w.writeStartDocument('UTF-8','1.0');
        w.writeStartElement('tns','SubmissionData ','tns'); 
        w.writeAttribute('','','xsi:schemaLocation','http://gov.hud.arm/client_profile_databag_6_0 client_profile_databag_6_0.xsd');
        w.writeAttribute('','','xmlns:tns','http://gov.hud.arm/client_profile_databag_6_0');
        w.writeAttribute('','','xmlns:xsi','http://www.w3.org/2001/XMLSchema-instance');
        w.writeStartElement('tns','Client_Profiles','tns');
        for (X9902Client__c c : x9902Clients) {
            System.debug('X9902Client__c: ');
            w.writeStartElementNoIndentNewLine('tns','Client_Profile','tns'); 
            w.writeElementIfNotNullNoIndent('tns', 'Client_ID_Num', 'tns', getStringValueOf(c.ClientIDNumber__c));
            w.writeElementIfNotNullNoIndent('tns', 'Client_Case_Num', 'tns', getStringValueOf(c.ClientCaseNumber__c));
            w.writeElementIfNotNullNoIndent('tns', 'Client_City', 'tns', getStringValueOf(c.ClientCity__c));
            w.writeElementIfNotNullNoIndent('tns', 'Client_State', 'tns', getStringValueOf(c.ClientState__c));
            w.writeElementIfNotNullNoIndent('tns', 'Client_Zip', 'tns', getStringValueOf(c.ClientZip__c));
            w.writeElementIfNotNullNoIndent('tns', 'Client_New_City', 'tns', getStringValueOf(c.ClientNewCity__c));
            w.writeElementIfNotNullNoIndent('tns', 'Client_New_State', 'tns', getStringValueOf(c.ClientNewState__c));
            w.writeElementIfNotNullNoIndent('tns', 'Client_New_Zip', 'tns', getStringValueOf(c.ClientNewZip__c));
            w.writeElementIfNotNullNoIndent('tns', 'Client_Family_Size', 'tns', getStringValueOf(c.ClientFamilySize__c));
            w.writeElementIfNotNullNoIndent('tns', 'Client_Gender', 'tns', getStringValueOf(c.ClientGender__c));
            w.writeElementIfNotNullNoIndent('tns', 'Client_Marital_Status', 'tns', getStringValueOf(c.ClientMaritalStatus__c));
            w.writeElementIfNotNullNoIndent('tns', 'Client_Race_ID', 'tns', getStringValueOf(c.ClientRaceID__c));
            w.writeElementIfNotNullNoIndent('tns', 'Client_Ethnicity_ID', 'tns', getStringValueOf(c.ClientEthnicityID__c));
            w.writeElementIfNotNullNoIndent('tns', 'Client_Household_Gross_Monthly_Income', 'tns', getStringValueOf(c.ClientHouseholdGrossMonthlyIncome__c));
            w.writeElementIfNotNullNoIndent('tns', 'Client_Head_Of_Household_Type', 'tns', getStringValueOf(c.ClientHeadofHouseholdType__c));
            w.writeElementIfNotNullNoIndent('tns', 'Client_Counselor_ID', 'tns', getStringValueOf(c.ClientCounselorID__c));
            w.writeElementIfNotNullNoIndent('tns', 'Client_Counselor_HUD_Id', 'tns', getStringValueOf(c.ClientCounselorHUDId__c));
            w.writeElementIfNotNullNoIndent('tns', 'Client_Highest_Educ_Grade', 'tns', getStringValueOf(c.ClientHighestEducation__c));
            w.writeElementIfNotNullNoIndent('tns', 'Client_Farm_Worker', 'tns', getStringValueOf(c.ClientFarmWorker__c));
            w.writeElementIfNotNullNoIndent('tns', 'Client_Rural_Area', 'tns', getStringValueOf(c.ClientRuralAreaStatus__c));
            w.writeElementIfNotNullNoIndent('tns', 'Client_Limited_English_Proficiency', 'tns', getStringValueOf(c.ClientLimitedEnglishProficiency__c));
            w.writeElementIfNotNullNoIndent('tns', 'Client_Colonias_Resident', 'tns', getStringValueOf(c.ClientColoniasResident__c));
            w.writeElementIfNotNullNoIndent('tns', 'Client_HUD_Assistance', 'tns', getStringValueOf(c.ClientHUDAssistance__c));
            //w.writeElementIfNotNullNoIndent('tns', 'Client_HUD_Assistance', 'tns', '2');
            w.writeElementIfNotNullNoIndent('tns', 'Client_Disabled', 'tns', getStringValueOf(c.ClientDisabled__c));
            w.writeElementIfNotNullNoIndent('tns', 'Client_Dependents_Num', 'tns', getStringValueOf(c.ClientDependentsNumber__c));
            w.writeElementIfNotNullNoIndent('tns', 'Client_Intake_DT', 'tns', HUD9902Helper.getFormattedDate(c.ClientIntakeDate__c));
            if(c.ClientCounselSessionDateStart__c != null){
                w.writeElementIfNotNullNoIndent('tns', 'Client_Counsel_Start_Session_DateTime', 'tns', String.valueOf(c.ClientCounselSessionDateStart__c.format('MM-dd-yyyy hh:mm')));
            }
            if(c.ClientCounselSessionDateEnd__c != null){
                w.writeElementIfNotNullNoIndent('tns', 'Client_Counsel_End_Session_DateTime', 'tns', String.valueOf(c.ClientCounselSessionDateEnd__c.format('MM-dd-yyyy hh:mm')));
            }
            w.writeElementIfNotNullNoIndent('tns', 'Client_Language_Spoken', 'tns', getStringValueOf(c.ClientLanguageSpoken__c));
            w.writeElementIfNotNullNoIndent('tns', 'Client_Session_Duration', 'tns', getStringValueOf(c.ClientSessionDuration__c));
            w.writeElementIfNotNullNoIndent('tns', 'Client_Counseling_Type', 'tns', getStringValueOf(c.ClientCounselingType__c));
            w.writeElementIfNotNullNoIndent('tns', 'Client_Counseling_Termination', 'tns', getStringValueOf(c.ClientCounselingTermination__c));
            w.writeElementIfNotNullNoIndent('tns', 'Client_Counseling_Fee', 'tns', getStringValueOf(c.ClientCounselingFee__c));
            w.writeElementIfNotNullNoIndent('tns', 'Client_Attribute_HUD_Grant', 'tns', getStringValueOf(c.ClientAttributeHUDGrant__c));
            w.writeElementIfNotNullNoIndent('tns', 'Client_Grant_Amount_Used', 'tns', getStringValueOf(c.ClientGrantAmountUsed__c));
            w.writeElementIfNotNullNoIndent('tns', 'Client_HECM_Certificate', 'tns', c.ClientHECMCertificate__c);
            Date issueDt = c.ClientHECMCertificateIssueDate__c;
            Date expDt = c.ClientHECMCertificateexpirationDate__c;
            if (issueDt != null && expDt !=  null) {
                String issueDate = String.valueOf(DateTime.newInstance(issueDt.year(),issueDt.month(),issueDt.day()).format('MM-dd-yyyy'));
                String expDate = String.valueOf(DateTime.newInstance(expDt.year(),expDt.month(),expDt.day()).format('MM-dd-yyyy'));
                w.writeElementIfNotNullNoIndent('tns', 'Client_HECM_Certificate_Issue_Date', 'tns', issueDate);
                w.writeElementIfNotNullNoIndent('tns', 'Client_HECM_Certificate_Expiration_Date', 'tns', expDate);
            }
            w.writeElementIfNotNullNoIndent('tns', 'Client_HECM_Certificate_ID', 'tns', c.ClientHECMCertificateID__c);
            w.writeElementIfNotNullNoIndent('tns', 'Client_Predatory_Lending', 'tns', getStringValueOf(c.ClientPredatoryLending__c));
            w.writeElementIfNotNullNoIndent('tns', 'Client_Mortgage_Type', 'tns', getStringValueOf(c.ClientMortgageType__c));
            w.writeElementIfNotNullNoIndent('tns', 'Client_Mortgage_Type_After', 'tns', getStringValueOf(c.ClientMortgageTypeAfter__c));
            w.writeElementIfNotNullNoIndent('tns', 'Client_Finance_Type_Before', 'tns', getStringValueOf(c.ClientFinanceTypeBefore__c));
            w.writeElementIfNotNullNoIndent('tns', 'Client_Finance_Type_After', 'tns', getStringValueOf(c.ClientFinanceTypeAfter__c));
            w.writeElementIfNotNullNoIndent('tns', 'Client_FirstTime_Home_Buyer', 'tns', getStringValueOf(c.ClientFirstTimeHomeBuyer__c));
            w.writeElementIfNotNullNoIndent('tns', 'Client_Discrimination_Victim', 'tns', getStringValueOf(c.ClientDiscriminationVictim__c));
            w.writeElementIfNotNullNoIndent('tns', 'Client_Mortgage_Closing_Cost', 'tns', getStringValueOf(c.ClientMortgageClosingCost__c));
            w.writeElementIfNotNullNoIndent('tns', 'Client_Mortgage_Interest_Rate', 'tns', getStringValueOf(c.ClientMortgageInterestRate__c));
            w.writeElementIfNotNullNoIndent('tns', 'Client_Referred_By', 'tns', getStringValueOf(c.ClientReferredBy__c));
            if(c.ClientSalesContractSigned__c != null){
               w.writeElementIfNotNullNoIndent('tns', 'Client_Sales_Contract_Signed', 'tns', HUD9902Helper.getFormattedDate(c.ClientSalesContractSigned__c));
            }
            w.writeElementIfNotNullNoIndent('tns', 'Client_Job_Duration', 'tns', getStringValueOf(c.ClientJobDuration__c));
            
            w.writeElementIfNotNullNoIndent('tns', 'Client_Credit_Score', 'tns', getStringValueOf(c.ClientCreditScore__c));
            w.writeElementIfNotNullNoIndent('tns', 'Client_No_Credit_Score_Reason', 'tns', getStringValueOf(c.ClientMissingCreditScoreReason__c));
            w.writeElementIfNotNullNoIndent('tns', 'Client_Credit_Score_Source', 'tns', getStringValueOf(c.ClientCreditScoreSource__c));
            w.writeElementIfNotNullNoIndent('tns', 'Client_Household_Debt', 'tns', getStringValueOf(c.ClientHouseholdDebt__c));
            w.writeElementIfNotNullNoIndent('tns', 'Client_Mortgage_Deliquency', 'tns', getStringValueOf(c.ClientMortgageDelinquency__c));
            w.writeElementIfNotNullNoIndent('tns', 'Client_Loan_Being_Reported', 'tns', getStringValueOf(c.ClientLoanBeingReported__c));
            w.writeElementIfNotNullNoIndent('tns', 'Client_Second_Loan_Exists', 'tns', getStringValueOf(c.ClientSecondLoanExists__c));
            w.writeElementIfNotNullNoIndent('tns', 'Client_Intake_Loan_Type', 'tns', getStringValueOf(c.ClientIntakeLoanType__c));
            w.writeElementIfNotNullNoIndent('tns', 'Client_Intake_Loan_Type_Is_Hybrid_ARM', 'tns', getStringValueOf(c.ClientIntakeLoanIsaHybridARMLoan__c));
            w.writeElementIfNotNullNoIndent('tns', 'Client_Intake_Loan_Type_Is_Option_ARM', 'tns', getStringValueOf(c.ClientIntakeLoanIsanOptionARMLoan__c));
            w.writeElementIfNotNullNoIndent('tns', 'Client_Intake_Loan_Type_Is_Interest_Only', 'tns', getStringValueOf(c.ClientIntakeLoanIsInterestOnly__c));
            w.writeElementIfNotNullNoIndent('tns', 'Client_Intake_Loan_Type_Is_FHA_Or_VA_Insured', 'tns', getStringValueOf(c.ClientIntakeLoanisFHAOrVAInsured__c));
            w.writeElementIfNotNullNoIndent('tns', 'Client_Intake_Loan_Type_Is_Privately_Held', 'tns', getStringValueOf(c.ClientIntakeLoanisaPrivatelyHeld__c));
            w.writeElementIfNotNullNoIndent('tns', 'Client_Intake_Loan_Type_Has_Interest_Rate_Reset', 'tns', getStringValueOf(c.ClientIntakeLoanHasInterestRate__c));
            w.writeElementIfNotNullNoIndent('tns', 'Client_Income_Level', 'tns', getStringValueOf(c.ClientIncomeLevel__c));
            if(c.ClientPurposeofVisit__c != 'Not HUD-Reportable'){
                w.writeElementIfNotNullNoIndent('tns', 'Client_Purpose_Of_Visit', 'tns', getStringValueOf(c.ClientPurposeofVisit__c));
            }
            w.writeElementIfNotNullNoIndent('tns', 'Client_Activity_Type', 'tns', getStringValueOf(c.ClientActivityType__c));
            w.writeElementIfNotNullNoIndent('tns', 'Client_9902_Reporting_Qtr', 'tns', getStringValueOf(c.X9902ReportingQuarter__c));
            
            /*
            w.writeStartElementNoIndent('tns','Client_Outcomes','tns'); 
                w.writeElementIfNotNullNoIndent('tns', 'Client_Outcome', 'tns', '19');
            w.writeEndElementNoIndent();
            */
            if(c.ClientOutcome__c != null){
                w.writeStartElementNoIndent('tns','Client_Outcomes','tns'); 
                for(String o : c.ClientOutcome__c.split(';')){
                    w.writeElementIfNotNullNoIndent('tns', 'Client_Outcome', 'tns', o);
                }
                w.writeEndElementNoIndent();
            }
            w.writeEndElementNoIndent();
        }
        w.writeEndElement();
        w.writeEndDocument();
        String xmlString = w.getXmlString();
        w.close();
        return xmlString;
    }

    public static String getRequestXml(List<X9902Client__c> x9902Clients) {
        XmlStreamWriter writer = new XmlStreamWriter();
        PrettyXmlStreamWriter w = new PrettyXmlStreamWriter(writer, 4);
        w.writeStartDocument('UTF-8','1.0');
        w.writeStartElement('tns','SubmissionData ','tns'); 
        w.writeAttribute('','','xsi:schemaLocation','http://gov.hud.arm/client_profile_databag_6_0 client_profile_databag_6_0.xsd');
        w.writeAttribute('','','xmlns:tns','http://gov.hud.arm/client_profile_databag_6_0');
        w.writeAttribute('','','xmlns:xsi','http://www.w3.org/2001/XMLSchema-instance');
        w.writeStartElement('tns','Client_Profiles','tns');
        for (X9902Client__c c : x9902Clients) {
            System.debug('X9902Client__c: ');
            w.writeStartElementNoIndentNewLine('tns','Client_Profile','tns'); 
            w.writeElementIfNotNullNoIndent('tns', 'Client_ID_Num', 'tns', getStringValueOf(c.ClientIDNumber__c));
            w.writeElementIfNotNullNoIndent('tns', 'Client_Case_Num', 'tns', getStringValueOf(c.ClientCaseNumber__c));
            w.writeElementIfNotNullNoIndent('tns', 'Client_City', 'tns', getStringValueOf(c.ClientCity__c));
            w.writeElementIfNotNullNoIndent('tns', 'Client_State', 'tns', getStringValueOf(c.ClientState__c));
            w.writeElementIfNotNullNoIndent('tns', 'Client_Zip', 'tns', getStringValueOf(c.ClientZip__c));
            w.writeElementIfNotNullNoIndent('tns', 'Client_New_City', 'tns', getStringValueOf(c.ClientNewCity__c));
            w.writeElementIfNotNullNoIndent('tns', 'Client_New_State', 'tns', getStringValueOf(c.ClientNewState__c));
            w.writeElementIfNotNullNoIndent('tns', 'Client_New_Zip', 'tns', getStringValueOf(c.ClientNewZip__c));
            w.writeElementIfNotNullNoIndent('tns', 'Client_Family_Size', 'tns', getStringValueOf(c.ClientFamilySize__c));
            w.writeElementIfNotNullNoIndent('tns', 'Client_Gender', 'tns', getStringValueOf(c.ClientGender__c));
            w.writeElementIfNotNullNoIndent('tns', 'Client_Marital_Status', 'tns', getStringValueOf(c.ClientMaritalStatus__c));
            w.writeElementIfNotNullNoIndent('tns', 'Client_Race_ID', 'tns', getStringValueOf(c.ClientRaceID__c));
            w.writeElementIfNotNullNoIndent('tns', 'Client_Ethnicity_ID', 'tns', getStringValueOf(c.ClientEthnicityID__c));
            w.writeElementIfNotNullNoIndent('tns', 'Client_Household_Gross_Monthly_Income', 'tns', getStringValueOf(c.ClientHouseholdGrossMonthlyIncome__c));
            w.writeElementIfNotNullNoIndent('tns', 'Client_Head_Of_Household_Type', 'tns', getStringValueOf(c.ClientHeadofHouseholdType__c));
            w.writeElementIfNotNullNoIndent('tns', 'Client_Counselor_ID', 'tns', getStringValueOf(c.ClientCounselorID__c));
            w.writeElementIfNotNullNoIndent('tns', 'Client_Counselor_HUD_Id', 'tns', getStringValueOf(c.ClientCounselorHUDId__c));
            w.writeElementIfNotNullNoIndent('tns', 'Client_Highest_Educ_Grade', 'tns', getStringValueOf(c.ClientHighestEducation__c));
            w.writeElementIfNotNullNoIndent('tns', 'Client_Farm_Worker', 'tns', getStringValueOf(c.ClientFarmWorker__c));
            w.writeElementIfNotNullNoIndent('tns', 'Client_Rural_Area', 'tns', getStringValueOf(c.ClientRuralAreaStatus__c));
            w.writeElementIfNotNullNoIndent('tns', 'Client_Limited_English_Proficiency', 'tns', getStringValueOf(c.ClientLimitedEnglishProficiency__c));
            w.writeElementIfNotNullNoIndent('tns', 'Client_Colonias_Resident', 'tns', getStringValueOf(c.ClientColoniasResident__c));
            w.writeElementIfNotNullNoIndent('tns', 'Client_HUD_Assistance', 'tns', getStringValueOf(c.ClientHUDAssistance__c));
            //w.writeElementIfNotNullNoIndent('tns', 'Client_HUD_Assistance', 'tns', '2');
            w.writeElementIfNotNullNoIndent('tns', 'Client_Disabled', 'tns', getStringValueOf(c.ClientDisabled__c));
            w.writeElementIfNotNullNoIndent('tns', 'Client_Dependents_Num', 'tns', getStringValueOf(c.ClientDependentsNumber__c));
            w.writeElementIfNotNullNoIndent('tns', 'Client_Intake_DT', 'tns', HUD9902Helper.getFormattedDate(c.ClientIntakeDate__c));
            if(c.ClientCounselSessionDateStart__c != null){
                w.writeElementIfNotNullNoIndent('tns', 'Client_Counsel_Start_Session_DateTime', 'tns', String.valueOf(c.ClientCounselSessionDateStart__c.format('MM-dd-yyyy hh:mm')));
            }
            if(c.ClientCounselSessionDateEnd__c != null){
                w.writeElementIfNotNullNoIndent('tns', 'Client_Counsel_End_Session_DateTime', 'tns', String.valueOf(c.ClientCounselSessionDateEnd__c.format('MM-dd-yyyy hh:mm')));
            }
            w.writeElementIfNotNullNoIndent('tns', 'Client_Language_Spoken', 'tns', getStringValueOf(c.ClientLanguageSpoken__c));
            w.writeElementIfNotNullNoIndent('tns', 'Client_Session_Duration', 'tns', getStringValueOf(c.ClientSessionDuration__c));
            w.writeElementIfNotNullNoIndent('tns', 'Client_Counseling_Type', 'tns', getStringValueOf(c.ClientCounselingType__c));
            w.writeElementIfNotNullNoIndent('tns', 'Client_Counseling_Termination', 'tns', getStringValueOf(c.ClientCounselingTermination__c));
            w.writeElementIfNotNullNoIndent('tns', 'Client_Counseling_Fee', 'tns', getStringValueOf(c.ClientCounselingFee__c));
            w.writeElementIfNotNullNoIndent('tns', 'Client_Attribute_HUD_Grant', 'tns', getStringValueOf(c.ClientAttributeHUDGrant__c));
            w.writeElementIfNotNullNoIndent('tns', 'Client_Grant_Amount_Used', 'tns', getStringValueOf(c.ClientGrantAmountUsed__c));
            w.writeElementIfNotNullNoIndent('tns', 'Client_HECM_Certificate', 'tns', 'N');
            w.writeElementIfNotNullNoIndent('tns', 'Client_Predatory_Lending', 'tns', getStringValueOf(c.ClientPredatoryLending__c));
            w.writeElementIfNotNullNoIndent('tns', 'Client_Mortgage_Type', 'tns', getStringValueOf(c.ClientMortgageType__c));
            w.writeElementIfNotNullNoIndent('tns', 'Client_Mortgage_Type_After', 'tns', getStringValueOf(c.ClientMortgageTypeAfter__c));
            w.writeElementIfNotNullNoIndent('tns', 'Client_Finance_Type_Before', 'tns', getStringValueOf(c.ClientFinanceTypeBefore__c));
            w.writeElementIfNotNullNoIndent('tns', 'Client_Finance_Type_After', 'tns', getStringValueOf(c.ClientFinanceTypeAfter__c));
            w.writeElementIfNotNullNoIndent('tns', 'Client_FirstTime_Home_Buyer', 'tns', getStringValueOf(c.ClientFirstTimeHomeBuyer__c));
            w.writeElementIfNotNullNoIndent('tns', 'Client_Discrimination_Victim', 'tns', getStringValueOf(c.ClientDiscriminationVictim__c));
            w.writeElementIfNotNullNoIndent('tns', 'Client_Mortgage_Closing_Cost', 'tns', getStringValueOf(c.ClientMortgageClosingCost__c));
            w.writeElementIfNotNullNoIndent('tns', 'Client_Mortgage_Interest_Rate', 'tns', getStringValueOf(c.ClientMortgageInterestRate__c));
            w.writeElementIfNotNullNoIndent('tns', 'Client_Referred_By', 'tns', getStringValueOf(c.ClientReferredBy__c));
            if(c.ClientSalesContractSigned__c != null){
               w.writeElementIfNotNullNoIndent('tns', 'Client_Sales_Contract_Signed', 'tns', HUD9902Helper.getFormattedDate(c.ClientSalesContractSigned__c));
            }
            w.writeElementIfNotNullNoIndent('tns', 'Client_Job_Duration', 'tns', getStringValueOf(c.ClientJobDuration__c));
            
            w.writeElementIfNotNullNoIndent('tns', 'Client_Credit_Score', 'tns', getStringValueOf(c.ClientCreditScore__c));
            w.writeElementIfNotNullNoIndent('tns', 'Client_No_Credit_Score_Reason', 'tns', getStringValueOf(c.ClientMissingCreditScoreReason__c));
            w.writeElementIfNotNullNoIndent('tns', 'Client_Credit_Score_Source', 'tns', getStringValueOf(c.ClientCreditScoreSource__c));
            w.writeElementIfNotNullNoIndent('tns', 'Client_Household_Debt', 'tns', getStringValueOf(c.ClientHouseholdDebt__c));
            w.writeElementIfNotNullNoIndent('tns', 'Client_Mortgage_Deliquency', 'tns', getStringValueOf(c.ClientMortgageDelinquency__c));
            w.writeElementIfNotNullNoIndent('tns', 'Client_Loan_Being_Reported', 'tns', getStringValueOf(c.ClientLoanBeingReported__c));
            w.writeElementIfNotNullNoIndent('tns', 'Client_Second_Loan_Exists', 'tns', getStringValueOf(c.ClientSecondLoanExists__c));
            w.writeElementIfNotNullNoIndent('tns', 'Client_Intake_Loan_Type', 'tns', getStringValueOf(c.ClientIntakeLoanType__c));
            w.writeElementIfNotNullNoIndent('tns', 'Client_Intake_Loan_Type_Is_Hybrid_ARM', 'tns', getStringValueOf(c.ClientIntakeLoanIsaHybridARMLoan__c));
            w.writeElementIfNotNullNoIndent('tns', 'Client_Intake_Loan_Type_Is_Option_ARM', 'tns', getStringValueOf(c.ClientIntakeLoanIsanOptionARMLoan__c));
            w.writeElementIfNotNullNoIndent('tns', 'Client_Intake_Loan_Type_Is_Interest_Only', 'tns', getStringValueOf(c.ClientIntakeLoanIsInterestOnly__c));
            w.writeElementIfNotNullNoIndent('tns', 'Client_Intake_Loan_Type_Is_FHA_Or_VA_Insured', 'tns', getStringValueOf(c.ClientIntakeLoanisFHAOrVAInsured__c));
            w.writeElementIfNotNullNoIndent('tns', 'Client_Intake_Loan_Type_Is_Privately_Held', 'tns', getStringValueOf(c.ClientIntakeLoanisaPrivatelyHeld__c));
            w.writeElementIfNotNullNoIndent('tns', 'Client_Intake_Loan_Type_Has_Interest_Rate_Reset', 'tns', getStringValueOf(c.ClientIntakeLoanHasInterestRate__c));
            w.writeElementIfNotNullNoIndent('tns', 'Client_Income_Level', 'tns', getStringValueOf(c.ClientIncomeLevel__c));
            if(c.ClientPurposeofVisit__c != 'Not HUD-Reportable'){
                w.writeElementIfNotNullNoIndent('tns', 'Client_Purpose_Of_Visit', 'tns', getStringValueOf(c.ClientPurposeofVisit__c));
            }
            w.writeElementIfNotNullNoIndent('tns', 'Client_Activity_Type', 'tns', getStringValueOf(c.ClientActivityType__c));
            w.writeElementIfNotNullNoIndent('tns', 'Client_9902_Reporting_Qtr', 'tns', getStringValueOf(c.X9902ReportingQuarter__c));
            /*
            w.writeStartElementNoIndent('tns','Client_Outcomes','tns'); 
                w.writeElementIfNotNullNoIndent('tns', 'Client_Outcome', 'tns', '19');
            w.writeEndElementNoIndent();
            */
            if(c.ClientOutcome__c != null){
                w.writeStartElementNoIndent('tns','Client_Outcomes','tns'); 
                for(String o : c.ClientOutcome__c.split(';')){
                    w.writeElementIfNotNullNoIndent('tns', 'Client_Outcome', 'tns', o);
                }
                w.writeEndElementNoIndent();
            }
            w.writeEndElementNoIndent();
        }
        w.writeEndElement();
        w.writeEndDocument();
        String xmlString = w.getXmlString();
        w.close();
        return xmlString;
    }

    public static String buildRequestBody(String requestXml, Integer agencyid, String agencyName, String vendorid, String pw, String fiscalYear) {
        String soapXML ='<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:ser="http://service.arm.hud.gov/">' +
            '<soapenv:Header></soapenv:Header><soapenv:Body><ser:postClientData><ser:submissionHeader6.0><ser:agcHcsId>'+agencyid+'</ser:agcHcsId>' +
            '<ser:agcName>'+agencyName+'</ser:agcName><ser:fiscalYearId>'+FiscalYear+'</ser:fiscalYearId><ser:cmsVendorId>'+vendorid+'</ser:cmsVendorId><ser:cmsPassword>'+pw+'</ser:cmsPassword></ser:submissionHeader6.0>';
        String strsubEncode = '<ser:submissionDataEncoding>TEXT/XML</ser:submissionDataEncoding>';
        String strFileEncode = '<ser:submissionData>' + EncodingUtil.base64Encode(blob.valueOf(requestXml)) + '</ser:submissionData>';
        String strEnv  = '</ser:postClientData></soapenv:Body></soapenv:Envelope>';
        return soapXML + strsubEncode + strFileEncode + strEnv;
    }
}