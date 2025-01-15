@isTest
private class CommunityUserControllerTest {
  @testSetup
  static void setup() {
    TestDataFactory.createCaseTypes(1, true);
  	
  }

  @IsTest
  static void testProcess() {
    CommunityUserController.getDesiredServices();
    Contact contactRecord = new Contact(
      FirstName = 'Test',
      LastName = 'Contact',
      Email = 'test@example.com'
    );
    Test.startTest();
    Contact insertedContact = CommunityUserController.insertCommunityContact(
      contactRecord,
        'en_US'
    );
    Test.stopTest();
    System.assertEquals('Test', insertedContact.FirstName);
  }

  @IsTest
  private static void getAgencyName() {
    TestDataFactory.createAgencyProfile(true);
    Test.startTest();
    String agencyName = CommunityUserController.getAgencyName();
    Test.stopTest();
    System.assertEquals('Test Agency', agencyName);
  }

  @IsTest
  private static void getUserLoginDetails() {
    Test.startTest();
    Map<String, Object> loginDetails = CommunityUserController.getUserLoginDetails();
    Test.stopTest();
    System.assertNotEquals(null, loginDetails.get('userFirstName'));
  }
    
  @IsTest
  private static void getDesiredServicesOptionsEnglish() {
    Test.startTest();
    List<Utility.PicklistOption> result = CommunityUserController.getDesiredServicesOptions('en-US');
    Test.stopTest();
  }
    
  @IsTest
  private static void getDesiredServicesOptionsSpanish() {
    Test.startTest();
    List<Utility.PicklistOption> result = CommunityUserController.getDesiredServicesOptions('en-ES');
    Test.stopTest();
  }
    
  @IsTest
  private static void assignPermissionSetToUser() {
    Profile adminProfile = [Select id from Profile where name = 'System Administrator' limit 1];
    User adminUser = TestDataFactory.createUsers(adminProfile.Id, '', 1, true)[0];
    Test.startTest();
      // force calculation of the PSG if it is not already Updated
      List<PermissionSetGroup> psg = [select Id, Status from PermissionSetGroup where DeveloperName =: Constants.NW_COMPASS_PORTAL_PERMISSION_SET_GROUP_NAME];
      if(!psg.isEmpty() && psg[0].Status != 'Updated'){
          Test.calculatePermissionSetGroup(psg[0].Id);
      }
      
    CommunityUserController.assignPermissionSetToUser(adminUser.Id);
    List<PermissionSetAssignment> psa = [SELECT Id FROM PermissionSetAssignment LIMIT 1];
      System.assertEquals(1, psa.Size());
    Test.stopTest();
  }
}