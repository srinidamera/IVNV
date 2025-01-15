public without sharing class UserTasksController {
    @AuraEnabled(cacheable=true)
    public static List<Task> getUserTasks(String pageType) {
        String NWC2NameSpace = Utility.getNwc2NameSpace();
        System.debug('pageType ==>'+pageType);
        List<Task> tasks = new List<Task>();
        List<Task> filteredTasks = new List<Task>();
        Set<String> favourableTypes = new Set<String> { 'Contact', NWC2NameSpace+'ClientCase__c', NWC2NameSpace+'Intake__c' };
        String userId = UserInfo.getUserId();
        String query = 'SELECT Id, Subject, LastModifiedDate, Status, Description, ActivityDate, WhatId ' +
                    'FROM Task WHERE OwnerId =:userId';
        // Add filters based on pageType
        if (pageType == 'Home') {
            query += ' AND Status != \'Completed\' AND ActivityDate > TODAY';
        }

        try {
            tasks = Database.query(query); // Execute the dynamic SOQL query
            String objectType;
            for (Task tsk : tasks) {
                objectType = tsk.WhatId != null ? String.valueOf(tsk.WhatId.getSObjectType()) : null;
                if (objectType != null && favourableTypes.contains(objectType)) {
                    filteredTasks.add(tsk);
                }
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }

        return filteredTasks;
    }

    @AuraEnabled(cacheable=true)
    public static Map<String, Integer> getTasksMetrics(){
        Map<String, Integer> taskMetrics = new Map<String, Integer> {'Not Started' => 0, 'In progress' => 0, 'Completed' => 0};
        try {
            List<User> users = [SELECT Id, ContactId FROM User WHERE Id = :UserInfo.getUserId() ];
            if (users.isEmpty()) return taskMetrics;
            List<AggregateResult> groupedTasks = [ SELECT
                                                   COUNT(Id) TaskCount,
                                                   Status
                                                   FROM Task
                                                   WHERE Status != 'Open'
                                                   AND
                                                   OwnerId = :UserInfo.getUserId()
                                                //    WhoId = :users[0].ContactId
                                                   Group By Status
                                                ];
            for(AggregateResult agRes: groupedTasks) {
                taskMetrics.put(String.valueOf(agRes.get('Status')), Integer.valueOf(agRes.get('TaskCount')));
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return taskMetrics;
    }

    /******* Wrappers *******/
    public virtual class TasksWrapper {
        @AuraEnabled
        public String id;

        @AuraEnabled
        public String name;

        @AuraEnabled
        public String lastUpdated;

        @AuraEnabled
        public String shortDescription;

        @AuraEnabled
        public String status;

        @AuraEnabled
        public List<KeyValPairs> keyValPairs;
    }

    public class KeyValPairs {
        @AuraEnabled
        public String key;

        @AuraEnabled
        public String value;
    }
}