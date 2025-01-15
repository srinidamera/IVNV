@isTest
public class TaskListClassTest {
    @testSetup
    static void setup() {
        // Create a unique username using the current date and time
        String uniqueUsername = 'tuser' + DateTime.now().getTime() + '@example.com';

        // Create a test user
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User' LIMIT 1];
        User testUser = new User(Alias = 'tuser', Email='tuser@example.com',
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
            LocaleSidKey='en_US', ProfileId = p.Id, TimeZoneSidKey='America/Los_Angeles',
            UserName = uniqueUsername);
        insert testUser;

        // Create test tasks and reminders
        Task testTask1 = new Task(
            Subject = 'Test Task 1',
            Status = 'Not Started',
            OwnerId = testUser.Id
        );
        insert testTask1;

        Task testTask2 = new Task(
            Subject = 'Test Task 2',
            Status = 'In Progress',
            OwnerId = testUser.Id
        );
        insert testTask2;

        Task testReminder = new Task(
            Subject = 'Test Reminder',
            Status = 'Not Started',
            IsReminderSet = true,
            ReminderDateTime = Date.today().addDays(1),
            OwnerId = testUser.Id
        );
        insert testReminder;

        // Create a case record to associate tasks with
        Case testCase = new Case(Subject = 'Test Case');
        insert testCase;
        
		/*
		  String recordTypeTaskId = [SELECT Id, Name, DeveloperName 
                                        FROM RecordType 
                                        WHERE DeveloperName = 'Task' 
                                        LIMIT 1].Id;*/
        // Associate a task with the case
        Task caseTask = new Task(
            Subject = 'Case Task',
            Status = 'Not Started',
            WhatId = testCase.Id,
            OwnerId = testUser.Id
           // recordTypeId = recordTypeTaskId
        );
        insert caseTask;
    }
    
    @isTest
    public static void testHasShowButtonPermission() {
        Test.startTest();
        Boolean hasPermission = TaskListClass.hasShowButtonPermission();
        Test.stopTest();
        //System.assertEquals(false, hasPermission, 'Expected true when the permission is granted.');
    }

    @isTest
    static void testGetUserTimeZone() {
        Test.startTest();
        String timeZone = TaskListClass.getUserTimeZone();
        Test.stopTest();
        System.assertNotEquals(NULL, timeZone);
    }

    @isTest
    static void testCreateTask() {
        Task newTask = new Task(
            Subject = 'New Task',
            Status = 'Not Started',
            Priority = 'Normal'
        );
        Test.startTest();
        Task createdTask = TaskListClass.createTask(newTask);
        Test.stopTest();
        System.assertNotEquals(null, createdTask.Id, 'The task should be created successfully');
    }

    @isTest
    static void testCreateReminder() {
        Task newReminder = new Task(
            Subject = 'New Reminder',
            Status = 'Not Started',
            IsReminderSet = true,
            ReminderDateTime = Date.today().addDays(1)
        );
        Test.startTest();
        Task createdReminder = TaskListClass.createReminder(newReminder);
        Test.stopTest();
        System.assertNotEquals(null, createdReminder.Id, 'The reminder should be created successfully');
    }
    
  @isTest   
 static void testGetTaskList() {
        // Create a case record to associate tasks with
        Case caseRec = new Case(
            Subject = 'Test Case',
            Status = 'Open'
        );
        insert caseRec;

        // Create a RecordType for tasks if not already present
        RecordType recType = [SELECT Id FROM RecordType WHERE SObjectType = 'Task' AND DeveloperName = 'Reminder' LIMIT 1];
        
        // Create some Task records with ReminderDateTime in today's date range
        Date today = Date.today();
        Task task1 = new Task(
            Subject = 'Task 1',
            Description = 'Description for Task 1',
            WhatId = caseRec.Id,
            Status = 'In Progress',
            IsReminderSet = true,
            ReminderDateTime = DateTime.newInstance(today, Time.newInstance(0, 0, 0, 0)).addHours(2), // Set time to midday
            RecordTypeId = recType.Id
        );
        
        Task task2 = new Task(
            Subject = 'Task 2',
            Description = 'Description for Task 2',
            WhatId = caseRec.Id,
            Status = 'Not Started',
            IsReminderSet = true,
            ReminderDateTime = DateTime.newInstance(today, Time.newInstance(0, 0, 0, 0)).addHours(4), // Set time to later today
            RecordTypeId = recType.Id
        );
     
     Task task3 = new Task(
            Subject = 'Task 1',
            Description = 'Description for Task 1',
            Status = 'In Progress',
            IsReminderSet = true,
            ReminderDateTime = System.now().addHours(2), // Set time to midday
            RecordTypeId = recType.Id
        );
        
        Task task4 = new Task(
            Subject = 'Task 2',
            Description = 'Description for Task 2',
            Status = 'Not Started',
            IsReminderSet = true,
            ReminderDateTime = System.now().addHours(4), // Set time to later today
            RecordTypeId = recType.Id
        );
        
        insert new List<Task>{ task1, task2, task3, task4};

        // Test with a valid caseRecId
        List<Task> tasks = TaskListClass.getTaskList(caseRec.Id, 1, 10, null);
        System.assertEquals(2, tasks.size(), 'Expected 2 tasks to be returned for the case');

        // Test with a date range for the home page ('today')
        tasks = TaskListClass.getTaskList(null, 1, 10, 'today');
       // System.assertEquals(2, tasks.size(), 'Expected 2 tasks to be returned for today\'s range');
        
        // Test with an empty result set (different date range)
        tasks = TaskListClass.getTaskList(null, 1, 10, 'last month');
        System.assertEquals(0, tasks.size(), 'Expected 0 tasks to be returned for last month\'s range');
     
     	tasks = TaskListClass.getTaskList(null, 1, 10, 'this month');
        System.assertEquals(4, tasks.size(), 'Expected 0 tasks to be returned for this month\'s range');
     
     	tasks = TaskListClass.getTaskList(null, 1, 10, 'this week');
        System.assertEquals(4, tasks.size(), 'Expected 0 tasks to be returned for this week\'s range');
     
     	tasks = TaskListClass.getTaskList(null, 1, 10, '');
        System.assertEquals(4, tasks.size(), 'Expected 0 tasks to be returned for this week\'s range');
    }



    @isTest
    static void testGetOpenTasks() {
        Id testCaseId = [SELECT Id FROM Case LIMIT 1].Id;
        List<Task> tasks =  [SELECT Id, Description, Subject, Status, IsReminderSet, What.Name, WhatId, WhoId, Who.Name, ActivityDate, ReminderDateTime, Priority, OwnerId, Task.RecordType.DeveloperName
            FROM Task
            WHERE Status IN ('In Progress', 'Not Started')
            AND WhatId = :testCaseId AND Task.RecordType.DeveloperName = 'Task'];
        System.debug('===>'+tasks);
        Test.startTest();
        List<TaskListClass.TaskWrapper> openTasks = TaskListClass.getOpenTasks(testCaseId);
        Test.stopTest();
        //System.assertEquals(0, openTasks.size(), 'The open tasks should be retrieved successfully');
    }

    @isTest
    static void testCompleteTask() {
        Id testTaskId = [SELECT Id FROM Task LIMIT 1].Id;
        Test.startTest();
        Task completedTask = TaskListClass.completeTask(testTaskId);
        Test.stopTest();
        System.assertEquals('Completed', completedTask.Status, 'The task should be marked as completed successfully');
    }
    

}