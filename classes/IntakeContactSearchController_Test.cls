/**=====================================================================
 * Description: Test class for Apex Class IntakeContactSearchController
 =====================================================================*/ 
@IsTest
public class IntakeContactSearchController_Test {
    
    /**=====================================================================
     * Description: Test Setup method to create test data for testing
     =====================================================================*/ 
    @testSetup 
    static void testSetup() {
		Account acc = new Account();
        acc.Name = 'Test Account';
        acc.AccountNumber = '123456';
        insert acc;
        List<Contact> conList = new List<Contact>();
        
        Contact con1 = new Contact();
        con1.AccountId = acc.Id;
        con1.FirstName = 'Test';
        con1.MiddleName = 'Class';
        con1.LastName = 'Contact';
        con1.Phone = '1234567890';
        con1.Email = 'test@test.com';
        conList.add(con1);
        
        Contact con2 = new Contact();
        con2.AccountId = acc.Id;
        con2.FirstName = 'Test';
        con2.MiddleName = 'Class';
        con2.LastName = 'Contact';
        con2.Phone = '1234567890';
        con2.Email = 'test@test.com';
        conList.add(con2);
        
        Contact con3 = new Contact();
        con3.AccountId = acc.Id;
        con3.FirstName = 'Test';
        con3.MiddleName = 'Class';
        con3.LastName = 'Contact';
        con3.Phone = '1234567890';
        con3.Email = 'test1@test.com';
        conList.add(con3);
        
        Contact con4 = new Contact();
        con4.AccountId = acc.Id;
        con4.FirstName = 'Test';
        con4.MiddleName = 'Class';
        con4.LastName = 'Contact';
        con4.Phone = '1234567890';
        conList.add(con4);
        
        insert conList;
        
	}
    
    /**=====================================================================
     * Description: Test method for testing retrieveContacts method which retuen contact based on search criteria
     =====================================================================*/ 
    public static testMethod void testRetrieveContacts() {
        Test.startTest();
        List<Contact> conList1 = IntakeContactSearchController.retrieveContacts('Test', 'Con', 'test@test.com', '123',  'FirstName', 'asc');
        System.assertEquals(2, conList1.size());
        List<Contact> conList2 = IntakeContactSearchController.retrieveContacts('Test*', 'Con*', 'test@test.com*', '123', 'FirstName', 'asc');
        System.assertEquals(2, conList2.size());
        Test.stopTest();
    }

}