/**
*Desc: An apex class controller for IntakePDF data retrieving 
*/
public with sharing class IntakePDFController {
    public Id intakeId { get; set; }
    public AgencyProfile__c footer { get; set; }
    public Intake__c intake { get; set; }
    public String currentDate { get; set; }
    public String OccupationStartDate { get; set; }
    public String Birthdate { get; set; }
    public String ageAsString { get; set; }
    public String MarketingCommunicationsOptOut { get; set; }
    public STring AnnualHouseholdIncome { get; set; }
    public Decimal TotalMonthlyIncome { get; set; }
    public Decimal MonthlyCreditorsDebt { get; set; }
    public Decimal CreditScore { get; set; }
    public Decimal NumberOfDependents { get; set; }
    public Intake__c intakeCase { get; set; }
    public List<Contact> coApplicants { get; set; }
    public String CaseType{ get; set; }
    
    public String formatPhoneNumber(String phoneNumber) {
        if (phoneNumber == null) {
            return '';
        }
        // Remove non-numeric characters
        String cleaned = phoneNumber.replaceAll('[^0-9]', '');
        if (cleaned.length() == 10) {
            return '(' + cleaned.substring(0, 3) + ') ' + cleaned.substring(3, 6) + '-' + cleaned.substring(6);
        } else {
            return phoneNumber; // Return as is if not 10 digits
        }
    }
    /**
*Desc: An apex class constructor for the data retrieving functionality
*/
    
    public IntakePDFController() {
        intakeId = ApexPages.currentPage().getParameters().get('id');
        currentDate = Date.Today().format();
        
        List<AgencyProfile__c> AgencyDetailList = [SELECT Id, Name, AgencyEmailAddress__c, AgencyAddress__Street__s, AgencyAddress__City__s, AgencyAddress__PostalCode__s, AgencyAddress__StateCode__s, AgencyAddress__CountryCode__s, AgencyAddress__Latitude__s,  AgencyPhoneNumber__c FROM AgencyProfile__c WITH SECURITY_ENFORCED Limit 1];
        if(!AgencyDetailList.isEmpty()){
            footer = AgencyDetailList[0];
        }
        
        if (intakeId != null) {
            // Query To Fetch Intake records, Co-applicants and primary record type contact details
            List<Intake__c> intakeList = [SELECT Id, Name, PrimaryClient__c, ClientNumber__c, CaseType__r.name, Household__c, FarmWorker__c, Education__c, EnglishProficiency__c, ReferralSource__c, 
                                          IntakeDate__c, Status__c, Purpose__c, ClientHUDAssistance__c, Race__c, Gender__c, ColoniasResidence__c,
                                          Ethnicity__c, MonthlyIncome__c, CreditScore__c, Employment_Status__c, MaritalStatus__c, Address__City__s, DisabledStatus__c, CurrentResidence__c,
                                          (SELECT Id, Name, Contact__c,
                                           Contact__r.FirstName, 
                                           Contact__r.LastName, 
                                           Contact__r.MiddleName, 
                                           Contact__r.Suffix, 
                                           Contact__r.Email, 
                                           Contact__r.Phone,
                                           Contact__r.Race__c, 
                                           Contact__r.Gender__c, 
                                           Contact__r.Ethnicity__c, 
                                           Contact__r.EnglishProficiency__c,
                                           Contact__r.X1stTimeHomeBuyer__c, 
                                           Contact__r.MailingStreet, 
                                           Contact__r.MailingCity, 
                                           Contact__r.MailingState, 
                                           Contact__r.MailingPostalCode, 
                                           Contact__r.PreferredLanguage__c, 
                                           Contact__r.Besttimetocontact__c,
                                           Contact__r.TotalMonthlyIncome__c, 
                                           Contact__r.Occupation__c
                                           FROM Co_Applicants__r),
                                          PrimaryClient__r.FirstName, 
                                          PrimaryClient__r.LastName, 
                                          PrimaryClient__r.MiddleName, 
                                          PrimaryClient__r.Suffix, 
                                          PrimaryClient__r.SSN__c,
                                          PrimaryClient__r.Email, 
                                          PrimaryClient__r.Phone,
                                          PrimaryClient__r.Age__c,
                                          PrimaryClient__r.Race__c, 
                                          PrimaryClient__r.Gender__c, 
                                          PrimaryClient__r.Ethnicity__c, 
                                          PrimaryClient__r.EnglishProficiency__c, 
                                          PrimaryClient__r.X1stTimeHomeBuyer__c,
                                          PrimaryClient__r.MarketingCommunicationsOptOut__c, 
                                          PrimaryClient__r.NumberOfDependents__c,  
                                          PrimaryClient__r.Birthdate, 
                                          PrimaryClient__r.OccupationStartDate__c, 
                                          PrimaryClient__r.PreferredLanguage__c,
                                          PrimaryClient__r.Besttimetocontact__c, 
                                          PrimaryClient__r.TotalMonthlyIncome__c, 
                                          PrimaryClient__r.HouseholdType__c, 
                                          PrimaryClient__r.MonthlyCreditorsDebt__c, 
                                          PrimaryClient__r.CreditScore__c,
                                          PrimaryClient__r.ActiveMilitary__c, 
                                          PrimaryClient__r.Veteran__c, 
                                          PrimaryClient__r.ReferralSource__c, 
                                          PrimaryClient__r.AnnualHouseholdIncome__c,
                                          PrimaryClient__r.Occupation__c,
                                          PrimaryClient__r.MailingAddressLine2__c,
                                          PrimaryClient__r.MailingStreet,
                                          PrimaryClient__r.MailingState,
                                          PrimaryClient__r.MailingCity,
                                          PrimaryClient__r.MailingPostalCode,
                                          PrimaryClient__r.MailingAddress,
                                          AnnualHouseholdIncome__c
                                          FROM Intake__c  WHERE Id = :intakeId WITH SECURITY_ENFORCED  ] ;
            
            if (!intakeList.isEmpty()) {
                intakeCase = intakeList[0];
                coApplicants = new List<Contact>();
                for (CoApplicant__c coapp : intakeCase.Co_Applicants__r) {
                    coApplicants.add(coapp.Contact__r);
                }
            }
                        
            for(Contact contact : coApplicants) {
                contact.FirstName = String.isNotBlank(contact.FirstName) ? contact.FirstName : 'N/A';
                contact.MiddleName = String.isNotBlank(contact.MiddleName) ? contact.MiddleName : 'N/A';
                contact.LastName = String.isNotBlank(contact.LastName) ? contact.LastName : 'N/A';
                contact.Suffix = String.isNotBlank(contact.Suffix) ? contact.Suffix : 'N/A';
                
                contact.Email = String.isNotBlank(contact.Email) ? contact.Email : 'N/A';
                contact.Phone = String.isNotBlank(contact.Phone) ? formatPhoneNumber(contact.Phone) : 'N/A';
                contact.Besttimetocontact__c = String.isNotBlank(contact.Besttimetocontact__c) ? contact.Besttimetocontact__c : 'N/A';
                contact.PreferredLanguage__c = String.isNotBlank(contact.PreferredLanguage__c) ? contact.PreferredLanguage__c : 'N/A';
                
                contact.Race__c = String.isNotBlank(contact.Race__c) ? contact.Race__c : 'N/A';
                contact.Ethnicity__c = String.isNotBlank(contact.Ethnicity__c) ? contact.Ethnicity__c : 'N/A';
                contact.Gender__c = String.isNotBlank(contact.Gender__c) ? contact.Gender__c : 'N/A';
                
                contact.MailingStreet = String.isNotBlank(contact.MailingStreet) ? contact.MailingStreet : 'N/A';
                contact.MailingCity = String.isNotBlank(contact.MailingCity) ? contact.MailingCity : 'N/A';
                contact.MailingState = String.isNotBlank(contact.MailingState) ? contact.MailingState : 'N/A';
                contact.MailingPostalCode = String.isNotBlank(contact.MailingPostalCode) ? contact.MailingPostalCode : 'N/A';
            }
            
            // setting N/A on all fields  whose initial values are null 
            if (!intakeList.isEmpty()) {
                intake = intakeList[0];         
                 
                CaseType = intake.CaseType__r.name != null ? intake.CaseType__r.name : 'N/A';
                
                Birthdate = intake.PrimaryClient__r.Birthdate != null ? intake.PrimaryClient__r.Birthdate.format() : 'N/A';
                OccupationStartDate = intake.PrimaryClient__r.OccupationStartDate__c != null ? intake.PrimaryClient__r.OccupationStartDate__c.format() : 'N/A';
                
                intake.PrimaryClient__r.MailingAddressLine2__c = String.isNotBlank(intake.PrimaryClient__r.MailingAddressLine2__c) ? intake.PrimaryClient__r.MailingAddressLine2__c : 'N/A';
                intake.PrimaryClient__r.MailingStreet = String.isNotBlank(intake.PrimaryClient__r.MailingStreet) ? intake.PrimaryClient__r.MailingStreet : 'N/A';
                intake.PrimaryClient__r.MailingState = String.isNotBlank(intake.PrimaryClient__r.MailingState) ? intake.PrimaryClient__r.MailingState : 'N/A';
                intake.PrimaryClient__r.MailingCity = String.isNotBlank(intake.PrimaryClient__r.MailingCity) ? intake.PrimaryClient__r.MailingCity : 'N/A';
                intake.PrimaryClient__r.MailingPostalCode = String.isNotBlank(intake.PrimaryClient__r.MailingPostalCode) ? intake.PrimaryClient__r.MailingPostalCode : 'N/A';
                
				if(intake.PrimaryClient__c != NULL && intake.PrimaryClient__r.age__c != NULL){
                    Decimal ageDecimal = intake.PrimaryClient__r.age__c;
                    Integer ageWithoutDecimal = ageDecimal != NULL ? ageDecimal.intValue() : 0;
                    ageAsString = String.valueOf(ageWithoutDecimal);
                }
                
                intake.Race__c = String.isNotBlank(intake.Race__c) ? intake.Race__c : 'N/A';
                intake.Gender__c = String.isNotBlank(intake.Gender__c) ? intake.Gender__c : 'N/A';
                intake.Ethnicity__c = String.isNotBlank(intake.Ethnicity__c) ? intake.Ethnicity__c : 'N/A';
                intake.FarmWorker__c = String.isNotBlank(intake.FarmWorker__c) ? intake.FarmWorker__c : 'N/A';
                intake.Education__c = String.isNotBlank(intake.Education__c) ? intake.Education__c : 'N/A';
                
                intake.MaritalStatus__c = String.isNotBlank(intake.MaritalStatus__c) ? intake.MaritalStatus__c : 'N/A';
                intake.EnglishProficiency__c = String.isNotBlank(intake.EnglishProficiency__c) ? intake.EnglishProficiency__c : 'N/A';
                intake.ColoniasResidence__c = String.isNotBlank(intake.ColoniasResidence__c) ? intake.ColoniasResidence__c : 'N/A';
                intake.ClientHUDAssistance__c = String.isNotBlank(intake.ClientHUDAssistance__c) ? intake.ClientHUDAssistance__c : 'N/A';
                
                intake.DisabledStatus__c = String.isNotBlank(intake.DisabledStatus__c) ? intake.DisabledStatus__c : 'N/A';
                intake.Employment_Status__c = String.isNotBlank(intake.Employment_Status__c) ? intake.Employment_Status__c : 'N/A';
                intake.CurrentResidence__c = String.isNotBlank(intake.CurrentResidence__c) ? intake.CurrentResidence__c : 'N/A';
                
                
                intake.PrimaryClient__r.MiddleName = String.isNotBlank(intake.PrimaryClient__r.MiddleName) ? intake.PrimaryClient__r.MiddleName : 'N/A';
                intake.PrimaryClient__r.Suffix = String.isNotBlank(intake.PrimaryClient__r.Suffix) ? intake.PrimaryClient__r.Suffix : 'N/A'; 
                intake.PrimaryClient__r.SSN__c = String.isNotBlank(intake.PrimaryClient__r.SSN__c) ? intake.PrimaryClient__r.SSN__c : 'N/A';
                
                intake.PrimaryClient__r.Email = String.isNotBlank(intake.PrimaryClient__r.Email) ? intake.PrimaryClient__r.Email : 'N/A';
                intake.PrimaryClient__r.Phone = String.isNotBlank(intake.PrimaryClient__r.Phone) ? formatPhoneNumber(intake.PrimaryClient__r.Phone) : 'N/A';
                intake.PrimaryClient__r.Race__c = String.isNotBlank(intake.PrimaryClient__r.Race__c) ? intake.PrimaryClient__r.Race__c : 'N/A'; 
                
                intake.PrimaryClient__r.Gender__c = String.isNotBlank(intake.PrimaryClient__r.Gender__c) ? intake.PrimaryClient__r.Gender__c : 'N/A';
                intake.PrimaryClient__r.Ethnicity__c = String.isNotBlank(intake.PrimaryClient__r.Ethnicity__c ) ? intake.PrimaryClient__r.Ethnicity__c  : 'N/A';
                intake.PrimaryClient__r.EnglishProficiency__c = String.isNotBlank(intake.PrimaryClient__r.EnglishProficiency__c) ? intake.PrimaryClient__r.EnglishProficiency__c : 'N/A';
                intake.PrimaryClient__r.X1stTimeHomeBuyer__c = String.isNotBlank(intake.PrimaryClient__r.X1stTimeHomeBuyer__c) ? intake.PrimaryClient__r.X1stTimeHomeBuyer__c : 'N/A';
                
                intake.PrimaryClient__r.PreferredLanguage__c = String.isNotBlank(intake.PrimaryClient__r.PreferredLanguage__c) ? intake.PrimaryClient__r.PreferredLanguage__c : 'N/A';
                intake.PrimaryClient__r.Besttimetocontact__c = String.isNotBlank(intake.PrimaryClient__r.Besttimetocontact__c) ? intake.PrimaryClient__r.Besttimetocontact__c : 'N/A';
                intake.PrimaryClient__r.HouseholdType__c = String.isNotBlank(intake.PrimaryClient__r.HouseholdType__c) ? intake.PrimaryClient__r.HouseholdType__c : 'N/A';
                
                intake.PrimaryClient__r.ActiveMilitary__c = String.isNotBlank(intake.PrimaryClient__r.ActiveMilitary__c) ? intake.PrimaryClient__r.ActiveMilitary__c : 'N/A'; 
                intake.PrimaryClient__r.Veteran__c = String.isNotBlank(intake.PrimaryClient__r.Veteran__c) ? intake.PrimaryClient__r.Veteran__c : 'N/A';
                
                intake.PrimaryClient__r.ReferralSource__c = String.isNotBlank(intake.PrimaryClient__r.ReferralSource__c) ? intake.PrimaryClient__r.ReferralSource__c : 'N/A';
                intake.PrimaryClient__r.Occupation__c = String.isNotBlank(intake.PrimaryClient__r.Occupation__c) ? intake.PrimaryClient__r.Occupation__c : 'N/A';
                
                MarketingCommunicationsOptOut = (intake.PrimaryClient__r.MarketingCommunicationsOptOut__c) ? 'Yes' : 'No';
                
                AnnualHouseholdIncome = !(intake.AnnualHouseholdIncome__c == null) ? String.valueOf(intake.AnnualHouseholdIncome__c) :'0';
                TotalMonthlyIncome = !(intake.PrimaryClient__r.TotalMonthlyIncome__c == null) ? intake.PrimaryClient__r.TotalMonthlyIncome__c : 0;
                NumberOfDependents = !(intake.PrimaryClient__r.NumberOfDependents__c == null) ? intake.PrimaryClient__r.NumberOfDependents__c : 0;
                
                CreditScore = !(intake.PrimaryClient__r.CreditScore__c == null) ? intake.PrimaryClient__r.CreditScore__c : 0;
                MonthlyCreditorsDebt = !(intake.PrimaryClient__r.MonthlyCreditorsDebt__c == null) ? intake.PrimaryClient__r.MonthlyCreditorsDebt__c : 0;
                
            } 
            else {
                System.debug('No Intake record found with Id: ' + intakeId); // In case if no Id fetched throws an exception
            }
        } 
        else {
            System.debug('intakeId is null.'); // In case if no Id fetched throws message on console
        }
    }
}