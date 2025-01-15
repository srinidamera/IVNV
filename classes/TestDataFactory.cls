/*
* @description    Utility Class providing methods to generate test data for each object. This class is flagged as a Test Class and can be used only in the context
*                 of test methods with the purpose to provide a generic way to generate test data. This class can be enriched with specific object methods
*                 in case of need.
*/
@IsTest
public class TestDataFactory {
    /*
* @desc: Method provides flexibility to return List<User> by performing DML
* and also without DML for test classes
*/
    public static List<User> createUsers(
        String profileId,
        String roleId,
        Integer nbOfRecords,
        Boolean executeDML
    ) {
        List<User> userList = new List<User>();
        if (string.IsBlank(profileId))
            profileId = UserInfo.getProfileId();
        if (string.IsBlank(roleId))
            roleId = UserInfo.getUserRoleId();
        
        User u;
        for (Integer i = 1; i <= nbOfRecords; i++) {
            u = new User();
            u.Alias = 'utst';
            u.Email = 'utst@test.com' + i;
            u.LastName = 'Default Last Name';
            u.FirstName = 'Default First Name';
            u.ProfileId = profileId;
            u.UserName = 'utst@test.com' + i;
            u.UserRoleId = roleId;
            u.EmailEncodingKey = 'UTF-8';
            u.LocaleSidKey = 'en_US';
            u.LanguageLocaleKey = 'en_US';
            u.TimeZoneSidKey = 'Europe/Brussels';
            userList.add(u);
        }
        
        if (executeDML && userList.size() > 0) {
            insert userList;
        }
        
        return userList;
    }
    /*
* @desc: Method provides flexibility to return List<Account> by performing DML
* and also without DML for test classes
*/
    public static List<Account> createAccounts(
        Integer nbOfRecords,
        Boolean executeDML
    ) {
        List<Account> acctList = new List<Account>();
        Account acct;
        for (Integer i = 1; i <= nbOfRecords; i++) {
            acct = new Account();
            acct.Name = 'TestAccount' + i;
            acctList.add(acct);
        }
        
        if (executeDML && acctList.size() > 0) {
            insert acctList;
        }
        
        return acctList;
    }
    
    /*
* @desc: Method provides flexibility to return List<Contact> by performing DML
* and also without DML for test classes
*/
    public static List<Contact> createContacts(
        Id accountId,
        Integer nbOfRecords,
        Boolean executeDML
    ) {
        List<Contact> conList = new List<Contact>();
        Contact con;
        RecordType rt = [Select Id, DeveloperName from RecordType where SobjectType='Contact' AND DeveloperName = 'PrimaryClient' limit 1];
        for (Integer i = 1; i <= nbOfRecords; i++) {
            con = new Contact();
            con.RecordTypeId = rt.Id;
            con.FirstName = 'TestFirst';
            con.LastName = 'TestLastName' + i;
            con.Email = 'test@test.com' + i;
            con.AccountId = accountId != null ? accountId : null;
            conList.add(con);
        }
        
        if (executeDML && conList.size() > 0) {
            insert conList;
        }
        
        return conList;
    }
    
    /*
* @desc: Method provides flexibility to return List<ClientCase__c> by performing DML
* and also without DML for test classes
*/
    public static List<ClientCase__c> createClientCases(
        Integer nbOfRecords,
        Boolean executeDML
    ) {
        List<ClientCase__c> clientCaseList = new List<ClientCase__c>();
        ClientCase__c clientCase;
        for (Integer i = 1; i <= nbOfRecords; i++) {
            clientCase = new ClientCase__c();
            clientCase.EmailAddress__c = 'test@test.com' + i;
            clientCase.IntakeDate__c = Date.Today();
            clientCase.PhoneNumber__c = '7867564534';
            clientCase.ClientCaseStatus__c = 'Closed - Incomplete';
            clientCase.CreditScore__c = 100;
            clientCase.Repository__c = 'Equifax';
            clientCase.CaseResolution__c = 'Credit Score and/or resolved credit issues';
            clientCase.SettlementDate__c = Date.Today();
            clientCaseList.add(clientCase);
        }
        
        if (executeDML && clientCaseList.size() > 0) {
            insert clientCaseList;
        }
        
        return clientCaseList;
    }
    
    /*
* @desc: Method provides flexibility to return List<CloudDocument__c> by performing DML
* and also without DML for test classes
*/
    public static List<CloudDocument__c> createCloudDocument(
        Id conId,
        Integer nbOfRecords,
        Boolean executeDML
    ) {
        List<CloudDocument__c> cloudDocumentList = new List<CloudDocument__c>();
        CloudDocument__c cloudDoc;
        for (Integer i = 1; i <= nbOfRecords; i++) {
            cloudDoc = new CloudDocument__c();
            cloudDoc.Contact__c = conId;
            cloudDoc.DecodedFileLocation__c = 'test Loc ' + i;
            cloudDoc.Filetype__c = 'test fileType ' + i;
            cloudDoc.FolderName__c = 'test folder ' + i;
            cloudDoc.fileName__c = 'test filte type ' + i;
            cloudDoc.FileContentPrefix__c = 'NW';
            cloudDocumentList.add(cloudDoc);
        }
        
        if (executeDML && cloudDocumentList.size() > 0) {
            insert cloudDocumentList;
        }
        
        return cloudDocumentList;
    }
    
