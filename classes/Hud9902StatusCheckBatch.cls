public with sharing class Hud9902StatusCheckBatch implements Database.Batchable<SObject>, Database.Stateful, Database.AllowsCallouts  {
    private Id x9902RecId;
    private String query;
    private String submissionIdFieldName;
    private String submissionStatusFieldName;
    private Boolean isProcessing = false;
    public Hud9902StatusCheckBatch(Id x9902RecId, String query, String submissionIdFieldName, String submissionStatusFieldName) {
        this.x9902RecId = x9902RecId;
        this.query = query;
        this.submissionIdFieldName = submissionIdFieldName;
        this.submissionStatusFieldName = submissionStatusFieldName;
    }

    public Database.QueryLocator start(Database.BatchableContext context) {
        return Database.getQueryLocator(this.query);
    }

    public void execute(Database.BatchableContext context, List<SObject> scope) {
        String submissionIdVals;
        List<String> submissionIds = new List<String>();
        Map<String, String> submissionIdToStatus = new Map<String, String>();
        for (SObject obj: scope) {
            submissionIdVals = (String) obj.get(this.submissionIdFieldName);
            if (String.isNotEmpty(submissionIdVals)) {
                submissionIds = submissionIdVals.split('\\s*,\\s*');
                for (String submissionId: submissionIds) {
                    if (String.isNotEmpty(submissionId)) {
                        submissionIdToStatus.put(submissionId, HTTPCalloutService.getSubmissionInfo(submissionId.trim()));
                    }
                }
                this.isProcessing = isSubmissionPending(submissionIdToStatus);
                if (!this.isProcessing) {
                    String combinedStatus;
                    if (isSubmissionSuccessful(submissionIdToStatus)) {
                        combinedStatus = 'DONE';
                    } else {
                        combinedStatus =  String.join(submissionIdToStatus.values(), '\n');
                    }
                    update9902Status(combinedStatus);
                }
            }
        }
    }

    public Boolean isSubmissionPending(Map<String, String> submissionIdToStatus) {
        for (String statusResponse: submissionIdToStatus.values()) {
            if (statusResponse != 'DONE' && statusResponse.substring(0,5) != 'Error') {
                return true;
            }
        }
        return false;
    }

    public Boolean isSubmissionSuccessful(Map<String, String> submissionIdToStatus) {
        Boolean isSuccess = true;
        for (String statusResponse: submissionIdToStatus.values()) {
            if (statusResponse != 'DONE') {
                isSuccess = false;
            }
        }
        return isSuccess;
    }

    public void update9902Status(String submissionStatus) {
        submissionStatus = submissionStatus.length() > 131072 ? submissionStatus.substring(0, 131071): submissionStatus;
        X9902__c x9902Rec = new X9902__c();
        x9902Rec.put('Id', this.x9902RecId);
        x9902Rec.put(submissionStatusFieldName, submissionStatus);
        update x9902Rec;
    }

    public void finish(Database.BatchableContext context) {
        if (this.isProcessing) {
            scheduleForClientCase(this.x9902RecId);
        }
    }

    public static void scheduleForClientCase(Id x9902RecId) {
        String jobName = 'Client-Hud9902StatusCheckBatch-' + x9902RecId;
        abortExistingStatusCheckJobs(jobName + '%');
        String NWC2NameSpace = Utility.getNwc2NameSpace();
        String query = 'SELECT Id, '+NWC2NameSpace+'ClientSubmissionID__c, '+NWC2NameSpace+'ClientSubmissionStatus__c FROM '+NWC2NameSpace+'X9902__c WHERE Id =:x9902RecId';
        String submissionIdFieldName = NWC2NameSpace+'ClientSubmissionID__c';
        String submissionStatusFieldName = NWC2NameSpace+'ClientSubmissionStatus__c';

        Integer delayInMinutes = 10;
        Hud9902StatusCheckBatch clientBatch = new Hud9902StatusCheckBatch(x9902RecId, query, submissionIdFieldName, submissionStatusFieldName);
        System.scheduleBatch(clientBatch, jobName + ' - ' + System.currentTimeMillis(), delayInMinutes);
    }

    public static void abortExistingStatusCheckJobs(String jobName) {
        List<CronTrigger> scheduledJobs = [SELECT Id, CronJobDetail.Name from CronTrigger WHERE CronJobDetail.Name LIKE :jobName];
        for (CronTrigger job:scheduledJobs ) {
            System.abortJob(job.Id);
        }
    }
}