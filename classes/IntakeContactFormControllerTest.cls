/**
 * @desc: Test Class for IntakeContactFormController.
 */
@IsTest
public class IntakeContactFormControllerTest {
    
    /**
     * @desc: Test Data Setup.
     */
    @testSetup 
    static void testSetup() {
        Account acc = TestDataFactory.createAccounts(1, true)[0];
        TestDataFactory.createContacts(acc.Id, 5, true);
	}
    
    /**
     * @desc: Test Method to test getPotentialDuplicates method of controller.
     */
    public static testMethod void testGetPotentialDuplicates() {
        Account acc = [Select id from Account limit 1];
        Test.startTest();
        Contact con = TestDataFactory.createContacts(acc.Id, 1, false)[0];
        List<Contact> conList1 = IntakeContactFormController.getPotentialDuplicates(con);
        Test.stopTest();
        System.assertEquals(1, conList1.size());
    }
}