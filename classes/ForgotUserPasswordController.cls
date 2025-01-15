/**
 * @description  : Class for forgot password Compass Portal Site
**/
public without sharing class ForgotUserPasswordController {
    /**
    * @description : Method sends the reset password email for community user
    **/
    @AuraEnabled
    public static Boolean resetCommunityUserPassword(String email) {
        try {
            List<User> user = [SELECT Id FROM User WHERE Email = :email AND IsPortalEnabled = true AND IsActive = true LIMIT 1];
            if(!user.isEmpty()) {
                System.ResetPasswordResult res =  System.resetPassword(user[0].Id, true);
                return true;
            }
        } catch (Exception e) { LoggerClass.log(e, email); }
        return false;
    }
}