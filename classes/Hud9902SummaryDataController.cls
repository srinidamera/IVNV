public class Hud9902SummaryDataController {
    public static DateTime qtrStartDateTime, qtrEndDateTime;
    public static Date qtrStartDate, qtrEndDate;
    public static String reportPeriod;
    public static String currentFiscalYear;
    public static String lastFiscalYear;
    public static Set<String> uniqueAppointmentClientPurposes = new Set<String>();
    public static Set<String> uniqueAttendanceClientPurposes = new Set<String>();
    public static Id fccRTId = Schema.SObjectType.ClientCase__c.getRecordTypeInfosByDeveloperName().get('FinancialCapabilityCounseling').getRecordTypeId();
    public static Id primaryClientRTId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('PrimaryClient').getRecordTypeId();
    
    public static Map<String, Set<String>> rowsBysections = new Map<String, Set<String>>{
        'Ethnicity' => new Set<String>{'Hispanic', 'Not Hispanic', 'EthnicityOther'},
            'Race' => new Set<String>{'American Indian/Alaskan Native', 'Asian', 'Black or African American', 'Native Hawaiian or Other Pacific Islander', 'More than one race', 'White', 'RaceOther'},
                'Income Levels' => new Set<String>{'Below 30% of AMI', '30 - 49% of AMI', '50 - 79% of AMI', '80 - 100% of AMI', '101% - 120% of AMI', 'AMIOther'},
                    'Rural Area Status' => new Set<String>{'Lives in a rural area', 'Does not live in a rural area', 'RuralOther'},
                        'English Proficiency' => new Set<String>{'Limited English Proficient', 'Not Limited English Proficient', 'EnglishOther'},
                            'Education'  => new Set<String>{'Completed financial literacy workshop, including home affordability, budgeting and understanding use of credit', 'Completed predatory lending, loan scam or other fraud prevention workshop', 'Completed fair housing workshop', 'Completed homelessness prevention workshop', 'Completed rental workshop', 'Completed pre-purchase homebuyer education workshop', 'Completed non-delinquency post-purchase workshop, including home maintenance and/or financial management for homeowners', 'Completed resolving or preventing mortgage delinquency workshop', 'Completed disaster preparedness assistance workshop', 'Completed disaster recovery assistance workshop'},
                                'Counseling' => new Set<String>{'Homeless Assistance', 'Rental Topics', 'Pre-purchase/Homebuying', 'Reverse Mortgage', 'Non-Delinquency Post-Purchase', 'Resolving or Preventing Forward Mortgage Delinquency or Default', 'Resolving or Preventing Reverse Mortgage Delinquency or Default', 'Disaster Preparedness Assistance', 'Disaster Recovery Assistance'},
                                    'Impact / Scope' => new Set<String>{'Households that received one-on-one counseling that also received education services.', 'Households that received information on fair housing, fair lending and/or accessibility rights.', 'Households for whom counselor developed a budget customized to a client’s current situation.', 'Households that improved their financial capacity (e.g. increased discretionary income, decreased debt load, increased savings, increased credit score, etc.) after receiving Housing Counseling Services.', 'Households that gained access to resources to help improve their housing situation (e.g. down payment assistance, rental assistance, utility assistance, etc.) after receiving Housing Counseling Services.', 'Households that gained access to non-housing resources (e.g. social service programs, legal services, public benefits such as Social Security or Medicaid, etc.) after receiving Housing Counseling Services', 'Homeless or potentially homeless households that obtained temporary or permanent housing after receiving Housing Counseling Services.', 'Households gained access to disaster recovery non-housing resources after receiving Housing Counseling Services (e.g. Red Cross/FEMA relief items, legal services, assistance).', 'Households obtained disaster recovery housing resources after receiving Housing Counseling Services (e.g. temporary shelter, homeowner rehab, relocation, etc.).', 'Households for whom counselor developed or updated an emergency preparedness plan.', 'Household that received rental counseling and avoided eviction after receiving Housing Counseling Services.', 'Households that received rental counseling and improved living conditions after receiving Housing Counseling Services.', 'Households that received pre-purchase/homebuying counseling and purchased housing after receiving Housing Counseling Services.', 'Households that received reverse mortgage counseling and obtained a Home Equity Conversion Mortgage (HECM) after receiving Housing Counseling Services.', 'Households that received non-delinquency post-purchase counseling that were able to improve home conditions or home affordability after receiving Housing Counseling Services', 'Households that prevented or resolved a forward mortgage default after receiving Housing Counseling Services.', 'Households that prevented or resolved a reverse mortgage default after receiving Housing Counseling Services.', 'Households that received a forward mortgage modification and remained current in their modified mortgage after receiving Housing Counseling Services.', 'Households that received a forward mortgage modification and improved their financial capacity after receiving Housing counseling Services.'}
    };        
        
        public static Map<String, String> labelTranslateForReport = new Map<String, String>{
            'EthnicityOther' => 'Chose not to respond',
                'RaceOther' => 'Chose not to respond',
                'AMIOther' => 'Chose not to respond',
                'RuralOther' => 'Chose not to respond',
                'EnglishOther' => 'Chose not to respond',
                'Below 30% of AMI' => '< 30% of Area Median Income (AMI)',
                '101% - 120% of AMI' => '> 100% of AMI'
                };
                    
                    public static Map<String, Integer> picklistToActivityCountAll = new Map<String, Integer> {
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
                            'EnglishOther' => 0,
                            'Completed financial literacy workshop, including home affordability, budgeting and understanding use of credit' => 0,
                            'Completed predatory lending, loan scam or other fraud prevention workshop' => 0,
                            'Completed fair housing workshop' => 0,
                            'Completed homelessness prevention workshop' => 0,
                            'Completed rental workshop' => 0,
                            'Completed pre-purchase homebuyer education workshop' => 0,
                            'Completed non-delinquency post-purchase workshop, including home maintenance and/or financial management for homeowners' => 0,
                            'Completed resolving or preventing mortgage delinquency workshop' => 0,
                            'Completed disaster preparedness assistance workshop' => 0,
                            'Completed disaster recovery assistance workshop' => 0,
                            'Homeless Assistance' => 0,
                            'Rental Topics' => 0,
                            'Pre-purchase/Homebuying' => 0,
                            'Reverse Mortgage' => 0,
                            'Non-Delinquency Post-Purchase' => 0,
                            'Resolving or Preventing Forward Mortgage Delinquency or Default' => 0,
                            'Resolving or Preventing Reverse Mortgage Delinquency or Default' => 0,
                            'Disaster Preparedness Assistance' => 0,
                            'Disaster Recovery Assistance' => 0,
                            'Households that received one-on-one counseling that also received education services.' => 0,
                            'Households that received information on fair housing, fair lending and/or accessibility rights.' => 0,
                            'Households for whom counselor developed a budget customized to a client’s current situation.' => 0,
                            'Households that improved their financial capacity (e.g. increased discretionary income, decreased debt load, increased savings, increased credit score, etc.) after receiving Housing Counseling Services.' => 0,
                            'Households that gained access to resources to help improve their housing situation (e.g. down payment assistance, rental assistance, utility assistance, etc.) after receiving Housing Counseling Services.' => 0,
                            'Households that gained access to non-housing resources (e.g. social service programs, legal services, public benefits such as Social Security or Medicaid, etc.) after receiving Housing Counseling Services' => 0,
                            'Homeless or potentially homeless households that obtained temporary or permanent housing after receiving Housing Counseling Services.' => 0,
                            'Households gained access to disaster recovery non-housing resources after receiving Housing Counseling Services (e.g. Red Cross/FEMA relief items, legal services, assistance).' => 0,
                            'Households obtained disaster recovery housing resources after receiving Housing Counseling Services (e.g. temporary shelter, homeowner rehab, relocation, etc.).' => 0,
                            'Households for whom counselor developed or updated an emergency preparedness plan.' => 0,
                            'Household that received rental counseling and avoided eviction after receiving Housing Counseling Services.' => 0,
                            'Households that received rental counseling and improved living conditions after receiving Housing Counseling Services.' => 0,
                            'Households that received pre-purchase/homebuying counseling and purchased housing after receiving Housing Counseling Services.' => 0,
                            'Households that received reverse mortgage counseling and obtained a Home Equity Conversion Mortgage (HECM) after receiving Housing Counseling Services.' => 0,
                            'Households that received non-delinquency post-purchase counseling that were able to improve home conditions or home affordability after receiving Housing Counseling Services' => 0,
                            'Households that prevented or resolved a forward mortgage default after receiving Housing Counseling Services.' => 0,
                            'Households that prevented or resolved a reverse mortgage default after receiving Housing Counseling Services.' => 0,
                            'Households that received a forward mortgage modification and remained current in their modified mortgage after receiving Housing Counseling Services.' => 0,
                            'Households that received a forward mortgage modification and improved their financial capacity after receiving Housing counseling Services.' => 0
                            
                            };
                                public static Map<String, Decimal> picklistToActivityDurationAll = new Map<String, Decimal> {
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
                                        'EnglishOther' => 0,
                                        'Completed financial literacy workshop, including home affordability, budgeting and understanding use of credit' => 0,
                                        'Completed predatory lending, loan scam or other fraud prevention workshop' => 0,
                                        'Completed fair housing workshop' => 0,
                                        'Completed homelessness prevention workshop' => 0,
                                        'Completed rental workshop' => 0,
                                        'Completed pre-purchase homebuyer education workshop' => 0,
                                        'Completed non-delinquency post-purchase workshop, including home maintenance and/or financial management for homeowners' => 0,
                                        'Completed resolving or preventing mortgage delinquency workshop' => 0,
                                        'Completed disaster preparedness assistance workshop' => 0,
                                        'Completed disaster recovery assistance workshop' => 0,
                                        'Homeless Assistance' => 0,
                                        'Rental Topics' => 0,
                                        'Pre-purchase/Homebuying' => 0,
                                        'Reverse Mortgage' => 0,
                                        'Non-Delinquency Post-Purchase' => 0,
                                        'Resolving or Preventing Forward Mortgage Delinquency or Default' => 0,
                                        'Resolving or Preventing Reverse Mortgage Delinquency or Default' => 0,
                                        'Disaster Preparedness Assistance' => 0,
                                        'Disaster Recovery Assistance' => 0,
                                        'Households that received one-on-one counseling that also received education services.' => 0,
                                        'Households that received information on fair housing, fair lending and/or accessibility rights.' => 0,
                                        'Households for whom counselor developed a budget customized to a client’s current situation.' => 0,
                                        'Households that improved their financial capacity (e.g. increased discretionary income, decreased debt load, increased savings, increased credit score, etc.) after receiving Housing Counseling Services.' => 0,
                                        'Households that gained access to resources to help improve their housing situation (e.g. down payment assistance, rental assistance, utility assistance, etc.) after receiving Housing Counseling Services.' => 0,
                                        'Households that gained access to non-housing resources (e.g. social service programs, legal services, public benefits such as Social Security or Medicaid, etc.) after receiving Housing Counseling Services' => 0,
                                        'Homeless or potentially homeless households that obtained temporary or permanent housing after receiving Housing Counseling Services.' => 0,
                                        'Households gained access to disaster recovery non-housing resources after receiving Housing Counseling Services (e.g. Red Cross/FEMA relief items, legal services, assistance).' => 0,
                                        'Households obtained disaster recovery housing resources after receiving Housing Counseling Services (e.g. temporary shelter, homeowner rehab, relocation, etc.).' => 0,
                                        'Households for whom counselor developed or updated an emergency preparedness plan.' => 0,
                                        'Household that received rental counseling and avoided eviction after receiving Housing Counseling Services.' => 0,
                                        'Households that received rental counseling and improved living conditions after receiving Housing Counseling Services.' => 0,
                                        'Households that received pre-purchase/homebuying counseling and purchased housing after receiving Housing Counseling Services.' => 0,
                                        'Households that received reverse mortgage counseling and obtained a Home Equity Conversion Mortgage (HECM) after receiving Housing Counseling Services.' => 0,
                                        'Households that received non-delinquency post-purchase counseling that were able to improve home conditions or home affordability after receiving Housing Counseling Services' => 0,
                                        'Households that prevented or resolved a forward mortgage default after receiving Housing Counseling Services.' => 0,
                                        'Households that prevented or resolved a reverse mortgage default after receiving Housing Counseling Services.' => 0,
                                        'Households that received a forward mortgage modification and remained current in their modified mortgage after receiving Housing Counseling Services.' => 0,
                                        'Households that received a forward mortgage modification and improved their financial capacity after receiving Housing counseling Services.' => 0
                                        };
                                            
                                            public static Map<String, Integer> picklistToActivityCountCurrentYear = new Map<String, Integer> {
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
                                                    'EnglishOther' => 0,
                                                    'Completed financial literacy workshop, including home affordability, budgeting and understanding use of credit' => 0,
                                                    'Completed predatory lending, loan scam or other fraud prevention workshop' => 0,
                                                    'Completed fair housing workshop' => 0,
                                                    'Completed homelessness prevention workshop' => 0,
                                                    'Completed rental workshop' => 0,
                                                    'Completed pre-purchase homebuyer education workshop' => 0,
                                                    'Completed non-delinquency post-purchase workshop, including home maintenance and/or financial management for homeowners' => 0,
                                                    'Completed resolving or preventing mortgage delinquency workshop' => 0,
                                                    'Completed disaster preparedness assistance workshop' => 0,
                                                    'Completed disaster recovery assistance workshop' => 0,
                                                    'Homeless Assistance' => 0,
                                                    'Rental Topics' => 0,
                                                    'Pre-purchase/Homebuying' => 0,
                                                    'Reverse Mortgage' => 0,
                                                    'Non-Delinquency Post-Purchase' => 0,
                                                    'Resolving or Preventing Forward Mortgage Delinquency or Default' => 0,
                                                    'Resolving or Preventing Reverse Mortgage Delinquency or Default' => 0,
                                                    'Disaster Preparedness Assistance' => 0,
                                                    'Disaster Recovery Assistance' => 0,
                                                    'Households that received one-on-one counseling that also received education services.' => 0,
                                                    'Households that received information on fair housing, fair lending and/or accessibility rights.' => 0,
                                                    'Households for whom counselor developed a budget customized to a client’s current situation.' => 0,
                                                    'Households that improved their financial capacity (e.g. increased discretionary income, decreased debt load, increased savings, increased credit score, etc.) after receiving Housing Counseling Services.' => 0,
                                                    'Households that gained access to resources to help improve their housing situation (e.g. down payment assistance, rental assistance, utility assistance, etc.) after receiving Housing Counseling Services.' => 0,
                                                    'Households that gained access to non-housing resources (e.g. social service programs, legal services, public benefits such as Social Security or Medicaid, etc.) after receiving Housing Counseling Services' => 0,
                                                    'Homeless or potentially homeless households that obtained temporary or permanent housing after receiving Housing Counseling Services.' => 0,
                                                    'Households gained access to disaster recovery non-housing resources after receiving Housing Counseling Services (e.g. Red Cross/FEMA relief items, legal services, assistance).' => 0,
                                                    'Households obtained disaster recovery housing resources after receiving Housing Counseling Services (e.g. temporary shelter, homeowner rehab, relocation, etc.).' => 0,
                                                    'Households for whom counselor developed or updated an emergency preparedness plan.' => 0,
                                                    'Household that received rental counseling and avoided eviction after receiving Housing Counseling Services.' => 0,
                                                    'Households that received rental counseling and improved living conditions after receiving Housing Counseling Services.' => 0,
                                                    'Households that received pre-purchase/homebuying counseling and purchased housing after receiving Housing Counseling Services.' => 0,
                                                    'Households that received reverse mortgage counseling and obtained a Home Equity Conversion Mortgage (HECM) after receiving Housing Counseling Services.' => 0,
                                                    'Households that received non-delinquency post-purchase counseling that were able to improve home conditions or home affordability after receiving Housing Counseling Services' => 0,
                                                    'Households that prevented or resolved a forward mortgage default after receiving Housing Counseling Services.' => 0,
                                                    'Households that prevented or resolved a reverse mortgage default after receiving Housing Counseling Services.' => 0,
                                                    'Households that received a forward mortgage modification and remained current in their modified mortgage after receiving Housing Counseling Services.' => 0,
                                                    'Households that received a forward mortgage modification and improved their financial capacity after receiving Housing counseling Services.' => 0
                                                    };
                                                        
                                                        public static Map<String, Decimal> picklistToActivityDurationCurrentYear = new Map<String, Decimal> {
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
                                                                'EnglishOther' => 0,
                                                                'Completed financial literacy workshop, including home affordability, budgeting and understanding use of credit' => 0,
                                                                'Completed predatory lending, loan scam or other fraud prevention workshop' => 0,
                                                                'Completed fair housing workshop' => 0,
                                                                'Completed homelessness prevention workshop' => 0,
                                                                'Completed rental workshop' => 0,
                                                                'Completed pre-purchase homebuyer education workshop' => 0,
                                                                'Completed non-delinquency post-purchase workshop, including home maintenance and/or financial management for homeowners' => 0,
                                                                'Completed resolving or preventing mortgage delinquency workshop' => 0,
                                                                'Completed disaster preparedness assistance workshop' => 0,
                                                                'Completed disaster recovery assistance workshop' => 0,
                                                                'Homeless Assistance' => 0,
                                                                'Rental Topics' => 0,
                                                                'Pre-purchase/Homebuying' => 0,
                                                                'Reverse Mortgage' => 0,
                                                                'Non-Delinquency Post-Purchase' => 0,
                                                                'Resolving or Preventing Forward Mortgage Delinquency or Default' => 0,
                                                                'Resolving or Preventing Reverse Mortgage Delinquency or Default' => 0,
                                                                'Disaster Preparedness Assistance' => 0,
                                                                'Disaster Recovery Assistance' => 0,
                                                                'Households that received one-on-one counseling that also received education services.' => 0,
                                                                'Households that received information on fair housing, fair lending and/or accessibility rights.' => 0,
                                                                'Households for whom counselor developed a budget customized to a client’s current situation.' => 0,
                                                                'Households that improved their financial capacity (e.g. increased discretionary income, decreased debt load, increased savings, increased credit score, etc.) after receiving Housing Counseling Services.' => 0,
                                                                'Households that gained access to resources to help improve their housing situation (e.g. down payment assistance, rental assistance, utility assistance, etc.) after receiving Housing Counseling Services.' => 0,
                                                                'Households that gained access to non-housing resources (e.g. social service programs, legal services, public benefits such as Social Security or Medicaid, etc.) after receiving Housing Counseling Services' => 0,
                                                                'Homeless or potentially homeless households that obtained temporary or permanent housing after receiving Housing Counseling Services.' => 0,
                                                                'Households gained access to disaster recovery non-housing resources after receiving Housing Counseling Services (e.g. Red Cross/FEMA relief items, legal services, assistance).' => 0,
                                                                'Households obtained disaster recovery housing resources after receiving Housing Counseling Services (e.g. temporary shelter, homeowner rehab, relocation, etc.).' => 0,
                                                                'Households for whom counselor developed or updated an emergency preparedness plan.' => 0,
                                                                'Household that received rental counseling and avoided eviction after receiving Housing Counseling Services.' => 0,
                                                                'Households that received rental counseling and improved living conditions after receiving Housing Counseling Services.' => 0,
                                                                'Households that received pre-purchase/homebuying counseling and purchased housing after receiving Housing Counseling Services.' => 0,
                                                                'Households that received reverse mortgage counseling and obtained a Home Equity Conversion Mortgage (HECM) after receiving Housing Counseling Services.' => 0,
                                                                'Households that received non-delinquency post-purchase counseling that were able to improve home conditions or home affordability after receiving Housing Counseling Services' => 0,
                                                                'Households that prevented or resolved a forward mortgage default after receiving Housing Counseling Services.' => 0,
                                                                'Households that prevented or resolved a reverse mortgage default after receiving Housing Counseling Services.' => 0,
                                                                'Households that received a forward mortgage modification and remained current in their modified mortgage after receiving Housing Counseling Services.' => 0,
                                                                'Households that received a forward mortgage modification and improved their financial capacity after receiving Housing counseling Services.' => 0
                                                                };
                                                                    
                                                                    public static Map<String, Integer> picklistToActivityCountLastYear = new Map<String, Integer> {
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
                                                                            'EnglishOther' => 0,
                                                                            'Completed financial literacy workshop, including home affordability, budgeting and understanding use of credit' => 0,
                                                                            'Completed predatory lending, loan scam or other fraud prevention workshop' => 0,
                                                                            'Completed fair housing workshop' => 0,
                                                                            'Completed homelessness prevention workshop' => 0,
                                                                            'Completed rental workshop' => 0,
                                                                            'Completed pre-purchase homebuyer education workshop' => 0,
                                                                            'Completed non-delinquency post-purchase workshop, including home maintenance and/or financial management for homeowners' => 0,
                                                                            'Completed resolving or preventing mortgage delinquency workshop' => 0,
                                                                            'Completed disaster preparedness assistance workshop' => 0,
                                                                            'Completed disaster recovery assistance workshop' => 0,
                                                                            'Homeless Assistance' => 0,
                                                                            'Rental Topics' => 0,
                                                                            'Pre-purchase/Homebuying' => 0,
                                                                            'Reverse Mortgage' => 0,
                                                                            'Non-Delinquency Post-Purchase' => 0,
                                                                            'Resolving or Preventing Forward Mortgage Delinquency or Default' => 0,
                                                                            'Resolving or Preventing Reverse Mortgage Delinquency or Default' => 0,
                                                                            'Disaster Preparedness Assistance' => 0,
                                                                            'Disaster Recovery Assistance' => 0,
                                                                            'Households that received one-on-one counseling that also received education services.' => 0,
                                                                            'Households that received information on fair housing, fair lending and/or accessibility rights.' => 0,
                                                                            'Households for whom counselor developed a budget customized to a client’s current situation.' => 0,
                                                                            'Households that improved their financial capacity (e.g. increased discretionary income, decreased debt load, increased savings, increased credit score, etc.) after receiving Housing Counseling Services.' => 0,
                                                                            'Households that gained access to resources to help improve their housing situation (e.g. down payment assistance, rental assistance, utility assistance, etc.) after receiving Housing Counseling Services.' => 0,
                                                                            'Households that gained access to non-housing resources (e.g. social service programs, legal services, public benefits such as Social Security or Medicaid, etc.) after receiving Housing Counseling Services' => 0,
                                                                            'Homeless or potentially homeless households that obtained temporary or permanent housing after receiving Housing Counseling Services.' => 0,
                                                                            'Households gained access to disaster recovery non-housing resources after receiving Housing Counseling Services (e.g. Red Cross/FEMA relief items, legal services, assistance).' => 0,
                                                                            'Households obtained disaster recovery housing resources after receiving Housing Counseling Services (e.g. temporary shelter, homeowner rehab, relocation, etc.).' => 0,
                                                                            'Households for whom counselor developed or updated an emergency preparedness plan.' => 0,
                                                                            'Household that received rental counseling and avoided eviction after receiving Housing Counseling Services.' => 0,
                                                                            'Households that received rental counseling and improved living conditions after receiving Housing Counseling Services.' => 0,
                                                                            'Households that received pre-purchase/homebuying counseling and purchased housing after receiving Housing Counseling Services.' => 0,
                                                                            'Households that received reverse mortgage counseling and obtained a Home Equity Conversion Mortgage (HECM) after receiving Housing Counseling Services.' => 0,
                                                                            'Households that received non-delinquency post-purchase counseling that were able to improve home conditions or home affordability after receiving Housing Counseling Services' => 0,
                                                                            'Households that prevented or resolved a forward mortgage default after receiving Housing Counseling Services.' => 0,
                                                                            'Households that prevented or resolved a reverse mortgage default after receiving Housing Counseling Services.' => 0,
                                                                            'Households that received a forward mortgage modification and remained current in their modified mortgage after receiving Housing Counseling Services.' => 0,
                                                                            'Households that received a forward mortgage modification and improved their financial capacity after receiving Housing counseling Services.' => 0
                                                                            };
                                                                                
                                                                                public static Map<String, Decimal> picklistToActivityDurationLastYear = new Map<String, Decimal> {
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
                                                                                        'EnglishOther' => 0,
                                                                                        'Completed financial literacy workshop, including home affordability, budgeting and understanding use of credit' => 0,
                                                                                        'Completed predatory lending, loan scam or other fraud prevention workshop' => 0,
                                                                                        'Completed fair housing workshop' => 0,
                                                                                        'Completed homelessness prevention workshop' => 0,
                                                                                        'Completed rental workshop' => 0,
                                                                                        'Completed pre-purchase homebuyer education workshop' => 0,
                                                                                        'Completed non-delinquency post-purchase workshop, including home maintenance and/or financial management for homeowners' => 0,
                                                                                        'Completed resolving or preventing mortgage delinquency workshop' => 0,
                                                                                        'Completed disaster preparedness assistance workshop' => 0,
                                                                                        'Completed disaster recovery assistance workshop' => 0,
                                                                                        'Homeless Assistance' => 0,
                                                                                        'Rental Topics' => 0,
                                                                                        'Pre-purchase/Homebuying' => 0,
                                                                                        'Reverse Mortgage' => 0,
                                                                                        'Non-Delinquency Post-Purchase' => 0,
                                                                                        'Resolving or Preventing Forward Mortgage Delinquency or Default' => 0,
                                                                                        'Resolving or Preventing Reverse Mortgage Delinquency or Default' => 0,
                                                                                        'Disaster Preparedness Assistance' => 0,
                                                                                        'Disaster Recovery Assistance' => 0,
                                                                                        'Households that received one-on-one counseling that also received education services.' => 0,
                                                                                        'Households that received information on fair housing, fair lending and/or accessibility rights.' => 0,
                                                                                        'Households for whom counselor developed a budget customized to a client’s current situation.' => 0,
                                                                                        'Households that improved their financial capacity (e.g. increased discretionary income, decreased debt load, increased savings, increased credit score, etc.) after receiving Housing Counseling Services.' => 0,
                                                                                        'Households that gained access to resources to help improve their housing situation (e.g. down payment assistance, rental assistance, utility assistance, etc.) after receiving Housing Counseling Services.' => 0,
                                                                                        'Households that gained access to non-housing resources (e.g. social service programs, legal services, public benefits such as Social Security or Medicaid, etc.) after receiving Housing Counseling Services' => 0,
                                                                                        'Homeless or potentially homeless households that obtained temporary or permanent housing after receiving Housing Counseling Services.' => 0,
                                                                                        'Households gained access to disaster recovery non-housing resources after receiving Housing Counseling Services (e.g. Red Cross/FEMA relief items, legal services, assistance).' => 0,
                                                                                        'Households obtained disaster recovery housing resources after receiving Housing Counseling Services (e.g. temporary shelter, homeowner rehab, relocation, etc.).' => 0,
                                                                                        'Households for whom counselor developed or updated an emergency preparedness plan.' => 0,
                                                                                        'Household that received rental counseling and avoided eviction after receiving Housing Counseling Services.' => 0,
                                                                                        'Households that received rental counseling and improved living conditions after receiving Housing Counseling Services.' => 0,
                                                                                        'Households that received pre-purchase/homebuying counseling and purchased housing after receiving Housing Counseling Services.' => 0,
                                                                                        'Households that received reverse mortgage counseling and obtained a Home Equity Conversion Mortgage (HECM) after receiving Housing Counseling Services.' => 0,
                                                                                        'Households that received non-delinquency post-purchase counseling that were able to improve home conditions or home affordability after receiving Housing Counseling Services' => 0,
                                                                                        'Households that prevented or resolved a forward mortgage default after receiving Housing Counseling Services.' => 0,
                                                                                        'Households that prevented or resolved a reverse mortgage default after receiving Housing Counseling Services.' => 0,
                                                                                        'Households that received a forward mortgage modification and remained current in their modified mortgage after receiving Housing Counseling Services.' => 0,
                                                                                        'Households that received a forward mortgage modification and improved their financial capacity after receiving Housing counseling Services.' => 0
                                                                                        };
                                                                                            public static Map<String, Integer> picklistToActivityCountHud = new Map<String, Integer> {
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
                                                                            'EnglishOther' => 0,
                                                                            'Completed financial literacy workshop, including home affordability, budgeting and understanding use of credit' => 0,
                                                                            'Completed predatory lending, loan scam or other fraud prevention workshop' => 0,
                                                                            'Completed fair housing workshop' => 0,
                                                                            'Completed homelessness prevention workshop' => 0,
                                                                            'Completed rental workshop' => 0,
                                                                            'Completed pre-purchase homebuyer education workshop' => 0,
                                                                            'Completed non-delinquency post-purchase workshop, including home maintenance and/or financial management for homeowners' => 0,
                                                                            'Completed resolving or preventing mortgage delinquency workshop' => 0,
                                                                            'Completed disaster preparedness assistance workshop' => 0,
                                                                            'Completed disaster recovery assistance workshop' => 0,
                                                                            'Homeless Assistance' => 0,
                                                                            'Rental Topics' => 0,
                                                                            'Pre-purchase/Homebuying' => 0,
                                                                            'Reverse Mortgage' => 0,
                                                                            'Non-Delinquency Post-Purchase' => 0,
                                                                            'Resolving or Preventing Forward Mortgage Delinquency or Default' => 0,
                                                                            'Resolving or Preventing Reverse Mortgage Delinquency or Default' => 0,
                                                                            'Disaster Preparedness Assistance' => 0,
                                                                            'Disaster Recovery Assistance' => 0,
                                                                            'Households that received one-on-one counseling that also received education services.' => 0,
                                                                            'Households that received information on fair housing, fair lending and/or accessibility rights.' => 0,
                                                                            'Households for whom counselor developed a budget customized to a client’s current situation.' => 0,
                                                                            'Households that improved their financial capacity (e.g. increased discretionary income, decreased debt load, increased savings, increased credit score, etc.) after receiving Housing Counseling Services.' => 0,
                                                                            'Households that gained access to resources to help improve their housing situation (e.g. down payment assistance, rental assistance, utility assistance, etc.) after receiving Housing Counseling Services.' => 0,
                                                                            'Households that gained access to non-housing resources (e.g. social service programs, legal services, public benefits such as Social Security or Medicaid, etc.) after receiving Housing Counseling Services' => 0,
                                                                            'Homeless or potentially homeless households that obtained temporary or permanent housing after receiving Housing Counseling Services.' => 0,
                                                                            'Households gained access to disaster recovery non-housing resources after receiving Housing Counseling Services (e.g. Red Cross/FEMA relief items, legal services, assistance).' => 0,
                                                                            'Households obtained disaster recovery housing resources after receiving Housing Counseling Services (e.g. temporary shelter, homeowner rehab, relocation, etc.).' => 0,
                                                                            'Households for whom counselor developed or updated an emergency preparedness plan.' => 0,
                                                                            'Household that received rental counseling and avoided eviction after receiving Housing Counseling Services.' => 0,
                                                                            'Households that received rental counseling and improved living conditions after receiving Housing Counseling Services.' => 0,
                                                                            'Households that received pre-purchase/homebuying counseling and purchased housing after receiving Housing Counseling Services.' => 0,
                                                                            'Households that received reverse mortgage counseling and obtained a Home Equity Conversion Mortgage (HECM) after receiving Housing Counseling Services.' => 0,
                                                                            'Households that received non-delinquency post-purchase counseling that were able to improve home conditions or home affordability after receiving Housing Counseling Services' => 0,
                                                                            'Households that prevented or resolved a forward mortgage default after receiving Housing Counseling Services.' => 0,
                                                                            'Households that prevented or resolved a reverse mortgage default after receiving Housing Counseling Services.' => 0,
                                                                            'Households that received a forward mortgage modification and remained current in their modified mortgage after receiving Housing Counseling Services.' => 0,
                                                                            'Households that received a forward mortgage modification and improved their financial capacity after receiving Housing counseling Services.' => 0
                                                                            };
                                                                                
                                                                                public static Map<String, Decimal> picklistToActivityDurationHud = new Map<String, Decimal> {
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
                                                                                        'EnglishOther' => 0,
                                                                                        'Completed financial literacy workshop, including home affordability, budgeting and understanding use of credit' => 0,
                                                                                        'Completed predatory lending, loan scam or other fraud prevention workshop' => 0,
                                                                                        'Completed fair housing workshop' => 0,
                                                                                        'Completed homelessness prevention workshop' => 0,
                                                                                        'Completed rental workshop' => 0,
                                                                                        'Completed pre-purchase homebuyer education workshop' => 0,
                                                                                        'Completed non-delinquency post-purchase workshop, including home maintenance and/or financial management for homeowners' => 0,
                                                                                        'Completed resolving or preventing mortgage delinquency workshop' => 0,
                                                                                        'Completed disaster preparedness assistance workshop' => 0,
                                                                                        'Completed disaster recovery assistance workshop' => 0,
                                                                                        'Homeless Assistance' => 0,
                                                                                        'Rental Topics' => 0,
                                                                                        'Pre-purchase/Homebuying' => 0,
                                                                                        'Reverse Mortgage' => 0,
                                                                                        'Non-Delinquency Post-Purchase' => 0,
                                                                                        'Resolving or Preventing Forward Mortgage Delinquency or Default' => 0,
                                                                                        'Resolving or Preventing Reverse Mortgage Delinquency or Default' => 0,
                                                                                        'Disaster Preparedness Assistance' => 0,
                                                                                        'Disaster Recovery Assistance' => 0,
                                                                                        'Households that received one-on-one counseling that also received education services.' => 0,
                                                                                        'Households that received information on fair housing, fair lending and/or accessibility rights.' => 0,
                                                                                        'Households for whom counselor developed a budget customized to a client’s current situation.' => 0,
                                                                                        'Households that improved their financial capacity (e.g. increased discretionary income, decreased debt load, increased savings, increased credit score, etc.) after receiving Housing Counseling Services.' => 0,
                                                                                        'Households that gained access to resources to help improve their housing situation (e.g. down payment assistance, rental assistance, utility assistance, etc.) after receiving Housing Counseling Services.' => 0,
                                                                                        'Households that gained access to non-housing resources (e.g. social service programs, legal services, public benefits such as Social Security or Medicaid, etc.) after receiving Housing Counseling Services' => 0,
                                                                                        'Homeless or potentially homeless households that obtained temporary or permanent housing after receiving Housing Counseling Services.' => 0,
                                                                                        'Households gained access to disaster recovery non-housing resources after receiving Housing Counseling Services (e.g. Red Cross/FEMA relief items, legal services, assistance).' => 0,
                                                                                        'Households obtained disaster recovery housing resources after receiving Housing Counseling Services (e.g. temporary shelter, homeowner rehab, relocation, etc.).' => 0,
                                                                                        'Households for whom counselor developed or updated an emergency preparedness plan.' => 0,
                                                                                        'Household that received rental counseling and avoided eviction after receiving Housing Counseling Services.' => 0,
                                                                                        'Households that received rental counseling and improved living conditions after receiving Housing Counseling Services.' => 0,
                                                                                        'Households that received pre-purchase/homebuying counseling and purchased housing after receiving Housing Counseling Services.' => 0,
                                                                                        'Households that received reverse mortgage counseling and obtained a Home Equity Conversion Mortgage (HECM) after receiving Housing Counseling Services.' => 0,
                                                                                        'Households that received non-delinquency post-purchase counseling that were able to improve home conditions or home affordability after receiving Housing Counseling Services' => 0,
                                                                                        'Households that prevented or resolved a forward mortgage default after receiving Housing Counseling Services.' => 0,
                                                                                        'Households that prevented or resolved a reverse mortgage default after receiving Housing Counseling Services.' => 0,
                                                                                        'Households that received a forward mortgage modification and remained current in their modified mortgage after receiving Housing Counseling Services.' => 0,
                                                                                        'Households that received a forward mortgage modification and improved their financial capacity after receiving Housing counseling Services.' => 0
                                                                                        };
                                                                                            
                                                                                            public static Map<String, List<DataWrapper>> picklistToEvtRec = new Map<String, List<DataWrapper>> {
                                                            'Hispanic' => new List<DataWrapper>(),
                                                                'Not Hispanic' => new List<DataWrapper>(),
                                                                'EthnicityOther' => new List<DataWrapper>(),
                                                                'American Indian/Alaskan Native' => new List<DataWrapper>(),
                                                                'Asian' => new List<DataWrapper>(),
                                                                'Black or African American' => new List<DataWrapper>(),
                                                                'Native Hawaiian or Other Pacific Islander' => new List<DataWrapper>(),
                                                                'More than one race' => new List<DataWrapper>(),
                                                                'White' => new List<DataWrapper>(),
                                                                'RaceOther' => new List<DataWrapper>(),
                                                                'Below 30% of AMI' => new List<DataWrapper>(),
                                                                '30 - 49% of AMI' => new List<DataWrapper>(),
                                                                '50 - 79% of AMI' => new List<DataWrapper>(),
                                                                '80 - 100% of AMI' => new List<DataWrapper>(),
                                                                '101% - 120% of AMI' => new List<DataWrapper>(),
                                                                'AMIOther' => new List<DataWrapper>(),
                                                                'Lives in a rural area' => new List<DataWrapper>(),
                                                                'Does not live in a rural area' => new List<DataWrapper>(),
                                                                'RuralOther' => new List<DataWrapper>(),
                                                                'Limited English Proficient' => new List<DataWrapper>(),
                                                                'Not Limited English Proficient' => new List<DataWrapper>(),
                                                                'EnglishOther' => new List<DataWrapper>(),
                                                                'Completed financial literacy workshop, including home affordability, budgeting and understanding use of credit' => new List<DataWrapper>(),
                                                                'Completed predatory lending, loan scam or other fraud prevention workshop' => new List<DataWrapper>(),
                                                                'Completed fair housing workshop' => new List<DataWrapper>(),
                                                                'Completed homelessness prevention workshop' => new List<DataWrapper>(),
                                                                'Completed rental workshop' => new List<DataWrapper>(),
                                                                'Completed pre-purchase homebuyer education workshop' => new List<DataWrapper>(),
                                                                'Completed non-delinquency post-purchase workshop, including home maintenance and/or financial management for homeowners' => new List<DataWrapper>(),
                                                                'Completed resolving or preventing mortgage delinquency workshop' => new List<DataWrapper>(),
                                                                'Completed disaster preparedness assistance workshop' => new List<DataWrapper>(),
                                                                'Completed disaster recovery assistance workshop' => new List<DataWrapper>(),
                                                                'Homeless Assistance' => new List<DataWrapper>(),
                                                                'Rental Topics' => new List<DataWrapper>(),
                                                                'Pre-purchase/Homebuying' => new List<DataWrapper>(),
                                                                'Reverse Mortgage' => new List<DataWrapper>(),
                                                                'Non-Delinquency Post-Purchase' => new List<DataWrapper>(),
                                                                'Resolving or Preventing Forward Mortgage Delinquency or Default' => new List<DataWrapper>(),
                                                                'Resolving or Preventing Reverse Mortgage Delinquency or Default' => new List<DataWrapper>(),
                                                                'Disaster Preparedness Assistance' => new List<DataWrapper>(),
                                                                'Disaster Recovery Assistance' => new List<DataWrapper>(),
                                                                'Households that received one-on-one counseling that also received education services.' => new List<DataWrapper>(),
                                                                'Households that received information on fair housing, fair lending and/or accessibility rights.' => new List<DataWrapper>(),
                                                                'Households for whom counselor developed a budget customized to a client’s current situation.' => new List<DataWrapper>(),
                                                                'Households that improved their financial capacity (e.g. increased discretionary income, decreased debt load, increased savings, increased credit score, etc.) after receiving Housing Counseling Services.' => new List<DataWrapper>(),
                                                                'Households that gained access to resources to help improve their housing situation (e.g. down payment assistance, rental assistance, utility assistance, etc.) after receiving Housing Counseling Services.' => new List<DataWrapper>(),
                                                                'Households that gained access to non-housing resources (e.g. social service programs, legal services, public benefits such as Social Security or Medicaid, etc.) after receiving Housing Counseling Services' => new List<DataWrapper>(),
                                                                'Homeless or potentially homeless households that obtained temporary or permanent housing after receiving Housing Counseling Services.' => new List<DataWrapper>(),
                                                                'Households gained access to disaster recovery non-housing resources after receiving Housing Counseling Services (e.g. Red Cross/FEMA relief items, legal services, assistance).' => new List<DataWrapper>(),
                                                                'Households obtained disaster recovery housing resources after receiving Housing Counseling Services (e.g. temporary shelter, homeowner rehab, relocation, etc.).' => new List<DataWrapper>(),
                                                                'Households for whom counselor developed or updated an emergency preparedness plan.' => new List<DataWrapper>(),
                                                                'Household that received rental counseling and avoided eviction after receiving Housing Counseling Services.' => new List<DataWrapper>(),
                                                                'Households that received rental counseling and improved living conditions after receiving Housing Counseling Services.' => new List<DataWrapper>(),
                                                                'Households that received pre-purchase/homebuying counseling and purchased housing after receiving Housing Counseling Services.' => new List<DataWrapper>(),
                                                                'Households that received reverse mortgage counseling and obtained a Home Equity Conversion Mortgage (HECM) after receiving Housing Counseling Services.' => new List<DataWrapper>(),
                                                                'Households that received non-delinquency post-purchase counseling that were able to improve home conditions or home affordability after receiving Housing Counseling Services' => new List<DataWrapper>(),
                                                                'Households that prevented or resolved a forward mortgage default after receiving Housing Counseling Services.' => new List<DataWrapper>(),
                                                                'Households that prevented or resolved a reverse mortgage default after receiving Housing Counseling Services.' => new List<DataWrapper>(),
                                                                'Households that received a forward mortgage modification and remained current in their modified mortgage after receiving Housing Counseling Services.' => new List<DataWrapper>(),
                                                                'Households that received a forward mortgage modification and improved their financial capacity after receiving Housing counseling Services.' => new List<DataWrapper>()
                                                                };
                                                                    Public static Set<String> hudActivitySelected = new Set<String>();
                                                                    
                                                                                         
                                                                                            @AuraEnabled(cacheable=true)
                                                                                            public static RetrunWrapper getData(String recordId){
                                                                                                RetrunWrapper result = new RetrunWrapper();
                                                                                                string NWC2NameSpace = Utility.getNwc2NameSpace();
                                                                                                try{
                                                                                                    if(String.isNotBlank(recordId)){
                                                                                                        X9902__c x9902 = [SELECT Id, PeriodStartDate__c, PeriodEndDate__c, Quarter__c FROM X9902__c WHERE Id = :recordId];
                                                                                                        
                                                                                                        qtrStartDate = x9902.PeriodStartDate__c;
                                                                                                        System.debug('qtrStartDate->'+qtrStartDate);
                                                                                                        qtrEndDate = x9902.PeriodEndDate__c;
                                                                                                        reportPeriod = x9902.Quarter__c;
                                                                                                        currentFiscalYear = x9902.PeriodEndDate__c != NULL ? String.valueOf(x9902.PeriodEndDate__c.year() - 1) : '';
                                                                                                        lastFiscalYear = x9902.PeriodEndDate__c != NULL ? String.valueOf(x9902.PeriodEndDate__c.year() - 2) : '';
                                                                                                        List<Event> eventList = new List<Event>();
                                                                                                        Contact con = new Contact();
                                                                                                        
                                                                                                        String WhatType = NWC2NameSpace + 'ClientCase__C';
                                                                                                        Integer newCount = 0;
                                                                                                        
                                                                                                        List<Event> appointmentList = [SELECT Id, WhatId, WhoId, Purpose__c, HUDActivityType__c, DurationInMinutes,
                                                                                                                                       TYPEOF Who
                                                                                                                                       WHEN Contact THEN Ethnicity__c, Race__c, AreaMedianIncome__c,RuralAreaStatus__c,EnglishProficiency__c, RecordType.Name
                                                                                                                                       END
                                                                                                                                       FROM Event 
                                                                                                                                       // WHERE (What.Type = 'ClientCase__C' OR Who.Type = 'Contact')
                                                                                                                                       WHERE Who.Type = 'Contact'
                                                                                                                                       AND What.Type = :WhatType
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
                                                                                                                    con = ev.Who;
                                                                                                                    if(con.Ethnicity__c == 'Hispanic'){
                                                                                                                        picklistToActivityCountAll.put('Hispanic', picklistToActivityCountAll.get('Hispanic') + 1);
                                                                                                                        picklistToEvtRec.get('Hispanic').add(new DataWrapper(ev.HUDActivityType__c, ev.DurationInMinutes));
                                                                                                                        if(ev.DurationInMinutes != NULL)
                                                                                                                        	picklistToActivityDurationAll.put('Hispanic', picklistToActivityDurationAll.get('Hispanic') + ev.DurationInMinutes);
                                                                                                                        updateCount(ev.HUDActivityType__c, con.Ethnicity__c,picklistToActivityCountCurrentYear, picklistToActivityCountLastYear, picklistToActivityDurationCurrentYear, picklistToActivityDurationLastYear, picklistToActivityCountHud, picklistToActivityDurationHud, ev.DurationInMinutes);
                                                                                                                    }else if(con.Ethnicity__c == 'Not Hispanic'){
                                                                                                                        picklistToActivityCountAll.put('Not Hispanic', picklistToActivityCountAll.get('Not Hispanic') + 1);
                                                                                                                        picklistToEvtRec.get('Not Hispanic').add(new DataWrapper(ev.HUDActivityType__c, ev.DurationInMinutes));
                                                                                                                        if(ev.DurationInMinutes != NULL)
                                                                                                                        	picklistToActivityDurationAll.put('Not Hispanic', picklistToActivityDurationAll.get('Not Hispanic') + ev.DurationInMinutes);
                                                                                                                        updateCount(ev.HUDActivityType__c, con.Ethnicity__c,picklistToActivityCountCurrentYear, picklistToActivityCountLastYear, picklistToActivityDurationCurrentYear, picklistToActivityDurationLastYear, picklistToActivityCountHud, picklistToActivityDurationHud, ev.DurationInMinutes);
                                                                                                                    }else{
                                                                                                                        picklistToActivityCountAll.put('EthnicityOther', picklistToActivityCountAll.get('EthnicityOther') + 1);
                                                                                                                        picklistToEvtRec.get('EthnicityOther').add(new DataWrapper(ev.HUDActivityType__c, ev.DurationInMinutes));
                                                                                                                        if(ev.DurationInMinutes != NULL)
                                                                                                                        	picklistToActivityDurationAll.put('EthnicityOther', picklistToActivityDurationAll.get('EthnicityOther') + ev.DurationInMinutes);
                                                                                                                        updateCount(ev.HUDActivityType__c, 'EthnicityOther',picklistToActivityCountCurrentYear, picklistToActivityCountLastYear, picklistToActivityDurationCurrentYear, picklistToActivityDurationLastYear, picklistToActivityCountHud, picklistToActivityDurationHud, ev.DurationInMinutes);
                                                                                                                    }
                                                                                                                    
                                                                                                                    if(con.Race__c == 'American Indian/Alaskan Native'){
                                                                                                                        picklistToActivityCountAll.put('American Indian/Alaskan Native', picklistToActivityCountAll.get('American Indian/Alaskan Native') + 1);
                                                                                                                        picklistToEvtRec.get('American Indian/Alaskan Native').add(new DataWrapper(ev.HUDActivityType__c, ev.DurationInMinutes));
                                                                                                                        if(ev.DurationInMinutes != NULL)
                                                                                                                        	picklistToActivityDurationAll.put('American Indian/Alaskan Native', picklistToActivityDurationAll.get('American Indian/Alaskan Native') + ev.DurationInMinutes);
                                                                                                                        updateCount(ev.HUDActivityType__c, con.Race__c,picklistToActivityCountCurrentYear, picklistToActivityCountLastYear, picklistToActivityDurationCurrentYear, picklistToActivityDurationLastYear, picklistToActivityCountHud, picklistToActivityDurationHud, ev.DurationInMinutes);
                                                                                                                    }else if(con.Race__c == 'Asian'){
                                                                                                                        picklistToActivityCountAll.put('Asian', picklistToActivityCountAll.get('Asian') + 1);
                                                                                                                        picklistToEvtRec.get('Asian').add(new DataWrapper(ev.HUDActivityType__c, ev.DurationInMinutes));
                                                                                                                        if(ev.DurationInMinutes != NULL)
                                                                                                                        	picklistToActivityDurationAll.put('Asian', picklistToActivityDurationAll.get('Asian') + ev.DurationInMinutes);
                                                                                                                        updateCount(ev.HUDActivityType__c, con.Race__c,picklistToActivityCountCurrentYear, picklistToActivityCountLastYear, picklistToActivityDurationCurrentYear, picklistToActivityDurationLastYear, picklistToActivityCountHud, picklistToActivityDurationHud, ev.DurationInMinutes);
                                                                                                                    }else if(con.Race__c == 'Black or African American'){
                                                                                                                        picklistToActivityCountAll.put('Black or African American', picklistToActivityCountAll.get('Black or African American') + 1);
                                                                                                                        picklistToEvtRec.get('Black or African American').add(new DataWrapper(ev.HUDActivityType__c, ev.DurationInMinutes));
                                                                                                                        if(ev.DurationInMinutes != NULL)
                                                                                                                        	picklistToActivityDurationAll.put('Black or African American', picklistToActivityDurationAll.get('Black or African American') + ev.DurationInMinutes);
                                                                                                                        updateCount(ev.HUDActivityType__c, con.Race__c,picklistToActivityCountCurrentYear, picklistToActivityCountLastYear, picklistToActivityDurationCurrentYear, picklistToActivityDurationLastYear, picklistToActivityCountHud, picklistToActivityDurationHud, ev.DurationInMinutes);
                                                                                                                    }else if(con.Race__c == 'Native Hawaiian or Other Pacific Islander'){
                                                                                                                        picklistToActivityCountAll.put('Native Hawaiian or Other Pacific Islander', picklistToActivityCountAll.get('Native Hawaiian or Other Pacific Islander') + 1);
                                                                                                                        picklistToEvtRec.get('Native Hawaiian or Other Pacific Islander').add(new DataWrapper(ev.HUDActivityType__c, ev.DurationInMinutes));
                                                                                                                        if(ev.DurationInMinutes != NULL)
                                                                                                                        	picklistToActivityDurationAll.put('Native Hawaiian or Other Pacific Islander', picklistToActivityDurationAll.get('Native Hawaiian or Other Pacific Islander') + ev.DurationInMinutes);
                                                                                                                        updateCount(ev.HUDActivityType__c, con.Race__c,picklistToActivityCountCurrentYear, picklistToActivityCountLastYear, picklistToActivityDurationCurrentYear, picklistToActivityDurationLastYear, picklistToActivityCountHud, picklistToActivityDurationHud, ev.DurationInMinutes);
                                                                                                                    }else if(con.Race__c == 'White'){
                                                                                                                        picklistToActivityCountAll.put('White', picklistToActivityCountAll.get('White') + 1);
                                                                                                                        picklistToEvtRec.get('White').add(new DataWrapper(ev.HUDActivityType__c, ev.DurationInMinutes));
                                                                                                                        if(ev.DurationInMinutes != NULL)
                                                                                                                        	picklistToActivityDurationAll.put('White', picklistToActivityDurationAll.get('White') + ev.DurationInMinutes);
                                                                                                                        updateCount(ev.HUDActivityType__c, con.Race__c,picklistToActivityCountCurrentYear, picklistToActivityCountLastYear, picklistToActivityDurationCurrentYear, picklistToActivityDurationLastYear, picklistToActivityCountHud, picklistToActivityDurationHud, ev.DurationInMinutes);
                                                                                                                    }else if(con.Race__c == 'More than one race'){
                                                                                                                        picklistToActivityCountAll.put('More than one race', picklistToActivityCountAll.get('More than one race') + 1);
                                                                                                                        picklistToEvtRec.get('More than one race').add(new DataWrapper(ev.HUDActivityType__c, ev.DurationInMinutes));
                                                                                                                        if(ev.DurationInMinutes != NULL)
                                                                                                                        	picklistToActivityDurationAll.put('More than one race', picklistToActivityDurationAll.get('More than one race') + ev.DurationInMinutes);
                                                                                                                        updateCount(ev.HUDActivityType__c, con.Race__c,picklistToActivityCountCurrentYear, picklistToActivityCountLastYear, picklistToActivityDurationCurrentYear, picklistToActivityDurationLastYear, picklistToActivityCountHud, picklistToActivityDurationHud, ev.DurationInMinutes);
                                                                                                                    }else {
                                                                                                                        picklistToActivityCountAll.put('RaceOther', picklistToActivityCountAll.get('RaceOther') + 1);
                                                                                                                        picklistToEvtRec.get('RaceOther').add(new DataWrapper(ev.HUDActivityType__c, ev.DurationInMinutes));
                                                                                                                        if(ev.DurationInMinutes != NULL)
                                                                                                                        	picklistToActivityDurationAll.put('RaceOther', picklistToActivityDurationAll.get('RaceOther') + ev.DurationInMinutes);
                                                                                                                        updateCount(ev.HUDActivityType__c, 'RaceOther',picklistToActivityCountCurrentYear, picklistToActivityCountLastYear, picklistToActivityDurationCurrentYear, picklistToActivityDurationLastYear, picklistToActivityCountHud, picklistToActivityDurationHud, ev.DurationInMinutes);
                                                                                                                    }
                                                                                                                    
                                                                                                                    if(con.AreaMedianIncome__c == 'Below 30% of AMI'){
                                                                                                                        picklistToActivityCountAll.put('Below 30% of AMI', picklistToActivityCountAll.get('Below 30% of AMI') + 1);
                                                                                                                        picklistToEvtRec.get('Below 30% of AMI').add(new DataWrapper(ev.HUDActivityType__c, ev.DurationInMinutes));
                                                                                                                        if(ev.DurationInMinutes != NULL)
                                                                                                                        	picklistToActivityDurationAll.put('Below 30% of AMI', picklistToActivityDurationAll.get('Below 30% of AMI') + ev.DurationInMinutes);
                                                                                                                        updateCount(ev.HUDActivityType__c, con.AreaMedianIncome__c,picklistToActivityCountCurrentYear, picklistToActivityCountLastYear, picklistToActivityDurationCurrentYear, picklistToActivityDurationLastYear, picklistToActivityCountHud, picklistToActivityDurationHud, ev.DurationInMinutes);
                                                                                                                    }else if(con.AreaMedianIncome__c == '30 - 49% of AMI'){
                                                                                                                        picklistToActivityCountAll.put('30 - 49% of AMI', picklistToActivityCountAll.get('30 - 49% of AMI') + 1);
                                                                                                                        picklistToEvtRec.get('30 - 49% of AMI').add(new DataWrapper(ev.HUDActivityType__c, ev.DurationInMinutes));
                                                                                                                        if(ev.DurationInMinutes != NULL)
                                                                                                                        	picklistToActivityDurationAll.put('30 - 49% of AMI', picklistToActivityDurationAll.get('30 - 49% of AMI') + ev.DurationInMinutes);
                                                                                                                        updateCount(ev.HUDActivityType__c, con.AreaMedianIncome__c,picklistToActivityCountCurrentYear, picklistToActivityCountLastYear, picklistToActivityDurationCurrentYear, picklistToActivityDurationLastYear, picklistToActivityCountHud, picklistToActivityDurationHud, ev.DurationInMinutes);
                                                                                                                    }else if(con.AreaMedianIncome__c == '50 - 79% of AMI'){
                                                                                                                        picklistToActivityCountAll.put('50 - 79% of AMI', picklistToActivityCountAll.get('50 - 79% of AMI') + 1);
                                                                                                                        picklistToEvtRec.get('50 - 79% of AMI').add(new DataWrapper(ev.HUDActivityType__c, ev.DurationInMinutes));
                                                                                                                        if(ev.DurationInMinutes != NULL)
                                                                                                                        	picklistToActivityDurationAll.put('50 - 79% of AMI', picklistToActivityDurationAll.get('50 - 79% of AMI') + ev.DurationInMinutes);
                                                                                                                        updateCount(ev.HUDActivityType__c, con.AreaMedianIncome__c,picklistToActivityCountCurrentYear, picklistToActivityCountLastYear, picklistToActivityDurationCurrentYear, picklistToActivityDurationLastYear, picklistToActivityCountHud, picklistToActivityDurationHud, ev.DurationInMinutes);
                                                                                                                    }else if(con.AreaMedianIncome__c == '80 - 100% of AMI'){
                                                                                                                        picklistToActivityCountAll.put('80 - 100% of AMI', picklistToActivityCountAll.get('80 - 100% of AMI') + 1);
                                                                                                                        picklistToEvtRec.get('80 - 100% of AMI').add(new DataWrapper(ev.HUDActivityType__c, ev.DurationInMinutes));
                                                                                                                        if(ev.DurationInMinutes != NULL)
                                                                                                                        	picklistToActivityDurationAll.put('80 - 100% of AMI', picklistToActivityDurationAll.get('80 - 100% of AMI') + ev.DurationInMinutes);
                                                                                                                        updateCount(ev.HUDActivityType__c, con.AreaMedianIncome__c,picklistToActivityCountCurrentYear, picklistToActivityCountLastYear, picklistToActivityDurationCurrentYear, picklistToActivityDurationLastYear, picklistToActivityCountHud, picklistToActivityDurationHud, ev.DurationInMinutes);
                                                                                                                    }else if(con.AreaMedianIncome__c == '101% - 120% of AMI' || con.AreaMedianIncome__c == 'Above 120% of AMI'){
                                                                                                                        picklistToActivityCountAll.put('101% - 120% of AMI', picklistToActivityCountAll.get('101% - 120% of AMI') + 1);
                                                                                                                        picklistToEvtRec.get('101% - 120% of AMI').add(new DataWrapper(ev.HUDActivityType__c, ev.DurationInMinutes));
                                                                                                                        if(ev.DurationInMinutes != NULL)
                                                                                                                        	picklistToActivityDurationAll.put('101% - 120% of AMI', picklistToActivityDurationAll.get('101% - 120% of AMI') + ev.DurationInMinutes);
                                                                                                                        updateCount(ev.HUDActivityType__c, '101% - 120% of AMI',picklistToActivityCountCurrentYear, picklistToActivityCountLastYear, picklistToActivityDurationCurrentYear, picklistToActivityDurationLastYear, picklistToActivityCountHud, picklistToActivityDurationHud, ev.DurationInMinutes);
                                                                                                                    }else{
                                                                                                                        picklistToActivityCountAll.put('AMIOther', picklistToActivityCountAll.get('AMIOther') + 1);
                                                                                                                        picklistToEvtRec.get('AMIOther').add(new DataWrapper(ev.HUDActivityType__c, ev.DurationInMinutes));
                                                                                                                        if(ev.DurationInMinutes != NULL)
                                                                                                                        	picklistToActivityDurationAll.put('AMIOther', picklistToActivityDurationAll.get('AMIOther') + ev.DurationInMinutes);
                                                                                                                        updateCount(ev.HUDActivityType__c, 'AMIOther',picklistToActivityCountCurrentYear, picklistToActivityCountLastYear, picklistToActivityDurationCurrentYear, picklistToActivityDurationLastYear, picklistToActivityCountHud, picklistToActivityDurationHud, ev.DurationInMinutes);
                                                                                                                    }
                                                                                                                    
                                                                                                                    if(con.RuralAreaStatus__c == 'Lives in a rural area'){
                                                                                                                        picklistToActivityCountAll.put('Lives in a rural area', picklistToActivityCountAll.get('Lives in a rural area') + 1);
                                                                                                                        picklistToEvtRec.get('Lives in a rural area').add(new DataWrapper(ev.HUDActivityType__c, ev.DurationInMinutes));
                                                                                                                        if(ev.DurationInMinutes != NULL)
                                                                                                                        	picklistToActivityDurationAll.put('Lives in a rural area', picklistToActivityDurationAll.get('Lives in a rural area') + ev.DurationInMinutes);
                                                                                                                        updateCount(ev.HUDActivityType__c, con.RuralAreaStatus__c,picklistToActivityCountCurrentYear, picklistToActivityCountLastYear, picklistToActivityDurationCurrentYear, picklistToActivityDurationLastYear, picklistToActivityCountHud, picklistToActivityDurationHud, ev.DurationInMinutes);
                                                                                                                    }else if(con.RuralAreaStatus__c == 'Does not live in a rural area'){
                                                                                                                        picklistToActivityCountAll.put('Does not live in a rural area', picklistToActivityCountAll.get('Does not live in a rural area') + 1);
                                                                                                                        picklistToEvtRec.get('Does not live in a rural area').add(new DataWrapper(ev.HUDActivityType__c, ev.DurationInMinutes));
                                                                                                                        if(ev.DurationInMinutes != NULL)
                                                                                                                        	picklistToActivityDurationAll.put('Does not live in a rural area', picklistToActivityDurationAll.get('Does not live in a rural area') + ev.DurationInMinutes);
                                                                                                                        updateCount(ev.HUDActivityType__c, con.RuralAreaStatus__c,picklistToActivityCountCurrentYear, picklistToActivityCountLastYear, picklistToActivityDurationCurrentYear, picklistToActivityDurationLastYear, picklistToActivityCountHud, picklistToActivityDurationHud, ev.DurationInMinutes);
                                                                                                                    }else{
                                                                                                                        picklistToActivityCountAll.put('RuralOther', picklistToActivityCountAll.get('RuralOther') + 1);
                                                                                                                        picklistToEvtRec.get('RuralOther').add(new DataWrapper(ev.HUDActivityType__c, ev.DurationInMinutes));
                                                                                                                        if(ev.DurationInMinutes != NULL)
                                                                                                                        	picklistToActivityDurationAll.put('RuralOther', picklistToActivityDurationAll.get('RuralOther') + ev.DurationInMinutes);
                                                                                                                        updateCount(ev.HUDActivityType__c, 'RuralOther',picklistToActivityCountCurrentYear, picklistToActivityCountLastYear, picklistToActivityDurationCurrentYear, picklistToActivityDurationLastYear, picklistToActivityCountHud, picklistToActivityDurationHud, ev.DurationInMinutes);
                                                                                                                    }
                                                                                                                    
                                                                                                                    if(con.EnglishProficiency__c == 'Limited English Proficient'){
                                                                                                                        picklistToActivityCountAll.put('Limited English Proficient', picklistToActivityCountAll.get('Limited English Proficient') + 1);
                                                                                                                        picklistToEvtRec.get('Limited English Proficient').add(new DataWrapper(ev.HUDActivityType__c, ev.DurationInMinutes));
                                                                                                                        if(ev.DurationInMinutes != NULL)
                                                                                                                        	picklistToActivityDurationAll.put('Limited English Proficient', picklistToActivityDurationAll.get('Limited English Proficient') + ev.DurationInMinutes);
                                                                                                                        updateCount(ev.HUDActivityType__c, con.EnglishProficiency__c,picklistToActivityCountCurrentYear, picklistToActivityCountLastYear, picklistToActivityDurationCurrentYear, picklistToActivityDurationLastYear, picklistToActivityCountHud, picklistToActivityDurationHud, ev.DurationInMinutes);
                                                                                                                    }else if(con.EnglishProficiency__c == 'Not Limited English Proficient'){
                                                                                                                        picklistToActivityCountAll.put('Not Limited English Proficient', picklistToActivityCountAll.get('Not Limited English Proficient') + 1);
                                                                                                                        picklistToEvtRec.get('Not Limited English Proficient').add(new DataWrapper(ev.HUDActivityType__c, ev.DurationInMinutes));
                                                                                                                        if(ev.DurationInMinutes != NULL)
                                                                                                                        	picklistToActivityDurationAll.put('Not Limited English Proficient', picklistToActivityDurationAll.get('Not Limited English Proficient') + ev.DurationInMinutes);
                                                                                                                        updateCount(ev.HUDActivityType__c, con.EnglishProficiency__c,picklistToActivityCountCurrentYear, picklistToActivityCountLastYear, picklistToActivityDurationCurrentYear, picklistToActivityDurationLastYear, picklistToActivityCountHud, picklistToActivityDurationHud, ev.DurationInMinutes);
                                                                                                                    }else{
                                                                                                                        picklistToActivityCountAll.put('EnglishOther', picklistToActivityCountAll.get('EnglishOther') + 1);
                                                                                                                        picklistToEvtRec.get('EnglishOther').add(new DataWrapper(ev.HUDActivityType__c, ev.DurationInMinutes));
                                                                                                                        if(ev.DurationInMinutes != NULL)
                                                                                                                        	picklistToActivityDurationAll.put('EnglishOther', picklistToActivityDurationAll.get('EnglishOther') + ev.DurationInMinutes);
                                                                                                                        updateCount(ev.HUDActivityType__c, 'EnglishOther',picklistToActivityCountCurrentYear, picklistToActivityCountLastYear, picklistToActivityDurationCurrentYear, picklistToActivityDurationLastYear, picklistToActivityCountHud, picklistToActivityDurationHud, ev.DurationInMinutes);
                                                                                                                    }
                                                                                                                }
                                                                                                            }
                                                                                                        }
                                                                                                        List<sumoapp__Attendee__c> attendeeList = [SELECT Id, Race__c, Ethnicity__c, AreaMedianIncome__c, sumoapp__SumoEvent__r.Name,
                                                                                                                                                   sumoapp__SumoEvent__r.Total_Duration_In_Minutes__c, sumoapp__SumoEvent__r.sumoapp__DurationInMinutes__c,
                                                                                                                                                   RuralAreaStatus__c, EnglishProficiency__c, sumoapp__SumoEvent__r.HUD_Purpose__c,
                                                                                                                                                   sumoapp__ContactRelation__c, sumoapp__SumoEvent__r.HUDActivityType__c, sumoapp__SumoEvent__r.RecordType.Name
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
                                                                                                            if(String.isNotBlank(att.sumoapp__SumoEvent__r.HUDActivityType__c) && att.sumoapp__SumoEvent__r.HUDActivityType__c != 'Not Billed to HUD'){
                                                                                                                hudActivitySelected.add(att.sumoapp__SumoEvent__r.HUDActivityType__c);
                                                                                                            }
                                                                                                            if(!uniqueAttendanceClientPurposes.contains(att.sumoapp__ContactRelation__c+'-'+att.sumoapp__SumoEvent__r.HUD_Purpose__c)){
                                                                                                                uniqueAttendanceClientPurposes.add(att.sumoapp__ContactRelation__c+'-'+att.sumoapp__SumoEvent__r.HUD_Purpose__c);
                                                                                                                Decimal duration = 0;
                                                                                                                if(att.sumoapp__SumoEvent__r.RecordType.Name == 'Course'){
                                                                                                                    duration = att.sumoapp__SumoEvent__r.Total_Duration_In_Minutes__c;
                                                                                                                } else if(att.sumoapp__SumoEvent__r.RecordType.Name == 'Event'){
                                                                                                                    duration = att.sumoapp__SumoEvent__r.sumoapp__DurationInMinutes__c;
                                                                                                                }
                                                                                                                if(att.Ethnicity__c == 'Hispanic'){
                                                                                                                    picklistToEvtRec.get('Hispanic').add(new DataWrapper(att.sumoapp__SumoEvent__r.HUDActivityType__c, duration));
                                                                                                                    picklistToActivityCountAll.put('Hispanic', picklistToActivityCountAll.get('Hispanic') + 1);
                                                                                                                    picklistToActivityDurationAll.put('Hispanic', picklistToActivityDurationAll.get('Hispanic') + duration);
                                                                                                                    
                                                                                                                    updateCount(att.sumoapp__SumoEvent__r.HUDActivityType__c, att.Ethnicity__c, picklistToActivityCountCurrentYear, picklistToActivityCountLastYear, picklistToActivityDurationCurrentYear, picklistToActivityDurationLastYear, picklistToActivityCountHud, picklistToActivityDurationHud, duration);
                                                                                                                }else if(att.Ethnicity__c == 'Not Hispanic'){
                                                                                                                    picklistToEvtRec.get('Not Hispanic').add(new DataWrapper(att.sumoapp__SumoEvent__r.HUDActivityType__c, duration));
                                                                                                                    picklistToActivityCountAll.put('Not Hispanic', picklistToActivityCountAll.get('Not Hispanic') + 1);
                                                                                                                    picklistToActivityDurationAll.put('Not Hispanic', picklistToActivityDurationAll.get('Not Hispanic') + duration);
                                                                                                                    updateCount(att.sumoapp__SumoEvent__r.HUDActivityType__c, att.Ethnicity__c, picklistToActivityCountCurrentYear, picklistToActivityCountLastYear, picklistToActivityDurationCurrentYear, picklistToActivityDurationLastYear, picklistToActivityCountHud, picklistToActivityDurationHud, duration);
                                                                                                                }else{
                                                                                                                    picklistToEvtRec.get('EthnicityOther').add(new DataWrapper(att.sumoapp__SumoEvent__r.HUDActivityType__c, duration));
                                                                                                                    picklistToActivityCountAll.put('EthnicityOther', picklistToActivityCountAll.get('EthnicityOther') + 1);
                                                                                                                    picklistToActivityDurationAll.put('EthnicityOther', picklistToActivityDurationAll.get('EthnicityOther') + duration);
                                                                                                                    updateCount(att.sumoapp__SumoEvent__r.HUDActivityType__c, 'EthnicityOther', picklistToActivityCountCurrentYear, picklistToActivityCountLastYear, picklistToActivityDurationCurrentYear, picklistToActivityDurationLastYear, picklistToActivityCountHud, picklistToActivityDurationHud, duration);
                                                                                                                }
                                                                                                                
                                                                                                                if(att.Race__c == 'American Indian/Alaskan Native'){
                                                                                                                    picklistToEvtRec.get('American Indian/Alaskan Native').add(new DataWrapper(att.sumoapp__SumoEvent__r.HUDActivityType__c, duration));
                                                                                                                    picklistToActivityCountAll.put('American Indian/Alaskan Native', picklistToActivityCountAll.get('American Indian/Alaskan Native') + 1);
                                                                                                                    picklistToActivityDurationAll.put('American Indian/Alaskan Native', picklistToActivityDurationAll.get('American Indian/Alaskan Native') + duration);
                                                                                                                    updateCount(att.sumoapp__SumoEvent__r.HUDActivityType__c, att.Race__c, picklistToActivityCountCurrentYear, picklistToActivityCountLastYear, picklistToActivityDurationCurrentYear, picklistToActivityDurationLastYear, picklistToActivityCountHud, picklistToActivityDurationHud, duration);
                                                                                                                }else if(att.Race__c == 'Asian'){
                                                                                                                    picklistToEvtRec.get('Asian').add(new DataWrapper(att.sumoapp__SumoEvent__r.HUDActivityType__c, duration));
                                                                                                                    picklistToActivityCountAll.put('Asian', picklistToActivityCountAll.get('Asian') + 1);
                                                                                                                    picklistToActivityDurationAll.put('Asian', picklistToActivityDurationAll.get('Asian') + duration);
                                                                                                                    updateCount(att.sumoapp__SumoEvent__r.HUDActivityType__c, att.Race__c, picklistToActivityCountCurrentYear, picklistToActivityCountLastYear, picklistToActivityDurationCurrentYear, picklistToActivityDurationLastYear, picklistToActivityCountHud, picklistToActivityDurationHud, duration);
                                                                                                                }else if(att.Race__c == 'Black or African American'){
                                                                                                                    picklistToEvtRec.get('Black or African American').add(new DataWrapper(att.sumoapp__SumoEvent__r.HUDActivityType__c, duration));
                                                                                                                    picklistToActivityCountAll.put('Black or African American', picklistToActivityCountAll.get('Black or African American') + 1);
                                                                                                                    picklistToActivityDurationAll.put('Black or African American', picklistToActivityDurationAll.get('Black or African American') + duration);
                                                                                                                    updateCount(att.sumoapp__SumoEvent__r.HUDActivityType__c, att.Race__c, picklistToActivityCountCurrentYear, picklistToActivityCountLastYear, picklistToActivityDurationCurrentYear, picklistToActivityDurationLastYear, picklistToActivityCountHud, picklistToActivityDurationHud, duration);
                                                                                                                }else if(att.Race__c == 'Native Hawaiian or Other Pacific Islander'){
                                                                                                                    picklistToEvtRec.get('Native Hawaiian or Other Pacific Islander').add(new DataWrapper(att.sumoapp__SumoEvent__r.HUDActivityType__c, duration));
                                                                                                                    picklistToActivityCountAll.put('Native Hawaiian or Other Pacific Islander', picklistToActivityCountAll.get('Native Hawaiian or Other Pacific Islander') + 1);
                                                                                                                    picklistToActivityDurationAll.put('Native Hawaiian or Other Pacific Islander', picklistToActivityDurationAll.get('Native Hawaiian or Other Pacific Islander') + duration);
                                                                                                                    updateCount(att.sumoapp__SumoEvent__r.HUDActivityType__c, att.Race__c, picklistToActivityCountCurrentYear, picklistToActivityCountLastYear, picklistToActivityDurationCurrentYear, picklistToActivityDurationLastYear, picklistToActivityCountHud, picklistToActivityDurationHud, duration);
                                                                                                                }else if(att.Race__c == 'White'){
                                                                                                                    picklistToEvtRec.get('White').add(new DataWrapper(att.sumoapp__SumoEvent__r.HUDActivityType__c, duration));
                                                                                                                    picklistToActivityCountAll.put('White', picklistToActivityCountAll.get('White') + 1);
                                                                                                                    picklistToActivityDurationAll.put('White', picklistToActivityDurationAll.get('White') + duration);
                                                                                                                    updateCount(att.sumoapp__SumoEvent__r.HUDActivityType__c, att.Race__c, picklistToActivityCountCurrentYear, picklistToActivityCountLastYear, picklistToActivityDurationCurrentYear, picklistToActivityDurationLastYear, picklistToActivityCountHud, picklistToActivityDurationHud, duration);
                                                                                                                }else if(att.Race__c == 'More than one race'){
                                                                                                                    picklistToEvtRec.get('More than one race').add(new DataWrapper(att.sumoapp__SumoEvent__r.HUDActivityType__c, duration));
                                                                                                                    picklistToActivityCountAll.put('More than one race', picklistToActivityCountAll.get('More than one race') + 1);
                                                                                                                    picklistToActivityDurationAll.put('More than one race', picklistToActivityDurationAll.get('More than one race') + duration);
                                                                                                                    updateCount(att.sumoapp__SumoEvent__r.HUDActivityType__c, att.Race__c, picklistToActivityCountCurrentYear, picklistToActivityCountLastYear, picklistToActivityDurationCurrentYear, picklistToActivityDurationLastYear, picklistToActivityCountHud, picklistToActivityDurationHud, duration);
                                                                                                                }else {
                                                                                                                    picklistToEvtRec.get('RaceOther').add(new DataWrapper(att.sumoapp__SumoEvent__r.HUDActivityType__c, duration));
                                                                                                                    picklistToActivityCountAll.put('RaceOther', picklistToActivityCountAll.get('RaceOther') + 1);
                                                                                                                    picklistToActivityDurationAll.put('RaceOther', picklistToActivityDurationAll.get('RaceOther') + duration);
                                                                                                                    updateCount(att.sumoapp__SumoEvent__r.HUDActivityType__c, 'RaceOther', picklistToActivityCountCurrentYear, picklistToActivityCountLastYear, picklistToActivityDurationCurrentYear, picklistToActivityDurationLastYear, picklistToActivityCountHud, picklistToActivityDurationHud, duration);
                                                                                                                }
                                                                                                                
                                                                                                                if(att.AreaMedianIncome__c == 'Below 30% of AMI'){
                                                                                                                    picklistToEvtRec.get('Below 30% of AMI').add(new DataWrapper(att.sumoapp__SumoEvent__r.HUDActivityType__c, duration));
                                                                                                                    picklistToActivityCountAll.put('Below 30% of AMI', picklistToActivityCountAll.get('Below 30% of AMI') + 1);
                                                                                                                    picklistToActivityDurationAll.put('Below 30% of AMI', picklistToActivityDurationAll.get('Below 30% of AMI') + duration);
                                                                                                                    updateCount(att.sumoapp__SumoEvent__r.HUDActivityType__c, att.AreaMedianIncome__c, picklistToActivityCountCurrentYear, picklistToActivityCountLastYear, picklistToActivityDurationCurrentYear, picklistToActivityDurationLastYear, picklistToActivityCountHud, picklistToActivityDurationHud, duration);
                                                                                                                }else if(att.AreaMedianIncome__c == '30 - 49% of AMI'){
                                                                                                                    picklistToEvtRec.get('30 - 49% of AMI').add(new DataWrapper(att.sumoapp__SumoEvent__r.HUDActivityType__c, duration));
                                                                                                                    picklistToActivityCountAll.put('30 - 49% of AMI', picklistToActivityCountAll.get('30 - 49% of AMI') + 1);
                                                                                                                    picklistToActivityDurationAll.put('30 - 49% of AMI', picklistToActivityDurationAll.get('30 - 49% of AMI') + duration);
                                                                                                                    updateCount(att.sumoapp__SumoEvent__r.HUDActivityType__c, att.AreaMedianIncome__c, picklistToActivityCountCurrentYear, picklistToActivityCountLastYear, picklistToActivityDurationCurrentYear, picklistToActivityDurationLastYear, picklistToActivityCountHud, picklistToActivityDurationHud, duration);
                                                                                                                }else if(att.AreaMedianIncome__c == '50 - 79% of AMI'){
                                                                                                                    picklistToEvtRec.get('50 - 79% of AMI').add(new DataWrapper(att.sumoapp__SumoEvent__r.HUDActivityType__c, duration));
                                                                                                                    picklistToActivityCountAll.put('50 - 79% of AMI', picklistToActivityCountAll.get('50 - 79% of AMI') + 1);
                                                                                                                    picklistToActivityDurationAll.put('50 - 79% of AMI', picklistToActivityDurationAll.get('50 - 79% of AMI') + duration);
                                                                                                                    updateCount(att.sumoapp__SumoEvent__r.HUDActivityType__c, att.AreaMedianIncome__c, picklistToActivityCountCurrentYear, picklistToActivityCountLastYear, picklistToActivityDurationCurrentYear, picklistToActivityDurationLastYear, picklistToActivityCountHud, picklistToActivityDurationHud, duration);
                                                                                                                }else if(att.AreaMedianIncome__c == '80 - 100% of AMI'){
                                                                                                                    picklistToEvtRec.get('80 - 100% of AMI').add(new DataWrapper(att.sumoapp__SumoEvent__r.HUDActivityType__c, duration));
                                                                                                                    picklistToActivityCountAll.put('80 - 100% of AMI', picklistToActivityCountAll.get('80 - 100% of AMI') + 1);
                                                                                                                    picklistToActivityDurationAll.put('80 - 100% of AMI', picklistToActivityDurationAll.get('80 - 100% of AMI') + duration);
                                                                                                                    updateCount(att.sumoapp__SumoEvent__r.HUDActivityType__c, att.AreaMedianIncome__c, picklistToActivityCountCurrentYear, picklistToActivityCountLastYear, picklistToActivityDurationCurrentYear, picklistToActivityDurationLastYear, picklistToActivityCountHud, picklistToActivityDurationHud, duration);
                                                                                                                }else if(att.AreaMedianIncome__c == '101% - 120% of AMI' || att.AreaMedianIncome__c == 'Above 120% of AMI'){
                                                                                                                    picklistToEvtRec.get('101% - 120% of AMI').add(new DataWrapper(att.sumoapp__SumoEvent__r.HUDActivityType__c, duration));
                                                                                                                    picklistToActivityCountAll.put('101% - 120% of AMI', picklistToActivityCountAll.get('101% - 120% of AMI') + 1);
                                                                                                                    picklistToActivityDurationAll.put('101% - 120% of AMI', picklistToActivityDurationAll.get('101% - 120% of AMI') + duration);
                                                                                                                    updateCount(att.sumoapp__SumoEvent__r.HUDActivityType__c, '101% - 120% of AMI', picklistToActivityCountCurrentYear, picklistToActivityCountLastYear, picklistToActivityDurationCurrentYear, picklistToActivityDurationLastYear, picklistToActivityCountHud, picklistToActivityDurationHud, duration);
                                                                                                                }else{
                                                                                                                    picklistToEvtRec.get('AMIOther').add(new DataWrapper(att.sumoapp__SumoEvent__r.HUDActivityType__c, duration));
                                                                                                                    picklistToActivityCountAll.put('AMIOther', picklistToActivityCountAll.get('AMIOther') + 1);
                                                                                                                    picklistToActivityDurationAll.put('AMIOther', picklistToActivityDurationAll.get('AMIOther') + duration);
                                                                                                                    updateCount(att.sumoapp__SumoEvent__r.HUDActivityType__c, 'AMIOther', picklistToActivityCountCurrentYear, picklistToActivityCountLastYear, picklistToActivityDurationCurrentYear, picklistToActivityDurationLastYear, picklistToActivityCountHud, picklistToActivityDurationHud, duration);
                                                                                                                }
                                                                                                                
                                                                                                                if(att.RuralAreaStatus__c == 'Lives in a rural area'){
                                                                                                                    picklistToEvtRec.get('Lives in a rural area').add(new DataWrapper(att.sumoapp__SumoEvent__r.HUDActivityType__c, duration));
                                                                                                                    picklistToActivityCountAll.put('Lives in a rural area', picklistToActivityCountAll.get('Lives in a rural area') + 1);
                                                                                                                    picklistToActivityDurationAll.put('Lives in a rural area', picklistToActivityDurationAll.get('Lives in a rural area') + duration);
                                                                                                                    updateCount(att.sumoapp__SumoEvent__r.HUDActivityType__c, att.RuralAreaStatus__c, picklistToActivityCountCurrentYear, picklistToActivityCountLastYear, picklistToActivityDurationCurrentYear, picklistToActivityDurationLastYear, picklistToActivityCountHud, picklistToActivityDurationHud, duration);
                                                                                                                }else if(att.RuralAreaStatus__c == 'Does not live in a rural area'){
                                                                                                                    picklistToEvtRec.get('Does not live in a rural area').add(new DataWrapper(att.sumoapp__SumoEvent__r.HUDActivityType__c, duration));
                                                                                                                    picklistToActivityCountAll.put('Does not live in a rural area', picklistToActivityCountAll.get('Does not live in a rural area') + 1);
                                                                                                                    picklistToActivityDurationAll.put('Does not live in a rural area', picklistToActivityDurationAll.get('Does not live in a rural area') + duration);
                                                                                                                    updateCount(att.sumoapp__SumoEvent__r.HUDActivityType__c, att.RuralAreaStatus__c, picklistToActivityCountCurrentYear, picklistToActivityCountLastYear, picklistToActivityDurationCurrentYear, picklistToActivityDurationLastYear, picklistToActivityCountHud, picklistToActivityDurationHud, duration);
                                                                                                                }else{
                                                                                                                    picklistToEvtRec.get('RuralOther').add(new DataWrapper(att.sumoapp__SumoEvent__r.HUDActivityType__c, duration));
                                                                                                                    picklistToActivityCountAll.put('RuralOther', picklistToActivityCountAll.get('RuralOther') + 1);
                                                                                                                    picklistToActivityDurationAll.put('RuralOther', picklistToActivityDurationAll.get('RuralOther') + duration);
                                                                                                                    updateCount(att.sumoapp__SumoEvent__r.HUDActivityType__c, 'RuralOther', picklistToActivityCountCurrentYear, picklistToActivityCountLastYear, picklistToActivityDurationCurrentYear, picklistToActivityDurationLastYear, picklistToActivityCountHud, picklistToActivityDurationHud, duration);
                                                                                                                }
                                                                                                                
                                                                                                                if(att.EnglishProficiency__c == 'Limited English Proficient'){
                                                                                                                    picklistToEvtRec.get('Limited English Proficient').add(new DataWrapper(att.sumoapp__SumoEvent__r.HUDActivityType__c, duration));
                                                                                                                    picklistToActivityCountAll.put('Limited English Proficient', picklistToActivityCountAll.get('Limited English Proficient') + 1);
                                                                                                                    picklistToActivityDurationAll.put('Limited English Proficient', picklistToActivityDurationAll.get('Limited English Proficient') + duration);
                                                                                                                    updateCount(att.sumoapp__SumoEvent__r.HUDActivityType__c, att.EnglishProficiency__c, picklistToActivityCountCurrentYear, picklistToActivityCountLastYear, picklistToActivityDurationCurrentYear, picklistToActivityDurationLastYear, picklistToActivityCountHud, picklistToActivityDurationHud, duration);
                                                                                                                }else if(att.EnglishProficiency__c == 'Not Limited English Proficient'){
                                                                                                                    picklistToEvtRec.get('Not Limited English Proficient').add(new DataWrapper(att.sumoapp__SumoEvent__r.HUDActivityType__c, duration));
                                                                                                                    picklistToActivityCountAll.put('Not Limited English Proficient', picklistToActivityCountAll.get('Not Limited English Proficient') + 1);
                                                                                                                    picklistToActivityDurationAll.put('Not Limited English Proficient', picklistToActivityDurationAll.get('Not Limited English Proficient') + duration);
                                                                                                                    updateCount(att.sumoapp__SumoEvent__r.HUDActivityType__c, att.EnglishProficiency__c, picklistToActivityCountCurrentYear, picklistToActivityCountLastYear, picklistToActivityDurationCurrentYear, picklistToActivityDurationLastYear, picklistToActivityCountHud, picklistToActivityDurationHud, duration);
                                                                                                                }else{
                                                                                                                    picklistToEvtRec.get('EnglishOther').add(new DataWrapper(att.sumoapp__SumoEvent__r.HUDActivityType__c, duration));
                                                                                                                    picklistToActivityCountAll.put('EnglishOther', picklistToActivityCountAll.get('EnglishOther') + 1);
                                                                                                                    picklistToActivityDurationAll.put('EnglishOther', picklistToActivityDurationAll.get('EnglishOther') + duration);
                                                                                                                    updateCount(att.sumoapp__SumoEvent__r.HUDActivityType__c, 'EnglishOther', picklistToActivityCountCurrentYear, picklistToActivityCountLastYear, picklistToActivityDurationCurrentYear, picklistToActivityDurationLastYear, picklistToActivityCountHud, picklistToActivityDurationHud, duration);
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
                                                                                                        
                                                                                                        for(sumoapp__AdditionalInfo__c course : [SELECT Id FROM sumoapp__AdditionalInfo__c 
                                                                                                                                                 WHERE RecordType.Name IN ('Course', 'Event')
                                                                                                                                                 AND IsParent__c = true
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
                                                                                                                    if(att.sumoapp__SumoEvent__r.Name == 'A-000194'){
                                                                                                                        System.debug('duraten->'+att.sumoapp__SumoEvent__r.Total_Duration_In_Minutes__c);
                                                                                                                    }
                                                                                                                    picklistToEvtRec.get(key).add(new DataWrapper(att.sumoapp__SumoEvent__r.HUDActivityType__c, att.sumoapp__SumoEvent__r.Total_Duration_In_Minutes__c));
                                                                                                                    updateCount(att.sumoapp__SumoEvent__r.HUDActivityType__c, key, picklistToActivityCountCurrentYear, picklistToActivityCountLastYear, picklistToActivityDurationCurrentYear, picklistToActivityDurationLastYear, picklistToActivityCountHud, picklistToActivityDurationHud, att.sumoapp__SumoEvent__r.Total_Duration_In_Minutes__c);
                                                                                                                    picklistToActivityCountAll.put(key, picklistToActivityCountAll.get(key) + 1);
                                                                                                                    if(att.sumoapp__SumoEvent__r.Total_Duration_In_Minutes__c != NULL)
                                                                                                                        picklistToActivityDurationAll.put(key, picklistToActivityDurationAll.get(key) + att.sumoapp__SumoEvent__r.Total_Duration_In_Minutes__c);
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
                                                                                                                    
                                                                                                                    picklistToEvtRec.get(key).add(new DataWrapper(ev.HUDActivityType__c, ev.DurationInMinutes));
                                                                                                                    updateCount(ev.HUDActivityType__c, key, picklistToActivityCountCurrentYear, picklistToActivityCountLastYear, picklistToActivityDurationCurrentYear, picklistToActivityDurationLastYear, picklistToActivityCountHud, picklistToActivityDurationHud, ev.DurationInMinutes);
                                                                                                                    picklistToActivityCountAll.put(key, picklistToActivityCountAll.get(key) + 1);
                                                                                                                    if(ev.DurationInMinutes != NULL)
                                                                                                                        picklistToActivityDurationAll.put(key, picklistToActivityDurationAll.get(key) + ev.DurationInMinutes);
                                                                                                                }
                                                                                                            }
                                                                                                        }
                                                                                                        
                                                                                                        eventList = [ SELECT WhoId, WhatId, Outcome__c, Purpose__c, HUDActivityType__c
                                                                                                                     FROM Event 
                                                                                                                     WHERE EndDateTime >= :qtrStartDate 
                                                                                                                     AND EndDateTime <= :qtrEndDate
                                                                                                                     AND Who.RecordTypeId = :primaryClientRTId
                                                                                                                     AND AppointmentStatus__c = 'Attended'
                                                                                                                     AND Purpose__c != 'Not HUD-Reportable'
                                                                                                                     AND Who.Type = 'Contact'
                                                                                                                     AND What.Type = :WhatType
                                                                                                                     // AND (Who.Type = 'Contact' OR What.Type = 'ClientCase__C')
                                                                                                                    ];
                                                                                                        Set<Id> clientCasesIds = new Set<Id>();
                                                                                                        for(Event evnt: eventList) {
                                                                                                            clientCasesIds.add(evnt.WhatId);
                                                                                                        }
                                                                                                        System.debug('clientCasesIds->'+clientCasesIds);
                                                                                                        List<Event> eventList2 = [ SELECT WhoId, WhatId, Outcome__c, Purpose__c, HUDActivityType__c
                                                                                                                                  FROM Event 
                                                                                                                                  WHERE EndDateTime < :qtrStartDate
                                                                                                                                  AND Who.RecordTypeId = :primaryClientRTId
                                                                                                                                  AND WhatId IN :clientCasesIds
                                                                                                                                  AND Who.Type = 'Contact'
                                                                                                                                  AND What.Type = :WhatType
                                                                                                                                 ];
                                                                                                        if(!eventList2.isEmpty()) {
                                                                                                            eventList.addAll(eventList2);
                                                                                                        }
                                                                                                        
                                                                                                        Map<String, Integer> outcomeCountMap = new Map<String, Integer>();
                                                                                                        
                                                                                                        outcomeCountMap = getOutcomeCountMap(eventList, false, '');
                                                                                                        
                                                                                                        if(outcomeCountMap != null){
                                                                                                            for(String outcome : outcomeCountMap.keySet()){
                                                                                                                picklistToActivityCountAll.put(outcome, outcomeCountMap.get(outcome));
                                                                                                            }
                                                                                                        }
                                                                                                        
                                                                                                        outcomeCountMap = getOutcomeCountMap(eventList, true, currentFiscalYear);
                                                                                                        
                                                                                                        if(outcomeCountMap != null){
                                                                                                            for(String outcome : outcomeCountMap.keySet()){
                                                                                                                picklistToActivityCountCurrentYear.put(outcome, outcomeCountMap.get(outcome));
                                                                                                            }
                                                                                                        }
                                                                                                        
                                                                                                        outcomeCountMap = getOutcomeCountMap(eventList, true, lastFiscalYear);
                                                                                                        
                                                                                                        if(outcomeCountMap != null){
                                                                                                            for(String outcome : outcomeCountMap.keySet()){
                                                                                                                picklistToActivityCountLastYear.put(outcome, outcomeCountMap.get(outcome));
                                                                                                            }
                                                                                                        }
                                                                                                        
                                                                                                        outcomeCountMap = getOutcomeCountMap(eventList, true, '');
                                                                                                        
                                                                                                        if(outcomeCountMap != null){
                                                                                                            for(String outcome : outcomeCountMap.keySet()){
                                                                                                                picklistToActivityCountHud.put(outcome, outcomeCountMap.get(outcome));
                                                                                                            }
                                                                                                        }
                                                                                                        
                                                                                                        outcomeCountMap = getOutcomeCountMap1(eventList, true, '');
                                                                                                        
                                                                                                    }
                                                                                                    
                                                                                                    List<ParentRowWrapper> recs = new List<ParentRowWrapper>();
                                                                                                    
                                                                                                    for(String section : rowsBysections.keySet()){
                                                                                                        ParentRowWrapper prw = new ParentRowWrapper();
                                                                                                        prw.rowName = section;
                                                                                                        
                                                                                                        List<RowWrapper> rwList = new List<RowWrapper>();
                                                                                                        
                                                                                                        Integer totalAllCount = 0;
                                                                                                        Decimal totalAllTimeSpent = 0;
                                                                                                        Integer totalCurrentYearCount = 0;
                                                                                                        Decimal totalCurrentYearTimeSpent = 0;
                                                                                                        Integer totalLastYearCount = 0;
                                                                                                        Decimal totalLastYearTimeSpent = 0;
                                                                                                        Integer totalHudCount = 0;
                                                                                                        Decimal totalHudTimeSpent = 0;
                                                                                                        
                                                                                                        for(String answer : rowsBysections.get(section)){
                                                                                                            RowWrapper rw = new RowWrapper();
                                                                                                            
                                                                                                            rw.answer = labelTranslateForReport.containsKey(answer) ? labelTranslateForReport.get(answer) : answer;
                                                                                                            rw.all = picklistToActivityCountAll.containsKey(answer) ? picklistToActivityCountAll.get(answer) : 0;
                                                                                                            //rw.allTimeSpent = picklistToActivityDurationAll.containsKey(answer) ? DateTime.valueOf(picklistToActivityDurationAll.get(answer) * 60 * 1000).formatGMT('DD:HH:mm') : null;
                                                                                                            rw.allTimeSpent = picklistToActivityDurationAll.containsKey(answer) && picklistToActivityDurationAll.get(answer) != 0 ? picklistToActivityDurationAll.get(answer) + ':00' : '00:00';
                                                                                                            rw.currentYearCount = picklistToActivityCountCurrentYear.containsKey(answer) ? picklistToActivityCountCurrentYear.get(answer) : 0;
                                                                                                            //rw.currentYearTimeSpent = picklistToActivityDurationCurrentYear.containsKey(answer) ? DateTime.valueOf(picklistToActivityDurationCurrentYear.get(answer) * 60 * 1000).formatGMT('DD:HH:mm') : '0';
                                                                                                            rw.currentYearTimeSpent = picklistToActivityDurationCurrentYear.containsKey(answer) && picklistToActivityDurationCurrentYear.get(answer) != 0 ? picklistToActivityDurationCurrentYear.get(answer) + ':00' : '00:00';
                                                                                                            rw.lastYearCount = picklistToActivityCountLastYear.containsKey(answer) ? picklistToActivityCountLastYear.get(answer) : 0;
                                                                                                            //rw.lastYearTimeSpent = picklistToActivityDurationLastYear.containskey(answer) ? DateTime.valueOf(picklistToActivityDurationLastYear.get(answer) * 60 * 1000).formatGMT('DD:HH:mm') : '00:00';
                                                                                                            rw.lastYearTimeSpent = picklistToActivityDurationLastYear.containskey(answer) && picklistToActivityDurationLastYear.get(answer) != 0 ? picklistToActivityDurationLastYear.get(answer) + ':00' : '00:00';
                                                                                                            rw.hudCount =  picklistToActivityCountHud.containsKey(answer) ?  picklistToActivityCountHud.get(answer) : 0;
                                                                                                            rw.hudTimeSpent = picklistToActivityDurationHud.containskey(answer) && picklistToActivityDurationHud.get(answer) != 0 ? picklistToActivityDurationHud.get(answer) + ':00' : '00:00';
                                                                                                            rw.recs = picklistToEvtRec.containskey(answer) ? picklistToEvtRec.get(answer) : new List<DataWrapper>();
                                                                                                            
                                                                                                            if(rw.all > 0){
                                                                                                                rw.showRow = true;
                                                                                                                totalAllCount += picklistToActivityCountAll.containskey(answer) ? picklistToActivityCountAll.get(answer) : 0;
                                                                                                                totalAllTimeSpent += picklistToActivityDurationAll.containskey(answer) ? picklistToActivityDurationAll.get(answer) : 0;
                                                                                                                totalCurrentYearCount += picklistToActivityCountCurrentYear.containskey(answer) ? picklistToActivityCountCurrentYear.get(answer) : 0;
                                                                                                                totalCurrentYearTimeSpent += picklistToActivityDurationCurrentYear.containskey(answer) ? picklistToActivityDurationCurrentYear.get(answer) : 0;
                                                                                                                totalLastYearCount += picklistToActivityCountLastYear.containskey(answer) ? picklistToActivityCountLastYear.get(answer) : 0;
                                                                                                                totalLastYearTimeSpent += picklistToActivityDurationLastYear.containskey(answer) ? picklistToActivityDurationLastYear.get(answer) : 0;
                                                                                                                totalHudCount += picklistToActivityCountHud.containskey(answer) ? picklistToActivityCountHud.get(answer) : 0;
                                                                                                                totalHudTimeSpent += picklistToActivityDurationHud.containskey(answer) ? picklistToActivityDurationHud.get(answer) : 0;
                                                                                                                
                                                                                                                rwList.add(rw);
                                                                                                            }
                                                                                                        }
                                                                                                        
                                                                                                        RowWrapper totalRow = new RowWrapper();
                                                                                                        
                                                                                                        totalRow.answer = 'Totals for ' + section;
                                                                                                        totalRow.all = totalAllCount;
                                                                                                        totalRow.allTimeSpent = totalAllTimeSpent != 0 ? totalAllTimeSpent + ':00' : '00:00';
                                                                                                        totalRow.currentYearCount = totalCurrentYearCount;
                                                                                                        totalRow.currentYearTimeSpent = totalCurrentYearTimeSpent != 0 ? totalCurrentYearTimeSpent + ':00' : '00:00';
                                                                                                        totalRow.lastYearCount = totalLastYearCount;
                                                                                                        totalRow.lastYearTimeSpent = totalLastYearTimeSpent != 0 ? totalLastYearTimeSpent + ':00' : '00:00';
                                                                                                        totalRow.hudCount = totalHudCount;
                                                                                                        totalRow.hudTimeSpent = totalHudTimeSpent != 0 ? totalHudTimeSpent + ':00' : '00:00';
                                                                                                        
                                                                                                        prw.rows = rwList;
                                                                                                        prw.totalRow = totalRow;
                                                                                                        
                                                                                                        recs.add(prw);
                                                                                                        
                                                                                                    }
                                                                                                    
                                                                                                    result.recs = recs;
                                                                                                    result.currentYear = currentFiscalYear;
                                                                                                    result.lastYear = lastFiscalYear;
                                                                                                    result.hudActivitySelected = hudActivitySelected;
                                                                                                    
                                                                                                    System.debug('result->'+result);
                                                                                                    return result;
                                                                                                } catch(Exception exe){
                                                                                                    throw new AuraHandledException(exe.getMessage());
                                                                                                }
                                                                                                
                                                                                                
                                                                                            }
    
    public static Map<String,Integer> getOutcomeCountMap(List<Event> events, Boolean isHUDBilable, String fiscalYear){
        List<String> outcomeArray = new List<String>();
        Map<String, Set<Id>> outcomeToClientCase = new Map<String, Set<Id>>();
        Map<String, Integer> outcomeCountMap = new Map<String, Integer>();
        for(Event evt: events) {
            
            if(isHUDBilable && (evt.HUDActivityType__c == NULL || evt.HUDActivityType__c == 'Not Billed to HUD' || (String.isNotBlank(fiscalYear) && String.isNotBlank(evt.HUDActivityType__c) && !evt.HUDActivityType__c.containsIgnoreCase(fiscalYear)))){
                continue;
            }
            /*if(isHUDBilable && evt.HUDActivityType__c == 'Not Billed to HUD'){
continue;
}*/
            outcomeArray = String.isNotBlank(evt.Outcome__c) ? evt.Outcome__c.split(';') : new List<String>();
            System.debug('outcomeArray->'+outcomeArray);
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
    
    public static Map<String,Integer> getOutcomeCountMap1(List<Event> events, Boolean isHUDBilable, String fiscalYear){
        List<String> outcomeArray = new List<String>();
        Map<String, Set<Id>> outcomeToClientCase = new Map<String, Set<Id>>();
        Map<String, Integer> outcomeCountMap = new Map<String, Integer>();
        for(Event evt: events) {
            
            if(isHUDBilable && (evt.HUDActivityType__c == NULL || evt.HUDActivityType__c == 'Not Billed to HUD')){
                continue;
            }
            /*if(isHUDBilable && evt.HUDActivityType__c == 'Not Billed to HUD'){
continue;
}*/
            if(String.isNotBlank(evt.HUDActivityType__c) && evt.HUDActivityType__c != 'Not Billed to HUD'){
                hudActivitySelected.add(evt.HUDActivityType__c);
            }
            outcomeArray = String.isNotBlank(evt.Outcome__c) ? evt.Outcome__c.split(';') : new List<String>();
            System.debug('outcomeArray->'+outcomeArray);
            if (!outcomeArray.isEmpty()) {
                for(String outcome: outcomeArray) {
                    if (outcomeToClientCase.containsKey(outcome)) {
                        if(!outcomeToClientCase.get(outcome).contains(evt.WhatId)){
                            picklistToEvtRec.get(outcome).add(new DataWrapper(evt.HUDActivityType__c, 0));
                        }
                        outcomeToClientCase.get(outcome).add(evt.WhatId);
                        
                        
                    } else {
                        outcomeToClientCase.put(outcome, new Set<Id> { evt.WhatId});
                        picklistToEvtRec.get(outcome).add(new DataWrapper(evt.HUDActivityType__c, 0));
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
    
    public static void updateCount(String hudActivityType, String key, Map<String, Integer> picklistToActivityCountCurrentYear, Map<String, Integer> picklistToActivityCountLastYear, Map<String, Decimal> picklistToActivityDurationCurrentYear, Map<String, Decimal> picklistToActivityDurationLastYear, Map<String, Integer> picklistToActivityCountHud, Map<String, Decimal> picklistToActivityDurationHud, Decimal duration){
        if(String.isNotBlank(hudActivityType)){
            if(hudActivityType.containsIgnoreCase(currentFiscalYear)){
                picklistToActivityCountCurrentYear.put(key, picklistToActivityCountCurrentYear.get(key) + 1);
                if(duration != NULL)
                    picklistToActivityDurationCurrentYear.put(key, picklistToActivityDurationCurrentYear.get(key) + duration);
            } else if(hudActivityType.containsIgnoreCase(lastFiscalYear)){
                picklistToActivityCountLastYear.put(key, picklistToActivityCountLastYear.get(key) + 1);
                if(duration != NULL)
                    picklistToActivityDurationLastYear.put(key, picklistToActivityDurationLastYear.get(key) + duration);
            }
            if(hudActivityType != 'Not Billed to HUD'){
                picklistToActivityCountHud.put(key, picklistToActivityCountHud.get(key) + 1);
                if(duration != NULL)
                    picklistToActivityDurationHud.put(key, picklistToActivityDurationHud.get(key) + duration);
            }
            
        }
        
    }
    
    public class RetrunWrapper{
        @AuraEnabled
        public String currentYear{get; set;}
        @AuraEnabled
        public String lastYear{get; set;}
        @AuraEnabled
        public List<ParentRowWrapper> recs{get; set;}
        @AuraEnabled
        public Set<String> hudActivitySelected{get; set;}
    }
    
    public class ParentRowWrapper{
        @AuraEnabled
        public String rowName{get; set;}
        @AuraEnabled
        public List<RowWrapper> rows{get; set;}
        @AuraEnabled
        public RowWrapper totalRow{get; set;}
    }
    
    public class RowWrapper{
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
        public Boolean showRow{get; set;}
        @AuraEnabled
        public List<Event> evtRecs{get; set;}
        @AuraEnabled
        public List<sumoapp__Attendee__c> attRecs{get; set;}
        @AuraEnabled
        public List<DataWrapper> recs{get; set;}
        
    }
    
    public class DataWrapper{
        @AuraEnabled
        public String activityType{get; set;}
        @AuraEnabled
        public Decimal timeSpent{get; set;}
        
        public DataWrapper(String activityType, Decimal timeSpent){
            this.activityType = activityType;
            this.timeSpent = timeSpent;
        }
    }
    
}