@IsTest
public with sharing class HudSubmissionStatusCheckTest {
    @TestSetup
    static void makeData(){
        TestDataFactory.createIntegrationSettings(true);
        List<X9902__c> x9902Recs = TestDataFactory.createX9902(1, false);
        x9902Recs[0].Summary9902SubmissionID__c = '2068030345';
        insert x9902Recs;
    }
 
    @IsTest
    static void verifyStatusCheck() {
        MockHttpResponseGenerator mock = new MockHttpResponseGenerator();
        HttpRequest request = new HttpRequest();
        mock.respond(request);
        Test.setMock(HttpCalloutMock.class, mock);
        X9902__c x9902 = [SELECT Id FROM X9902__c LIMIT 1];
        Test.startTest();
        System.enqueueJob(new HudSubmissionStatusCheck(blob.valueOf(TestDataFactory.getSampleXmlString()), '2068030345', x9902.Id, '9902_Summary'));
        Test.stopTest();
        x9902 = [SELECT Id, Summary9902SubmissionStatus__c FROM X9902__c WHERE Id =:x9902.Id];
        System.assertEquals('DONE', x9902.Summary9902SubmissionStatus__c);
    }
}