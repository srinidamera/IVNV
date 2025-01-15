/*
* @description    Hud Ami IL Process Batch
* @group          HUD AMI Integration
*/
public with sharing class HudAmiILProcessBatch implements Database.Batchable<HudAmiRequestProcessService.HudAmiStateCountyWrapper>,Database.AllowsCallouts,Database.Stateful {
    public List<HudAmiCalloutService.HudAmiStateResponse> statesList;
    public List<HudAmiRequestProcessService.HudAmiStateCountyWrapper> stateCountiesList;
    public Map<String,HudAmiRequestProcessService.HudAmiIlDataWrapper> idataWrapMap;
    /*
    * @description : Parameterized Constructor
    */
    public HudAmiILProcessBatch(List<HudAmiCalloutService.HudAmiStateResponse> statesList, List<HudAmiRequestProcessService.HudAmiStateCountyWrapper> stateCountiesList) {
        this.statesList = statesList;
        this.stateCountiesList = stateCountiesList;
        this.idataWrapMap = new Map<String,HudAmiRequestProcessService.HudAmiIlDataWrapper>();
    }
    /*
    * @description : Start method of batch
    */
    public Iterable<HudAmiRequestProcessService.HudAmiStateCountyWrapper> start(Database.BatchableContext BC) {
        if(!this.stateCountiesList.isEmpty())
            return this.stateCountiesList;
        return new List<HudAmiRequestProcessService.HudAmiStateCountyWrapper>();
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
    public void execute(Database.BatchableContext BC, List<HudAmiRequestProcessService.HudAmiStateCountyWrapper> recordList){
        HudAmiRequestProcessService.HudAmiStateCountyWrapper stateCountyWrap = recordList[0];
        HudAmiCalloutService.CalloutParamsWrapper reqParam = new HudAmiCalloutService.CalloutParamsWrapper();
        reqParam.calltype = HudAmiCalloutService.GET_IL_INFO;
        reqParam.endpointPostfix = HudAmiCalloutService.ILDATALIST_ENDPOINT+stateCountyWrap.fipsCode;
        try{        
            HudAmiCalloutService.CalloutResponseWrapper respWrap = doCallout(reqParam);
            System.debug('respWrap 41 '+respWrap);
            if(respWrap.statusCode == 200){
                HudAmiRequestProcessService.HudAmiIlDataWrapper idatawrap = HudAmiRequestProcessService.populateIldataList(respWrap.ilResp);
                idataWrapMap.put(stateCountyWrap.fipsCode,idatawrap);
            } else if(respWrap.statusCode == 429){
                DateTime myStartDateTime = datetime.now();
                DateTime newDateTime = myStartDateTime.addSeconds(5);
                while(datetime.now() < newDateTime ) {}
                respWrap = doCallout(reqParam);
                if(respWrap.statusCode == 200){
                    HudAmiRequestProcessService.HudAmiIlDataWrapper idatawrap = HudAmiRequestProcessService.populateIldataList(respWrap.ilResp);
                    idataWrapMap.put(stateCountyWrap.fipsCode,idatawrap);
                } else {
                    Log__c logRec = new Log__c();
                    logRec.ClassName__c = 'HudAmiCountyProcessBatch';
                    logRec.MethodName__c = 'HudAmiILProcessBatch.execute';
                    logRec.LineNumber__c = 36;
                    logRec.ExceptionMessage__c = 'respWrap.statusCode : '+respWrap.statusCode;
                    logRec.StackTrace__c = 'HudAmiILProcessBatch.execute --> stateobj : '+stateCountyWrap.stateCode + ' fips : '+stateCountyWrap.fipsCode;
                    insert logRec;
                }
            } else {
                Log__c logRec = new Log__c();
                logRec.ClassName__c = 'HudAmiCountyProcessBatch';
                logRec.MethodName__c = 'HudAmiILProcessBatch.execute';
                logRec.LineNumber__c = 28;
                logRec.ExceptionMessage__c = 'respWrap.statusCode : '+respWrap.statusCode;
                logRec.StackTrace__c = 'HudAmiILProcessBatch.execute --> stateobj : '+stateCountyWrap.stateCode + ' fips : '+stateCountyWrap.fipsCode;
                insert logRec;
            }
        } catch(Exception ex){
            Log__c logRec = new Log__c();
            logRec.ClassName__c = 'HudAmiCountyProcessBatch';
            logRec.MethodName__c = 'HudAmiILProcessBatch.execute';
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
        if((!idataWrapMap.isEmpty()) || statesList.size() > 0){
            if (!Test.isRunningTest()) {
                HudAmiZipProcessBatch bat = new HudAmiZipProcessBatch(statesList, stateCountiesList, idataWrapMap);
                Database.executeBatch(bat,1);
            }
        }
    }
}