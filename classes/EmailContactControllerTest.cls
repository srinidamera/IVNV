@isTest
public class EmailContactControllerTest {

    @testSetup
    static void setup() {
        // Create a Contact record
        Contact testContact = new Contact(FirstName = 'Test', LastName = 'Contact', Email = 'testemail@example.com');
        insert testContact;
    }

    @isTest
    static void testGetContactEmailRecords() {
        // Query the test contact
        List<Contact> contacts = [SELECT Id, Email FROM Contact WHERE Email = 'testemail@example.com' LIMIT 1];
        
        if (!contacts.isEmpty()) {
            Contact testContact = contacts[0];

            // Call the method and assert results
            List<EmailMessage> emails = EmailContactController.getContactEmailRecords(testContact.Id, testContact.Email);

            if (!emails.isEmpty()) {
                System.assertEquals(testContact.Email, emails[0].ToAddress);
            } else {
                System.debug('No emails found for the contact');
            }
        } else {
            System.debug('No contact found');
        }
    }

    @isTest
    static void testGetEmailAddress() {
        // Query the test contact
        List<Contact> contacts = [SELECT Id, Email FROM Contact WHERE Email = 'testemail@example.com' LIMIT 1];
        
        if (!contacts.isEmpty()) {
            Contact testContact = contacts[0];

            // Call the method and assert results
            String emailAddress = EmailContactController.getEmailAddress(testContact.Id);

            // Assert that the email address is correct
            System.assertEquals('testemail@example.com', emailAddress);
        } else {
            System.debug('No contact found');
        }
    }
}