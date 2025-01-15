/**
* 
* @author       Avilash Basu
* @description A test class covering the coverage and use cases for methods in IntakeFormController
* @date     2024-01-24
* @group        Intake Form 
* 
*/
@isTest
public class IntakeFormControllerTest {
    
    @testSetup static void setup() {
        
        List<String> values = new List<String>{'Education','Homeless Assistance','Rental Topics','Prepurchase/Homebuying','Non-delinquency Post-Purchase','Reverse Mortgage','Resolving or Preventing Forward Mortgage Delinquency or Default','Resolving or Preventing Reverse Mortgage Delinquency or Default','Disaster Preparedness Assistance','Disaster Recovery Assistance','Financial Capability','Housing Stability Capability Program'};
            List<CaseType__c> recList = new List<CaseType__c>();
        for(String elt : values) {
            CaseType__c ct = new CaseType__c();
            ct.Name=elt;
            ct.IsClientLookup__c = true;
            recList.add(ct);
        }
        
        insert recList;
        
        Account acc = TestDataFactory.createAccounts(1, true)[0];
        Contact con = TestDataFactory.createContacts(acc.Id, 1, true)[0];
        
        Intake__c intake = TestDataFactory.createIntakes(con, acc.Id, 1, true)[0];
        TestDataFactory.createCaseTypes(2, true);
        List<HUDAMIData__c> hudamiDataList = TestDataFactory.createHUDAMIDataRecords(1, false);
        
        // Modify all values for each record
        hudamiDataList[0] = new HUDAMIData__c(
            CountyName__c = 'SampleCounty',
            TownName__c = 'SampleTown',
            Zipcode__c = '77777',
            StateCode__c = 'SC',
            StateName__c = 'SampleState',
            MedianFamilyIncome__c = '60000',
            il_metro_name__c = 'SampleMetro',
            Areaname__c = 'SampleArea',
            il30p1__c = '20000',
            il30p2__c = '25000',
            il30p3__c = '30000',
            il50p1__c = '40000',
            il50p2__c = '45000',
            il50p3__c = '50000',
            il80p1__c = '60000',
            il80p2__c = '65000',
            il80p3__c = '70000',
            il30p4__c = '50000',
            il50p4__c = '60000',
            il80p4__c = '70000'
        );
        insert hudamiDataList;
    }
    
    /**
* 
* @description testmethod covering coverage for method testGetPicklistValues
*/
    testMethod static void testGetPicklistValues(){
        String objectApiName='Account';
        List<String> fieldNames = new List<String>{'Industry'};
            IntakeFormController.getPicklistValues(fieldNames, objectApiName);
        
    }
    
