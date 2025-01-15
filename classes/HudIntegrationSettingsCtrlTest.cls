@isTest
public class HudIntegrationSettingsCtrlTest {
    
    static String statusCode;
    
    @testSetup static void setup() {
        // Create common test IntegrationSettings__c record
        
        Profile adminProfile = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        //UserRole role = [Select Id , name from UserRole where Name='Admin'];
        List<User> adminUser = new List<User>();
        adminUser = TestDataFactory.createUsers(adminProfile.Id,'', 1, false);
        adminUser[0].isActive = true;
        //adminUser[0].UserName = 'TestUserPCN101@gmail.com';
        insert adminUser;
        System.debug('adminUser '+adminUser);
        
        system.runAs(adminUser[0]){
            IntegrationSettings__c rec = new IntegrationSettings__c(); 
            rec.Name = 'HUD Settings';
            rec.AgencyID__c = '82310';
            rec.Username__c = 'MX2310';
            rec.Password__c = '8cs!Harm';
            rec.HUD_AMI_End_Point_URL__c = 'https://www.huduser.gov/hudapi/public';
            rec.HUD_AMI_Data_Token_1__c = 'eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiIsImp0aSI6IjAwMjA3ZmVhY2Q4NjJmNGY0N2Y2ZjAyMWY3ODBhNjA3YTg1YWY3Njc3NTllYTk3MjE4YzZhNGRhMDlhNTcyM2E1MzYxN2Q1NmFjOGNmMzdjIn0.eyJhdWQiOiI2IiwianRpIjoiMDAyMDdmZWFjZDg2MmY0ZjQ3ZjZmMDIxZjc4MGE2MDdhODVhZjc2Nzc1OWVhOTcyMThjNmE0ZGE';
            rec.HUD_AMI_Data_Token_2__c = 'wOWE1NzIzYTUzNjE3ZDU2YWM4Y2YzN2MiLCJpYXQiOjE2MjE5NjYwMzYsIm5iZiI6MTYyMTk2NjAzNiwiZXhwIjoxOTM3NDk4ODM2LCJzdWIiOiIxNjM4MSIsInNjb3BlcyI6W119.HC8YUPS_dvwvUiUwsixAqDn1Q85CeWhbJjirkRZNgJZFFFngBm-ZfRTlOIuq8puRQAzaKARDy5IzaAq3u-Uqng';
            rec.HUD_AMI_Data_Token_3__c = '';
            System.debug('@@@ rec : '+rec);
            insert rec;
            
            List<HUDAMIData__c> hudamiDataList = TestDataFactory.createHUDAMIDataRecords(1, false);
            
            // Modify all values for each record
            hudamiDataList[0] = new HUDAMIData__c(
                Name = 'AL_0112599999_',
                CountyName__c = 'SampleCounty',
                TownName__c = 'SampleTown',
                Zipcode__c = '77777',
                StateCode__c = 'SC',
                StateName__c = 'SampleState',
                MedianFamilyIncome__c = '60000',
                il_metro_name__c = 'SampleMetro',
                Areaname__c = 'SampleArea',
                il30p1__c = '20000',
                il30p2__c = '25000',
                il30p3__c = '30000',
                il50p1__c = '40000',
                il50p2__c = '45000',
                il50p3__c = '50000',
                il80p1__c = '60000',
                il80p2__c = '65000',
                il80p3__c = '70000',
                il30p4__c = '50000',
                il50p4__c = '60000',
                il80p4__c = '70000'
            );
            insert hudamiDataList;
        } 
    }
    
    public class CalloutResponseWrapper{
        public List<HudAmiCalloutService.HudAmiStateResponse> stateRes;
        public List<HudAmiRequestProcessService.HudAmiStateCountyWrapper> stateCountiesList;
        public Map<String,HudAmiRequestProcessService.HudAmiIlDataWrapper> idataWrapMap;
        public List<HudAmiRequestProcessService.HudAmiDTOWrapper> dtoWrapList;
    }
    
