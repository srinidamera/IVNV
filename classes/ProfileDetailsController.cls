/*
@description    this is controller class for profileDetails lwc
*/
public class ProfileDetailsController {
    /*
    @description    this method is used to return contact details and its co-applicant details
    */
    @AuraEnabled(cacheable=true)
    public static ResultWrapper getProfileDetails(){
        ResultWrapper result = new ResultWrapper();
        try{
            List<Contact> conRec = [Select Id, Name, Suffix, Email, Phone, Besttimetocontact__c, PreferredLanguage__c, RelationshipToPrimaryApplicant__c,
                                 MailingStreet, MailingAddressLine2__c, MailingCity, MailingState, MailingStateCode, MailingPostalCode,
                                 Birthdate, Gender__c, Race__c, Ethnicity__c, RuralAreaStatus__c, EnglishProficiency__c, X1stTimeHomeBuyer__c, HouseholdSize__c, HouseholdType__c, MaritalStatus__c, Education__c, ActiveMilitary__c, Disabled__c,
                                 TotalMonthlyIncome__c, NumberOfDependents__c, EmploymentStatus__c, CreditScore__c, AccountId, HouseholdMonthlyIncome1__c from Contact where Id IN (Select ContactId from User where Id =: UserInfo.getUserId()) WITH USER_MODE Limit 1];
            
            if(conRec.size() > 0){
                result.primaryContact = new ContactDetailWrapper(conRec[0], 1);
            }
            
            if(conRec.size() > 0 && String.isNotBlank(conRec[0].AccountId)){
                List<Contact> coApplicants = [Select Id, Name, Suffix, Email, Phone, Besttimetocontact__c, PreferredLanguage__c, RelationshipToPrimaryApplicant__c,
                                              MailingStreet, MailingAddressLine2__c, MailingCity, MailingState, MailingStateCode, MailingPostalCode,
                                              Birthdate, Gender__c, Race__c, Ethnicity__c, RuralAreaStatus__c, EnglishProficiency__c, X1stTimeHomeBuyer__c, HouseholdSize__c, HouseholdType__c, MaritalStatus__c, Education__c, ActiveMilitary__c, Disabled__c,
                                              TotalMonthlyIncome__c, NumberOfDependents__c, EmploymentStatus__c, CreditScore__c, AccountId, HouseholdMonthlyIncome1__c from Contact where AccountId =: conRec[0].AccountId AND Id != :conRec[0].Id AND RecordType.DeveloperName = 'CoApplicant'
                                              AND isActive__c  = true WITH USER_MODE
                                            ];
                
                List<ContactDetailWrapper> coAppList = new List<ContactDetailWrapper>();
                
                Integer counter = 1;
                for(Contact con : coApplicants){
                    coAppList.add(new ContactDetailWrapper(con, counter++));
                }
                
                result.coApplicants = coAppList;
                
            }
            return result;
            
        } catch(Exception exe){
            throw new AuraHandledException(exe.getMessage());
        }
    }
    
    /*
    @description   wrapper class to return contact details and its co-applicant details
    */
    public class ResultWrapper{
        @AuraEnabled
        public ContactDetailWrapper primaryContact{get;set;}
        @AuraEnabled
        public List<ContactDetailWrapper> coApplicants{get;set;}
    }
    
