@isTest
public class CreateReferralControllerTest {
    
    @isTest
    static void testGetReferrals() {
        Test.startTest();
        CreateReferralController.getReferrals();
        Test.stopTest();
    }
    
    @isTest
    static void testInsertReferrals() {
        Referral__c referral = new Referral__c(Name='Test Referral');
        Test.startTest();
        CreateReferralController.insertReferrals(new List<Referral__c>{referral});
        Test.stopTest();
    }
}