/**
* @description    : Test Class for ClientActionPlansController
**/
@IsTest
public class ClientActionPlansControllerTest {
    
    /*
@description    Test method for getGoalsForClientCase
*/
    @testSetup
    private static void testGetGoalsForClientCase1(){
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
        TestDataFactory.createFinancialSnapshots(clCase.Id , 3, true);
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
        
        ClientActionPlansController.ClientActionPlanWrapper result = ClientActionPlansController.getGoalsForClientCase(clCase.Id);
        
        System.assertNotEquals(null, result);
        System.assertNotEquals(null, result.actionPlans);
        System.assertEquals(1, result.actionPlans.size());
        System.assertEquals(2, result.actionPlans[0].obstacleList.size());
    }
    
    /*
@description    Test method for getGoalsForClientCase
*/
    @IsTest
    private static void testGetGoalsForClientCase2(){
        ClientCase__c clCase = TestDataFactory.createClientCases(1, true)[0];
        
        ClientActionPlan__c  cap = new ClientActionPlan__c ();
        cap.ClientCase__c = clCase.Id;
        insert cap;
        
        Goal__c goal = new Goal__c();
        goal.ClientCase__c = clCase.Id;
        goal.ClientActionPlan__c = cap.Id;
        goal.GoalSubject__c = 'test subject';
        goal.GoalDetails__c = 'test details';
        goal.GoalType__c = 'Short Term';
        goal.Status__c = 'In Progress';
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
        sol.SolutionSubject__c = 'other';
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
        
        ClientActionPlansController.ClientActionPlanWrapper result = ClientActionPlansController.getGoalsForClientCase(clCase.Id);
        
        System.assertNotEquals(null, result);
        System.assertNotEquals(null, result.actionPlans);
        System.assertEquals(1, result.actionPlans.size());
        System.assertEquals(2, result.actionPlans[0].obstacleList.size());
    }
    
    /*
@description    Test method for getGoalsForClientCase
*/
    @IsTest
    private static void testGetGoalsForClientCase3(){
        ClientCase__c clCase = TestDataFactory.createClientCases(1, true)[0];
        
        ClientActionPlan__c  cap = new ClientActionPlan__c ();
        cap.ClientCase__c = clCase.Id;
        insert cap;
        
        Goal__c goal = new Goal__c();
        goal.ClientCase__c = clCase.Id;
        goal.ClientActionPlan__c = cap.Id;
        goal.GoalSubject__c = 'test subject';
        goal.GoalDetails__c = 'test details';
        goal.GoalType__c = 'Short Term';
        goal.Status__c = 'Completed';
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
        sol.SolutionSubject__c = 'other';
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
        clientTask.Solution__c = sol.Id;
        taskList.add(clientTask);
        
        Task counselorTask = new Task();
        counselorTask.ActionType__c = 'Counselor Action';
        counselorTask.Subject = 'test sub';
        counselorTask.Description = 'test sub';
        counselorTask.Status = 'Completed';
        counselorTask.ActivityDate = System.today();
        counselorTask.WhatId = sol.Id;
        counselorTask.Solution__c = sol.Id;
        taskList.add(counselorTask);
        
        insert taskList;
        Test.startTest();
        ClientActionPlansController.ClientActionPlanWrapper result = ClientActionPlansController.getGoalsForClientCase(clCase.Id);
        Test.stopTest();
        
        
        System.assertNotEquals(null, result);
        System.assertNotEquals(null, result.actionPlans);
        System.assertEquals(1, result.actionPlans.size());
        System.assertEquals(2, result.actionPlans[0].obstacleList.size());
    }
    
