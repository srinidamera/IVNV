public class Hud9902DataDetailController {
    public static DateTime qtrStartDateTime, qtrEndDateTime;
    public static Date qtrStartDate, qtrEndDate;
    public static String reportPeriod;
    public static String currentFiscalYear;
    public static String lastFiscalYear;
    public static Set<String> uniqueAppointmentClientPurposes = new Set<String>();
    public static Set<String> uniqueAttendanceClientPurposes = new Set<String>();
    public static Id fccRTId = Schema.SObjectType.ClientCase__c.getRecordTypeInfosByDeveloperName().get('FinancialCapabilityCounseling').getRecordTypeId();
    public static Id primaryClientRTId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('PrimaryClient').getRecordTypeId();
    public static Integer recsPerSection = String.isNotBlank(System.Label.NoOfRecordPerSectionInHud9902DetailReport) ? Integer.valueOf(System.Label.NoOfRecordPerSectionInHud9902DetailReport) : 10;
    
    
    public static Map<String, String> labelTranslateForReport = new Map<String, String>{
        'EthnicityOther' => 'Chose not to respond',
            'RaceOther' => 'Chose not to respond',
            'AMIOther' => 'Chose not to respond',
            'RuralOther' => 'Chose not to respond',
            'EnglishOther' => 'Chose not to respond',
            'Below 30% of AMI' => '< 30% of Area Median Income (AMI)',
            '101% - 120% of AMI' => '> 100% of AMI'
            };
                
                public static Map<String, Map<String, List<sObject>>> picklistToActivityRecs = new Map<String, Map<String, List<sObject>>> {
                    'Ethnicity' => new Map<String, List<sObject>>(),
                        'Race' => new Map<String, List<sObject>>(),
                        'Income Levels' => new Map<String, List<sObject>>(),
                        'Rural Area Status' => new Map<String, List<sObject>>(),
                        'English Proficiency' => new Map<String, List<sObject>>(),
                        'Education' => new Map<String, List<sObject>>(),
                        'Counseling' => new Map<String, List<sObject>>(),
                        'Impact / Scope' => new Map<String, List<sObject>>()
                        };
                            
                            public static Map<String, Integer> activitiesWithOrder = new Map<String, Integer> {
                                'Hispanic' => 1,
                                    'Not Hispanic' => 2,
                                    'EthnicityOther' => 3,
                                    'American Indian/Alaskan Native' => 1,
                                    'Asian' => 2,
                                    'Black or African American' => 3,
                                    'Native Hawaiian or Other Pacific Islander' => 4,
                                    'More than one race' => 5,
                                    'White' => 6,
                                    'RaceOther' => 7,
                                    'Below 30% of AMI' => 1,
                                    '30 - 49% of AMI' => 2,
                                    '50 - 79% of AMI' => 3,
                                    '80 - 100% of AMI' => 4,
                                    '101% - 120% of AMI' => 5,
                                    'AMIOther' => 6,
                                    'Lives in a rural area' => 1,
                                    'Does not live in a rural area' => 2,
                                    'RuralOther' => 3,
                                    'Limited English Proficient' => 1,
                                    'Not Limited English Proficient' => 2,
                                    'EnglishOther' => 3,
                                    'Completed financial literacy workshop, including home affordability, budgeting and understanding use of credit' => 1,
                                    'Completed predatory lending, loan scam or other fraud prevention workshop' => 2,
                                    'Completed fair housing workshop' => 3,
                                    'Completed homelessness prevention workshop' => 4,
                                    'Completed rental workshop' => 5,
                                    'Completed pre-purchase homebuyer education workshop' => 6,
                                    'Completed non-delinquency post-purchase workshop, including home maintenance and/or financial management for homeowners' => 7,
                                    'Completed resolving or preventing mortgage delinquency workshop' => 8,
                                    'Completed disaster preparedness assistance workshop' => 9,
                                    'Completed disaster recovery assistance workshop' => 10,
                                    'Homeless Assistance' => 1,
                                    'Rental Topics' => 2,
                                    'Pre-purchase/Homebuying' => 3,
                                    'Home Maintenance' => 4,
                                    'Reverse Mortgage' => 5,
                                    'Non-Delinquency Post-Purchase' => 6,
                                    'Resolving or Preventing Forward Mortgage Delinquency or Default' => 7,
                                    'Resolving or Preventing Reverse Mortgage Delinquency or Default' => 8,
                                    'Disaster Preparedness Assistance' => 9,
                                    'Disaster Recovery Assistance' => 10,
                                    'Households that received one-on-one counseling that also received education services.' => 1,
                                    'Households that received information on fair housing, fair lending and/or accessibility rights.' => 2,
                                    'Households for whom counselor developed a budget customized to a client’s current situation.' => 3,
                                    'Households that improved their financial capacity (e.g. increased discretionary income, decreased debt load, increased savings, increased credit score, etc.) after receiving Housing Counseling Services.' => 4,
                                    'Households that gained access to resources to help improve their housing situation (e.g. down payment assistance, rental assistance, utility assistance, etc.) after receiving Housing Counseling Services.' => 5,
                                    'Households that gained access to non-housing resources (e.g. social service programs, legal services, public benefits such as Social Security or Medicaid, etc.) after receiving Housing Counseling Services' => 6,
                                    'Homeless or potentially homeless households that obtained temporary or permanent housing after receiving Housing Counseling Services.' => 7,
                                    'Households gained access to disaster recovery non-housing h . resources after receiving Housing Counseling Services (e.g. Red Cross/FEMA relief items, legal services, assistance).' => 8,
                                    'Households obtained disaster recovery housing resources after receiving Housing Counseling Services (e.g. temporary shelter, homeowner rehab, relocation, etc.).' => 9,
                                    'Households for whom counselor developed or updated an emergency preparedness plan.' => 10,
                                    'Household that received rental counseling and avoided eviction after receiving Housing Counseling Services.' => 11,
                                    'Households that received rental counseling and improved living conditions after receiving Housing Counseling Services.' => 12,
                                    'Households that received pre-purchase/homebuying counseling and purchased housing after receiving Housing Counseling Services.' => 13,
                                    'Households that received reverse mortgage counseling and obtained a Home Equity Conversion Mortgage (HECM) after receiving Housing Counseling Services.' => 14,
                                    'Households that received non-delinquency post-purchase counseling that were able to improve home conditions or home affordability after receiving Housing Counseling Services' => 15,
                                    'Households that prevented or resolved a forward mortgage default after receiving Housing Counseling Services.' => 16,
                                    'Households that prevented or resolved a reverse mortgage default after receiving Housing Counseling Services.' => 17,
                                    'Households that received a forward mortgage modification and remained current in their modified mortgage after receiving Housing Counseling Services.' => 18,
                                    'Households that received a forward mortgage modification and improved their financial capacity after receiving Housing counseling Services.' => 19
                                    
                                    };
                                        
                                        public static Map<String, String> picklistToFieldMap = new Map<String, String> {
                                            'Ethnicity' => 'Ethnicity__c',
                                                'Race' => 'Race__c',
                                                'Income Levels' => 'AreaMedianIncome__c',
                                                'Rural Area Status' => 'RuralAreaStatus__c',
                                                'English Proficiency' => 'EnglishProficiency__c',
                                                'Education' => 'sumoapp__SumoEvent__r.HUD_Purpose__c',
                                                'Counseling' => '',
                                                'Impact / Scope' => ''
                                                };
                                                    
                                                    
                                                    
                                                    
                                                    @AuraEnabled(cacheable=true)
                                                    public static RetrunWrapper getData(String recordId){
                                                        RetrunWrapper result = new RetrunWrapper();
                                                        
                                                        try{
                                                            if(String.isNotBlank(recordId)){
                                                                X9902__c x9902 = [SELECT Id, PeriodStartDate__c, PeriodEndDate__c, Quarter__c FROM X9902__c WHERE Id = :recordId];
                                                                
                                                                qtrStartDate = x9902.PeriodStartDate__c;
                                                                qtrEndDate = x9902.PeriodEndDate__c;
                                                                reportPeriod = x9902.Quarter__c;
                                                                currentFiscalYear = x9902.PeriodEndDate__c != NULL ? String.valueOf(x9902.PeriodEndDate__c.year() - 1) : '';
                                                                lastFiscalYear = x9902.PeriodEndDate__c != NULL ? String.valueOf(x9902.PeriodEndDate__c.year() - 2) : '';
                                                                List<Event> eventList = new List<Event>();
                                                                Contact con = new Contact();
                                                                
																Set<String> hudActivitySelected = new Set<String>();
                                                                
                                                                Integer newCount = 0;
                                                                Set<Id> clientCasesIds = new Set<Id>();
                                                                
                                                                List<Event> appointmentList = [SELECT Id, WhatId, WhoId, Purpose__c, HUDActivityType__c, DurationInMinutes, ActivityDate, AppointmentDuration__c,
                                                                                               TYPEOF Who
                                                                                               WHEN Contact THEN Client__c, Ethnicity__c, Race__c, AreaMedianIncome__c,RuralAreaStatus__c,EnglishProficiency__c, RecordType.Name
                                                                                               END
                                                                                               /*TYPEOF What
WHEN ClientCase__c THEN ClientNumber__c, Name, PrimaryClient__c, IntakeDate__c, CaseTypeName__c, RecordType.Name
END*/
                                                                                               FROM Event 
                                                                                               // WHERE (What.Type = 'ClientCase__C' OR Who.Type = 'Contact')
                                                                                               WHERE Who.Type = 'Contact'
                                                                                               AND What.Type = 'ClientCase__C'
                                                                                               AND EndDateTime >= :qtrStartDate 
                                                                                               AND EndDateTime <= :qtrEndDate
                                                                                               AND AppointmentStatus__c = 'Attended'
                                                                                               AND Who.RecordType.Name = 'Primary Client'
                                                                                               AND Purpose__c NOT IN ('Not HUD-Reportable', null, '', NULL)
                                                                                              ];
                                                                
                                                                for(Event ev : appointmentList){
                                                                    if(String.isNotBlank(ev.HUDActivityType__c) && ev.HUDActivityType__c != 'Not Billed to HUD'){
                                                                        hudActivitySelected.add(ev.HUDActivityType__c);
                                                                    }
                                                                    
                                                                    if(!uniqueAppointmentClientPurposes.contains(ev.WhoId+'-'+ev.Purpose__c)){
                                                                        uniqueAppointmentClientPurposes.add(ev.WhoId+'-'+ev.Purpose__c);
                                                                        if(ev.Who instanceof Contact){
                                                                            if(ev.WhatId.getSObjectType().getDescribe().getName() == 'ClientCase__c'){
                                                                                clientCasesIds.add(ev.WhatId);
                                                                            }
                                                                            con = ev.Who;
                                                                            if(con.Ethnicity__c == 'Hispanic'){
                                                                                addRecsToMap('Ethnicity', 'Hispanic', ev);
                                                                            }else if(con.Ethnicity__c == 'Not Hispanic'){
                                                                                addRecsToMap('Ethnicity', 'Not Hispanic', ev);
                                                                            }else{
                                                                                addRecsToMap('Ethnicity', 'EthnicityOther', ev);
                                                                            }
                                                                            
                                                                            if(con.Race__c == 'American Indian/Alaskan Native'){
                                                                                addRecsToMap('Race', 'American Indian/Alaskan Native', ev);
                                                                            }else if(con.Race__c == 'Asian'){
                                                                                addRecsToMap('Race', 'Asian', ev);
                                                                            }else if(con.Race__c == 'Black or African American'){
                                                                                addRecsToMap('Race', 'Black or African American', ev);
                                                                            }else if(con.Race__c == 'Native Hawaiian or Other Pacific Islander'){
                                                                                addRecsToMap('Race', 'Native Hawaiian or Other Pacific Islander', ev);
                                                                            }else if(con.Race__c == 'White'){
                                                                                addRecsToMap('Race', 'White', ev);
                                                                            }else if(con.Race__c == 'More than one race'){
                                                                                addRecsToMap('Race', 'More than one race', ev);
                                                                            }else {
                                                                                addRecsToMap('Race', 'RaceOther', ev);
                                                                            }
                                                                            
                                                                            if(con.AreaMedianIncome__c == 'Below 30% of AMI'){
                                                                                addRecsToMap('Income Levels', 'Below 30% of AMI', ev);
                                                                            }else if(con.AreaMedianIncome__c == '30 - 49% of AMI'){
                                                                                addRecsToMap('Income Levels', '30 - 49% of AMI', ev);
                                                                            }else if(con.AreaMedianIncome__c == '50 - 79% of AMI'){
                                                                                addRecsToMap('Income Levels', '50 - 79% of AMI', ev);
                                                                            }else if(con.AreaMedianIncome__c == '80 - 100% of AMI'){
                                                                                addRecsToMap('Income Levels', '80 - 100% of AMI', ev);
                                                                            }else if(con.AreaMedianIncome__c == '101% - 120% of AMI' || con.AreaMedianIncome__c == 'Above 120% of AMI'){
                                                                                addRecsToMap('Income Levels', '101% - 120% of AMI', ev);
                                                                            }else{
                                                                                addRecsToMap('Income Levels', 'AMIOther', ev);
                                                                            }
                                                                            
                                                                            if(con.RuralAreaStatus__c == 'Lives in a rural area'){
                                                                                addRecsToMap('Rural Area Status', 'Lives in a rural area', ev);
                                                                            }else if(con.RuralAreaStatus__c == 'Does not live in a rural area'){
                                                                                addRecsToMap('Rural Area Status', 'Does not live in a rural area', ev);
                                                                            }else{
                                                                                addRecsToMap('Rural Area Status', 'RuralOther', ev);
                                                                            }
                                                                            
                                                                            if(con.EnglishProficiency__c == 'Limited English Proficient'){
                                                                                addRecsToMap('English Proficiency', 'Limited English Proficient', ev);
                                                                            }else if(con.EnglishProficiency__c == 'Not Limited English Proficient'){
                                                                                addRecsToMap('English Proficiency', 'Not Limited English Proficient', ev);
                                                                            }else{
                                                                                addRecsToMap('English Proficiency', 'EnglishOther', ev);
                                                                            }
                                                                        }
                                                                    }
                                                                }
                                                                
                                                                List<sumoapp__Attendee__c> attendeeList = [SELECT Id, Name, Race__c, Ethnicity__c, AreaMedianIncome__c, sumoapp__SumoEvent__r.Total_Duration_In_Minutes__c, sumoapp__SumoEvent__r.sumoapp__DurationInMinutes__c,
                                                                                                           RuralAreaStatus__c, EnglishProficiency__c, sumoapp__SumoEvent__r.HUD_Purpose__c, ClientNumber__c, sumoapp__StartDatetime__c, sumoapp__EventName__c,
                                                                                                           sumoapp__ContactRelation__c, sumoapp__ContactRelation__r.Name, sumoapp__ContactRelation__r.Client__c, sumoapp__SumoEvent__r.HUDActivityType__c, sumoapp__SumoEvent__r.sumoapp__EventName__c,
                                                                                                           sumoapp__SumoEvent__r.RecordType.Name, sumoapp__SumoEvent__r.ClientCase__c
                                                                                                           FROM sumoapp__Attendee__c
                                                                                                           WHERE sumoapp__SumoEvent__r.RecordType.Name IN ('Course', 'Event')
                                                                                                           AND sumoapp__SumoEvent__r.IsParent__c = true
                                                                                                           AND Attendance_Status__c IN ('Course Complete', 'Attended - Complete')
                                                                                                           AND sumoapp__ContactRelation__r.RecordType.Name = 'Primary Client'
                                                                                                           AND sumoapp__SumoEvent__r.sumoapp__EndDatetime__c >= :qtrStartDate
                                                                                                           AND sumoapp__SumoEvent__r.sumoapp__EndDatetime__c <= :qtrEndDate
                                                                                                           AND sumoapp__SumoEvent__r.HUD_Purpose__c NOT IN (null, '', NULL)
                                                                                                           AND ExcludeAttendeeFromHUD9902__c = False
                                                                                                           AND sumoapp__SumoEvent__r.ExcludeCourseFromHUD9902__c = False
                                                                                                           AND sumoapp__SumoEvent__r.sumoapp__Status__c != 'CANCELED' 
                                                                                                          ];        
                                                                for(sumoapp__Attendee__c att : attendeeList){
                                                                    if(String.isNotBlank(att.sumoapp__SumoEvent__r.HUDActivityType__c) && att.sumoapp__SumoEvent__r.HUDActivityType__c != 'Not Billed to HUD'){
                                                                        hudActivitySelected.add(att.sumoapp__SumoEvent__r.HUDActivityType__c);
                                                                    }
                                                                    
                                                                    if(!uniqueAttendanceClientPurposes.contains(att.sumoapp__ContactRelation__c+'-'+att.sumoapp__SumoEvent__r.HUD_Purpose__c)){
                                                                        uniqueAttendanceClientPurposes.add(att.sumoapp__ContactRelation__c+'-'+att.sumoapp__SumoEvent__r.HUD_Purpose__c);
                                                                        
                                                                        if(att.sumoapp__SumoEvent__r.ClientCase__c != NULL){
                                                                            clientCasesIds.add(att.sumoapp__SumoEvent__r.ClientCase__c);
                                                                        }
                                                                        
                                                                        Decimal duration = 0;
                                                                        if(att.sumoapp__SumoEvent__r.RecordType.Name == 'Course'){
                                                                            duration = att.sumoapp__SumoEvent__r.Total_Duration_In_Minutes__c;
                                                                        } else if(att.sumoapp__SumoEvent__r.RecordType.Name == 'Event'){
                                                                            duration = att.sumoapp__SumoEvent__r.sumoapp__DurationInMinutes__c;
                                                                        }
                                                                        
                                                                        if(att.Ethnicity__c == 'Hispanic'){
                                                                            addRecsToMap('Ethnicity', 'Hispanic', att);
                                                                        }else if(att.Ethnicity__c == 'Not Hispanic'){
                                                                            addRecsToMap('Ethnicity', 'Not Hispanic', att);
                                                                        }else{
                                                                            addRecsToMap('Ethnicity', 'EthnicityOther', att);
                                                                        }
                                                                        
                                                                        if(att.Race__c == 'American Indian/Alaskan Native'){
                                                                            addRecsToMap('Race', 'American Indian/Alaskan Native', att);
                                                                        }else if(att.Race__c == 'Asian'){
                                                                            addRecsToMap('Race', 'Asian', att);
                                                                        }else if(att.Race__c == 'Black or African American'){
                                                                            addRecsToMap('Race', 'Black or African American', att);
                                                                        }else if(att.Race__c == 'Native Hawaiian or Other Pacific Islander'){
                                                                            addRecsToMap('Race', 'Native Hawaiian or Other Pacific Islander', att);
                                                                        }else if(att.Race__c == 'White'){
                                                                            addRecsToMap('Race', 'White', att);
                                                                        }else if(att.Race__c == 'More than one race'){
                                                                            addRecsToMap('Race', 'More than one race', att);
                                                                        }else {
                                                                            addRecsToMap('Race', 'RaceOther', att);
                                                                        }
                                                                        
                                                                        if(att.AreaMedianIncome__c == 'Below 30% of AMI'){
                                                                            addRecsToMap('Income Levels', 'Below 30% of AMI', att);
                                                                        }else if(att.AreaMedianIncome__c == '30 - 49% of AMI'){
                                                                            addRecsToMap('Income Levels', '30 - 49% of AMI', att);
                                                                        }else if(att.AreaMedianIncome__c == '50 - 79% of AMI'){
                                                                            addRecsToMap('Income Levels', '50 - 79% of AMI', att);
                                                                        }else if(att.AreaMedianIncome__c == '80 - 100% of AMI'){
                                                                            addRecsToMap('Income Levels', '80 - 100% of AMI', att);
                                                                        }else if(att.AreaMedianIncome__c == '101% - 120% of AMI' || att.AreaMedianIncome__c == 'Above 120% of AMI'){
                                                                            addRecsToMap('Income Levels', '101% - 120% of AMI', att);
                                                                        }else{
                                                                            addRecsToMap('Income Levels', 'AMIOther', att);
                                                                        }
                                                                        
                                                                        if(att.RuralAreaStatus__c == 'Lives in a rural area'){
                                                                            addRecsToMap('Rural Area Status', 'Lives in a rural area', att);
                                                                        }else if(att.RuralAreaStatus__c == 'Does not live in a rural area'){
                                                                            addRecsToMap('Rural Area Status', 'Does not live in a rural area', att);
                                                                        }else{
                                                                            addRecsToMap('Rural Area Status', 'RuralOther', att);
                                                                        }
                                                                        
                                                                        if(att.EnglishProficiency__c == 'Limited English Proficient'){
                                                                            addRecsToMap('English Proficiency', 'Limited English Proficient', att);
                                                                        }else if(att.EnglishProficiency__c == 'Not Limited English Proficient'){
                                                                            addRecsToMap('English Proficiency', 'Not Limited English Proficient', att);
                                                                        }else{
                                                                            addRecsToMap('English Proficiency', 'EnglishOther', att);
                                                                            
                                                                        }
                                                                    }
                                                                }
                                                                
                                                                List<Id> courseIdList = new List<Id>();
                                                                List<Id> clientCaseIdList = new List<Id>();
                                                                
                                                                List<ClientCase__c> clientCaseList = [SELECT Id 
                                                                                                      FROM ClientCase__c 
                                                                                                      WHERE IntakeDate__c <=: qtrEndDate 
                                                                                                      AND IntakeDate__c >=: qtrStartDate 
                                                                                                      AND RecordTypeId != :fccRTId
                                                                                                     ];
                                                                for(ClientCase__c cc : clientCaseList){
                                                                    clientCaseIdList.add(cc.Id);
                                                                }
                                                                
                                                                for(sumoapp__AdditionalInfo__c course : [SELECT Id, ClientCase__c FROM sumoapp__AdditionalInfo__c 
                                                                                                         WHERE RecordType.Name IN ('Course', 'Event')
                                                                                                         AND IsParent__c = true
                                                                                                         AND ExcludeCourseFromHUD9902__c = False
                                                                                                         AND sumoapp__EndDatetime__c >=:qtrStartDate
                                                                                                         AND sumoapp__EndDatetime__c <=:qtrEndDate]){
                                                                                                             courseIdList.add(course.Id);
                                                                                                         }
                                                                
                                                                
                                                                String key;
                                                                
                                                                Set<String> uniqueContactPurpose = new Set<String>();
                                                                
                                                                for(sumoapp__Attendee__c att : attendeeList) {
                                                                    if(String.isNotBlank(att.sumoapp__SumoEvent__r.HUDActivityType__c) && att.sumoapp__SumoEvent__r.HUDActivityType__c != 'Not Billed to HUD'){
                                                                        hudActivitySelected.add(att.sumoapp__SumoEvent__r.HUDActivityType__c);
                                                                    }
                                                                    
                                                                    SYstem.debug('att.sumoapp__SumoEvent__c->'+att.sumoapp__SumoEvent__c);
                                                                    if (att.sumoapp__SumoEvent__r?.HUD_Purpose__c != null) {
                                                                        if (!uniqueContactPurpose.contains(att.sumoapp__ContactRelation__c+'-'+att.sumoapp__SumoEvent__r.HUD_Purpose__c)) {
                                                                            uniqueContactPurpose.add(att.sumoapp__ContactRelation__c+'-'+att.sumoapp__SumoEvent__r.HUD_Purpose__c);
                                                                            key = att.sumoapp__SumoEvent__r.HUD_Purpose__c;
                                                                            
                                                                            addRecsToMap('Education', key, att);
                                                                            
                                                                        }   
                                                                    }
                                                                }
                                                                
                                                                uniqueAppointmentClientPurposes = new Set<String>();
                                                                for(Event ev : appointmentList){
                                                                    if(String.isNotBlank(ev.HUDActivityType__c) && ev.HUDActivityType__c != 'Not Billed to HUD'){
                                                                        hudActivitySelected.add(ev.HUDActivityType__c);
                                                                    }
                                                                    
                                                                    if(String.isNotBlank(ev.Purpose__c)) {
                                                                        if(!uniqueAppointmentClientPurposes.contains(ev.WhoId+'-'+ev.Purpose__c)){
                                                                            uniqueAppointmentClientPurposes.add(ev.WhoId+'-'+ev.Purpose__c);
                                                                            key = ev.Purpose__c;
                                                                            addRecsToMap('Counseling', key, ev);
                                                                            
                                                                        }
                                                                    }
                                                                }
                                                                
                                                                eventList = [ SELECT WhoId, WhatId, Outcome__c, Purpose__c, HUDActivityType__c, DurationInMinutes, ActivityDate, AppointmentDuration__c,
                                                                             TYPEOF Who
                                                                             WHEN Contact THEN Client__c, Ethnicity__c, Race__c, AreaMedianIncome__c,RuralAreaStatus__c,EnglishProficiency__c, RecordType.Name
                                                                             END
                                                                             FROM Event 
                                                                             WHERE EndDateTime >= :qtrStartDate 
                                                                             AND EndDateTime <= :qtrEndDate
                                                                             AND Who.RecordTypeId = :primaryClientRTId
                                                                             AND AppointmentStatus__c = 'Attended'
                                                                             AND Purpose__c != 'Not HUD-Reportable'
                                                                             AND Who.Type = 'Contact'
                                                                             AND What.Type = 'ClientCase__C'
                                                                             // AND (Who.Type = 'Contact' OR What.Type = 'ClientCase__C')
                                                                            ];
                                                                
                                                                for(Event evnt: eventList) {
                                                                    clientCasesIds.add(evnt.WhatId);
                                                                }
                                                                
                                                                List<Event> eventList2 = [ SELECT WhoId, WhatId, Outcome__c, Purpose__c, HUDActivityType__c, DurationInMinutes, ActivityDate, AppointmentDuration__c,
                                                                                          TYPEOF Who
                                                                                          WHEN Contact THEN Client__c, Ethnicity__c, Race__c, AreaMedianIncome__c,RuralAreaStatus__c,EnglishProficiency__c, RecordType.Name
                                                                                          END
                                                                                          FROM Event 
                                                                                          WHERE EndDateTime < :qtrStartDate
                                                                                          AND Who.RecordTypeId = :primaryClientRTId
                                                                                          AND WhatId IN :clientCasesIds
                                                                                          AND Who.Type = 'Contact'
                                                                                          AND What.Type = 'ClientCase__C'
                                                                                         ];
                                                                if(!eventList2.isEmpty()) {
                                                                    eventList.addAll(eventList2);
                                                                }
                                                                
                                                                Map<Id, ClientCase__c> clientCaseMap = new Map<Id, ClientCase__c>([Select Id, ClientNumber__c, Name, PrimaryClient__c, PrimaryClient__r.Name, IntakeDate__c, CaseTypeName__c, RecordType.Name from ClientCase__c where Id IN :clientCasesIds]);
                                                                
                                                                Map<String, Set<Id>> outcomeToClientCase = new Map<String, Set<Id>>();
                                                                
                                                                for(Event evt: eventList) {
                                                                    
                                                                    List<String> outcomeArray = String.isNotBlank(evt.Outcome__c) ? evt.Outcome__c.split(';') : new List<String>();
                                                                    for(String outcome: outcomeArray) {
                                                                        if (outcomeToClientCase.containsKey(outcome)) {
                                                                            if(!outcomeToClientCase.get(outcome).contains(evt.WhatId)){
                                                                                outcomeToClientCase.get(outcome).add(evt.WhatId);
                                                                                addRecsToMap('Impact / Scope', outcome, evt);
                                                                            }
                                                                        } else {
                                                                            outcomeToClientCase.put(outcome, new Set<Id> { evt.WhatId});
                                                                            addRecsToMap('Impact / Scope', outcome, evt);
                                                                        }
                                                                    }
                                                                }
                                                                                                                                
                                                                List<ParentRowWrapper> recs = new List<ParentRowWrapper>();
                                                                
                                                                for(String section : picklistToActivityRecs.keySet()){
                                                                    ParentRowWrapper prw = new ParentRowWrapper();
                                                                    prw.rowName = section;
                                                                    
                                                                    Integer totalAllCount = 0;
                                                                    Decimal totalAllTimeSpent = 0;
                                                                    Integer totalCurrentYearCount = 0;
                                                                    Decimal totalCurrentYearTimeSpent = 0;
                                                                    Integer totalLastYearCount = 0;
                                                                    Decimal totalLastYearTimeSpent = 0;
                                                                    Integer totalHudCount = 0;
                                                                    Decimal totalHudTimeSpent = 0;
                                                                    
                                                                    List<AnswerWrapper> ansWrapList = new List<AnswerWrapper>();
                                                                    if(picklistToActivityRecs.get(section) != NULL){
                                                                        
                                                                        for(String answer : picklistToActivityRecs.get(section).keySet()){
                                                                            AnswerWrapper ansWrap = new AnswerWrapper();
                                                                            ansWrap.answer = answer;
                                                                            ansWrap.orderNo = activitiesWithOrder.containsKey(answer) ? activitiesWithOrder.get(answer) : 0;
                                                                            prw.isExpanded = true;
                                                                            
                                                                            List<RowWrapper> rowWrapList = new List<RowWrapper>();
                                                                            
                                                                            Integer totalAnsAllCount = 0;
                                                                            Decimal totalAnsAllTimeSpent = 0;
                                                                            Integer totalAnsCurrentYearCount = 0;
                                                                            Decimal totalAnsCurrentYearTimeSpent = 0;
                                                                            Integer totalAnsLastYearCount = 0;
                                                                            Decimal totalAnsLastYearTimeSpent = 0;
                                                                            Integer totalAnsHudCount = 0;
                                                                            Decimal totalAnsHudTimeSpent = 0;
                                                                            String answerLabel = '';
                                                                            
                                                                            if(picklistToActivityRecs.get(section).get(answer) != NULL){
                                                                                
                                                                                for(sObject obj : picklistToActivityRecs.get(section).get(answer)){
                                                                                    if(obj.Id.getSObjectType().getDescribe().getName() == 'Event' && ((Event)obj).Who instanceof Contact){
                                                                                        Event evt = (Event)obj;
                                                                                        con = evt.Who;
                                                                                        RowWrapper rw = new RowWrapper();
                                                                                        rw.recId = evt.Id;
                                                                                        rw.activityType = evt.HUDActivityType__c;
                                                                                        rw.associatedActivity = evt.Purpose__c;
                                                                                        rw.clientNo = con.Client__c;
                                                                                        rw.intakeOrClassDate = evt.ActivityDate != NULL ? evt.ActivityDate.format() : '';
                                                                                        ClientCase__c cc = clientCaseMap.containsKey(evt.WhatId) ? clientCaseMap.get(evt.WhatId) : null;
                                                                                        if(cc != null){
                                                                                            //rw.clientNo = cc.ClientNumber__c ;
                                                                                            rw.caseId = cc.Id ;
                                                                                            rw.caseHref = '/' + cc.Id;
                                                                                            rw.caseNo = cc.Name;
                                                                                            rw.clientId = cc.PrimaryClient__c;
                                                                                            rw.clientHref = '/' + cc.PrimaryClient__c;
                                                                                            rw.name = cc.PrimaryClient__c != NULL ? cc.PrimaryClient__r.Name : '' ;
                                                                                            rw.intakeOrClassDate = cc.IntakeDate__c != NULL ? cc.IntakeDate__c.format() : '';
                                                                                            //rw.subCategory = con.Ethnicity__c;
                                                                                            //rw.associatedActivity = cc.CaseTypeName__c ;
                                                                                            
                                                                                        }
                                                                                        
                                                                                        /*System.debug('answer->'+answer);
System.debug('labelTranslateForReport.get(answer)->'+labelTranslateForReport.get(answer));
System.debug('picklistToFieldMap.get(section)->'+picklistToFieldMap.get(section));
System.debug('(String)con.get(picklistToFieldMap.get(section))->'+(String)con.get(picklistToFieldMap.get(section)));*/
                                                                                        
                                                                                        if(section == 'Education'){
                                                                                            //rw.answer = evt.sumoapp__SumoEvent__r.HUD_Purpose__c;
                                                                                            //answerLabel = evt.sumoapp__SumoEvent__r.HUD_Purpose__c;
                                                                                        } else if(section == 'Counseling'){
                                                                                            rw.answer = evt.Purpose__c;
                                                                                            answerLabel = evt.Purpose__c;
                                                                                        } else if(section == 'Impact / Scope'){
                                                                                            rw.answer = answer;
                                                                                            answerLabel = answer;
                                                                                        } else if(labelTranslateForReport.containsKey(answer)){
                                                                                            rw.answer = labelTranslateForReport.get(answer);
                                                                                            answerLabel = labelTranslateForReport.get(answer);
                                                                                        } else{
                                                                                            rw.answer = (String)con.get(picklistToFieldMap.get(section));
                                                                                            answerLabel = (String)con.get(picklistToFieldMap.get(section));
                                                                                        }
                                                                                        //rw.answer = (String)con.get(picklistToFieldMap.get(section));
                                                                                        //rw.answer = labelTranslateForReport.containsKey((String)con.get(picklistToFieldMap.get(section))) ? labelTranslateForReport.get((String)con.get(picklistToFieldMap.get(section))) : answer;
                                                                                        //answerLabel = (String)con.get(picklistToFieldMap.get(section));
                                                                                        rw.all = 1;
                                                                                        totalAnsAllCount += 1;
                                                                                        if(evt.AppointmentDuration__c != NULL){
                                                                                            //totalAnsAllTimeSpent += evt.AppointmentDuration__c;
                                                                                            rw.allTimeSpent = evt.AppointmentDuration__c != NULL ? evt.AppointmentDuration__c + ':00' : '00:00';
                                                                                            //rw.hudTimeSpent = evt.AppointmentDuration__c != NULL ? evt.AppointmentDuration__c + ':00' : '00:00';
                                                                                            rw.timeSpentOnActivity = evt.AppointmentDuration__c;
                                                                                        }
                                                                                        
                                                                                        
                                                                                        /*if(evt.HUDActivityType__c != NULL && evt.HUDActivityType__c.containsIgnoreCase(currentFiscalYear)){
                                                                                            rw.currentYearCount = 1;
                                                                                            totalAnsCurrentYearCount += 1;
                                                                                            if(evt.AppointmentDuration__c != NULL){
                                                                                                totalAnsCurrentYearTimeSpent += evt.AppointmentDuration__c;
                                                                                                totalAnsHudTimeSpent += evt.AppointmentDuration__c;
                                                                                                rw.currentYearTimeSpent = evt.AppointmentDuration__c != NULL ? evt.AppointmentDuration__c + ':00' : '00:00';
                                                                                            }
                                                                                            rw.hudCount = 1;
                                                                                            totalAnsHudCount += 1;
                                                                                            rw.hudTimeSpent = rw.currentYearTimeSpent;
                                                                                        }
                                                                                        if(evt.HUDActivityType__c != NULL && evt.HUDActivityType__c.containsIgnoreCase(lastFiscalYear)){
                                                                                            rw.lastYearCount = 1;
                                                                                            totalAnsLastYearCount += 1;
                                                                                            if(evt.AppointmentDuration__c != NULL){
                                                                                                totalAnsLastYearTimeSpent += evt.AppointmentDuration__c;
                                                                                                totalAnsHudTimeSpent += evt.AppointmentDuration__c;
                                                                                                rw.lastYearTimeSpent = evt.AppointmentDuration__c != NULL ? evt.AppointmentDuration__c + ':00' : '00:00';
                                                                                            }
                                                                                            rw.hudCount = 1;
                                                                                            totalAnsHudCount += 1;
                                                                                            rw.hudTimeSpent = rw.lastYearTimeSpent;
                                                                                        }*/
                                                                                        
                                                                                        rowWrapList.add(rw);
                                                                                    } else if(obj.Id.getSObjectType().getDescribe().getName() == 'sumoapp__Attendee__c'){
                                                                                        sumoapp__Attendee__c evt = (sumoapp__Attendee__c)obj;
                                                                                        //con = evt.Who;
                                                                                        RowWrapper rw = new RowWrapper();
                                                                                        
                                                                                        ClientCase__c cc = clientCaseMap.containsKey(evt.sumoapp__SumoEvent__r.ClientCase__c) ? clientCaseMap.get(evt.sumoapp__SumoEvent__r.ClientCase__c) : null;
                                                                                        rw.recId = evt.Id;
                                                                                        rw.activityType = evt.sumoapp__SumoEvent__r.HUDActivityType__c;
                                                                                        rw.associatedActivity = evt.sumoapp__SumoEvent__r.HUD_Purpose__c ;
                                                                                        rw.clientNo = evt.sumoapp__ContactRelation__r.Client__c;
                                                                                        rw.intakeOrClassDate = evt.sumoapp__StartDatetime__c != NULL ? evt.sumoapp__StartDatetime__c.format('MM/dd/yyyy') : '';
                                                                                        if(cc != null){
                                                                                            //rw.clientNo = cc.ClientNumber__c ;
                                                                                            rw.caseId = cc.Id ;
                                                                                            rw.caseHref = '/' + cc.Id;
                                                                                            rw.caseNo = cc.Name;
                                                                                            rw.clientId = cc.PrimaryClient__c;
                                                                                            rw.clientHref = '/' + cc.PrimaryClient__c;
                                                                                            rw.name = cc.PrimaryClient__c != NULL ? cc.PrimaryClient__r.Name : '' ;
                                                                                            rw.intakeOrClassDate = cc.IntakeDate__c != NULL ? cc.IntakeDate__c.format() : '';
                                                                                            //rw.subCategory = con.Ethnicity__c;
                                                                                            //rw.associatedActivity = cc.CaseTypeName__c ;
                                                                                        } else{
                                                                                            //rw.clientNo = evt.ClientNumber__c ;
                                                                                            rw.caseNo = '';
                                                                                            rw.caseId = '';
                                                                                            rw.caseHref = '';
                                                                                            rw.clientId = evt.sumoapp__ContactRelation__c;
                                                                                            rw.clientHref = '/' + evt.sumoapp__ContactRelation__c;
                                                                                            rw.name = evt.sumoapp__ContactRelation__r.Name;
                                                                                            rw.intakeOrClassDate = evt.sumoapp__StartDatetime__c != NULL ? evt.sumoapp__StartDatetime__c.format('MM/dd/yyyy') : '';
                                                                                            //rw.subCategory = con.Ethnicity__c;
                                                                                            rw.associatedActivity = evt.sumoapp__SumoEvent__r.sumoapp__EventName__c;
                                                                                        }
                                                                                        
                                                                                        
                                                                                        if(section == 'Education'){
                                                                                            rw.answer = evt.sumoapp__SumoEvent__r.HUD_Purpose__c;
                                                                                            answerLabel = evt.sumoapp__SumoEvent__r.HUD_Purpose__c;
                                                                                        } else if(section == 'Counseling'){
                                                                                            //rw.answer = evt.sumoapp__SumoEvent__r.HUD_Purpose__c;
                                                                                            //answerLabel = evt.sumoapp__SumoEvent__r.HUD_Purpose__c;
                                                                                        } else if(section == 'Impact / Scope'){
                                                                                            //rw.answer = evt.Outcome__c;
                                                                                            //answerLabel = evt.Outcome__c;
                                                                                        } else if(labelTranslateForReport.containsKey(answer)){
                                                                                            rw.answer = labelTranslateForReport.get(answer);
                                                                                            answerLabel = labelTranslateForReport.get(answer);
                                                                                        } else{
                                                                                            rw.answer = (String)evt.get(picklistToFieldMap.get(section));
                                                                                            answerLabel = (String)evt.get(picklistToFieldMap.get(section));
                                                                                        }
                                                                                        
                                                                                        //rw.answer = (String)evt.get(picklistToFieldMap.get(section));
                                                                                        //rw.answer = labelTranslateForReport.containsKey((String)evt.get(picklistToFieldMap.get(section))) ? labelTranslateForReport.get((String)evt.get(picklistToFieldMap.get(section))) : answer;
                                                                                        //answerLabel = (String)evt.get(picklistToFieldMap.get(section));
                                                                                        rw.all = 1;
                                                                                        totalAnsAllCount += 1;
                                                                                        
                                                                                        Decimal duration = 0;
                                                                                        if(evt.sumoapp__SumoEvent__r.RecordType.Name == 'Course'){
                                                                                            duration = evt.sumoapp__SumoEvent__r.Total_Duration_In_Minutes__c;
                                                                                        } else if(evt.sumoapp__SumoEvent__r.RecordType.Name == 'Event'){
                                                                                            duration = evt.sumoapp__SumoEvent__r.sumoapp__DurationInMinutes__c;
                                                                                        }
                                                                                        
                                                                                        if(duration != NULL){
                                                                                            //totalAnsAllTimeSpent += duration;
                                                                                            rw.allTimeSpent = duration != NULL ? duration + ':00' : '00:00';
                                                                                            //rw.hudTimeSpent = duration != NULL ? duration + ':00' : '00:00';
                                                                                            rw.timeSpentOnActivity = duration;
                                                                                        }
                                                                                        
                                                                                        
                                                                                        /*if(evt.sumoapp__SumoEvent__r.HUDActivityType__c != NULL && evt.sumoapp__SumoEvent__r.HUDActivityType__c.containsIgnoreCase(currentFiscalYear)){
                                                                                            rw.currentYearCount = 1;
                                                                                            totalAnsCurrentYearCount += 1;
                                                                                            if(duration != NULL){
                                                                                                totalAnsCurrentYearTimeSpent += duration;
                                                                                                totalAnsHudTimeSpent += duration;
                                                                                                rw.currentYearTimeSpent = duration != NULL ? duration + ':00' : '00:00';
                                                                                            }
                                                                                            rw.hudCount = 1;
                                                                                            totalAnsHudCount += 1;
                                                                                            rw.hudTimeSpent = rw.currentYearTimeSpent;
                                                                                        }
                                                                                        if(evt.sumoapp__SumoEvent__r.HUDActivityType__c != NULL && evt.sumoapp__SumoEvent__r.HUDActivityType__c.containsIgnoreCase(lastFiscalYear)){
                                                                                            rw.lastYearCount = 1;
                                                                                            totalAnsLastYearCount += 1;
                                                                                            if(duration != NULL){
                                                                                                totalAnsLastYearTimeSpent += duration;
                                                                                                totalAnsHudTimeSpent += duration;
                                                                                                rw.lastYearTimeSpent = duration != NULL ? duration + ':00' : '00:00';
                                                                                            }
                                                                                            rw.hudCount = 1;
                                                                                            totalAnsHudCount += 1;
                                                                                            rw.hudTimeSpent = rw.lastYearTimeSpent;
                                                                                        }*/
                                                                                        
                                                                                        rowWrapList.add(rw);
                                                                                    }
                                                                                }
                                                                            }
                                                                            
                                                                            RowWrapper totalAnswerRow = new RowWrapper();
                                                                            totalAnswerRow.subRowTotalLabel = 'Total for';
                                                                            totalAnswerRow.answer = answerLabel;
                                                                            
                                                                            totalAnswerRow.all = totalAnsAllCount;
                                                                            totalAnswerRow.allTimeSpent = totalAnsAllTimeSpent != 0 ? totalAnsAllTimeSpent + ':00' : '00:00';
                                                                            totalAnswerRow.currentYearCount = totalAnsCurrentYearCount;
                                                                            totalAnswerRow.currentYearTimeSpent = totalAnsCurrentYearTimeSpent != 0 ? totalAnsCurrentYearTimeSpent + ':00' : '00:00';
                                                                            totalAnswerRow.lastYearCount = totalAnsLastYearCount;
                                                                            totalAnswerRow.lastYearTimeSpent = totalAnsLastYearTimeSpent != 0 ? totalAnsLastYearTimeSpent + ':00' : '00:00';
                                                                            totalAnswerRow.hudCount = totalAnsHudCount;
                                                                            totalAnswerRow.hudTimeSpent = totalAnsHudTimeSpent != 0 ? totalAnsHudTimeSpent + ':00' : '00:00';
                                                                            
                                                                            ansWrap.totalAnswerRow = totalAnswerRow;
                                                                            ansWrap.rows = rowWrapList;
                                                                            ansWrap.needPagination = rowWrapList.size() > recsPerSection ? true : false;
                                                                            ansWrapList.add(ansWrap);
                                                                            
                                                                            totalAllCount += totalAnsAllCount;
                                                                            totalAllTimeSpent += totalAnsAllTimeSpent;
                                                                            totalCurrentYearCount += totalAnsCurrentYearCount;
                                                                            totalCurrentYearTimeSpent += totalAnsCurrentYearTimeSpent;
                                                                            totalLastYearCount += totalAnsLastYearCount;
                                                                            totalLastYearTimeSpent += totalAnsLastYearTimeSpent;
                                                                            totalHudCount += totalAnsHudCount;
                                                                            totalHudTimeSpent += totalAnsHudTimeSpent;
                                                                        }
                                                                    }
                                                                    RowWrapper totalParentRow = new RowWrapper();
                                                                    totalParentRow.subRowTotalLabel = 'Total for';
                                                                    totalParentRow.answer = section;
                                                                    
                                                                    totalParentRow.all = totalAllCount;
                                                                    totalParentRow.allTimeSpent = totalAllTimeSpent != 0 ? totalAllTimeSpent + ':00' : '00:00';
                                                                    totalParentRow.currentYearCount = totalCurrentYearCount;
                                                                    totalParentRow.currentYearTimeSpent = totalCurrentYearTimeSpent != 0 ? totalCurrentYearTimeSpent + ':00' : '00:00';
                                                                    totalParentRow.lastYearCount = totalLastYearCount;
                                                                    totalParentRow.lastYearTimeSpent = totalLastYearTimeSpent != 0 ? totalLastYearTimeSpent + ':00' : '00:00';
                                                                    totalParentRow.hudCount = totalHudCount;
                                                                    totalParentRow.hudTimeSpent = totalHudTimeSpent != 0 ? totalHudTimeSpent + ':00' : '00:00';
                                                                    
                                                                    prw.totalRow = totalParentRow;
                                                                    prw.answerRows = ansWrapList;
                                                                    recs.add(prw);
                                                                    
                                                                }
                                                                
                                                                result.recs = recs;
                                                                result.currentYear = currentFiscalYear;
                                                                result.lastYear = lastFiscalYear;
                                                                result.hudActivitySelected = hudActivitySelected;
                                                                
                                                                System.debug('picklistToActivityRecs->'+picklistToActivityRecs);
                                                                System.debug('result->'+result);
                                                            }
                                                            return result;
                                                        } catch(Exception exe){
                                                            throw new AuraHandledException(exe.getMessage());
                                                        }
                                                        
                                                        
                                                    }
    
    public static void addRecsToMap(String parentTag, String answer, sObject rec){
        if(!picklistToActivityRecs.containsKey(parentTag)){
            picklistToActivityRecs.put(parentTag, new Map<String, List<sObject>>());
        }
        
        Map<String, List<sObject>> recsMap = picklistToActivityRecs.get(parentTag);
        
        if(!recsMap.containsKey(answer)){
            recsMap.put(answer, new List<sObject>());
        }
        recsMap.get(answer).add(rec);
        
    }
    
    public class RetrunWrapper{
        @AuraEnabled
        public String currentYear{get; set;}
        @AuraEnabled
        public String lastYear{get; set;}
        @AuraEnabled
        public Set<String> hudActivitySelected{get; set;}
        @AuraEnabled
        public List<ParentRowWrapper> recs{get; set;}
    }
    
    public class ParentRowWrapper{
        @AuraEnabled
        public String rowName{get; set;}
        @AuraEnabled
        public List<AnswerWrapper> answerRows{get; set;}
        @AuraEnabled
        public RowWrapper totalRow{get; set;}
        @AuraEnabled
        public Boolean isExpanded{get; set;}
    }
    
    public class AnswerWrapper{
        @AuraEnabled
        public String answer{get; set;}
        @AuraEnabled
        public List<RowWrapper> rows{get; set;}
        @AuraEnabled
        public RowWrapper totalAnswerRow{get; set;}
        @AuraEnabled
        public Integer orderNo{get; set;}
        @AuraEnabled
        public Boolean needPagination{get; set;}
    }
    
    public class RowWrapper{
        @AuraEnabled
        public String recId{get; set;}
        @AuraEnabled
        public String clientNo{get; set;}
        @AuraEnabled
        public String clientId{get; set;}
        @AuraEnabled
        public String clientHref{get; set;}
        @AuraEnabled
        public String caseId{get; set;}
        @AuraEnabled
        public String caseHref{get; set;}
        @AuraEnabled
        public String caseNo{get; set;}
        @AuraEnabled
        public String name{get; set;}
        @AuraEnabled
        public String intakeOrClassDate{get; set;}
        @AuraEnabled
        public String subRowTotalLabel{get; set;}
        @AuraEnabled
        public String subCategory{get; set;}
        @AuraEnabled
        public String associatedActivity{get; set;}
        @AuraEnabled
        public String answer{get; set;}
        @AuraEnabled
        public Integer all{get; set;}
        @AuraEnabled
        public String allTimeSpent{get; set;}
        @AuraEnabled
        public Integer currentYearCount{get; set;}
        @AuraEnabled
        public String currentYearTimeSpent{get; set;}
        @AuraEnabled
        public Integer lastYearCount{get; set;}
        @AuraEnabled
        public String lastYearTimeSpent{get; set;}
        @AuraEnabled
        public Integer hudCount{get; set;}
        @AuraEnabled
        public String hudTimeSpent{get; set;}
        @AuraEnabled
        public String activityType{get; set;}
        @AuraEnabled
        public String recCount{get; set;}
        @AuraEnabled
        public Decimal timeSpentOnActivity{get; set;}
    }
    
}