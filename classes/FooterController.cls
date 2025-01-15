/**
 * @description  : Class for footer Compass Portal Site
**/
public without sharing class FooterController {
	/**
    * @description : Method to get Agency Profile Data
    **/
    @AuraEnabled(cacheable=true)
    public static AgencyProfile__c getAgencyProfileDetails() {
        try {
            AgencyProfile__c agencyProfileRec = [SELECT Id, Name, AgencyEmailAddress__c	, AgencyPhoneNumber__c, AgencyAddress__c from AgencyProfile__c  LIMIT 1];
            
            return agencyProfileRec != null ? agencyProfileRec : NULL;
        } catch (Exception exe) { 
            LoggerClass.log(exe, null);
            throw new AuraHandledException(exe.getMessage());
        }
        
    }
}