    /*
@description    Test method for saveGoalsForClientCase
*/
    @IsTest
    private static void testSaveGoalsForClientCase_Update(){
        ClientCase__c clCase = TestDataFactory.createClientCases(1, true)[0];
        
        ClientActionPlan__c  cap = new ClientActionPlan__c ();
        cap.ClientCase__c = clCase.Id;
        insert cap;
        
        Goal__c goal = new Goal__c();
        goal.ClientCase__c = clCase.Id;
        goal.ClientActionPlan__c = cap.Id;
        goal.GoalSubject__c = 'test subject';
        goal.GoalDetails__c = 'test details';
        goal.GoalType__c = 'Short Term';
        goal.Status__c = 'In Progress';
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
        obs2.ObstacleSubject__c = 'Lack of required skills';
        obs2.ObstacleDetails__c = 'test details';
        obs2.DueDate__c = System.today();
        obsList.add(obs2);
        
        insert obsList;
        
        Solution__c sol = new Solution__c();
        sol.Obstacle__c = obs1.Id;
        sol.SolutionSubject__c = 'Reduce debt';
        sol.SolutionDetails__c = 'test details';
        sol.Status__c = 'Not Started';
        
        insert sol;
        
        String jsonString = '{"clientCaseId":"'+ clCase.Id +'","actionPlanId":"'+ cap.Id +'","goalDetail":"goal details","goalId":"'+ goal.Id +'","goalName":"Buy a Car","goalOtherName":"","goalStatus":"Completed","goalType":"Short Term",'+
            '"obstacleList":[{"obsExternalId":"572577","obstacleDetail":"obstacledetail 1","obstacleDueDate":"2024-05-04","obstacleId":"'+ obs1.Id +'","obstacleName":"Lack of opportunity","obstacleOtherName":"",'+
            '"showAddSolutionAction":true,"showObstacleOtherName":false,"solutionList":[{"clientAction":"sdfsd","clientActionDetail":"2342qwfefas","clientActionDueDate":"2024-05-28","clientActionId":"",'+
            '"clientActionStatus":"Completed","counselorAction":"sdfsdf","counselorActionDetail":"asdfasdf","counselorActionDueDate":"2024-06-04","counselorActionId":"","counselorActionStatus":"Completed",'+
            '"showSolutionOtherName":false,"solExternalId":"745113","solutionDetail":"sol details 1","solutionId":"'+ sol.Id +'","solutionName":"Increase income","solutionOtherName":"","viewModeCollapsed":false}],'+
            '"viewModeCollapsed":false},{"obsExternalId":"330117","obstacleDetail":"sdasdfasdf","obstacleDueDate":"2024-05-21",'+
            '"obstacleId":"'+ obs2.Id +'","obstacleName":"Other","obstacleOtherName":"asdfasdfvaxc","showAddSolutionAction":true,"showObstacleOtherName":true,"solutionList":[],"viewModeCollapsed":false}],'+
            '"progressBarAltText":"Progress: 100.0%","progressBarText":"6/6 Action Items Completed","progressBarWidthClass":"slds-progress-bar__value slds-progress-bar__value_success","progressBarWidthStyle":"width:100.0%;",'+
            '"showGoalOtherName":false,"statusClass":"slds-badge slds-theme_success","viewModeCollapsed":true}';
        
        
        
        ClientActionPlansController.GoalWrapper inputWrapper = (ClientActionPlansController.GoalWrapper)JSON.deserialize(jsonString, ClientActionPlansController.GoalWrapper.class);
        
        ClientActionPlansController.saveGoalsForClientCase(inputWrapper);
        
        List<Goal__c> goalList = [Select Id, Name, GoalSubject__c from Goal__c where Id =:goal.Id WITH SECURITY_ENFORCED ];
        
        List<Obstacle__c> obstacleList = [Select Id, Name, ObstacleSubject__c from Obstacle__c 
                                          where Id =:obs1.Id WITH SECURITY_ENFORCED];
        
        List<Solution__c> solutionList = [Select Id, Name, SolutionSubject__c,
                                          (Select Id, Status, Subject, ActionType__c, Description, ActivityDate from Activities__r)
                                          from Solution__c where Id =:sol.Id WITH SECURITY_ENFORCED];
        
        
        System.assertNotEquals(null, goalList);
        System.assertEquals('Buy a Car', goalList[0].GoalSubject__c);
        System.assertNotEquals(null, obstacleList);
        System.assertEquals('Lack of opportunity', obstacleList[0].ObstacleSubject__c);
        System.assertNotEquals(null, solutionList);
        System.assertEquals('Increase income', solutionList[0].SolutionSubject__c);
        System.assertEquals(2, solutionList[0].Activities__r.size());
    }
    
    @isTest
    public static void testFinancialSnapshotWrapper() {
        FinancialSnapshot__c snapshot = [SELECT CreditScore__c, CoAppCreditScore__c, Savings__c, CurrentMonthlyDebtObligation__c,
                                         GrossMonthlyIncome__c, HousingExpense__c, TotalDebt__c, 
                                         TotalAssets__c FROM FinancialSnapshot__c LIMIT 1];
        
        ClientActionPlansController.FinancialSnapshotWrapper wrapper = new ClientActionPlansController.FinancialSnapshotWrapper(snapshot);
        
        // Assert to verify the values are correctly assigned
    /*    System.assertEquals(String.valueOf(snapshot.CreditScore__c), wrapper.creditScore);
        System.assertEquals('N/A', wrapper.coAppCreditScore); // Adjust if snapshot.CurrentMonthlyDebtObligation__c is null
        System.assertEquals(String.valueOf(snapshot.Savings__c), wrapper.savings);
        System.assertEquals(String.valueOf(snapshot.GrossMonthlyIncome__c), wrapper.grossMonthlyIncome);
        System.assertEquals(String.valueOf(snapshot.HousingExpense__c), wrapper.housingExpense);
        System.assertEquals(String.valueOf(snapshot.TotalDebt__c), wrapper.totalDebt);
        System.assertEquals(String.valueOf(snapshot.TotalAssets__c), wrapper.totalAssets);
        System.assertEquals('', wrapper.conditionOfProperty); // As this field is hardcoded to an empty string*/
    }
    
    @isTest
    public static void TestFunctions() {
        Goal__c goal = [Select Id from Goal__c limit 1];
        Solution__c sol =  [Select Id from Solution__c limit 1];
        Test.startTest();
        ClientActionPlansController.hasRemoveObstaclePermission();
        ClientActionPlansController.deleteObstaclesAndSolutionsForGoal(goal.id);
        ClientActionPlansController.deleteSolution(sol.Id);
        Test.stopTest();
    }
    
    @isTest
    public static void TestgetClientCase() {
        ClientCase__c goal = [Select Id from ClientCase__c limit 1];
        Test.startTest();
        ClientActionPlansController.getClientCase(goal.id);
        Test.stopTest();
    }
   
    @IsTest
    static void verifyIsIntakeStaffUser() {
        Test.startTest();
        Boolean isIntakeStaffUser = ClientActionPlansController.isIntakeStaffUser();
        Test.stopTest();
    }
    
    
}