    /*
* @desc: Method provides flexibility to return List<ClientCaseTask__c> by performing DML
* and also without DML for test classes
*/
    public static List<ClientCaseTask__c> createClientCaseTasks(
        ClientCase__c clientCase,
        Integer nbOfRecords,
        Boolean executeDML
    ) {
        List<ClientCaseTask__c> clientCaseTaskList = new List<ClientCaseTask__c>();
        ClientCaseTask__c clCaseTask;
        List<Utility.PicklistOption> status = ClientCaseGuidanceController.getStatusPicklist();
        for (Integer i = 1; i <= nbOfRecords; i++) {
            clCaseTask = new ClientCaseTask__c();
            clCaseTask.Name = 'Test Task' + i;
            clCaseTask.StepName__c = 'Step ' + i;
            clCaseTask.ClientCase__c = clientCase.Id;
            clCaseTask.Status__c = status[Math.mod(i - 1, 4)].value;
            clCaseTask.Display_Order__c = i;
            clCaseTask.Comments__c = 'Test Comment ' + i;
            clCaseTask.StepDetails__c = 'Sample Details:<ul><li>One</li><li>Two</li><li>Three</li><li>Four</li></ul>Sample ends';
            clientCaseTaskList.add(clCaseTask);
        }
        
        if (executeDML && clientCaseTaskList.size() > 0) {
            insert clientCaseTaskList;
        }
        
        return clientCaseTaskList;
    }
    
    public static List<CaseType__c> createCaseTypes(
        Integer nbOfRecords,
        Boolean executeDML
    ) {
        List<CaseType__c> caseTypes = new List<CaseType__c>();
        CaseType__c cs = new CaseType__c();
        for (Integer i = 1; i <= nbOfRecords; i++) {
            cs = new CaseType__c(Name = 'Test' + i);
            caseTypes.add(cs);
        }
        
        if (executeDML && caseTypes.size() > 0) {
            insert caseTypes;
        }
        
        return caseTypes;
    }
    
    /*
* @desc: Method provides flexibility to return AgencyProfile__c by performing DML
* and also without DML for test classes
*/
    public static AgencyProfile__c createAgencyProfile(Boolean executeDML) {
        AgencyProfile__c ap = new AgencyProfile__c();
        ap.Name = 'Test Agency';
        if (executeDML) {
            insert ap;
        }
        return ap;
    }
    
    /*
* @desc: Method provides flexibility to return CounselorNote__c by performing DML
* and also without DML for test classes
*/
    
    public static List<CounselorNote__c> createCounselorNote(Id clientCaseId, Id contactId,Integer numberOfRecords, boolean executeDML) {
        List<CounselorNote__c> notes = new List<CounselorNote__c>();
        for(Integer i =0; i<numberOfRecords; i++){
            CounselorNote__c note = new CounselorNote__c();
            note.Duration__c=35;
            note.StartDatetime__c=System.now().addMinutes(Integer.valueOf(Math.random()*100));
            note.subject__c='Hosing Counselor Notes Test '+i;
            note.ClientCase__c = clientCaseId;
            note.Contact__c=contactId;
            notes.add(note);
        }
        
        if(executeDML) {
            Database.insert(notes);
        }
        
        
        return notes;
    }
    
    /*
* @desc: Method provides flexibility to return CounselorNote__c by performing DML
* and also without DML for test classes
*/
    
    public static List<CounselorNote__c> createGoal(Id clientCaseId, Id contactId,Integer numberOfRecords, boolean executeDML) {
        List<CounselorNote__c> notes = new List<CounselorNote__c>();
        for(Integer i =0; i<numberOfRecords; i++){
            CounselorNote__c note = new CounselorNote__c();
            note.Duration__c=35;
            note.StartDatetime__c=System.now().addMinutes(Integer.valueOf(Math.random()*100));
            note.subject__c='Hosing Counselor Notes Test '+i;
            note.ClientCase__c = clientCaseId;
            note.Contact__c = contactId;
            notes.add(note);
        }
        
        if(executeDML) {
            Database.insert(notes);
        }
        
        
        return notes;
    }
    
