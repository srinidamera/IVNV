/**
* @description  : This Apex class is designed to handle interactions with community users in Salesforce. 

	do we need to assign any role to the user?
	username, me suffix
	do we have any choice to make the alias name, first 8 characters of the name field

**/
public without sharing class CommunityUserController {
  /*
    This method retrieves a list of desired services from a 
    custom object called CaseType__c and returns it as a list of picklist options.
    */
  @AuraEnabled(cacheable=true)
  public static List<Utility.PicklistOption> getDesiredServices() {
    List<Utility.PicklistOption> options = new List<Utility.PicklistOption>();
    for (CaseType__c caseType : [SELECT id, Name FROM CaseType__c LIMIT 200]) {
      options.add(new Utility.PicklistOption(caseType.Name, caseType.Name));
    }
    return options;
  }
    
  @AuraEnabled(cacheable=true)
  public static List<Utility.PicklistOption> getDesiredServicesOptions(String language) {
    List<Utility.PicklistOption> options = new List<Utility.PicklistOption>();
        for (CaseType__c caseType : [SELECT id, Name, NameSpanish__c FROM CaseType__c LIMIT 200]) {
            if(language == 'en-US'){
                options.add(new Utility.PicklistOption(caseType.Name, caseType.Name));
            } else{
                options.add(new Utility.PicklistOption(caseType.NameSpanish__c, caseType.NameSpanish__c));
            }
        }
    return options;
  }

    
  /*
    This method inserts a new contact record into the Salesforce. If successful, 
    it returns the inserted contact record; otherwise, it throws an AuraHandledException with the error message.
    */
  @AuraEnabled
  public static Contact insertCommunityContact(Contact contactRecord, String localLanguage) {
    if(isUserAlreadyRegistered(contactRecord.Email)){
          throw new AuraHandledException('User with this email already exists.');
      }
    try { 
      createPartnerUser(contactRecord, localLanguage);
      return contactRecord;
    } catch (Exception ex) {
      throw new AuraHandledException(ex.getMessage());
    }
  }

  /*Checks if a user with the given email already exists.*/
  private static Boolean isUserAlreadyRegistered(String email){
    List<User> existingUsers  = [SELECT Id FROM User WHERE Email = :email OR UserName=:email LIMIT 1];
    return !existingUsers.isEmpty();
  }

  /*This method will create the partner user*/
  public static String createPartnerUser(Contact contactRecord, String localLanguage) {
    Profile partnerProfile;
    List<Profile> partnerProfiles = [
      SELECT Id
      FROM Profile
      WHERE Name = :Constants.NW_COMPASS_PORTAL_PROFILE_NAME
      LIMIT 1
    ];
    if (partnerProfiles.isEmpty()) {
      return null;
    }
    partnerProfile = partnerProfiles[0];
    String userName = contactRecord.Email; //+'.'+ Constants.PORTAL_USERNAME_SUFFIX;
    List<User> users = [SELECT id, Name FROM User WHERE userName = :userName];
    if (!users.isEmpty()) {
      return null;
    }
    String fullName = contactRecord.FirstName + ' ' + contactRecord.LastName;
    String alias = fullName.length() > 8 ? fullName.substring(0, 8) : fullName;
    User theUser = new User(
      Username = userName,
      ContactId = contactRecord.Id,
      ProfileId = partnerProfile.Id,
      Alias = alias,
      Email = contactRecord.Email,
      EmailEncodingKey = Constants.EMAIL_ENCODING_KEY,
      FirstName = contactRecord.FirstName,
      LastName = contactRecord.LastName,
      CommunityNickname = alias + getRandomFourDigitString(),
      TimeZoneSidKey = Constants.TIME_ZONE_SID_KEY,
      LocaleSidKey = localLanguage,
      LanguageLocaleKey = localLanguage
    ); 
    Account portalAccount = new Account(Name = formatName(contactRecord.LastName, contactRecord.FirstName), OwnerId = Label.Default_Household_Owner);
    insert portalAccount;
    Id userId = Site.createExternalUser(theUser, portalAccount.Id, null);
    updateContactDetails(JSON.serialize(contactRecord), userId);
    assignPermissionSetToUser(userId);
    return userId;
  }

  /*This method will assign the permission set to the user*/
  @future
  public static void assignPermissionSetToUser(String userId) {
    if (userId == '' || userId == null) {
      return;
    }
    List<PermissionSetGroup> psg = [select Id from PermissionSetGroup where DeveloperName =: Constants.NW_COMPASS_PORTAL_PERMISSION_SET_GROUP_NAME];
    if (psg.isEmpty()) {
      return;
    }
    PermissionSetAssignment psa = new PermissionSetAssignment(PermissionSetGroupId = psg[0].Id,AssigneeId = userId);
    insert psa;
  }

  private static void updateContactDetails(
    String serializedContact,
    String userId
  ) {
    Id prospectRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Prospect').getRecordTypeId();
    List<User> users = [
      SELECT ContactId
      FROM User
      WHERE Id = :userId AND ContactId != NULL
      LIMIT 1
    ];
    Contact contactRecord = (Contact) JSON.deserialize(
      serializedContact,
      Contact.class
    );
    if (users.isEmpty()) {
      return;
    }
    contactRecord.Id = users[0].ContactId;
    contactRecord.CorrespondingPortalUser__c = userId;
    contactRecord.RecordTypeId = prospectRecordTypeId;
    update contactRecord;
  }

  /*
    This method returns the Agency Name.
    */
  @AuraEnabled(cacheable=true)
  public static String getAgencyName() {
    return [SELECT Name FROM AgencyProfile__c LIMIT 1]?.Name;
  }

  /*This method will get user first name and first time login status*/
  @AuraEnabled
  public static Map<String, Object> getUserLoginDetails() {
    Map<String, Object> userDetails = new Map<String, Object>();
    userDetails.put('userFirstName', UserInfo.getFirstName());
    List<User> users = [SELECT Id FROM User WHERE Id =: UserInfo.getUserId() AND Profile.Name != 'Compass Portal Profile'];
    if(users.size() == 0) {
      userDetails.put('isLoggingFirstTime', false);
      return userDetails;
    }
    Integer loginCount = (Integer) [SELECT COUNT(Id) loginCount FROM LoginHistory WHERE UserId =: UserInfo.getUserId()][0].get('loginCount');
    userDetails.put('isLoggingFirstTime', loginCount == 1);
    // To show Welcome message.
    List<LoginHistory> history = [SELECT Id, UserId, LoginTime FROM LoginHistory WHERE UserId =: UserInfo.getUserId() ORDER By LoginTime DESC LIMIT 1];
    if(history.size() > 0) {
      userDetails.put('lastLoginTime', history[0].LoginTime);
    }
    return userDetails;
  }
    
    
  public static String formatName(String lastName, String firstName) {
      if (lastName == null) {
          lastName = '';
      }
      if (firstName == null) {
          firstName = '';
      }
      String capitalizedLastName = '';
      if (!String.isEmpty(lastName)) {
          capitalizedLastName = lastName.substring(0, 1).toUpperCase() + lastName.substring(1).toLowerCase();
      }
      String firstInitial = '';
      if (!String.isEmpty(firstName)) {
          firstInitial = firstName.substring(0, 1).toUpperCase();
      }
      String result = capitalizedLastName + ', ' + firstInitial + ' ' + Constants.HOUSEHOLD_POSTFIX;
      return result;
  }

  public static String getRandomFourDigitString() {
      String randomDigits = '';
      for (Integer i = 0; i < 4; i++) {
          Integer randomDigit = Math.floor(Math.random() * 10).intValue();
          randomDigits += String.valueOf(randomDigit);
      }
      return randomDigits;
  }

}