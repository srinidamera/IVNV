public class CreateReferralController {
    @AuraEnabled(cacheable=true)
    public static List<Contact> getReferrals(){ 
        return [SELECT Id, Name,AccountId,Speciality__c, Account.Name,Account.BillingAddress, Account_Referral_Type__c,Email,  Phone  
            FROM Contact WHERE Account.RecordType.Name = 'Organization' and RecordType.Name = 'Affiliate'];
    }

    @AuraEnabled()
    public static List<Referral__c> insertReferrals(List<Referral__c> referrals){
        insert referrals;
        return referrals;
    }
}