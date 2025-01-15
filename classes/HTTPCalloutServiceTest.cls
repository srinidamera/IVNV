@IsTest
public class HTTPCalloutServiceTest {
    
    @TestSetup
    static void setupTestData() {
        IntegrationSettings__c settings = new IntegrationSettings__c(
            Name = 'HUD Settings',
            EndpointURL__c = 'https://example.com/endpoint',
            AgencyID__c = '12345',
            AgencyName__c = 'Test Agency',
            VendorID__c = '67890',
            CMSPassword__c = 'password',
            Username__c = 'testuser',
            Password__c = 'testpassword'
        );
        insert settings;
    }
    
    @IsTest
    static void testPostHUDReport() {
        Test.startTest();
        String reqBody = '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/"><soapenv:Body><submissionId>12345</submissionId></soapenv:Body></soapenv:Envelope>';
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        String submissionId = HTTPCalloutService.postHUDReport(reqBody);
        Test.stopTest();
    }

    @IsTest
    static void testGetSubmissionInfo() {
        Test.startTest();
        String submissionID = '12345'; 
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        String submissionStatus = HTTPCalloutService.getSubmissionInfo(submissionID);
        Test.stopTest();
        
        System.debug('Submission Status: ' + submissionStatus);
    }
    

    @IsTest
    static void testGetHttprequest() {
        HttpRequest req = HTTPCalloutService.getHttprequest();
    }
    
    @IsTest
    static void testThreadSleep() {
        HTTPCalloutService.threadSleep(1000);
    }
}