@istest
private class courseProgressBarControllerTest {

    @istest
    static void getParentAndChildRecordsTest() {

        sumoapp__AdditionalInfo__c parent = new sumoapp__AdditionalInfo__c(sumoapp__StartDatetime__c=datetime.now());
        insert parent;
        sumoapp__AdditionalInfo__c child = new sumoapp__AdditionalInfo__c(sumoapp__Parent__c = parent.Id, sumoapp__StartDatetime__c=datetime.now());
        insert child;
        Test.startTest();
        List<courseProgressBarController.courseWrapper> course =  courseProgressBarController.getParentAndChildRecords(child.Id);
        
    }
}