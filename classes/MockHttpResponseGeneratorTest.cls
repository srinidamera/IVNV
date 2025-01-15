@IsTest
public class MockHttpResponseGeneratorTest {
    
    @IsTest
    static void testResponseWithGetSubmissionInfo() {
        MockHttpResponseGenerator mock = new MockHttpResponseGenerator();

        HttpRequest req = new HttpRequest();
        req.setBody('<getSubmissionInfo>test</getSubmissionInfo>');

        HttpResponse res = mock.respond(req);

        System.assertEquals(200, res.getStatusCode());
        System.assertEquals('OK', res.getStatus());
        System.assertEquals('text/xml', res.getHeader('Content-Type'));
        System.assert(res.getBody().contains('<statusMessage>Success</statusMessage>'));
    }

    @IsTest
    static void testResponseWithoutGetSubmissionInfo() {
        MockHttpResponseGenerator mock = new MockHttpResponseGenerator();

        HttpRequest req = new HttpRequest();
        req.setBody('<someOtherRequest>test</someOtherRequest>');

        HttpResponse res = mock.respond(req);

        System.assertEquals(200, res.getStatusCode());
        System.assertEquals('OK', res.getStatus());
        System.assertEquals('text/xml', res.getHeader('Content-Type'));
        System.assert(res.getBody().contains('<submissionId>12345</submissionId>'));
    }
}