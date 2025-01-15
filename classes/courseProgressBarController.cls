public with sharing class courseProgressBarController {
    /*
    * @description : To get course and class records
    */ 
    @AuraEnabled(cacheable=true)
    public static List<courseWrapper> getParentAndChildRecords(Id recordId) {
        List<courseWrapper>  courseWrapperList = New List<courseWrapper>();
        List<sumoapp__AdditionalInfo__c> aInfoList = [Select Id,Name,sumoapp__Parent__c,IsParent__c,sumoapp__StartDatetime__c From sumoapp__AdditionalInfo__c Where Id =:recordId WITH SECURITY_ENFORCED];
        List<sumoapp__AdditionalInfo__c> resultList = new List<sumoapp__AdditionalInfo__c>();
        string parentId = recordId;
        if(aInfoList[0].IsParent__c){
            resultList = [Select Id,Name,sumoapp__Parent__c,IsParent__c,sumoapp__StartDatetime__c From sumoapp__AdditionalInfo__c Where sumoapp__Parent__c =:recordId WITH SECURITY_ENFORCED Order By Name limit 12];
        }
        else{
            resultList = [Select Id,Name,sumoapp__Parent__c,IsParent__c,sumoapp__StartDatetime__c From sumoapp__AdditionalInfo__c Where sumoapp__Parent__c =:aInfoList[0].sumoapp__Parent__c WITH SECURITY_ENFORCED Order By Name limit 12];
            parentId = aInfoList[0].sumoapp__Parent__c;
        }
        
        integer classNum = 1;
        integer classdate = 24;
        for(sumoapp__AdditionalInfo__c ainfoVar : resultList){
            if(recordId == ainfoVar.Id){
                courseWrapperList.add(New courseWrapper(ainfoVar,ainfoVar.IsParent__c,true,'Day '+string.valueOf(classNum)+' - '+ainfoVar.sumoapp__StartDatetime__c.format('MM/dd/YYYY'),parentId));
            }
            else{
                courseWrapperList.add(New courseWrapper(ainfoVar,ainfoVar.IsParent__c,false, 'Day '+string.valueOf(classNum)+' - '+ainfoVar.sumoapp__StartDatetime__c.format('MM/dd/YYYY'),parentId));
            }
            classNum++;
            classdate++;
        }
        return courseWrapperList;
    }

    public class courseWrapper{
        @AuraEnabled public sumoapp__AdditionalInfo__c aInfo;
        @AuraEnabled public boolean isParent;
        @AuraEnabled public boolean isActive;
        @AuraEnabled public string sessionName;
        @AuraEnabled public string parentId;
        public courseWrapper(sumoapp__AdditionalInfo__c aInfo, boolean isParent,boolean isActive,string sessionName,string parentId ){
            this.aInfo = aInfo;
            this.isParent = isParent;
            this.isActive = isActive;
            this.sessionName = sessionName;
            this.parentId = parentId;
        }
    }
}