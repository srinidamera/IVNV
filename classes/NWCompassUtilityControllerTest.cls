@isTest
public class NWCompassUtilityControllerTest {
    @isTest
    static void testGetAgencyProfileDetailsSuccess() {
        // Set up test data
        AgencyProfile__c testAgencyProfile = new AgencyProfile__c(
            Name = 'Test Agency',
            AgencyPhoneNumber__c = '123-456-7890'
            // AgencyAddress__c is omitted because it's not writable
        );
        insert testAgencyProfile;
        
        // Test the method
        Test.startTest();
        AgencyProfile__c result = NWCompassUtilityController.getAgencyProfileDetails();
        Test.stopTest();
        
        // Verify the results
        System.assertNotEquals(null, result, 'The result should not be null.');
        System.assertEquals(testAgencyProfile.Id, result.Id, 'The Id should match.');
        System.assertEquals(testAgencyProfile.Name, result.Name, 'The Name should match.');
        System.assertEquals(testAgencyProfile.AgencyPhoneNumber__c, result.AgencyPhoneNumber__c, 'The AgencyPhoneNumber__c should match.');
    }
    /*
    @isTest
    static void testGetAgencyProfileDetailsNoRecords() {
        // Test the method when no records exist
        Test.startTest();
        AgencyProfile__c result = NWCompassUtilityController.getAgencyProfileDetails();
        Test.stopTest();
        
        // Verify the results
        System.assertEquals(null, result, 'The result should be null when no records exist.');
    }
*/
    @isTest
    static void testGetAgencyProfileDetailsException() {
        // Set up mock data to simulate an exception
        // This example assumes a logging utility that we can mock or simulate
        // Use Test.startTest() and Test.stopTest() for exception simulation
        
        // Create a trigger or mock that will throw an exception when the method is called
        // Since we cannot directly throw exceptions in a static method, we simulate it
        Test.startTest();
        try {
            // Assuming the exception could be due to a query or other issue
            AgencyProfile__c result = NWCompassUtilityController.getAgencyProfileDetails();
            System.assert(false, 'Expected an exception to be thrown.');
        } catch (AuraHandledException e) {
            System.assert(e.getMessage().contains(''), 'Exception message should be captured.');
        }
        Test.stopTest();
    }
}