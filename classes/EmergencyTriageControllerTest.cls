@isTest
public class EmergencyTriageControllerTest {

    @testSetup static void setup() {
        TestDataFactory.createCaseTypes(3, true);
    }
    
    testMethod static void testGetCaseTypes() {
        EmergencyTriageController.getCaseTypes();
    }
    
    testMethod static void testStoreLeadIntake() {
        EmergencyTriageController.IntakeWrapper wrapper = new EmergencyTriageController.IntakeWrapper();
        Contact primaryContact = TestDataFactory.createContacts(null, 1, false).get(0);
        
        
        wrapper.contact =primaryContact;
       	wrapper.intakeCaseType = [Select Name from CaseType__c LIMIT 1]?.Name;
        
        EmergencyTriageController.storeLeadIntake(wrapper);
        
        
    }
    
    testMethod static void testStoreLeadIntakeException() {
        EmergencyTriageController.IntakeWrapper wrapper = new EmergencyTriageController.IntakeWrapper();
        Contact primaryContact = TestDataFactory.createContacts(null, 1, false).get(0);
        
		primaryContact.HouseholdType__c='Single';        
        wrapper.contact =primaryContact;
        
       	wrapper.intakeCaseType = [Select Name from CaseType__c LIMIT 1]?.Name;
        try{
        	EmergencyTriageController.storeLeadIntake(wrapper);    
        }catch(Exception ex) {
            
        }
        
        
        
    }
    
    testMethod static void testGetIntakeDetails() {
        Contact primaryContact = TestDataFactory.createContacts(null, 1, true).get(0);
        TestDataFactory.createIntakes(primaryContact, null, 2, true);
        EmergencyTriageController.getIntakeDetails(primaryContact.Id);
    }
}