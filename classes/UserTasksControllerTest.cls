@isTest
private class UserTasksControllerTest {
    
   @testSetup static void setup() {
    // Create and insert user inside System.runAs to avoid Mixed DML
    Profile adminProfile = [SELECT Id FROM Profile WHERE Name='System Administrator'];
    User testUser;
    
    System.runAs(new User(Id=UserInfo.getUserId())) {
        String uniqueUsername = 'testuser_' + DateTime.now().getTime() + '@example.com';
        testUser = new User(
            ProfileId = adminProfile.Id,
            UserName = uniqueUsername,
            LastName = 'Default Last Name',
            Email = uniqueUsername,
            Alias = 'testuser',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            isActive = true
        );
        insert testUser;
    }

    // Create and insert non-setup objects (Account, Contact, etc.) outside of System.runAs
    Account acc = TestDataFactory.createAccounts(1, true)[0];
    Contact testContact = TestDataFactory.createContacts(acc.Id, 1, true)[0];
    ClientCase__c testClientCase = TestDataFactory.createClientCases(1, true)[0];
    Intake__c testIntake = TestDataFactory.createIntakes(testContact, acc.Id, 1, true)[0];
}
    
    @isTest
    static void testGetUserTasks() {
        User testUser = [SELECT Id FROM User WHERE LastName = 'Default Last Name'];
        
        Contact testContact = [SELECT Id FROM Contact LIMIT 1];
        
        ClientCase__c testClientCase = [SELECT Id FROM ClientCase__c LIMIT 1];
        
        Intake__c testIntake = [SELECT Id FROM Intake__c LIMIT 1];
        
        Task testTask2 = TestDataFactory.createTasks(1, true, 'Task for Client Case', 'In Progress', testUser.Id, testClientCase.Id, 2)[0];
        Task testTask3 = TestDataFactory.createTasks(1, true, 'Task for Intake', 'Not Started', testUser.Id, testIntake.Id, 3)[0];
        Task testTask4 = TestDataFactory.createTasks(1, true, 'Task without WhatId', 'Not Started', testUser.Id, null, 1)[0];
        
        // Set the current user context to the test user
        Test.startTest();
        System.runAs(testUser) {
            List<Task> userTasks = UserTasksController.getUserTasks('Profile');
            System.assertEquals(2, userTasks.size(), 'Expected 3 tasks to be returned');

            // Check that only the favourable tasks are returned
            Set<Id> expectedTaskIds = new Set<Id> { testTask2.Id, testTask3.Id};
            for (Task t : userTasks) {
                System.assert(expectedTaskIds.contains(t.Id), 'Returned task should be in the expected task list');
            }
        }
        Test.stopTest();
    }
	
    @isTest
    static void testGetTasksMetrics() {
        User testUser = [SELECT Id FROM User WHERE LastName = 'Default Last Name'];
        
        Task testTask2 = TestDataFactory.createTasks(1, true, 'Task Not Started', 'Not Started', testUser.Id, null, 1)[0];
        Task testTask3 = TestDataFactory.createTasks(1, true, 'Task In Progress', 'In Progress', testUser.Id, null, 2)[0];
        Task testTask4 = TestDataFactory.createTasks(1, true, 'Task Completed', 'Completed', testUser.Id, null, 3)[0];

        // Set the current user context to the test user
        Test.startTest();
        System.runAs(testUser) {
            Map<String, Integer> taskMetrics = UserTasksController.getTasksMetrics();
            System.assertEquals(1, taskMetrics.get('Not Started'), 'Expected 1 Not Started task');
            System.assertEquals(1, taskMetrics.get('In Progress'), 'Expected 1 In Progress task');
            System.assertEquals(1, taskMetrics.get('Completed'), 'Expected 1 Completed task');
        }
        Test.stopTest();
    }

    @isTest
    static void testGetTasksMetrics_ExceptionHandling() {
        User testUser = [SELECT Id FROM User WHERE LastName = 'Default Last Name'];

        // Set the current user context to the test user
        Test.startTest();
        System.runAs(testUser) {
            // This simulates an error by using an invalid query structure
            try {
                // Attempt to fetch tasks for a user with no tasks, this should not raise an exception
                Map<String, Integer> taskMetrics = UserTasksController.getTasksMetrics();
                System.assertNotEquals(null, taskMetrics, 'Task metrics should not be null');
            } catch (Exception e) {
                System.assert(false, 'Exception should not be thrown in this context');
            }
        }
        Test.stopTest();
    }

    @isTest
    static void testGetUserTasks_NoTasks() {
        User testUser = [SELECT Id FROM User WHERE LastName = 'Default Last Name'];

        // Set the current user context to the test user
        Test.startTest();
        System.runAs(testUser) {
            List<Task> userTasks = UserTasksController.getUserTasks('Profile');
            System.assertEquals(0, userTasks.size(), 'Expected 0 tasks to be returned');
        }
        Test.stopTest();
    }

    @isTest
    static void testGetUserTasks_ExceptionHandling() {
        User testUser = [SELECT Id FROM User WHERE LastName = 'Default Last Name'];

        // Set the current user context to the test user
        Test.startTest();
        System.runAs(testUser) {
            // Simulate exception handling in getUserTasks
            try {
                // This will not throw an exception as there are no tasks
                List<Task> userTasks = UserTasksController.getUserTasks('Home');
                System.assertEquals(0, userTasks.size(), 'Expected 0 tasks to be returned');
            } catch (AuraHandledException e) {
                System.assert(false, 'Exception should not be thrown in this context');
            }
        }
        Test.stopTest();
    }
}