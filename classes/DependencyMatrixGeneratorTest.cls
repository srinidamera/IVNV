@isTest
public class DependencyMatrixGeneratorTest {

    testmethod static void testMatrixGenerator() {
        string NWC2NameSpace = Utility.getNwc2NameSpace();
		DependencyMatrixGenerator.getDependencyMatrix(NWC2NameSpace+'Contact', NWC2NameSpace+'MaritalStatus__c' ,NWC2NameSpace+'HouseholdType__c');
    }
    
    testMethod static void testWrapper() {
        DependencyMatrixGenerator.PickListInfo wrapper = new DependencyMatrixGenerator.PickListInfo();
        wrapper.label='Test';
        wrapper.validFor='Test';
        wrapper.value='Test';
    }
}