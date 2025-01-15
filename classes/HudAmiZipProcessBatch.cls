/*
* @description    Hud Ami Zip Process Batch
* @group          HUD AMI Integration
*/
public with sharing class HudAmiZipProcessBatch implements Database.Batchable<HudAmiRequestProcessService.HudAmiStateCountyWrapper>,Database.AllowsCallouts,Database.Stateful {
    public List<HudAmiCalloutService.HudAmiStateResponse> statesList;
    public List<HudAmiRequestProcessService.HudAmiStateCountyWrapper> stateCountiesList;
    public Map<String,HudAmiRequestProcessService.HudAmiIlDataWrapper> idataWrapMap;
    public List<HudAmiRequestProcessService.HudAmiDTOWrapper> dtoWrapList;
    /*
    * @description : Parameterized Constructor
    */
    public HudAmiZipProcessBatch(List<HudAmiCalloutService.HudAmiStateResponse> statesList, List<HudAmiRequestProcessService.HudAmiStateCountyWrapper> stateCountiesList, Map<String,HudAmiRequestProcessService.HudAmiIlDataWrapper> idataWrapMap) {
        this.statesList = statesList;
        this.stateCountiesList = stateCountiesList;
        this.idataWrapMap = idataWrapMap;
        this.dtoWrapList = new List<HudAmiRequestProcessService.HudAmiDTOWrapper>();
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
        reqParam.calltype = HudAmiCalloutService.GET_COUNTY_ZIP_INFO;
        reqParam.endpointPostfix = HudAmiCalloutService.COUNTYZIPLIST_ENDPOINT+(stateCountyWrap.fipsCode.substring(0,5));
        
        HudAmiCalloutService.CalloutResponseWrapper respWrap = doCallout(reqParam);
        try{
            if(respWrap.statusCode == 200){
                List<HudAmiRequestProcessService.HudAmiDTOWrapper> dtoObjList = HudAmiRequestProcessService.processCountyZipDataList(stateCountyWrap,idataWrapMap.get(stateCountyWrap.fipsCode),respWrap.zipResp.data.results);
                dtoWrapList.addAll(dtoObjList);
            } else if(respWrap.statusCode == 429){
                DateTime myStartDateTime = datetime.now();
                DateTime newDateTime = myStartDateTime.addSeconds(5);
                while(datetime.now() < newDateTime ) {}
                respWrap = doCallout(reqParam);
                if(respWrap.statusCode == 200){
                    List<HudAmiRequestProcessService.HudAmiDTOWrapper> dtoObjList = HudAmiRequestProcessService.processCountyZipDataList(stateCountyWrap,idataWrapMap.get(stateCountyWrap.fipsCode),respWrap.zipResp.data.results);
                    dtoWrapList.addAll(dtoObjList);
                } else {
                    Log__c logRec = new Log__c();
                    logRec.ClassName__c = 'HudAmiCountyProcessBatch';
                    logRec.MethodName__c = 'HudAmiZipProcessBatch.execute';
                    logRec.LineNumber__c = 37;
                    logRec.ExceptionMessage__c = 'respWrap.statusCode : '+respWrap.statusCode;
                    logRec.StackTrace__c = 'HudAmiZipProcessBatch.execute --> stateobj : '+stateCountyWrap.stateCode + ' fips : '+stateCountyWrap.fipsCode;
                    insert logRec;
                }
            } else {
                Log__c logRec = new Log__c();
                logRec.ClassName__c = 'HudAmiCountyProcessBatch';
                logRec.MethodName__c = 'HudAmiZipProcessBatch.execute';
                logRec.LineNumber__c = 28;
                logRec.ExceptionMessage__c = 'respWrap.statusCode : '+respWrap.statusCode;
                logRec.StackTrace__c = 'HudAmiZipProcessBatch.execute --> stateobj : '+stateCountyWrap.stateCode + ' fips : '+stateCountyWrap.fipsCode;
                insert logRec;
            }
        } catch(Exception ex){
            Log__c logRec = new Log__c();
            logRec.ClassName__c = 'HudAmiCountyProcessBatch';
            logRec.MethodName__c = 'HudAmiZipProcessBatch.execute';
            logRec.LineNumber__c = ex.getLineNumber();
            logRec.ExceptionMessage__c = ex.getMessage();
            logRec.StackTrace__c = ex.getStackTraceString()+' stateCountyWrap : '+stateCountyWrap+' stateCountyWrap.fipsCode : '+stateCountyWrap?.fipsCode+' idataWrapMap.get(stateCountyWrap.fipsCode) : '+idataWrapMap?.get(stateCountyWrap.fipsCode)+' respWrap : '+respWrap+' respWrap.zipResp : '+respWrap?.zipResp+' respWrap.zipResp.data : '+respWrap?.zipResp?.data+' respWrap.zipResp.data.results : '+respWrap?.zipResp?.data?.results;
            insert logRec;
        }
    }
    /*
    * @description : Finish method of batch
    */
    public void finish(Database.BatchableContext BC){
        if((!dtoWrapList?.isEmpty()) || statesList?.size() > 0){
            if (!Test.isRunningTest()) {
                HudAmiRequestCommitBatch bat = new HudAmiRequestCommitBatch(statesList,dtoWrapList);
                Database.executeBatch(bat,2000);
            }
        }
    }
}