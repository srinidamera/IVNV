public with sharing class HUD9902SummaryReportGenerateBatch implements Database.Batchable<SObject>, Database.Stateful {
    public DateTime qtrStartDateTime, qtrEndDateTime;
    public Date qtrStartDate, qtrEndDate;
    public String reportPeriod;
    public X9902__c x9902 = new X9902__c();
    private List<Id> successes = new List<Id>();
    private List<Id> failures = new List<Id>();
    Id fccRTId = Schema.SObjectType.ClientCase__c.getRecordTypeInfosByDeveloperName().get('FinancialCapabilityCounseling').getRecordTypeId();
    private final String queryString;
    @testVisible
    private static String result = '';
    @testVisible
    private Boolean throwError = false;
    Id reportId;                    // Salesforce Id
    private string NWC2NameSpace = Utility.getNwc2NameSpace();
    public HUD9902SummaryReportGenerateBatch(String reportRecordId) {
        
        queryString = 'SELECT Id, '+NWC2NameSpace+'PeriodStartDate__c, '+NWC2NameSpace+'PeriodEndDate__c FROM '+NWC2NameSpace+'X9902__c WHERE Id = \'' + reportRecordId +'\'';
        x9902 = [SELECT Id, PeriodStartDate__c, PeriodEndDate__c, Quarter__c FROM X9902__c WHERE Id = :reportRecordId];
        qtrStartDate = x9902.PeriodStartDate__c;
        qtrEndDate = x9902.PeriodEndDate__c;
        reportPeriod = x9902.Quarter__c;
      //  System.debug('queryString: ' + queryString);
        reportId = (Id)reportRecordId;

        List<X9902Summary__c> x9902Summary = [SELECT Id FROM X9902Summary__c WHERE X9902__c = :reportId LIMIT 10000];
        Database.delete(x9902Summary);
    }

    public Database.QueryLocator start(Database.BatchableContext context) {
        return Database.getQueryLocator(queryString);
    }

    public void execute(Database.BatchableContext context, List<X9902__c> scope) {
        generateSubmissionReport(scope);
    }

    public void finish(Database.BatchableContext context) {

    }

    public void generateSubmissionReport(List<X9902__c> scope){
        List<X9902Summary__c> summary9902ToInsert = new List<X9902Summary__c>();
        X9902Summary__c x9902Summary = new X9902Summary__c();
        List<Id> clientCaseIdList = new List<Id>();
        List<Event> eventList = new List<Event>();
        List<sumoapp__AdditionalInfo__c> courses = new List<sumoapp__AdditionalInfo__c>();
        Map<String, Integer> outcomeCountMap = new Map<String, Integer>();
        Map<String,x9902Categories__c> x9902CategoriesMap = HUD9902Helper.get9902CategoriesMap();
        Id primaryClientRTId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('PrimaryClient').getRecordTypeId();

        // Element Type: 9902 - Section 3-7 Calculation :: START
        Set<String> uniqueAppointmentClientPurposes = new Set<String>();
        Set<String> uniqueAttendanceClientPurposes = new Set<String>();
        Contact con = new Contact();
        Integer sec3HispanicCount = 0;
        Integer sec3NonHispanicCount = 0;
        Integer sec3ChoseNotToRespondCount = 0;
        Integer sec4AmericanIndianAlaskanNativeCount = 0;
        Integer sec4AsianCount = 0;
        Integer sec4BlackorAfricanAmericanCount = 0;
        Integer sec4NativeHawaiianCount = 0;
        Integer sec4WhiteCount = 0;
        Integer sec4ChoseNotToRespondCount = 0;
        Integer sec4MoreThanoneRaceCount = 0;

        Integer sec5LessThan30PofAMICount = 0;
        Integer sec5_30To49PofAMICount = 0;
        Integer sec5_50To79PofAMICount = 0;
        Integer sec5_80To100PofAMICount = 0;
        Integer sec5_MoreThan100PofAMICount = 0;
        Integer sec5ChoseNotToRespondCount = 0;

        Integer sec6HouseholdLivesinaRuralAreaCount = 0;
        Integer sec6HouseholdDoesNotLiveinaRuralAreaCount = 0;
        Integer sec6ChoseNotToRespondCount = 0;

        Integer sec7HouseholdisLimitedEnglishProficientCount = 0;
        Integer sec7NotLimitedEnglishProficientCount = 0;
        Integer sec7ChoseNotToRespondCount = 0;

        //Picklist Counts for HUD PDF
        Map<String, Integer> picklistToActivityCount = new Map<String, Integer> {
            'Hispanic' => 0,
            'Not Hispanic' => 0,
            'EthnicityOther' => 0,
            'American Indian/Alaskan Native' => 0,
            'Asian' => 0,
            'Black or African American' => 0,
            'Native Hawaiian or Other Pacific Islander' => 0,
            'More than one race' => 0,
            'White' => 0,
            'RaceOther' => 0,
            'Below 30% of AMI' => 0,
            '30 - 49% of AMI' => 0,
            '50 - 79% of AMI' => 0,
            '80 - 100% of AMI' => 0,
            '101% - 120% of AMI' => 0,
            'AMIOther' => 0,
            'Lives in a rural area' => 0,
            'Does not live in a rural area' => 0,
            'RuralOther' => 0,
            'Limited English Proficient' => 0,
            'Not Limited English Proficient' => 0,
            'EnglishOther' => 0
        };
        //Count picklist values to fields map 
        
        //Fields for HUD PDF
        Map<String, String> picklistToFieldMap = new Map<String, String> {
            'Hispanic' => 'HUDHispanic__c',
            'Not Hispanic' => 'HUDNotHispanic__c',
            'EthnicityOther' => 'HUDChoseNottoRespond__c',
            'American Indian/Alaskan Native' => 'HUDAmericanIndianAlaskanNative__c',
            'Asian' => 'HUDAsian__c',
            'Black or African American' => 'HUDBlackorAfricanAmerican__c',
            'Native Hawaiian or Other Pacific Islander' => 'HUDNativeHawaiian__c',
            'More than one race' => 'HUDMoreThanoneRace__c',
            'White' => 'HUDWhite__c',
            'RaceOther' => 'HUDMultiRaceChosenottorespond__c',
            'Below 30% of AMI' => 'HUDX30ofAreaMedianIncomeAMI__c',
            '30 - 49% of AMI' => 'HUDX3049ofAMI__c',
            '50 - 79% of AMI' => 'HUDX5079ofAMI__c',
            '80 - 100% of AMI' => 'HUDX80100ofAMI__c',
            '101% - 120% of AMI' => 'HUDX100AMI__c',
            'AMIOther' => 'HUDAMIChosenottorespond__c',
            'Lives in a rural area' => 'HUDHouseholdlivesinaruralarea__c',
            'Does not live in a rural area' => 'HUDHouseholddoesnotliveinarural__c',
            'RuralOther' => 'HUDRuralChosenottorespond__c',
            'Limited English Proficient' => 'HUDHouseholdisLimitedEnglish__c',
            'Not Limited English Proficient' => 'HUDNotLimitedEnglishProficient__c',
            'EnglishOther' => 'HUDLimitedEnglishProficienChoseNotTo__c'
        };

        Integer newCount = 0;
        String WhatType = NWC2NameSpace + 'ClientCase__c';
        List<Event> appointmentList = [SELECT Id, WhatId, WhoId, Purpose__c, HUDActivityType__c,
        TYPEOF Who
            WHEN Contact THEN Ethnicity__c, Race__c, AreaMedianIncome__c,RuralAreaStatus__c,EnglishProficiency__c, RecordType.Name
        END
            FROM Event 
            // WHERE (What.Type = 'ClientCase__C' OR Who.Type = 'Contact')
            WHERE Who.Type = 'Contact'
            AND What.Type =: WhatType
            AND EndDateTime >= :qtrStartDate 
            AND EndDateTime <= :qtrEndDate
            AND AppointmentStatus__c = 'Attended'
            AND Who.RecordType.Name = 'Primary Client'
            AND Purpose__c NOT IN ('Not HUD-Reportable', null, '', NULL)
        ];
		System.debug(' qtrStartDate: ' + qtrStartDate + ' qtrEndDate: ' + qtrEndDate);
        for(Event ev : appointmentList){
            if(!uniqueAppointmentClientPurposes.contains(ev.WhoId+'-'+ev.Purpose__c)){
                uniqueAppointmentClientPurposes.add(ev.WhoId+'-'+ev.Purpose__c);
                if(ev.Who instanceof Contact){
                    con = ev.Who;
                    if(con.Ethnicity__c == 'Hispanic'){
                        sec3HispanicCount += 1;
                        updateCount(ev.HUDActivityType__c, con.Ethnicity__c,picklistToActivityCount);
                    }else if(con.Ethnicity__c == 'Not Hispanic'){
                        sec3NonHispanicCount += 1;
                        updateCount(ev.HUDActivityType__c, con.Ethnicity__c,picklistToActivityCount);
                    }else{
                        sec3ChoseNotToRespondCount += 1;
                        updateCount(ev.HUDActivityType__c, 'EthnicityOther',picklistToActivityCount);
                    }

                    if(con.Race__c == 'American Indian/Alaskan Native'){
                        sec4AmericanIndianAlaskanNativeCount +=1;
                        updateCount(ev.HUDActivityType__c, con.Race__c,picklistToActivityCount);
                    }else if(con.Race__c == 'Asian'){
                        updateCount(ev.HUDActivityType__c, con.Race__c,picklistToActivityCount);
                        sec4AsianCount +=1;
                    }else if(con.Race__c == 'Black or African American'){
                        updateCount(ev.HUDActivityType__c, con.Race__c,picklistToActivityCount);
                        sec4BlackorAfricanAmericanCount +=1;
                    }else if(con.Race__c == 'Native Hawaiian or Other Pacific Islander'){
                        updateCount(ev.HUDActivityType__c, con.Race__c,picklistToActivityCount);
                        sec4NativeHawaiianCount +=1;
                    }else if(con.Race__c == 'White'){
                        updateCount(ev.HUDActivityType__c, con.Race__c,picklistToActivityCount);
                        sec4WhiteCount +=1;
                    }else if(con.Race__c == 'More than one race'){
                        updateCount(ev.HUDActivityType__c, con.Race__c,picklistToActivityCount);
                        sec4MoreThanoneRaceCount +=1;
                    }else {
                        updateCount(ev.HUDActivityType__c, 'RaceOther',picklistToActivityCount);
                        sec4ChoseNotToRespondCount +=1;
                    }

                    if(con.AreaMedianIncome__c == 'Below 30% of AMI'){
                        updateCount(ev.HUDActivityType__c, con.AreaMedianIncome__c,picklistToActivityCount);
                        sec5LessThan30PofAMICount += 1; 
                    }else if(con.AreaMedianIncome__c == '30 - 49% of AMI'){
                        updateCount(ev.HUDActivityType__c, con.AreaMedianIncome__c,picklistToActivityCount);
                        sec5_30To49PofAMICount += 1;
                    }else if(con.AreaMedianIncome__c == '50 - 79% of AMI'){
                        updateCount(ev.HUDActivityType__c, con.AreaMedianIncome__c,picklistToActivityCount);
                        sec5_50To79PofAMICount += 1;
                    }else if(con.AreaMedianIncome__c == '80 - 100% of AMI'){
                        updateCount(ev.HUDActivityType__c, con.AreaMedianIncome__c,picklistToActivityCount);
                        sec5_80To100PofAMICount += 1;
                    }else if(con.AreaMedianIncome__c == '101% - 120% of AMI' || con.AreaMedianIncome__c == 'Above 120% of AMI'){
                        updateCount(ev.HUDActivityType__c, '101% - 120% of AMI',picklistToActivityCount);
                        sec5_MoreThan100PofAMICount += 1;
                    }else{
                        updateCount(ev.HUDActivityType__c, 'AMIOther',picklistToActivityCount);
                        sec5ChoseNotToRespondCount += 1;
                    }

                    if(con.RuralAreaStatus__c == 'Lives in a rural area'){
                        updateCount(ev.HUDActivityType__c, con.RuralAreaStatus__c,picklistToActivityCount);
                        sec6HouseholdLivesinaRuralAreaCount += 1; 
                    }else if(con.RuralAreaStatus__c == 'Does not live in a rural area'){
                        updateCount(ev.HUDActivityType__c, con.RuralAreaStatus__c,picklistToActivityCount);
                        sec6HouseholdDoesNotLiveinaRuralAreaCount += 1;
                    }else{
                        updateCount(ev.HUDActivityType__c, 'RuralOther',picklistToActivityCount);
                        sec6ChoseNotToRespondCount += 1;
                    }

                    if(con.EnglishProficiency__c == 'Limited English Proficient'){
                        updateCount(ev.HUDActivityType__c, con.EnglishProficiency__c,picklistToActivityCount);
                        sec7HouseholdisLimitedEnglishProficientCount += 1; 
                    }else if(con.EnglishProficiency__c == 'Not Limited English Proficient'){
                        updateCount(ev.HUDActivityType__c, con.EnglishProficiency__c,picklistToActivityCount);
                        sec7NotLimitedEnglishProficientCount += 1;
                    }else{
                        sec7ChoseNotToRespondCount += 1;
                        updateCount(ev.HUDActivityType__c, 'EnglishOther',picklistToActivityCount);
                    }
                }
            }
        }

        List<sumoapp__Attendee__c> attendeeList = [SELECT Id, Race__c, Ethnicity__c, AreaMedianIncome__c, 
                RuralAreaStatus__c, EnglishProficiency__c, sumoapp__SumoEvent__r.HUD_Purpose__c,
                sumoapp__ContactRelation__c, sumoapp__SumoEvent__r.HUDActivityType__c
            FROM sumoapp__Attendee__c
            WHERE sumoapp__SumoEvent__r.RecordType.Name IN ('Course', 'Event')
            AND sumoapp__SumoEvent__r.IsParent__c = true
            AND Attendance_Status__c IN ('Course Complete', 'Attended - Complete')
            AND sumoapp__ContactRelation__r.RecordType.Name = 'Primary Client'
            AND sumoapp__SumoEvent__r.sumoapp__EndDatetime__c >= :qtrStartDate
            AND sumoapp__SumoEvent__r.sumoapp__EndDatetime__c <= :qtrEndDate
            AND sumoapp__SumoEvent__r.HUD_Purpose__c NOT IN (null, '', NULL)
            AND ExcludeAttendeeFromHUD9902__c = False
            AND sumoapp__SumoEvent__r.sumoapp__Status__c != 'CANCELED' 
        ];        
        for(sumoapp__Attendee__c att : attendeeList){
            if(!uniqueAttendanceClientPurposes.contains(att.sumoapp__ContactRelation__c+'-'+att.sumoapp__SumoEvent__r.HUD_Purpose__c)){
                uniqueAttendanceClientPurposes.add(att.sumoapp__ContactRelation__c+'-'+att.sumoapp__SumoEvent__r.HUD_Purpose__c);
                if(att.Ethnicity__c == 'Hispanic'){
                    updateCount(att.sumoapp__SumoEvent__r.HUDActivityType__c, att.Ethnicity__c, picklistToActivityCount);
                    sec3HispanicCount += 1; 
                }else if(att.Ethnicity__c == 'Not Hispanic'){
                    updateCount(att.sumoapp__SumoEvent__r.HUDActivityType__c, att.Ethnicity__c, picklistToActivityCount);
                    sec3NonHispanicCount += 1;
                }else{
                    updateCount(att.sumoapp__SumoEvent__r.HUDActivityType__c, 'EthnicityOther', picklistToActivityCount);
                    sec3ChoseNotToRespondCount += 1;
                }

                if(att.Race__c == 'American Indian/Alaskan Native'){
                    updateCount(att.sumoapp__SumoEvent__r.HUDActivityType__c, att.Race__c, picklistToActivityCount);
                    sec4AmericanIndianAlaskanNativeCount +=1;
                }else if(att.Race__c == 'Asian'){
                    updateCount(att.sumoapp__SumoEvent__r.HUDActivityType__c, att.Race__c, picklistToActivityCount);
                    sec4AsianCount +=1;
                }else if(att.Race__c == 'Black or African American'){
                    updateCount(att.sumoapp__SumoEvent__r.HUDActivityType__c, att.Race__c, picklistToActivityCount);
                    sec4BlackorAfricanAmericanCount +=1;
                }else if(att.Race__c == 'Native Hawaiian or Other Pacific Islander'){
                    updateCount(att.sumoapp__SumoEvent__r.HUDActivityType__c, att.Race__c, picklistToActivityCount);
                    sec4NativeHawaiianCount +=1;
                }else if(att.Race__c == 'White'){
                    updateCount(att.sumoapp__SumoEvent__r.HUDActivityType__c, att.Race__c, picklistToActivityCount);
                    sec4WhiteCount +=1;
                }else if(att.Race__c == 'More than one race'){
                    updateCount(att.sumoapp__SumoEvent__r.HUDActivityType__c, att.Race__c, picklistToActivityCount);
                    sec4MoreThanoneRaceCount +=1;
                }else {
                    updateCount(att.sumoapp__SumoEvent__r.HUDActivityType__c, 'RaceOther', picklistToActivityCount);
                    sec4ChoseNotToRespondCount +=1;
                }

                if(att.AreaMedianIncome__c == 'Below 30% of AMI'){
                    updateCount(att.sumoapp__SumoEvent__r.HUDActivityType__c, att.AreaMedianIncome__c, picklistToActivityCount);
                    sec5LessThan30PofAMICount += 1; 
                }else if(att.AreaMedianIncome__c == '30 - 49% of AMI'){
                    updateCount(att.sumoapp__SumoEvent__r.HUDActivityType__c, att.AreaMedianIncome__c, picklistToActivityCount);
                    sec5_30To49PofAMICount += 1;
                }else if(att.AreaMedianIncome__c == '50 - 79% of AMI'){
                    updateCount(att.sumoapp__SumoEvent__r.HUDActivityType__c, att.AreaMedianIncome__c, picklistToActivityCount);
                    sec5_50To79PofAMICount += 1;
                }else if(att.AreaMedianIncome__c == '80 - 100% of AMI'){
                    updateCount(att.sumoapp__SumoEvent__r.HUDActivityType__c, att.AreaMedianIncome__c, picklistToActivityCount);
                    sec5_80To100PofAMICount += 1;
                }else if(att.AreaMedianIncome__c == '101% - 120% of AMI' || att.AreaMedianIncome__c == 'Above 120% of AMI'){
                    updateCount(att.sumoapp__SumoEvent__r.HUDActivityType__c, '101% - 120% of AMI', picklistToActivityCount);
                    sec5_MoreThan100PofAMICount += 1;
                }else{
                    updateCount(att.sumoapp__SumoEvent__r.HUDActivityType__c, 'AMIOther', picklistToActivityCount);
                    sec5ChoseNotToRespondCount += 1;
                }

                if(att.RuralAreaStatus__c == 'Lives in a rural area'){
                    updateCount(att.sumoapp__SumoEvent__r.HUDActivityType__c, att.RuralAreaStatus__c, picklistToActivityCount);
                    sec6HouseholdLivesinaRuralAreaCount += 1; 
                }else if(att.RuralAreaStatus__c == 'Does not live in a rural area'){
                    updateCount(att.sumoapp__SumoEvent__r.HUDActivityType__c, att.RuralAreaStatus__c, picklistToActivityCount);
                    sec6HouseholdDoesNotLiveinaRuralAreaCount += 1;
                }else{
                    updateCount(att.sumoapp__SumoEvent__r.HUDActivityType__c, 'RuralOther', picklistToActivityCount);
                    sec6ChoseNotToRespondCount += 1;
                }

                if(att.EnglishProficiency__c == 'Limited English Proficient'){
                    updateCount(att.sumoapp__SumoEvent__r.HUDActivityType__c, att.EnglishProficiency__c, picklistToActivityCount);
                    sec7HouseholdisLimitedEnglishProficientCount += 1; 
                }else if(att.EnglishProficiency__c == 'Not Limited English Proficient'){
                    updateCount(att.sumoapp__SumoEvent__r.HUDActivityType__c, att.EnglishProficiency__c, picklistToActivityCount);
                    sec7NotLimitedEnglishProficientCount += 1;
                }else{
                    updateCount(att.sumoapp__SumoEvent__r.HUDActivityType__c, 'EnglishOther', picklistToActivityCount);
                    sec7ChoseNotToRespondCount += 1;
                }
            }
        }


        x9902Summary.Hispanic__c = sec3HispanicCount;
        x9902Summary.NotHispanic__c = sec3NonHispanicCount;
        x9902Summary.ChoseNottoRespond__c = sec3ChoseNotToRespondCount;

        x9902Summary.AmericanIndianAlaskanNative__c = sec4AmericanIndianAlaskanNativeCount;
        x9902Summary.Asian__c = sec4AsianCount;
        x9902Summary.BlackorAfricanAmerican__c = sec4BlackorAfricanAmericanCount;
        x9902Summary.NativeHawaiian__c = sec4NativeHawaiianCount;
        x9902Summary.White__c = sec4WhiteCount;
        x9902Summary.MoreThanoneRace__c = sec4MoreThanoneRaceCount;
        x9902Summary.MultiRaceChosenottorespond__c = sec4ChoseNotToRespondCount;

        x9902Summary.X30ofAreaMedianIncomeAMI__c = sec5LessThan30PofAMICount;
        x9902Summary.X3049ofAMI__c = sec5_30To49PofAMICount;
        x9902Summary.X5079ofAMI__c = sec5_50To79PofAMICount;
        x9902Summary.X80100ofAMI__c = sec5_80To100PofAMICount;
        x9902Summary.X100AMI__c = sec5_MoreThan100PofAMICount;
        x9902Summary.AMIChosenottorespond__c = sec5ChoseNotToRespondCount;

        x9902Summary.Householdlivesinaruralarea__c = sec6HouseholdLivesinaRuralAreaCount;
        x9902Summary.Householddoesnotliveinaruralarea__c = sec6HouseholdDoesNotLiveinaRuralAreaCount;
        x9902Summary.RuralChosenottorespond__c = sec6ChoseNotToRespondCount;

        x9902Summary.HouseholdisLimitedEnglishProficient__c = sec7HouseholdisLimitedEnglishProficientCount;
        x9902Summary.NotLimitedEnglishProficient__c = sec7NotLimitedEnglishProficientCount;
        x9902Summary.LimitedEnglishProficienChoseNotToRespond__c = sec7ChoseNotToRespondCount;
        
        for(String picklistValue : picklistToFieldMap.keySet()){
            x9902Summary.put(picklistToFieldMap.get(picklistValue), picklistToActivityCount.get(picklistValue));
        }

      //  System.debug('Section- Required Params:: qtrStartDate:: ' + qtrStartDate);
      //  System.debug('Section- Required Params:: qtrEndDate:: ' + qtrEndDate);
      //  System.debug('Section- Required Params:: fccRTId:: ' + fccRTId);
        // System.debug('Section- Required Params:: :: ' + );
        List<ClientCase__c> clientCaseList = [SELECT Id 
            FROM ClientCase__c 
            WHERE IntakeDate__c <=: qtrEndDate 
            AND IntakeDate__c >=: qtrStartDate 
            AND RecordTypeId != :fccRTId
        ];
      //  System.debug('Section- Required Params:: clientCaseList:: ' + clientCaseList);

        for(ClientCase__c cc : clientCaseList){
            clientCaseIdList.add(cc.Id);
        }

        Map<String, Integer> hudPurposeToAttendeeCount = new Map<String, Integer> {
            'Completed financial literacy workshop, including home affordability, budgeting and understanding use of credit' => 0,
            'Completed predatory lending, loan scam or other fraud prevention workshop' => 0,
            'Completed fair housing workshop' => 0,
            'Completed homelessness prevention workshop' => 0,
            'Completed rental workshop' => 0,
            'Completed pre-purchase homebuyer education workshop' => 0,
            'Completed non-delinquency post-purchase workshop, including home maintenance and/or financial management for homeowners' => 0,
            'Completed resolving or preventing mortgage delinquency workshop' => 0,
            'Completed disaster preparedness assistance workshop' => 0,
            'Completed disaster recovery assistance workshop' => 0
        };
        Map<String, Integer> hudPurposeToHUDSec8Count = new Map<String, Integer> {
            'Completed financial literacy workshop, including home affordability, budgeting and understanding use of credit' => 0,
            'Completed predatory lending, loan scam or other fraud prevention workshop' => 0,
            'Completed fair housing workshop' => 0,
            'Completed homelessness prevention workshop' => 0,
            'Completed rental workshop' => 0,
            'Completed pre-purchase homebuyer education workshop' => 0,
            'Completed non-delinquency post-purchase workshop, including home maintenance and/or financial management for homeowners' => 0,
            'Completed resolving or preventing mortgage delinquency workshop' => 0,
            'Completed disaster preparedness assistance workshop' => 0,
            'Completed disaster recovery assistance workshop' => 0
        };
        Integer count = 0;
        String key;
        // for(AggregateResult ar : hudpResult) {
        //     if (ar.get('HUDP') != null) {
        //         key = (String)ar.get('HUDP');
        //         System.debug('Section-8:: key:: ' + key);
        //         count = hudPurposeToAttendeeCount.get(key) + 1;
        //         System.debug('Section-8:: count:: ' + count);
        //         hudPurposeToAttendeeCount.put(key, count);
        //     }
        // }
        Set<String> uniqueContactPurpose = new Set<String>();
        System.debug('attendeeList->'+attendeeList.size());
        for(sumoapp__Attendee__c att : attendeeList) {
            if (att.sumoapp__SumoEvent__r?.HUD_Purpose__c != null) {
                System.debug('uniqueContactPurpose.contains(att.sumoapp__ContactRelation__c+att.sumoapp__SumoEvent__r.HUD_Purpose__c)->'+uniqueContactPurpose.contains(att.sumoapp__ContactRelation__c+'-'+att.sumoapp__SumoEvent__r.HUD_Purpose__c));
                
                if (!uniqueContactPurpose.contains(att.sumoapp__ContactRelation__c+'-'+att.sumoapp__SumoEvent__r.HUD_Purpose__c)) {
                    System.debug('uniqueContactPurpose->'+uniqueContactPurpose.size());
                    uniqueContactPurpose.add(att.sumoapp__ContactRelation__c+'-'+att.sumoapp__SumoEvent__r.HUD_Purpose__c);
                    key = att.sumoapp__SumoEvent__r.HUD_Purpose__c;
                    count = hudPurposeToAttendeeCount.get(key) + 1;
                    hudPurposeToAttendeeCount.put(key, count);
                    updateCount(att.sumoapp__SumoEvent__r.HUDActivityType__c, key, hudPurposeToHUDSec8Count);
                }   
            }
        }
        System.debug('hudPurposeToAttendeeCount->'+hudPurposeToAttendeeCount);
      //  System.debug('Section-8:: hudPurposeToAttendeeCount-SIZE:: ' + hudPurposeToAttendeeCount.size());
      //  System.debug('Section-8:: hudPurposeToAttendeeCount:: ' + JSON.serialize(hudPurposeToAttendeeCount));
        Map<String, String> hudPurposeToField = new Map<String, String> {
            'Completed financial literacy workshop, including home affordability, budgeting and understanding use of credit' => 'Completedfinancialliteracyworkshop__c',
            'Completed predatory lending, loan scam or other fraud prevention workshop' => 'Completedpredatorylending__c',
            'Completed fair housing workshop' => 'Completedfairhousingworkshop__c',
            'Completed homelessness prevention workshop' => 'HomelessnessPreventionWorkshop__c',
            'Completed rental workshop' => 'Completedrentalworkshop__c',
            'Completed pre-purchase homebuyer education workshop' => 'Prepurchasehomebuyereducationworkshop__c',
            'Completed non-delinquency post-purchase workshop, including home maintenance and/or financial management for homeowners' => 'NonDelinquencyPostPurchaseWorkshop__c',
            'Completed resolving or preventing mortgage delinquency workshop' => 'MortgageDelinquencyWorkshop__c',
            'Completed disaster preparedness assistance workshop' => 'CompletedDisasterPreparednessWorkshop__c',
            'Completed disaster recovery assistance workshop' => 'DisasterRecoveryWorkshop__c'
        };

        Map<String, String> hudPurposeToHUDFieldMap = new Map<String, String> {
            'Completed financial literacy workshop, including home affordability, budgeting and understanding use of credit' => 'HUDCompletedfinancialliteracy__c',
            'Completed predatory lending, loan scam or other fraud prevention workshop' => 'HUDCompletedpredatorylending__c',
            'Completed fair housing workshop' => 'HUDCompletedfairhousingworkshop__c',
            'Completed homelessness prevention workshop' => 'HUDHomelessnessPreventionWorkshop__c',
            'Completed rental workshop' => 'HUDCompletedrentalworkshop__c',
            'Completed pre-purchase homebuyer education workshop' => 'HUDPrepurchasehomebuyereducation__c',
            'Completed non-delinquency post-purchase workshop, including home maintenance and/or financial management for homeowners' => 'HUDNonDelinquencyPostPurchaseWork__c',
            'Completed resolving or preventing mortgage delinquency workshop' => 'HUDMortgageDelinquencyWorkshop__c',
            'Completed disaster preparedness assistance workshop' => 'HUDCompletedDisasterPreparedness__c',
            'Completed disaster recovery assistance workshop' => 'HUDDisasterRecoveryWorkshop__c'
        };
        for(String purpose: hudPurposeToHUDFieldMap.keySet()) {
            x9902Summary.put(hudPurposeToHUDFieldMap.get(purpose), hudPurposeToHUDSec8Count.get(purpose));
        }

        for(String purpose: hudPurposeToField.keySet()) {
            x9902Summary.put(hudPurposeToField.get(purpose), hudPurposeToAttendeeCount.get(purpose));
        }

        // Section-9 : Households Receiving One-on-One Counseling, by Purpose 
        // AggregateResult[] eventPurposeResult =  [SELECT 
        //                                             Purpose__c purpose 
        //                                             FROM Event 
        //                                             WHERE Who.RecordTypeId = :primaryClientRTId
        //                                             AND EndDateTime >= :qtrStartDate 
        //                                             AND EndDateTime <= :qtrEndDate
        //                                             AND AppointmentStatus__c = 'Attended'
        //                                             AND Purpose__c != 'Not HUD-Reportable'
        //                                             AND Who.Type = 'Contact'
        //                                             AND What.Type = 'ClientCase__C'
        //                                             // AND (Who.Type = 'Contact' OR What.Type = 'ClientCase__C')
        //                                             GROUP BY WhoId, Purpose__c
        //                                         ];
        // System.debug('Section-9:: eventPurposeResult:: ' + JSON.serialize(eventPurposeResult));
        Map<String, Integer> eventPurposeToAttendeeCount = new Map<String, Integer> {
            'Homeless Assistance' => 0,
            'Rental Topics' => 0,
            'Pre-purchase/Homebuying' => 0,
            'Home Maintenance' => 0,
            'Reverse Mortgage' => 0,
            'Non-Delinquency Post-Purchase' => 0,
            'Resolving or Preventing Forward Mortgage Delinquency or Default' => 0,
            'Resolving or Preventing Reverse Mortgage Delinquency or Default' => 0,
            'Disaster Preparedness Assistance' => 0,
            'Disaster Recovery Assistance' => 0
        };
        Map<String, Integer> eventPurposeToHUDSec9Count = new Map<String, Integer> {
            'Homeless Assistance' => 0,
            'Rental Topics' => 0,
            'Pre-purchase/Homebuying' => 0,
            'Home Maintenance' => 0,
            'Reverse Mortgage' => 0,
            'Non-Delinquency Post-Purchase' => 0,
            'Resolving or Preventing Forward Mortgage Delinquency or Default' => 0,
            'Resolving or Preventing Reverse Mortgage Delinquency or Default' => 0,
            'Disaster Preparedness Assistance' => 0,
            'Disaster Recovery Assistance' => 0
        };
        Map<String, String> eventPurposeToSummaryField = new Map<String, String> {
            'Homeless Assistance' => 'HomelessAssistance__c',
            'Rental Topics' => 'RentalTopics__c',
            'Pre-purchase/Homebuying' => 'PrepurchaseHomebuying__c',
            'Reverse Mortgage' => 'ReverseMortgage__c',
            'Non-Delinquency Post-Purchase' => 'HomeMaintenance__c',
            'Resolving or Preventing Forward Mortgage Delinquency or Default' => 'ForwardMortgageDelinquencyorDefault__c',
            'Resolving or Preventing Reverse Mortgage Delinquency or Default' => 'ReverseMortgageDelinquencyorDefault__c',
            'Disaster Preparedness Assistance' => 'DisasterPreparednessAssistance__c',
            'Disaster Recovery Assistance' => 'DisasterRecoveryAssistance__c'
        };
        Map<String, String> eventPurposeToHUDSec9Fields = new Map<String, String> {
            'Homeless Assistance' => 'HUDHomelessAssistance__c',
            'Rental Topics' => 'HUDRentalTopics__c',
            'Pre-purchase/Homebuying' => 'HUDPrepurchaseHomebuying__c',
            'Reverse Mortgage' => 'HUDReverseMortgage__c',
            'Non-Delinquency Post-Purchase' => 'HUDHomeMaintenance__c',
            'Resolving or Preventing Forward Mortgage Delinquency or Default' => 'HUDForwardMortgageDelinquencyor__c',
            'Resolving or Preventing Reverse Mortgage Delinquency or Default' => 'HUDReverseMortgageDelinquencyor__c',
            'Disaster Preparedness Assistance' => 'HUDDisasterPreparednessAssistance__c',
            'Disaster Recovery Assistance' => 'HUDDisasterRecoveryAssistance__c'
        };
        // for(AggregateResult ar : eventPurposeResult){
        //     if (ar.get('purpose') != null) {
        //         key = (String)ar.get('purpose');
        //         count = eventPurposeToAttendeeCount.get(key) + 1;
        //         eventPurposeToAttendeeCount.put(key, count);
        //     }
        // }
        uniqueAppointmentClientPurposes = new Set<String>();
        for(Event ev : appointmentList){
            if(String.isNotBlank(ev.Purpose__c)) {
                if(!uniqueAppointmentClientPurposes.contains(ev.WhoId+'-'+ev.Purpose__c)){
                    uniqueAppointmentClientPurposes.add(ev.WhoId+'-'+ev.Purpose__c);
                    key = ev.Purpose__c;
                    count = eventPurposeToAttendeeCount.get(key) + 1;
                    eventPurposeToAttendeeCount.put(key, count);
                    updateCount(ev.HUDActivityType__c, key, eventPurposeToHUDSec9Count);
                }
            }
        }
     //   System.debug('Section-9:: eventPurposeToAttendeeCount-SIZE:: ' + eventPurposeToAttendeeCount.size());
       // System.debug('Section-9:: eventPurposeToAttendeeCount:: ' + JSON.serialize(eventPurposeToAttendeeCount));
        for(String purpose : eventPurposeToSummaryField.keySet()){
            x9902Summary.put(eventPurposeToSummaryField.get(purpose), eventPurposeToAttendeeCount.get(purpose));
        }
        for(String purpose: eventPurposeToHUDSec9Fields.keySet()) {
            x9902Summary.put(eventPurposeToHUDSec9Fields.get(purpose), eventPurposeToHUDSec9Count.get(purpose));
        }

        /* Section-10 : Impact and Scope of One-on-One Counseling Service */
        //First error: field 'Outcome__c' can not be grouped in a query call	
        eventList = [ SELECT WhoId, WhatId, Outcome__c, Purpose__c, HUDActivityType__c
                        FROM Event 
                        WHERE EndDateTime >= :qtrStartDate 
                        AND EndDateTime <= :qtrEndDate
                        AND Who.RecordTypeId = :primaryClientRTId
                        AND AppointmentStatus__c = 'Attended'
                        AND Purpose__c != 'Not HUD-Reportable'
                        AND Who.Type = 'Contact'
                        AND What.Type =: WhatType
                        // AND (Who.Type = 'Contact' OR What.Type = 'ClientCase__C')
                    ];
        Set<Id> clientCasesIds = new Set<Id>();
        for(Event evnt: eventList) {
            clientCasesIds.add(evnt.WhatId);
        }
        List<Event> eventList2 = [ SELECT WhoId, WhatId, Outcome__c, Purpose__c, HUDActivityType__c
                                    FROM Event 
                                    WHERE EndDateTime < :qtrStartDate
                                    AND Who.RecordTypeId = :primaryClientRTId
                                    AND WhatId IN :clientCasesIds
                                    AND Who.Type = 'Contact'
                                    AND What.Type =: WhatType
                                ];
        if(!eventList2.isEmpty()) {
            eventList.addAll(eventList2);
        }
        Map<String, String> eventOutcomeToSummaryField = new Map<String, String> {
            'Households that received one-on-one counseling that also received education services.' => 'OneononeCounseling__c',
            'Households that received information on fair housing, fair lending and/or accessibility rights.' => 'ReceivedInformationonFairHousing__c',
            'Households for whom counselor developed a budget customized to a client’s current situation.' => 'SustainableHouseholdBudget__c',
            'Households that improved their financial capacity (e.g. increased discretionary income, decreased debt load, increased savings, increased credit score, etc.) after receiving Housing Counseling Services.' => 'HouseholdsImprovedFinancialCapacity__c',
            'Households that gained access to resources to help improve their housing situation (e.g. down payment assistance, rental assistance, utility assistance, etc.) after receiving Housing Counseling Services.' => 'HouseholdsGainedAccesstoResources__c',
            'Households that gained access to non-housing resources (e.g. social service programs, legal services, public benefits such as Social Security or Medicaid, etc.) after receiving Housing Counseling Services' => 'GainedAccesstoNonHousingResources__c',
            'Homeless or potentially homeless households that obtained temporary or permanent housing after receiving Housing Counseling Services.' => 'HomelessobtainedHousing__c',
            'Households gained access to disaster recovery non-housing h . resources after receiving Housing Counseling Services (e.g. Red Cross/FEMA relief items, legal services, assistance).' => 'DisasterRecoveryNonhousingResources__c',
            'Households obtained disaster recovery housing resources after receiving Housing Counseling Services (e.g. temporary shelter, homeowner rehab, relocation, etc.).' => 'DisasterRecoveryHousingResources__c',
            'Households for whom counselor developed or updated an emergency preparedness plan.' => 'EmergencyPreparednessPlan__c',
            'Household that received rental counseling and avoided eviction after receiving Housing Counseling Services.' => 'HouseholdsReceivedRentalCounselling__c',
            'Households that received rental counseling and improved living conditions after receiving Housing Counseling Services.' => 'HouseholdsImprovedLivingConditions__c',
            'Households that received pre-purchase/homebuying counseling and purchased housing after receiving Housing Counseling Services.' => 'PrepurchaseHomebuyingCounseling__c',
            'Households that received reverse mortgage counseling and obtained a Home Equity Conversion Mortgage (HECM) after receiving Housing Counseling Services.' => 'HouseholdsReceivedReverseMortgage__c',
            'Households that received non-delinquency post-purchase counseling that were able to improve home conditions or home affordability after receiving Housing Counseling Services' => 'NonDelinquencyPostPurchaseCounseling__c',
            'Households that prevented or resolved a forward mortgage default after receiving Housing Counseling Services.' => 'PreventedForwardMortgageDefault__c',
            'Households that prevented or resolved a reverse mortgage default after receiving Housing Counseling Services.' => 'PreventedReverseMortgageDefault__c',
            'Households that received a forward mortgage modification and remained current in their modified mortgage after receiving Housing Counseling Services.' => 'ForwardMortgageModImprovedFinancials__c',
            'Households that received a forward mortgage modification and improved their financial capacity after receiving Housing counseling Services.' => 'ForwardModImprovedFinancialCapacity__c'
        };
        
        Map<String, String> eventOutcomeToHUDSec10FieldsMap = new Map<String, String> {
            'Households that received one-on-one counseling that also received education services.' => 'HUDOneononeCounseling__c',
            'Households that received information on fair housing, fair lending and/or accessibility rights.' => 'HUDReceivedInformationonFair__c',
            'Households for whom counselor developed a budget customized to a client’s current situation.' => 'HUDSustainableHouseholdBudget__c',
            'Households that improved their financial capacity (e.g. increased discretionary income, decreased debt load, increased savings, increased credit score, etc.) after receiving Housing Counseling Services.' => 'HUDHouseholdsImprovedFinancial__c',
            'Households that gained access to resources to help improve their housing situation (e.g. down payment assistance, rental assistance, utility assistance, etc.) after receiving Housing Counseling Services.' => 'HUDHouseholdsGainedAccessto__c',
            'Households that gained access to non-housing resources (e.g. social service programs, legal services, public benefits such as Social Security or Medicaid, etc.) after receiving Housing Counseling Services' => 'HUDGainedAccesstoNonHousing__c',
            'Homeless or potentially homeless households that obtained temporary or permanent housing after receiving Housing Counseling Services.' => 'HUDHomelessobtainedHousing__c',
            'Households gained access to disaster recovery non-housing h . resources after receiving Housing Counseling Services (e.g. Red Cross/FEMA relief items, legal services, assistance).' => 'HUDDisasterRecoveryNonhousing__c',
            'Households obtained disaster recovery housing resources after receiving Housing Counseling Services (e.g. temporary shelter, homeowner rehab, relocation, etc.).' => 'HUDDisasterRecoveryHousingResources__c',
            'Households for whom counselor developed or updated an emergency preparedness plan.' => 'HUDEmergencyPreparednessPlan__c',
            'Household that received rental counseling and avoided eviction after receiving Housing Counseling Services.' => 'HUDHouseholdsReceivedRental__c',
            'Households that received rental counseling and improved living conditions after receiving Housing Counseling Services.' => 'HUDHouseholdsImprovedLiving__c',
            'Households that received pre-purchase/homebuying counseling and purchased housing after receiving Housing Counseling Services.' => 'HUDPrepurchaseHomebuyingCounseling__c',
            'Households that received reverse mortgage counseling and obtained a Home Equity Conversion Mortgage (HECM) after receiving Housing Counseling Services.' => 'HUDHouseholdsReceivedReverseMortgage__c',
            'Households that received non-delinquency post-purchase counseling that were able to improve home conditions or home affordability after receiving Housing Counseling Services' => 'HUDNonDelinquencyPostPurchaseCoun__c',
            'Households that prevented or resolved a forward mortgage default after receiving Housing Counseling Services.' => 'HUDPreventedForwardMortgageDefault__c',
            'Households that prevented or resolved a reverse mortgage default after receiving Housing Counseling Services.' => 'HUDPreventedReverseMortgageDefault__c',
            'Households that received a forward mortgage modification and remained current in their modified mortgage after receiving Housing Counseling Services.' => 'HUDForwardMortgageModImproved__c',
            'Households that received a forward mortgage modification and improved their financial capacity after receiving Housing counseling Services.' => 'HUDForwardModImprovedFinancial__c'
        };

        outcomeCountMap = getOutcomeCountMap(eventList, false);
        if(outcomeCountMap != null){
            for(String outcome : outcomeCountMap.keySet()){
                if (eventOutcomeToSummaryField.containsKey(outcome)) {
                    x9902Summary.put(eventOutcomeToSummaryField.get(outcome), outcomeCountMap.get(outcome));
                }
            }
        }

        
        outcomeCountMap = getOutcomeCountMap(eventList, true);
        if(outcomeCountMap != null){
            for(String outcome : outcomeCountMap.keySet()){
                if (eventOutcomeToHUDSec10FieldsMap.containsKey(outcome)) {
                    x9902Summary.put(eventOutcomeToHUDSec10FieldsMap.get(outcome), outcomeCountMap.get(outcome));
                }
            }
        }

        List<X9902Summary__c> groupSessions = new List<X9902Summary__c>();
        List<X9902Summary__c> groupSessionAttendees = new List<X9902Summary__c>();
        List<X9902Summary__c> attendees = new List<X9902Summary__c>();
        Map<Id, sumoapp__AdditionalInfo__c> idToCourseMap = new Map<Id, sumoapp__AdditionalInfo__c>();

        Set<String> acceptableAttendeeStatus = new Set<String> { 'Course Complete', 'Attended - Complete' };
        Map<String, Set<Id>> attendeeClientNumberToCourseIds = new Map<String, Set<Id>>();
        Map<Id, String> courseIdToGroupSessionId = new Map<Id, String>();
        Map<String, sumoapp__Attendee__c> clientNumberToUniqueAttendees = new Map<String, sumoapp__Attendee__c>();
        Map<String, sumoapp__Attendee__c> clientCourseNumberToAttendees = new Map<String, sumoapp__Attendee__c>();
        Map<String, String> courseIdWithCousePurpose = new Map<String, String>();
        X9902Summary__c tempSummaryObj;
        
        /* Section-11 : Group Session */
        courses = [SELECT
                    Id,
                    RecordType.Name,
                    CourseNumber__c,
                    sumoapp__Organizer__r.CMSCounselorID__c,
                    sumoapp__Organizer__r.CounselorHUDID__c,
                    sumoapp__EventName__c,
                    sumoapp__StartDatetime__c,
                    Total_Duration_In_Minutes__c,
                    sumoapp__Duration__c ,
                    Session_Type__c,
                    Funder__r.HUDGrantType__c,
                    HUDActivityType__c,
                   	HUD_Purpose__c,
                    (SELECT 
                        Id,
                        Attendance_Status__c,
                        sumoapp__ContactRelation__r.Client__c,
                        CreatedBy.CounselorHUDID__c,
                        sumoapp__TotalPrice__c,
                        ReferralSource__c,
                        AreaMedianIncome__c,
                        MailingAddress__City__s,
                        MailingAddress__StateCode__s,
                        MailingAddress__PostalCode__s,
                        RuralAreaStatus__c,
                        X1stTimeHomeBuyer__c,
                        EnglishProficiency__c,
                        Race__c,
                        Ethnicity__c,
                        sumoapp__SumoEvent__c,
                     	sumoapp__SumoEvent__r.HUD_Purpose__c,
                        LastModifiedDate
                        FROM sumoapp__EventAttendees__r
                        WHERE sumoapp__ContactRelation__r.RecordtypeId =:primaryClientRTId
                     	AND Attendance_Status__c IN ('Attended - Complete', 'Course Complete')
                        AND ExcludeAttendeeFromHUD9902__c = False
                    )
                   FROM sumoapp__AdditionalInfo__c
                   WHERE IsParent__c = true
                   AND sumoapp__EndDatetime__c >=:qtrStartDate
                   AND sumoapp__EndDatetime__c <=:qtrEndDate
                   AND RecordType.Name IN ('Course', 'Event')
                   AND ExcludeCourseFromHUD9902__c = False
                   AND sumoapp__Status__c != 'CANCELED'
                   AND HUD_Purpose__c NOT IN ('', NULL)
                  ];
        for(sumoapp__AdditionalInfo__c course: courses) {
            // Prepare attendee info
            Boolean courseHasAttendedAttendee = false;
            for(sumoapp__Attendee__c attendee: course.sumoapp__EventAttendees__r) {
                // if(attendee.Attendance_Status__c == 'Course Complete' || attendee.Attendance_Status__c == 'Attended - Complete'){
                    courseHasAttendedAttendee = true;
                    break;
                // }
            }
            if(courseHasAttendedAttendee){
                tempSummaryObj = new X9902Summary__c();
                tempSummaryObj.ElementType__c = 'Group Session';
                tempSummaryObj.X9902__c = reportId;
                tempSummaryObj.ReportPeriodId__c = HUD9902Helper.getHudCategoryCode(HUD9902Helper.KEY_ReportPeriods, reportPeriod, x9902CategoriesMap);
                tempSummaryObj.Course__c = course.Id;
                tempSummaryObj.ActivityTypeID__c = HUD9902Helper.getHudCategoryCode(HUD9902Helper.KEY_ActivityTypes, course.HUDActivityType__c, x9902CategoriesMap);
                tempSummaryObj.GroupSessionID__c = course.CourseNumber__c;
                tempSummaryObj.GroupSessionCounselorID__c = course.sumoapp__Organizer__r?.CMSCounselorID__c;
                tempSummaryObj.GroupSessionCounselorHUDId__c = course.sumoapp__Organizer__r?.CounselorHUDID__c;
                tempSummaryObj.GroupSessionTitle__c = course.sumoapp__EventName__c;
                tempSummaryObj.GroupSessionDate__c = course.sumoapp__StartDatetime__c.date();
                if (course.RecordType.Name == 'Course') {   
                    tempSummaryObj.GroupSessionDuration__c = course.Total_Duration_In_Minutes__c;
                } else {
                    tempSummaryObj.GroupSessionDuration__c = course.sumoapp__Duration__c != null ? Integer.valueOf(course.sumoapp__Duration__c) : 0;
                }
                tempSummaryObj.GroupSessionType__c = HUD9902Helper.getHudCategoryCode(HUD9902Helper.KEY_SESSION_TYPES, course.Session_Type__c, x9902CategoriesMap);                                          // New Field Session_Type__c
                tempSummaryObj.GroupSessionAttributeHUD_Grant__c = course.Funder__r?.HUDGrantType__c != null ?
                                                                    HUD9902Helper.getHudCategoryCode(HUD9902Helper.KEY_HUDGrantTypes, course.Funder__r.HUDGrantType__c, x9902CategoriesMap) :
                                                                    HUD9902Helper.getHudCategoryCode(HUD9902Helper.KEY_HUDGrantTypes, 'N/A', x9902CategoriesMap);
            //    System.debug('DEBUGG:: ' + course.HUDActivityType__c);
                tempSummaryObj.GroupSessionActivityType__c = HUD9902Helper.getHudCategoryCode(HUD9902Helper.KEY_ActivityTypes, course.HUDActivityType__c, x9902CategoriesMap);
                // 9902 Summary record of ElementType Group Session
                groupSessions.add(tempSummaryObj);
                courseIdToGroupSessionId.put(course.Id, course.CourseNumber__c);
                idToCourseMap.put(course.Id, course);
				Set<String> uniqueContactPurpose1 = new Set<String>();
                for(sumoapp__Attendee__c attendee: course.sumoapp__EventAttendees__r) {
                    // Select attendees with attended status
                    if(acceptableAttendeeStatus.contains(attendee.Attendance_Status__c)) {
                        // For ElementType Gorup Session Attendee
                        if(attendeeClientNumberToCourseIds.containsKey(attendee.sumoapp__ContactRelation__r?.Client__c)) {
                            attendeeClientNumberToCourseIds.get(attendee.sumoapp__ContactRelation__r?.Client__c).add(course.Id);
                        } else {
                            attendeeClientNumberToCourseIds.put(attendee.sumoapp__ContactRelation__r?.Client__c, new Set<Id> { course.Id });
                        }
                        // For ElementType Attendee
                        if (!clientNumberToUniqueAttendees.containsKey(attendee.sumoapp__ContactRelation__r?.Client__c) || clientNumberToUniqueAttendees.get(attendee.sumoapp__ContactRelation__r?.Client__c).LastModifiedDate < attendee.LastModifiedDate) {
                            clientNumberToUniqueAttendees.put(attendee.sumoapp__ContactRelation__r?.Client__c, attendee);
                        }
                        clientCourseNumberToAttendees.put(attendee.sumoapp__ContactRelation__r?.Client__c + '-' + course.CourseNumber__c, attendee);
                    }
                }
                courseIdWithCousePurpose.put(course.Id, course.HUD_Purpose__c);
            }
        }

        // Section-12 & 13 : Group Session Attendee & Attendee
        Set<Id> coursesEnrolled;
        sumoapp__Attendee__c attendee;
        Set<String> uniqueContactPurpose1 = new Set<String>();
        for(sumoapp__Attendee__c uniqueAttendee: clientNumberToUniqueAttendees.values()) {
            // 9902 Summary record of ElementType Group Session Attendee
            coursesEnrolled = attendeeClientNumberToCourseIds.get(uniqueAttendee.sumoapp__ContactRelation__r?.Client__c);
            if(coursesEnrolled != null && !coursesEnrolled.isEmpty()) {
                for(Id courseId: coursesEnrolled) {
                    attendee = clientCourseNumberToAttendees.get(uniqueAttendee.sumoapp__ContactRelation__r?.Client__c + '-' +  courseIdToGroupSessionId.get(courseId));
                    if(!uniqueContactPurpose1.contains(attendee.sumoapp__ContactRelation__c + '-' + courseIdWithCousePurpose.get(courseId))) {
                        uniqueContactPurpose1.add(attendee.sumoapp__ContactRelation__c + '-' + courseIdWithCousePurpose.get(courseId));
                        tempSummaryObj = new X9902Summary__c();
                        tempSummaryObj.Course__c = courseId;
                        tempSummaryObj.ActivityTypeID__c = HUD9902Helper.getHudCategoryCode(HUD9902Helper.KEY_ActivityTypes, idToCourseMap.get(courseId).HUDActivityType__c, x9902CategoriesMap);
                        tempSummaryObj.ElementType__c = 'Group Session Attendee';
                        tempSummaryObj.GroupSessionID__c = courseIdToGroupSessionId.get(courseId);
                        tempSummaryObj.X9902__c = reportId;
                        tempSummaryObj.ReportPeriodId__c = HUD9902Helper.getHudCategoryCode(HUD9902Helper.KEY_ReportPeriods, reportPeriod, x9902CategoriesMap);
                        tempSummaryObj.GroupSessionAttendeeID__c = attendee.sumoapp__ContactRelation__r?.Client__c;
                        tempSummaryObj.GroupSessionCounselorHUDId__c = attendee.CreatedBy.CounselorHUDID__c;
                        tempSummaryObj.GroupSessionAttendeeFeeAmount__c = attendee.sumoapp__TotalPrice__c != null ? attendee.sumoapp__TotalPrice__c.setScale(0) : 0;
                        tempSummaryObj.GroupSessionAttendeeReferredBy__c = attendee.ReferralSource__c != null ? HUD9902Helper.getHudCategoryCode(HUD9902Helper.KEY_ReferredByTypes, attendee.ReferralSource__c, x9902CategoriesMap) : HUD9902Helper.getHudCategoryCode(HUD9902Helper.KEY_ReferredByTypes, 'N/A', x9902CategoriesMap);
                        tempSummaryObj.GroupSessionAttendeeIncomeLevel__c = HUD9902Helper.getHudCategoryCode(HUD9902Helper.KEY_IncomeLevels, attendee.AreaMedianIncome__c, x9902CategoriesMap);
                        tempSummaryObj.GroupSessionAttendeeCity__c = attendee.MailingAddress__City__s;
                        tempSummaryObj.GroupSessionAttendeeState__c = HUD9902Helper.getHudCategoryCode(HUD9902Helper.KEY_STATES, attendee.MailingAddress__StateCode__s, x9902CategoriesMap);
                        tempSummaryObj.GroupSessionAttendeeZipCode__c = attendee.MailingAddress__PostalCode__s;
                        tempSummaryObj.GroupSessionAttendeeRuralAreaStatus__c = HUD9902Helper.getHudCategoryCode(HUD9902Helper.KEY_RURAL_AREA_TYPES, attendee.RuralAreaStatus__c, x9902CategoriesMap);
                        tempSummaryObj.AttendeeFirstTimeHomeBuyer__c = attendee.X1stTimeHomeBuyer__c == 'Yes' ? 'Y' : 'N';
                        tempSummaryObj.GroupAttendeeLimitedEnglishProficiency__c = HUD9902Helper.getHudCategoryCode(HUD9902Helper.KEY_ENGLISH_PROFICIENCY_TYPES, attendee.EnglishProficiency__c, x9902CategoriesMap);
                        groupSessionAttendees.add(tempSummaryObj);
                    }
                }
            }
            // 9902 Summary record of ElementType Attendee
            tempSummaryObj = new X9902Summary__c();
            tempSummaryObj.ElementType__c = 'Attendee';
            tempSummaryObj.X9902__c = reportId;
            tempSummaryObj.ActivityTypeID__c = HUD9902Helper.getHudCategoryCode(HUD9902Helper.KEY_ActivityTypes, idToCourseMap.get(uniqueAttendee.sumoapp__SumoEvent__c).HUDActivityType__c, x9902CategoriesMap);
            tempSummaryObj.ReportPeriodId__c = HUD9902Helper.getHudCategoryCode(HUD9902Helper.KEY_ReportPeriods, reportPeriod, x9902CategoriesMap);
            tempSummaryObj.AttendeeID__c = uniqueAttendee.sumoapp__ContactRelation__r?.Client__c;
            tempSummaryObj.AttendeeCity__c = uniqueAttendee.MailingAddress__City__s;
            tempSummaryObj.AttendeeState__c = HUD9902Helper.getHudCategoryCode(HUD9902Helper.KEY_STATES, uniqueAttendee.MailingAddress__StateCode__s, x9902CategoriesMap);
            tempSummaryObj.AttendeeZipCode__c = uniqueAttendee.MailingAddress__PostalCode__s;
            tempSummaryObj.AttendeeRuralAreaStatus__c = HUD9902Helper.getHudCategoryCode(HUD9902Helper.KEY_RURAL_AREA_TYPES, uniqueAttendee.RuralAreaStatus__c, x9902CategoriesMap);
            tempSummaryObj.AttendeeLimitedEnglishProficiency__c = HUD9902Helper.getHudCategoryCode(HUD9902Helper.KEY_ENGLISH_PROFICIENCY_TYPES, uniqueAttendee.EnglishProficiency__c, x9902CategoriesMap);
            tempSummaryObj.AttendeeRaceID__c = HUD9902Helper.getHudCategoryCode(HUD9902Helper.KEY_RACES, uniqueAttendee.Race__c, x9902CategoriesMap);
            tempSummaryObj.AttendeeEthnicityID__c = HUD9902Helper.getHudCategoryCode(HUD9902Helper.KEY_ETHNICITIES, uniqueAttendee.Ethnicity__c, x9902CategoriesMap);
            tempSummaryObj.AttendeeIncomeLevel__c = HUD9902Helper.getHudCategoryCode(HUD9902Helper.KEY_IncomeLevels, uniqueAttendee.AreaMedianIncome__c, x9902CategoriesMap);
            attendees.add(tempSummaryObj);
        }

        x9902Summary.ElementType__c = '9902';
        x9902Summary.ReportPeriodId__c = HUD9902Helper.getHudCategoryCode(HUD9902Helper.KEY_ReportPeriods, reportPeriod, x9902CategoriesMap);
        x9902Summary.ActivityTypeID__c = '4';
        x9902Summary.X9902__c = reportId;
        summary9902ToInsert.add(x9902Summary);

        if(!groupSessions.isEmpty()) {
            summary9902ToInsert.addAll(groupSessions);
        }
        if(!groupSessionAttendees.isEmpty()) {
            summary9902ToInsert.addAll(groupSessionAttendees);
        }
        if(!attendees.isEmpty()) {
            summary9902ToInsert.addAll(attendees);
        }

        if(!summary9902ToInsert.isEmpty()) {
            insert summary9902ToInsert;
        }
    }

    public Map<String,Integer> getOutcomeCountMap(List<Event> events, Boolean isHUDBilable){
        List<String> outcomeArray = new List<String>();
        Map<String, Set<Id>> outcomeToClientCase = new Map<String, Set<Id>>();
        Map<String, Integer> outcomeCountMap = new Map<String, Integer>();
        for(Event evt: events) {
            if(isHUDBilable && (evt.HUDActivityType__c == NULL || evt.HUDActivityType__c == 'Not Billed to HUD')){
                continue;
            }
            outcomeArray = String.isNotBlank(evt.Outcome__c) ? evt.Outcome__c.split(';') : new List<String>();
            if (!outcomeArray.isEmpty()) {
                for(String outcome: outcomeArray) {
                    if (outcomeToClientCase.containsKey(outcome)) {
                        outcomeToClientCase.get(outcome).add(evt.WhatId);
                    } else {
                        outcomeToClientCase.put(outcome, new Set<Id> { evt.WhatId});
                    }
                }
            }
        }
        Integer count;
        for(String outcome: outcomeToClientCase.keySet()) {
            count = outcomeToClientCase.get(outcome) != null ? outcomeToClientCase.get(outcome).size() : 0;
            outcomeCountMap.put(outcome, count);
        }
        return outcomeCountMap;
    }

    public void updateCount(String hudActivityType, String key, Map<String, Integer> picklistToActivityCount){
        if(hudActivityType != NULL && hudActivityType != 'Not Billed to HUD'){
            picklistToActivityCount.put(key, picklistToActivityCount.get(key) + 1);
        }
    }
}