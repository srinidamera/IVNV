/*
* @description    Hud Ami Callout Service
* @group          HUD AMI Integration
*/
public with sharing class HudAmiCalloutService {
    
    public static final String GET_STATE_INFO = 'StateList';
    public static final String GET_COUNTY_INFO = 'CountyList';
    public static final String GET_IL_INFO  = 'IlData';
    public static final String GET_COUNTY_ZIP_INFO = 'CountyZip';
    public static final String STATELIST_ENDPOINT = '/fmr/listStates';
    public static final String COUNTYLIST_ENDPOINT = '/fmr/statedata/';
    public static final String ILDATALIST_ENDPOINT = '/il/data/';
    public static final String COUNTYZIPLIST_ENDPOINT  = '/usps?type=7&query=';
    
    public static IntegrationSettings__c integSett = IntegrationSettings__c.getValues('HUD Settings');
    /*
    * @description : Wrapper Class
    */
    public class CalloutParamsWrapper{
        public String calltype, endpointPostfix;
    }
    /*
    * @description : Wrapper Class
    */
    public class CalloutResponseWrapper{
        public Integer statusCode;
        public String errorMsg;
        public List<HudAmiStateResponse> stateRespList;
        public List<HudAmiCountyResponse> countyRespList;
        public HudAmiIlDataResponse ilResp;
        public HudAmiCountyZipResponse zipResp;
    }
    /*
    * @description : To perform Callout
    */ 
    public static CalloutResponseWrapper performCallout(CalloutParamsWrapper param){
        CalloutResponseWrapper respWrap = new CalloutResponseWrapper();
        
        Httprequest req = new Httprequest();
        Http http = new Http();
        Httpresponse response = new Httpresponse();
        
        try{  
        	String finalendpoint = integSett.HUD_AMI_End_Point_URL__c + param.endpointPostfix;
            
            req.setendpoint(finalendpoint);      
            req.setmethod('GET');
            req.setTimeout(120000);
            req.setHeader('Authorization', 'Bearer '+getamiToken());
            
            response = http.send(req);
            
            System.debug('@@@@ response '+response);
            
            respWrap.statusCode = response.getStatusCode();
            
            if (response.getStatusCode() == 200 ) {
                
                System.debug('@@@@ res.getBody() : '+ response.getBody());
                
                if(param.calltype.equalsIgnoreCase(GET_STATE_INFO)){
                    respWrap.stateRespList = parseStateResp(response.getBody());
                }
                
                if(param.calltype.equalsIgnoreCase(GET_COUNTY_INFO)){
                    respWrap.countyRespList = parseCountyResp(response.getBody());
                }
                
                if(param.calltype.equalsIgnoreCase(GET_IL_INFO)){
                    respWrap.ilResp = parseIlResp(response.getBody());
                }
                
                if(param.calltype.equalsIgnoreCase(GET_COUNTY_ZIP_INFO)){
                    respWrap.zipResp = parseZipResp(response.getBody());
                }
            } else {
                respWrap.errorMsg = response.getBody();
            }
            
        } catch(Exception ex) {
            System.debug('@@@@ ex.getCause : '+ex.getCause());
            System.debug('@@@@ ex.getMessage : '+ex.getMessage());
            System.debug('@@@@ ex.getStackTraceString : '+ex.getStackTraceString());
            System.debug('@@@@ ex.getLineNumber : '+ex.getLineNumber());
            Log__c logRec = new Log__c();
            logRec.ClassName__c = 'HudAmiCountyProcessBatch';
            logRec.MethodName__c = 'HudAmiCalloutService.performCallout';
            logRec.LineNumber__c = ex.getLineNumber();
            logRec.ExceptionMessage__c = ex.getMessage();
            logRec.StackTrace__c = ex.getStackTraceString();
            insert logRec;
        }
        return respWrap;
    }
    /*
    * @description : To get ami Token
    */ 
    public static String getamiToken(){
        String amiToken;
        if(String.isNotBlank(integSett.HUD_AMI_Data_Token_1__c) && String.isNotBlank(integSett.HUD_AMI_Data_Token_2__c)){
            amiToken = integSett.HUD_AMI_Data_Token_1__c.trim()+integSett.HUD_AMI_Data_Token_2__c.trim();
        }
        
        if(String.isNotBlank(integSett.HUD_AMI_Data_Token_1__c) && String.isNotBlank(integSett.HUD_AMI_Data_Token_2__c) && String.isNotBlank(integSett.HUD_AMI_Data_Token_3__c)){
            amiToken = integSett.HUD_AMI_Data_Token_1__c.trim()+integSett.HUD_AMI_Data_Token_2__c.trim()+integSett.HUD_AMI_Data_Token_3__c.trim();
        }
        
        return amiToken;
    }
    /*
    * @description : To parse State Resp
    */ 
    public static List<HudAmiStateResponse> parseStateResp(String json) {
        return (List<HudAmiStateResponse>) System.JSON.deserialize(json, List<HudAmiStateResponse>.class);
    }
    
    public class HudAmiStateResponse {
        public String state_name, state_code, state_num, category;
    }
    
    /*public class HudAmiCountyResponse {
        public String state_code, fips_code, county_name, town_name, category;
    }*/
    public class HudAmiCountyResponse {
        public String town_name, county_name, fips_code, statename, statecode;
    }
    /*
    * @description : To parse County Resp
    */ 
    public static List<HudAmiCountyResponse> parseCountyResp(String jsonString) {
        Map<String, Object> meta = (Map<String, Object>)JSON.deserializeUntyped(jsonString);
        Map<String,object> getData = (Map<String,object>) meta.get('data');
        List<HudAmiCountyResponse> wrapList = new List<HudAmiCountyResponse>();
        for(Object obj : (List<Object>) getData.get('counties')){
            Map<String, Object> countyObj = (Map<String, Object>)obj;
            HudAmiCountyResponse wrap = new HudAmiCountyResponse();
            wrap.town_name = (String)countyObj.get('town_name');
            wrap.county_name = (String)countyObj.get('county_name');
            wrap.fips_code = (String)countyObj.get('fips_code');
            wrap.statename = (String)countyObj.get('statename');
            wrap.statecode = (String)countyObj.get('statecode');
            System.debug('wrap : '+wrap);
            wrapList.add(wrap);
        }
        return wrapList;
        //return (List<HudAmiCountyResponse>) System.JSON.deserialize(json, List<HudAmiCountyResponse>.class);
    }
    /*
    * @description : To parse Il Resp
    */ 
    public static HudAmiIlDataResponse parseIlResp(String json) {
        return (HudAmiIlDataResponse) System.JSON.deserialize(json, HudAmiIlDataResponse.class);
    }
    /*
    * @description : To parse Zip Resp
    */ 
    public static HudAmiCountyZipResponse parseZipResp(String json) {
        return (HudAmiCountyZipResponse) System.JSON.deserialize(json, HudAmiCountyZipResponse.class);
    }
}