@IsTest
public class HUD9902ClientReportGenerateBatchTest {    
    @TestSetup
    static void setupData() {
        Id primaryClientRecordTypeId = [SELECT Id FROM RecordType WHERE SObjectType = 'Contact' AND Name = 'Primary Client' LIMIT 1].Id;
        Id affiliateRTI = [SELECT Id FROM RecordType WHERE SObjectType = 'Contact' AND Name = 'Affiliate' LIMIT 1].Id;
        
        TestDataFactory.createAutomationBypassCS(true);
        RecordType rt = [SELECT Id FROM RecordType WHERE DeveloperName = 'FinancialCapabilityCounseling' AND SObjectType = :HUD9902Helper.CLIENT_CASE_OBJECT LIMIT 1];
        x9902Categories__c newRecord = new x9902Categories__c(
            GroupItemID__c = '16', 
            Name = '1',
            GroupID__c = '24', 
            GroupName__c = 'Rental Counseling Outcomes', 
            ItemDescription__c = 'Withdrew from counseling', 
            SBIItemDescription__c = 'SampleSBIItemDescription'
        );
        insert newRecord;
        Account acc = TestDataFactory.createAccounts(1, true)[0];
        
        Contact con = TestDataFactory.createContacts(acc.Id, 1, false)[0];
        con.RecordTypeId = primaryClientRecordTypeId;
        con.PreferredLanguage__c = 'Cambodian';
        con.MailingCity = 'San Francisco';
        con.MailingStateCode = 'CA';
        con.MailingPostalCode = '94105';
        insert con;
        
        Contact con2 = TestDataFactory.createContacts(acc.Id, 1, false)[0];
        con2.RecordTypeId = affiliateRTI;
        con2.PreferredLanguage__c = 'Cambodian';
        con2.MailingCity = 'San Francisco';
        con2.MailingStateCode = 'CA';
        con2.MailingPostalCode = '94104';
        insert con2;
        
        User user = [SELECT Id FROM User WHERE IsActive = true LIMIT 1];
        
        ClientCase__c clientCase = TestDataFactory.createClientCases(1, false)[0];
        clientCase.RecordTypeId = rt.Id;
        clientCase.PrimaryClient__c = con.Id;
        clientCase.OwnerId = user.Id;
        clientCase.PropertyAddress__City__s = 'Los Angeles';
        clientCase.PropertyAddress__StateCode__s = 'CA';
        clientCase.PropertyAddress__PostalCode__s = '90001';
        clientCase.X1stTimeHomeBuyer__c = 'Yes';
        clientCase.PurchasePrice__c = 350000.00;
        clientCase.SettlementDate__c = Date.today();
        clientCase.ClosingCosts__c = 5000.00;
       // clientCase.TotalCashAndLoansRequired__c = 370000.00;
        clientCase.BuyersAgentSalesConcessions__c = '1500.00';
        clientCase.MSA__c = 'Los Angeles-Long Beach-Anaheim, CA';
        clientCase.HouseholdSize__c = 4;
        clientCase.Gender__c = 'Male';
        clientCase.MaritalStatus__c = 'Married';
        clientCase.Race__c = 'White';
        clientCase.Ethnicity__c = 'Hispanic';
        clientCase.HouseholdType__c = 'Married with dependents';
        clientCase.Education__c = 'Junior College';
        clientCase.FarmWorker__c = 'No';
        clientCase.RuralAreaStatus__c = 'Lives in a rural area';
        clientCase.EnglishProficiency__c = 'Limited English Proficient';
        clientCase.ColoniasResidence__c = 'No';
        clientCase.ClientHUDAssistance__c = 'Purchase REO Property';
        clientCase.DisabledStatus__c = 'No';
        clientCase.NumberofDependents__c = 2;
        clientCase.IntakeDate__c = Date.today();
        clientCase.CounselSessionDateStart__c = Date.today().addDays(-30);
        clientCase.CounselSessionDateEnd__c = Date.today();
        clientCase.CounselingSessionTypes__c = '3';
        clientCase.CounselingTermination__c = 'Dropped Out';
        clientCase.CounselingFee__c = 100.00;
        clientCase.HUDGrant__c = 'HECM';
        clientCase.GrantAmountUsed__c = 5000.00;
        clientCase.HECMCertificateIssueDate__c = Date.today().addDays(-365);
        clientCase.HECMCertificateExpirationDate__c = Date.today().addYears(1);
        clientCase.HECMCertificateID__c = 'HECM-12345';
        clientCase.ClientPredatoryLending__c = 'No';
        clientCase.X1stTimeHomeBuyer__c = 'Yes';
        clientCase.DiscriminationVictim__c = 'No';
        insert clientCase;

        X9902__c report = new X9902__c(
            PeriodStartDate__c = Date.today().addMonths(-3),
            PeriodEndDate__c = Date.today().addMonths(1),
            Quarter__c = 'Quarter 1'
        );
        insert report;
        
        List<sumoapp__AdditionalInfo__c> SumoEvents = TestDataFactory.createSumoEvent(5, false);
        for (sumoapp__AdditionalInfo__c AdditionalInfo: SumoEvents) {
            AdditionalInfo.RecordTypeId = Schema.SObjectType.sumoapp__AdditionalInfo__c.getRecordTypeInfosByName().get('Course').getRecordTypeId();
            AdditionalInfo.sumoapp__EndDatetime__c = DateTime.newInstance(2024, 1, 15).addDays(5);
            AdditionalInfo.Facilitator__c = UserInfo.getuserId();
            AdditionalInfo.sumoapp__StartDatetime__c =  Date.Today();
            AdditionalInfo.HUD_Purpose__c = 'Completed rental workshop';
            
        }
        insert SumoEvents;
        
        List<sumoapp__Attendee__c> Attendees = TestDataFactory.createAttendee(con, SumoEvents[0].Id, 7, false);
        
        
        integer i=0;
        for (sumoapp__Attendee__c att : Attendees) {
            att.Attendance_Status__c = 'Course Complete';
            att.sumoapp__ContactRelation__c = con.Id;          
            i++;
        }
        
        insert Attendees;
        
        Intake__c Intake = TestDataFactory.createIntakes(con, acc.Id, 1, True)[0];
        
        List<ClientCase__c> clientCases = TestDataFactory.createClientCases(5, false);
        for(ClientCase__c cs : clientCases){
            cs.IntakeDate__c = System.today().addDays(1);
            cs.RecordTypeId = rt.Id; 
            cs.PrimaryClient__c = con.Id;
        }
        /*for (Integer j = 0; i < 5; i++) {
            clientCases[j].IntakeDate__c = System.today().addDays(j);
            clientCases[j].RecordTypeId = rt.Id; 
            clientCases[j].PrimaryClient__c = con.Id;
        }*/
        insert clientCases;
        System.debug('-->'+[Select PrimaryClient__c from ClientCase__c]);

        List<Event> events = new List<Event>();
        Event evt;
        i=0;
        for (sumoapp__AdditionalInfo__c course : SumoEvents) {
            evt = new Event();
            evt.sumoapp__AdditionalInfo__c = course.Id;
            evt.WhatId = clientCases[i].id;
            evt.WhoId = con.Id;
            evt.Purpose__c = 'Rental Topics';
            evt.StartDateTime = System.now();
            evt.EndDateTime = System.now().addHours(2);
            evt.DurationInMinutes = 120;
            evt.AppointmentStatus__c = 'Attended';
            events.add(evt);
            i++;
        }
        insert events;
        
        List<Loan__c> loans = TestDataFactory.createLoan(con2, 5, false);
        for (Loan__c ln: loans) {
            ln.ClientCase__c = clientCases[0].Id;
        }
        insert loans;
    }
    