    /**
* 
* @description testmethod covering coverage for method storeIntakeForm
*/
    testMethod static void testStoreIntakeForm() {
        Profile adminProfile = [Select id from Profile where name = 'System Administrator' limit 1];
        User adminUser = TestDataFactory.createUsers(adminProfile.Id, '', 1, true)[0];
        system.runAs(adminUser){
            IntakeFormController.IntakeSubmissionWrapper wrap = new IntakeFormController.IntakeSubmissionWrapper();
            wrap.contact = new Contact(FirstName='Test', LastName='Test',Email='tommy@dummy.com', Phone='9898989898', MailingStreet='Test Street', MailingCity='Test City', MailingState='Colorado', MailingPostalCode='777777', MailingCountry='United States');
            ClientCase__c cc = new ClientCase__C();
            cc.Race__c='Asian';
            cc.Ethnicity__c='Not Hispanic';
            cc.Gender__c='Female';
            cc.HouseholdType__c='Married without children';
            cc.Education__c='Junior College';
            cc.MaritalStatus__c='Divorced';
            cc.HouseholdSize__c=2;
            cc.X1stTimeHomeBuyer__c='Yes';
            IntakeFormController.ClientCaseWrapper caseWrap = new IntakeFormController.ClientCaseWrapper();
            //Intake__c intake = [Select Id from Intake__c limit 1];
            Intake__C intake = TestDataFactory.createIntakes(new Contact(), null, 1, false).get(0);
            //caseWrap.clientCase = cc;
            Id recordTypeId = [Select Id from CaseType__c LIMIT 1]?.Id;
            caseWrap.clientCase = intake;
            caseWrap.recordType = recordTypeId;
            wrap.clientCase = caseWrap;
            
            Contact coApp = new Contact();
            coApp.FirstName='Test 2';
            coApp.LastName= 'Test 2';
            coApp.Email='john@dummy.com';
            coApp.Phone='9999999999';
            coApp.RelationshipToPrimaryApplicant__c='Brother';
            coApp.Race__c='Asian';
            coApp.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Co-Applicant').getRecordTypeId();
            coApp.MaritalStatus__c = 'Single';
            coApp.HouseholdType__c='Single adult';
            
            wrap.contacts = new List<Contact>{coApp};
                
                IntakeFormController.storeIntakeForm(wrap);
            
            List<Contact> contact = [Select id, FirstName, LastName from Contact where Email='tommy@dummy.com'];
            System.assert(contact.size()>0,'Contact was not created');
            
            List<Contact> coApplicants = [Select id, FirstName, LastName from Contact where Email='john@dummy.com'];
            System.assert(coApplicants.size()>0,'Co Applicant was not created');
            
            List<ClientCase__c> clientCases = [Select id from ClientCase__c];
            //System.assertEquals(2,clientCases.size(),'The number of client cases created is not equal to number of record types');   
        }
    }
    
    /**
* 
* @description testmethod covering coverage for method getCaseTypes
*/
    testMethod static void testGetCaseTypes() {
        List<CaseType__c> types = IntakeFormController.getCaseTypes();
        System.assert(types.size()>0,'No case Types were fetched');
    }
    
    /**
* 
* @description testmethod covering coverage for method storeIntakeFormException
*/
    testMethod static void testStoreIntakeFormException() {
        IntakeFormController.IntakeSubmissionWrapper wrap = new IntakeFormController.IntakeSubmissionWrapper();
        IntakeFormController.ClientCaseWrapper caseWrap = new IntakeFormController.ClientCaseWrapper();
        
        wrap.clientCase = caseWrap;
        wrap.contact = new Contact(FirstName='Test', LastName='Test', MailingStreet='Test Street', MailingCity='Test City', MailingStateCode='AL', MailingPostalCode='77777', MailingCountryCode='US');
        IntakeFormController.storeIntakeForm(wrap);
        Contact con = [Select Id from Contact where FirstName='Test' LIMIT 1];
        List<HUDAMIData__c> hudamiDataList = [SELECT Id, CountyName__c, TownName__c, Zipcode__c, MedianFamilyIncome__c , il30p1__c, il30p2__c FROM HUDAMIData__c];
        IntakeFormController.getIntakeDetails(con.Id);
    }
    
    testMethod static void testGetTaskList() {
        IntakeFormController.getTaskList(null);
    }
    
    testMethod static void testGetTaskList2() {
        ClientCase__c cc = TestDataFactory.createClientCases(1,true).get(0);
        Task tsk = new Task();
        tsk.WhatId = cc.Id;
        IntakeFormController.getTaskList(null);
    }
    
    
    
    
    
    
    
    
    
    
    
    testMethod static void testCreateCoApplicants() {
		List<Contact> conList = new List<Contact>();
        for (Integer i = 1; i <= 4; i++) {
            Contact con = new Contact();
            con.FirstName = 'TestConFirstName';
            con.LastName = 'TestCOnLastName' + i;
            con.Email = 'test@test121.com' + i;
            conList.add(con);
        }
        insert conList;
        Intake__c intake = TestDataFactory.createIntakes(conList.get(0),null,1,true).get(0);
        IntakeFormController.createCoApplicants(intake, conList);
    }
    
    
    testMethod static void testCheckIfRecordTypePrimary() {
        Contact con = [Select Id from Contact LIMIT 1];
        IntakeFormController.checkIfRecordTypePrimary(con);
        
    }
    
}