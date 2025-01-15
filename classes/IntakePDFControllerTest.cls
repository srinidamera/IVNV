@IsTest
private class IntakePDFControllerTest {
    
    @TestSetup
    static void setup() {
        List<Account> portalAccounts = TestDataFactory.createAccounts(1, true);
        List<Contact> ConList = TestDataFactory.createContacts(portalAccounts[0].Id, 2, true);
        Contact primaryContact = ConList[0];
        primaryContact.email = 'primary@example.com';
        primaryContact.FirstName = 'Primary';
        update primaryContact;

        Contact coApplicant = ConList[1];
        coApplicant.FirstName = 'CoApplicant';
        coApplicant.Email = 'coapplicant@example.com';
        coApplicant.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Co-Applicant').getRecordTypeId();
        update coApplicant;

        Intake__c intake = TestDataFactory.createIntakes(primaryContact, portalAccounts[0].id, 1, true)[0];
        Intake__c intakeCo = TestDataFactory.createIntakes(coApplicant, portalAccounts[0].id, 1, true)[0];

        CoApplicant__c coApp = new CoApplicant__c(IntakeRequest__c = intake.Id, Contact__c = coApplicant.Id);
        insert coApp;
    }
    
    @IsTest
    static void testIntakePDFControllerWithId() {
        Intake__c intake = [SELECT Id FROM Intake__c LIMIT 1];
        Test.setCurrentPage(Page.printIntakeVf); 
        ApexPages.currentPage().getParameters().put('id', intake.Id);
        IntakePDFController controller = new IntakePDFController();
        String name = controller.intake.Name;
        List<Contact> coApplicants = controller.coApplicants;
    }
    
    @IsTest
    static void testIntakePDFControllerWithoutId() {
        Test.setCurrentPage(Page.printIntakeVf); 
        ApexPages.currentPage().getParameters().put('id', null);

        IntakePDFController controller = new IntakePDFController();

        String name = controller.intake == null ? 'No intake' : controller.intake.Name;
        String cdate = controller.currentDate;
    }
    
     @IsTest
    static void testFormatPhoneNumber() {
        IntakePDFController controller = new IntakePDFController();

        // Test with a 10-digit phone number
        String formattedNumber = controller.formatPhoneNumber('1234567890');
        System.assertEquals('(123) 456-7890', formattedNumber, 'The phone number should be formatted correctly.');

        // Test with a phone number that includes non-numeric characters
        String formattedNumberWithChars = controller.formatPhoneNumber('(123) 456-7890');
        System.assertEquals('(123) 456-7890', formattedNumberWithChars, 'The phone number should be formatted correctly.');

        // Test with a phone number that is not 10 digits
        String shortNumber = controller.formatPhoneNumber('12345');
        System.assertEquals('12345', shortNumber, 'The phone number should be returned as is if it is not 10 digits.');

        // Test with a null phone number
        String nullNumber = controller.formatPhoneNumber(null);
        System.assertEquals('', nullNumber, 'The phone number should return an empty string if null.');
    }
}