    public static CalloutResponseWrapper getWrapper() {
        CalloutResponseWrapper wrapper = new CalloutResponseWrapper();
        
        List<HudAmiCalloutService.HudAmiStateResponse> stateRes = new List<HudAmiCalloutService.HudAmiStateResponse>();
        HudAmiCalloutService.HudAmiStateResponse res = new HudAmiCalloutService.HudAmiStateResponse();
        res.state_name = 'Alabama';
        res.state_code = 'AL';
        res.state_num = '1.0';
        res.category = 'State';
        stateRes.add(res);
        
        
        List<HudAmiRequestProcessService.HudAmiStateCountyWrapper> stateCountiesList = new List<HudAmiRequestProcessService.HudAmiStateCountyWrapper>();
        String townName = 'Albany';
        String countyName = 'Tuscaloosa County';
        String fipsCode = '0112599999';
        String stateName = 'Alabama';
        String stateCode = 'AL';
        String stateNumber = '1.0';
        String stateInfoId = 'AL_01125';
        //countyName":"Tuscaloosa County","fipsCode":"0112599999","stateCode":"AL","stateInfoId":"AL_01125","stateName":"Alabama","stateNumber":"1.0"
        
        HudAmiRequestProcessService.HudAmiStateCountyWrapper resCounty = new HudAmiRequestProcessService.HudAmiStateCountyWrapper(stateInfoId, stateName, stateNumber, stateCode, fipsCode, countyName, townName);
        stateCountiesList.add(resCounty);
        
        Map<String,HudAmiRequestProcessService.HudAmiIlDataWrapper> idataWrapMap = new Map<String,HudAmiRequestProcessService.HudAmiIlDataWrapper>();
        
        String icountyName = 'Walker County, AL';
        String icountiesMsa = '';
        String itownName = 'Walker County, AL';
        String imetroStatus = '0';
        String imetroName = '';
        String iareaName = 'Walker County, AL';
        String iyear = '2024';
        Integer imedianIncome = 73100;
        Integer il30p1 = 15400;
        Integer il30p2 = 20440;
        Integer il30p3 = 25820;
        Integer il30p4 = 31200;
        Integer il30p5 = 36580;
        Integer il30p6 = 41960;
        Integer il30p7 = 45350;
        Integer il30p8 = 48250;
        Integer il50p1 = 25600;
        Integer il50p2 = 29250;
        Integer il50p3 = 32900;
        Integer il50p4 = 36550;
        Integer il50p5 = 39500;
        Integer il50p6 = 42400;
        Integer il50p7 = 45350;
        Integer il50p8 = 48250;
        Integer il80p1 = 40950;
        Integer il80p2 = 46800;
        Integer il80p3 = 52650;
        Integer il80p4 = 58500;
        Integer il80p5 = 63200;
        Integer il80p6 = 67900;
        Integer il80p7 = 72550;
        Integer il80p8 = 77250;
        
        HudAmiRequestProcessService.HudAmiIlDataWrapper ilZipRes = new HudAmiRequestProcessService.HudAmiIlDataWrapper(icountyName, icountiesMsa, itownName, imetroStatus, imetroName, iareaName, iyear, imedianIncome, il30p1, il30p2, il30p3, il30p4, il30p5, il30p6, il30p7, il30p8,  il50p1, il50p2, il50p3, il50p4, il50p5, il50p6, il50p7, il50p8, il80p1, il80p2, il80p3, il80p4,  il80p5, il80p6, il80p7, il80p8);
        idataWrapMap.put(resCounty.fipsCode, ilZipRes);
        
        
        
        HudAmiRequestProcessService.HudAmiStateCountyWrapper statewrp = resCounty;
        HudAmiRequestProcessService.HudAmiIlDataWrapper ildatawrp = ilZipRes;
        
        String zfipscode = '0112599999';
        String zstatecode = 'AL';
        String zipCode = '';
        Double resratio = 0.1712073262089315;
        Double busratio = 0.28518444266238974;
        Double othratio = 0.45663040282269923;
        Double totratio = 0.1858247512049655;
        
        HudAmiRequestProcessService.HudAmiCountyZipWrapper coutyZipObj = new HudAmiRequestProcessService.HudAmiCountyZipWrapper(zfipscode, zstatecode, zipCode, resratio, busratio, othratio, totratio);
        HudAmiRequestProcessService.HudAmiDTOWrapper DtoWrap = new HudAmiRequestProcessService.HudAmiDTOWrapper(statewrp, ildatawrp, coutyZipObj);
        List<HudAmiRequestProcessService.HudAmiDTOWrapper> dtoWrapList = new List<HudAmiRequestProcessService.HudAmiDTOWrapper>();
        dtoWrapList.add(DtoWrap);
        
        wrapper.stateRes = stateRes;
        wrapper.stateCountiesList = stateCountiesList;
        wrapper.idataWrapMap = idataWrapMap;
        wrapper.dtoWrapList = dtoWrapList;
        return wrapper;
    }
    
