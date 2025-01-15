public with sharing class HUD9902ErrorUtilityTest {
    private static String NWC2NameSpace = Utility.getNwc2NameSpace();
    public HUD9902ErrorUtilityTest() {
    }

    @future
    public static void processErrorForSummary(Id X9902RecId) {
        X9902__c x9902Rec = [SELECT Id, ClientSubmissionStatus__c, Summary9902SubmissionStatus__c FROM X9902__c WHERE Id = :X9902RecId LIMIT 1];
        HUD9902ErrorUtility.deleteErrorRecords(x9902Rec.Id, new Set<String>());
        if (x9902Rec.Summary9902SubmissionStatus__c == null || x9902Rec.Summary9902SubmissionStatus__c == '' || x9902Rec.Summary9902SubmissionStatus__c == 'DONE') return;
        List<HUD9902ErrorLog__c> errLogs = new List<HUD9902ErrorLog__c>();
        String hudErrors = x9902Rec.Summary9902SubmissionStatus__c;

        // Add generic error records first
        Set<String> genericErrors = HUD9902ErrorUtility.getGenericErrors(hudErrors);
        for (String errorMsg: genericErrors) {
            errLogs.add(HUD9902ErrorUtility.createErrorRecord(x9902Rec, null, errorMsg, '9902 Summary'));
        }

        // Process record specific error having line numbers
        Map<Integer, String> errorLineNumberToMsg = HUD9902ErrorUtility.getLineNumberDetails(hudErrors);
        Map<String, Integer> identifierToLineNum = new Map<String, Integer>();
        Set<String> identifiers = new Set<String>();
        String identifier;
        for (Integer lineNumber: errorLineNumberToMsg.keySet()) {
            identifier = HUD9902ErrorUtility.getIdentifierTagValueAtLine(HUD9902ErrorUtility.readContentVersion(x9902Rec.Id, '9902_Summary%'), lineNumber);
            if (identifier != null) {
                identifiers.add(identifier);
            }
            identifierToLineNum.put(identifier, lineNumber);
        }
        if (!identifiers.isEmpty()) {
            // Process Group Session Records
            List<sumoapp__AdditionalInfo__c> courseRecs = HUD9902ErrorUtility.getSourceCourseRecs(identifiers);
            Map<String, Id> result = HUD9902ErrorUtility.matchStringsToSObjects(identifiers, courseRecs, HUD9902ErrorUtilityTest.NWC2NameSpace + 'CourseNumber__c');

            // Process Attendee Records
            List<sumoapp__Attendee__c> attendeeRecs = HUD9902ErrorUtility.getSourceAttendeeRecs(identifiers);
            result.putAll(HUD9902ErrorUtility.matchStringsToSObjects(identifiers, attendeeRecs, 'sumoapp__ContactRelation__r.Client__c'));
            Id recId;
            for (String ident: result.keySet()) {
                recId = result.get(ident);
                errLogs.add(HUD9902ErrorUtility.createErrorRecord(x9902Rec, recId, errorLineNumberToMsg.get(identifierToLineNum.get(ident)), '9902 Summary'));
                System.debug(ident + '  :  ' + HUD9902ErrorUtility.generateRecordUrl(recId));
            }
        }
        if (!errLogs.isEmpty()) insert errLogs;
    }

    public static void test() {
        X9902__c x9902Rec = [SELECT Id, ClientSubmissionStatus__c, Summary9902SubmissionStatus__c FROM X9902__c WHERE Id = 'a0tVa000006IUdhIAG' LIMIT 1];
        if (x9902Rec.Summary9902SubmissionStatus__c == null || x9902Rec.Summary9902SubmissionStatus__c == '' || x9902Rec.Summary9902SubmissionStatus__c == 'DONE') return;

        String hudErrors = x9902Rec.Summary9902SubmissionStatus__c;
        // String multilineString = HUD9902ErrorUtility.readContentVersion(x9902Rec.Id);
        // System.debug(multilineString);
        
        Map<Integer, String> errorLineNumberToMsg = HUD9902ErrorUtility.getLineNumberDetails(hudErrors);
        System.debug('errorLineNumberToMsg::' + JSON.serializePretty(errorLineNumberToMsg));
       /* String multilineString = '<?xml version="1.0" encoding="UTF-8"?>\n' +
                                '<tns:SubmissionData xsi:schemaLocation="http://gov.hud.arm/form_9902_databag_6_0 form_9902_databag_6_0.xsd"\n' +
                                '	xmlns:tns="http://gov.hud.arm/form_9902_databag_6_0"\n' +
                                '	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">\n' +
                                '	<tns:Form_9902 >\n' +
                                '		<tns:Report_Period_Id>2</tns:Report_Period_Id>\n' +
                                '		<tns:Ethnicity_Households_Counseling_Hispanic activity_type_id="4">318</tns:Ethnicity_Households_Counseling_Hispanic>\n' +
                                '		<tns:Ethnicity_Households_Counseling_Non_Hispanic activity_type_id="4">283</tns:Ethnicity_Households_Counseling_Non_Hispanic>\n' +
                                '		<tns:Ethnicity_Households_Counseling_No_Response activity_type_id="4">284</tns:Ethnicity_Households_Counseling_No_Response>\n' +
                                '		<tns:Section_3_Total activity_type_id="4">885</tns:Section_3_Total>\n' +
                                '		<tns:Race_Households_Counseling_American_Indian activity_type_id="4">127</tns:Race_Households_Counseling_American_Indian>\n' +
                                '		<tns:Race_Households_Counseling_Asian activity_type_id="4">106</tns:Race_Households_Counseling_Asian>\n' +
                                '		<tns:Race_Households_Counseling_Black_African_American activity_type_id="4">118</tns:Race_Households_Counseling_Black_African_American>\n' +
                                '		<tns:Race_Households_Counseling_Pacific_Islanders activity_type_id="4">140</tns:Race_Households_Counseling_Pacific_Islanders>\n' +
                                '		<tns:Race_Households_Counseling_White activity_type_id="4">122</tns:Race_Households_Counseling_White>\n' +
                                '		<tns:Race_Households_Counseling_More_Than_One_Race activity_type_id="4">132</tns:Race_Households_Counseling_More_Than_One_Race>\n' +
                                '		<tns:Race_Households_Counseling_No_Response activity_type_id="4">140</tns:Race_Households_Counseling_No_Response>\n' +
                                '		<tns:Section_4_Total activity_type_id="4">885</tns:Section_4_Total>\n' +
                                '		<tns:Less30_AMI_Level activity_type_id="4">112</tns:Less30_AMI_Level>\n' +
                                '		<tns:a30_49_AMI_Level activity_type_id="4">138</tns:a30_49_AMI_Level>\n' +
                                '		<tns:a50_79_AMI_Level activity_type_id="4">129</tns:a50_79_AMI_Level>\n' +
                                '		<tns:a80_100_AMI_Level activity_type_id="4">116</tns:a80_100_AMI_Level>\n' +
                                '		<tns:Greater100_AMI_Level activity_type_id="4">256</tns:Greater100_AMI_Level>\n' +
                                '		<tns:AMI_No_Response activity_type_id="4">134</tns:AMI_No_Response>\n' +
                                '		<tns:Section_5_Total activity_type_id="4">885</tns:Section_5_Total>\n' +
                                '		<tns:Lives_In_Rural_Area activity_type_id="4">300</tns:Lives_In_Rural_Area>\n' +
                                '		<tns:Does_Not_Live_In_Rural_Area activity_type_id="4">283</tns:Does_Not_Live_In_Rural_Area>\n' +
                                '		<tns:Rural_Area_No_Response activity_type_id="4">302</tns:Rural_Area_No_Response>\n' +
                                '		<tns:Section_6_Total activity_type_id="4">885</tns:Section_6_Total>\n' +
                                '		<tns:Limited_English_Proficient activity_type_id="4">275</tns:Limited_English_Proficient>\n' +
                                '		<tns:Not_Limited_English_Proficient activity_type_id="4">281</tns:Not_Limited_English_Proficient>\n' +
                                '		<tns:Limited_English_Proficient_No_Response activity_type_id="4">329</tns:Limited_English_Proficient_No_Response>\n' +
                                '		<tns:Section_7_Total activity_type_id="4">885</tns:Section_7_Total>\n' +
                                '		<tns:Education_Compl_Fin_Lit_Workshop activity_type_id="4">0</tns:Education_Compl_Fin_Lit_Workshop>\n' +
                                '		<tns:Education_Compl_Pred_Lend_Workshop activity_type_id="4">0</tns:Education_Compl_Pred_Lend_Workshop>\n' +
                                '		<tns:Education_Compl_Fair_Housing_Workshop activity_type_id="4">805</tns:Education_Compl_Fair_Housing_Workshop>\n' +
                                '		<tns:Education_Compl_Homeless_Prev_Workshop activity_type_id="4">0</tns:Education_Compl_Homeless_Prev_Workshop>\n' +
                                '		<tns:Education_Compl_Rental_Workshop activity_type_id="4">40</tns:Education_Compl_Rental_Workshop>\n' +
                                '		<tns:Education_Compl_PrePurchase_HomeBuyer_Workshop activity_type_id="4">0</tns:Education_Compl_PrePurchase_HomeBuyer_Workshop>\n' +
                                '		<tns:Education_Compl_NonDelinqency_PostPurchase_Workshop activity_type_id="4">40</tns:Education_Compl_NonDelinqency_PostPurchase_Workshop>\n' +
                                '		<tns:Education_Compl_Resolv_Prevent_Mortg_Delinq_Workshop activity_type_id="4">0</tns:Education_Compl_Resolv_Prevent_Mortg_Delinq_Workshop>\n' +
                                '		<tns:Education_Compl_Disaster_Prepare_Workshop activity_type_id="4">0</tns:Education_Compl_Disaster_Prepare_Workshop>\n' +
                                '		<tns:Education_Compl_Disaster_Recovery_Workshop activity_type_id="4">0</tns:Education_Compl_Disaster_Recovery_Workshop>\n' +
                                '		<tns:Section_8_Total activity_type_id="4">885</tns:Section_8_Total>\n' +
                                '		<tns:One_Homeless_Assistance_Counseling activity_type_id="4">0</tns:One_Homeless_Assistance_Counseling>\n' +
                                '		<tns:One_Rental_Topics_Counseling activity_type_id="4">0</tns:One_Rental_Topics_Counseling>\n' +
                                '		<tns:One_PrePurchase_HomeBuying_Counseling activity_type_id="4">0</tns:One_PrePurchase_HomeBuying_Counseling>\n' +
                                '		<tns:One_Non_Delinq_Post_Purchase_Counseling activity_type_id="4">0</tns:One_Non_Delinq_Post_Purchase_Counseling>\n' +
                                '		<tns:One_Reverse_Mortgage_Counseling activity_type_id="4">0</tns:One_Reverse_Mortgage_Counseling>\n' +
                                '		<tns:One_Resolv_Prevent_Fwd_Mortg_Delinq_Counseling activity_type_id="4">0</tns:One_Resolv_Prevent_Fwd_Mortg_Delinq_Counseling>\n' +
                                '		<tns:One_Resolv_Prevent_Rev_Mortg_Delinq_Counseling activity_type_id="4">0</tns:One_Resolv_Prevent_Rev_Mortg_Delinq_Counseling>\n' +
                                '		<tns:One_Disaster_Preparedness_Assistance_Counseling activity_type_id="4">0</tns:One_Disaster_Preparedness_Assistance_Counseling>\n' +
                                '		<tns:One_Disaster_Recovery_Assistance_Counseling activity_type_id="4">0</tns:One_Disaster_Recovery_Assistance_Counseling>\n' +
                                '		<tns:Section_9_Total activity_type_id="4">0</tns:Section_9_Total>\n' +
                                '		<tns:Outcome_One_On_One_And_Education activity_type_id="4">0</tns:Outcome_One_On_One_And_Education>\n' +
                                '		<tns:Outcome_Received_Info_Fair_Housing activity_type_id="4">0</tns:Outcome_Received_Info_Fair_Housing>\n' +
                                '		<tns:Outcome_Developed_Budget activity_type_id="4">0</tns:Outcome_Developed_Budget>\n' +
                                '		<tns:Outcome_Improved_Financial_Capacity activity_type_id="4">0</tns:Outcome_Improved_Financial_Capacity>\n' +
                                '		<tns:Outcome_Gained_Access_Resources_Improve_Housing activity_type_id="4">0</tns:Outcome_Gained_Access_Resources_Improve_Housing>\n' +
                                '		<tns:Outcome_Gained_Access_NonHousing_Resources activity_type_id="4">0</tns:Outcome_Gained_Access_NonHousing_Resources>\n' +
                                '		<tns:Outcome_Homeless_Obtained_Housing activity_type_id="4">0</tns:Outcome_Homeless_Obtained_Housing>\n' +
                                '		<tns:Outcome_Gained_Access_Disaster_Recovery_NonHousing_Resources activity_type_id="4">0</tns:Outcome_Gained_Access_Disaster_Recovery_NonHousing_Resources>\n' +
                                '		<tns:Outcome_Obtained_Disaster_Recovery_Housing_Resources activity_type_id="4">0</tns:Outcome_Obtained_Disaster_Recovery_Housing_Resources>\n' +
                                '		<tns:Outcome_Developed_Emergency_Preparedness_Plan activity_type_id="4">0</tns:Outcome_Developed_Emergency_Preparedness_Plan>\n' +
                                '		<tns:Outcome_Received_Rental_Counseling_Avoided_Eviction activity_type_id="4">0</tns:Outcome_Received_Rental_Counseling_Avoided_Eviction>\n' +
                                '		<tns:Outcome_Received_Rental_Counseling_Improved_Living_Conditions activity_type_id="4">0</tns:Outcome_Received_Rental_Counseling_Improved_Living_Conditions>\n' +
                                '		<tns:Outcome_Received_PrePurchase_Counseling_Purchased_Housing activity_type_id="4">0</tns:Outcome_Received_PrePurchase_Counseling_Purchased_Housing>\n' +
                                '		<tns:Outcome_Received_Reverse_Mortgage_Counseling_Obtained_HECM activity_type_id="4">0</tns:Outcome_Received_Reverse_Mortgage_Counseling_Obtained_HECM>\n' +
                                '		<tns:Outcome_Received_NonDelinquency_PostPurchase_Counseling_Improve_Conditions_Affordability activity_type_id="4">0</tns:Outcome_Received_NonDelinquency_PostPurchase_Counseling_Improve_Conditions_Affordability>\n' +
                                '		<tns:Outcome_Prevented_Resolved_Forward_Mortgage_Default activity_type_id="4">0</tns:Outcome_Prevented_Resolved_Forward_Mortgage_Default>\n' +
                                '		<tns:Outcome_Prevented_Resolved_Reverse_Mortgage_Default activity_type_id="4">0</tns:Outcome_Prevented_Resolved_Reverse_Mortgage_Default>\n' +
                                '		<tns:Outcome_Received_Forward_Mortgage_Modification_Remain_Current_In_Modified_Mortgage activity_type_id="4">0</tns:Outcome_Received_Forward_Mortgage_Modification_Remain_Current_In_Modified_Mortgage>\n' +
                                '		<tns:Outcome_Received_Forward_Mortgage_Modification_Improved_Financial_Capacity activity_type_id="4">0</tns:Outcome_Received_Forward_Mortgage_Modification_Improved_Financial_Capacity>\n' +
                                '		<tns:Section_10_Total activity_type_id="4">0</tns:Section_10_Total>\n' +
                                '	</tns:Form_9902 >\n' +
                                '	<tns:Group_Sessions >\n' +
                                '		<tns:Group_Session >\n' +
                                '			<tns:Group_Session_Id>7200919420</tns:Group_Session_Id>\n' +
                                '			<tns:Group_Session_Counselor_Id>12373</tns:Group_Session_Counselor_Id>\n' +
                                '			<tns:Group_Session_Counselor_HUD_Id>abhi12</tns:Group_Session_Counselor_HUD_Id>\n' +
                                '			<tns:Group_Session_Title>Pre Purchase Best Practices</tns:Group_Session_Title>\n' +
                                '			<tns:Group_Session_Date>11-30-2023</tns:Group_Session_Date>\n' +
                                '			<tns:Group_Session_Duration>60</tns:Group_Session_Duration>\n' +
                                '			<tns:Group_Session_Type>23</tns:Group_Session_Type>\n' +
                                '			<tns:Group_Session_Attribute_HUD_Grant>7</tns:Group_Session_Attribute_HUD_Grant>\n' +
                                '			<tns:Group_Session_Activity_Type>17</tns:Group_Session_Activity_Type>\n' +
                                '			<tns:Group_Session_Attendees>\n' +
                                '				<tns:Group_Session_Attendee>\n' +
                                '					<tns:Attendee_Id>7103710254</tns:Attendee_Id>\n' +
                                '					<tns:Attendee_Fee_Amount>0</tns:Attendee_Fee_Amount>\n' +
                                '					<tns:Attendee_Referred_By>9</tns:Attendee_Referred_By>\n' +
                                '					<tns:Attendee_FirstTime_Home_Buyer>N</tns:Attendee_FirstTime_Home_Buyer>\n' +
                                '					<tns:Attendee_Income_Level>7</tns:Attendee_Income_Level>\n' +
                                '					<tns:Attendee_City>New York</tns:Attendee_City>\n' +
                                '					<tns:Attendee_State>41</tns:Attendee_State>\n' +
                                '					<tns:Attendee_Zip_Code>10005</tns:Attendee_Zip_Code>\n' +
                                '					<tns:Attendee_Rural_Area>1</tns:Attendee_Rural_Area>\n' +
                                '					<tns:Attendee_Limited_English_Proficiency>2</tns:Attendee_Limited_English_Proficiency>\n' +
                                '				</tns:Group_Session_Attendee>\n' +
                                '				<tns:Group_Session_Attendee>\n' +
                                '					<tns:Attendee_Id>7103699588</tns:Attendee_Id>\n' +
                                '					<tns:Attendee_Fee_Amount>0</tns:Attendee_Fee_Amount>\n' +
                                '					<tns:Attendee_Referred_By>9</tns:Attendee_Referred_By>\n' +
                                '					<tns:Attendee_FirstTime_Home_Buyer>N</tns:Attendee_FirstTime_Home_Buyer>\n' +
                                '					<tns:Attendee_Income_Level>11</tns:Attendee_Income_Level>\n' +
                                '					<tns:Attendee_City>New York</tns:Attendee_City>\n' +
                                '					<tns:Attendee_State>41</tns:Attendee_State>\n' +
                                '					<tns:Attendee_Zip_Code>10005</tns:Attendee_Zip_Code>\n' +
                                '					<tns:Attendee_Rural_Area>3</tns:Attendee_Rural_Area>\n' +
                                '					<tns:Attendee_Limited_English_Proficiency>2</tns:Attendee_Limited_English_Proficiency>\n' +
                                '				</tns:Group_Session_Attendee>\n' +
                                '				<tns:Group_Session_Attendee>\n' +
                                '					<tns:Attendee_Id>7103713519</tns:Attendee_Id>\n' +
                                '					<tns:Attendee_Fee_Amount>0</tns:Attendee_Fee_Amount>\n' +
                                '					<tns:Attendee_Referred_By>9</tns:Attendee_Referred_By>\n' +
                                '					<tns:Attendee_FirstTime_Home_Buyer>N</tns:Attendee_FirstTime_Home_Buyer>\n' +
                                '					<tns:Attendee_Income_Level>9</tns:Attendee_Income_Level>\n' +
                                '					<tns:Attendee_City>New York</tns:Attendee_City>\n' +
                                '					<tns:Attendee_State>41</tns:Attendee_State>\n' +
                                '					<tns:Attendee_Zip_Code>10005</tns:Attendee_Zip_Code>\n' +
                                '					<tns:Attendee_Rural_Area>2</tns:Attendee_Rural_Area>\n' +
                                '					<tns:Attendee_Limited_English_Proficiency>2</tns:Attendee_Limited_English_Proficiency>\n' +
                                '				</tns:Group_Session_Attendee>\n' +
                                '				<tns:Group_Session_Attendee>\n' +
                                '					<tns:Attendee_Id>7103695065</tns:Attendee_Id>\n' +
                                '					<tns:Attendee_Fee_Amount>0</tns:Attendee_Fee_Amount>\n' +
                                '					<tns:Attendee_Referred_By>9</tns:Attendee_Referred_By>\n' +
                                '					<tns:Attendee_FirstTime_Home_Buyer>N</tns:Attendee_FirstTime_Home_Buyer>\n' +
                                '					<tns:Attendee_Income_Level>12</tns:Attendee_Income_Level>\n' +
                                '					<tns:Attendee_City>New York</tns:Attendee_City>\n' +
                                '					<tns:Attendee_State>41</tns:Attendee_State>\n' +
                                '					<tns:Attendee_Zip_Code>10005</tns:Attendee_Zip_Code>\n' +
                                '					<tns:Attendee_Rural_Area>1</tns:Attendee_Rural_Area>\n' +
                                '					<tns:Attendee_Limited_English_Proficiency>2</tns:Attendee_Limited_English_Proficiency>\n' +
                                '				</tns:Group_Session_Attendee>\n' +
                                '				<tns:Group_Session_Attendee>\n' +
                                '					<tns:Attendee_Id>7103696251</tns:Attendee_Id>\n' +
                                '					<tns:Attendee_Fee_Amount>0</tns:Attendee_Fee_Amount>\n' +
                                '					<tns:Attendee_Referred_By>9</tns:Attendee_Referred_By>\n' +
                                '					<tns:Attendee_FirstTime_Home_Buyer>N</tns:Attendee_FirstTime_Home_Buyer>\n' +
                                '					<tns:Attendee_Income_Level>9</tns:Attendee_Income_Level>\n' +
                                '					<tns:Attendee_City>New York</tns:Attendee_City>\n' +
                                '					<tns:Attendee_State>41</tns:Attendee_State>\n' +
                                '					<tns:Attendee_Zip_Code>10005</tns:Attendee_Zip_Code>\n' +
                                '					<tns:Attendee_Rural_Area>3</tns:Attendee_Rural_Area>\n' +
                                '					<tns:Attendee_Limited_English_Proficiency>1</tns:Attendee_Limited_English_Proficiency>\n' +
                                '				</tns:Group_Session_Attendee>\n' +
                                '				<tns:Group_Session_Attendee>\n' +
                                '					<tns:Attendee_Id>7103749299</tns:Attendee_Id>\n' +
                                '					<tns:Attendee_Fee_Amount>0</tns:Attendee_Fee_Amount>\n' +
                                '					<tns:Attendee_Referred_By>9</tns:Attendee_Referred_By>\n' +
                                '					<tns:Attendee_FirstTime_Home_Buyer>N</tns:Attendee_FirstTime_Home_Buyer>\n' +
                                '					<tns:Attendee_Income_Level>10</tns:Attendee_Income_Level>\n' +
                                '					<tns:Attendee_City>New York</tns:Attendee_City>\n' +
                                '					<tns:Attendee_State>41</tns:Attendee_State>\n' +
                                '					<tns:Attendee_Zip_Code>10005</tns:Attendee_Zip_Code>\n' +
                                '					<tns:Attendee_Rural_Area>2</tns:Attendee_Rural_Area>\n' +
                                '					<tns:Attendee_Limited_English_Proficiency>3</tns:Attendee_Limited_English_Proficiency>\n' +
                                '				</tns:Group_Session_Attendee>\n' +
                                '				<tns:Group_Session_Attendee>\n' +
                                '					<tns:Attendee_Id>7103727682</tns:Attendee_Id>\n' +
                                '					<tns:Attendee_Fee_Amount>0</tns:Attendee_Fee_Amount>\n' +
                                '					<tns:Attendee_Referred_By>9</tns:Attendee_Referred_By>\n' +
                                '					<tns:Attendee_FirstTime_Home_Buyer>N</tns:Attendee_FirstTime_Home_Buyer>\n' +
                                '					<tns:Attendee_Income_Level>11</tns:Attendee_Income_Level>\n' +
                                '					<tns:Attendee_City>New York</tns:Attendee_City>\n' +
                                '					<tns:Attendee_State>41</tns:Attendee_State>\n' +
                                '					<tns:Attendee_Zip_Code>10005</tns:Attendee_Zip_Code>\n' +
                                '					<tns:Attendee_Rural_Area>2</tns:Attendee_Rural_Area>\n' +
                                '					<tns:Attendee_Limited_English_Proficiency>3</tns:Attendee_Limited_English_Proficiency>\n' +
                                '				</tns:Group_Session_Attendee>\n' +
                                '				<tns:Group_Session_Attendee>\n' +
                                '					<tns:Attendee_Id>7103659412</tns:Attendee_Id>\n' +
                                '					<tns:Attendee_Fee_Amount>0</tns:Attendee_Fee_Amount>\n' +
                                '					<tns:Attendee_Referred_By>9</tns:Attendee_Referred_By>\n' +
                                '					<tns:Attendee_FirstTime_Home_Buyer>N</tns:Attendee_FirstTime_Home_Buyer>\n' +
                                '					<tns:Attendee_Income_Level>7</tns:Attendee_Income_Level>\n' +
                                '					<tns:Attendee_City>New York</tns:Attendee_City>\n' +
                                '					<tns:Attendee_State>41</tns:Attendee_State>\n' +
                                '					<tns:Attendee_Zip_Code>10005</tns:Attendee_Zip_Code>\n' +
                                '					<tns:Attendee_Rural_Area>2</tns:Attendee_Rural_Area>\n' +
                                '					<tns:Attendee_Limited_English_Proficiency>1</tns:Attendee_Limited_English_Proficiency>\n' +
                                '				</tns:Group_Session_Attendee>\n' +
                                '				<tns:Group_Session_Attendee>\n' +
                                '					<tns:Attendee_Id>7103669638</tns:Attendee_Id>\n' +
                                '					<tns:Attendee_Fee_Amount>0</tns:Attendee_Fee_Amount>\n' +
                                '					<tns:Attendee_Referred_By>9</tns:Attendee_Referred_By>\n' +
                                '					<tns:Attendee_FirstTime_Home_Buyer>N</tns:Attendee_FirstTime_Home_Buyer>\n' +
                                '					<tns:Attendee_Income_Level>7</tns:Attendee_Income_Level>\n' +
                                '					<tns:Attendee_City>New York</tns:Attendee_City>\n' +
                                '					<tns:Attendee_State>41</tns:Attendee_State>\n' +
                                '					<tns:Attendee_Zip_Code>10005</tns:Attendee_Zip_Code>\n' +
                                '					<tns:Attendee_Rural_Area>2</tns:Attendee_Rural_Area>\n' +
                                '					<tns:Attendee_Limited_English_Proficiency>2</tns:Attendee_Limited_English_Proficiency>\n' +
                                '				</tns:Group_Session_Attendee>\n' +
                                '				<tns:Group_Session_Attendee>\n' +
                                '					<tns:Attendee_Id>7103736063</tns:Attendee_Id>\n' +
                                '					<tns:Attendee_Fee_Amount>0</tns:Attendee_Fee_Amount>\n' +
                                '					<tns:Attendee_Referred_By>9</tns:Attendee_Referred_By>\n' +
                                '					<tns:Attendee_FirstTime_Home_Buyer>N</tns:Attendee_FirstTime_Home_Buyer>\n' +
                                '					<tns:Attendee_Income_Level>11</tns:Attendee_Income_Level>\n' +
                                '					<tns:Attendee_City>New York</tns:Attendee_City>\n' +
                                '					<tns:Attendee_State>41</tns:Attendee_State>\n' +
                                '					<tns:Attendee_Zip_Code>10005</tns:Attendee_Zip_Code>\n' +
                                '					<tns:Attendee_Rural_Area>2</tns:Attendee_Rural_Area>\n' +
                                '					<tns:Attendee_Limited_English_Proficiency>1</tns:Attendee_Limited_English_Proficiency>\n' +
                                '				</tns:Group_Session_Attendee>\n' +
                                '				<tns:Group_Session_Attendee>\n' +
                                '					<tns:Attendee_Id>7103671348</tns:Attendee_Id>\n' +
                                '					<tns:Attendee_Fee_Amount>0</tns:Attendee_Fee_Amount>\n' +
                                '					<tns:Attendee_Referred_By>9</tns:Attendee_Referred_By>\n' +
                                '					<tns:Attendee_FirstTime_Home_Buyer>N</tns:Attendee_FirstTime_Home_Buyer>\n' +
                                '					<tns:Attendee_Income_Level>10</tns:Attendee_Income_Level>\n' +
                                '					<tns:Attendee_City>New York</tns:Attendee_City>\n' +
                                '					<tns:Attendee_State>41</tns:Attendee_State>\n' +
                                '					<tns:Attendee_Zip_Code>10005</tns:Attendee_Zip_Code>\n' +
                                '					<tns:Attendee_Rural_Area>2</tns:Attendee_Rural_Area>\n' +
                                '					<tns:Attendee_Limited_English_Proficiency>1</tns:Attendee_Limited_English_Proficiency>\n' +
                                '				</tns:Group_Session_Attendee>\n' +
                                '				<tns:Group_Session_Attendee>\n' +
                                '					<tns:Attendee_Id>7103704338</tns:Attendee_Id>\n' +
                                '					<tns:Attendee_Fee_Amount>0</tns:Attendee_Fee_Amount>\n' +
                                '					<tns:Attendee_Referred_By>9</tns:Attendee_Referred_By>\n' +
                                '					<tns:Attendee_FirstTime_Home_Buyer>N</tns:Attendee_FirstTime_Home_Buyer>\n' +
                                '					<tns:Attendee_Income_Level>7</tns:Attendee_Income_Level>\n' +
                                '					<tns:Attendee_City>New York</tns:Attendee_City>\n' +
                                '					<tns:Attendee_State>41</tns:Attendee_State>\n' +
                                '					<tns:Attendee_Zip_Code>10005</tns:Attendee_Zip_Code>\n' +
                                '					<tns:Attendee_Rural_Area>1</tns:Attendee_Rural_Area>\n' +
                                '					<tns:Attendee_Limited_English_Proficiency>1</tns:Attendee_Limited_English_Proficiency>\n' +
                                '				</tns:Group_Session_Attendee>\n' +
                                '				<tns:Group_Session_Attendee>\n' +
                                '					<tns:Attendee_Id>7103693212</tns:Attendee_Id>\n' +
                                '					<tns:Attendee_Fee_Amount>0</tns:Attendee_Fee_Amount>\n' +
                                '					<tns:Attendee_Referred_By>9</tns:Attendee_Referred_By>\n' +
                                '					<tns:Attendee_FirstTime_Home_Buyer>N</tns:Attendee_FirstTime_Home_Buyer>\n' +
                                '					<tns:Attendee_Income_Level>11</tns:Attendee_Income_Level>\n' +
                                '					<tns:Attendee_City>New York</tns:Attendee_City>\n' +
                                '					<tns:Attendee_State>41</tns:Attendee_State>\n' +
                                '					<tns:Attendee_Zip_Code>10005</tns:Attendee_Zip_Code>\n' +
                                '					<tns:Attendee_Rural_Area>2</tns:Attendee_Rural_Area>\n' +
                                '					<tns:Attendee_Limited_English_Proficiency>3</tns:Attendee_Limited_English_Proficiency>\n' +
                                '				</tns:Group_Session_Attendee>\n' +
                                '				<tns:Group_Session_Attendee>\n' +
                                '					<tns:Attendee_Id>7103716890</tns:Attendee_Id>\n' +
                                '					<tns:Attendee_Fee_Amount>0</tns:Attendee_Fee_Amount>\n' +
                                '					<tns:Attendee_Referred_By>9</tns:Attendee_Referred_By>\n' +
                                '					<tns:Attendee_FirstTime_Home_Buyer>N</tns:Attendee_FirstTime_Home_Buyer>\n' +
                                '					<tns:Attendee_Income_Level>11</tns:Attendee_Income_Level>\n' +
                                '					<tns:Attendee_City>New York</tns:Attendee_City>\n' +
                                '					<tns:Attendee_State>41</tns:Attendee_State>\n' +
                                '					<tns:Attendee_Zip_Code>10005</tns:Attendee_Zip_Code>\n' +
                                '					<tns:Attendee_Rural_Area>2</tns:Attendee_Rural_Area>\n' +
                                '					<tns:Attendee_Limited_English_Proficiency>1</tns:Attendee_Limited_English_Proficiency>\n' +
                                '				</tns:Group_Session_Attendee>\n' +
                                '				<tns:Group_Session_Attendee>\n' +
                                '					<tns:Attendee_Id>7103744111</tns:Attendee_Id>\n' +
                                '					<tns:Attendee_Fee_Amount>0</tns:Attendee_Fee_Amount>\n' +
                                '					<tns:Attendee_Referred_By>9</tns:Attendee_Referred_By>\n' +
                                '					<tns:Attendee_FirstTime_Home_Buyer>N</tns:Attendee_FirstTime_Home_Buyer>\n' +
                                '					<tns:Attendee_Income_Level>7</tns:Attendee_Income_Level>\n' +
                                '					<tns:Attendee_City>New York</tns:Attendee_City>\n' +
                                '					<tns:Attendee_State>41</tns:Attendee_State>\n' +
                                '					<tns:Attendee_Zip_Code>10005</tns:Attendee_Zip_Code>\n' +
                                '					<tns:Attendee_Rural_Area>2</tns:Attendee_Rural_Area>\n' +
                                '					<tns:Attendee_Limited_English_Proficiency>3</tns:Attendee_Limited_English_Proficiency>\n' +
                                '				</tns:Group_Session_Attendee>\n' +
                                '				<tns:Group_Session_Attendee>\n' +
                                '					<tns:Attendee_Id>7103749814</tns:Attendee_Id>\n' +
                                '					<tns:Attendee_Fee_Amount>0</tns:Attendee_Fee_Amount>\n' +
                                '					<tns:Attendee_Referred_By>9</tns:Attendee_Referred_By>\n' +
                                '					<tns:Attendee_FirstTime_Home_Buyer>N</tns:Attendee_FirstTime_Home_Buyer>\n' +
                                '					<tns:Attendee_Income_Level>9</tns:Attendee_Income_Level>\n' +
                                '					<tns:Attendee_City>New York</tns:Attendee_City>\n' +
                                '					<tns:Attendee_State>41</tns:Attendee_State>\n' +
                                '					<tns:Attendee_Zip_Code>10005</tns:Attendee_Zip_Code>\n' +
                                '					<tns:Attendee_Rural_Area>1</tns:Attendee_Rural_Area>\n' +
                                '					<tns:Attendee_Limited_English_Proficiency>2</tns:Attendee_Limited_English_Proficiency>\n' +
                                '				</tns:Group_Session_Attendee>\n' +
                                '				<tns:Group_Session_Attendee>\n' +
                                '					<tns:Attendee_Id>7103681814</tns:Attendee_Id>\n' +
                                '					<tns:Attendee_Fee_Amount>0</tns:Attendee_Fee_Amount>\n' +
                                '					<tns:Attendee_Referred_By>9</tns:Attendee_Referred_By>\n' +
                                '					<tns:Attendee_FirstTime_Home_Buyer>N</tns:Attendee_FirstTime_Home_Buyer>\n' +
                                '					<tns:Attendee_Income_Level>7</tns:Attendee_Income_Level>\n' +
                                '					<tns:Attendee_City>New York</tns:Attendee_City>\n' +
                                '					<tns:Attendee_State>41</tns:Attendee_State>\n' +
                                '					<tns:Attendee_Zip_Code>10005</tns:Attendee_Zip_Code>\n' +
                                '					<tns:Attendee_Rural_Area>1</tns:Attendee_Rural_Area>\n' +
                                '					<tns:Attendee_Limited_English_Proficiency>2</tns:Attendee_Limited_English_Proficiency>\n' +
                                '				</tns:Group_Session_Attendee>\n' +
                                '				<tns:Group_Session_Attendee>\n' +
                                '					<tns:Attendee_Id>7103661744</tns:Attendee_Id>\n' +
                                '					<tns:Attendee_Fee_Amount>0</tns:Attendee_Fee_Amount>\n' +
                                '					<tns:Attendee_Referred_By>9</tns:Attendee_Referred_By>\n' +
                                '					<tns:Attendee_FirstTime_Home_Buyer>N</tns:Attendee_FirstTime_Home_Buyer>\n' +
                                '					<tns:Attendee_Income_Level>7</tns:Attendee_Income_Level>\n' +
                                '					<tns:Attendee_City>New York</tns:Attendee_City>\n' +
                                '					<tns:Attendee_State>41</tns:Attendee_State>\n' +
                                '					<tns:Attendee_Zip_Code>10005</tns:Attendee_Zip_Code>\n' +
                                '					<tns:Attendee_Rural_Area>3</tns:Attendee_Rural_Area>\n' +
                                '					<tns:Attendee_Limited_English_Proficiency>1</tns:Attendee_Limited_English_Proficiency>\n' +
                                '				</tns:Group_Session_Attendee>\n' +
                                '				<tns:Group_Session_Attendee>\n' +
                                '					<tns:Attendee_Id>7103660938</tns:Attendee_Id>\n' +
                                '					<tns:Attendee_Fee_Amount>0</tns:Attendee_Fee_Amount>\n' +
                                '					<tns:Attendee_Referred_By>9</tns:Attendee_Referred_By>\n' +
                                '					<tns:Attendee_FirstTime_Home_Buyer>N</tns:Attendee_FirstTime_Home_Buyer>\n' +
                                '					<tns:Attendee_Income_Level>11</tns:Attendee_Income_Level>\n' +
                                '					<tns:Attendee_City>New York</tns:Attendee_City>\n' +
                                '					<tns:Attendee_State>41</tns:Attendee_State>\n' +
                                '					<tns:Attendee_Zip_Code>10005</tns:Attendee_Zip_Code>\n' +
                                '					<tns:Attendee_Rural_Area>2</tns:Attendee_Rural_Area>\n' +
                                '					<tns:Attendee_Limited_English_Proficiency>1</tns:Attendee_Limited_English_Proficiency>\n' +
                                '				</tns:Group_Session_Attendee>\n' +
                                '				<tns:Group_Session_Attendee>\n' +
                                '					<tns:Attendee_Id>7103744241</tns:Attendee_Id>\n' +
                                '					<tns:Attendee_Fee_Amount>0</tns:Attendee_Fee_Amount>\n' +
                                '					<tns:Attendee_Referred_By>9</tns:Attendee_Referred_By>\n' +
                                '					<tns:Attendee_FirstTime_Home_Buyer>N</tns:Attendee_FirstTime_Home_Buyer>\n' +
                                '					<tns:Attendee_Income_Level>12</tns:Attendee_Income_Level>\n' +
                                '					<tns:Attendee_City>New York</tns:Attendee_City>\n' +
                                '					<tns:Attendee_State>41</tns:Attendee_State>\n' +
                                '					<tns:Attendee_Zip_Code>10005</tns:Attendee_Zip_Code>\n' +
                                '					<tns:Attendee_Rural_Area>1</tns:Attendee_Rural_Area>\n' +
                                '					<tns:Attendee_Limited_English_Proficiency>1</tns:Attendee_Limited_English_Proficiency>\n' +
                                '				</tns:Group_Session_Attendee>\n' +
                                '				<tns:Group_Session_Attendee>\n' +
                                '					<tns:Attendee_Id>7103739196</tns:Attendee_Id>\n' +
                                '					<tns:Attendee_Fee_Amount>0</tns:Attendee_Fee_Amount>\n' +
                                '					<tns:Attendee_Referred_By>9</tns:Attendee_Referred_By>\n' +
                                '					<tns:Attendee_FirstTime_Home_Buyer>N</tns:Attendee_FirstTime_Home_Buyer>\n' +
                                '					<tns:Attendee_Income_Level>12</tns:Attendee_Income_Level>\n' +
                                '					<tns:Attendee_City>New York</tns:Attendee_City>\n' +
                                '					<tns:Attendee_State>41</tns:Attendee_State>\n' +
                                '					<tns:Attendee_Zip_Code>10005</tns:Attendee_Zip_Code>\n' +
                                '					<tns:Attendee_Rural_Area>1</tns:Attendee_Rural_Area>\n' +
                                '					<tns:Attendee_Limited_English_Proficiency>3</tns:Attendee_Limited_English_Proficiency>\n' +
                                '				</tns:Group_Session_Attendee>\n' +
                                '				<tns:Group_Session_Attendee>\n' +
                                '					<tns:Attendee_Id>7103663620</tns:Attendee_Id>\n' +
                                '					<tns:Attendee_Fee_Amount>0</tns:Attendee_Fee_Amount>\n' +
                                '					<tns:Attendee_Referred_By>9</tns:Attendee_Referred_By>\n' +
                                '					<tns:Attendee_FirstTime_Home_Buyer>N</tns:Attendee_FirstTime_Home_Buyer>\n' +
                                '					<tns:Attendee_Income_Level>11</tns:Attendee_Income_Level>\n' +
                                '					<tns:Attendee_City>New York</tns:Attendee_City>\n' +
                                '					<tns:Attendee_State>41</tns:Attendee_State>\n' +
                                '					<tns:Attendee_Zip_Code>10005</tns:Attendee_Zip_Code>\n' +
                                '					<tns:Attendee_Rural_Area>3</tns:Attendee_Rural_Area>\n' +
                                '					<tns:Attendee_Limited_English_Proficiency>2</tns:Attendee_Limited_English_Proficiency>\n' +
                                '				</tns:Group_Session_Attendee>\n' +
                                '				<tns:Group_Session_Attendee>\n' +
                                '					<tns:Attendee_Id>7103687808</tns:Attendee_Id>\n' +
                                '					<tns:Attendee_Fee_Amount>0</tns:Attendee_Fee_Amount>\n' +
                                '					<tns:Attendee_Referred_By>9</tns:Attendee_Referred_By>\n' +
                                '					<tns:Attendee_FirstTime_Home_Buyer>N</tns:Attendee_FirstTime_Home_Buyer>\n' +
                                '					<tns:Attendee_Income_Level>12</tns:Attendee_Income_Level>\n' +
                                '					<tns:Attendee_City>New York</tns:Attendee_City>\n' +
                                '					<tns:Attendee_State>41</tns:Attendee_State>\n' +
                                '					<tns:Attendee_Zip_Code>10005</tns:Attendee_Zip_Code>\n' +
                                '					<tns:Attendee_Rural_Area>3</tns:Attendee_Rural_Area>\n' +
                                '					<tns:Attendee_Limited_English_Proficiency>1</tns:Attendee_Limited_English_Proficiency>\n' +
                                '				</tns:Group_Session_Attendee>\n' +
                                '				<tns:Group_Session_Attendee>\n' +
                                '					<tns:Attendee_Id>7103735774</tns:Attendee_Id>\n' +
                                '					<tns:Attendee_Fee_Amount>0</tns:Attendee_Fee_Amount>\n' +
                                '					<tns:Attendee_Referred_By>9</tns:Attendee_Referred_By>\n' +
                                '					<tns:Attendee_FirstTime_Home_Buyer>N</tns:Attendee_FirstTime_Home_Buyer>\n' +
                                '					<tns:Attendee_Income_Level>8</tns:Attendee_Income_Level>\n' +
                                '					<tns:Attendee_City>New York</tns:Attendee_City>\n' +
                                '					<tns:Attendee_State>41</tns:Attendee_State>\n' +
                                '					<tns:Attendee_Zip_Code>10005</tns:Attendee_Zip_Code>\n' +
                                '					<tns:Attendee_Rural_Area>3</tns:Attendee_Rural_Area>\n' +
                                '					<tns:Attendee_Limited_English_Proficiency>2</tns:Attendee_Limited_English_Proficiency>\n' +
                                '				</tns:Group_Session_Attendee>\n' +
                                '				<tns:Group_Session_Attendee>\n' +
                                '					<tns:Attendee_Id>7103669305</tns:Attendee_Id>\n' +
                                '					<tns:Attendee_Fee_Amount>0</tns:Attendee_Fee_Amount>\n' +
                                '					<tns:Attendee_Referred_By>9</tns:Attendee_Referred_By>\n' +
                                '					<tns:Attendee_FirstTime_Home_Buyer>N</tns:Attendee_FirstTime_Home_Buyer>\n' +
                                '					<tns:Attendee_Income_Level>12</tns:Attendee_Income_Level>\n' +
                                '					<tns:Attendee_City>New York</tns:Attendee_City>\n' +
                                '					<tns:Attendee_State>41</tns:Attendee_State>\n' +
                                '					<tns:Attendee_Zip_Code>10005</tns:Attendee_Zip_Code>\n' +
                                '					<tns:Attendee_Rural_Area>1</tns:Attendee_Rural_Area>\n' +
                                '					<tns:Attendee_Limited_English_Proficiency>1</tns:Attendee_Limited_English_Proficiency>\n' +
                                '				</tns:Group_Session_Attendee>\n' +
                                '				<tns:Group_Session_Attendee>\n' +
                                '					<tns:Attendee_Id>7103682436</tns:Attendee_Id>\n' +
                                '					<tns:Attendee_Fee_Amount>0</tns:Attendee_Fee_Amount>\n' +
                                '					<tns:Attendee_Referred_By>9</tns:Attendee_Referred_By>\n' +
                                '					<tns:Attendee_FirstTime_Home_Buyer>N</tns:Attendee_FirstTime_Home_Buyer>\n' +
                                '					<tns:Attendee_Income_Level>9</tns:Attendee_Income_Level>\n' +
                                '					<tns:Attendee_City>New York</tns:Attendee_City>\n' +
                                '					<tns:Attendee_State>41</tns:Attendee_State>\n' +
                                '					<tns:Attendee_Zip_Code>10005</tns:Attendee_Zip_Code>\n' +
                                '					<tns:Attendee_Rural_Area>3</tns:Attendee_Rural_Area>\n' +
                                '					<tns:Attendee_Limited_English_Proficiency>2</tns:Attendee_Limited_English_Proficiency>\n' +
                                '				</tns:Group_Session_Attendee>\n' +
                                '				<tns:Group_Session_Attendee>\n' +
                                '					<tns:Attendee_Id>7103732327</tns:Attendee_Id>\n' +
                                '					<tns:Attendee_Fee_Amount>0</tns:Attendee_Fee_Amount>\n' +
                                '					<tns:Attendee_Referred_By>9</tns:Attendee_Referred_By>\n' +
                                '					<tns:Attendee_FirstTime_Home_Buyer>N</tns:Attendee_FirstTime_Home_Buyer>\n' +
                                '					<tns:Attendee_Income_Level>12</tns:Attendee_Income_Level>\n' +
                                '					<tns:Attendee_City>New York</tns:Attendee_City>\n' +
                                '					<tns:Attendee_State>41</tns:Attendee_State>\n' +
                                '					<tns:Attendee_Zip_Code>10005</tns:Attendee_Zip_Code>\n' +
                                '					<tns:Attendee_Rural_Area>3</tns:Attendee_Rural_Area>\n' +
                                '					<tns:Attendee_Limited_English_Proficiency>1</tns:Attendee_Limited_English_Proficiency>\n' +
                                '				</tns:Group_Session_Attendee>\n' +
                                '				<tns:Group_Session_Attendee>\n' +
                                '					<tns:Attendee_Id>7103685922</tns:Attendee_Id>\n' +
                                '					<tns:Attendee_Fee_Amount>0</tns:Attendee_Fee_Amount>\n' +
                                '					<tns:Attendee_Referred_By>9</tns:Attendee_Referred_By>\n' +
                                '					<tns:Attendee_FirstTime_Home_Buyer>N</tns:Attendee_FirstTime_Home_Buyer>\n' +
                                '					<tns:Attendee_Income_Level>7</tns:Attendee_Income_Level>\n' +
                                '					<tns:Attendee_City>New York</tns:Attendee_City>\n' +
                                '					<tns:Attendee_State>41</tns:Attendee_State>\n' +
                                '					<tns:Attendee_Zip_Code>10005</tns:Attendee_Zip_Code>\n' +
                                '					<tns:Attendee_Rural_Area>3</tns:Attendee_Rural_Area>\n' +
                                '					<tns:Attendee_Limited_English_Proficiency>1</tns:Attendee_Limited_English_Proficiency>\n' +
                                '				</tns:Group_Session_Attendee>\n' +
                                '				<tns:Group_Session_Attendee>\n' +
                                '					<tns:Attendee_Id>7103678270</tns:Attendee_Id>\n' +
                                '					<tns:Attendee_Fee_Amount>0</tns:Attendee_Fee_Amount>\n' +
                                '					<tns:Attendee_Referred_By>9</tns:Attendee_Referred_By>\n' +
                                '					<tns:Attendee_FirstTime_Home_Buyer>N</tns:Attendee_FirstTime_Home_Buyer>\n' +
                                '					<tns:Attendee_Income_Level>11</tns:Attendee_Income_Level>\n' +
                                '					<tns:Attendee_City>New York</tns:Attendee_City>\n' +
                                '					<tns:Attendee_State>41</tns:Attendee_State>\n' +
                                '					<tns:Attendee_Zip_Code>10005</tns:Attendee_Zip_Code>\n' +
                                '					<tns:Attendee_Rural_Area>3</tns:Attendee_Rural_Area>\n' +
                                '					<tns:Attendee_Limited_English_Proficiency>1</tns:Attendee_Limited_English_Proficiency>\n' +
                                '				</tns:Group_Session_Attendee>\n' +
                                '				<tns:Group_Session_Attendee>\n' +
                                '					<tns:Attendee_Id>7103702395</tns:Attendee_Id>\n' +
                                '					<tns:Attendee_Fee_Amount>0</tns:Attendee_Fee_Amount>\n' +
                                '					<tns:Attendee_Referred_By>9</tns:Attendee_Referred_By>\n' +
                                '					<tns:Attendee_FirstTime_Home_Buyer>N</tns:Attendee_FirstTime_Home_Buyer>\n' +
                                '					<tns:Attendee_Income_Level>11</tns:Attendee_Income_Level>\n' +
                                '					<tns:Attendee_City>New York</tns:Attendee_City>\n' +
                                '					<tns:Attendee_State>41</tns:Attendee_State>\n' +
                                '					<tns:Attendee_Zip_Code>10005</tns:Attendee_Zip_Code>\n' +
                                '					<tns:Attendee_Rural_Area>1</tns:Attendee_Rural_Area>\n' +
                                '					<tns:Attendee_Limited_English_Proficiency>2</tns:Attendee_Limited_English_Proficiency>\n' +
                                '				</tns:Group_Session_Attendee>\n' +
                                '				<tns:Group_Session_Attendee>\n' +
                                '					<tns:Attendee_Id>7103681172</tns:Attendee_Id>\n' +
                                '					<tns:Attendee_Fee_Amount>0</tns:Attendee_Fee_Amount>\n' +
                                '					<tns:Attendee_Referred_By>9</tns:Attendee_Referred_By>\n' +
                                '					<tns:Attendee_FirstTime_Home_Buyer>N</tns:Attendee_FirstTime_Home_Buyer>\n' +
                                '					<tns:Attendee_Income_Level>7</tns:Attendee_Income_Level>\n' +
                                '					<tns:Attendee_City>New York</tns:Attendee_City>\n' +
                                '					<tns:Attendee_State>41</tns:Attendee_State>\n' +
                                '					<tns:Attendee_Zip_Code>10005</tns:Attendee_Zip_Code>\n' +
                                '					<tns:Attendee_Rural_Area>2</tns:Attendee_Rural_Area>\n' +
                                '					<tns:Attendee_Limited_English_Proficiency>3</tns:Attendee_Limited_English_Proficiency>\n' +
                                '				</tns:Group_Session_Attendee>\n' +
                                '				<tns:Group_Session_Attendee>\n' +
                                '					<tns:Attendee_Id>7103749835</tns:Attendee_Id>\n' +
                                '					<tns:Attendee_Fee_Amount>0</tns:Attendee_Fee_Amount>\n' +
                                '					<tns:Attendee_Referred_By>9</tns:Attendee_Referred_By>\n' +
                                '					<tns:Attendee_FirstTime_Home_Buyer>N</tns:Attendee_FirstTime_Home_Buyer>\n' +
                                '					<tns:Attendee_Income_Level>11</tns:Attendee_Income_Level>\n' +
                                '					<tns:Attendee_City>New York</tns:Attendee_City>\n' +
                                '					<tns:Attendee_State>41</tns:Attendee_State>\n' +
                                '					<tns:Attendee_Zip_Code>10005</tns:Attendee_Zip_Code>\n' +
                                '					<tns:Attendee_Rural_Area>1</tns:Attendee_Rural_Area>\n' +
                                '					<tns:Attendee_Limited_English_Proficiency>3</tns:Attendee_Limited_English_Proficiency>\n' +
                                '				</tns:Group_Session_Attendee>\n' +
                                '				<tns:Group_Session_Attendee>\n' +
                                '					<tns:Attendee_Id>7103727210</tns:Attendee_Id>\n' +
                                '					<tns:Attendee_Fee_Amount>0</tns:Attendee_Fee_Amount>\n' +
                                '					<tns:Attendee_Referred_By>9</tns:Attendee_Referred_By>\n' +
                                '					<tns:Attendee_FirstTime_Home_Buyer>N</tns:Attendee_FirstTime_Home_Buyer>\n' +
                                '					<tns:Attendee_Income_Level>8</tns:Attendee_Income_Level>\n' +
                                '					<tns:Attendee_City>New York</tns:Attendee_City>\n' +
                                '					<tns:Attendee_State>41</tns:Attendee_State>\n' +
                                '					<tns:Attendee_Zip_Code>10005</tns:Attendee_Zip_Code>\n' +
                                '					<tns:Attendee_Rural_Area>1</tns:Attendee_Rural_Area>\n' +
                                '					<tns:Attendee_Limited_English_Proficiency>2</tns:Attendee_Limited_English_Proficiency>\n' +
                                '				</tns:Group_Session_Attendee>\n' +
                                '				<tns:Group_Session_Attendee>\n' +
                                '					<tns:Attendee_Id>7103690749</tns:Attendee_Id>\n' +
                                '					<tns:Attendee_Fee_Amount>0</tns:Attendee_Fee_Amount>\n' +
                                '					<tns:Attendee_Referred_By>9</tns:Attendee_Referred_By>\n' +
                                '					<tns:Attendee_FirstTime_Home_Buyer>N</tns:Attendee_FirstTime_Home_Buyer>\n' +
                                '					<tns:Attendee_Income_Level>10</tns:Attendee_Income_Level>\n' +
                                '					<tns:Attendee_City>New York</tns:Attendee_City>\n' +
                                '					<tns:Attendee_State>41</tns:Attendee_State>\n' +
                                '					<tns:Attendee_Zip_Code>10005</tns:Attendee_Zip_Code>\n' +
                                '					<tns:Attendee_Rural_Area>2</tns:Attendee_Rural_Area>\n' +
                                '					<tns:Attendee_Limited_English_Proficiency>1</tns:Attendee_Limited_English_Proficiency>\n' +
                                '				</tns:Group_Session_Attendee>\n' +
                                '				<tns:Group_Session_Attendee>\n' +
                                '					<tns:Attendee_Id>7103664663</tns:Attendee_Id>\n' +
                                '					<tns:Attendee_Fee_Amount>0</tns:Attendee_Fee_Amount>\n' +
                                '					<tns:Attendee_Referred_By>9</tns:Attendee_Referred_By>\n' +
                                '					<tns:Attendee_FirstTime_Home_Buyer>N</tns:Attendee_FirstTime_Home_Buyer>\n' +
                                '					<tns:Attendee_Income_Level>11</tns:Attendee_Income_Level>\n' +
                                '					<tns:Attendee_City>New York</tns:Attendee_City>\n' +
                                '					<tns:Attendee_State>41</tns:Attendee_State>\n' +
                                '					<tns:Attendee_Zip_Code>10005</tns:Attendee_Zip_Code>\n' +
                                '					<tns:Attendee_Rural_Area>2</tns:Attendee_Rural_Area>\n' +
                                '					<tns:Attendee_Limited_English_Proficiency>2</tns:Attendee_Limited_English_Proficiency>\n' +
                                '				</tns:Group_Session_Attendee>\n' +
                                '				<tns:Group_Session_Attendee>\n' +
                                '					<tns:Attendee_Id>7103741695</tns:Attendee_Id>\n' +
                                '					<tns:Attendee_Fee_Amount>0</tns:Attendee_Fee_Amount>\n' +
                                '					<tns:Attendee_Referred_By>9</tns:Attendee_Referred_By>\n' +
                                '					<tns:Attendee_FirstTime_Home_Buyer>N</tns:Attendee_FirstTime_Home_Buyer>\n' +
                                '					<tns:Attendee_Income_Level>9</tns:Attendee_Income_Level>\n' +
                                '					<tns:Attendee_City>New York</tns:Attendee_City>\n' +
                                '					<tns:Attendee_State>41</tns:Attendee_State>\n' +
                                '					<tns:Attendee_Zip_Code>10005</tns:Attendee_Zip_Code>\n' +
                                '					<tns:Attendee_Rural_Area>3</tns:Attendee_Rural_Area>\n' +
                                '					<tns:Attendee_Limited_English_Proficiency>3</tns:Attendee_Limited_English_Proficiency>\n' +
                                '				</tns:Group_Session_Attendee>\n' +
                                '				<tns:Group_Session_Attendee>\n' +
                                '					<tns:Attendee_Id>7103709403</tns:Attendee_Id>\n' +
                                '					<tns:Attendee_Fee_Amount>0</tns:Attendee_Fee_Amount>\n' +
                                '					<tns:Attendee_Referred_By>9</tns:Attendee_Referred_By>\n' +
                                '					<tns:Attendee_FirstTime_Home_Buyer>N</tns:Attendee_FirstTime_Home_Buyer>\n' +
                                '					<tns:Attendee_Income_Level>12</tns:Attendee_Income_Level>\n' +
                                '					<tns:Attendee_City>New York</tns:Attendee_City>\n' +
                                '					<tns:Attendee_State>41</tns:Attendee_State>\n' +
                                '					<tns:Attendee_Zip_Code>10005</tns:Attendee_Zip_Code>\n' +
                                '					<tns:Attendee_Rural_Area>3</tns:Attendee_Rural_Area>\n' +
                                '					<tns:Attendee_Limited_English_Proficiency>1</tns:Attendee_Limited_English_Proficiency>\n' +
                                '				</tns:Group_Session_Attendee>\n' +
                                '				<tns:Group_Session_Attendee>\n' +
                                '					<tns:Attendee_Id>7103734810</tns:Attendee_Id>\n' +
                                '					<tns:Attendee_Fee_Amount>0</tns:Attendee_Fee_Amount>\n' +
                                '					<tns:Attendee_Referred_By>9</tns:Attendee_Referred_By>\n' +
                                '					<tns:Attendee_FirstTime_Home_Buyer>N</tns:Attendee_FirstTime_Home_Buyer>\n' +
                                '					<tns:Attendee_Income_Level>12</tns:Attendee_Income_Level>\n' +
                                '					<tns:Attendee_City>New York</tns:Attendee_City>\n' +
                                '					<tns:Attendee_State>41</tns:Attendee_State>\n' +
                                '					<tns:Attendee_Zip_Code>10005</tns:Attendee_Zip_Code>\n' +
                                '					<tns:Attendee_Rural_Area>2</tns:Attendee_Rural_Area>\n' +
                                '					<tns:Attendee_Limited_English_Proficiency>2</tns:Attendee_Limited_English_Proficiency>\n' +
                                '				</tns:Group_Session_Attendee>\n' +
                                '				<tns:Group_Session_Attendee>\n' +
                                '					<tns:Attendee_Id>7103693296</tns:Attendee_Id>\n' +
                                '					<tns:Attendee_Fee_Amount>0</tns:Attendee_Fee_Amount>\n' +
                                '					<tns:Attendee_Referred_By>9</tns:Attendee_Referred_By>\n' +
                                '					<tns:Attendee_FirstTime_Home_Buyer>N</tns:Attendee_FirstTime_Home_Buyer>\n' +
                                '					<tns:Attendee_Income_Level>11</tns:Attendee_Income_Level>\n' +
                                '					<tns:Attendee_City>New York</tns:Attendee_City>\n' +
                                '					<tns:Attendee_State>41</tns:Attendee_State>\n' +
                                '					<tns:Attendee_Zip_Code>10005</tns:Attendee_Zip_Code>\n' +
                                '					<tns:Attendee_Rural_Area>3</tns:Attendee_Rural_Area>\n' +
                                '					<tns:Attendee_Limited_English_Proficiency>1</tns:Attendee_Limited_English_Proficiency>\n' +
                                '				</tns:Group_Session_Attendee>\n' +
                                '				<tns:Group_Session_Attendee>\n' +
                                '					<tns:Attendee_Id>7103706124</tns:Attendee_Id>\n' +
                                '					<tns:Attendee_Fee_Amount>0</tns:Attendee_Fee_Amount>\n' +
                                '					<tns:Attendee_Referred_By>9</tns:Attendee_Referred_By>\n' +
                                '					<tns:Attendee_FirstTime_Home_Buyer>N</tns:Attendee_FirstTime_Home_Buyer>\n' +
                                '					<tns:Attendee_Income_Level>10</tns:Attendee_Income_Level>\n' +
                                '					<tns:Attendee_City>New York</tns:Attendee_City>\n' +
                                '					<tns:Attendee_State>41</tns:Attendee_State>\n' +
                                '					<tns:Attendee_Zip_Code>10005</tns:Attendee_Zip_Code>\n' +
                                '					<tns:Attendee_Rural_Area>2</tns:Attendee_Rural_Area>\n' +
                                '					<tns:Attendee_Limited_English_Proficiency>1</tns:Attendee_Limited_English_Proficiency>\n' +
                                '				</tns:Group_Session_Attendee>\n' +
                                '			</tns:Group_Session_Attendees>\n' +
                                '		</tns:Group_Session >\n' +
                                '		<tns:Group_Session >\n' +
                                '			<tns:Group_Session_Id>7200924762</tns:Group_Session_Id>\n' +
                                '			<tns:Group_Session_Counselor_Id>12373</tns:Group_Session_Counselor_Id>\n' +
                                '			<tns:Group_Session_Counselor_HUD_Id>abhi12</tns:Group_Session_Counselor_HUD_Id>\n' +
                                '			<tns:Group_Session_Title>Home counseling Event</tns:Group_Session_Title>\n' +
                                '			<tns:Group_Session_Date>11-30-2023</tns:Group_Session_Date>\n' +
                                '			<tns:Group_Session_Duration>60</tns:Group_Session_Duration>\n' +
                                '			<tns:Group_Session_Type>23</tns:Group_Session_Type>\n' +
                                '			<tns:Group_Session_Attribute_HUD_Grant>7</tns:Group_Session_Attribute_HUD_Grant>\n' +
                                '			<tns:Group_Session_Activity_Type>17</tns:Group_Session_Activity_Type>\n' +
                                '			<tns:Group_Session_Attendees>\n' +
                                '				<tns:Group_Session_Attendee>\n' +
                                '					<tns:Attendee_Id>7103680799</tns:Attendee_Id>\n' +
                                '					<tns:Attendee_Fee_Amount>0</tns:Attendee_Fee_Amount>\n' +
                                '					<tns:Attendee_Referred_By>9</tns:Attendee_Referred_By>\n' +
                                '					<tns:Attendee_FirstTime_Home_Buyer>N</tns:Attendee_FirstTime_Home_Buyer>\n' +
                                '					<tns:Attendee_Income_Level>8</tns:Attendee_Income_Level>\n' +
                                '					<tns:Attendee_City>New York</tns:Attendee_City>\n' +
                                '					<tns:Attendee_State>41</tns:Attendee_State>\n' +
                                '					<tns:Attendee_Zip_Code>10005</tns:Attendee_Zip_Code>\n' +
                                '					<tns:Attendee_Rural_Area>1</tns:Attendee_Rural_Area>\n' +
                                '					<tns:Attendee_Limited_English_Proficiency>3</tns:Attendee_Limited_English_Proficiency>\n' +
                                '				</tns:Group_Session_Attendee>\n' +
                                '				<tns:Group_Session_Attendee>\n' +
                                '					<tns:Attendee_Id>7103715138</tns:Attendee_Id>\n' +
                                '					<tns:Attendee_Fee_Amount>0</tns:Attendee_Fee_Amount>\n' +
                                '					<tns:Attendee_Referred_By>9</tns:Attendee_Referred_By>\n' +
                                '					<tns:Attendee_FirstTime_Home_Buyer>N</tns:Attendee_FirstTime_Home_Buyer>\n' +
                                '					<tns:Attendee_Income_Level>9</tns:Attendee_Income_Level>\n' +
                                '					<tns:Attendee_City>New York</tns:Attendee_City>\n' +
                                '					<tns:Attendee_State>41</tns:Attendee_State>\n' +
                                '					<tns:Attendee_Zip_Code>10005</tns:Attendee_Zip_Code>\n' +
                                '					<tns:Attendee_Rural_Area>3</tns:Attendee_Rural_Area>\n' +
                                '					<tns:Attendee_Limited_English_Proficiency>3</tns:Attendee_Limited_English_Proficiency>\n' +
                                '				</tns:Group_Session_Attendee>\n' +
                                '				<tns:Group_Session_Attendee>\n' +
                                '					<tns:Attendee_Id>7103685208</tns:Attendee_Id>\n' +
                                '					<tns:Attendee_Fee_Amount>0</tns:Attendee_Fee_Amount>\n' +
                                '					<tns:Attendee_Referred_By>9</tns:Attendee_Referred_By>\n' +
                                '					<tns:Attendee_FirstTime_Home_Buyer>N</tns:Attendee_FirstTime_Home_Buyer>\n' +
                                '					<tns:Attendee_Income_Level>7</tns:Attendee_Income_Level>\n' +
                                '					<tns:Attendee_City>New York</tns:Attendee_City>\n' +
                                '					<tns:Attendee_State>41</tns:Attendee_State>\n' +
                                '					<tns:Attendee_Zip_Code>10005</tns:Attendee_Zip_Code>\n' +
                                '					<tns:Attendee_Rural_Area>1</tns:Attendee_Rural_Area>\n' +
                                '					<tns:Attendee_Limited_English_Proficiency>1</tns:Attendee_Limited_English_Proficiency>\n' +
                                '				</tns:Group_Session_Attendee>\n' +
                                '				<tns:Group_Session_Attendee>\n' +
                                '					<tns:Attendee_Id>7103744239</tns:Attendee_Id>\n' +
                                '					<tns:Attendee_Fee_Amount>0</tns:Attendee_Fee_Amount>\n' +
                                '					<tns:Attendee_Referred_By>9</tns:Attendee_Referred_By>\n' +
                                '					<tns:Attendee_FirstTime_Home_Buyer>N</tns:Attendee_FirstTime_Home_Buyer>\n' +
                                '					<tns:Attendee_Income_Level>12</tns:Attendee_Income_Level>\n' +
                                '					<tns:Attendee_City>New York</tns:Attendee_City>\n' +
                                '					<tns:Attendee_State>41</tns:Attendee_State>\n' +
                                '					<tns:Attendee_Zip_Code>10005</tns:Attendee_Zip_Code>\n' +
                                '					<tns:Attendee_Rural_Area>1</tns:Attendee_Rural_Area>\n' +
                                '					<tns:Attendee_Limited_English_Proficiency>1</tns:Attendee_Limited_English_Proficiency>\n' +
                                '				</tns:Group_Session_Attendee>\n' +
                                '				<tns:Group_Session_Attendee>\n' +
                                '					<tns:Attendee_Id>7103672547</tns:Attendee_Id>\n' +
                                '					<tns:Attendee_Fee_Amount>0</tns:Attendee_Fee_Amount>\n' +
                                '					<tns:Attendee_Referred_By>9</tns:Attendee_Referred_By>\n' +
                                '					<tns:Attendee_FirstTime_Home_Buyer>N</tns:Attendee_FirstTime_Home_Buyer>\n' +
                                '					<tns:Attendee_Income_Level>11</tns:Attendee_Income_Level>\n' +
                                '					<tns:Attendee_City>New York</tns:Attendee_City>\n' +
                                '					<tns:Attendee_State>41</tns:Attendee_State>\n' +
                                '					<tns:Attendee_Zip_Code>10005</tns:Attendee_Zip_Code>\n' +
                                '					<tns:Attendee_Rural_Area>2</tns:Attendee_Rural_Area>\n' +
                                '					<tns:Attendee_Limited_English_Proficiency>2</tns:Attendee_Limited_English_Proficiency>\n' +
                                '				</tns:Group_Session_Attendee>\n' +
                                '				<tns:Group_Session_Attendee>\n' +
                                '					<tns:Attendee_Id>7103680507</tns:Attendee_Id>\n' +
                                '					<tns:Attendee_Fee_Amount>0</tns:Attendee_Fee_Amount>\n' +
                                '					<tns:Attendee_Referred_By>9</tns:Attendee_Referred_By>\n' +
                                '					<tns:Attendee_FirstTime_Home_Buyer>N</tns:Attendee_FirstTime_Home_Buyer>\n' +
                                '					<tns:Attendee_Income_Level>7</tns:Attendee_Income_Level>\n' +
                                '					<tns:Attendee_City>New York</tns:Attendee_City>\n' +
                                '					<tns:Attendee_State>41</tns:Attendee_State>\n' +
                                '					<tns:Attendee_Zip_Code>10005</tns:Attendee_Zip_Code>\n' +
                                '					<tns:Attendee_Rural_Area>2</tns:Attendee_Rural_Area>\n' +
                                '					<tns:Attendee_Limited_English_Proficiency>3</tns:Attendee_Limited_English_Proficiency>\n' +
                                '				</tns:Group_Session_Attendee>\n' +
                                '				<tns:Group_Session_Attendee>\n' +
                                '					<tns:Attendee_Id>7103742902</tns:Attendee_Id>\n' +
                                '					<tns:Attendee_Fee_Amount>0</tns:Attendee_Fee_Amount>\n' +
                                '					<tns:Attendee_Referred_By>9</tns:Attendee_Referred_By>\n' +
                                '					<tns:Attendee_FirstTime_Home_Buyer>N</tns:Attendee_FirstTime_Home_Buyer>\n' +
                                '					<tns:Attendee_Income_Level>8</tns:Attendee_Income_Level>\n' +
                                '					<tns:Attendee_City>New York</tns:Attendee_City>\n' +
                                '					<tns:Attendee_State>41</tns:Attendee_State>\n' +
                                '					<tns:Attendee_Zip_Code>10005</tns:Attendee_Zip_Code>\n' +
                                '					<tns:Attendee_Rural_Area>3</tns:Attendee_Rural_Area>\n' +
                                '					<tns:Attendee_Limited_English_Proficiency>1</tns:Attendee_Limited_English_Proficiency>\n' +
                                '				</tns:Group_Session_Attendee>\n' +
                                '				<tns:Group_Session_Attendee>\n' +
                                '					<tns:Attendee_Id>7103670102</tns:Attendee_Id>\n' +
                                '					<tns:Attendee_Fee_Amount>0</tns:Attendee_Fee_Amount>\n' +
                                '					<tns:Attendee_Referred_By>9</tns:Attendee_Referred_By>\n' +
                                '					<tns:Attendee_FirstTime_Home_Buyer>N</tns:Attendee_FirstTime_Home_Buyer>\n' +
                                '					<tns:Attendee_Income_Level>8</tns:Attendee_Income_Level>\n' +
                                '					<tns:Attendee_City>New York</tns:Attendee_City>\n' +
                                '					<tns:Attendee_State>41</tns:Attendee_State>\n' +
                                '					<tns:Attendee_Zip_Code>10005</tns:Attendee_Zip_Code>\n' +
                                '					<tns:Attendee_Rural_Area>1</tns:Attendee_Rural_Area>\n' +
                                '					<tns:Attendee_Limited_English_Proficiency>2</tns:Attendee_Limited_English_Proficiency>\n' +
                                '				</tns:Group_Session_Attendee>\n' +
                                '				<tns:Group_Session_Attendee>\n' +
                                '					<tns:Attendee_Id>7103669250</tns:Attendee_Id>\n' +
                                '					<tns:Attendee_Fee_Amount>0</tns:Attendee_Fee_Amount>\n' +
                                '					<tns:Attendee_Referred_By>9</tns:Attendee_Referred_By>\n' +
                                '					<tns:Attendee_FirstTime_Home_Buyer>N</tns:Attendee_FirstTime_Home_Buyer>\n' +
                                '					<tns:Attendee_Income_Level>7</tns:Attendee_Income_Level>\n' +
                                '					<tns:Attendee_City>New York</tns:Attendee_City>\n' +
                                '					<tns:Attendee_State>41</tns:Attendee_State>\n' +
                                '					<tns:Attendee_Zip_Code>10005</tns:Attendee_Zip_Code>\n' +
                                '					<tns:Attendee_Rural_Area>1</tns:Attendee_Rural_Area>\n' +
                                '					<tns:Attendee_Limited_English_Proficiency>1</tns:Attendee_Limited_English_Proficiency>\n' +
                                '				</tns:Group_Session_Attendee>\n' +
                                '				<tns:Group_Session_Attendee>\n' +
                                '					<tns:Attendee_Id>7103717720</tns:Attendee_Id>\n' +
                                '					<tns:Attendee_Fee_Amount>0</tns:Attendee_Fee_Amount>\n' +
                                '					<tns:Attendee_Referred_By>9</tns:Attendee_Referred_By>\n' +
                                '					<tns:Attendee_FirstTime_Home_Buyer>N</tns:Attendee_FirstTime_Home_Buyer>\n' +
                                '					<tns:Attendee_Income_Level>10</tns:Attendee_Income_Level>\n' +
                                '					<tns:Attendee_City>New York</tns:Attendee_City>\n' +
                                '					<tns:Attendee_State>41</tns:Attendee_State>\n' +
                                '					<tns:Attendee_Zip_Code>10005</tns:Attendee_Zip_Code>\n' +
                                '					<tns:Attendee_Rural_Area>1</tns:Attendee_Rural_Area>\n' +
                                '					<tns:Attendee_Limited_English_Proficiency>2</tns:Attendee_Limited_English_Proficiency>\n' +
                                '				</tns:Group_Session_Attendee>\n' +
                                '				<tns:Group_Session_Attendee>\n' +
                                '					<tns:Attendee_Id>7103667801</tns:Attendee_Id>\n' +
                                '					<tns:Attendee_Fee_Amount>0</tns:Attendee_Fee_Amount>\n' +
                                '					<tns:Attendee_Referred_By>9</tns:Attendee_Referred_By>\n' +
                                '					<tns:Attendee_FirstTime_Home_Buyer>N</tns:Attendee_FirstTime_Home_Buyer>\n' +
                                '					<tns:Attendee_Income_Level>7</tns:Attendee_Income_Level>\n' +
                                '					<tns:Attendee_City>New York</tns:Attendee_City>\n' +
                                '					<tns:Attendee_State>41</tns:Attendee_State>\n' +
                                '					<tns:Attendee_Zip_Code>10005</tns:Attendee_Zip_Code>\n' +
                                '					<tns:Attendee_Rural_Area>3</tns:Attendee_Rural_Area>\n' +
                                '					<tns:Attendee_Limited_English_Proficiency>1</tns:Attendee_Limited_English_Proficiency>\n' +
                                '				</tns:Group_Session_Attendee>\n' +
                                '				<tns:Group_Session_Attendee>\n' +
                                '					<tns:Attendee_Id>7103673626</tns:Attendee_Id>\n' +
                                '					<tns:Attendee_Fee_Amount>0</tns:Attendee_Fee_Amount>\n' +
                                '					<tns:Attendee_Referred_By>9</tns:Attendee_Referred_By>\n' +
                                '					<tns:Attendee_FirstTime_Home_Buyer>N</tns:Attendee_FirstTime_Home_Buyer>\n' +
                                '					<tns:Attendee_Income_Level>11</tns:Attendee_Income_Level>\n' +
                                '					<tns:Attendee_City>New York</tns:Attendee_City>\n' +
                                '					<tns:Attendee_State>41</tns:Attendee_State>\n' +
                                '					<tns:Attendee_Zip_Code>10005</tns:Attendee_Zip_Code>\n' +
                                '					<tns:Attendee_Rural_Area>1</tns:Attendee_Rural_Area>\n' +
                                '					<tns:Attendee_Limited_English_Proficiency>2</tns:Attendee_Limited_English_Proficiency>\n' +
                                '				</tns:Group_Session_Attendee>\n' +
                                '				<tns:Group_Session_Attendee>\n' +
                                '					<tns:Attendee_Id>7103674485</tns:Attendee_Id>\n' +
                                '					<tns:Attendee_Fee_Amount>0</tns:Attendee_Fee_Amount>\n' +
                                '					<tns:Attendee_Referred_By>9</tns:Attendee_Referred_By>\n' +
                                '					<tns:Attendee_FirstTime_Home_Buyer>N</tns:Attendee_FirstTime_Home_Buyer>\n' +
                                '					<tns:Attendee_Income_Level>12</tns:Attendee_Income_Level>\n' +
                                '					<tns:Attendee_City>New York</tns:Attendee_City>\n' +
                                '					<tns:Attendee_State>41</tns:Attendee_State>\n' +
                                '					<tns:Attendee_Zip_Code>10005</tns:Attendee_Zip_Code>\n' +
                                '					<tns:Attendee_Rural_Area>1</tns:Attendee_Rural_Area>\n' +
                                '					<tns:Attendee_Limited_English_Proficiency>1</tns:Attendee_Limited_English_Proficiency>\n' +
                                '				</tns:Group_Session_Attendee>\n' +
                                '				<tns:Group_Session_Attendee>\n' +
                                '					<tns:Attendee_Id>7103675186</tns:Attendee_Id>\n' +
                                '					<tns:Attendee_Fee_Amount>0</tns:Attendee_Fee_Amount>\n' +
                                '					<tns:Attendee_Referred_By>9</tns:Attendee_Referred_By>\n' +
                                '					<tns:Attendee_FirstTime_Home_Buyer>N</tns:Attendee_FirstTime_Home_Buyer>\n' +
                                '					<tns:Attendee_Income_Level>10</tns:Attendee_Income_Level>\n' +
                                '					<tns:Attendee_City>New York</tns:Attendee_City>\n' +
                                '					<tns:Attendee_State>41</tns:Attendee_State>\n' +
                                '					<tns:Attendee_Zip_Code>10005</tns:Attendee_Zip_Code>\n' +
                                '					<tns:Attendee_Rural_Area>1</tns:Attendee_Rural_Area>\n' +
                                '					<tns:Attendee_Limited_English_Proficiency>3</tns:Attendee_Limited_English_Proficiency>\n' +
                                '				</tns:Group_Session_Attendee>\n' +
                                '				<tns:Group_Session_Attendee>\n' +
                                '					<tns:Attendee_Id>7103744049</tns:Attendee_Id>\n' +
                                '					<tns:Attendee_Fee_Amount>0</tns:Attendee_Fee_Amount>\n' +
                                '					<tns:Attendee_Referred_By>9</tns:Attendee_Referred_By>\n' +
                                '					<tns:Attendee_FirstTime_Home_Buyer>N</tns:Attendee_FirstTime_Home_Buyer>\n' +
                                '					<tns:Attendee_Income_Level>12</tns:Attendee_Income_Level>\n' +
                                '					<tns:Attendee_City>New York</tns:Attendee_City>\n' +
                                '					<tns:Attendee_State>41</tns:Attendee_State>\n' +
                                '					<tns:Attendee_Zip_Code>10005</tns:Attendee_Zip_Code>\n' +
                                '					<tns:Attendee_Rural_Area>3</tns:Attendee_Rural_Area>\n' +
                                '					<tns:Attendee_Limited_English_Proficiency>3</tns:Attendee_Limited_English_Proficiency>\n' +
                                '				</tns:Group_Session_Attendee>\n' +
                                '				<tns:Group_Session_Attendee>\n' +
                                '					<tns:Attendee_Id>7103703508</tns:Attendee_Id>\n' +
                                '					<tns:Attendee_Fee_Amount>0</tns:Attendee_Fee_Amount>\n' +
                                '					<tns:Attendee_Referred_By>9</tns:Attendee_Referred_By>\n' +
                                '					<tns:Attendee_FirstTime_Home_Buyer>N</tns:Attendee_FirstTime_Home_Buyer>\n' +
                                '					<tns:Attendee_Income_Level>12</tns:Attendee_Income_Level>\n' +
                                '					<tns:Attendee_City>New York</tns:Attendee_City>\n' +
                                '					<tns:Attendee_State>41</tns:Attendee_State>\n' +
                                '					<tns:Attendee_Zip_Code>10005</tns:Attendee_Zip_Code>\n' +
                                '					<tns:Attendee_Rural_Area>2</tns:Attendee_Rural_Area>\n' +
                                '					<tns:Attendee_Limited_English_Proficiency>1</tns:Attendee_Limited_English_Proficiency>\n' +
                                '				</tns:Group_Session_Attendee>\n' +
                                '				<tns:Group_Session_Attendee>\n' +
                                '					<tns:Attendee_Id>7103726216</tns:Attendee_Id>\n' +
                                '					<tns:Attendee_Fee_Amount>0</tns:Attendee_Fee_Amount>\n' +
                                '					<tns:Attendee_Referred_By>9</tns:Attendee_Referred_By>\n' +
                                '					<tns:Attendee_FirstTime_Home_Buyer>N</tns:Attendee_FirstTime_Home_Buyer>\n' +
                                '					<tns:Attendee_Income_Level>8</tns:Attendee_Income_Level>\n' +
                                '					<tns:Attendee_City>New York</tns:Attendee_City>\n' +
                                '					<tns:Attendee_State>41</tns:Attendee_State>\n' +
                                '					<tns:Attendee_Zip_Code>10005</tns:Attendee_Zip_Code>\n' +
                                '					<tns:Attendee_Rural_Area>2</tns:Attendee_Rural_Area>\n' +
                                '					<tns:Attendee_Limited_English_Proficiency>3</tns:Attendee_Limited_English_Proficiency>\n' +
                                '				</tns:Group_Session_Attendee>\n' +
                                '				<tns:Group_Session_Attendee>\n' +
                                '					<tns:Attendee_Id>7103679732</tns:Attendee_Id>\n' +
                                '					<tns:Attendee_Fee_Amount>0</tns:Attendee_Fee_Amount>\n' +
                                '					<tns:Attendee_Referred_By>9</tns:Attendee_Referred_By>\n' +
                                '					<tns:Attendee_FirstTime_Home_Buyer>N</tns:Attendee_FirstTime_Home_Buyer>\n' +
                                '					<tns:Attendee_Income_Level>9</tns:Attendee_Income_Level>\n' +
                                '					<tns:Attendee_City>New York</tns:Attendee_City>\n' +
                                '					<tns:Attendee_State>41</tns:Attendee_State>\n' +
                                '					<tns:Attendee_Zip_Code>10005</tns:Attendee_Zip_Code>\n' +
                                '					<tns:Attendee_Rural_Area>1</tns:Attendee_Rural_Area>\n' +
                                '					<tns:Attendee_Limited_English_Proficiency>1</tns:Attendee_Limited_English_Proficiency>\n' +
                                '				</tns:Group_Session_Attendee>\n' +
                                '				<tns:Group_Session_Attendee>\n' +
                                '					<tns:Attendee_Id>7103722000</tns:Attendee_Id>\n' +
                                '					<tns:Attendee_Fee_Amount>0</tns:Attendee_Fee_Amount>\n' +
                                '					<tns:Attendee_Referred_By>9</tns:Attendee_Referred_By>\n' +
                                '					<tns:Attendee_FirstTime_Home_Buyer>N</tns:Attendee_FirstTime_Home_Buyer>\n' +
                                '					<tns:Attendee_Income_Level>11</tns:Attendee_Income_Level>\n' +
                                '					<tns:Attendee_City>New York</tns:Attendee_City>\n' +
                                '					<tns:Attendee_State>41</tns:Attendee_State>\n' +
                                '					<tns:Attendee_Zip_Code>10005</tns:Attendee_Zip_Code>\n' +
                                '					<tns:Attendee_Rural_Area>2</tns:Attendee_Rural_Area>\n' +
                                '					<tns:Attendee_Limited_English_Proficiency>3</tns:Attendee_Limited_English_Proficiency>\n' +
                                '				</tns:Group_Session_Attendee>\n' +
                                '				<tns:Group_Session_Attendee>\n' +
                                '					<tns:Attendee_Id>7103757061</tns:Attendee_Id>\n' +
                                '					<tns:Attendee_Fee_Amount>0</tns:Attendee_Fee_Amount>\n' +
                                '					<tns:Attendee_Referred_By>9</tns:Attendee_Referred_By>\n' +
                                '					<tns:Attendee_FirstTime_Home_Buyer>N</tns:Attendee_FirstTime_Home_Buyer>\n' +
                                '					<tns:Attendee_Income_Level>10</tns:Attendee_Income_Level>\n' +
                                '					<tns:Attendee_City>New York</tns:Attendee_City>\n' +
                                '					<tns:Attendee_State>41</tns:Attendee_State>\n' +
                                '					<tns:Attendee_Zip_Code>10005</tns:Attendee_Zip_Code>\n' +
                                '					<tns:Attendee_Rural_Area>2</tns:Attendee_Rural_Area>\n' +
                                '					<tns:Attendee_Limited_English_Proficiency>2</tns:Attendee_Limited_English_Proficiency>\n' +
                                '				</tns:Group_Session_Attendee>\n' +
                                '				<tns:Group_Session_Attendee>\n' +
                                '					<tns:Attendee_Id>7103663747</tns:Attendee_Id>\n' +
                                '					<tns:Attendee_Fee_Amount>0</tns:Attendee_Fee_Amount>\n' +
                                '					<tns:Attendee_Referred_By>9</tns:Attendee_Referred_By>\n' +
                                '					<tns:Attendee_FirstTime_Home_Buyer>N</tns:Attendee_FirstTime_Home_Buyer>\n' +
                                '					<tns:Attendee_Income_Level>11</tns:Attendee_Income_Level>\n' +
                                '					<tns:Attendee_City>New York</tns:Attendee_City>\n' +
                                '					<tns:Attendee_State>41</tns:Attendee_State>\n' +
                                '					<tns:Attendee_Zip_Code>10005</tns:Attendee_Zip_Code>\n' +
                                '					<tns:Attendee_Rural_Area>2</tns:Attendee_Rural_Area>\n' +
                                '					<tns:Attendee_Limited_English_Proficiency>1</tns:Attendee_Limited_English_Proficiency>\n' +
                                '				</tns:Group_Session_Attendee>\n' +
                                '				<tns:Group_Session_Attendee>\n' +
                                '					<tns:Attendee_Id>7103692237</tns:Attendee_Id>\n' +
                                '					<tns:Attendee_Fee_Amount>0</tns:Attendee_Fee_Amount>\n' +
                                '					<tns:Attendee_Referred_By>9</tns:Attendee_Referred_By>\n' +
                                '					<tns:Attendee_FirstTime_Home_Buyer>N</tns:Attendee_FirstTime_Home_Buyer>\n' +
                                '					<tns:Attendee_Income_Level>12</tns:Attendee_Income_Level>\n' +
                                '					<tns:Attendee_City>New York</tns:Attendee_City>\n' +
                                '					<tns:Attendee_State>41</tns:Attendee_State>\n' +
                                '					<tns:Attendee_Zip_Code>10005</tns:Attendee_Zip_Code>\n' +
                                '					<tns:Attendee_Rural_Area>2</tns:Attendee_Rural_Area>\n' +
                                '					<tns:Attendee_Limited_English_Proficiency>3</tns:Attendee_Limited_English_Proficiency>\n' +
                                '				</tns:Group_Session_Attendee>\n' +
                                '				<tns:Group_Session_Attendee>\n' +
                                '					<tns:Attendee_Id>7103688244</tns:Attendee_Id>\n' +
                                '					<tns:Attendee_Fee_Amount>0</tns:Attendee_Fee_Amount>\n' +
                                '					<tns:Attendee_Referred_By>9</tns:Attendee_Referred_By>\n' +
                                '					<tns:Attendee_FirstTime_Home_Buyer>N</tns:Attendee_FirstTime_Home_Buyer>\n' +
                                '					<tns:Attendee_Income_Level>12</tns:Attendee_Income_Level>\n' +
                                '					<tns:Attendee_City>New York</tns:Attendee_City>\n' +
                                '					<tns:Attendee_State>41</tns:Attendee_State>\n' +
                                '					<tns:Attendee_Zip_Code>10005</tns:Attendee_Zip_Code>\n' +
                                '					<tns:Attendee_Rural_Area>1</tns:Attendee_Rural_Area>\n' +
                                '					<tns:Attendee_Limited_English_Proficiency>2</tns:Attendee_Limited_English_Proficiency>\n' +
                                '				</tns:Group_Session_Attendee>\n' +
                                '				<tns:Group_Session_Attendee>\n' +
                                '					<tns:Attendee_Id>7103714720</tns:Attendee_Id>\n' +
                                '					<tns:Attendee_Fee_Amount>0</tns:Attendee_Fee_Amount>\n' +
                                '					<tns:Attendee_Referred_By>9</tns:Attendee_Referred_By>\n' +
                                '					<tns:Attendee_FirstTime_Home_Buyer>N</tns:Attendee_FirstTime_Home_Buyer>\n' +
                                '					<tns:Attendee_Income_Level>11</tns:Attendee_Income_Level>\n' +
                                '					<tns:Attendee_City>New York</tns:Attendee_City>\n' +
                                '					<tns:Attendee_State>41</tns:Attendee_State>\n' +
                                '					<tns:Attendee_Zip_Code>10005</tns:Attendee_Zip_Code>\n' +
                                '					<tns:Attendee_Rural_Area>1</tns:Attendee_Rural_Area>\n' +
                                '					<tns:Attendee_Limited_English_Proficiency>3</tns:Attendee_Limited_English_Proficiency>\n' +
                                '				</tns:Group_Session_Attendee>\n' +
                                '				<tns:Group_Session_Attendee>\n' +
                                '					<tns:Attendee_Id>7103723326</tns:Attendee_Id>\n' +
                                '					<tns:Attendee_Fee_Amount>0</tns:Attendee_Fee_Amount>\n' +
                                '					<tns:Attendee_Referred_By>9</tns:Attendee_Referred_By>\n' +
                                '					<tns:Attendee_FirstTime_Home_Buyer>N</tns:Attendee_FirstTime_Home_Buyer>\n' +
                                '					<tns:Attendee_Income_Level>7</tns:Attendee_Income_Level>\n' +
                                '					<tns:Attendee_City>New York</tns:Attendee_City>\n' +
                                '					<tns:Attendee_State>41</tns:Attendee_State>\n' +
                                '					<tns:Attendee_Zip_Code>10005</tns:Attendee_Zip_Code>\n' +
                                '					<tns:Attendee_Rural_Area>2</tns:Attendee_Rural_Area>\n' +
                                '					<tns:Attendee_Limited_English_Proficiency>1</tns:Attendee_Limited_English_Proficiency>\n' +
                                '				</tns:Group_Session_Attendee>\n' +
                                '				<tns:Group_Session_Attendee>\n' +
                                '					<tns:Attendee_Id>7103742190</tns:Attendee_Id>\n' +
                                '					<tns:Attendee_Fee_Amount>0</tns:Attendee_Fee_Amount>\n' +
                                '					<tns:Attendee_Referred_By>9</tns:Attendee_Referred_By>\n' +
                                '					<tns:Attendee_FirstTime_Home_Buyer>N</tns:Attendee_FirstTime_Home_Buyer>\n' +
                                '					<tns:Attendee_Income_Level>9</tns:Attendee_Income_Level>\n' +
                                '					<tns:Attendee_City>New York</tns:Attendee_City>\n' +
                                '					<tns:Attendee_State>41</tns:Attendee_State>\n' +
                                '					<tns:Attendee_Zip_Code>10005</tns:Attendee_Zip_Code>\n' +
                                '					<tns:Attendee_Rural_Area>2</tns:Attendee_Rural_Area>\n' +
                                '					<tns:Attendee_Limited_English_Proficiency>1</tns:Attendee_Limited_English_Proficiency>\n' +
                                '				</tns:Group_Session_Attendee>\n' +
                                '				<tns:Group_Session_Attendee>\n' +
                                '					<tns:Attendee_Id>7103721871</tns:Attendee_Id>\n' +
                                '					<tns:Attendee_Fee_Amount>0</tns:Attendee_Fee_Amount>\n' +
                                '					<tns:Attendee_Referred_By>9</tns:Attendee_Referred_By>\n' +
                                '					<tns:Attendee_FirstTime_Home_Buyer>N</tns:Attendee_FirstTime_Home_Buyer>\n' +
                                '					<tns:Attendee_Income_Level>8</tns:Attendee_Income_Level>\n' +
                                '					<tns:Attendee_City>New York</tns:Attendee_City>\n' +
                                '					<tns:Attendee_State>41</tns:Attendee_State>\n' +
                                '					<tns:Attendee_Zip_Code>10005</tns:Attendee_Zip_Code>\n' +
                                '					<tns:Attendee_Rural_Area>3</tns:Attendee_Rural_Area>\n' +
                                '					<tns:Attendee_Limited_English_Proficiency>3</tns:Attendee_Limited_English_Proficiency>\n' +
                                '				</tns:Group_Session_Attendee>\n' +
                                '				<tns:Group_Session_Attendee>\n' +
                                '					<tns:Attendee_Id>7103684645</tns:Attendee_Id>\n' +
                                '					<tns:Attendee_Fee_Amount>0</tns:Attendee_Fee_Amount>\n' +
                                '					<tns:Attendee_Referred_By>9</tns:Attendee_Referred_By>\n' +
                                '					<tns:Attendee_FirstTime_Home_Buyer>N</tns:Attendee_FirstTime_Home_Buyer>\n' +
                                '					<tns:Attendee_Income_Level>10</tns:Attendee_Income_Level>\n' +
                                '					<tns:Attendee_City>New York</tns:Attendee_City>\n' +
                                '					<tns:Attendee_State>41</tns:Attendee_State>\n' +
                                '					<tns:Attendee_Zip_Code>10005</tns:Attendee_Zip_Code>\n' +
                                '					<tns:Attendee_Rural_Area>1</tns:Attendee_Rural_Area>\n' +
                                '					<tns:Attendee_Limited_English_Proficiency>3</tns:Attendee_Limited_English_Proficiency>\n' +
                                '				</tns:Group_Session_Attendee>\n' +
                                '				<tns:Group_Session_Attendee>\n' +
                                '					<tns:Attendee_Id>7103700162</tns:Attendee_Id>\n' +
                                '					<tns:Attendee_Fee_Amount>0</tns:Attendee_Fee_Amount>\n' +
                                '					<tns:Attendee_Referred_By>9</tns:Attendee_Referred_By>\n' +
                                '					<tns:Attendee_FirstTime_Home_Buyer>N</tns:Attendee_FirstTime_Home_Buyer>\n' +
                                '					<tns:Attendee_Income_Level>9</tns:Attendee_Income_Level>\n' +
                                '					<tns:Attendee_City>New York</tns:Attendee_City>\n' +
                                '					<tns:Attendee_State>41</tns:Attendee_State>\n' +
                                '					<tns:Attendee_Zip_Code>10005</tns:Attendee_Zip_Code>\n' +
                                '					<tns:Attendee_Rural_Area>3</tns:Attendee_Rural_Area>\n' +
                                '					<tns:Attendee_Limited_English_Proficiency>1</tns:Attendee_Limited_English_Proficiency>\n' +
                                '				</tns:Group_Session_Attendee>\n' +
                                '				<tns:Group_Session_Attendee>\n' +
                                '					<tns:Attendee_Id>7103679692</tns:Attendee_Id>\n' +
                                '					<tns:Attendee_Fee_Amount>0</tns:Attendee_Fee_Amount>\n' +
                                '					<tns:Attendee_Referred_By>9</tns:Attendee_Referred_By>\n' +
                                '					<tns:Attendee_FirstTime_Home_Buyer>N</tns:Attendee_FirstTime_Home_Buyer>\n' +
                                '					<tns:Attendee_Income_Level>8</tns:Attendee_Income_Level>\n' +
                                '					<tns:Attendee_City>New York</tns:Attendee_City>\n' +
                                '					<tns:Attendee_State>41</tns:Attendee_State>\n' +
                                '					<tns:Attendee_Zip_Code>10005</tns:Attendee_Zip_Code>\n' +
                                '					<tns:Attendee_Rural_Area>2</tns:Attendee_Rural_Area>\n' +
                                '					<tns:Attendee_Limited_English_Proficiency>1</tns:Attendee_Limited_English_Proficiency>\n' +
                                '				</tns:Group_Session_Attendee>\n' +
                                '				<tns:Group_Session_Attendee>\n' +
                                '					<tns:Attendee_Id>7103743937</tns:Attendee_Id>\n' +
                                '					<tns:Attendee_Fee_Amount>0</tns:Attendee_Fee_Amount>\n' +
                                '					<tns:Attendee_Referred_By>9</tns:Attendee_Referred_By>\n' +
                                '					<tns:Attendee_FirstTime_Home_Buyer>N</tns:Attendee_FirstTime_Home_Buyer>\n' +
                                '					<tns:Attendee_Income_Level>8</tns:Attendee_Income_Level>\n' +
                                '					<tns:Attendee_City>New York</tns:Attendee_City>\n' +
                                '					<tns:Attendee_State>41</tns:Attendee_State>\n' +
                                '					<tns:Attendee_Zip_Code>10005</tns:Attendee_Zip_Code>\n' +
                                '					<tns:Attendee_Rural_Area>1</tns:Attendee_Rural_Area>\n' +
                                '					<tns:Attendee_Limited_English_Proficiency>1</tns:Attendee_Limited_English_Proficiency>\n' +
                                '				</tns:Group_Session_Attendee>\n' +
                                '				<tns:Group_Session_Attendee>\n' +
                                '					<tns:Attendee_Id>7103688117</tns:Attendee_Id>\n' +
                                '					<tns:Attendee_Fee_Amount>0</tns:Attendee_Fee_Amount>\n' +
                                '					<tns:Attendee_Referred_By>9</tns:Attendee_Referred_By>\n' +
                                '					<tns:Attendee_FirstTime_Home_Buyer>N</tns:Attendee_FirstTime_Home_Buyer>\n' +
                                '					<tns:Attendee_Income_Level>12</tns:Attendee_Income_Level>\n' +
                                '					<tns:Attendee_City>New York</tns:Attendee_City>\n' +
                                '					<tns:Attendee_State>41</tns:Attendee_State>\n' +
                                '					<tns:Attendee_Zip_Code>10005</tns:Attendee_Zip_Code>\n' +
                                '					<tns:Attendee_Rural_Area>2</tns:Attendee_Rural_Area>\n' +
                                '					<tns:Attendee_Limited_English_Proficiency>2</tns:Attendee_Limited_English_Proficiency>\n' +
                                '				</tns:Group_Session_Attendee>\n' +
                                '				<tns:Group_Session_Attendee>\n' +
                                '					<tns:Attendee_Id>7103733863</tns:Attendee_Id>\n' +
                                '					<tns:Attendee_Fee_Amount>0</tns:Attendee_Fee_Amount>\n' +
                                '					<tns:Attendee_Referred_By>9</tns:Attendee_Referred_By>\n' +
                                '					<tns:Attendee_FirstTime_Home_Buyer>N</tns:Attendee_FirstTime_Home_Buyer>\n' +
                                '					<tns:Attendee_Income_Level>11</tns:Attendee_Income_Level>\n' +
                                '					<tns:Attendee_City>New York</tns:Attendee_City>\n' +
                                '					<tns:Attendee_State>41</tns:Attendee_State>\n' +
                                '					<tns:Attendee_Zip_Code>10005</tns:Attendee_Zip_Code>\n' +
                                '					<tns:Attendee_Rural_Area>3</tns:Attendee_Rural_Area>\n' +
                                '					<tns:Attendee_Limited_English_Proficiency>3</tns:Attendee_Limited_English_Proficiency>\n' +
                                '				</tns:Group_Session_Attendee>\n' +
                                '				<tns:Group_Session_Attendee>\n' +
                                '					<tns:Attendee_Id>7103749403</tns:Attendee_Id>\n' +
                                '					<tns:Attendee_Fee_Amount>0</tns:Attendee_Fee_Amount>\n' +
                                '					<tns:Attendee_Referred_By>9</tns:Attendee_Referred_By>\n' +
                                '					<tns:Attendee_FirstTime_Home_Buyer>N</tns:Attendee_FirstTime_Home_Buyer>\n' +
                                '					<tns:Attendee_Income_Level>11</tns:Attendee_Income_Level>\n' +
                                '					<tns:Attendee_City>New York</tns:Attendee_City>\n' +
                                '					<tns:Attendee_State>41</tns:Attendee_State>\n' +
                                '					<tns:Attendee_Zip_Code>10005</tns:Attendee_Zip_Code>\n' +
                                '					<tns:Attendee_Rural_Area>2</tns:Attendee_Rural_Area>\n' +
                                '					<tns:Attendee_Limited_English_Proficiency>3</tns:Attendee_Limited_English_Proficiency>\n' +
                                '				</tns:Group_Session_Attendee>\n' +
                                '				<tns:Group_Session_Attendee>\n' +
                                '					<tns:Attendee_Id>7103719673</tns:Attendee_Id>\n' +
                                '					<tns:Attendee_Fee_Amount>0</tns:Attendee_Fee_Amount>\n' +
                                '					<tns:Attendee_Referred_By>9</tns:Attendee_Referred_By>\n' +
                                '					<tns:Attendee_FirstTime_Home_Buyer>N</tns:Attendee_FirstTime_Home_Buyer>\n' +
                                '					<tns:Attendee_Income_Level>11</tns:Attendee_Income_Level>\n' +
                                '					<tns:Attendee_City>New York</tns:Attendee_City>\n' +
                                '					<tns:Attendee_State>41</tns:Attendee_State>\n' +
                                '					<tns:Attendee_Zip_Code>10005</tns:Attendee_Zip_Code>\n' +
                                '					<tns:Attendee_Rural_Area>3</tns:Attendee_Rural_Area>\n' +
                                '					<tns:Attendee_Limited_English_Proficiency>3</tns:Attendee_Limited_English_Proficiency>\n' +
                                '				</tns:Group_Session_Attendee>\n' +
                                '				<tns:Group_Session_Attendee>\n' +
                                '					<tns:Attendee_Id>7103683774</tns:Attendee_Id>\n' +
                                '					<tns:Attendee_Fee_Amount>0</tns:Attendee_Fee_Amount>\n' +
                                '					<tns:Attendee_Referred_By>9</tns:Attendee_Referred_By>\n' +
                                '					<tns:Attendee_FirstTime_Home_Buyer>N</tns:Attendee_FirstTime_Home_Buyer>\n' +
                                '					<tns:Attendee_Income_Level>11</tns:Attendee_Income_Level>\n' +
                                '					<tns:Attendee_City>New York</tns:Attendee_City>\n' +
                                '					<tns:Attendee_State>41</tns:Attendee_State>\n' +
                                '					<tns:Attendee_Zip_Code>10005</tns:Attendee_Zip_Code>\n' +
                                '					<tns:Attendee_Rural_Area>1</tns:Attendee_Rural_Area>\n' +
                                '					<tns:Attendee_Limited_English_Proficiency>3</tns:Attendee_Limited_English_Proficiency>\n' +
                                '				</tns:Group_Session_Attendee>\n' +
                                '				<tns:Group_Session_Attendee>\n' +
                                '					<tns:Attendee_Id>7103659598</tns:Attendee_Id>\n' +
                                '					<tns:Attendee_Fee_Amount>0</tns:Attendee_Fee_Amount>\n' +
                                '					<tns:Attendee_Referred_By>9</tns:Attendee_Referred_By>\n' +
                                '					<tns:Attendee_FirstTime_Home_Buyer>N</tns:Attendee_FirstTime_Home_Buyer>\n' +
                                '					<tns:Attendee_Income_Level>7</tns:Attendee_Income_Level>\n' +
                                '					<tns:Attendee_City>New York</tns:Attendee_City>\n' +
                                '					<tns:Attendee_State>41</tns:Attendee_State>\n' +
                                '					<tns:Attendee_Zip_Code>10005</tns:Attendee_Zip_Code>\n' +
                                '					<tns:Attendee_Rural_Area>1</tns:Attendee_Rural_Area>\n' +
                                '					<tns:Attendee_Limited_English_Proficiency>1</tns:Attendee_Limited_English_Proficiency>\n' +
                                '				</tns:Group_Session_Attendee>\n' +
                                '				<tns:Group_Session_Attendee>\n' +
                                '					<tns:Attendee_Id>7103664153</tns:Attendee_Id>\n' +
                                '					<tns:Attendee_Fee_Amount>0</tns:Attendee_Fee_Amount>\n' +
                                '					<tns:Attendee_Referred_By>9</tns:Attendee_Referred_By>\n' +
                                '					<tns:Attendee_FirstTime_Home_Buyer>N</tns:Attendee_FirstTime_Home_Buyer>\n' +
                                '					<tns:Attendee_Income_Level>9</tns:Attendee_Income_Level>\n' +
                                '					<tns:Attendee_City>New York</tns:Attendee_City>\n' +
                                '					<tns:Attendee_State>41</tns:Attendee_State>\n' +
                                '					<tns:Attendee_Zip_Code>10005</tns:Attendee_Zip_Code>\n' +
                                '					<tns:Attendee_Rural_Area>2</tns:Attendee_Rural_Area>\n' +
                                '					<tns:Attendee_Limited_English_Proficiency>2</tns:Attendee_Limited_English_Proficiency>\n' +
                                '				</tns:Group_Session_Attendee>\n' +
                                '				<tns:Group_Session_Attendee>\n' +
                                '					<tns:Attendee_Id>7103737521</tns:Attendee_Id>\n' +
                                '					<tns:Attendee_Fee_Amount>0</tns:Attendee_Fee_Amount>\n' +
                                '					<tns:Attendee_Referred_By>9</tns:Attendee_Referred_By>\n' +
                                '					<tns:Attendee_FirstTime_Home_Buyer>N</tns:Attendee_FirstTime_Home_Buyer>\n' +
                                '					<tns:Attendee_Income_Level>9</tns:Attendee_Income_Level>\n' +
                                '					<tns:Attendee_City>New York</tns:Attendee_City>\n' +
                                '					<tns:Attendee_State>41</tns:Attendee_State>\n' +
                                '					<tns:Attendee_Zip_Code>10005</tns:Attendee_Zip_Code>\n' +
                                '					<tns:Attendee_Rural_Area>1</tns:Attendee_Rural_Area>\n' +
                                '					<tns:Attendee_Limited_English_Proficiency>2</tns:Attendee_Limited_English_Proficiency>\n' +
                                '				</tns:Group_Session_Attendee>\n' +
                                '				<tns:Group_Session_Attendee>\n' +
                                '					<tns:Attendee_Id>7103757628</tns:Attendee_Id>\n' +
                                '					<tns:Attendee_Fee_Amount>0</tns:Attendee_Fee_Amount>\n' +
                                '					<tns:Attendee_Referred_By>9</tns:Attendee_Referred_By>\n' +
                                '					<tns:Attendee_FirstTime_Home_Buyer>N</tns:Attendee_FirstTime_Home_Buyer>\n' +
                                '					<tns:Attendee_Income_Level>9</tns:Attendee_Income_Level>\n' +
                                '					<tns:Attendee_City>New York</tns:Attendee_City>\n' +
                                '					<tns:Attendee_State>41</tns:Attendee_State>\n' +
                                '					<tns:Attendee_Zip_Code>10005</tns:Attendee_Zip_Code>\n' +
                                '					<tns:Attendee_Rural_Area>2</tns:Attendee_Rural_Area>\n' +
                                '					<tns:Attendee_Limited_English_Proficiency>2</tns:Attendee_Limited_English_Proficiency>\n' +
                                '				</tns:Group_Session_Attendee>\n' +
                                '			</tns:Group_Session_Attendees>\n' +
                                '		</tns:Group_Session >\n' +
                                '		<tns:Group_Session >\n' +
                                '			<tns:Group_Session_Id>7200906967</tns:Group_Session_Id>\n' +
                                '			<tns:Group_Session_Counselor_Id>12373</tns:Group_Session_Counselor_Id>\n' +
                                '			<tns:Group_Session_Counselor_HUD_Id>abhi12</tns:Group_Session_Counselor_HUD_Id>\n' +
                                '			<tns:Group_Session_Title>Client counseling</tns:Group_Session_Title>\n' +
                                '			<tns:Group_Session_Date>11-30-2023</tns:Group_Session_Date>\n' +
                                '			<tns:Group_Session_Duration>60</tns:Group_Session_Duration>\n' +
                                '			<tns:Group_Session_Type>23</tns:Group_Session_Type>\n' +
                                '			<tns:Group_Session_Attribute_HUD_Grant>7</tns:Group_Session_Attribute_HUD_Grant>\n' +
                                '			<tns:Group_Session_Activity_Type>17</tns:Group_Session_Activity_Type>\n' +
                                '			<tns:Group_Session_Attendees>\n' +
                                '				<tns:Group_Session_Attendee>\n' +
                                '					<tns:Attendee_Id>7103719829</tns:Attendee_Id>\n' +
                                '					<tns:Attendee_Fee_Amount>0</tns:Attendee_Fee_Amount>\n' +
                                '					<tns:Attendee_Referred_By>9</tns:Attendee_Referred_By>\n' +
                                '					<tns:Attendee_FirstTime_Home_Buyer>N</tns:Attendee_FirstTime_Home_Buyer>\n' +
                                '					<tns:Attendee_Income_Level>8</tns:Attendee_Income_Level>\n' +
                                '					<tns:Attendee_City>New York</tns:Attendee_City>\n' +
                                '					<tns:Attendee_State>41</tns:Attendee_State>\n' +
                                '					<tns:Attendee_Zip_Code>10005</tns:Attendee_Zip_Code>\n' +
                                '					<tns:Attendee_Rural_Area>2</tns:Attendee_Rural_Area>\n' +
                                '					<tns:Attendee_Limited_English_Proficiency>3</tns:Attendee_Limited_English_Proficiency>\n' +
                                '				</tns:Group_Session_Attendee>\n' +
                                '				<tns:Group_Session_Attendee>\n' +
                                '					<tns:Attendee_Id>7103673633</tns:Attendee_Id>\n' +
                                '					<tns:Attendee_Fee_Amount>0</tns:Attendee_Fee_Amount>\n' +
                                '					<tns:Attendee_Referred_By>9</tns:Attendee_Referred_By>\n' +
                                '					<tns:Attendee_FirstTime_Home_Buyer>N</tns:Attendee_FirstTime_Home_Buyer>\n' +
                                '					<tns:Attendee_Income_Level>11</tns:Attendee_Income_Level>\n' +
                                '					<tns:Attendee_City>New York</tns:Attendee_City>\n' +
                                '					<tns:Attendee_State>41</tns:Attendee_State>\n' +
                                '					<tns:Attendee_Zip_Code>10005</tns:Attendee_Zip_Code>\n' +
                                '					<tns:Attendee_Rural_Area>1</tns:Attendee_Rural_Area>\n' +
                                '					<tns:Attendee_Limited_English_Proficiency>2</tns:Attendee_Limited_English_Proficiency>\n' +
                                '				</tns:Group_Session_Attendee>\n' +
                                '				<tns:Group_Session_Attendee>\n' +
                                '					<tns:Attendee_Id>7103700973</tns:Attendee_Id>\n' +
                                '					<tns:Attendee_Fee_Amount>0</tns:Attendee_Fee_Amount>\n' +
                                '					<tns:Attendee_Referred_By>9</tns:Attendee_Referred_By>\n' +
                                '					<tns:Attendee_FirstTime_Home_Buyer>N</tns:Attendee_FirstTime_Home_Buyer>\n' +
                                '					<tns:Attendee_Income_Level>9</tns:Attendee_Income_Level>\n' +
                                '					<tns:Attendee_City>New York</tns:Attendee_City>\n' +
                                '					<tns:Attendee_State>41</tns:Attendee_State>\n' +
                                '					<tns:Attendee_Zip_Code>10005</tns:Attendee_Zip_Code>\n' +
                                '					<tns:Attendee_Rural_Area>3</tns:Attendee_Rural_Area>\n' +
                                '					<tns:Attendee_Limited_English_Proficiency>1</tns:Attendee_Limited_English_Proficiency>\n' +
                                '				</tns:Group_Session_Attendee>\n' +
                                '				<tns:Group_Session_Attendee>\n' +
                                '					<tns:Attendee_Id>7103733762</tns:Attendee_Id>\n' +
                                '					<tns:Attendee_Fee_Amount>0</tns:Attendee_Fee_Amount>\n' +
                                '					<tns:Attendee_Referred_By>9</tns:Attendee_Referred_By>\n' +
                                '					<tns:Attendee_FirstTime_Home_Buyer>N</tns:Attendee_FirstTime_Home_Buyer>\n' +
                                '					<tns:Attendee_Income_Level>11</tns:Attendee_Income_Level>\n' +
                                '					<tns:Attendee_City>New York</tns:Attendee_City>\n' +
                                '					<tns:Attendee_State>41</tns:Attendee_State>\n' +
                                '					<tns:Attendee_Zip_Code>10005</tns:Attendee_Zip_Code>\n' +
                                '					<tns:Attendee_Rural_Area>3</tns:Attendee_Rural_Area>\n' +
                                '					<tns:Attendee_Limited_English_Proficiency>1</tns:Attendee_Limited_English_Proficiency>\n' +
                                '				</tns:Group_Session_Attendee>\n' +
                                '				<tns:Group_Session_Attendee>\n' +
                                '					<tns:Attendee_Id>7103736860</tns:Attendee_Id>\n' +
                                '					<tns:Attendee_Fee_Amount>0</tns:Attendee_Fee_Amount>\n' +
                                '					<tns:Attendee_Referred_By>9</tns:Attendee_Referred_By>\n' +
                                '					<tns:Attendee_FirstTime_Home_Buyer>N</tns:Attendee_FirstTime_Home_Buyer>\n' +
                                '					<tns:Attendee_Income_Level>11</tns:Attendee_Income_Level>\n' +
                                '					<tns:Attendee_City>New York</tns:Attendee_City>\n' +
                                '					<tns:Attendee_State>41</tns:Attendee_State>\n' +
                                '					<tns:Attendee_Zip_Code>10005</tns:Attendee_Zip_Code>\n' +
                                '					<tns:Attendee_Rural_Area>1</tns:Attendee_Rural_Area>\n' +
                                '					<tns:Attendee_Limited_English_Proficiency>3</tns:Attendee_Limited_English_Proficiency>\n' +
                                '				</tns:Group_Session_Attendee>\n' +
                                '				<tns:Group_Session_Attendee>\n' +
                                '					<tns:Attendee_Id>7103718745</tns:Attendee_Id>\n' +
                                '					<tns:Attendee_Fee_Amount>0</tns:Attendee_Fee_Amount>\n' +
                                '					<tns:Attendee_Referred_By>9</tns:Attendee_Referred_By>\n' +
                                '					<tns:Attendee_FirstTime_Home_Buyer>N</tns:Attendee_FirstTime_Home_Buyer>\n' +
                                '					<tns:Attendee_Income_Level>9</tns:Attendee_Income_Level>\n' +
                                '					<tns:Attendee_City>New York</tns:Attendee_City>\n' +
                                '					<tns:Attendee_State>41</tns:Attendee_State>\n' +
                                '					<tns:Attendee_Zip_Code>10005</tns:Attendee_Zip_Code>\n' +
                                '					<tns:Attendee_Rural_Area>3</tns:Attendee_Rural_Area>\n' +
                                '					<tns:Attendee_Limited_English_Proficiency>3</tns:Attendee_Limited_English_Proficiency>\n' +
                                '				</tns:Group_Session_Attendee>\n' +
                                '				<tns:Group_Session_Attendee>\n' +
                                '					<tns:Attendee_Id>7103713606</tns:Attendee_Id>\n' +
                                '					<tns:Attendee_Fee_Amount>0</tns:Attendee_Fee_Amount>\n' +
                                '					<tns:Attendee_Referred_By>9</tns:Attendee_Referred_By>\n' +
                                '					<tns:Attendee_FirstTime_Home_Buyer>N</tns:Attendee_FirstTime_Home_Buyer>\n' +
                                '					<tns:Attendee_Income_Level>10</tns:Attendee_Income_Level>\n' +
                                '					<tns:Attendee_City>New York</tns:Attendee_City>\n' +
                                '					<tns:Attendee_State>41</tns:Attendee_State>\n' +
                                '					<tns:Attendee_Zip_Code>10005</tns:Attendee_Zip_Code>\n' +
                                '					<tns:Attendee_Rural_Area>1</tns:Attendee_Rural_Area>\n' +
                                '					<tns:Attendee_Limited_English_Proficiency>3</tns:Attendee_Limited_English_Proficiency>\n' +
                                '				</tns:Group_Session_Attendee>\n' +
                                '				<tns:Group_Session_Attendee>\n' +
                                '					<tns:Attendee_Id>7103662542</tns:Attendee_Id>\n' +
                                '					<tns:Attendee_Fee_Amount>0</tns:Attendee_Fee_Amount>\n' +
                                '					<tns:Attendee_Referred_By>9</tns:Attendee_Referred_By>\n' +
                                '					<tns:Attendee_FirstTime_Home_Buyer>N</tns:Attendee_FirstTime_Home_Buyer>\n' +
                                '					<tns:Attendee_Income_Level>7</tns:Attendee_Income_Level>\n' +
                                '					<tns:Attendee_City>New York</tns:Attendee_City>\n' +
                                '					<tns:Attendee_State>41</tns:Attendee_State>\n' +
                                '					<tns:Attendee_Zip_Code>10005</tns:Attendee_Zip_Code>\n' +
                                '					<tns:Attendee_Rural_Area>2</tns:Attendee_Rural_Area>\n' +
                                '					<tns:Attendee_Limited_English_Proficiency>2</tns:Attendee_Limited_English_Proficiency>\n' +
                                '				</tns:Group_Session_Attendee>\n' +
                                '				<tns:Group_Session_Attendee>\n' +
                                '					<tns:Attendee_Id>7103706861</tns:Attendee_Id>\n' +
                                '					<tns:Attendee_Fee_Amount>0</tns:Attendee_Fee_Amount>\n' +
                                '					<tns:Attendee_Referred_By>9</tns:Attendee_Referred_By>\n' +
                                '					<tns:Attendee_FirstTime_Home_Buyer>N</tns:Attendee_FirstTime_Home_Buyer>\n' +
                                '					<tns:Attendee_Income_Level>7</tns:Attendee_Income_Level>\n' +
                                '					<tns:Attendee_City>New York</tns:Attendee_City>\n' +
                                '					<tns:Attendee_State>41</tns:Attendee_State>\n' +
                                '					<tns:Attendee_Zip_Code>10005</tns:Attendee_Zip_Code>\n' +
                                '					<tns:Attendee_Rural_Area>2</tns:Attendee_Rural_Area>\n' +
                                '					<tns:Attendee_Limited_English_Proficiency>3</tns:Attendee_Limited_English_Proficiency>\n' +
                                '				</tns:Group_Session_Attendee>\n' +
                                '				<tns:Group_Session_Attendee>\n' +
                                '					<tns:Attendee_Id>7103724363</tns:Attendee_Id>\n' +
                                '					<tns:Attendee_Fee_Amount>0</tns:Attendee_Fee_Amount>\n' +
                                '					<tns:Attendee_Referred_By>9</tns:Attendee_Referred_By>\n' +
                                '					<tns:Attendee_FirstTime_Home_Buyer>N</tns:Attendee_FirstTime_Home_Buyer>\n' +
                                '					<tns:Attendee_Income_Level>11</tns:Attendee_Income_Level>\n' +
                                '					<tns:Attendee_City>New York</tns:Attendee_City>\n' +
                                '					<tns:Attendee_State>41</tns:Attendee_State>\n' +
                                '					<tns:Attendee_Zip_Code>10005</tns:Attendee_Zip_Code>\n' +
                                '					<tns:Attendee_Rural_Area>1</tns:Attendee_Rural_Area>\n' +
                                '					<tns:Attendee_Limited_English_Proficiency>1</tns:Attendee_Limited_English_Proficiency>\n' +
                                '				</tns:Group_Session_Attendee>\n' +
                                '				<tns:Group_Session_Attendee>\n' +
                                '					<tns:Attendee_Id>7103662022</tns:Attendee_Id>\n' +
                                '					<tns:Attendee_Fee_Amount>0</tns:Attendee_Fee_Amount>\n' +
                                '					<tns:Attendee_Referred_By>9</tns:Attendee_Referred_By>\n' +
                                '					<tns:Attendee_FirstTime_Home_Buyer>N</tns:Attendee_FirstTime_Home_Buyer>\n' +
                                '					<tns:Attendee_Income_Level>12</tns:Attendee_Income_Level>\n' +
                                '					<tns:Attendee_City>New York</tns:Attendee_City>\n' +
                                '					<tns:Attendee_State>41</tns:Attendee_State>\n' +
                                '					<tns:Attendee_Zip_Code>10005</tns:Attendee_Zip_Code>\n' +
                                '					<tns:Attendee_Rural_Area>1</tns:Attendee_Rural_Area>\n' +
                                '					<tns:Attendee_Limited_English_Proficiency>3</tns:Attendee_Limited_English_Proficiency>\n' +
                                '				</tns:Group_Session_Attendee>\n' +
                                '				<tns:Group_Session_Attendee>\n' +
                                '					<tns:Attendee_Id>7103726065</tns:Attendee_Id>\n' +
                                '					<tns:Attendee_Fee_Amount>0</tns:Attendee_Fee_Amount>\n' +
                                '					<tns:Attendee_Referred_By>9</tns:Attendee_Referred_By>\n' +
                                '					<tns:Attendee_FirstTime_Home_Buyer>N</tns:Attendee_FirstTime_Home_Buyer>\n' +
                                '					<tns:Attendee_Income_Level>9</tns:Attendee_Income_Level>\n' +
                                '					<tns:Attendee_City>New York</tns:Attendee_City>\n' +
                                '					<tns:Attendee_State>41</tns:Attendee_State>\n' +
                                '					<tns:Attendee_Zip_Code>10005</tns:Attendee_Zip_Code>\n' +
                                '					<tns:Attendee_Rural_Area>2</tns:Attendee_Rural_Area>\n' +
                                '					<tns:Attendee_Limited_English_Proficiency>1</tns:Attendee_Limited_English_Proficiency>\n' +
                                '				</tns:Group_Session_Attendee>\n' +
                                '				<tns:Group_Session_Attendee>\n' +
                                '					<tns:Attendee_Id>7103738928</tns:Attendee_Id>\n' +
                                '					<tns:Attendee_Fee_Amount>0</tns:Attendee_Fee_Amount>\n' +
                                '					<tns:Attendee_Referred_By>9</tns:Attendee_Referred_By>\n' +
                                '					<tns:Attendee_FirstTime_Home_Buyer>N</tns:Attendee_FirstTime_Home_Buyer>\n' +
                                '					<tns:Attendee_Income_Level>11</tns:Attendee_Income_Level>\n' +
                                '					<tns:Attendee_City>New York</tns:Attendee_City>\n' +
                                '					<tns:Attendee_State>41</tns:Attendee_State>\n' +
                                '					<tns:Attendee_Zip_Code>10005</tns:Attendee_Zip_Code>\n' +
                                '					<tns:Attendee_Rural_Area>2</tns:Attendee_Rural_Area>\n' +
                                '					<tns:Attendee_Limited_English_Proficiency>3</tns:Attendee_Limited_English_Proficiency>\n' +
                                '				</tns:Group_Session_Attendee>\n' +
                                '				<tns:Group_Session_Attendee>\n' +
                                '					<tns:Attendee_Id>7103736790</tns:Attendee_Id>\n' +
                                '					<tns:Attendee_Fee_Amount>0</tns:Attendee_Fee_Amount>\n' +
                                '					<tns:Attendee_Referred_By>9</tns:Attendee_Referred_By>\n' +
                                '					<tns:Attendee_FirstTime_Home_Buyer>N</tns:Attendee_FirstTime_Home_Buyer>\n' +
                                '					<tns:Attendee_Income_Level>11</tns:Attendee_Income_Level>\n' +
                                '					<tns:Attendee_City>New York</tns:Attendee_City>\n' +
                                '					<tns:Attendee_State>41</tns:Attendee_State>\n' +
                                '					<tns:Attendee_Zip_Code>10005</tns:Attendee_Zip_Code>\n' +
                                '					<tns:Attendee_Rural_Area>2</tns:Attendee_Rural_Area>\n' +
                                '					<tns:Attendee_Limited_English_Proficiency>2</tns:Attendee_Limited_English_Proficiency>\n' +
                                '				</tns:Group_Session_Attendee>\n' +
                                '				<tns:Group_Session_Attendee>\n' +
                                '					<tns:Attendee_Id>7103726588</tns:Attendee_Id>\n' +
                                '					<tns:Attendee_Fee_Amount>0</tns:Attendee_Fee_Amount>\n' +
                                '					<tns:Attendee_Referred_By>9</tns:Attendee_Referred_By>\n' +
                                '					<tns:Attendee_FirstTime_Home_Buyer>N</tns:Attendee_FirstTime_Home_Buyer>\n' +
                                '					<tns:Attendee_Income_Level>9</tns:Attendee_Income_Level>\n' +
                                '					<tns:Attendee_City>New York</tns:Attendee_City>\n' +
                                '					<tns:Attendee_State>41</tns:Attendee_State>\n' +
                                '					<tns:Attendee_Zip_Code>10005</tns:Attendee_Zip_Code>\n' +
                                '					<tns:Attendee_Rural_Area>1</tns:Attendee_Rural_Area>\n' +
                                '					<tns:Attendee_Limited_English_Proficiency>2</tns:Attendee_Limited_English_Proficiency>\n' +
                                '				</tns:Group_Session_Attendee>\n' +
                                '				<tns:Group_Session_Attendee>\n' +
                                '					<tns:Attendee_Id>7103759115</tns:Attendee_Id>\n' +
                                '					<tns:Attendee_Fee_Amount>0</tns:Attendee_Fee_Amount>\n' +
                                '					<tns:Attendee_Referred_By>9</tns:Attendee_Referred_By>\n' +
                                '					<tns:Attendee_FirstTime_Home_Buyer>N</tns:Attendee_FirstTime_Home_Buyer>\n' +
                                '					<tns:Attendee_Income_Level>11</tns:Attendee_Income_Level>\n' +
                                '					<tns:Attendee_City>New York</tns:Attendee_City>\n' +
                                '					<tns:Attendee_State>41</tns:Attendee_State>\n' +
                                '					<tns:Attendee_Zip_Code>10005</tns:Attendee_Zip_Code>\n' +
                                '					<tns:Attendee_Rural_Area>3</tns:Attendee_Rural_Area>\n' +
                                '					<tns:Attendee_Limited_English_Proficiency>1</tns:Attendee_Limited_English_Proficiency>\n' +
                                '				</tns:Group_Session_Attendee>\n' +
                                '				<tns:Group_Session_Attendee>\n' +
                                '					<tns:Attendee_Id>7103694268</tns:Attendee_Id>\n' +
                                '					<tns:Attendee_Fee_Amount>0</tns:Attendee_Fee_Amount>\n' +
                                '					<tns:Attendee_Referred_By>9</tns:Attendee_Referred_By>\n' +
                                '					<tns:Attendee_FirstTime_Home_Buyer>N</tns:Attendee_FirstTime_Home_Buyer>\n' +
                                '					<tns:Attendee_Income_Level>9</tns:Attendee_Income_Level>\n' +
                                '					<tns:Attendee_City>New York</tns:Attendee_City>\n' +
                                '					<tns:Attendee_State>41</tns:Attendee_State>\n' +
                                '					<tns:Attendee_Zip_Code>10005</tns:Attendee_Zip_Code>\n' +
                                '					<tns:Attendee_Rural_Area>2</tns:Attendee_Rural_Area>\n' +
                                '					<tns:Attendee_Limited_English_Proficiency>2</tns:Attendee_Limited_English_Proficiency>\n' +
                                '				</tns:Group_Session_Attendee>\n' +
                                '				<tns:Group_Session_Attendee>\n' +
                                '					<tns:Attendee_Id>7103662721</tns:Attendee_Id>\n' +
                                '					<tns:Attendee_Fee_Amount>0</tns:Attendee_Fee_Amount>\n' +
                                '					<tns:Attendee_Referred_By>9</tns:Attendee_Referred_By>\n' +
                                '					<tns:Attendee_FirstTime_Home_Buyer>N</tns:Attendee_FirstTime_Home_Buyer>\n' +
                                '					<tns:Attendee_Income_Level>12</tns:Attendee_Income_Level>\n' +
                                '					<tns:Attendee_City>New York</tns:Attendee_City>\n' +
                                '					<tns:Attendee_State>41</tns:Attendee_State>\n' +
                                '					<tns:Attendee_Zip_Code>10005</tns:Attendee_Zip_Code>\n' +
                                '					<tns:Attendee_Rural_Area>2</tns:Attendee_Rural_Area>\n' +
                                '					<tns:Attendee_Limited_English_Proficiency>1</tns:Attendee_Limited_English_Proficiency>\n' +
                                '				</tns:Group_Session_Attendee>\n' +
                                '				<tns:Group_Session_Attendee>\n' +
                                '					<tns:Attendee_Id>7103711352</tns:Attendee_Id>\n' +
                                '					<tns:Attendee_Fee_Amount>0</tns:Attendee_Fee_Amount>\n' +
                                '					<tns:Attendee_Referred_By>9</tns:Attendee_Referred_By>\n' +
                                '					<tns:Attendee_FirstTime_Home_Buyer>N</tns:Attendee_FirstTime_Home_Buyer>\n' +
                                '					<tns:Attendee_Income_Level>7</tns:Attendee_Income_Level>\n' +
                                '					<tns:Attendee_City>New York</tns:Attendee_City>\n' +
                                '					<tns:Attendee_State>41</tns:Attendee_State>\n' +
                                '					<tns:Attendee_Zip_Code>10005</tns:Attendee_Zip_Code>\n' +
                                '					<tns:Attendee_Rural_Area>2</tns:Attendee_Rural_Area>\n' +
                                '					<tns:Attendee_Limited_English_Proficiency>3</tns:Attendee_Limited_English_Proficiency>\n' +
                                '				</tns:Group_Session_Attendee>\n' +
                                '				<tns:Group_Session_Attendee>\n' +
                                '					<tns:Attendee_Id>7103698939</tns:Attendee_Id>\n' +
                                '					<tns:Attendee_Fee_Amount>0</tns:Attendee_Fee_Amount>\n' +
                                '					<tns:Attendee_Referred_By>9</tns:Attendee_Referred_By>\n' +
                                '					<tns:Attendee_FirstTime_Home_Buyer>N</tns:Attendee_FirstTime_Home_Buyer>\n' +
                                '					<tns:Attendee_Income_Level>7</tns:Attendee_Income_Level>\n' +
                                '					<tns:Attendee_City>New York</tns:Attendee_City>\n' +
                                '					<tns:Attendee_State>41</tns:Attendee_State>\n' +
                                '					<tns:Attendee_Zip_Code>10005</tns:Attendee_Zip_Code>\n' +
                                '					<tns:Attendee_Rural_Area>2</tns:Attendee_Rural_Area>\n' +
                                '					<tns:Attendee_Limited_English_Proficiency>3</tns:Attendee_Limited_English_Proficiency>\n' +
                                '				</tns:Group_Session_Attendee>\n' +
                                '				<tns:Group_Session_Attendee>\n' +
                                '					<tns:Attendee_Id>7103702944</tns:Attendee_Id>\n' +
                                '					<tns:Attendee_Fee_Amount>0</tns:Attendee_Fee_Amount>\n' +
                                '					<tns:Attendee_Referred_By>9</tns:Attendee_Referred_By>\n' +
                                '					<tns:Attendee_FirstTime_Home_Buyer>N</tns:Attendee_FirstTime_Home_Buyer>\n' +
                                '					<tns:Attendee_Income_Level>11</tns:Attendee_Income_Level>\n' +
                                '					<tns:Attendee_City>New York</tns:Attendee_City>\n' +
                                '					<tns:Attendee_State>41</tns:Attendee_State>\n' +
                                '					<tns:Attendee_Zip_Code>10005</tns:Attendee_Zip_Code>\n' +
                                '					<tns:Attendee_Rural_Area>3</tns:Attendee_Rural_Area>\n' +
                                '					<tns:Attendee_Limited_English_Proficiency>2</tns:Attendee_Limited_English_Proficiency>\n' +
                                '				</tns:Group_Session_Attendee>\n' +
                                '				<tns:Group_Session_Attendee>\n' +
                                '					<tns:Attendee_Id>7103693972</tns:Attendee_Id>\n' +
                                '					<tns:Attendee_Fee_Amount>0</tns:Attendee_Fee_Amount>\n' +
                                '					<tns:Attendee_Referred_By>9</tns:Attendee_Referred_By>\n' +
                                '					<tns:Attendee_FirstTime_Home_Buyer>N</tns:Attendee_FirstTime_Home_Buyer>\n' +
                                '					<tns:Attendee_Income_Level>8</tns:Attendee_Income_Level>\n' +
                                '					<tns:Attendee_City>New York</tns:Attendee_City>\n' +
                                '					<tns:Attendee_State>41</tns:Attendee_State>\n' +
                                '					<tns:Attendee_Zip_Code>10005</tns:Attendee_Zip_Code>\n' +
                                '					<tns:Attendee_Rural_Area>3</tns:Attendee_Rural_Area>\n' +
                                '					<tns:Attendee_Limited_English_Proficiency>2</tns:Attendee_Limited_English_Proficiency>\n' +
                                '				</tns:Group_Session_Attendee>\n' +
                                '				<tns:Group_Session_Attendee>\n' +
                                '					<tns:Attendee_Id>7103749978</tns:Attendee_Id>\n' +
                                '					<tns:Attendee_Fee_Amount>0</tns:Attendee_Fee_Amount>\n' +
                                '					<tns:Attendee_Referred_By>9</tns:Attendee_Referred_By>\n' +
                                '					<tns:Attendee_FirstTime_Home_Buyer>N</tns:Attendee_FirstTime_Home_Buyer>\n' +
                                '					<tns:Attendee_Income_Level>11</tns:Attendee_Income_Level>\n' +
                                '					<tns:Attendee_City>New York</tns:Attendee_City>\n' +
                                '					<tns:Attendee_State>41</tns:Attendee_State>\n' +
                                '					<tns:Attendee_Zip_Code>10005</tns:Attendee_Zip_Code>\n' +
                                '					<tns:Attendee_Rural_Area>1</tns:Attendee_Rural_Area>\n' +
                                '					<tns:Attendee_Limited_English_Proficiency>2</tns:Attendee_Limited_English_Proficiency>\n' +
                                '				</tns:Group_Session_Attendee>\n' +
                                '				<tns:Group_Session_Attendee>\n' +
                                '					<tns:Attendee_Id>7103719194</tns:Attendee_Id>\n' +
                                '					<tns:Attendee_Fee_Amount>0</tns:Attendee_Fee_Amount>\n' +
                                '					<tns:Attendee_Referred_By>9</tns:Attendee_Referred_By>\n' +
                                '					<tns:Attendee_FirstTime_Home_Buyer>N</tns:Attendee_FirstTime_Home_Buyer>\n' +
                                '					<tns:Attendee_Income_Level>10</tns:Attendee_Income_Level>\n' +
                                '					<tns:Attendee_City>New York</tns:Attendee_City>\n' +
                                '					<tns:Attendee_State>41</tns:Attendee_State>\n' +
                                '					<tns:Attendee_Zip_Code>10005</tns:Attendee_Zip_Code>\n' +
                                '					<tns:Attendee_Rural_Area>3</tns:Attendee_Rural_Area>\n' +
                                '					<tns:Attendee_Limited_English_Proficiency>3</tns:Attendee_Limited_English_Proficiency>\n' +
                                '				</tns:Group_Session_Attendee>\n' +
                                '				<tns:Group_Session_Attendee>\n' +
                                '					<tns:Attendee_Id>7103748749</tns:Attendee_Id>\n' +
                                '					<tns:Attendee_Fee_Amount>0</tns:Attendee_Fee_Amount>\n' +
                                '					<tns:Attendee_Referred_By>9</tns:Attendee_Referred_By>\n' +
                                '					<tns:Attendee_FirstTime_Home_Buyer>N</tns:Attendee_FirstTime_Home_Buyer>\n' +
                                '					<tns:Attendee_Income_Level>10</tns:Attendee_Income_Level>\n' +
                                '					<tns:Attendee_City>New York</tns:Attendee_City>\n' +
                                '					<tns:Attendee_State>41</tns:Attendee_State>\n' +
                                '					<tns:Attendee_Zip_Code>10005</tns:Attendee_Zip_Code>\n' +
                                '					<tns:Attendee_Rural_Area>2</tns:Attendee_Rural_Area>\n' +
                                '					<tns:Attendee_Limited_English_Proficiency>1</tns:Attendee_Limited_English_Proficiency>\n' +
                                '				</tns:Group_Session_Attendee>\n' +
                                '				<tns:Group_Session_Attendee>\n' +
                                '					<tns:Attendee_Id>7103737676</tns:Attendee_Id>\n' +
                                '					<tns:Attendee_Fee_Amount>0</tns:Attendee_Fee_Amount>\n' +
                                '					<tns:Attendee_Referred_By>9</tns:Attendee_Referred_By>\n' +
                                '					<tns:Attendee_FirstTime_Home_Buyer>N</tns:Attendee_FirstTime_Home_Buyer>\n' +
                                '					<tns:Attendee_Income_Level>11</tns:Attendee_Income_Level>\n' +
                                '					<tns:Attendee_City>New York</tns:Attendee_City>\n' +
                                '					<tns:Attendee_State>41</tns:Attendee_State>\n' +
                                '					<tns:Attendee_Zip_Code>10005</tns:Attendee_Zip_Code>\n' +
                                '					<tns:Attendee_Rural_Area>1</tns:Attendee_Rural_Area>\n' +
                                '					<tns:Attendee_Limited_English_Proficiency>1</tns:Attendee_Limited_English_Proficiency>\n' +
                                '				</tns:Group_Session_Attendee>\n' +
                                '				<tns:Group_Session_Attendee>\n' +
                                '					<tns:Attendee_Id>7103665562</tns:Attendee_Id>\n' +
                                '					<tns:Attendee_Fee_Amount>0</tns:Attendee_Fee_Amount>\n' +
                                '					<tns:Attendee_Referred_By>9</tns:Attendee_Referred_By>\n' +
                                '					<tns:Attendee_FirstTime_Home_Buyer>N</tns:Attendee_FirstTime_Home_Buyer>\n' +
                                '					<tns:Attendee_Income_Level>11</tns:Attendee_Income_Level>\n' +
                                '					<tns:Attendee_City>New York</tns:Attendee_City>\n' +
                                '					<tns:Attendee_State>41</tns:Attendee_State>\n' +
                                '					<tns:Attendee_Zip_Code>10005</tns:Attendee_Zip_Code>\n' +
                                '					<tns:Attendee_Rural_Area>1</tns:Attendee_Rural_Area>\n' +
                                '					<tns:Attendee_Limited_English_Proficiency>3</tns:Attendee_Limited_English_Proficiency>\n' +
                                '				</tns:Group_Session_Attendee>\n' +
                                '				<tns:Group_Session_Attendee>\n' +
                                '					<tns:Attendee_Id>7103706044</tns:Attendee_Id>\n' +
                                '					<tns:Attendee_Fee_Amount>0</tns:Attendee_Fee_Amount>\n' +
                                '					<tns:Attendee_Referred_By>9</tns:Attendee_Referred_By>\n' +
                                '					<tns:Attendee_FirstTime_Home_Buyer>N</tns:Attendee_FirstTime_Home_Buyer>\n' +
                                '					<tns:Attendee_Income_Level>11</tns:Attendee_Income_Level>\n' +
                                '					<tns:Attendee_City>New York</tns:Attendee_City>\n' +
                                '					<tns:Attendee_State>41</tns:Attendee_State>\n' +
                                '					<tns:Attendee_Zip_Code>10005</tns:Attendee_Zip_Code>\n' +
                                '					<tns:Attendee_Rural_Area>2</tns:Attendee_Rural_Area>\n' +
                                '					<tns:Attendee_Limited_English_Proficiency>1</tns:Attendee_Limited_English_Proficiency>\n' +
                                '				</tns:Group_Session_Attendee>\n' +
                                '				<tns:Group_Session_Attendee>\n' +
                                '					<tns:Attendee_Id>7103675042</tns:Attendee_Id>\n' +
                                '					<tns:Attendee_Fee_Amount>0</tns:Attendee_Fee_Amount>\n' +
                                '					<tns:Attendee_Referred_By>9</tns:Attendee_Referred_By>\n' +
                                '					<tns:Attendee_FirstTime_Home_Buyer>N</tns:Attendee_FirstTime_Home_Buyer>\n' +
                                '					<tns:Attendee_Income_Level>9</tns:Attendee_Income_Level>\n' +
                                '					<tns:Attendee_City>New York</tns:Attendee_City>\n' +
                                '					<tns:Attendee_State>41</tns:Attendee_State>\n' +
                                '					<tns:Attendee_Zip_Code>10005</tns:Attendee_Zip_Code>\n' +
                                '					<tns:Attendee_Rural_Area>3</tns:Attendee_Rural_Area>\n' +
                                '					<tns:Attendee_Limited_English_Proficiency>2</tns:Attendee_Limited_English_Proficiency>\n' +
                                '				</tns:Group_Session_Attendee>\n' +
                                '				<tns:Group_Session_Attendee>\n' +
                                '					<tns:Attendee_Id>7103756263</tns:Attendee_Id>\n' +
                                '					<tns:Attendee_Fee_Amount>0</tns:Attendee_Fee_Amount>\n' +
                                '					<tns:Attendee_Referred_By>9</tns:Attendee_Referred_By>\n' +
                                '					<tns:Attendee_FirstTime_Home_Buyer>N</tns:Attendee_FirstTime_Home_Buyer>\n' +
                                '					<tns:Attendee_Income_Level>11</tns:Attendee_Income_Level>\n' +
                                '					<tns:Attendee_City>New York</tns:Attendee_City>\n' +
                                '					<tns:Attendee_State>41</tns:Attendee_State>\n' +
                                '					<tns:Attendee_Zip_Code>10005</tns:Attendee_Zip_Code>\n' +
                                '					<tns:Attendee_Rural_Area>1</tns:Attendee_Rural_Area>\n' +
                                '					<tns:Attendee_Limited_English_Proficiency>3</tns:Attendee_Limited_English_Proficiency>\n' +
                                '				</tns:Group_Session_Attendee>\n' +
                                '				<tns:Group_Session_Attendee>\n' +
                                '					<tns:Attendee_Id>7103682187</tns:Attendee_Id>\n' +
                                '					<tns:Attendee_Fee_Amount>0</tns:Attendee_Fee_Amount>\n' +
                                '					<tns:Attendee_Referred_By>9</tns:Attendee_Referred_By>\n' +
                                '					<tns:Attendee_FirstTime_Home_Buyer>N</tns:Attendee_FirstTime_Home_Buyer>\n' +
                                '					<tns:Attendee_Income_Level>9</tns:Attendee_Income_Level>\n' +
                                '					<tns:Attendee_City>New York</tns:Attendee_City>\n' +
                                '					<tns:Attendee_State>41</tns:Attendee_State>\n' +
                                '					<tns:Attendee_Zip_Code>10005</tns:Attendee_Zip_Code>\n' +
                                '					<tns:Attendee_Rural_Area>2</tns:Attendee_Rural_Area>\n' +
                                '					<tns:Attendee_Limited_English_Proficiency>1</tns:Attendee_Limited_English_Proficiency>\n' +
                                '				</tns:Group_Session_Attendee>\n' +
                                '				<tns:Group_Session_Attendee>\n' +
                                '					<tns:Attendee_Id>7103686659</tns:Attendee_Id>\n' +
                                '					<tns:Attendee_Fee_Amount>0</tns:Attendee_Fee_Amount>\n' +
                                '					<tns:Attendee_Referred_By>9</tns:Attendee_Referred_By>\n' +
                                '					<tns:Attendee_FirstTime_Home_Buyer>N</tns:Attendee_FirstTime_Home_Buyer>\n' +
                                '					<tns:Attendee_Income_Level>11</tns:Attendee_Income_Level>\n' +
                                '					<tns:Attendee_City>New York</tns:Attendee_City>\n' +
                                '					<tns:Attendee_State>41</tns:Attendee_State>\n' +
                                '					<tns:Attendee_Zip_Code>10005</tns:Attendee_Zip_Code>\n' +
                                '					<tns:Attendee_Rural_Area>2</tns:Attendee_Rural_Area>\n' +
                                '					<tns:Attendee_Limited_English_Proficiency>2</tns:Attendee_Limited_English_Proficiency>\n' +
                                '				</tns:Group_Session_Attendee>\n' +
                                '				<tns:Group_Session_Attendee>\n' +
                                '					<tns:Attendee_Id>7103694521</tns:Attendee_Id>\n' +
                                '					<tns:Attendee_Fee_Amount>0</tns:Attendee_Fee_Amount>\n' +
                                '					<tns:Attendee_Referred_By>9</tns:Attendee_Referred_By>\n' +
                                '					<tns:Attendee_FirstTime_Home_Buyer>N</tns:Attendee_FirstTime_Home_Buyer>\n' +
                                '					<tns:Attendee_Income_Level>12</tns:Attendee_Income_Level>\n' +
                                '					<tns:Attendee_City>New York</tns:Attendee_City>\n' +
                                '					<tns:Attendee_State>41</tns:Attendee_State>\n' +
                                '					<tns:Attendee_Zip_Code>10005</tns:Attendee_Zip_Code>\n' +
                                '					<tns:Attendee_Rural_Area>3</tns:Attendee_Rural_Area>\n' +
                                '					<tns:Attendee_Limited_English_Proficiency>3</tns:Attendee_Limited_English_Proficiency>\n' +
                                '				</tns:Group_Session_Attendee>\n' +
                                '				<tns:Group_Session_Attendee>\n' +
                                '					<tns:Attendee_Id>7103671878</tns:Attendee_Id>\n' +
                                '					<tns:Attendee_Fee_Amount>0</tns:Attendee_Fee_Amount>\n' +
                                '					<tns:Attendee_Referred_By>9</tns:Attendee_Referred_By>\n' +
                                '					<tns:Attendee_FirstTime_Home_Buyer>N</tns:Attendee_FirstTime_Home_Buyer>\n' +
                                '					<tns:Attendee_Income_Level>11</tns:Attendee_Income_Level>\n' +
                                '					<tns:Attendee_City>New York</tns:Attendee_City>\n' +
                                '					<tns:Attendee_State>41</tns:Attendee_State>\n' +
                                '					<tns:Attendee_Zip_Code>10005</tns:Attendee_Zip_Code>\n' +
                                '					<tns:Attendee_Rural_Area>2</tns:Attendee_Rural_Area>\n' +
                                '					<tns:Attendee_Limited_English_Proficiency>1</tns:Attendee_Limited_English_Proficiency>\n' +
                                '				</tns:Group_Session_Attendee>\n' +
                                '				<tns:Group_Session_Attendee>\n' +
                                '					<tns:Attendee_Id>7103663213</tns:Attendee_Id>\n' +
                                '					<tns:Attendee_Fee_Amount>0</tns:Attendee_Fee_Amount>\n' +
                                '					<tns:Attendee_Referred_By>9</tns:Attendee_Referred_By>\n' +
                                '					<tns:Attendee_FirstTime_Home_Buyer>N</tns:Attendee_FirstTime_Home_Buyer>\n' +
                                '					<tns:Attendee_Income_Level>8</tns:Attendee_Income_Level>\n' +
                                '					<tns:Attendee_City>New York</tns:Attendee_City>\n' +
                                '					<tns:Attendee_State>41</tns:Attendee_State>\n' +
                                '					<tns:Attendee_Zip_Code>10005</tns:Attendee_Zip_Code>\n' +
                                '					<tns:Attendee_Rural_Area>2</tns:Attendee_Rural_Area>\n' +
                                '					<tns:Attendee_Limited_English_Proficiency>1</tns:Attendee_Limited_English_Proficiency>\n' +
                                '				</tns:Group_Session_Attendee>\n' +
                                '				<tns:Group_Session_Attendee>\n' +
                                '					<tns:Attendee_Id>7103756479</tns:Attendee_Id>\n' +
                                '					<tns:Attendee_Fee_Amount>0</tns:Attendee_Fee_Amount>\n' +
                                '					<tns:Attendee_Referred_By>9</tns:Attendee_Referred_By>\n' +
                                '					<tns:Attendee_FirstTime_Home_Buyer>N</tns:Attendee_FirstTime_Home_Buyer>\n' +
                                '					<tns:Attendee_Income_Level>8</tns:Attendee_Income_Level>\n' +
                                '					<tns:Attendee_City>New York</tns:Attendee_City>\n' +
                                '					<tns:Attendee_State>41</tns:Attendee_State>\n' +
                                '					<tns:Attendee_Zip_Code>10005</tns:Attendee_Zip_Code>\n' +
                                '					<tns:Attendee_Rural_Area>2</tns:Attendee_Rural_Area>\n' +
                                '					<tns:Attendee_Limited_English_Proficiency>2</tns:Attendee_Limited_English_Proficiency>\n' +
                                '				</tns:Group_Session_Attendee>\n' +
                                '				<tns:Group_Session_Attendee>\n' +
                                '					<tns:Attendee_Id>7103713140</tns:Attendee_Id>\n' +
                                '					<tns:Attendee_Fee_Amount>0</tns:Attendee_Fee_Amount>\n' +
                                '					<tns:Attendee_Referred_By>9</tns:Attendee_Referred_By>\n' +
                                '					<tns:Attendee_FirstTime_Home_Buyer>N</tns:Attendee_FirstTime_Home_Buyer>\n' +
                                '					<tns:Attendee_Income_Level>11</tns:Attendee_Income_Level>\n' +
                                '					<tns:Attendee_City>New York</tns:Attendee_City>\n' +
                                '					<tns:Attendee_State>41</tns:Attendee_State>\n' +
                                '					<tns:Attendee_Zip_Code>10005</tns:Attendee_Zip_Code>\n' +
                                '					<tns:Attendee_Rural_Area>3</tns:Attendee_Rural_Area>\n' +
                                '					<tns:Attendee_Limited_English_Proficiency>2</tns:Attendee_Limited_English_Proficiency>\n' +
                                '				</tns:Group_Session_Attendee>\n' +
                                '				<tns:Group_Session_Attendee>\n' +
                                '					<tns:Attendee_Id>7103741041</tns:Attendee_Id>\n' +
                                '					<tns:Attendee_Fee_Amount>0</tns:Attendee_Fee_Amount>\n' +
                                '					<tns:Attendee_Referred_By>9</tns:Attendee_Referred_By>\n' +
                                '					<tns:Attendee_FirstTime_Home_Buyer>N</tns:Attendee_FirstTime_Home_Buyer>\n' +
                                '					<tns:Attendee_Income_Level>11</tns:Attendee_Income_Level>\n' +
                                '					<tns:Attendee_City>New York</tns:Attendee_City>\n' +
                                '					<tns:Attendee_State>41</tns:Attendee_State>\n' +
                                '					<tns:Attendee_Zip_Code>10005</tns:Attendee_Zip_Code>\n' +
                                '					<tns:Attendee_Rural_Area>2</tns:Attendee_Rural_Area>\n' +
                                '					<tns:Attendee_Limited_English_Proficiency>3</tns:Attendee_Limited_English_Proficiency>\n' +
                                '				</tns:Group_Session_Attendee>\n' +
                                '				<tns:Group_Session_Attendee>\n' +
                                '					<tns:Attendee_Id>7103750628</tns:Attendee_Id>\n' +
                                '					<tns:Attendee_Fee_Amount>0</tns:Attendee_Fee_Amount>\n' +
                                '					<tns:Attendee_Referred_By>9</tns:Attendee_Referred_By>\n' +
                                '					<tns:Attendee_FirstTime_Home_Buyer>N</tns:Attendee_FirstTime_Home_Buyer>\n' +
                                '					<tns:Attendee_Income_Level>11</tns:Attendee_Income_Level>\n' +
                                '					<tns:Attendee_City>New York</tns:Attendee_City>\n' +
                                '					<tns:Attendee_State>41</tns:Attendee_State>\n' +
                                '					<tns:Attendee_Zip_Code>10005</tns:Attendee_Zip_Code>\n' +
                                '					<tns:Attendee_Rural_Area>3</tns:Attendee_Rural_Area>\n' +
                                '					<tns:Attendee_Limited_English_Proficiency>2</tns:Attendee_Limited_English_Proficiency>\n' +
                                '				</tns:Group_Session_Attendee>\n' +
                                '				<tns:Group_Session_Attendee>\n' +
                                '					<tns:Attendee_Id>7103661590</tns:Attendee_Id>\n' +
                                '					<tns:Attendee_Fee_Amount>0</tns:Attendee_Fee_Amount>\n' +
                                '					<tns:Attendee_Referred_By>9</tns:Attendee_Referred_By>\n' +
                                '					<tns:Attendee_FirstTime_Home_Buyer>N</tns:Attendee_FirstTime_Home_Buyer>\n' +
                                '					<tns:Attendee_Income_Level>10</tns:Attendee_Income_Level>\n' +
                                '					<tns:Attendee_City>New York</tns:Attendee_City>\n' +
                                '					<tns:Attendee_State>41</tns:Attendee_State>\n' +
                                '					<tns:Attendee_Zip_Code>10005</tns:Attendee_Zip_Code>\n' +
                                '					<tns:Attendee_Rural_Area>2</tns:Attendee_Rural_Area>\n' +
                                '					<tns:Attendee_Limited_English_Proficiency>3</tns:Attendee_Limited_English_Proficiency>\n' +
                                '				</tns:Group_Session_Attendee>\n' +
                                '			</tns:Group_Session_Attendees>\n' +
                                '		</tns:Group_Session >\n' +
                                '	</tns:Group_Sessions >\n' +
                                '	<tns:Attendees>\n' +
                                '		<Attendee>\n' +
                                '			<tns:Attendee_Id>7103710254</tns:Attendee_Id>\n' +
                                '			<tns:Attendee_Income_Level>7</tns:Attendee_Income_Level>\n' +
                                '			<tns:Attendee_City>New York</tns:Attendee_City>\n' +
                                '			<tns:Attendee_State>41</tns:Attendee_State>\n' +
                                '			<tns:Attendee_Zip_Code>10005</tns:Attendee_Zip_Code>\n' +
                                '			<tns:Attendee_Rural_Area>1</tns:Attendee_Rural_Area>\n' +
                                '			<tns:Attendee_Limited_English_Proficiency>2</tns:Attendee_Limited_English_Proficiency>\n' +
                                '			<tns:Attendee_Race_ID>19</tns:Attendee_Race_ID>\n' +
                                '			<tns:Attendee_Ethnicity_ID>2</tns:Attendee_Ethnicity_ID>\n' +
                                '		</tns:Attendee>\n' +
                                '		<tns:Attendee>\n' +
                                '			<tns:Attendee_Id>7103699588</tns:Attendee_Id>\n' +
                                '			<tns:Attendee_Income_Level>11</tns:Attendee_Income_Level>\n' +
                                '			<tns:Attendee_City>New York</tns:Attendee_City>\n' +
                                '			<tns:Attendee_State>41</tns:Attendee_State>\n' +
                                '			<tns:Attendee_Zip_Code>10005</tns:Attendee_Zip_Code>\n' +
                                '			<tns:Attendee_Rural_Area>3</tns:Attendee_Rural_Area>\n' +
                                '			<tns:Attendee_Limited_English_Proficiency>2</tns:Attendee_Limited_English_Proficiency>\n' +
                                '			<tns:Attendee_Race_ID>16</tns:Attendee_Race_ID>\n' +
                                '			<tns:Attendee_Ethnicity_ID>4</tns:Attendee_Ethnicity_ID>\n' +
                                '		</tns:Attendee>\n' +
                                '		<tns:Attendee>\n' +
                                '			<tns:Attendee_Id>7103713519</tns:Attendee_Id>\n' +
                                '			<tns:Attendee_Income_Level>9</tns:Attendee_Income_Level>\n' +
                                '			<tns:Attendee_City>New York</tns:Attendee_City>\n' +
                                '			<tns:Attendee_State>41</tns:Attendee_State>\n' +
                                '			<tns:Attendee_Zip_Code>10005</tns:Attendee_Zip_Code>\n' +
                                '			<tns:Attendee_Rural_Area>2</tns:Attendee_Rural_Area>\n' +
                                '			<tns:Attendee_Limited_English_Proficiency>2</tns:Attendee_Limited_English_Proficiency>\n' +
                                '			<tns:Attendee_Race_ID>16</tns:Attendee_Race_ID>\n' +
                                '			<tns:Attendee_Ethnicity_ID>3</tns:Attendee_Ethnicity_ID>\n' +
                                '		</tns:Attendee>\n' +
                                '	</tns:Attendees>\n' +
                                '</tns:SubmissionData>\n';
*/
        Map<String, Integer> identifierToLineNum = new Map<String, Integer>();
        Set<String> identifiers = new Set<String>();
        String identifier;
        for (Integer lineNumber: errorLineNumberToMsg.keySet()) {
            identifier = HUD9902ErrorUtility.getIdentifierTagValueAtLine(HUD9902ErrorUtility.readContentVersion(x9902Rec.Id, '9902_Summary%'), lineNumber);
            if (identifier != null) {
                identifiers.add(identifier);
            }
            identifierToLineNum.put(identifier, lineNumber);
        }
        if (identifiers.isEmpty())  return;
        System.debug('identifiers:: ' + JSON.serializePretty(identifiers));
        List<sumoapp__Attendee__c> attendeeRecs = HUD9902ErrorUtility.getSourceAttendeeRecs(identifiers);
        Map<String, Id> result = HUD9902ErrorUtility.matchStringsToSObjects(identifiers, attendeeRecs, 'sumoapp__ContactRelation__r.Client__c');
        Id recId;
        List<HUD9902ErrorLog__c> errLogs = new List<HUD9902ErrorLog__c>();
        for (String ident: result.keySet()) {
            recId = result.get(ident);
            errLogs.add(HUD9902ErrorUtility.createErrorRecord(x9902Rec, recId, errorLineNumberToMsg.get(identifierToLineNum.get(ident)), '9902 Summary'));
            System.debug(ident + '  :  ' + HUD9902ErrorUtility.generateRecordUrl(recId));
        }
        insert errLogs;
    }
}
// HUD9902ErrorUtilityTest.test();
// HUD9902ErrorUtilityTest.processErrorForSummary('a0tVa000006pYIUIA2');