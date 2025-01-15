public without sharing class UserClassesController {
    
    /*
     * @desc: Method for home page classes tiles
     */ 
    @AuraEnabled(cacheable=true)
    public static List<sumoapp__Attendee__c> getUserClasses() {
        List<sumoapp__Attendee__c> classes = new List<sumoapp__Attendee__c>();
        try {
            List<User> users = [SELECT Id, ContactId FROM User WHERE Id = :UserInfo.getUserId()];
            if (users.isEmpty() || users[0].ContactId == null) return classes;
            classes = [ SELECT Id,
                        sumoapp__SumoEvent__r.Id,
                        sumoapp__SumoEvent__r.sumoapp__EventName__c,
                        sumoapp__SumoEvent__r.sumoapp__StartDatetime__c,
                        sumoapp__Status__c
                        FROM sumoapp__Attendee__c
                        WHERE sumoapp__ContactRelation__c = :users[0].ContactId 
                       	AND sumoapp__SumoEvent__r.sumoapp__EndDatetime__c > Today
                        AND sumoapp__SumoEvent__r.Public__c  = TRUE
                      ];
            return classes;
            // // For Testing
            // return [ SELECT Id, 
            //                    sumoapp__SumoEvent__r.sumoapp__EventName__c,
            //                    sumoapp__SumoEvent__r.sumoapp__StartDatetime__c,
            //                    sumoapp__Status__c
            //                    FROM sumoapp__Attendee__c LIMIT 8
            //                ];
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}