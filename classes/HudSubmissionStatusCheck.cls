public with sharing class HudSubmissionStatusCheck implements Queueable, Database.AllowsCallouts  {
    Blob xmlContent;
    String submissionId;
    Id x9902RecordId;
    String filePrefix;
    public HudSubmissionStatusCheck(Blob xmlContent, String submissionId, Id x9902RecordId, String filePrefix) {
        this.xmlContent = xmlContent;
        this.submissionId = submissionId;
        this.x9902RecordId = x9902RecordId;
        this.filePrefix = filePrefix;
    }

    public void execute(QueueableContext context) {
        String submissionStatus;
        Boolean chkStatus = true;
        Integer remainingCpuLimit = Limits.getLimitCpuTime() - Limits.getCpuTime();
        if (this.submissionId.substring(0,5) != 'Error'){
            while (chkStatus & remainingCpuLimit > 6000){
                submissionStatus = HTTPCalloutService.getSubmissionInfo(this.submissionId);
                if (submissionStatus == 'DONE' || submissionStatus.substring(0,5) == 'Error') { 
                    chkStatus = false;
                } else {
                    HTTPCalloutService.threadSleep(5000);
                }
                remainingCpuLimit = Limits.getLimitCpuTime() - Limits.getCpuTime();
            }
        }
        if(!chkStatus && remainingCpuLimit > 500) {
            X9902__c x9902 = new X9902__c();
            x9902.Id = this.x9902RecordId;
            if (this.filePrefix == '9902_Summary') {
                x9902.Summary9902SubmissionStatus__c = submissionStatus;
            } else if (this.filePrefix == '9902_Counselor') {
                x9902.CounselorSubmissionStatus__c = submissionStatus;
            } else {
                x9902.ClientSubmissionStatus__c = submissionStatus;
            }
            update x9902;
            if (!Test.isRunningTest()) System.enqueueJob(new SaveGeneratedHudXml(this.xmlContent, this.x9902RecordId, this.filePrefix + '-' +x9902RecordId));
        } else {
            if (!Test.isRunningTest()) System.enqueueJob(new HudSubmissionStatusCheck(this.xmlContent, this.submissionId, this.x9902RecordId, this.filePrefix));
        }
    }
}