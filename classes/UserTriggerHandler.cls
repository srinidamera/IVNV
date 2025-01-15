public class UserTriggerHandler {
    /**
* @desc:Handles after insert trigger events for User.
*/
    public static void afterInsert(List<User> newUsers) {
        assignPortalPSGroup(newUsers);
    }
    
    /**
* Assign Portal Permission Set Group to new Users.
*/
    public static void assignPortalPSGroup(List<User> newUsers) {
        if(newUsers.isEmpty()){
            return;
        }
        
        Set<Id> userIds = new Set<Id>();
        
        List<PermissionSetGroup> psg = [select Id from PermissionSetGroup where DeveloperName =: Constants.NW_COMPASS_PORTAL_PERMISSION_SET_GROUP_NAME];
        if (psg.isEmpty()) {
            return;
        }
        
        for(User usr : newUsers){
            if(String.isNotBlank(usr.ContactId)){
                userIds.add(usr.Id);
            }
        }
        
        assignPortalPSGroup(userIds, psg[0].Id);
        
        /*List<PermissionSetAssignment> psaList = new List<PermissionSetAssignment>();

for(Id usrId : userIds){
PermissionSetAssignment psa = new PermissionSetAssignment(PermissionSetGroupId = psg[0].Id, AssigneeId = usrId);
psaList.add(psa);
}

if(psaList.size() > 0){
insert psaList;
}*/
    }
    
    @future
    public static void assignPortalPSGroup(Set<Id> newUserIds, Id psgId) {
        List<PermissionSetAssignment> psaList = new List<PermissionSetAssignment>();
        
        for(Id usrId : newUserIds){
            PermissionSetAssignment psa = new PermissionSetAssignment(PermissionSetGroupId = psgId, AssigneeId = usrId);
            psaList.add(psa);
        }
        
        if(psaList.size() > 0){
            insert psaList;
        }
    }
    
    public static void populateUniqueClientId(List<User> userList){
        System.debug('populateUniqueClientId ==>');
        Set<String> uniqueValuesSet = new Set<String>();
        String uniqueId;
        Boolean isUnique = false;
        while(!isUnique){
            while(uniqueValuesSet.size() < userList.size()){
                uniqueValuesSet.add(getNewUniqueId());
            }
            List<User> userListDump = checkDuplicacy(uniqueValuesSet); 
            if(userListDump.size() > 0){
                uniqueValuesSet = new Set<String>();
            } else {
                isUnique = true;
            }
        }
        Integer index = 0;
        List<String> uniqueValuesList = new List<String>(uniqueValuesSet);
        for(User usr : userList){
            usr.CMSCounselorID__c = uniqueValuesList[index];
            index++;
        }
        System.debug('last user list'+userList);
        if(!Trigger.isExecuting){
            Database.update(userList,false);
        }
        //return accList;
    }
    
    private static List<User> checkDuplicacy(Set<String> uniqueValuesSet){
        return new List<User>([Select id from User where CMSCounselorID__c in: uniqueValuesSet limit 1]);
    }
    
    public static String getNewUniqueId(){
		Long timestamp = System.currentTimeMillis();
        // Generate a random number between 0 and 999999
        Integer randomNum = Math.abs(Crypto.getRandomInteger());
        randomNum = randomNum - (randomNum / 100000) * 100000;
        // Combine the timestamp and random number
        Long uniqueLong = randomNum + timestamp;
        // Get the last 5 digits of the combined number
        String uniqueNumber = String.valueOf(uniqueLong).substring(Math.max(String.valueOf(uniqueLong).length() - 5, 0));
        // Ensure uniqueNumber is exactly 5 digits
        while (uniqueNumber.length() < 5) {
            // Generate a random digit between 0 and 9
            Integer aleaNumberN = (Integer)(Math.random() * 10);
            /*if (aleaNumberN == 0 && uniqueNumber.length() == 0) {
                uniqueNumber = '1'; // Prevent leading zero if the number is empty
            } else {
                uniqueNumber = String.valueOf(aleaNumberN) + uniqueNumber; // Prepend the random digit
            }*/
            if (aleaNumberN == 0 && uniqueNumber.length() == 0) {
                uniqueNumber = '1'; // Prevent leading zero if the number is empty
            } else {
                uniqueNumber = String.valueOf(aleaNumberN) + uniqueNumber; // Prepend the random digit
            }
        }
        if (uniqueNumber.substring(0, 1) == '0') {
            // Replace the leading zero with a random digit between 1 and 9
            Integer leadingDigit = (Integer)(Math.random() * 9) + 1; // Random number between 1 and 9
            uniqueNumber = leadingDigit + uniqueNumber.substring(1); // Replace the first character
            
        }
        System.debug('uniqueNumber--->'+ uniqueNumber);
		return uniqueNumber;
	}
    
    public static void beforeInsert(List<User> users){
        List<User> userList = new List<User>();
        for(User eachUser : users){
            if(eachUser.IsCounselor__c && (eachUser.CMSCounselorID__c == '' || eachUser.CMSCounselorID__c == null)){
                userList.add(eachUser);
            }
        }
        populateUniqueClientId(userList);
    }
    
    public static void beforeUpdate(List<User> users){
        List<User> userList = new List<User>();
        for(User eachUser : users){
            if(eachUser.IsCounselor__c && (eachUser.CMSCounselorID__c == '' || eachUser.CMSCounselorID__c == null)){
                userList.add(eachUser);
            }
        }
        populateUniqueClientId(userList);
    }
}