    @isTest static void getHudIntegrationSettingsTest() {
        IntegrationSettings__c rec = [Select Id, Name, AgencyID__c, Username__c, Password__c, HUD_AMI_End_Point_URL__c, HUD_AMI_Data_Token_1__c, HUD_AMI_Data_Token_2__c, HUD_AMI_Data_Token_3__c from IntegrationSettings__c limit 1];
        //setup();
        User adminUser = [Select Id from User where LastName= 'Default Last Name'];
        Test.startTest();
        system.runAs(adminUser){
        HudIntegrationSettingsCtrl.getHudIntegrationSettings();
        }
        Test.stopTest();
        System.assert(HudIntegrationSettingsCtrl.getHudIntegrationSettings() != null);
    }
    
    @isTest static void upsertHudIntegRecordTest() {
        IntegrationSettings__c rec = [Select Id, Name, AgencyID__c, Username__c, Password__c, HUD_AMI_End_Point_URL__c, HUD_AMI_Data_Token_1__c, HUD_AMI_Data_Token_2__c, HUD_AMI_Data_Token_3__c from IntegrationSettings__c limit 1];
        //setup();
        User adminUser = [Select Id from User where LastName= 'Default Last Name'];
        Boolean actualValue = false;
        Test.startTest();
        system.runAs(adminUser){
        actualValue = HudIntegrationSettingsCtrl.upsertHudIntegRecord(String.valueOf(rec.Id), String.valueOf(rec.AgencyID__c), String.valueOf(rec.Username__c), String.valueOf(rec.Password__c), String.valueOf(rec.HUD_AMI_End_Point_URL__c), String.valueOf(rec.HUD_AMI_Data_Token_1__c), String.valueOf(rec.HUD_AMI_Data_Token_2__c), String.valueOf(rec.HUD_AMI_Data_Token_3__c));
        }
        Test.stopTest();
        System.assertEquals(true, actualValue);
    }
    
