@IsTest
public class HUD9902SummaryReportControllerTest {
    
    @testSetup 
    static void testSetup() {
        // Create test data for X9902__c
        X9902__c x9902Rec = TestDataFactory.createX9902(1,false)[0];
        x9902Rec.PeriodStartDate__c = System.today().addDays(-10);
        insert x9902Rec;
                
        List<X9902Agency__c> x9902Agency1 = TestDataFactory.createX9902Agency(1, false, x9902Rec.Id, 'Profile');
        
        insert x9902Agency1;

        // Create test data for IntegrationSettings__c
        IntegrationSettings__c settings = TestDataFactory.createIntegrationSettings(true);
        
        // Create test data for HUD9902FiscalYear__c
        HUD9902FiscalYear__c fiscalYear = new HUD9902FiscalYear__c(
            Name = '2028',
            FiscalYearId__c = '28'
        );
        insert fiscalYear;
        
         X9902Summary__c summary = new X9902Summary__c(
            ElementType__c = '9902',
            X9902__c = x9902Rec.Id,
            GroupSessionID__c = 'GSID001',
            GroupSessionDate__c = Date.today(),
            GroupSessionAttendeeID__c = 'GSAID001',
            GroupSessionCounselorHUDId__c = 'HUD001',
            GroupSessionAttendeeFeeAmount__c = 100
        );
        insert summary;
	}
    
    @isTest
    static void get9902SummaryDetailsTest() {
        X9902__c x9902Rec = [Select Id from X9902__c limit 1];
        Test.startTest();
            PageReference pageRef = Page.HUD9902Summary;
            Test.setCurrentPage(pageRef);
            pageRef.getParameters().put('recId', x9902Rec.Id);
            HUD9902SummaryReportController objCtrl = new HUD9902SummaryReportController();
        Test.stopTest();
    }

}