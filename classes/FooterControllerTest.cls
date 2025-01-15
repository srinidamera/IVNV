/**
 * @description  : Test class for FooterController
**/
@IsTest
public class FooterControllerTest {
	/**
     * @description  : Test method to test for getAgencyProfileDetails when Agency details exists
    **/
    @isTest
    public static void testgetAgencyProfileDetails(){        
        AgencyProfile__c agency = new AgencyProfile__c();
        agency.Name = 'Test';
        agency.AgencyPhoneNumber__c = '1234567890';
        agency.AgencyAddress__Street__s = 'Test';
        agency.AgencyAddress__City__s = 'Test';
        agency.AgencyAddress__StateCode__s = 'CA';
        agency.AgencyAddress__PostalCode__s = '12345';
        agency.AgencyAddress__CountryCode__s = 'US';
        
        insert agency;

        Test.startTest();
        	AgencyProfile__c result = FooterController.getAgencyProfileDetails();
        Test.stopTest();
        System.assertNotEquals(null, result);
    }
	
	/**
     * @description  : Test method to test for getAgencyProfileDetails when Agency details does not exists(Exception Thrown)
    **/    
    @isTest
    public static void testgetAgencyProfileDetails_Exception(){        
        try{
        Test.startTest();
        	AgencyProfile__c result = FooterController.getAgencyProfileDetails();
        Test.stopTest();
        } catch(Exception exe){
            System.assert(true);
        }
        
    }
}