@isTest
public class EmailControllerTest {
    @testSetup
    static void setupTestData() {
        Account acc = TestDataFactory.createAccounts(1, true)[0];
        Contact contact = TestDataFactory.createContacts(acc.id, 1, true)[0];
       
        ClientCase__c testClientCase = TestDataFactory.createClientCases(1, false)[0];
        testClientCase.PrimaryClient__c = contact.Id;
        insert testClientCase;

        // Create an Intake__c record
        Intake__c intake = new Intake__c(PrimaryClient__c = contact.Id);
        insert intake;

        // Create EmailMessage records
        EmailMessage emailMessage1 = new EmailMessage(
            FromAddress = 'sender1@example.com',
            ToAddress = 'john.doe@example.com',
            Subject = 'Subject 1',
            TextBody = 'Body 1',
            MessageDate = DateTime.now(),
            RelatedToId = testClientCase.Id
        );
        insert emailMessage1;

        EmailMessage emailMessage2 = new EmailMessage(
            FromAddress = 'sender2@example.com',
            ToAddress = 'john.doe@example.com',
            Subject = 'Subject 2',
            TextBody = 'Body 2',
            MessageDate = DateTime.now().addDays(-1),
            RelatedToId = testClientCase.Id
        );
        insert emailMessage2;
    }

    @isTest
    static void testGetEmailRecords() {
        ClientCase__c testClientCase = [SELECT Id FROM ClientCase__c LIMIT 1];
        Test.startTest();
        List<EmailMessage> emailMessages = EmailController.getEmailRecords(testClientCase.Id);
        Test.stopTest();
        System.assertEquals(2, emailMessages.size(), 'There should be 2 email messages');
        System.assertEquals('Subject 1', emailMessages[0].Subject, 'The most recent email should be first');
        System.assertEquals('Subject 2', emailMessages[1].Subject, 'The older email should be second');
    }

    @isTest
    static void testGetContactEmailAddress() {
        ClientCase__c testClientCase = [SELECT Id FROM ClientCase__c LIMIT 1];
        Test.startTest();
        String email = EmailController.getContactEmailAddress(testClientCase.Id);
        Test.stopTest();
        System.assertEquals('test@test.com1', email, 'The email address should match the Contact email');
    }

    @isTest
    static void testGetIntakeEmailAddress() {
        Intake__c intake = [SELECT Id FROM Intake__c LIMIT 1];
        Test.startTest();
        String email = EmailController.getIntakeEmailAddress(intake.Id);
        Test.stopTest();
        System.assertEquals('test@test.com1', email, 'The email address should match the Intake contact email');
    }

}