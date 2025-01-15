@IsTest
public class UserTriggerHandlerTest {
    
    @TestSetup
    private static void testDataSetup(){
        Account acc = TestDataFactory.createAccounts(1, true)[0];
        Contact con = TestDataFactory.createContacts(acc.id,1, true)[0];
    }

    @IsTest
    private static void testAssignPortalPSGroup(){
        Id primaryClientRecTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName()
        .get('PrimaryClient')
        .getRecordTypeId();
        
        Contact con = [Select Id from Contact limit 1];
        
        Id profileId = [Select Id From Profile Where Name ='NWCompass Portal'].Id;
        
        User tempUser = new User(  
            FirstName = 'test',  
            LastName = 'user',  
            email = 'testuser321@sfdc.org',  
            Username = 'testuser321@sfdc.org',  
            EmailEncodingKey = 'ISO-8859-1',  
            Alias = 'testu321',  
            TimeZoneSidKey = 'America/Los_Angeles',  
            LocaleSidKey = 'en_US',  
            LanguageLocaleKey = 'en_US',  
            ProfileId = profileId,
            contactId = con.Id
        ); 
        
        insert tempUser;
		
        List<PermissionSetGroup> psg = [select Id from PermissionSetGroup where DeveloperName =: Constants.NW_COMPASS_PORTAL_PERMISSION_SET_GROUP_NAME];
        
        List<PermissionSetAssignment> res = [Select Id, PermissionSetGroupId from PermissionSetAssignment where AssigneeId =:tempUser.Id AND PermissionSetGroupId IN :psg];
        
        System.assertNotEquals(0, res.size());
    }
}