    /*
* @desc: Method returns community user with given profile, email and lastName for test classes.
*/
    public static User createCommunityUser(String communityProfileName, String email, String lName, Boolean isInsert) {
        Profile communityProfile = [SELECT Id, Name FROM Profile WHERE Name LIKE '%Community%' LIMIT 1];
        Account acc = createAccounts(1, true)[0];
        Contact con = createContacts(acc.Id, 1, false)[0];
        con.Email = email;
        con.LastName = lName;
        con.Accountid = acc.Id;
        insert con;
        
        User communityUser = new User (
            Email = email,
            ProfileId = communityProfile.Id, 
            UserName = email, 
            Alias = 'Test',
            TimeZoneSidKey = 'America/New_York',
            EmailEncodingKey = 'ISO-8859-1',
            LocaleSidKey = 'en_US', 
            LanguageLocaleKey = 'en_US',
            ContactId = con.Id,
            PortalRole = 'Manager',
            FirstName = 'Firstname',
            LastName = lName
        );
        if (isInsert) insert communityUser;
        return communityUser;
    }
    
    
    /*
* @desc: Method creates Sumo Event records.
* It provides flexibility to control the number of records created and 
* whether DML operations are executed.
*/
    public static List<sumoapp__AdditionalInfo__c> createSumoEvent(Integer numberOfRecords, boolean executeDML) {
        List<sumoapp__AdditionalInfo__c> sumoEvents = new List<sumoapp__AdditionalInfo__c>();
        
        for (Integer i = 0; i < numberOfRecords; i++) {
            sumoapp__AdditionalInfo__c sumoEvent = new sumoapp__AdditionalInfo__c(
                sumoapp__EventName__c = 'Test Event Name ' + i,
                sumoapp__StartDatetime__c = System.now(),
                sumoapp__EndDatetime__c = System.now().addHours(2)
            );
            
            sumoEvents.add(sumoEvent);
        }
        
        if (executeDML) {
            insert sumoEvents;
        }
        
        return sumoEvents;
    }
    
    
    /*
* @desc: Method creates Attendee records associated with a Contact. 
* It provides flexibility to control the number of records created and 
* whether DML operations are executed.
*/
    public static List<sumoapp__Attendee__c> createAttendee(Contact con, Id sumoEventId, Integer numberOfRecords, boolean executeDML) {
        List<sumoapp__Attendee__c> attendees = new List<sumoapp__Attendee__c>();
        
        for (Integer i = 0; i < numberOfRecords; i++) {
            sumoapp__Attendee__c attendee = new sumoapp__Attendee__c(
                sumoapp__SumoEvent__c = sumoEventId,
                sumoapp__Status__c = 'BOOKED',
                sumoapp__ContactRelation__c = con.id,
                Attendance_Status__c = 'No Show'
            );           
            attendees.add(attendee);
        }
        
        if (executeDML) {
            insert attendees;
        }
        
        return attendees;
    }
    
    
    /*
* @desc: Method creates Sumo Event Info records.
* It provides flexibility to control the number of records created and 
* whether DML operations are executed.
*/
    public static List<sumoapp__AdditionalInfo__c> createSumoEventInfo(Integer numberOfRecords, boolean executeDML) {
        List<sumoapp__AdditionalInfo__c> sumoEventsInfo = new List<sumoapp__AdditionalInfo__c>();
        
        Id recordTypeId = [SELECT Id FROM RecordType WHERE DeveloperName = 'Event' AND SobjectType = 'sumoapp__AdditionalInfo__c' LIMIT 1]?.Id;
        
        for (Integer i = 0; i < numberOfRecords; i++) {
            
            sumoapp__AdditionalInfo__c info = new sumoapp__AdditionalInfo__c();
            info.sumoapp__StartDatetime__c = System.now().addMinutes(-30);
            info.sumoapp__EventName__c = 'Test Course ' + i;
            info.RecordTypeId = recordTypeId;
            
            sumoEventsInfo.add(info);
        }
        
        if (executeDML) {
            insert sumoEventsInfo;
        }
        
        return sumoEventsInfo;
    }
    
    public static AgencyProfile__c InsertAgencyRecord(boolean executeDML) {
        AgencyProfile__c agencyProfile = new AgencyProfile__c(
            Name = 'Test Agency',
            AgencyEmailAddress__c = 'test@example.com',
            AgencyAddress__Street__s = '123 Test St',
            AgencyAddress__City__s = 'Test City',
            AgencyAddress__PostalCode__s = '12345',
            AgencyAddress__StateCode__s = 'CA',
            AgencyAddress__CountryCode__s = 'US',
            AgencyPhoneNumber__c = '555-123-4567'
        );
        
        if (executeDML) {
            insert agencyProfile;
        }
        
        return agencyProfile;
    }
    
    
    /*
* @desc: Method creates Event records associated with a Contact. 
* It provides flexibility to control the number of records created and 
* whether DML operations are executed.
*/
    public static List<Event> createEvent(Contact con, Id sumoEventInfoId, Integer numberOfRecords, boolean executeDML) {
        List<Event> events = new List<Event>();
        
        for (Integer i = 0; i < numberOfRecords; i++) {
            Event evt = new Event();
            evt.sumoapp__AdditionalInfo__c = sumoEventInfoId;
            evt.WhoId = con.Id;
            evt.Purpose__c = 'Non-Delinquency Post-Purchase';
            evt.Outcome__c = 'Households that received one-on-one counseling that also received education services.';
            evt.Description = 'Test Description ' + i;
            evt.StartDateTime = Date.today().addDays(3);
            evt.DurationInMinutes = 60;
            
            events.add(evt);
        }
        
        if (executeDML) {
            insert events;
        }
        
        return events;
    }
    
    
    /*
* @desc: Method creates CounselorNote records associated with a Contact and ClientCase. 
* It provides flexibility to control the number of records created and 
* whether DML operations are executed.
*/
    public static List<CounselorNote__c> createCounselorNote(Contact con, ClientCase__c clientCase, Integer numberOfRecords, boolean executeDML) {
        List<CounselorNote__c> counselorNotes = new List<CounselorNote__c>();
        
        for (Integer i = 0; i < numberOfRecords; i++) {
            CounselorNote__c counselorNote = new CounselorNote__c(
                ClientCase__c = clientCase.Id,
                Subject__c = 'Test Sub ' + i,
                Contact__c = con.id,
                StartDatetime__c = DateTime.now().addDays(-1),
                Notes__c = 'Test Note ' + i,
                Duration__c = 30
            );
            counselorNotes.add(counselorNote);
        }
        try{
            if (executeDML) {
                insert counselorNotes;
            }            
        }catch (Exception e) {
            String errorMessage = 'Error inserting CounselorNote__c: ' + e.getMessage() + '\n' + e.getStackTraceString();
            System.debug(errorMessage);
        }  
        
        
        return counselorNotes;
    }
    
    /**
* @desc: Method creates Loan records associated with a Contact.
* It provides flexibility to control the number of records created and
* whether DML operations are executed.
*/
    public static List<Loan__c> createLoan(Contact con, Integer numberOfRecords, boolean executeDML) {
        return createLoan(con, null, numberOfRecords, executeDML);
    }
    
