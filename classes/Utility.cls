/*
@description    Utility class for common utility methods and common wrapper classes
*/
public class Utility {

    /*
    @description    Wrapper class for picklist options
    */
    public class PicklistOption {
        @AuraEnabled
        public string label{get;set;}
        @AuraEnabled
        public string value{get;set;}
        
        public PicklistOption(String label, String value){
            this.label = label;
            this.value = value;
        }
    }

    public static List<HUDAMIData__c> getHUDAMIData(Set<String> zipCodes, Set<String> townCountyZipKeys) {
        List<HUDAMIData__c> hudamiData = new List<HUDAMIData__c>();
        if (!zipCodes.isEmpty()) {
            hudamiData = [SELECT Id, CountyName__c, TownName__c, MedianFamilyIncome__c, il_metro_name__c, Areaname__c,
            Zipcode__c, StateCode__c, StateName__c, UniqueKey__c, il30p1__c, il30p2__c, il30p3__c, il30p4__c, il30p5__c,
            il30p6__c, il30p7__c, il30p8__c, il50p1__c, il50p2__c, il50p3__c, il50p4__c, il50p5__c, il50p6__c,
            il50p7__c, il50p8__c, il80p1__c, il80p2__c, il80p3__c, il80p4__c, il80p5__c, il80p6__c, il80p7__c,
            il80p8__c FROM HUDAMIData__c WHERE Zipcode__c IN :zipCodes WITH SECURITY_ENFORCED ];
        } else if (!townCountyZipKeys.isEmpty()) {
            hudamiData = [
                SELECT Id, CountyName__c, TownName__c, MedianFamilyIncome__c, il_metro_name__c, Areaname__c,
                Zipcode__c, StateCode__c, StateName__c, UniqueKey__c, il30p1__c, il30p2__c, il30p3__c, il30p4__c, il30p5__c,
                il30p6__c, il30p7__c, il30p8__c, il50p1__c, il50p2__c, il50p3__c, il50p4__c, il50p5__c, il50p6__c,
                il50p7__c, il50p8__c, il80p1__c, il80p2__c, il80p3__c, il80p4__c, il80p5__c, il80p6__c, il80p7__c,
                il80p8__c
                FROM HUDAMIData__c
                WHERE UniqueKey__c IN :townCountyZipKeys WITH SECURITY_ENFORCED
            ];
        }

        return hudamiData;
    }
    
    /*
    @description    Get NWC2 NameSpace
    */
     public static string getNwc2NameSpace(){
         string NWC2NameSpace = string.valueOf(System.Label.NWC2NameSpace).replace('unmanaged','').trim();
         return NWC2NameSpace;
     }

     /*
    @description    Generate 10 digit unique
    */
    public static String getNewUniqueId(){
		Long timestamp = System.currentTimeMillis();
		Integer randomNum = Math.abs(Crypto.getRandomInteger());
		randomNum = randomNum - (randomNum / 100000) * 100000;
		Long uniqueLong = randomNum + timestamp;
		String uniqueNumber = String.valueOf(uniqueLong).substring(Math.max(String.valueOf(uniqueLong).length() - 10, 0));
		while(uniqueNumber.length() < 10) {
			double MIN = Math.pow(10,0);
			double MAX = Math.pow(10,1) - 1;
			String aleaNumberN = String.valueOf(Math.Round(Math.Random() * (MAX-MIN) + MIN));
			if(aleaNumberN == '0'){
				uniqueNumber = '8' + uniqueNumber;
			} else {
				uniqueNumber = aleaNumberN + uniqueNumber;
			}
		}
        
        if (uniqueNumber.substring(0, 1) == '0') {
            // Replace the leading zero with a random digit between 1 and 9
            Integer leadingDigit = (Integer)(Math.random() * 9) + 1; // Random number between 1 and 9
            uniqueNumber = leadingDigit + uniqueNumber.substring(1); // Replace the first character
            
        }
		return uniqueNumber;
	}
    
}