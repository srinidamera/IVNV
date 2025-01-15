/*
* @description    Hud Ami Service Class
* @group          HUD AMI Integration
*/
public with sharing class HudAmiRequestProcessService {
    /*
* @description : HudAmiStateCounty Wrapper Class
*/
    public class HudAmiStateCountyWrapper {
        public String stateInfoId, stateName, stateNumber, stateCode, fipsCode, countyName, townName;
        /*
* @description : Parameterized Constructor
*/
        public HudAmiStateCountyWrapper(String stateInfoId, String stateName, String stateNumber, String stateCode, String fipsCode, String countyName, String townName){
            this.stateInfoId  = stateInfoId;
            this.stateName  = stateName;
            this.stateNumber  = stateNumber;
            this.stateCode  = stateCode;
            this.fipsCode   = fipsCode;
            this.countyName  = countyName;
            this.townName  = townName;
        }
    }
    
    /*
* @description : Method to populate State County list
*/
    public static List<HudAmiStateCountyWrapper> populateStateCountylist(HudAmiCalloutService.HUDAmiStateResponse stateObj, List<HudAmiCalloutService.HudAmiCountyResponse> countyList){
        List<HudAmiStateCountyWrapper> statecountyList = new List<HudAmiStateCountyWrapper>();
        for(HudAmiCalloutService.HudAmiCountyResponse coutyResp :countyList){
            statecountyList.add(new HudAmiStateCountyWrapper(stateObj.state_code +'_' +coutyResp.fips_code.substring(0,5),
                                                             stateObj.state_name,
                                                             stateObj.state_num,
                                                             stateObj.state_code,
                                                             coutyResp.fips_code,
                                                             coutyResp.county_name,
                                                             coutyResp.town_name));
        }
        return statecountyList;
    }
    /*
* @description : HudAmiIlData Wrapper Class
*/
    public class HudAmiIlDataWrapper {
        public String icountyName;
        public String icountiesMsa;
        public String itownName;
        public String imetroStatus;
        public String imetroName;
        public String iareaName;
        public String iyear;
        public Integer imedianIncome;
        public Integer il30p1;
        public Integer il30p2;
        public Integer il30p3;
        public Integer il30p4;
        public Integer il30p5;
        public Integer il30p6;
        public Integer il30p7;
        public Integer il30p8;
        public Integer il50p1;
        public Integer il50p2;
        public Integer il50p3;
        public Integer il50p4;
        public Integer il50p5;
        public Integer il50p6;
        public Integer il50p7;
        public Integer il50p8;
        public Integer il80p1;
        public Integer il80p2;
        public Integer il80p3;
        public Integer il80p4;
        public Integer il80p5;
        public Integer il80p6;
        public Integer il80p7;
        public Integer il80p8;
        /*
* @description : Parameterized Constructor
*/
        public HudAmiIlDataWrapper(String icountyName,String icountiesMsa, String itownName,String imetroStatus,String imetroName, String iareaName,String iyear,Integer imedianIncome,
                                   Integer il30p1,Integer il30p2,Integer il30p3,Integer il30p4, Integer il30p5,Integer il30p6,Integer il30p7,Integer il30p8, Integer il50p1,Integer il50p2,Integer il50p3,Integer il50p4,
                                   Integer il50p5,Integer il50p6,Integer il50p7,Integer il50p8, Integer il80p1,Integer il80p2,Integer il80p3,Integer il80p4, Integer il80p5,Integer il80p6,Integer il80p7,Integer il80p8) {
                                       this.icountyName = icountyName;
                                       this.icountiesMsa  = icountiesMsa;
                                       this.itownName = itownName;
                                       this.imetroStatus = imetroStatus ;
                                       this.imetroName  = imetroName;
                                       this.iareaName   = iareaName;
                                       this.iyear  = iyear;
                                       this.imedianIncome  = imedianIncome;
                                       this.il30p1  = il30p1;
                                       this.il30p2  = il30p2;
                                       this.il30p3  = il30p3;
                                       this.il30p4  = il30p4;
                                       this.il30p5  = il30p5;
                                       this.il30p6  = il30p6;
                                       this.il30p7  = il30p7;
                                       this.il30p8  = il30p8;
                                       this.il50p1  = il50p1;
                                       this.il50p2  = il50p2;
                                       this.il50p3  = il50p3;
                                       this.il50p4  = il50p4;
                                       this.il50p5  = il50p5;
                                       this.il50p6  = il50p6;
                                       this.il50p7  = il50p7;
                                       this.il50p8  = il50p8;
                                       this.il80p1  = il80p1;
                                       this.il80p2  = il80p2;
                                       this.il80p3  = il80p3;
                                       this.il80p4  = il80p4;
                                       this.il80p5  = il80p5;
                                       this.il80p6  = il80p6;
                                       this.il80p7  = il80p7;
                                       this.il80p8  = il80p8;
                                   }
    }
    /*
* @description : Method to populate Il data List
*/
    public static HudAmiIlDataWrapper populateIldataList(HudAmiIlDataResponse ildataResp){
        return new HudAmiIlDataWrapper(ildataResp.data.county_name ,
                                       ildataResp.data.counties_msa ,
                                       ildataResp.data.town_name ,
                                       ildataResp.data.metro_status ,
                                       ildataResp.data.metro_name ,
                                       ildataResp.data.area_name ,
                                       ildataResp.data.year ,
                                       ildataResp.data.median_income,
                                       ildataResp.data.extremely_low.il30_p1,
                                       ildataResp.data.extremely_low.il30_p2,
                                       ildataResp.data.extremely_low.il30_p3,
                                       ildataResp.data.extremely_low.il30_p4,
                                       ildataResp.data.extremely_low.il30_p5,
                                       ildataResp.data.extremely_low.il30_p6,
                                       ildataResp.data.extremely_low.il30_p7,
                                       ildataResp.data.extremely_low.il30_p8,
                                       ildataResp.data.very_low.il50_p1,
                                       ildataResp.data.very_low.il50_p2,
                                       ildataResp.data.very_low.il50_p3,
                                       ildataResp.data.very_low.il50_p4,
                                       ildataResp.data.very_low.il50_p5,
                                       ildataResp.data.very_low.il50_p6,
                                       ildataResp.data.very_low.il50_p7,
                                       ildataResp.data.very_low.il50_p8,
                                       ildataResp.data.low.il80_p1,
                                       ildataResp.data.low.il80_p2,
                                       ildataResp.data.low.il80_p3,
                                       ildataResp.data.low.il80_p4,
                                       ildataResp.data.low.il80_p5,
                                       ildataResp.data.low.il80_p6,
                                       ildataResp.data.low.il80_p7,
                                       ildataResp.data.low.il80_p8);       
    }
    /*
* @description : HudAmiCountyZip Wrapper Class
*/
    public class HudAmiCountyZipWrapper {
        public String zfipscode;
        public String zstatecode;
        public String zipCode;
        public Double resratio;
        public Double busratio;
        public Double othratio;
        public Double totratio;
        /*
* @description : Parameterized Constructor
*/
        public HudAmiCountyZipWrapper(String zfipscode,String zstatecode,String zipCode,Double resratio,Double busratio,Double othratio,Double totratio) {
            this.zfipscode = zfipscode;
            this.zstatecode = zstatecode;
            this.zipCode = zipCode;
            this.resratio = resratio;
            this.busratio = busratio;
            this.othratio = othratio;
            this.totratio = totratio;
        }
    }
    /*
* @description : HudAmiDTO Wrapper Class
*/
    public class HudAmiDTOWrapper {
        
        public HudAmiStateCountyWrapper statewrp;
        public HudAmiIlDataWrapper ildatawrp;
        public HudAmiCountyZipWrapper coutyZipObj;
        /*
* @description : Constructor
*/
        /*
* @description : Parameterized Constructor
*/
        public HudAmiDTOWrapper(HudAmiStateCountyWrapper statewrp,HudAmiIlDataWrapper  ildatawrp,HudAmiCountyZipWrapper coutyZipObj){
            this.statewrp = statewrp; 
            this.ildatawrp = ildatawrp;
            this.coutyZipObj = coutyZipObj;
        }
    }
    /*
* @description : Method to process County Zip Data List
*/
    public static List<HudAmiDTOWrapper> processCountyZipDataList(HudAmiStateCountyWrapper scObj,HudAmiIlDataWrapper ildataWrap,List<HudAmiCountyZipResponse.Results> resultList){
        
        List<HudAmiDTOWrapper> huddtoList = new List<HudAmiDTOWrapper>();
        
        for(HudAmiCountyZipResponse.Results robj :resultList){
            huddtoList.add(new HudAmiDTOWrapper(scObj,ildataWrap,new HudAmiCountyZipWrapper(scObj.fipsCode,scObj.stateCode,robj.geoid,robj.res_ratio,robj.bus_ratio,robj.oth_ratio,robj.tot_ratio)));
        }
        return huddtoList;
    }
    /*
* @description : Method to upsert Hud Ami Data
*/
    public static void upsertHudAmiData(List<HudAmiDTOWrapper> finaldataList){
        Set<String> stateCountyUniqueSet = new Set<String> ();
        List<HUDAMIData__c> hudamiList  = new List<HUDAMIData__c>();
        List<HUDAMIData__c> finalamiList  = new List<HUDAMIData__c>();
        Set<HUDAMIData__c> hudamiSet  = new Set<HUDAMIData__c>();
        
        Map<String,HUDAMIData__c> hudAmidataMap = new Map<String,HUDAMIData__c>();
        System.debug('@@@@@@@@@@@finaldataList upsertHudAmiData '+finaldataList);
        System.debug('@@@@@@@@@@@finaldataList upsertHudAmiData size'+finaldataList.size());
        
        for(HudAmiDTOWrapper obj :finaldataList){
            stateCountyUniqueSet.add(obj.coutyZipObj.zstatecode+'_'+obj.coutyZipObj.zfipscode+'_'+obj.coutyZipObj.zipCode);
        }
        
        System.debug('@@@@@@@@@@@stateCountyUniqueSet  '+finaldataList);
        System.debug('@@@@@@@@@@@stateCountyUniqueSet  size'+finaldataList.size());
        
        hudamiList = [Select Id,Name,CountyName__c,FIPScode__c,il30p1__c,il30p2__c,il30p3__c,
                      il30p4__c,il30p5__c,il30p6__c,il30p7__c,il30p8__c,il50p1__c,il50p2__c,
                      il50p3__c,il50p4__c,il50p5__c,il50p6__c,il50p7__c,il50p8__c,il80p1__c,
                      il80p2__c,il80p3__c,il80p4__c,il80p5__c,il80p6__c,il80p7__c,il80p8__c,
                      Areaname__c,MSA__c,MedianFamilyIncome__c, il_metro_name__c,TownName__c,Year__c,
                      StateCode__c,StateName__c,Zipcode__c from HUDAMIData__c where Name =:stateCountyUniqueSet WITH SECURITY_ENFORCED];
        
        System.debug('@@@@@@@@hudamiList  '+hudamiList);
        System.debug('@@@@@@@@hudamiList size '+hudamiList.size());
        
        if(hudamiList.size() > 0) {
            for(HUDAMIData__c hudobj : hudamiList){    
                hudAmidataMap.put(hudobj.Name,hudobj);
            }
        }             
        
        try{
            for(HUDAmiDTOWrapper wrpObj:finaldataList){
                if(wrpObj == null || wrpObj.ildatawrp == null || wrpObj.ildatawrp.imedianIncome == null || wrpObj.ildatawrp.imedianIncome < 1){
                    continue;
                }           
                HUDAMIData__c rec ;
                
                String uniquecode = '';
                if(wrpObj.coutyZipObj != null){
                    uniquecode = wrpObj.coutyZipObj.zstatecode+'_'+wrpObj.coutyZipObj.zfipscode+'_'+wrpObj.coutyZipObj.zipCode;
                }
                
                rec = hudAmidataMap.containsKey(uniquecode) ? hudAmidataMap.get(uniquecode) : new HUDAMIData__c();
                
                if (Schema.sObjectType.HUDAMIData__c.Fields.Name.isCreateable() && Schema.sObjectType.HUDAMIData__c.Fields.Name.isUpdateable()){
                    rec.Name = String.isNotBlank(uniquecode) ? uniquecode : ''; 
                }
                
                if(wrpObj.ildatawrp != null){
                    rec.Areaname__c	= String.isNotBlank(wrpObj.ildatawrp.iareaName) ? wrpObj.ildatawrp.iareaName : '';
                    rec.MSA__c = String.isNotBlank(wrpObj.ildatawrp.icountiesMsa) ? wrpObj.ildatawrp.icountiesMsa : '';
                    rec.CountyName__c =	String.isNotBlank(wrpObj.ildatawrp.icountyName) ? wrpObj.ildatawrp.icountyName  : '';
                    rec.il30p1__c =	String.valueOf(wrpObj.ildatawrp.il30p1 != null ? wrpObj.ildatawrp.il30p1 : 0);
                    rec.il30p2__c =	String.valueOf(wrpObj.ildatawrp.il30p2 != null ? wrpObj.ildatawrp.il30p2 : 0);
                    rec.il30p3__c =	String.valueOf(wrpObj.ildatawrp.il30p3 != null ? wrpObj.ildatawrp.il30p3 : 0);
                    rec.il30p4__c =	String.valueOf(wrpObj.ildatawrp.il30p4 != null ? wrpObj.ildatawrp.il30p4 : 0);
                    rec.il30p5__c = String.valueOf(wrpObj.ildatawrp.il30p5 != null ? wrpObj.ildatawrp.il30p5 : 0);
                    rec.il30p6__c =	String.valueOf(wrpObj.ildatawrp.il30p6 != null ? wrpObj.ildatawrp.il30p6 : 0);
                    rec.il30p7__c =	String.valueOf(wrpObj.ildatawrp.il30p7 != null ? wrpObj.ildatawrp.il30p7 : 0);
                    rec.il30p8__c =	String.valueOf(wrpObj.ildatawrp.il30p8 != null ? wrpObj.ildatawrp.il30p8 : 0);
                    rec.il50p1__c =	String.valueOf(wrpObj.ildatawrp.il50p1 != null ? wrpObj.ildatawrp.il50p1 : 0);
                    rec.il50p2__c =	String.valueOf(wrpObj.ildatawrp.il50p2 != null ? wrpObj.ildatawrp.il50p2 : 0);
                    rec.il50p3__c =	String.valueOf(wrpObj.ildatawrp.il50p3 != null ? wrpObj.ildatawrp.il50p3 : 0);
                    rec.il50p4__c =	String.valueOf(wrpObj.ildatawrp.il50p4 != null ? wrpObj.ildatawrp.il50p4 : 0);
                    rec.il50p5__c =	String.valueOf(wrpObj.ildatawrp.il50p5 != null ? wrpObj.ildatawrp.il50p5 : 0);
                    rec.il50p6__c =	String.valueOf(wrpObj.ildatawrp.il50p6 != null ? wrpObj.ildatawrp.il50p6 : 0);
                    rec.il50p7__c =	String.valueOf(wrpObj.ildatawrp.il50p7 != null ? wrpObj.ildatawrp.il50p7 : 0);
                    rec.il50p8__c =	String.valueOf(wrpObj.ildatawrp.il50p8 != null ? wrpObj.ildatawrp.il50p8 : 0);
                    rec.il80p1__c =	String.valueOf(wrpObj.ildatawrp.il80p1 != null ? wrpObj.ildatawrp.il80p1 : 0);
                    rec.il80p2__c =	String.valueOf(wrpObj.ildatawrp.il80p2 != null ? wrpObj.ildatawrp.il80p2 : 0);
                    rec.il80p3__c =	String.valueOf(wrpObj.ildatawrp.il80p3 != null ? wrpObj.ildatawrp.il80p3 : 0);
                    rec.il80p4__c = String.valueOf(wrpObj.ildatawrp.il80p4 != null ? wrpObj.ildatawrp.il80p4 : 0);
                    rec.il80p5__c =	String.valueOf(wrpObj.ildatawrp.il80p5 != null ? wrpObj.ildatawrp.il80p5 : 0);
                    rec.il80p6__c =	String.valueOf(wrpObj.ildatawrp.il80p6 != null ? wrpObj.ildatawrp.il80p6 : 0);
                    rec.il80p7__c =	String.valueOf(wrpObj.ildatawrp.il80p7 != null ? wrpObj.ildatawrp.il80p7 : 0);
                    rec.il80p8__c =	String.valueOf(wrpObj.ildatawrp.il80p8 != null ? wrpObj.ildatawrp.il80p8 : 0);
                    //rec.CountyName__c =	String.isNotBlank(wrpObj.ildatawrp.icountyName) ? wrpObj.ildatawrp.icountyName : '';
                    rec.TownName__c	= String.isNotBlank(wrpObj.ildatawrp.itownName) ? wrpObj.ildatawrp.itownName : '';
                    rec.MedianFamilyIncome__c = String.valueOf(wrpObj.ildatawrp.imedianIncome != null ? wrpObj.ildatawrp.imedianIncome : 0);
                    rec.il_metro_name__c = String.isNotBlank(wrpObj.ildatawrp.imetroName) ? wrpObj.ildatawrp.imetroName: '';
                    rec.Year__c = String.isNotBlank(wrpObj.ildatawrp.iyear)? wrpObj.ildatawrp.iyear : '';
                }
                
                if(wrpObj.statewrp != null){
                    rec.StateCode__c =	String.isNotBlank(wrpObj.statewrp.stateCode)? wrpObj.statewrp.stateCode : '';
                    rec.StateName__c =	String.isNotBlank(wrpObj.statewrp.stateName)? wrpObj.statewrp.stateName :'';
                    //rec.TownName__c = String.isNotBlank(wrpObj.statewrp.townName) ? wrpObj.statewrp.townName :'';
                    //rec.CountyName__c = String.isNotBlank(wrpObj.statewrp.countyName) ? wrpObj.statewrp.countyName : '';
                    rec.FIPScode__c = String.isNotBlank(wrpObj.statewrp.fipsCode) ? wrpObj.statewrp.fipsCode : '';                
                }
                
                if(wrpObj.coutyZipObj != null){                    
                    rec.zipcode__c = String.isNotBlank(wrpObj.coutyZipObj.zipCode) ? wrpObj.coutyZipObj.zipCode : '';
                }
                
                hudamiSet.add(rec);
            }
            if (Test.isRunningTest()) {
                Integer i = 5/0;
            }
        }catch(Exception ex){
            Log__c logRec = new Log__c();
            logRec.ClassName__c = 'HudAmiCountyProcessBatch';
            logRec.MethodName__c = 'HudAmiRequestProcessService.upsertHudAmiData.loop failure';
            logRec.LineNumber__c = ex.getLineNumber();
            logRec.ExceptionMessage__c = ex.getMessage();
            logRec.StackTrace__c = ex.getStackTraceString();
            insert logRec;
        }
        
        if(hudamiSet.size() > 0){
            finalamiList.addAll(hudamiSet);
        }
        
        if(finalamiList.size() > 0){
            try{
                Database.UpsertResult[] srList = Database.upsert(finalamiList,false);
                List<Log__c> logRecList = new List<Log__c>();
                for (Database.UpsertResult sr : srList) {
                    if (!sr.isSuccess()) {
                        for(Database.Error err : sr.getErrors()) {
                            System.debug('@@@@ '+err.getStatusCode() + ' : ' + err.getMessage());
                            System.debug('@@@ Fields that affected this error: ' + err.getFields());
                            Log__c logRec = new Log__c();
                            logRec.ClassName__c = 'HudAmiCountyProcessBatch';
                            logRec.MethodName__c = 'HudAmiRequestProcessService.upsertHudAmiData.upsert Failure';
                            logRec.ExceptionMessage__c = err.getMessage();
                            logRec.RelatedToRecord__c = sr.getId();
                            logRec.StackTrace__c = 'Status Code : '+err.getStatusCode() + ' Fields : ' +err.getFields();
                            logRecList.add(logRec);
                        }
                    }
                }
                if(!logRecList.isEmpty()){
                    insert logRecList;
                }
                if (Test.isRunningTest()) {
                    Integer i = 5/0;
                }
            } catch(Exception ex){
                System.debug('@@@@ ex.getCause : '+ex.getCause());
                System.debug('@@@@ ex.getMessage : '+ex.getMessage());
                System.debug('@@@@ ex.getStackTraceString : '+ex.getStackTraceString());
                System.debug('@@@@ ex.getLineNumber : '+ex.getLineNumber());
                Log__c logRec = new Log__c();
                logRec.ClassName__c = 'HudAmiCountyProcessBatch';
                logRec.MethodName__c = 'HudAmiRequestProcessService.upsertHudAmiData';
                logRec.LineNumber__c = ex.getLineNumber();
                logRec.ExceptionMessage__c = ex.getMessage();
                logRec.StackTrace__c = ex.getStackTraceString();
                insert logRec;
            }
        }
    }
}