    @isTest static void triggerHudCalloutTest() {
        IntegrationSettings__c rec = [Select Id, Name, AgencyID__c, Username__c, Password__c, HUD_AMI_End_Point_URL__c, HUD_AMI_Data_Token_1__c, HUD_AMI_Data_Token_2__c, HUD_AMI_Data_Token_3__c from IntegrationSettings__c limit 1];
        Boolean actualValue = false;
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new StateCalloutMock());
        actualValue = HudIntegrationSettingsCtrl.triggerHudCallout();
        Test.stopTest();
        System.assertEquals(true, actualValue);
    }
    
    @isTest static void HudAMICountyProcessBatchTest() {
        CalloutResponseWrapper wrapper = new CalloutResponseWrapper();
        wrapper = getWrapper();
        User adminUser = [Select Id from User WHERE LastName = 'Default Last Name'];
        HudAmiCalloutService.CalloutResponseWrapper respWrap = new HudAmiCalloutService.CalloutResponseWrapper();
        Test.startTest();
        system.runAs(adminUser){
            statusCode = '200';
            Test.setMock(HttpCalloutMock.class, new CountyCalloutMock());
            
            
            respWrap.stateRespList = wrapper.stateRes;
            
            HudAmiCountyProcessBatch batchObject = new HudAmiCountyProcessBatch(respWrap.stateRespList);
            Database.executeBatch(batchObject,1);
        }
        Test.stopTest();
        System.assertEquals('Alabama', wrapper.stateRes[0].state_name);
    }
    
    @isTest static void HudAMICountyProcessBatchNegativeTest() {
        CalloutResponseWrapper wrapper = new CalloutResponseWrapper();
        wrapper = getWrapper();
        User adminUser = [Select Id from User WHERE LastName = 'Default Last Name'];
        
        Test.startTest();
        system.runAs(adminUser){
            statusCode = '429';
            Test.setMock(HttpCalloutMock.class, new CountyCalloutMock());
            
            HudAmiCalloutService.CalloutResponseWrapper respWrap = new HudAmiCalloutService.CalloutResponseWrapper();
            
            respWrap.stateRespList = wrapper.stateRes;
            
            HudAmiCountyProcessBatch batchObject = new HudAmiCountyProcessBatch(respWrap.stateRespList);
            Database.executeBatch(batchObject,1);
        }
        Test.stopTest();
        System.assertEquals('Alabama', wrapper.stateRes[0].state_name);
    }
    
    @isTest static void HudAMICountyProcessBatchNegative2Test() {
        CalloutResponseWrapper wrapper = new CalloutResponseWrapper();
        wrapper = getWrapper();
        User adminUser = [Select Id from User WHERE LastName = 'Default Last Name'];
        
        Test.startTest();
        
        system.runAs(adminUser){
            statusCode = '455';
            Test.setMock(HttpCalloutMock.class, new CountyCalloutMock());
            
            HudAmiCalloutService.CalloutResponseWrapper respWrap = new HudAmiCalloutService.CalloutResponseWrapper();
            
            respWrap.stateRespList = wrapper.stateRes;
            
            HudAmiCountyProcessBatch batchObject = new HudAmiCountyProcessBatch(respWrap.stateRespList);
            Database.executeBatch(batchObject,1);
        }
        Test.stopTest();
        System.assertEquals('Alabama', wrapper.stateRes[0].state_name);
    }
    
    @isTest static void HudAMIILProcessBatchTest() {
        CalloutResponseWrapper wrapper = new CalloutResponseWrapper();
        wrapper = getWrapper();
        User adminUser = [Select Id from User WHERE LastName = 'Default Last Name'];
        
        Test.startTest();
        system.runAs(adminUser){
            statusCode = '200';
            Test.setMock(HttpCalloutMock.class, new ILCalloutMock());
            
            HudAmiILProcessBatch bat = new HudAmiILProcessBatch(wrapper.stateRes, wrapper.stateCountiesList);
            Database.executeBatch(bat,1);
        }
        Test.stopTest();
        System.assertEquals('Alabama', wrapper.stateRes[0].state_name);
    }
    
    @isTest static void HudAMIILProcessBatchNegativeTest() {
        CalloutResponseWrapper wrapper = new CalloutResponseWrapper();
        wrapper = getWrapper();
        User adminUser = [Select Id from User WHERE LastName = 'Default Last Name'];
        
        Test.startTest();
        system.runAs(adminUser){
            statusCode = '429';
            Test.setMock(HttpCalloutMock.class, new ILCalloutMock());
            
            HudAmiILProcessBatch bat = new HudAmiILProcessBatch(wrapper.stateRes, wrapper.stateCountiesList);
            Database.executeBatch(bat,1);
        }
        Test.stopTest();
        System.assertEquals('Alabama', wrapper.stateRes[0].state_name);
    }
    
    @isTest static void HudAMIILProcessBatchNegative2Test() {
        CalloutResponseWrapper wrapper = new CalloutResponseWrapper();
        wrapper = getWrapper();
        User adminUser = [Select Id from User WHERE LastName = 'Default Last Name'];
        
        Test.startTest();
        system.runAs(adminUser){
            statusCode = '455';
            Test.setMock(HttpCalloutMock.class, new ILCalloutMock());
            
            HudAmiILProcessBatch bat = new HudAmiILProcessBatch(wrapper.stateRes, wrapper.stateCountiesList);
            Database.executeBatch(bat,1);
        }
        Test.stopTest();
        System.assertEquals('Alabama', wrapper.stateRes[0].state_name);
    }
    
    @isTest static void HudAMIZipProcessBatchTest() {
        CalloutResponseWrapper wrapper = new CalloutResponseWrapper();
        wrapper = getWrapper();
        User adminUser = [Select Id from User WHERE LastName = 'Default Last Name'];
        
        Test.startTest();
        system.runAs(adminUser){
            statusCode = '200';
            Test.setMock(HttpCalloutMock.class, new ZIPCalloutMock());
            
            HudAmiZipProcessBatch bat = new HudAmiZipProcessBatch(wrapper.stateRes, wrapper.stateCountiesList, wrapper.idataWrapMap);
            Database.executeBatch(bat,1);
        }
        system.runAs(adminUser){
            statusCode = '200';
            Test.setMock(HttpCalloutMock.class, new ZIPCalloutMock());
            
            HudAmiZipProcessBatch bat = new HudAmiZipProcessBatch(null, wrapper.stateCountiesList, null);
            Database.executeBatch(bat,1);
        }
        Test.stopTest();
        System.assertEquals('Alabama', wrapper.stateRes[0].state_name);
    }
    
    @isTest static void HudAMIZipProcessBatchNegativeTest() {
        CalloutResponseWrapper wrapper = new CalloutResponseWrapper();
        wrapper = getWrapper();
        User adminUser = [Select Id from User WHERE LastName = 'Default Last Name'];
        
        Test.startTest();
        system.runAs(adminUser){
            statusCode = '429';
            Test.setMock(HttpCalloutMock.class, new ZIPCalloutMock());
            
            HudAmiZipProcessBatch bat = new HudAmiZipProcessBatch(wrapper.stateRes, wrapper.stateCountiesList, wrapper.idataWrapMap);
            Database.executeBatch(bat,1);
        }
        Test.stopTest();
        System.assertEquals('Alabama', wrapper.stateRes[0].state_name);
    }
    
    @isTest static void HudAMIZipProcessBatchNegative2Test() {
        CalloutResponseWrapper wrapper = new CalloutResponseWrapper();
        wrapper = getWrapper();
        User adminUser = [Select Id from User WHERE LastName = 'Default Last Name'];
        
        Test.startTest();
        system.runAs(adminUser){
            statusCode = '455';
            Test.setMock(HttpCalloutMock.class, new ZIPCalloutMock());
            
            HudAmiZipProcessBatch bat = new HudAmiZipProcessBatch(wrapper.stateRes, wrapper.stateCountiesList, wrapper.idataWrapMap);
            Database.executeBatch(bat,1);
        }
        Test.stopTest();
        System.assertEquals('Alabama', wrapper.stateRes[0].state_name);
    }
    
    @isTest static void HudAMIRequestCommitProcessBatchTest() {
        CalloutResponseWrapper wrapper = new CalloutResponseWrapper();
        wrapper = getWrapper();
        User adminUser = [Select Id from User WHERE LastName = 'Default Last Name'];
        List<HUDAMIData__c> hudamiDataList = [SELECT Id, Name, CountyName__c, TownName__c, Zipcode__c, MedianFamilyIncome__c , il30p1__c, il30p2__c FROM HUDAMIData__c];
        Test.startTest();
        system.runAs(adminUser){
            wrapper.dtoWrapList[0].ildatawrp.iyear = '288308766554';
            HudAmiRequestCommitBatch bat = new HudAmiRequestCommitBatch(wrapper.stateRes, wrapper.dtoWrapList);
            Database.executeBatch(bat,2000);
        }
        Test.stopTest();
        System.assertEquals('Alabama', wrapper.stateRes[0].state_name);
    }
    
    @isTest static void HudAMIRequestCommitProcessBatchNegTest() {
        CalloutResponseWrapper wrapper = new CalloutResponseWrapper();
        wrapper = getWrapper();
        User adminUser = [Select Id from User WHERE LastName = 'Default Last Name'];
        
        Test.startTest();
        system.runAs(adminUser){
            List<HudAmiRequestProcessService.HudAmiDTOWrapper> dtwrapList = new List<HudAmiRequestProcessService.HudAmiDTOWrapper>();
            
            HudAmiRequestCommitBatch bat = new HudAmiRequestCommitBatch(wrapper.stateRes, dtwrapList);
            Database.executeBatch(bat,2000);
        }
        Test.stopTest();
        System.assertEquals('Alabama', wrapper.stateRes[0].state_name);
    }
    
    public class StateCalloutMock implements HttpCalloutMock{
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('[{"state_name":"Alabama","state_code":"AL","state_num":"1.0","category":"State"}]');
            res.setStatusCode(200);
            return res;
        }
    }
    
    public class CountyCalloutMock implements HttpCalloutMock{
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"data": {"counties": [{"county_name": "Albany","town_name": "Albany","fips_code": "5","statename": "","statecode": "NY"}]}}');
            if (statusCode == '200') {
                res.setStatusCode(200);
            } else if (statusCode == '429') {
                res.setStatusCode(429);
            } else {
                res.setStatusCode(455);
            }
            
            return res;
        }
    }
    
    public class ILCalloutMock implements HttpCalloutMock{
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            //res.setBody('{"data": {"counties": [{"county_name": "Albany","town_name": "Albany","fips_code": "5","statename": "","statecode": "NY"}]}}');
            res.setBody('{"data": {"Data": [{"area_name": "Walker County, AL","county_name": "Walker County, AL","counties_msa": "","town_name": "Walker County","metro_status": "0","metro_name": "","median_income": "73100","year": "2024","extremely_low" : {"Extremely_low" : {"il30_p1" : "15400","il30_p2" : "20440","il30_p3" : "25820","il30_p4" : "31200","il30_p5" : "36580","il30_p6" : "41960","il30_p7" : "45350","il30_p8" : "48250"}},"low" : {"Low" : {"il80_p1" : "40950","il80_p2" : "46800","il80_p3" : "52650","il80_p4" : "58500","il80_p5" : "63200","il80_p6" : "67900","il80_p7" : "72550","il80_p8" : "77250"}},"very_low" : {"Very_low" : {"il50_p1" : "25600","il50_p2" : "29250","il50_p3" : "32900","il50_p4" : "36550","il50_p5" : "39500","il50_p6" : "42400","il50_p7" : "45350","il50_p8" : "48250"}}}]}}');
            if (statusCode == '200') {
                res.setStatusCode(200);
            } else if (statusCode == '429') {
                res.setStatusCode(429);
            } else {
                res.setStatusCode(455);
            }
            return res;
        }
    }
    
    public class ZIPCalloutMock implements HttpCalloutMock{
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"data": {"year": "2024","quarter": "1","input": "01125","crosswalk_type": "county-zip","results" : [{"geoid" : "35401","res_ratio" : "0.1712073262089315","bus_ratio" : "0.28518444266238974","oth_ratio" : "0.45663040282269923","tot_ratio" : "0.1858247512049655"},{"geoid" : "35405","res_ratio" : "0.16784387469614273","bus_ratio" : "0.13181635926222934","oth_ratio" : "0.2184651573066745","tot_ratio" : "0.16654530323520234"}]}}');
            if (statusCode == '200') {
                res.setStatusCode(200);
            } else if (statusCode == '429') {
                res.setStatusCode(429);
            } else {
                res.setStatusCode(455);
            }
            return res;
        }
    }
    
}