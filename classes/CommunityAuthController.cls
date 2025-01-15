/*
@description    Controller class containing methods for login the community user in the portal
*/
public without sharing class CommunityAuthController { 
    /*
    @description    This method will accept the username & password and login the community user in the portal
    */
    @AuraEnabled
    public static string doLogin(String username, String password){
        try { 
            String startUrl = System.Label.Compass_Community_URL;
            ApexPages.PageReference pageRef = Site.login(username, password, startUrl); 
            if(pageRef != null)   return pageRef.getUrl(); 
            if(Test.isRunningTest()){
                Integer i = 5/0;
            }
            throw new CalloutException(); 
        } catch (Exception e) {LoggerClass.log(e,'Community Login Failed');throw new AuraHandledException(e.getMessage()); }
    }
}