    /**
* @desc: Method creates Loan records associated with a Contact.
* It provides flexibility to control the number of records created and
* whether DML operations are executed.
*/
    public static List<Loan__c> createLoan(Contact con, String clientCaseId, Integer numberOfRecords, boolean executeDML) {
        List<Loan__c> loans = new List<Loan__c>();
        
        for (Integer i = 0; i < numberOfRecords; i++) {
            Loan__c loan = new Loan__c(
                MortgageType__c = '1 - year ARM',
                LienPosition__c = '2', 
                InterestRate__c = 3.5, 
                MortgageInsuranceType__c = 'Other Mortgage Insurance',
                MonthlyPI__c = 1500, 
                MonthlyMortgageInsuranceAmount__c = 0, 
                ApplicationStatus__c = 'Approved',
                Lender__c = con.id,
                ProgramName__c = 'Test Program',
                ClientCase__c = clientCaseId,
                Amount__c = 100
            );
            
            loans.add(loan);
        }
        
        if (executeDML) {
            insert loans;
        }
        
        return loans;
    }
    
    /**
* @description : Create intakes 
*/
    public static List<Intake__c> createIntakes(Contact relatedContact, id AccountId, Integer size, Boolean isInsert) {
        List<Intake__c> intakes = new List<Intake__c>();
        for(Integer i=0; i<size; i++) { 
            Intake__c intake = new Intake__c();
            intake.ColoniasResidence__c='No';
            intake.CreditScore__c=223;
            intake.CurrentResidence__c='Own';
            intake.DisabledStatus__c='No';
            intake.Education__c='None';
            intake.Employment_Status__c='Employed Full-Time';
            intake.EnglishProficiency__c='Limited English Proficient';
            intake.Ethnicity__c='Hispanic';
            intake.FarmWorker__c='No';
            intake.Gender__c='Male';
            intake.HouseholdMonthlyIncome__c=1222;
            intake.MonthlyCreditorsDebt__c=2333;
            intake.MonthlyIncome__c=1222;
            intake.NumberofDependents__c=2;
            intake.Occupation__c='Test';
            //intake.PreferredLanguage__c='English';
            intake.PrimaryClient__c=relatedContact.Id;
            intake.Household__c=accountId;
            //intake.Status__c='Open Intake';
            intakes.add(intake);
        }
        
        if(isInsert) {
            insert intakes;
        }
        
        return intakes;
        
    }
    
    /**
    * @desc: Method creates IntegrationSettings__c records with predefined values.
    * It provides flexibility to control the number of records created and
    * whether DML operations are executed.
    */
    public static IntegrationSettings__c createIntegrationSettings(boolean executeDML) {
        
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
        
        
        if (executeDML) {
            insert settings;
        }
        
        return settings;
    }
    
    /**
* @desc: Method creates X9902__c records with predefined values.
* It provides flexibility to control the number of records created and
* whether DML operations are executed.
*/
    public static List<X9902__c> createX9902(Integer numberOfRecords, boolean executeDML) {
        List<X9902__c> recs = new List<X9902__c>();
        
        for (Integer i = 0; i < numberOfRecords; i++) {
            X9902__c rec = new X9902__c(
                PeriodStartDate__c = Date.today().addDays(-1),
                PeriodEndDate__c = Date.today().adddays(365),
                FiscalYear__c = String.valueof(Date.today().year())
            );
            
            recs.add(rec);
        }
        
        if (executeDML) {
            insert recs;
        }
        
        return recs;
    }
    
    /**
* @desc: Method creates X9902Counselor__c records with predefined values.
* It provides flexibility to control the number of records created and
* whether DML operations are executed.
*/
    public static List<X9902Counselor__c> createX9902Counselor(Integer numberOfRecords, boolean executeDML, String x9902RecId, String elementType) {
        List<X9902Counselor__c> recs = new List<X9902Counselor__c>();
        
        for (Integer i = 0; i < numberOfRecords; i++) {
            X9902Counselor__c rec = new X9902Counselor__c(
                X9902__c = x9902RecId,
                ElementType__c = elementType
            );
            
            recs.add(rec);
        }
        
        if (executeDML) {
            insert recs;
        }
        
        return recs;
    }
    
	/**
* @desc: Method creates HUD9902FiscalYear__c records with predefined values.
* It provides flexibility to control the number of records created and
* whether DML operations are executed.
*/
    public static List<HUD9902FiscalYear__c> createHUD9902FiscalYear(Integer numberOfRecords, boolean executeDML) {
        return createHUD9902FiscalYear('28', '2028', numberOfRecords, executeDML);
    }
    
    /**
* @desc: Method creates HUD9902FiscalYear__c records with predefined values.
* It provides flexibility to control the number of records created and
* whether DML operations are executed.
*/
    public static List<HUD9902FiscalYear__c> createHUD9902FiscalYear(String fiscalYearID, String fiscalYearName, Integer numberOfRecords, boolean executeDML) {
        List<HUD9902FiscalYear__c> recs = new List<HUD9902FiscalYear__c>();
        
        for (Integer i = 0; i < numberOfRecords; i++) {
            HUD9902FiscalYear__c rec = new HUD9902FiscalYear__c(
                FiscalYearID__c = fiscalYearID,
                Name = fiscalYearName
            );
            
            recs.add(rec);
        }
        
        if (executeDML) {
            insert recs;
        }
        
        return recs;
    }
    
