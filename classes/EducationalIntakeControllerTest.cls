@isTest
public class EducationalIntakeControllerTest {

    @testSetup static void setup() {
        List<String> values = new List<String>{'Education','Homeless Assistance','Rental Topics','Prepurchase/Homebuying','Non-delinquency Post-Purchase','Reverse Mortgage','Resolving or Preventing Forward Mortgage Delinquency or Default','Resolving or Preventing Reverse Mortgage Delinquency or Default','Disaster Preparedness Assistance','Disaster Recovery Assistance','Financial Capability','Housing Stability Capability Program'};
            List<CaseType__c> recList = new List<CaseType__c>();
        for(String elt : values) {
            CaseType__c ct = new CaseType__c();
            ct.Name=elt;
            recList.add(ct);
        }
        
        insert recList;
    }
    
    
    testMethod static void testStoreIntakeForm() {
        EducationalIntakeController.EducationalIntakeWrapper wrap = new EducationalIntakeController.EducationalIntakeWrapper();
        wrap.contact = new Contact(FirstName='Test', LastName='Test',Email='tommy@dummy.com', Phone='9898989898', MailingStreet='Test Street', MailingCity='Test City',  MailingPostalCode='777777');
        
        
        Contact coApp = new Contact();
        coApp.FirstName='Test 2';
        coApp.LastName= 'Test 2';
        coApp.Email='john@dummy.com';
        coApp.Phone='9999999999';
        coApp.RelationshipToPrimaryApplicant__c='Brother';
        coApp.Race__c='Asian';
        
        
        wrap.contacts = new List<Contact>{coApp};
        
        EducationalIntakeController.storeEducationIntake(wrap);
        
        List<Contact> contact = [Select id, FirstName, LastName from Contact where Email='tommy@dummy.com'];
        System.assert(contact.size()>0,'Contact was not created');
        
        List<Contact> coApplicants = [Select id, FirstName, LastName from Contact where Email='john@dummy.com'];
        System.assert(coApplicants.size()>0,'Co Applicant was not created');
        
        EducationalIntakeController.getIntakeDetails(contact[0].Id);
        
    }

	testMethod static void testExceptionInStoreIntake() {
        EducationalIntakeController.EducationalIntakeWrapper wrap = new EducationalIntakeController.EducationalIntakeWrapper();
        wrap.contact = new Contact(FirstName='Test', LastName='Test',Email='tommy@dummy.com', Phone='9898989898', MailingStreet='Test Street', MailingCity='Test City',  MailingPostalCode='777777',MailingAddressLine2__c='Testing');
        
        
        Contact coApp = new Contact();
        coApp.FirstName='Test 2';
        coApp.LastName= 'Test 2';
        coApp.Email='john@dummy.com';
        coApp.Phone='99999999990';
        coApp.RelationshipToPrimaryApplicant__c='Brother';
        coApp.Race__c='Asian';
        coApp.MailingAddressLine2__c='Testing Address Line';
        coApp.HouseHoldType__c='Single Adult';
        
        
        wrap.contacts = new List<Contact>{coApp};
            try{
                EducationalIntakeController.storeEducationIntake(wrap);
            }catch(Exception ex) {
                
            }
        
       
        
        
    }   
    
}