    /*
    @description   wrapper class to Contact Details
    */
    public class ContactDetailWrapper{
        @AuraEnabled
        public Integer SeqNo{get;set;}
        @AuraEnabled
        public String FullName{get;set;}
        @AuraEnabled
        public String Suffix{get;set;}
        @AuraEnabled
        public String EmailAddress{get;set;}
        @AuraEnabled
        public String FormattedPhoneNumber{get;set;}
        @AuraEnabled
        public String BestTimeToCall{get;set;}
        @AuraEnabled
        public String PreferredLanguage{get;set;}
        @AuraEnabled
        public String RelationshipToClient{get;set;}
        @AuraEnabled
        public String Street{get;set;}
        @AuraEnabled
        public String AddressLine2{get;set;}
        @AuraEnabled
        public String City{get;set;}
        @AuraEnabled
        public String State{get;set;}
        @AuraEnabled
        public String PostaCode{get;set;}
        @AuraEnabled
        public String Address{get;set;}
        @AuraEnabled
        public String Birthdate{get;set;}
        @AuraEnabled
        public String Gender{get;set;}
        @AuraEnabled
        public String Race{get;set;}
        @AuraEnabled
        public String Ethnicity{get;set;}
        @AuraEnabled
        public String Community{get;set;}
        @AuraEnabled
        public String FirstTimeHomeBuyer{get;set;}
        @AuraEnabled
        public String FluencyInEnglish{get;set;}
        @AuraEnabled
        public Integer HouseholdSize{get;set;}
        @AuraEnabled
        public String HouseholdTypeHeadOfHousehold{get;set;}
        @AuraEnabled
        public String MaritalStatus{get;set;}
        @AuraEnabled
        public String Education{get;set;}
        @AuraEnabled
        public String ActiveMilitary{get;set;}
        @AuraEnabled
        public String LegallyDisabled{get;set;}
        @AuraEnabled
        public Decimal TotalMonthlyIncome{get;set;}
        @AuraEnabled
        public Decimal HouseholdIncome{get;set;}
        @AuraEnabled
        public Integer NoOfDependents{get;set;}
        @AuraEnabled
        public String EmploymentStatus{get;set;}
        @AuraEnabled
        public Integer CreditScore{get;set;}
        
        public ContactDetailWrapper(Contact con, Integer SeqNo){
            this.SeqNo = SeqNo;
            this.FullName = con.Name;
            this.Suffix = con.Suffix;
            this.EmailAddress = con.Email;
            this.FormattedPhoneNumber = con.Phone;
            this.BestTimeToCall = con.Besttimetocontact__c;
            this.PreferredLanguage = con.PreferredLanguage__c;
            this.RelationshipToClient = con.RelationshipToPrimaryApplicant__c;
            this.Street = con.MailingStreet;
            this.AddressLine2 = con.MailingAddressLine2__c;
            
            String add = '';
            add += String.isNotBlank(con.MailingStreet) ? con.MailingStreet : '';
            add += String.isNotBlank(con.MailingAddressLine2__c) ? ('<br>' + con.MailingAddressLine2__c) : '';
            add += String.isNotBlank(con.MailingCity) ? ('<br>' + con.MailingCity + ' ') : '';
            add += String.isNotBlank(con.MailingStateCode) ? con.MailingStateCode : '';
            add += String.isNotBlank(con.MailingPostalCode) ? (', ' + con.MailingPostalCode) : '';
            
            this.Address = add;
            
            this.City = con.MailingCity;
            this.State = con.MailingStateCode;
            this.PostaCode = con.MailingPostalCode;
            this.Birthdate = String.valueof(con.Birthdate);
            this.Gender = con.Gender__c;
            this.Race = con.Race__c;
            this.Ethnicity = con.Ethnicity__c;
            this.Community = con.RuralAreaStatus__c;
            this.FirstTimeHomeBuyer = con.X1stTimeHomeBuyer__c;
            this.FluencyInEnglish = con.EnglishProficiency__c;
            this.HouseholdSize = Integer.valueOf(con.HouseholdSize__c);
            this.HouseholdTypeHeadOfHousehold = con.HouseholdType__c;
            this.MaritalStatus = con.MaritalStatus__c;
            this.Education = con.Education__c;
            this.ActiveMilitary = con.ActiveMilitary__c;
            this.LegallyDisabled = con.Disabled__c ? 'Yes' : 'No';
            this.TotalMonthlyIncome = con.TotalMonthlyIncome__c;
            this.HouseholdIncome = con.HouseholdMonthlyIncome1__c;
            this.NoOfDependents = Integer.valueOf(con.NumberOfDependents__c);
            this.EmploymentStatus = con.EmploymentStatus__c;
            this.CreditScore = Integer.valueOf(con.CreditScore__c);
        }
    }
}