@IsTest
public class PrintActionPlanVfControllerTest {
	@testSetup 
    static void testSetup() {
        ClientCase__c clCase = TestDataFactory.createClientCases(1, true)[0];
        
        ClientActionPlan__c  cap = new ClientActionPlan__c ();
        cap.ClientCase__c = clCase.Id;
        insert cap;
        
        Goal__c goal = new Goal__c();
        goal.ClientCase__c = clCase.Id;
        goal.ClientActionPlan__c = cap.Id;
        goal.GoalSubject__c = 'Buy a house';
        goal.GoalDetails__c = 'test details';
        goal.GoalType__c = 'Short Term';
        goal.Status__c = 'Not Started';
        goal.DueDate__c = System.today();
        
        insert goal;
        
        List<Obstacle__c> obsList = new List<Obstacle__c>();
        
        Obstacle__c obs1 = new Obstacle__c();
        obs1.Goal__c = goal.Id;
        obs1.ObstacleSubject__c = 'Buy a house';
        obs1.ObstacleDetails__c = 'test details';
        obs1.DueDate__c = System.today();
        obsList.add(obs1);
        
        Obstacle__c obs2 = new Obstacle__c();
        obs2.Goal__c = goal.Id;
        obs2.ObstacleSubject__c = 'Lack of opportunity';
        obs2.ObstacleDetails__c = 'test details';
        obs2.DueDate__c = System.today();
        obsList.add(obs2);
        
        insert obsList;
        
        Solution__c sol = new Solution__c();
        sol.Obstacle__c = obs1.Id;
        sol.SolutionSubject__c = 'Increase income';
        sol.SolutionDetails__c = 'test details';
        sol.Status__c = 'Not Started';
        
        insert sol;
        
        List<Task> taskList = new List<Task>();
        
        Task clientTask = new Task();
        clientTask.ActionType__c = 'Client Action';
        clientTask.Subject = 'test sub';
        clientTask.Description = 'test sub';
        clientTask.Status = 'Not Started';
        clientTask.ActivityDate = System.today();
        clientTask.WhatId = sol.Id;
        taskList.add(clientTask);
        
        Task counselorTask = new Task();
        counselorTask.ActionType__c = 'Counselor Action';
        counselorTask.Subject = 'test sub';
        counselorTask.Description = 'test sub';
        counselorTask.Status = 'Completed';
        counselorTask.ActivityDate = System.today();
        counselorTask.WhatId = sol.Id;
        taskList.add(counselorTask);
        
        insert taskList;
        
        TestDataFactory.createFinancialSnapshots(clCase.Id , 3, true);
	}
    
    @isTest
    static void getPrintActionPlanVf() {
        ClientCase__c cc = [Select Id from ClientCase__c limit 1];
        
        Test.startTest();
            PageReference pageRef = Page.printActionPlanVf;
            Test.setCurrentPage(pageRef);
            pageRef.getParameters().put('Id', cc.Id);
            PrintActionPlanVfController objCtrl = new PrintActionPlanVfController();
        	System.assertNotEquals(NULL, objCtrl.clientCaseName);
        	System.assertNotEquals(NULL, objCtrl.wrapList);
        	System.assertNotEquals(NULL, objCtrl.wrapList[0].actionPlans);
        	System.assertEquals(1, objCtrl.wrapList[0].actionPlans.size());
        	System.assertNotEquals(NULL, objCtrl.wrapList[0].actionPlans[0].obstacleList);
        	System.assertEquals(2, objCtrl.wrapList[0].actionPlans[0].obstacleList.size());
        Test.stopTest();
    }

}