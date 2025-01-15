@isTest
public class EventLogTriggerTest {
    
    @isTest
    static void testEventLogTrigger() {
        // Create mock data for the EventLog__e platform event
        List<EventLog__e> eventLogs = new List<EventLog__e>();
        
        // Populate with a sample EventLog__e record
        EventLog__e eventLog = new EventLog__e(
            RelatedToRecord__c = '0012o00001H7dYFAQ1', // Sample ID, can be any string
            GovtLimitinExecutingCode__c = 'TestGovtCode',
            ExceptionMessage__c = 'Test exception message',
            ExceptionType__c = 'Test exception type',
            LineNumber__c = 10, // Ensure this is a number if LineNumber__c is Decimal
            StackTrace__c = 'Test stack trace',
            MethodName__c = 'TestMethod',
            ClassName__c = 'TestClass'
        );
        
        eventLogs.add(eventLog);

        // Simulate the publishing of platform events
        Test.startTest();
        EventBus.publish(eventLogs);
        Test.stopTest();

        // Query the Log__c records created by the trigger
        List<Log__c> logs = [SELECT RelatedToRecord__c, RecordLink__c, GovtLimitinExecutingCode__c, 
                             ExceptionMessage__c, ExceptionType__c, LineNumber__c, 
                             StackTrace__c, MethodName__c, ClassName__c 
                             FROM Log__c];
        
        // Assert that the Log__c records have been created
        System.assertEquals(1, logs.size(), 'One Log__c record should be created');
        
        Log__c log = logs[0];
        
        // Verify the fields in the Log__c record
        System.assertEquals(eventLog.RelatedToRecord__c, log.RelatedToRecord__c, 'RelatedToRecord__c should match');
        System.assertEquals('/' + eventLog.RelatedToRecord__c, log.RecordLink__c, 'RecordLink__c should be correctly set');
        System.assertEquals(eventLog.GovtLimitinExecutingCode__c, log.GovtLimitinExecutingCode__c, 'GovtLimitinExecutingCode__c should match');
        System.assertEquals(eventLog.ExceptionMessage__c, log.ExceptionMessage__c, 'ExceptionMessage__c should match');
        System.assertEquals(eventLog.ExceptionType__c, log.ExceptionType__c, 'ExceptionType__c should match');
        System.assertEquals(eventLog.LineNumber__c, log.LineNumber__c, 'LineNumber__c should match');
        System.assertEquals(eventLog.StackTrace__c, log.StackTrace__c, 'StackTrace__c should match');
        System.assertEquals(eventLog.MethodName__c, log.MethodName__c, 'MethodName__c should match');
        System.assertEquals(eventLog.ClassName__c, log.ClassName__c, 'ClassName__c should match');
    }
}