    @IsTest
    static void testBatchExecution() {
        X9902__c report = [SELECT Id, PeriodStartDate__c, Quarter__c, PeriodEndDate__c FROM X9902__c LIMIT 1];
        Test.startTest();
        HUD9902ClientReportGenerateBatch batch = new HUD9902ClientReportGenerateBatch(report.Id);
        Database.executeBatch(batch);
        Test.stopTest();
    }
    
    @IsTest
    static void testExecuteMethod() {
        X9902__c report = [SELECT Id, PeriodStartDate__c, Quarter__c, PeriodEndDate__c FROM X9902__c LIMIT 1];

        /*List<ClientCase__c> clientCase = [SELECT 
                                          Id, 
                                          OwnerId, Name, 
                                          PrimaryClient__c, 
                                          PrimaryClient__r.Account.ClientNumber__c, 
                                          PrimaryClient__r.MailingCity,
                                          PrimaryClient__r.MailingStateCode, 
                                          PrimaryClient__r.MailingPostalCode,
                                          PropertyAddress__City__s,
                                          PropertyAddress__StateCode__s,
                                          PropertyAddress__PostalCode__s,
                                          HouseholdSize__c, CounselSessionDuration__c,
                                          Gender__c,
                                          MaritalStatus__c, 
                                          Race__c, 
                                          Ethnicity__c, 
                                          HouseholdType__c,
                                          Education__c, PrimaryClient__r.PreferredLanguage__c,
                                          FarmWorker__c, 
                                          RuralAreaStatus__c, 
                                          EnglishProficiency__c, 
                                          ColoniasResidence__c,
                                          ClientHUDAssistance__c,
                                          DisabledStatus__c,
                                          NumberofDependents__c,
                                          IntakeDate__c,
                                          CounselSessionDateStart__c,
                                          CounselSessionDateEnd__c,
                                          CounselingSessionTypes__c,
                                          CounselingTermination__c,
                                          CounselingFee__c,
                                          HUDGrant__c,
                                          GrantAmountUsed__c,
                                          HECMCertificateIssueDate__c,
                                          HECMCertificateExpirationDate__c,
                                          HECMCertificateID__c,
                                          ClientPredatoryLending__c,
                                          X1stTimeHomeBuyer__c,
                                          DiscriminationVictim__c,
                                          ReferralSource__c,
                                          SettlementDate__c,
                                          CreditScore__c,
                                          MissingCreditScoreReason__c,
                                          CreditScoreSource__c,
                                          HouseholdDebt__c,
                                          MortgageDelinquency__c,
                                          SecondLoanExists__c,
                                          AreaMedianIncome__c,
                                          Purpose__c
                                          FROM ClientCase__c LIMIT 1];*/
        List<Event> evts = [SELECT Id, WhatId, WhoId, HUDActivityType__c, Purpose__c, Outcome__c
                                          FROM Event LIMIT 1];
        
        Test.startTest();
        HUD9902ClientReportGenerateBatch batch = new HUD9902ClientReportGenerateBatch(report.id);
        batch.execute(null, evts);
        Test.stopTest();
        
    }
    
