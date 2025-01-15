@IsTest
public with sharing class SaveGeneratedHudXmlTest {
    @TestSetup
    static void makeData(){
        TestDataFactory.createIntegrationSettings(true);
        List<X9902__c> x9902Recs = TestDataFactory.createX9902(1, false);
        x9902Recs[0].Summary9902SubmissionID__c = '2068030345';
        insert x9902Recs;
    }

    @IsTest
    static void verifySave() {
        MockHttpResponseGenerator mock = new MockHttpResponseGenerator();
        HttpRequest request = new HttpRequest();
        mock.respond(request);
        Test.setMock(HttpCalloutMock.class, mock);
        X9902__c x9902 = [SELECT Id FROM X9902__c LIMIT 1];
        Test.startTest();
        System.enqueueJob(new SaveGeneratedHudXml(blob.valueOf(TestDataFactory.getSampleXmlString()), x9902.Id, 'Summary-' + x9902.Id));
        Test.stopTest();
        ContentDocumentLink docLink = [SELECT ContentDocument.Title FROM ContentDocumentLink WHERE LinkedEntityId =:x9902.Id];
        System.assertEquals('Summary-' + x9902.Id, docLink.ContentDocument.Title);
    }
}