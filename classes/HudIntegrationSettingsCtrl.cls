/*
* @description    Controller class containing methods for Hud Integration Settings Component
* @group          HUD AMI Integration
*/
public class HudIntegrationSettingsCtrl {
    /*
    * @description : To get Hud Integration Settings
    */ 
    @AuraEnabled
    public static IntegrationSettings__c getHudIntegrationSettings(){
        IntegrationSettings__c rec = [Select Id, Name, AgencyID__c, AgencyName__c, Username__c, Password__c, HUD_AMI_End_Point_URL__c, HUD_AMI_Data_Token_1__c, HUD_AMI_Data_Token_2__c, HUD_AMI_Data_Token_3__c from IntegrationSettings__c limit 1];
        return rec;
    }
    /*
    * @description : To upsert Hud Integration Settings
    */ 
    @AuraEnabled
    public static boolean upsertHudIntegRecord(String recId, String agencyId, String userName, String password, String endpointUrl, String amiToken1, String amiToken2, String amiToken3){
        IntegrationSettings__c rec = new IntegrationSettings__c();
        rec.Id = String.isNotEmpty(recId) ? recId : '';
        rec.Name = 'HUD Settings';
        rec.AgencyID__c = agencyId;
        rec.Username__c = userName;
        rec.Password__c = password;
        rec.HUD_AMI_End_Point_URL__c = endpointUrl;
        rec.HUD_AMI_Data_Token_1__c = amiToken1;
        rec.HUD_AMI_Data_Token_2__c = amiToken2;
        rec.HUD_AMI_Data_Token_3__c = amiToken3;
        System.debug('@@@ rec : '+rec);
        upsert rec;
        return true;
    }
    /*
    * @description : To trigger Hud Integration Callouts
    */ 
    @AuraEnabled
    public static Boolean triggerHudCallout(){
        System.debug('triggerHudCallout');
        
        if(!validFieldAccess()){
            return false;
        }
        
        IntegrationSettings__c integSettRec = IntegrationSettings__c.getValues('HUD Settings');
        String amitoken = HudAmiCalloutService.getamiToken();
        
        HudAmiCalloutService.CalloutParamsWrapper paramWrap = new HudAmiCalloutService.CalloutParamsWrapper();
        paramWrap.endpointPostfix = HudAmiCalloutService.STATELIST_ENDPOINT;
        paramWrap.calltype = HudAmiCalloutService.GET_STATE_INFO;
        
		HudAmiCalloutService.CalloutResponseWrapper respWrap = HudAmiCalloutService.performCallout(paramWrap);
        if(respWrap.statusCode == 200){
            System.debug('@@@@ respWrap.stateRespList : '+respWrap.stateRespList);
            if (!Test.isRunningTest()) {
                HudAmiCountyProcessBatch batchObject = new HudAmiCountyProcessBatch(respWrap.stateRespList);
        	    Database.executeBatch(batchObject,1);
            }
        } else {
            Log__c logRec = new Log__c();
            logRec.ClassName__c = 'HudAmiCountyProcessBatch';
            logRec.MethodName__c = 'HudIntegrationSettingsCtrl.triggerHudCallout';
            logRec.LineNumber__c = 51;
            logRec.ExceptionMessage__c = respWrap.errorMsg;
            logRec.StackTrace__c = 'HudIntegrationSettingsCtrl.triggerHudCallout';
            insert logRec;
        }
        
        System.debug('@@@@ respWrap : '+respWrap);
        return true;
    }
    /*
    * @description : To check valid field access
    */ 
    private static boolean validFieldAccess(){
        if(Schema.sObjectType.HUDAMIData__c.Fields.Areaname__c.isCreateable() && Schema.sObjectType.HUDAMIData__c.Fields.Areaname__c.isUpdateable() &&
           Schema.sObjectType.HUDAMIData__c.Fields.MSA__c.isCreateable() && Schema.sObjectType.HUDAMIData__c.Fields.MSA__c.isUpdateable() &&
           Schema.sObjectType.HUDAMIData__c.Fields.CountyName__c.isCreateable() && Schema.sObjectType.HUDAMIData__c.Fields.CountyName__c.isUpdateable() &&
           Schema.sObjectType.HUDAMIData__c.Fields.il30p1__c.isCreateable() && Schema.sObjectType.HUDAMIData__c.Fields.il30p1__c.isUpdateable() &&
           Schema.sObjectType.HUDAMIData__c.Fields.il30p2__c.isCreateable() && Schema.sObjectType.HUDAMIData__c.Fields.il30p2__c.isUpdateable() &&
           Schema.sObjectType.HUDAMIData__c.Fields.il30p3__c.isCreateable() && Schema.sObjectType.HUDAMIData__c.Fields.il30p3__c.isUpdateable() &&
           Schema.sObjectType.HUDAMIData__c.Fields.il30p4__c.isCreateable() && Schema.sObjectType.HUDAMIData__c.Fields.il30p4__c.isUpdateable() &&
           Schema.sObjectType.HUDAMIData__c.Fields.il30p5__c.isCreateable() && Schema.sObjectType.HUDAMIData__c.Fields.il30p5__c.isUpdateable() &&
           Schema.sObjectType.HUDAMIData__c.Fields.il30p6__c.isCreateable() && Schema.sObjectType.HUDAMIData__c.Fields.il30p6__c.isUpdateable() &&
           Schema.sObjectType.HUDAMIData__c.Fields.il30p7__c.isCreateable() && Schema.sObjectType.HUDAMIData__c.Fields.il30p7__c.isUpdateable() &&
           Schema.sObjectType.HUDAMIData__c.Fields.il30p8__c.isCreateable() && Schema.sObjectType.HUDAMIData__c.Fields.il30p8__c.isUpdateable() &&
           Schema.sObjectType.HUDAMIData__c.Fields.il50p1__c.isCreateable() && Schema.sObjectType.HUDAMIData__c.Fields.il50p1__c.isUpdateable() &&
           Schema.sObjectType.HUDAMIData__c.Fields.il50p2__c.isCreateable() && Schema.sObjectType.HUDAMIData__c.Fields.il50p2__c.isUpdateable() &&
           Schema.sObjectType.HUDAMIData__c.Fields.il50p3__c.isCreateable() && Schema.sObjectType.HUDAMIData__c.Fields.il50p3__c.isUpdateable() &&
           Schema.sObjectType.HUDAMIData__c.Fields.il50p4__c.isCreateable() && Schema.sObjectType.HUDAMIData__c.Fields.il50p4__c.isUpdateable() &&
           Schema.sObjectType.HUDAMIData__c.Fields.il50p5__c.isCreateable() && Schema.sObjectType.HUDAMIData__c.Fields.il50p5__c.isUpdateable() &&
           Schema.sObjectType.HUDAMIData__c.Fields.il50p6__c.isCreateable() && Schema.sObjectType.HUDAMIData__c.Fields.il50p6__c.isUpdateable() &&
           Schema.sObjectType.HUDAMIData__c.Fields.il50p7__c.isCreateable() && Schema.sObjectType.HUDAMIData__c.Fields.il50p7__c.isUpdateable() &&
           Schema.sObjectType.HUDAMIData__c.Fields.il50p8__c.isCreateable() && Schema.sObjectType.HUDAMIData__c.Fields.il50p8__c.isUpdateable() &&
           Schema.sObjectType.HUDAMIData__c.Fields.il80p1__c.isCreateable() && Schema.sObjectType.HUDAMIData__c.Fields.il80p1__c.isUpdateable() &&
           Schema.sObjectType.HUDAMIData__c.Fields.il80p2__c.isCreateable() && Schema.sObjectType.HUDAMIData__c.Fields.il80p2__c.isUpdateable() &&
           Schema.sObjectType.HUDAMIData__c.Fields.il80p3__c.isCreateable() && Schema.sObjectType.HUDAMIData__c.Fields.il80p3__c.isUpdateable() &&
           Schema.sObjectType.HUDAMIData__c.Fields.il80p4__c.isCreateable() && Schema.sObjectType.HUDAMIData__c.Fields.il80p4__c.isUpdateable() &&
           Schema.sObjectType.HUDAMIData__c.Fields.il80p5__c.isCreateable() && Schema.sObjectType.HUDAMIData__c.Fields.il80p5__c.isUpdateable() &&
           Schema.sObjectType.HUDAMIData__c.Fields.il80p6__c.isCreateable() && Schema.sObjectType.HUDAMIData__c.Fields.il80p6__c.isUpdateable() &&
           Schema.sObjectType.HUDAMIData__c.Fields.il80p7__c.isCreateable() && Schema.sObjectType.HUDAMIData__c.Fields.il80p7__c.isUpdateable() &&
           Schema.sObjectType.HUDAMIData__c.Fields.il80p8__c.isCreateable() && Schema.sObjectType.HUDAMIData__c.Fields.il80p8__c.isUpdateable() &&
           Schema.sObjectType.HUDAMIData__c.Fields.TownName__c.isCreateable() && Schema.sObjectType.HUDAMIData__c.Fields.TownName__c.isUpdateable() &&
           Schema.sObjectType.HUDAMIData__c.Fields.MedianFamilyIncome__c.isCreateable() && Schema.sObjectType.HUDAMIData__c.Fields.MedianFamilyIncome__c.isUpdateable() &&
           Schema.sObjectType.HUDAMIData__c.Fields.il_metro_name__c.isCreateable() && Schema.sObjectType.HUDAMIData__c.Fields.il_metro_name__c.isUpdateable() &&
           Schema.sObjectType.HUDAMIData__c.Fields.Year__c.isCreateable() && Schema.sObjectType.HUDAMIData__c.Fields.Year__c.isUpdateable() &&
           Schema.sObjectType.HUDAMIData__c.Fields.StateCode__c.isCreateable() && Schema.sObjectType.HUDAMIData__c.Fields.StateCode__c.isUpdateable() &&
           Schema.sObjectType.HUDAMIData__c.Fields.StateName__c.isCreateable() && Schema.sObjectType.HUDAMIData__c.Fields.StateName__c.isUpdateable() &&
           Schema.sObjectType.HUDAMIData__c.Fields.FIPScode__c.isCreateable() && Schema.sObjectType.HUDAMIData__c.Fields.StateCode__c.isUpdateable() &&
           Schema.sObjectType.HUDAMIData__c.Fields.zipcode__c.isCreateable() && Schema.sObjectType.HUDAMIData__c.Fields.StateName__c.isUpdateable()){
            return true;
    	}
        return false;
    }
}