/*
* @description    Hud Ami County Process Batch
* @group          HUD AMI Integration
*/
public with sharing class HudAmiCountyProcessBatch  implements Database.Batchable<HudAmiCalloutService.HudAmiStateResponse>,Database.AllowsCallouts,Database.Stateful {
    public List<HudAmiCalloutService.HudAmiStateResponse> statesList;
    public List<HudAmiRequestProcessService.HudAmiStateCountyWrapper> stateCountiesList;
    /*
    * @description : Parameterized Constructor
    */
    public HudAmiCountyProcessBatch(List<HudAmiCalloutService.HudAmiStateResponse> statesList){
        this.statesList = statesList;
        this.stateCountiesList = new List<HudAmiRequestProcessService.HudAmiStateCountyWrapper>();
    }
    /*
    * @description : Start method of batch
    */ 
    public Iterable<HudAmiCalloutService.HudAmiStateResponse> start(Database.BatchableContext BC) {
        List<HudAmiCalloutService.HudAmiStateResponse> tempStatesList = new List<HudAmiCalloutService.HudAmiStateResponse>();
        tempStatesList.add(statesList.remove(0));
        return tempStatesList;
    }
    /*
    * @description : Callout method of batch
    */
    private HudAmiCalloutService.CalloutResponseWrapper doCallout(HudAmiCalloutService.CalloutParamsWrapper reqParam){
        return HudAmiCalloutService.performCallout(reqParam);
    }
    /*
    * @description : Execute method of batch
    */
    public void execute(Database.BatchableContext BC, List<HudAmiCalloutService.HudAmiStateResponse> recordList){
        HudAmiCalloutService.HudAmiStateResponse stateobj = recordList[0];
        HudAmiCalloutService.CalloutParamsWrapper reqParam = new HudAmiCalloutService.CalloutParamsWrapper();
        reqParam.calltype = 'CountyList';
        reqParam.endpointPostfix = HudAmiCalloutService.COUNTYLIST_ENDPOINT+stateobj.state_code;
        try {
            HudAmiCalloutService.CalloutResponseWrapper respWrap = doCallout(reqParam);
            if(respWrap.statusCode == 200){
                stateCountiesList.addAll(HudAmiRequestProcessService.populateStateCountylist(stateobj, respWrap.countyRespList));
            } else if(respWrap.statusCode == 429){
                DateTime myStartDateTime = datetime.now();
                DateTime newDateTime = myStartDateTime.addSeconds(5);
                while(datetime.now() < newDateTime ) {}
                respWrap = doCallout(reqParam);
                if(respWrap.statusCode == 200){
                    stateCountiesList.addAll(HudAmiRequestProcessService.populateStateCountylist(stateobj, respWrap.countyRespList));
                } else {
                    Log__c logRec = new Log__c();
                    logRec.ClassName__c = 'HudAmiCountyProcessBatch';
                    logRec.MethodName__c = 'HudAmiCountyProcessBatch.execute';
                    logRec.LineNumber__c = 39;
                    logRec.ExceptionMessage__c = 'respWrap.statusCode : '+respWrap.statusCode;
                    logRec.StackTrace__c = 'HudAmiCountyProcessBatch.execute --> stateobj : '+stateobj.state_code;
                    insert logRec;
                }
            } else {
                Log__c logRec = new Log__c();
                logRec.ClassName__c = 'HudAmiCountyProcessBatch';
                logRec.MethodName__c = 'HudAmiCountyProcessBatch.execute';
                logRec.LineNumber__c = 32;
                logRec.ExceptionMessage__c = 'respWrap.statusCode : '+respWrap.statusCode;
                logRec.StackTrace__c = 'HudAmiCountyProcessBatch.execute --> stateobj : '+stateobj.state_code;
                insert logRec;
            }
        } catch(Exception ex){
            Log__c logRec = new Log__c();
            logRec.ClassName__c = 'HudAmiCountyProcessBatch';
            logRec.MethodName__c = 'HudAmiCountyProcessBatch.execute';
            logRec.LineNumber__c = ex.getLineNumber();
            logRec.ExceptionMessage__c = ex.getMessage();
            logRec.StackTrace__c = ex.getStackTraceString();
            insert logRec;
        }                
    }
    /*
    * @description : Finish method of batch
    */
    public void finish(Database.BatchableContext BC){
        if((!stateCountiesList.isEmpty()) || statesList.size() > 0){
            if (!Test.isRunningTest()) {
                HudAmiILProcessBatch bat = new HudAmiILProcessBatch(statesList,stateCountiesList);
                Database.executeBatch(bat,1);
            }
        }
    } 
}