     @IsTest
    static void testLoanNullCondition() {
        RecordType rt = [SELECT Id FROM RecordType WHERE DeveloperName = 'FinancialCapabilityCounseling' AND SObjectType = :HUD9902Helper.CLIENT_CASE_OBJECT LIMIT 1];
        User user = [SELECT Id FROM User WHERE IsActive = true LIMIT 1];
        Contact con = [Select Id from Contact LIMIT 1];

        /*ClientCase__c clientCase = new ClientCase__c();
        clientCase.RecordTypeId = rt.Id;
        clientCase.PrimaryClient__c = con.Id;
        clientCase.OwnerId = user.Id;
        clientCase.PropertyAddress__City__s = 'Los Angeles';
        clientCase.PropertyAddress__StateCode__s = 'CA';
        clientCase.PropertyAddress__PostalCode__s = '90001';
        clientCase.X1stTimeHomeBuyer__c = 'Yes';
        clientCase.PurchasePrice__c = 350000.00;
        clientCase.SettlementDate__c = Date.today();
        clientCase.ClosingCosts__c = 5000.00;
        //clientCase.TotalCashAndLoansRequired__c = 370000.00;
        clientCase.BuyersAgentSalesConcessions__c = '1500.00';
        clientCase.MSA__c = 'Los Angeles-Long Beach-Anaheim, CA';
        clientCase.ClientCaseStatus__c = 'Closed - Incomplete';
        insert clientCase;*/
        
        List<Event> evts = [SELECT Id, WhatId, WhoId, HUDActivityType__c, Purpose__c, Outcome__c
                                          FROM Event LIMIT 1];

        X9902__c report = new X9902__c(
            PeriodStartDate__c = Date.today().addMonths(-3),
            PeriodEndDate__c = Date.today().addMonths(1),
            Quarter__c = 'Quarter 1'
        );
        insert report;

        Test.startTest();
        HUD9902ClientReportGenerateBatch batch = new HUD9902ClientReportGenerateBatch(report.Id);
        batch.execute(null, evts);
        Test.stopTest();
    }
    
}