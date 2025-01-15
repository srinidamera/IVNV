public class HUDAMICalculationService {
    
    public class HUDAMIServiceWrapper{
        @AuraEnabled
        public String error, countyName, metropolitanStatisticalArea, areaMedianIncome, areaname, townName, zipcode, stateCode, stateName;
        
        @AuraEnabled
        public DateTime aMILastCalculatedDate;
        
        @AuraEnabled
        public Decimal householdOfAMI;
    }
	
	@AuraEnabled
    public static HUDAMIServiceWrapper getHudAmiCalculatedWrapper(HUDAMIData__c hudRec, Integer householdSize, Decimal annualHouseholdIncome){
        HUDAMIServiceWrapper wrap = new HUDAMIServiceWrapper();
        String NWC2NameSpace = Utility.getNwc2NameSpace();
        Decimal il30, il50, il80, il80To100, il100To120;

        if(String.isBlank(String.valueOf(hudRec.MedianFamilyIncome__c))){
            wrap.error = 'Missing Median Family Income';
            return wrap;
        }
        if(householdSize < 1){
            wrap.error = 'Missing Household Size';
            return wrap;
        } 
        if(annualHouseholdIncome < 0){
            wrap.error = 'Missing Annual Household Income';
            return wrap;
        } 
        // if(annualHouseholdIncome < 1){
        //     wrap.error = 'Missing Annual Household Income';
        //     return wrap;
        // } 
        try{
            wrap.countyName = hudRec.CountyName__c;
            wrap.metropolitanStatisticalArea = hudRec.il_metro_name__c;
            wrap.areaname = hudRec.Areaname__c;
            wrap.townName = hudRec.TownName__c;
            wrap.zipcode = hudRec.Zipcode__c;
            wrap.stateCode = hudRec.StateCode__c;
            wrap.stateName = hudRec.StateName__c;
            wrap.aMILastCalculatedDate = System.now();

            if(householdSize <= 8){
                il30 = Decimal.valueOf((String)hudRec.get(NWC2NameSpace+'il30p'+householdSize+'__c'));
                il50 = Decimal.valueOf((String)hudRec.get(NWC2NameSpace+'il50p'+householdSize+'__c'));
                il80 = Decimal.valueOf((String)hudRec.get(NWC2NameSpace+'il80p'+householdSize+'__c'));
                il80To100 = (il80 * 1.25).round();
                il100To120 = (il80 * 1.5).round();
            } else {
                Decimal dummyVal = Decimal.valueOf((String)hudRec.get(NWC2NameSpace+'il30p4__c'));
                il30 = roundUpToNearestFifty((dummyVal + ((householdSize - 4) * 0.08 * dummyVal)));
                dummyVal = Decimal.valueOf((String)hudRec.get(NWC2NameSpace+'il50p4__c'));
                il50 = roundUpToNearestFifty((dummyVal + ((householdSize - 4) * 0.08 * dummyVal)));
                dummyVal = Decimal.valueOf((String)hudRec.get(NWC2NameSpace+'il80p4__c'));
                il80 = roundUpToNearestFifty((dummyVal + ((householdSize - 4) * 0.08 * dummyVal)));
                dummyVal = Decimal.valueOf((String)hudRec.get(NWC2NameSpace+'il80p4__c')) * 1.25;
                il80To100 = roundUpToNearestFifty((dummyVal + ((householdSize - 4) * 0.08 * dummyVal)));
                dummyVal = Decimal.valueOf((String)hudRec.get(NWC2NameSpace+'il80p4__c')) * 1.5;
                il100To120 = roundUpToNearestFifty((dummyVal + ((householdSize - 4) * 0.08 * dummyVal)));
            }

            if(annualHouseholdIncome <= il30){
                wrap.areaMedianIncome = 'Below 30% of AMI';
            } else if(annualHouseholdIncome <= il50){
                wrap.areaMedianIncome = '30 - 49% of AMI';
            } else if(annualHouseholdIncome <= il80){
                wrap.areaMedianIncome = '50 - 79% of AMI';
            } else if(annualHouseholdIncome <= il80To100){
                wrap.areaMedianIncome = '80 - 100% of AMI';
            } else if(annualHouseholdIncome <= il100To120){
                wrap.areaMedianIncome = '101% - 120% of AMI';
            } else {
                wrap.areaMedianIncome = 'Above 120% of AMI';
            }
            Decimal result = (annualHouseholdIncome / il80To100) * 100;

            wrap.householdOfAMI = result.round();

            return wrap;
        } catch(Exception ex){
            wrap = new HUDAMIServiceWrapper();
            wrap.error = 'Exception : '+ex.getMessage()+' - '+ex.getLineNumber();
            return wrap;
        }
    }
    
    @AuraEnabled
    public static Map<String,List<String>> getCountyNamesBasedOnZip(String zipCode){
        Map<String,List<String>> resp = new Map<String,List<String>>();
        List<HUDAMIData__c> hudData = new List<HUDAMIData__c>([Select id , CountyName__c , TownName__c from HUDAMIData__c where Zipcode__c =:zipCode]);
        for(HUDAMIData__c rec : hudData){
            if(resp.containsKey(rec.CountyName__c)){
                resp.get(rec.CountyName__c).add(rec.TownName__c);
            } else {
                resp.put(rec.CountyName__c, new List<String>{rec.TownName__c});
            }
        }
        return resp;
    }

    private static Decimal roundUpToNearestFifty(Decimal value){
        return (((value / 50).round(System.RoundingMode.CEILING)) * 50);
    }
}