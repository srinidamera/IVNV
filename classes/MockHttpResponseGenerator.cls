public class MockHttpResponseGenerator implements HttpCalloutMock {
    public HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'text/xml');
        res.setStatusCode(200);
        res.setStatus('OK');
        if(req.getBody().contains('getSubmissionInfo')) {
            // Return a valid XML body that matches what the real service would return
            res.setBody('<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/"><soapenv:Body><statusMessage>Success</statusMessage></soapenv:Body></soapenv:Envelope>');
        } else {
            res.setBody('<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/"><soapenv:Body><submissionId>12345</submissionId></soapenv:Body></soapenv:Envelope>');
        }
        
        return res;
    }
}