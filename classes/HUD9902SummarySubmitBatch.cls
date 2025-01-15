public with sharing class HUD9902SummarySubmitBatch implements Database.Batchable<SObject>, Database.Stateful, Database.AllowsCallouts {
    // private String queryString = 'SELECT Id, X9902__c FROM X9902Summary__c ';
    private String NWC2NameSpace = Utility.getNwc2NameSpace();
    private String queryString = 'SELECT Id, '+NWC2NameSpace+'PeriodEndDate__c FROM '+NWC2NameSpace+'X9902__c ';
    Id reportId;
    public HUD9902SummarySubmitBatch(String reportRecordId){
        reportId = (Id)reportRecordId;
        // queryString = queryString + ' WHERE X9902__c = \'' + reportRecordId + '\'';
        queryString = queryString + ' WHERE Id = \'' + reportRecordId + '\'';
        reset9902Fields([SELECT Id FROM X9902__c WHERE Id = :reportRecordId]);
    }
    
    public Database.QueryLocator start(Database.BatchableContext context) {
        return Database.getQueryLocator(queryString);
    }
    
    public void execute(Database.BatchableContext context, List<X9902__c> scope) {
        if (scope != null && !scope.isEmpty()) {
            for (X9902__c x9902Rec : scope) {
                if (x9902Rec != null) {
                    syncSummaryWithHud(x9902Rec); 
                } else {
                    System.debug('Encountered a null X9902__c record');
                }
            }
        } else {
            System.debug('Scope is null or empty');
        }
        // CalloutException e = new CalloutException();
        // e.setMessage('Summary Batch exception');
        // throw e;
    }
    
    public void finish(Database.BatchableContext context) {
    }
    
    public static String syncSummaryWithHud(X9902__c x9902) {
        String submissionId;
        
        if (x9902 != null) {
            Id x9902RecordId = x9902.Id;
            
            if (x9902.PeriodEndDate__c != null) {
                Map<String, HUD9902FiscalYear__c> fiscalYearCodeMap = HUD9902FiscalYear__c.getAll();
                HUD9902FiscalYear__c fiscalYearRecord = fiscalYearCodeMap.get(String.valueOf(x9902.PeriodEndDate__c.year()));
                
                if (fiscalYearRecord != null && fiscalYearRecord.FiscalYearID__c != null) {
                    String fiscalYear = fiscalYearRecord.FiscalYearID__c;
                    String reportedMonth = String.valueOf(x9902.PeriodEndDate__c.month());
                    
                    IntegrationSettings__c mc = IntegrationSettings__c.getValues('HUD Settings');
                    if (mc != null && mc.EndpointURL__c != null && mc.AgencyID__c != null && mc.AgencyName__c != null && mc.VendorID__c != null && mc.CMSPassword__c != null) {
                        String endpoint = mc.EndpointURL__c;
                        Integer agencyid = Integer.valueOf(mc.AgencyID__c);
                        String agencyName = mc.AgencyName__c;
                        String vendorid = mc.VendorID__c;
                        String pw = mc.CMSPassword__c;
                        
                        String xml = getSummaryRequestBody(x9902RecordId);
                        String strFileEncode = EncodingUtil.base64Encode(blob.valueOf(xml));
                        String soapXML = '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:ser="http://service.arm.hud.gov/">' +
                            '<soapenv:Header></soapenv:Header><soapenv:Body><ser:postForm9902Data><ser:submissionHeader6.0>' +
                            '<ser:agcHcsId>' + agencyid + '</ser:agcHcsId><ser:agcName>' + agencyName + '</ser:agcName>' +
                            '<ser:fiscalYearId>' + fiscalYear + '</ser:fiscalYearId><ser:cmsVendorId>' + vendorid + '</ser:cmsVendorId>' +
                            '<ser:cmsPassword>' + pw + '</ser:cmsPassword></ser:submissionHeader6.0>';
                        
                        String subXML1 = '<ser:submissionData>';
                        String subXML2 = '</ser:submissionData>';
                        String strEncodedSubxml = subXML1 + strFileEncode + subXML2;
                        String strsubEncode = '<ser:submissionDataEncoding>TEXT/XML</ser:submissionDataEncoding>';
                        String strEnv = '</ser:postForm9902Data></soapenv:Body></soapenv:Envelope>';
                        String finalReqBody = soapXML + strsubEncode + strEncodedSubxml + strEnv;
                        
                        submissionId = HTTPCalloutService.postHUDReport(finalReqBody);
                        system.debug('submissionId....'+ submissionId);
                        x9902 = new X9902__c();
                        x9902.Id = x9902RecordId;
                        x9902.Summary9902SubmissionID__c = submissionId;
                        update x9902;
                        
                        // ID jobID1 = System.enqueueJob(new HudSubmissionStatusCheck(blob.valueOf(xml), submissionId, x9902RecordId));
                        ID jobID1 = System.enqueueJob(new HudSubmissionStatusCheck(blob.valueOf(xml), submissionId, x9902RecordId, '9902_Summary'));
                        System.debug('JobId::' + jobID1);
                    } else {
                        System.debug('Integration settings are missing required fields.');
                    }
                } else {
                    System.debug('Fiscal year record is null or missing FiscalYearID__c.');
                }
            } else {
                System.debug('PeriodEndDate__c is null for record: ' + x9902.Id);
            }
        } else {
            System.debug('x9902 record is null.');
        }
        
        return submissionId;
    }
    
    
    public static String getSummaryRequestBody(Id x9902RecordId) {
        XmlStreamWriter writer = new XmlStreamWriter();
        PrettyXmlStreamWriter w = new PrettyXmlStreamWriter(writer, 4);
        w.writeStartDocument('UTF-8','1.0');
        w.writeStartElement('tns','SubmissionData','tns');
        w.writeAttribute('','','xsi:schemaLocation','http://gov.hud.arm/form_9902_databag_6_0 form_9902_databag_6_0.xsd');
        w.writeAttribute('','','xmlns:tns','http://gov.hud.arm/form_9902_databag_6_0');
        w.writeAttribute('','','xmlns:xsi','http://www.w3.org/2001/XMLSchema-instance');
        w.writeStartElement('tns','Form_9902 ','tns');
        
        write9902Details(x9902RecordId, w);
        List<X9902Summary__c> gslst9902 = [ SELECT
                                           Id,
                                           ElementType__c,
                                           X9902__c,
                                           ReportPeriodId__c,
                                           Course__c,
                                           GroupSessionID__c,
                                           GroupSessionCounselorID__c,
                                           GroupSessionTitle__c,
                                           GroupSessionDate__c,
                                           GroupSessionDuration__c,
                                           GroupSessionType__c,
                                           GroupSessionAttributeHUD_Grant__c,
                                           GroupSessionActivityType__c,
                                           GroupSessionCounselorHUDId__c
                                           FROM X9902Summary__c
                                           WHERE X9902__c = :x9902RecordId
                                           AND ElementType__c = 'Group Session'
                                           //   AND GroupSessionID__c != NULL 
                                          ];
        if(!gslst9902.isEmpty()){
            writeGroupSessionAndAttendeeDetails(x9902RecordId, w, gslst9902);
            writeAttendeeDetails(x9902RecordId, w);
        } //No Group Session Data
        w.writeEndDocument(); 
        String xml = w.getXmlString();
        w.close();
        return xml;
    }
    
    public static void write9902Details(Id x9902RecordId, PrettyXmlStreamWriter w) {
        Boolean rptIdFlg=TRUE;
        // // 9902
        List<X9902Summary__c> lst9902 = [select Id,ActivityTypeID__c,ReportPeriodId__c,Hispanic__c,NotHispanic__c,ChoseNottoRespond__c,Section3TOTAL__c,
                                         AmericanIndianAlaskanNative__c,Asian__c,BlackorAfricanAmerican__c, NativeHawaiian__c, White__c,MoreThanoneRace__c,MultiRaceChosenottorespond__c,Section4TOTAL__c,
                                         X30ofAreaMedianIncomeAMI__c,X3049ofAMI__c,X5079ofAMI__c,X80100ofAMI__c,X100AMI__c,AMIChosenottorespond__c,Section5TOTAL__c,
                                         Householdlivesinaruralarea__c,Householddoesnotliveinaruralarea__c,RuralChosenottorespond__c,Section6TOTAL__c,
                                         HouseholdisLimitedEnglishProficient__c,NotLimitedEnglishProficient__c,LimitedEnglishProficienChoseNotToRespond__c,Section7TOTAL__c,
                                         Completedfinancialliteracyworkshop__c,Completedpredatorylending__c,Completedfairhousingworkshop__c,HomelessnessPreventionWorkshop__c,Completedrentalworkshop__c,Prepurchasehomebuyereducationworkshop__c,
                                         NonDelinquencyPostPurchaseWorkshop__c,MortgageDelinquencyWorkshop__c,CompletedDisasterPreparednessWorkshop__c,DisasterRecoveryWorkshop__c,Section_8_TOTAL__c,
                                         HomelessAssistance__c,RentalTopics__c,PrepurchaseHomebuyingCounseling__c, PrepurchaseHomebuying__c, HomeMaintenance__c, ReverseMortgageDelinquencyorDefault__c,ForwardMortgageDelinquencyorDefault__c,DisasterPreparednessAssistance__c,DisasterRecoveryAssistance__c,Section9TOTAL__c,
                                         OneononeCounseling__c,ReceivedInformationonFairHousing__c,SustainableHouseholdBudget__c,HouseholdsImprovedFinancialCapacity__c,HouseholdsGainedAccesstoResources__c,GainedAccesstoNonHousingResources__c,HomelessobtainedHousing__c,
                                         DisasterRecoveryNonhousingResources__c,DisasterRecoveryHousingResources__c,EmergencyPreparednessPlan__c,HouseholdsReceivedRentalCounselling__c,HouseholdsImprovedLivingConditions__c,
                                         HouseholdsReceivedReverseMortgage__c,NonDelinquencyPostPurchaseCounseling__c,PreventedForwardMortgageDefault__c,PreventedReverseMortgageDefault__c,ForwardModImprovedFinancialCapacity__c,Section10TOTAL__c, ReverseMortgage__c,
                                         ForwardMortgageModImprovedFinancials__c
                                         FROM X9902Summary__c 
                                         where X9902__c = :x9902RecordId 
                                         AND ElementType__c = '9902' 
                                         WITH SECURITY_ENFORCED
                                        ];
        Map<String, String> tagMap=new Map<String, String>{
            'Report_Period_Id'=>'ReportPeriodId__c',
            'Ethnicity_Households_Counseling_Hispanic'=> 'Hispanic__c',
            'Ethnicity_Households_Counseling_Non_Hispanic'=> 'NotHispanic__c',
            'Ethnicity_Households_Counseling_No_Response'=> 'ChoseNottoRespond__c',
            'Section_3_Total'=> 'Section3TOTAL__c',
            'Race_Households_Counseling_American_Indian'=> 'AmericanIndianAlaskanNative__c',
            'Race_Households_Counseling_Asian'=> 'Asian__c',
            'Race_Households_Counseling_Black_African_American'=> 'BlackorAfricanAmerican__c',
            'Race_Households_Counseling_Pacific_Islanders'=> 'NativeHawaiian__c',
            'Race_Households_Counseling_White'=>'White__c',
            'Race_Households_Counseling_More_Than_One_Race'=>'MoreThanoneRace__c',
            'Race_Households_Counseling_No_Response'=>'MultiRaceChosenottorespond__c',
            'Section_4_Total'=>'Section4TOTAL__c',
            'Less30_AMI_Level'=>'X30ofAreaMedianIncomeAMI__c',
            'a30_49_AMI_Level'=>'X3049ofAMI__c',
            'a50_79_AMI_Level'=>'X5079ofAMI__c',
            'a80_100_AMI_Level'=>'X80100ofAMI__c',
            'Greater100_AMI_Level'=>'X100AMI__c',
            'AMI_No_Response'=>'AMIChosenottorespond__c',
            'Section_5_Total'=>'Section5TOTAL__c',
            'Lives_In_Rural_Area'=>'Householdlivesinaruralarea__c',
            'Does_Not_Live_In_Rural_Area'=>'Householddoesnotliveinaruralarea__c',
            'Rural_Area_No_Response'=>'RuralChosenottorespond__c',
            'Section_6_Total'=>'Section6TOTAL__c',
            'Limited_English_Proficient'=>'HouseholdisLimitedEnglishProficient__c',
            'Not_Limited_English_Proficient'=>'NotLimitedEnglishProficient__c',
            'Limited_English_Proficient_No_Response'=>'LimitedEnglishProficienChoseNotToRespond__c',
            'Section_7_Total'=>'Section7TOTAL__c',
            'Education_Compl_Fin_Lit_Workshop'=> 'Completedfinancialliteracyworkshop__c',
            'Education_Compl_Pred_Lend_Workshop'=>'Completedpredatorylending__c',
            'Education_Compl_Fair_Housing_Workshop'=>'Completedfairhousingworkshop__c',
            'Education_Compl_Homeless_Prev_Workshop'=>'HomelessnessPreventionWorkshop__c',
            'Education_Compl_Rental_Workshop'=>'Completedrentalworkshop__c',
            'Education_Compl_PrePurchase_HomeBuyer_Workshop'=>'Prepurchasehomebuyereducationworkshop__c',
            'Education_Compl_NonDelinqency_PostPurchase_Workshop'=>'NonDelinquencyPostPurchaseWorkshop__c',
            'Education_Compl_Resolv_Prevent_Mortg_Delinq_Workshop'=>'MortgageDelinquencyWorkshop__c',
            'Education_Compl_Disaster_Prepare_Workshop'=>'CompletedDisasterPreparednessWorkshop__c',
            'Education_Compl_Disaster_Recovery_Workshop'=>'DisasterRecoveryWorkshop__c',
            'Section_8_Total'=>'Section_8_TOTAL__c',
            'One_Homeless_Assistance_Counseling'=>'HomelessAssistance__c',
            'One_Rental_Topics_Counseling'=>'RentalTopics__c',
            'One_PrePurchase_HomeBuying_Counseling'=>'PrepurchaseHomebuying__c',
            'One_Non_Delinq_Post_Purchase_Counseling'=>'HomeMaintenance__c',
            'One_Reverse_Mortgage_Counseling'=>'ReverseMortgageDelinquencyorDefault__c',
            'One_Resolv_Prevent_Fwd_Mortg_Delinq_Counseling'=>'ForwardMortgageDelinquencyorDefault__c',
            'One_Resolv_Prevent_Rev_Mortg_Delinq_Counseling'=>'ReverseMortgage__c',
            'One_Disaster_Preparedness_Assistance_Counseling'=>'DisasterPreparednessAssistance__c',
            'One_Disaster_Recovery_Assistance_Counseling'=>'DisasterRecoveryAssistance__c',
            'Section_9_Total'=>'Section9TOTAL__c',
            'Outcome_One_On_One_And_Education'=>'OneononeCounseling__c',
            'Outcome_Received_Info_Fair_Housing'=>'ReceivedInformationonFairHousing__c',
            'Outcome_Developed_Budget'=>'SustainableHouseholdBudget__c',
            'Outcome_Improved_Financial_Capacity'=>'HouseholdsImprovedFinancialCapacity__c',
            'Outcome_Gained_Access_Resources_Improve_Housing'=>'HouseholdsGainedAccesstoResources__c',
            'Outcome_Gained_Access_NonHousing_Resources'=>'GainedAccesstoNonHousingResources__c',
            'Outcome_Homeless_Obtained_Housing'=>'HomelessobtainedHousing__c',
            'Outcome_Gained_Access_Disaster_Recovery_NonHousing_Resources'=>'DisasterRecoveryNonhousingResources__c',
            'Outcome_Obtained_Disaster_Recovery_Housing_Resources'=>'DisasterRecoveryHousingResources__c',
            'Outcome_Developed_Emergency_Preparedness_Plan'=>'EmergencyPreparednessPlan__c',
            'Outcome_Received_Rental_Counseling_Avoided_Eviction'=>'HouseholdsReceivedRentalCounselling__c',
            'Outcome_Received_Rental_Counseling_Improved_Living_Conditions'=>'HouseholdsImprovedLivingConditions__c',
            'Outcome_Received_PrePurchase_Counseling_Purchased_Housing'=>'PrepurchaseHomebuyingCounseling__c',
            'Outcome_Received_Reverse_Mortgage_Counseling_Obtained_HECM'=>'HouseholdsReceivedReverseMortgage__c',
            'Outcome_Received_NonDelinquency_PostPurchase_Counseling_Improve_Conditions_Affordability'=>'NonDelinquencyPostPurchaseCounseling__c',
            'Outcome_Prevented_Resolved_Forward_Mortgage_Default'=>'PreventedForwardMortgageDefault__c',
            'Outcome_Prevented_Resolved_Reverse_Mortgage_Default'=>'PreventedReverseMortgageDefault__c',
            'Outcome_Received_Forward_Mortgage_Modification_Remain_Current_In_Modified_Mortgage' => 'ForwardMortgageModImprovedFinancials__c',
            'Outcome_Received_Forward_Mortgage_Modification_Improved_Financial_Capacity'=>'ForwardModImprovedFinancialCapacity__c',
            'Section_10_Total'=>'Section10TOTAL__c'
        };
                    
        for(String key : tagMap.keySet()){
            for(X9902Summary__c objAp : lst9902){
                String actType = String.valueOf(objAP.ActivityTypeID__c);
                if(rptIdFlg==TRUE && key=='Report_Period_Id'){
                    if(!Test.isRunningTest()){
                        w.writeElement('tns',key ,'tns', String.valueOf(objAP.get(tagMap.get(key))));
                    }
                    rptIdFlg=FALSE;
                }
                if(key!='Report_Period_Id'){
                    if(!Test.isRunningTest()){
                        if(objAP.get(tagMap.get(key)) != null) {
                            w.writeElementWithAttribute('tns',key,'tns', String.valueOf(objAP.get(tagMap.get(key))), 'activity_type_id', '4');
                        } else {
                            w.writeElementWithAttribute('tns',key,'tns', '0', 'activity_type_id', '4');
                        }
                    }
                }
            }
        }
        w.writeEndElement();
    }
    
    public static void writeGroupSessionAndAttendeeDetails(Id x9902RecordId, PrettyXmlStreamWriter w, List<X9902Summary__c> gslst9902) {
        List<X9902Summary__c> gsalst9902 = [ SELECT
                                            Id,
                                            ElementType__c,
                                            X9902__c,
                                            ReportPeriodId__c,
                                            GroupSessionID__c,
                                            GroupSessionAttendeeID__c,
                                            GroupSessionCounselorHUDId__c,
                                            GroupSessionAttendeeFeeAmount__c,
                                            GroupSessionAttendeeReferredBy__c,
                                            GroupSessionAttendeeIncomeLevel__c,
                                            GroupSessionAttendeeCity__c,
                                            GroupSessionAttendeeState__c,
                                            GroupSessionAttendeeZipCode__c,
                                            GroupSessionAttendeeRuralAreaStatus__c,
                                            AttendeeFirstTimeHomeBuyer__c,
                                            GroupAttendeeLimitedEnglishProficiency__c
                                            FROM X9902Summary__c
                                            WHERE X9902__c = :x9902RecordId
                                            AND ElementType__c = 'Group Session Attendee'
                                            //   AND GroupSessionID__c != NULL
                                           ];
        map<String, List<X9902Summary__c>> sessionIdToGroupSessionAttendees = new map<String, List<X9902Summary__c>>();
        for(X9902Summary__c gsa : gsalst9902){
            if(sessionIdToGroupSessionAttendees.containsKey(gsa.GroupSessionID__c)) {
                sessionIdToGroupSessionAttendees.get(gsa.GroupSessionID__c).add(gsa);
            } else {
                sessionIdToGroupSessionAttendees.put(gsa.GroupSessionID__c, new List<X9902Summary__c> { gsa });
            }
        }
        
        // Group Session and Group Session Attendees
        Map<String, String> groupSessionTagToObjField = new Map<String, String> {
            'Group_Session_Id' => 'GroupSessionID__c',
            'Group_Session_Counselor_Id' => 'GroupSessionCounselorID__c',
            'Group_Session_Counselor_HUD_Id' => 'GroupSessionCounselorHUDId__c',
            'Group_Session_Title' => 'GroupSessionTitle__c',
            'Group_Session_Date' => 'GroupSessionDate__c',
            'Group_Session_Duration' => 'GroupSessionDuration__c',
            'Group_Session_Type' => 'GroupSessionType__c',
            'Group_Session_Attribute_HUD_Grant' => 'GroupSessionAttributeHUD_Grant__c',
            'Group_Session_Activity_Type' => 'GroupSessionActivityType__c'
        };
                    
        Map<String, String> groupSessionAttendeeTagToField = new Map<String, String> {
            'Attendee_Id' => 'GroupSessionAttendeeID__c',
            'Attendee_Fee_Amount' => 'GroupSessionAttendeeFeeAmount__c',
            'Attendee_Referred_By' => 'GroupSessionAttendeeReferredBy__c',
            'Attendee_FirstTime_Home_Buyer' => 'AttendeeFirstTimeHomeBuyer__c',
            'Attendee_Income_Level' => 'GroupSessionAttendeeIncomeLevel__c',
            //'Attendee_Address_1' => 'Group_Session_Attendee_Address_1__c',
            //'Attendee_Address_2' => 'Group_Session_Attendee_Address_2__c',
            'Attendee_City' => 'GroupSessionAttendeeCity__c',
            'Attendee_State' => 'GroupSessionAttendeeState__c',
            'Attendee_Zip_Code' => 'GroupSessionAttendeeZipCode__c',
            'Attendee_Rural_Area' => 'GroupSessionAttendeeRuralAreaStatus__c',
            'Attendee_Limited_English_Proficiency' => 'GroupAttendeeLimitedEnglishProficiency__c'
        };
        Map<String, X9902Summary__c> sessionIdToGroupSession = new Map<String, X9902Summary__c>();
        for(X9902Summary__c gs : gslst9902){ 
            sessionIdToGroupSession.put(gs.GroupSessionID__c, gs);
        }
        List<X9902Summary__c> relatedGsAttendees;
        if(gslst9902.size() > 0){
            w.writeStartElement('tns','Group_Sessions ','tns');
            for(X9902Summary__c objAP1 : sessionIdToGroupSession.values()) {
                relatedGsAttendees = sessionIdToGroupSessionAttendees.get(objAp1.GroupSessionID__c);
                if(relatedGsAttendees != null && !relatedGsAttendees.isEmpty()) {
                    w.writeStartElementNoIndentNewLine('tns','Group_Session ','tns');  
                    for(String key : groupSessionTagToObjField.keySet()){  
                        Date groupSessDt=objAP1.GroupSessionDate__c; 
                        if(key!='Group_Session_Date'){
                            if( objAP1.get(groupSessionTagToObjField.get(key)) == null) {
                                w.writeElementNoIndent('tns',key,'tns', '');
                            } else {
                                w.writeElementNoIndent('tns',key,'tns', String.valueOf(objAP1.get(groupSessionTagToObjField.get(key))));
                            }
                        } else {
                            w.writeElementNoIndent('tns',key,'tns', DateTime.newInstance(groupSessDt.year(),groupSessDt.month(),groupSessDt.day()).format('MM-dd-yyyy'));
                        }
                    }
                    // Group Session Attendees
                    if(relatedGsAttendees != null && !relatedGsAttendees.isEmpty()) {
                        w.writeStartElement('tns','Group_Session_Attendees','tns');
                        for(X9902Summary__c objAp2 : relatedGsAttendees){ 
                            // if(objAp2.GroupSessionID__c == objAp1.GroupSessionID__c){  
                            w.writeStartElementNoIndentNewLine('tns','Group_Session_Attendee','tns');
                            for(String key : groupSessionAttendeeTagToField.keySet()){
                                string strAtt = string.valueOf(objAP2.get(groupSessionAttendeeTagToField.get(key)))!=null?string.valueOf(objAP2.get(groupSessionAttendeeTagToField.get(key))):'';
                                if(key != 'Attendee_Address_2'){
                                    if(strAtt != null){
                                        w.writeElementNoIndent('tns',key,'tns', strAtt);
                                    }
                                } else {
                                    String address2 = string.valueOf(objAP2.get(groupSessionAttendeeTagToField.get(key)))!=null?string.valueOf(objAP2.get(groupSessionAttendeeTagToField.get(key))):'';
                                    if(String.isNotBlank(address2)){
                                        w.writeElementNoIndent('tns',key,'tns', address2);
                                    }
                                }
                            }
                            w.writeEndElementNoIndent(); 
                            // } //attendee
                        } //For X9902Summary__c objAp2
                        w.writeEndElement();
                    }
                    w.writeEndElementNoIndent();
                }
            } //For X9902Summary__c objAp1
            w.writeEndElement();
        } //No Group Session Data
    }
    
    public static void writeAttendeeDetails(Id x9902RecordId, PrettyXmlStreamWriter w) {
        Map<String, String> attendeeTagToField = new Map<String, String> {
            'Attendee_Id' => 'AttendeeID__c',
            'Attendee_Income_Level' => 'AttendeeIncomeLevel__c',
            'Attendee_City' => 'AttendeeCity__c',
            'Attendee_State' => 'AttendeeState__c',
            'Attendee_Zip_Code' => 'AttendeeZipCode__c',
            'Attendee_Rural_Area' => 'AttendeeRuralAreaStatus__c',
            'Attendee_Limited_English_Proficiency' => 'AttendeeLimitedEnglishProficiency__c',
            'Attendee_Race_ID' => 'AttendeeRaceID__c',
            'Attendee_Ethnicity_ID' => 'AttendeeEthnicityID__c'
        };
        List<X9902Summary__c> alst9902 = [ SELECT
                                            Id,
                                            ElementType__c,
                                            X9902__c,
                                            ReportPeriodId__c,
                                            AttendeeID__c,
                                            AttendeeCity__c,
                                            AttendeeState__c,
                                            AttendeeZipCode__c,
                                            AttendeeRuralAreaStatus__c,
                                            AttendeeLimitedEnglishProficiency__c,
                                            AttendeeRaceID__c,
                                            AttendeeEthnicityID__c,
                                            AttendeeIncomeLevel__c
                                            FROM X9902Summary__c
                                            WHERE X9902__c = :x9902RecordId
                                            AND ElementType__c = 'Attendee'
                                            LIMIT 10000
                                        ];
        
        w.writeStartElement('tns','Attendees','tns');
        for(X9902Summary__c objAp : alst9902){ 
            w.writeStartElementNoIndentNewLine('tns','Attendee','tns');
            for(String key : attendeeTagToField.keySet()){  
                if(key != 'Attendee_Address_2'){
                    // remove this null check.................let it fail when values are missing.
                    string s1=String.valueOf(objAP.get(attendeeTagToField.get(key)));       
                    if (s1!=null) {
                        w.writeElementNoIndent('tns',key,'tns', String.valueOf(objAP.get(attendeeTagToField.get(key))));
                    } else {
                        w.writeElementNoIndent('tns',key,'tns', '');
                    }
                } else {
                    String address2 = string.valueOf(objAP.get(attendeeTagToField.get(key)))!=null?string.valueOf(objAP.get(attendeeTagToField.get(key))):'';
                    if(String.isNotBlank(address2)){
                        w.writeElementNoIndent('tns',key,'tns', address2);
                    }
                }
            } //Key
            w.writeEndElementNoIndent();
        } //For
        w.writeEndElement();
    }
    
    public void reset9902Fields(X9902__c x9902) {
        x9902.Summary9902SubmissionID__c = '';
        x9902.Summary9902SubmissionStatus__c = 'In-Progress';
        update x9902;
    }
}