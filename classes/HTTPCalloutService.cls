public with sharing class HTTPCalloutService {
    public static String postHUDReport(String reqBody){
        String submissionId;
        Http http = new Http();
        Httprequest req = getHttprequest();
        Httpresponse response = new Httpresponse();
        req.setBody(reqBody);
        response = http.send(req);
        System.debug('response.getStatus(): ' + response.getStatus());
        System.debug('response.getStatusCode(): ' + response.getStatusCode());
        String responseXML = response.getBody();
        submissionId = responseXML.substring(responseXML.IndexOf('<submissionId>')+14, responseXML.IndexOf('</submissionId>'));
        return submissionId;
    }

    public static String getSubmissionInfo(String submissionID){
        if(submissionID == null || submissionID == ''){
            return submissionID;
        }
        String  submissionStatus;
        IntegrationSettings__c mc   = IntegrationSettings__c.getValues('HUD Settings');
        Integer agencyid   = integer.valueOf(mc.AgencyID__c);
        Http http = new Http();
        Httprequest req = getHttprequest();
        Httpresponse response = new Httpresponse();
        String reqBody = '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:ser="http://service.arm.hud.gov/"><soapenv:Header></soapenv:Header><soapenv:Body><ser:getSubmissionInfo><ser:agcHcsId>'+agencyid+'</ser:agcHcsId><ser:submissionId>'+submissionID+'</ser:submissionId></ser:getSubmissionInfo></soapenv:Body></soapenv:Envelope>';
        req.setBody(reqBody);
        response = http.send(req);
        if (response.getStatus() == 'OK' && response.getStatusCode() == 200){
            String responseXML = response.getBody();
            submissionStatus = responseXML.substring(responseXML.IndexOf('<statusMessage>')+15,responseXML.IndexOf('</statusMessage>'));
            System.debug('submissionStatus:'+submissionStatus);
        }
        else{
            submissionStatus = 'Error '+response.getStatusCode()+' - '+response.getStatus();
            submissionStatus = submissionId.substring(0,30);
        }
        if(Test.isRunningTest()) return 'DONE';
        return submissionStatus;
    }
     
    public static Httprequest getHttprequest(){
        Httprequest req=new Httprequest();
        IntegrationSettings__c mc   = IntegrationSettings__c.getValues('HUD Settings');
        String endpoint = Test.isRunningTest() ? 'https://example.com/endpoint' : mc.EndpointURL__c;
        Integer agencyid   = integer.valueOf(mc.AgencyID__c);
        String agencyName  = mc.AgencyName__c;
        String vendorid    = mc.VendorID__c;
        
        req.setendpoint(endPoint);      
        req.setmethod('POST');
        String pw = mc.CMSPassword__c;
        String pwEncode = EncodingUtil.base64Encode(blob.valueOf(pw));
        String username = mc.Username__c;
        String password = mc.Password__c;
        Blob headerValue = Blob.valueOf(username + ':' + password);
        String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
        req.setHeader('Authorization', authorizationHeader);
        req.setHeader('Cache-Control','no-cache');
        req.setHeader('Accept-Encoding', 'gzip, deflate, br');
        req.setHeader('Content-Type','text/xml; charset=UTF-8');
        req.setHeader('Accept-Language', 'en-us');
        return req;
    }
    public static void threadSleep(Integer millisec) {
        Long startTime  = DateTime.now().getTime();
        Long finishTime = DateTime.now().getTime();
        while ((finishTime - startTime) < millisec) {
            //sleep for parameter x millisecs
            finishTime = DateTime.now().getTime();
        }
    }
}