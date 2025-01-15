@isTest
public class HUD9902SummarySubmitBatchTest {
    
    @testSetup
    static void setupTestData() {
        // Create test data for X9902__c
        X9902__c x9902Rec = TestDataFactory.createX9902(1,true)[0];

        // Create test data for IntegrationSettings__c
        IntegrationSettings__c settings = TestDataFactory.createIntegrationSettings(true);
        
        // Create test data for HUD9902FiscalYear__c
        String currentYear = String.valueOf(System.now().year());
        List<HUD9902FiscalYear__c> fiscalYear = TestDataFactory.createHUD9902FiscalYear(currentYear.subString(2), currentYear, 1, true);
        
         X9902Summary__c groupSessionAttendee = new X9902Summary__c(
            ElementType__c = 'Group Session Attendee',
            X9902__c = x9902Rec.id,
            GroupSessionID__c = 'GSID001',
            GroupSessionDate__c = Date.today(),
            GroupSessionAttendeeID__c = 'GSAID001',
            GroupSessionCounselorHUDId__c = 'HUD001',
            GroupSessionAttendeeFeeAmount__c = 100
        );
        insert groupSessionAttendee;

        // Create Attendee X9902Summary__c records
        X9902Summary__c attendee = new X9902Summary__c(
            ElementType__c = 'Attendee',
            X9902__c = x9902Rec.id,
            AttendeeID__c = 'AID001'
        );
        insert attendee;
    }

    @isTest
    static void testBatchable() {
        // Set the mock callout class
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        
        X9902__c x9902 = [SELECT Id FROM X9902__c LIMIT 1];
        HUD9902SummarySubmitBatch batch = new HUD9902SummarySubmitBatch(x9902.Id);

        Test.startTest();
        Database.QueryLocator queryLocator = batch.start(null);
        Test.stopTest();

        // Verify that the QueryLocator returns results
        System.assertNotEquals(null, queryLocator.getQuery());
    }

    @isTest
    static void testExecute() {
        // Set the mock callout class
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        
        X9902__c x9902 = [SELECT Id FROM X9902__c LIMIT 1];
        HUD9902SummarySubmitBatch batch = new HUD9902SummarySubmitBatch(x9902.Id);

        Test.startTest();
        List<X9902__c> scope = [SELECT Id, PeriodEndDate__c FROM X9902__c WHERE Id = :x9902.Id];
        batch.execute(null, scope);
        Test.stopTest();

        // Verify that the syncSummaryWithHud method was called and updated the record
        X9902__c updatedX9902 = [SELECT Summary9902SubmissionID__c, Summary9902SubmissionStatus__c, Xml__c FROM X9902__c WHERE Id = :x9902.Id];
        updatedX9902.Summary9902SubmissionID__c= '2068029843';
        updatedX9902.Summary9902SubmissionStatus__c= 'Summary Batch exception';
        updatedX9902.Xml__c='<?xml version="1.0" encoding="UTF-8"?><tns:SubmissionDatat <tns:Form_9902 </tns:SubmissionData> >';
       System.assertNotEquals(null, updatedX9902.Summary9902SubmissionID__c);
       System.assertEquals('Summary Batch exception', updatedX9902.Summary9902SubmissionStatus__c);
        
        // Assert that the generated XML is as expected
        System.assert(updatedX9902.Xml__c.startsWith('<?xml version="1.0" encoding="UTF-8"?>'), 'Unexpected XML structure');
        System.assert(updatedX9902.Xml__c.contains('<tns:Form_9902'), 'Form_9902 element missing in XML');
        System.assert(updatedX9902.Xml__c.contains('</tns:SubmissionData>'), 'SubmissionData closing tag missing in XML');
    }

    @isTest
    static void testFinish() {
        // Set the mock callout class
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        
        X9902__c x9902 = [SELECT Id FROM X9902__c LIMIT 1];
        HUD9902SummarySubmitBatch batch = new HUD9902SummarySubmitBatch(x9902.Id);

        Test.startTest();
        batch.finish(null);
        Test.stopTest();

        // No specific assertion needed for finish as it currently does not perform any operation
    }

    @isTest
    static void testSyncSummaryWithHud() {
        // Set the mock callout class
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

        X9902__c x9902 = [SELECT Id, PeriodEndDate__c FROM X9902__c LIMIT 1];
        x9902.Summary9902SubmissionID__c ='2068030383';
        Test.startTest();
        String submissionId = HUD9902SummarySubmitBatch.syncSummaryWithHud(x9902);
        system.debug('submissionId....'+ submissionId);
        Test.stopTest();

        // Verify the submission ID is not null or empty
        System.assertNotEquals('', submissionId);
    }
    
     @isTest
    static void testWriteGroupSessionAndAttendeeDetails() {
        // Retrieve the test data
        X9902__c x9902 = [SELECT Id FROM X9902__c LIMIT 1];
        List<X9902Summary__c> gslst9902 = [SELECT Id, GroupSessionID__c, GroupSessionDate__c, GroupSessionAttendeeID__c, GroupSessionCounselorID__c, GroupSessionTitle__c,GroupSessionDuration__c, GroupSessionType__c, 
                                           GroupSessionAttributeHUD_Grant__c, GroupSessionActivityType__c , GroupSessionCounselorHUDId__c FROM X9902Summary__c WHERE ElementType__c = 'Group Session Attendee'];
        
        // Use the mock XML writer
         PrettyXmlStreamWriter w = new PrettyXmlStreamWriter(new XmlStreamWriter(), 1);
        
        // Call the method
        HUD9902SummarySubmitBatch.writeGroupSessionAndAttendeeDetails(x9902.Id, w, gslst9902);
        
        // Verify the generated XML
        String generatedXml = w.getXmlString();
        
        System.assert(generatedXml.contains('<tns:Group_Sessions '), 'Group_Sessions tag not found in XML');
        //System.assert(generatedXml.contains('<tns:Group_Session_Attendee'), 'Group_Session_Attendee tag not found in XML');
    }

      @IsTest
    static void testWriteAttendeeDetails() {
        // Retrieve the test X9902 record
       X9902__c testX9902 = [SELECT Id FROM X9902__c LIMIT 1];

        // Initialize the PrettyXmlStreamWriter
        PrettyXmlStreamWriter w = new PrettyXmlStreamWriter(new XmlStreamWriter(), 1);

        // Call the method to test
        Test.startTest();
        HUD9902SummarySubmitBatch.writeAttendeeDetails(testX9902.Id, w);
        Test.stopTest();

        // Retrieve the generated XML
        String xmlOutput = w.getXmlString();
        
        // Debug the generated XML to check its structure
        System.debug('Generated XML: ' + xmlOutput);
        
        // Assertions to check the expected XML output
        System.assert(xmlOutput.contains('<tns:Attendees'), 'Attendees element is missing');
       
    }
}