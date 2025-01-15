/**
* @desc: Handles trigger logic and data processing for sumoapp__AdditionalInfo__c object.
*/
public with sharing class CourseTriggerHandler {
    
    public static List<sumoapp__AdditionalInfo__c> populateUniqueClientId(List<sumoapp__AdditionalInfo__c> ccList){
        Set<String> uniqueValuesSet = new Set<String>();
        String uniqueId;
        Boolean isUnique = false;
        while(!isUnique){
            while(uniqueValuesSet.size() < ccList.size()){
                uniqueValuesSet.add(Utility.getNewUniqueId());
            }
            List<sumoapp__AdditionalInfo__c> ccListDump = checkDuplicacy(uniqueValuesSet);
            if(ccListDump.size() > 0){
                uniqueValuesSet = new Set<String>();
            } else {
                isUnique = true;
            }
        }
        Integer index = 0;
        List<String> uniqueValuesList = new List<String>(uniqueValuesSet);
        for(sumoapp__AdditionalInfo__c cc : ccList){
            cc.CourseNumber__c = uniqueValuesList[index];
            index++;
        }
        if(!Trigger.isExecuting){
            Database.update(ccList,false);
        }
        return ccList;
    }
    
    public static void beforeInsert(List<sumoapp__AdditionalInfo__c> newCourses) {
        try {
            calculateCourseSeriesDuration(newCourses, new Map<Id, sumoapp__AdditionalInfo__c>(), true);
            populateUniqueClientId(newCourses);
        } catch (Exception e) {
            LoggerClass.log(e,'');
        }
    }
    
    private static List<sumoapp__AdditionalInfo__c> checkDuplicacy(Set<String> uniqueValuesSet){
        return new List<sumoapp__AdditionalInfo__c>([Select id from sumoapp__AdditionalInfo__c where CourseNumber__c in: uniqueValuesSet limit 1]);
    }
    
    /**
* @desc: Executes after inserting new sumoapp__AdditionalInfo__c records.
* @param newCourse: List of new sumoapp__AdditionalInfo__c records inserted.
*/
    public static void afterInsert(List<sumoapp__AdditionalInfo__c> newCourses) {
        try {
            calculateCourseSeriesDuration(newCourses, new Map<Id, sumoapp__AdditionalInfo__c>(), true);
        } catch (Exception e) {
            LoggerClass.log(e,'');
        }
    }
    
    /**
* @desc: Executes after updating existing sumoapp__AdditionalInfo__c records.
* @param newCourse: List of new sumoapp__AdditionalInfo__c records being updated.
* @param oldCourse: Map of old sumoapp__AdditionalInfo__c records being updated.
*/
    public static void afterUpdate(List<sumoapp__AdditionalInfo__c> newCourses, Map<Id, sumoapp__AdditionalInfo__c> oldCourses) {
        try {
            calculateCourseSeriesDuration(newCourses, oldCourses, false);
        } catch (Exception e) {
            LoggerClass.log(e,'');
        }
    }
    
    /**
* @desc: calculate Course Series Duration in minute
* @param newCourses: List of new sumoapp__AdditionalInfo__c records inserted.
* @param oldCourses: Map of old sumoapp__AdditionalInfo__c records to check for changes.
* @param IsNew: Boolean flag indicating if the records are new.
*/  
    public static void calculateCourseSeriesDuration(List<sumoapp__AdditionalInfo__c> newCourses, Map<Id, sumoapp__AdditionalInfo__c> oldCourses, Boolean IsNew){
        Set<Id> parentCourseIds = new Set<Id>();
        
        for(sumoapp__AdditionalInfo__c course : newCourses){
            if(!course.IsParent__c && (IsNew || oldCourses.get(course.Id).sumoapp__DurationInMinutes__c != course.sumoapp__DurationInMinutes__c)){
                parentCourseIds.add(course.sumoapp__Parent__c);
            }
        }
        
        if(parentCourseIds.size() > 0){
            Map<Id,Decimal> courseDurationMap = new Map<Id,Decimal>();
            List<sumoapp__AdditionalInfo__c> allChildCourseList = [select id, sumoapp__DurationInMinutes__c, sumoapp__Parent__c from sumoapp__AdditionalInfo__c where sumoapp__Parent__c IN : parentCourseIds WITH SECURITY_ENFORCED]; 
            for(sumoapp__AdditionalInfo__c course : allChildCourseList){
                Decimal duration = 0;
                if(courseDurationMap.containsKey(course.sumoapp__Parent__c)){
                    duration = courseDurationMap.get(course.sumoapp__Parent__c);
                }
                duration = duration + course.sumoapp__DurationInMinutes__c;
                courseDurationMap.put(course.sumoapp__Parent__c, duration);
            }

            List<sumoapp__AdditionalInfo__c> parentCourseList = [select id, Total_Duration_In_Minutes__c from sumoapp__AdditionalInfo__c where id IN : courseDurationMap.keySet() WITH SECURITY_ENFORCED];
            for(sumoapp__AdditionalInfo__c parentCourse : parentCourseList){
                parentCourse.Total_Duration_In_Minutes__c = courseDurationMap.get(parentCourse.Id);
            }
            update parentCourseList;
        }
    }
}