public without sharing class TaskListClass {
    
    @AuraEnabled(cacheable=true)
    public static Boolean hasShowButtonPermission() {
        return FeatureManagement.checkPermission('IntakeStaff');
    }

    @AuraEnabled(cacheable=true)
    public static String getUserTimeZone() {
        // Fetch the current user's time zone
        User currentUser = [SELECT TimeZoneSidKey FROM User WHERE Id = :UserInfo.getUserId()];
        return currentUser.TimeZoneSidKey;
    }

    @AuraEnabled
    public static task createTask(Task task) {
            task.RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('Task').getRecordTypeId();
            upsert task;
            return [Select id, Subject, Status, IsReminderSet, What.Name, WhatId, WhoId, ReminderDateTime from task where id = :task.Id];

    }
     @AuraEnabled
    public static task createReminder(Task task) {
            task.RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('Reminder').getRecordTypeId();
            upsert task;
            return [Select id, Subject, Status, IsReminderSet, What.Name, WhatId, WhoId, ReminderDateTime from task where id = :task.Id];

    }

    @AuraEnabled
    public static List<Task> getTaskList(Id caseRecId, Integer page, Integer pageSize, String dateRange) {
        List<Task> tasks = new List<Task>();
        Integer offset = (page - 1) * pageSize;

        if (caseRecId != null) {
            // Query for RecordPage
            tasks = [
                SELECT Id, Subject, Description, IsReminderSet, ReminderDateTime, Task.Owner.Name 
                FROM Task
                WHERE WhatId = :caseRecId
                AND Task.RecordType.DeveloperName IN ('Reminder')
                AND Status IN ('In Progress', 'Not Started')
                ORDER BY ReminderDateTime ASC
                LIMIT :pageSize
                OFFSET :offset
            ];
        } else {
            // Query for HomePage
            Date startDate;
            Date endDate = Date.today().addDays(1); // Default end date to tomorrow

            // Determine the date range based on user input
            if (dateRange == 'this week') {
                startDate = Date.today().toStartOfWeek();
                endDate = startDate.addDays(7);
            } else if (dateRange == 'this month') {
                startDate = Date.today().toStartOfMonth();
                endDate = startDate.addMonths(1);
            } else if (dateRange == 'last month') {
                startDate = Date.today().addMonths(-1).toStartOfMonth();
                endDate = Date.today().toStartOfMonth();
            } else if (dateRange == 'today') {
                startDate = Date.today();
                endDate = startDate.addDays(1);
            } else {
                // Default date range
                startDate = Date.newInstance(2000, 1, 1);
                endDate = Date.newInstance(4000, 12, 31);
            }

            tasks = [
                SELECT Id, Subject, Description, IsReminderSet, ReminderDateTime , Task.Owner.Name
                FROM Task
                WHERE Status IN ('In Progress', 'Not Started')
                AND ReminderDateTime >= :startDate
                AND ReminderDateTime < :endDate
                AND Task.RecordType.DeveloperName IN ('Reminder')
                ORDER BY ReminderDateTime ASC
                LIMIT :pageSize
                OFFSET :offset
            ];
        }

        System.debug('### Tasks : ' + tasks.size());
        return tasks;
    }


    public class TaskWrapper {
        @AuraEnabled
        public Task task { get; set; }
        @AuraEnabled
        public String ownerName { get; set; }
    }

    @AuraEnabled
    public static List<TaskWrapper> getOpenTasks(Id recId) {
        List<Task> tasks = [
            SELECT Id, Description, Subject, Status, IsReminderSet, What.Name, WhatId, WhoId, Who.Name, ActivityDate, ReminderDateTime, Priority, OwnerId, Task.RecordType.DeveloperName
            FROM Task
            WHERE Status IN ('In Progress', 'Not Started')
            AND WhatId = :recId AND Task.RecordType.DeveloperName = 'Task' AND ActionType__c = null
            ORDER BY ActivityDate ASC
        ];

        Set<Id> ownerIds = new Set<Id>();
        for (Task task : tasks) {
            ownerIds.add(task.OwnerId);
        }

        Map<Id, String> ownerNames = new Map<Id, String>();

        // Fetching User Names
        for (User user : [SELECT Id, Name FROM User WHERE Id IN :ownerIds]) {
            ownerNames.put(user.Id, user.Name);
        }

        // Constructing result list
        List<TaskWrapper> result = new List<TaskWrapper>();
        for (Task task : tasks) {
            TaskWrapper wrapper = new TaskWrapper();
            wrapper.task = task;
            wrapper.ownerName = ownerNames.get(task.OwnerId);
            result.add(wrapper);
        }

        return result;
    }

    @AuraEnabled
    public static Task completeTask(Id recId) 
    {
        Task rec = new Task(Id = recId);
        rec.Status = 'Completed';
        update rec;
        return rec;
    }
}