    /**
* @desc: Method creates CounselorTraining__c records with predefined values.
* It provides flexibility to control the number of records created and
* whether DML operations are executed.
*/
    public static List<CounselorTraining__c> createCounselorTraining(Integer numberOfRecords, boolean executeDML, String userId) {
        List<CounselorTraining__c> recs = new List<CounselorTraining__c>();
        
        for (Integer i = 0; i < numberOfRecords; i++) {
            CounselorTraining__c rec = new CounselorTraining__c(
                Counselor__c = userId,
                TrainingCourseEndDate__c = Date.today().addMonths(-6),
                TrainingDuration__c = 5,
                TrainingOrganization__c = 'Others ',
                TrainingTitle__c = 'Test Training'
            );
            
            recs.add(rec);
        }
        
        if (executeDML) {
            insert recs;
        }
        
        return recs;
    }
    
    /**
* @desc: Method creates X9902Agency__c records with predefined values.
* It provides flexibility to control the number of records created and
* whether DML operations are executed.
*/
    public static List<X9902Agency__c> createX9902Agency(Integer numberOfRecords, boolean executeDML, String x9902RecId, String elementType) {
        List<X9902Agency__c> recs = new List<X9902Agency__c>();
        
        for (Integer i = 0; i < numberOfRecords; i++) {
            X9902Agency__c rec = new X9902Agency__c(
                X9902__c = x9902RecId,
                ElementType__c = elementType,
                AgencysOfficeEmailAddress__c = 'test@etest.com',
                AgencyLanguages__c = '2;3',
                AgencyCounselingMethods__c = '1;2',
                AgencyMailingAddressLine1__c = 'line 1',
                AgencyMailingAddressLine2__c = 'test',
                AgencyMailingAddressCity__c = 'test',
                AgencyMailingAddressState__c = 'AK',
                AgencyMailingAddressZipCode__c = '12345'
                
            );
            
            recs.add(rec);
        }
        
        if (executeDML) {
            insert recs;
        }
        
        return recs;
    }
    
    public static List<FinancialSnapshot__c> createFinancialSnapshots(
        Id clientCaseId,
        Integer nbOfRecords,
        Boolean executeDML
    ) {
        List<FinancialSnapshot__c> snapshotList = new List<FinancialSnapshot__c>();
        FinancialSnapshot__c snapshot;
        
        for (Integer i = 1; i <= nbOfRecords; i++) {
            snapshot = new FinancialSnapshot__c();
            snapshot.CreditScore__c = 750 + i; 
            snapshot.CoAppCreditScore__c = 720 + i;
            snapshot.Savings__c = 15000 + (i * 1000);
            snapshot.GrossMonthlyIncome__c = 6000 + (i * 500);
            snapshot.NetMonthlyIncome__c = 5000 + (i * 400);
            snapshot.CurrentMonthlyDebtObligation__c = 1000 + (i * 100);
            snapshot.HousingExpense__c = 1200 + (i * 50);
            snapshot.TotalDebt__c = 20000 + (i * 2000);
            snapshot.TotalAssets__c = 100000 + (i * 5000);
            snapshot.NetWorth__c = 80000 + (i * 3000);
            snapshot.ClientCase__c = clientCaseId;
            
            snapshotList.add(snapshot);
        }
        
        if (executeDML && snapshotList.size() > 0) {
            insert snapshotList;
        }
        
        return snapshotList;
    }
    
    public static List<HUDAMIData__c> createHUDAMIDataRecords(
        Integer nbOfRecords,
        Boolean executeDML
    ) {
        List<HUDAMIData__c> hudamiDataList = new List<HUDAMIData__c>();
        HUDAMIData__c hudamiData;
        
        for (Integer i = 1; i <= nbOfRecords; i++) {
            hudamiData = new HUDAMIData__c(
                CountyName__c = 'SampleCounty' + i,
                TownName__c = 'SampleTown' + i,
                Zipcode__c = '12345' + i,
                StateCode__c = 'SC',
                StateName__c = 'SampleState',
                MedianFamilyIncome__c = String.valueOf(60000 + (i * 1000)),
                il_metro_name__c = 'SampleMetro' + i,
                Areaname__c = 'SampleArea' + i,
                il30p1__c = String.valueOf(20000 + (i * 500)),
                il30p2__c = String.valueOf(25000 + (i * 500)),
                il30p3__c = String.valueOf(30000 + (i * 500)),
                il50p1__c = String.valueOf(40000 + (i * 1000)),
                il50p2__c = String.valueOf(45000 + (i * 1000)),
                il50p3__c = String.valueOf(50000 + (i * 1000)),
                il80p1__c = String.valueOf(60000 + (i * 1000)),
                il80p2__c = String.valueOf(65000 + (i * 1000)),
                il80p3__c = String.valueOf(70000 + (i * 1000))
            );
            
            hudamiDataList.add(hudamiData);
        }
        
        if (executeDML && !hudamiDataList.isEmpty()) {
            insert hudamiDataList;
        }
        
        return hudamiDataList;
    }
    
    public static List<CoApplicant__c> createCoApplicants(Id intakeRequestId,Id contactId, Id clientCaseId, Integer nbOfRecords, Boolean executeDML) {
        List<CoApplicant__c> coApplicantList = new List<CoApplicant__c>();
        
        for (Integer i = 0; i < nbOfRecords; i++) {
            CoApplicant__c coApplicant = new CoApplicant__c(
                IntakeRequest__c = intakeRequestId,
                Contact__c = contactId,
                ClientCase__c = clientCaseId
            );
            coApplicantList.add(coApplicant);
        }
        
        if (executeDML && coApplicantList.size() > 0) {
            insert coApplicantList;
        }
        
        return coApplicantList;
    }
    
