@IsTest
public class GetObjectAPINameTest {
    
    @IsTest
    static void testGetSObjectType() {
        // Create test data
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;
        
        Contact testContact = new Contact(FirstName = 'Test', LastName = 'Contact', AccountId = testAccount.Id);
        insert testContact;
        
        // List of valid record IDs
        List<String> validRecordIds = new List<String>{testAccount.Id, testContact.Id};
        
        // Invoke the method
        List<String> result = GetObjectAPIName.getSObjectType(validRecordIds);
        
        // Validate the results
        System.assertEquals(2, result.size());
        System.assertEquals('Account', result[0]);
        System.assertEquals('Contact', result[1]);
    }
    
    @IsTest
    static void testGetSObjectTypeInvalidId() {
        // List with an invalid record ID
        List<String> invalidRecordIds = new List<String>{'001InvalidId'};
        
        // Invoke the method
        List<String> result = GetObjectAPIName.getSObjectType(invalidRecordIds);
        
        // Validate the results
        System.assertEquals(1, result.size());
        System.assert(result[0].startsWith('Error:'));
    }
    
    @IsTest
    static void testGetSObjectTypeEmptyList() {
        // Empty list
        List<String> emptyList = new List<String>();
        
        // Invoke the method
        List<String> result = GetObjectAPIName.getSObjectType(emptyList);
        
        // Validate the results
        System.assertEquals(0, result.size());
    }
    
    
}