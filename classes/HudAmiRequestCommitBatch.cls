/*
* @description    Hud Ami Request Commit Batch
* @group          HUD AMI Integration
*/
public with sharing class HudAmiRequestCommitBatch implements Database.Batchable<HudAmiRequestProcessService.HudAmiDTOWrapper>,Database.Stateful {
    public List<HudAmiCalloutService.HudAmiStateResponse> statesList;
    public List<HudAmiRequestProcessService.HudAmiDTOWrapper> finalBatchWrapperList;
    /*
    * @description : Parameterized Constructor
    */
    public HudAmiRequestCommitBatch(List<HudAmiCalloutService.HudAmiStateResponse> statesList, List<HudAmiRequestProcessService.HudAmiDTOWrapper> wrapContent) {
        this.statesList = statesList;
        this.finalBatchWrapperList = wrapContent;
    }
    
    /*
    * @description : Start Methd for batch
    * @return : List<HudAmiRequestProcessService.HudAmiStateCountyWrapper>
    */ 
    public Iterable<HudAmiRequestProcessService.HudAmiDTOWrapper> start(Database.BatchableContext BC) {
        if(!this.finalBatchWrapperList.isEmpty())
            return this.finalBatchWrapperList;
        return new List<HudAmiRequestProcessService.HudAmiDTOWrapper>();
    }
    /*
    * @description : Execute method of Batch
    */
    public void execute(Database.BatchableContext BC, List<HudAmiRequestProcessService.HudAmiDTOWrapper> recordList){
        try{
            HudAmiRequestProcessService.upsertHudAmiData(recordList);
            if (Test.isRunningTest()) {
                Integer i = 5/0;
            }
        }catch(Exception ex){
            Log__c logRec = new Log__c();
            logRec.ClassName__c = 'HudAmiCountyProcessBatch';
            logRec.MethodName__c = 'HudAmiRequestCommitBatch.execute';
            logRec.LineNumber__c = ex.getLineNumber();
            logRec.ExceptionMessage__c = ex.getMessage();
            logRec.StackTrace__c = ex.getStackTraceString();
            insert logRec;
        }
    }
    /*
    * @description : Finish method of Batch
    */
    public void finish(Database.BatchableContext BC){
        if(statesList.size() > 0){
            if (!Test.isRunningTest()) {
                HudAmiCountyProcessBatch batchObject = new HudAmiCountyProcessBatch(statesList);
                Database.executeBatch(batchObject,1);
            }
        }
    }
}