        /**
* @desc: Method creates Task records with predefined values.
* It provides flexibility to control the number of records created and
* whether DML operations are executed.
*/
    public static List<Task> createTasks(Integer numberOfRecords, boolean executeDML, String taskSubject, String taskStatus, String ownerId, String whatId, Integer addDays) {
        List<Task> tasks = new List<Task>();
        
        for (Integer i = 0; i < numberOfRecords; i++) {
            Task testTask2 = new Task(
            Subject = taskSubject,
            Status = taskStatus,
            ActivityDate = Date.today().addDays(addDays),
            OwnerId = ownerId,
            WhatId = whatId // Matches favourableTypes
        );
            
            tasks.add(testTask2);
        }
        
        if (executeDML) {
            insert tasks;
        }
        
        return tasks;
    }
    
    public static String getSampleXmlString() {
      return '    <?xml version="1.0" encoding="UTF-8"?><tns:SubmissionData xsi:schemaLocation="http://gov.hud.arm/form_9902_databag_6_0 form_9902_databag_6_0.xsd" xmlns:tns="http://gov.hud.arm/form_9902_databag_6_0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">    ' +
              '        <tns:Form_9902 >    ' +
              '            <tns:Report_Period_Id>5</tns:Report_Period_Id>    ' +
              '            <tns:Ethnicity_Households_Counseling_Hispanic activity_type_id="4">8</tns:Ethnicity_Households_Counseling_Hispanic>    ' +
              '            <tns:Ethnicity_Households_Counseling_Non_Hispanic activity_type_id="4">3</tns:Ethnicity_Households_Counseling_Non_Hispanic>    ' +
              '            <tns:Ethnicity_Households_Counseling_No_Response activity_type_id="4">31</tns:Ethnicity_Households_Counseling_No_Response>    ' +
              '            <tns:Section_3_Total activity_type_id="4">42</tns:Section_3_Total>    ' +
              '            <tns:Race_Households_Counseling_American_Indian activity_type_id="4">9</tns:Race_Households_Counseling_American_Indian>    ' +
              '            <tns:Race_Households_Counseling_Asian activity_type_id="4">32</tns:Race_Households_Counseling_Asian>    ' +
              '            <tns:Race_Households_Counseling_Black_African_American activity_type_id="4">0</tns:Race_Households_Counseling_Black_African_American>    ' +
              '            <tns:Race_Households_Counseling_Pacific_Islanders activity_type_id="4">1</tns:Race_Households_Counseling_Pacific_Islanders>    ' +
              '            <tns:Race_Households_Counseling_White activity_type_id="4">0</tns:Race_Households_Counseling_White>    ' +
              '            <tns:Race_Households_Counseling_More_Than_One_Race activity_type_id="4">0</tns:Race_Households_Counseling_More_Than_One_Race>    ' +
              '            <tns:Race_Households_Counseling_No_Response activity_type_id="4">0</tns:Race_Households_Counseling_No_Response>    ' +
              '            <tns:Section_4_Total activity_type_id="4">42</tns:Section_4_Total>    ' +
              '            <tns:Less30_AMI_Level activity_type_id="4">1</tns:Less30_AMI_Level>    ' +
              '            <tns:a30_49_AMI_Level activity_type_id="4">1</tns:a30_49_AMI_Level>    ' +
              '            <tns:a50_79_AMI_Level activity_type_id="4">33</tns:a50_79_AMI_Level>    ' +
              '            <tns:a80_100_AMI_Level activity_type_id="4">1</tns:a80_100_AMI_Level>    ' +
              '            <tns:Greater100_AMI_Level activity_type_id="4">2</tns:Greater100_AMI_Level>    ' +
              '            <tns:AMI_No_Response activity_type_id="4">4</tns:AMI_No_Response>    ' +
              '            <tns:Section_5_Total activity_type_id="4">42</tns:Section_5_Total>    ' +
              '            <tns:Lives_In_Rural_Area activity_type_id="4">41</tns:Lives_In_Rural_Area>    ' +
              '            <tns:Does_Not_Live_In_Rural_Area activity_type_id="4">0</tns:Does_Not_Live_In_Rural_Area>    ' +
              '            <tns:Rural_Area_No_Response activity_type_id="4">1</tns:Rural_Area_No_Response>    ' +
              '            <tns:Section_6_Total activity_type_id="4">42</tns:Section_6_Total>    ' +
              '            <tns:Limited_English_Proficient activity_type_id="4">38</tns:Limited_English_Proficient>    ' +
              '            <tns:Not_Limited_English_Proficient activity_type_id="4">4</tns:Not_Limited_English_Proficient>    ' +
              '            <tns:Limited_English_Proficient_No_Response activity_type_id="4">0</tns:Limited_English_Proficient_No_Response>    ' +
              '            <tns:Section_7_Total activity_type_id="4">42</tns:Section_7_Total>    ' +
              '            <tns:Education_Compl_Fin_Lit_Workshop activity_type_id="4">0</tns:Education_Compl_Fin_Lit_Workshop>    ' +
              '            <tns:Education_Compl_Pred_Lend_Workshop activity_type_id="4">0</tns:Education_Compl_Pred_Lend_Workshop>    ' +
              '            <tns:Education_Compl_Fair_Housing_Workshop activity_type_id="4">35</tns:Education_Compl_Fair_Housing_Workshop>    ' +
              '            <tns:Education_Compl_Homeless_Prev_Workshop activity_type_id="4">0</tns:Education_Compl_Homeless_Prev_Workshop>    ' +
              '            <tns:Education_Compl_Rental_Workshop activity_type_id="4">0</tns:Education_Compl_Rental_Workshop>    ' +
              '            <tns:Education_Compl_PrePurchase_HomeBuyer_Workshop activity_type_id="4">0</tns:Education_Compl_PrePurchase_HomeBuyer_Workshop>    ' +
              '            <tns:Education_Compl_NonDelinqency_PostPurchase_Workshop activity_type_id="4">0</tns:Education_Compl_NonDelinqency_PostPurchase_Workshop>    ' +
              '            <tns:Education_Compl_Resolv_Prevent_Mortg_Delinq_Workshop activity_type_id="4">0</tns:Education_Compl_Resolv_Prevent_Mortg_Delinq_Workshop>    ' +
              '            <tns:Education_Compl_Disaster_Prepare_Workshop activity_type_id="4">0</tns:Education_Compl_Disaster_Prepare_Workshop>    ' +
              '            <tns:Education_Compl_Disaster_Recovery_Workshop activity_type_id="4">0</tns:Education_Compl_Disaster_Recovery_Workshop>    ' +
              '            <tns:Section_8_Total activity_type_id="4">35</tns:Section_8_Total>    ' +
              '            <tns:One_Homeless_Assistance_Counseling activity_type_id="4">2</tns:One_Homeless_Assistance_Counseling>    ' +
              '            <tns:One_Rental_Topics_Counseling activity_type_id="4">1</tns:One_Rental_Topics_Counseling>    ' +
              '            <tns:One_PrePurchase_HomeBuying_Counseling activity_type_id="4">3</tns:One_PrePurchase_HomeBuying_Counseling>    ' +
              '            <tns:One_Non_Delinq_Post_Purchase_Counseling activity_type_id="4">1</tns:One_Non_Delinq_Post_Purchase_Counseling>    ' +
              '            <tns:One_Reverse_Mortgage_Counseling activity_type_id="4">0</tns:One_Reverse_Mortgage_Counseling>    ' +
              '            <tns:One_Resolv_Prevent_Fwd_Mortg_Delinq_Counseling activity_type_id="4">0</tns:One_Resolv_Prevent_Fwd_Mortg_Delinq_Counseling>    ' +
              '            <tns:One_Resolv_Prevent_Rev_Mortg_Delinq_Counseling activity_type_id="4">0</tns:One_Resolv_Prevent_Rev_Mortg_Delinq_Counseling>    ' +
              '            <tns:One_Disaster_Preparedness_Assistance_Counseling activity_type_id="4">0</tns:One_Disaster_Preparedness_Assistance_Counseling>    ' +
              '            <tns:One_Disaster_Recovery_Assistance_Counseling activity_type_id="4">0</tns:One_Disaster_Recovery_Assistance_Counseling>    ' +
              '            <tns:Section_9_Total activity_type_id="4">7</tns:Section_9_Total>    ' +
              '            <tns:Outcome_One_On_One_And_Education activity_type_id="4">2</tns:Outcome_One_On_One_And_Education>    ' +
              '            <tns:Outcome_Received_Info_Fair_Housing activity_type_id="4">3</tns:Outcome_Received_Info_Fair_Housing>    ' +
              '            <tns:Outcome_Developed_Budget activity_type_id="4">2</tns:Outcome_Developed_Budget>    ' +
              '            <tns:Outcome_Improved_Financial_Capacity activity_type_id="4">0</tns:Outcome_Improved_Financial_Capacity>    ' +
              '            <tns:Outcome_Gained_Access_Resources_Improve_Housing activity_type_id="4">1</tns:Outcome_Gained_Access_Resources_Improve_Housing>    ' +
              '            <tns:Outcome_Gained_Access_NonHousing_Resources activity_type_id="4">0</tns:Outcome_Gained_Access_NonHousing_Resources>    ' +
              '            <tns:Outcome_Homeless_Obtained_Housing activity_type_id="4">0</tns:Outcome_Homeless_Obtained_Housing>    ' +
              '            <tns:Outcome_Gained_Access_Disaster_Recovery_NonHousing_Resources activity_type_id="4">0</tns:Outcome_Gained_Access_Disaster_Recovery_NonHousing_Resources>    ' +
              '            <tns:Outcome_Obtained_Disaster_Recovery_Housing_Resources activity_type_id="4">0</tns:Outcome_Obtained_Disaster_Recovery_Housing_Resources>    ' +
              '            <tns:Outcome_Developed_Emergency_Preparedness_Plan activity_type_id="4">0</tns:Outcome_Developed_Emergency_Preparedness_Plan>    ' +
              '            <tns:Outcome_Received_Rental_Counseling_Avoided_Eviction activity_type_id="4">0</tns:Outcome_Received_Rental_Counseling_Avoided_Eviction>    ' +
              '            <tns:Outcome_Received_Rental_Counseling_Improved_Living_Conditions activity_type_id="4">0</tns:Outcome_Received_Rental_Counseling_Improved_Living_Conditions>    ' +
              '            <tns:Outcome_Received_PrePurchase_Counseling_Purchased_Housing activity_type_id="4">1</tns:Outcome_Received_PrePurchase_Counseling_Purchased_Housing>    ' +
              '            <tns:Outcome_Received_Reverse_Mortgage_Counseling_Obtained_HECM activity_type_id="4">0</tns:Outcome_Received_Reverse_Mortgage_Counseling_Obtained_HECM>    ' +
              '            <tns:Outcome_Received_NonDelinquency_PostPurchase_Counseling_Improve_Conditions_Affordability activity_type_id="4">0</tns:Outcome_Received_NonDelinquency_PostPurchase_Counseling_Improve_Conditions_Affordability>    ' +
              '            <tns:Outcome_Prevented_Resolved_Forward_Mortgage_Default activity_type_id="4">0</tns:Outcome_Prevented_Resolved_Forward_Mortgage_Default>    ' +
              '            <tns:Outcome_Prevented_Resolved_Reverse_Mortgage_Default activity_type_id="4">0</tns:Outcome_Prevented_Resolved_Reverse_Mortgage_Default>    ' +
              '            <tns:Outcome_Received_Forward_Mortgage_Modification_Remain_Current_In_Modified_Mortgage activity_type_id="4">0</tns:Outcome_Received_Forward_Mortgage_Modification_Remain_Current_In_Modified_Mortgage>    ' +
              '            <tns:Outcome_Received_Forward_Mortgage_Modification_Improved_Financial_Capacity activity_type_id="4">0</tns:Outcome_Received_Forward_Mortgage_Modification_Improved_Financial_Capacity>    ' +
              '            <tns:Section_10_Total activity_type_id="4">9</tns:Section_10_Total>    ' +
              '        </tns:Form_9902 >    ' +
              '        <tns:Group_Sessions >    ' +
              '            <tns:Group_Session >    ' +
              '                <tns:Group_Session_Id>1000000441</tns:Group_Session_Id>    ' +
              '                <tns:Group_Session_Counselor_Id>12373</tns:Group_Session_Counselor_Id>    ' +
              '                <tns:Group_Session_Counselor_HUD_Id>abhi12</tns:Group_Session_Counselor_HUD_Id>    ' +
              '                <tns:Group_Session_Title>Pre Purchase Best Practices</tns:Group_Session_Title>    ' +
              '                <tns:Group_Session_Date>04-22-2024</tns:Group_Session_Date>    ' +
              '                <tns:Group_Session_Duration>60</tns:Group_Session_Duration>    ' +
              '                <tns:Group_Session_Type>23</tns:Group_Session_Type>    ' +
              '                <tns:Group_Session_Attribute_HUD_Grant>7</tns:Group_Session_Attribute_HUD_Grant>    ' +
              '                <tns:Group_Session_Activity_Type>18</tns:Group_Session_Activity_Type>    ' +
              '                <tns:Group_Session_Attendees>    ' +
              '                    <tns:Group_Session_Attendee>    ' +
              '                        <tns:Attendee_Id>1000000001</tns:Attendee_Id>    ' +
              '                        <tns:Attendee_Fee_Amount>0</tns:Attendee_Fee_Amount>    ' +
              '                        <tns:Attendee_Referred_By>9</tns:Attendee_Referred_By>    ' +
              '                        <tns:Attendee_FirstTime_Home_Buyer>N</tns:Attendee_FirstTime_Home_Buyer>    ' +
              '                        <tns:Attendee_Income_Level>9</tns:Attendee_Income_Level>    ' +
              '                        <tns:Attendee_City>New York</tns:Attendee_City>    ' +
              '                        <tns:Attendee_State>41</tns:Attendee_State>    ' +
              '                        <tns:Attendee_Zip_Code>10005</tns:Attendee_Zip_Code>    ' +
              '                        <tns:Attendee_Rural_Area>1</tns:Attendee_Rural_Area>    ' +
              '                        <tns:Attendee_Limited_English_Proficiency>1</tns:Attendee_Limited_English_Proficiency>    ' +
              '                    </tns:Group_Session_Attendee>    ' +
              '                </tns:Group_Session_Attendees>    ' +
              '            </tns:Group_Session >    ' +
              '        </tns:Group_Sessions >    ' +
              '        <tns:Attendees>    ' +
              '            <tns:Attendee>    ' +
              '                <tns:Attendee_Id>1000000001</tns:Attendee_Id>    ' +
              '                <tns:Attendee_Income_Level>9</tns:Attendee_Income_Level>    ' +
              '                <tns:Attendee_City>New York</tns:Attendee_City>    ' +
              '                <tns:Attendee_State>41</tns:Attendee_State>    ' +
              '                <tns:Attendee_Zip_Code>10005</tns:Attendee_Zip_Code>    ' +
              '                <tns:Attendee_Rural_Area>1</tns:Attendee_Rural_Area>    ' +
              '                <tns:Attendee_Limited_English_Proficiency>1</tns:Attendee_Limited_English_Proficiency>    ' +
              '                <tns:Attendee_Race_ID>14</tns:Attendee_Race_ID>    ' +
              '                <tns:Attendee_Ethnicity_ID>4</tns:Attendee_Ethnicity_ID>    ' +
              '            </tns:Attendee>    ' +
              '        </tns:Attendees>    ' +
              '    </tns:SubmissionData>    ';
    }

    public static void createAutomationBypassCS(Boolean executeDML) {
        AutomationBypass__c bypass = new AutomationBypass__c();
        bypass.AccountAutomationBypass__c = true;
        bypass.ClientCaseAutomationBypass__c = true;
        bypass.CoApplicantAutomationBypass__c = true;
        bypass.ContactAutomationByPass__c = true;
        bypass.CourseAutomationBypass__c = true;
        bypass.CreditReportAutomationBypass__c = true;
        bypass.CreditScoreAutomationBypass__c = true;
        bypass.EventAutomationBypass__c = true;
        bypass.GoalAutomationBypass__c = true;
        bypass.IntakeAutomationBypass__c = true;
        bypass.ReferralAutomationBypass_c__c = true;
        bypass.ReferralAutomationBypass_c__c = true;
        
        if (executeDML) {
            insert bypass;
        }
    }
}