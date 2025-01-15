@isTest
private class CommunityAuthControllerTest {
    @isTest
    static void testDoLogin() {
        try{
        	String startUrl = System.Label.Compass_Community_URL;
        	String loginUrl = CommunityAuthController.doLogin('soyab.hussain21@gmail.com.community', 'Salesforce@123');    
        }catch(Exception e){}
    }
}