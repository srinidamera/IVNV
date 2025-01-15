@istest
public class NWQRCounselingReportControllerTest {
    
    @testSetup 
    static void testSetup() {
        string NWC2NameSpace = Utility.getNwc2NameSpace();
        string objectName = NWC2NameSpace + 'ClientCase__c';

        RecordType rtCC = [Select Id, DeveloperName from RecordType where SobjectType =: objectName And developerName = 'FinancialCapabilityCounseling'];
        Account acc = TestDataFactory.createAccounts(1, true)[0];
        Contact con = TestDataFactory.createContacts(acc.Id, 1, true)[0];
        CaseType__c ct = TestDataFactory.createCaseTypes(1,false)[0];
        ct.HUDPurpose__c = 'Homeless Assistance';
        insert ct;
        
        ClientCase__c cc = TestDataFactory.createClientCases(1,false)[0];
        cc.ClientCaseStatus__c = 'Closed - Complete';
        cc.RecordTypeId = rtCC.Id;
        cc.ClientCaseClosedDate__c = Date.Today();
        cc.Purpose__c = 'Homeless Assistance';
        cc.CaseResolution__c = 'Increase access to credit';
        cc.CaseResolutionDate__c = Date.Today();
        cc.DisabledStatus__c = 'No';
        cc.LastActivityType__c = 'Appointment';
        cc.CaseType__c = ct.Id;
        insert cc;
        
        sumoapp__AdditionalInfo__c info = TestDataFactory.createSumoEventInfo(1, true)[0];
        Event evt = TestDataFactory.createEvent(con, info.Id, 1, false)[0];
        evt.whoId = con.id;
        evt.Purpose__c = 'Resolving or Preventing Forward Mortgage Delinquency or Default';
        evt.StartDateTime = DateTime.now();
        evt.AppointmentStatus__c = 'Attended';
        evt.WhatId = cc.Id;
        insert evt;
	}
    
    static testMethod void testCounselingFetch(){
        
        Test.startTest();
        List<NWQRCounselingReportController.OrsReportWrapper> orsoutput = NWQRCounselingReportController.fetchOrsCounselingRecords(Date.Today() - 1,Date.Today() + 1);
        Test.StopTest();
        
        System.assertEquals(1,orsoutput.size());
    }

}