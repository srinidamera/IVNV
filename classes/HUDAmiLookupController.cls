/**
 * @description A controller class to handle various HUD AMI (Area Median Income) related operations 
 * including validation, record retrieval, AMI calculations, and updates.
 */
public with sharing class HUDAmiLookupController {

    /**
     * @description Validates if the given record has a valid Metropolitan Statistical Area (MSA) value.
     * @param recordId The Id of the record to validate.
     * @param objectApiName The API name of the object the record belongs to.
     * @return Boolean indicating whether the record has a valid MSA value.
     * @throws AuraHandledException if an error occurs during the validation process.
     */
    @AuraEnabled
    public static Boolean validAMI(Id recordId, String objectApiName) {
        String NWC2NameSpace = Utility.getNwc2NameSpace();
        try {
            Schema.SObjectType sObjectType = Schema.getGlobalDescribe().get(objectApiName);
            Schema.DescribeSObjectResult describeResult = sObjectType.getDescribe();
            List<SObject> objList = Database.query('SELECT Id, '+NWC2NameSpace+'MetropolitanStatisticalArea__c FROM ' + describeResult.getName() + ' WHERE Id = :recordId WITH SECURITY_ENFORCED LIMIT 1');
            if (!objList.isEmpty()) {
                SObject obj = objList[0];
                if (String.isNotEmpty((String)obj.get(NWC2NameSpace+'MetropolitanStatisticalArea__c'))) {
                    return true;
                }
            }
        } catch (Exception e) {
            System.debug('Error in validAMI: ' + e.getMessage());
            throw new AuraHandledException('Error in validAMI: ' + e.getMessage());
        }
        return false;
    }
    
    /**
     * @description Retrieves a record based on the record Id and object API name.
     * @param recordId The Id of the record to retrieve.
     * @param objectApiName The API name of the object.
     * @return The retrieved SObject record.
     * @throws AuraHandledException if an error occurs during the retrieval process.
     */
    @AuraEnabled(cacheable=true)
    public static SObject getRecord(Id recordId, String objectApiName) {
        SObject record = null;
        try {
            Schema.SObjectType sObjectType = Schema.getGlobalDescribe().get(objectApiName);
            if (sObjectType == null) {
                throw new AuraHandledException('Invalid objectApiName: ' + objectApiName);
            }
            
            if (sObjectType == Intake__c.SObjectType) {
                record = [SELECT Id, HouseholdSize__c, Address__PostalCode__s, AnnualHouseholdIncome__c, HouseholdMonthlyIncome__c, MetropolitanStatisticalArea__c, HouseholdofAMI__c, DateAMILastCalculated__c, AreaMedianIncome__c  
                          FROM Intake__c  
                          WHERE Id = :recordId AND Address__PostalCode__s != null WITH SECURITY_ENFORCED
                          LIMIT 1];
            } else if (sObjectType == Contact.SObjectType) {
                record = [SELECT Id, AnnualHouseholdIncome__c, MailingPostalCode, HouseholdMonthlyIncome1__c, HouseholdSize__c, MetropolitanStatisticalArea__c  
                          FROM Contact  
                          WHERE Id = :recordId AND MailingPostalCode != null WITH SECURITY_ENFORCED
                          LIMIT 1];
            } else if (sObjectType == ClientCase__c.SObjectType) {
                record = [SELECT Id, AnnualHouseholdIncome__c, Address__PostalCode__s, HouseholdMonthlyIncome1__c, DateAMILastCalculated__c, HouseholdSize__c, MetropolitanStatisticalArea__c  
                          FROM ClientCase__c  
                          WHERE Id = :recordId AND Address__PostalCode__s != null 
                          WITH SECURITY_ENFORCED limit 1];
            }
            else {
                throw new AuraHandledException('Unsupported objectApiName: ' + objectApiName);
            }
            return record;
        } catch (Exception e) {
            throw new AuraHandledException('Error fetching record: ' + e.getMessage());
        }
    }
    
    /**
     * @description Retrieves unique county names related to HUD AMI data based on the record's zip code.
     * @param recordId The Id of the record to fetch HUD AMI data.
     * @param objectApiName The API name of the object the record belongs to.
     * @return List of unique county names.
     * @throws AuraHandledException if an error occurs during the retrieval process.
     */
    @AuraEnabled
    public static List<String> getHudAmiUniqueCounty(Id recordId, String objectApiName) {
        try {
            SObject obj = getRecord(recordId, objectApiName);
            if (obj != null) {
                String zipCodeField = (objectApiName == Intake__c.SObjectType.getDescribe().getName()) ? 'Address__PostalCode__s' :
                                      (objectApiName == Contact.SObjectType.getDescribe().getName()) ? 'MailingPostalCode' :
                                      (objectApiName == ClientCase__c.SObjectType.getDescribe().getName()) ? 'Address__PostalCode__s' :
                                      null;
                if (String.isNotBlank(zipCodeField)) {
                    String zipCode = (String)obj.get(zipCodeField);
                    
                    List<HUDAMIData__c> hudList = [SELECT Id, CountyName__c, TownName__c, MedianFamilyIncome__c, 
                                                   il_metro_name__c, Areaname__c, Zipcode__c, StateCode__c, StateName__c,
                                                   il30p1__c, il30p2__c, il30p3__c, il30p4__c, il30p5__c, il30p6__c, il30p7__c, il30p8__c,
                                                   il50p1__c, il50p2__c, il50p3__c, il50p4__c, il50p5__c, il50p6__c, il50p7__c, il50p8__c,
                                                   il80p1__c, il80p2__c, il80p3__c, il80p4__c, il80p5__c, il80p6__c, il80p7__c, il80p8__c
                                                   FROM HUDAMIData__c WHERE Zipcode__c = :zipCode WITH SECURITY_ENFORCED ORDER BY CountyName__c ASC ];
                    
                    Set<String> hudamiuniqueCountiesSet = new Set<String>();
                    for (HUDAMIData__c hud : hudList) {
                        hudamiuniqueCountiesSet.add(hud.CountyName__c);
                    }
                    System.debug('hudamiuniqueCountiesSet###' + hudamiuniqueCountiesSet);
                    return new List<String>(hudamiuniqueCountiesSet);
                } else {
                    throw new AuraHandledException('Invalid object API name or missing zip code field.');
                }
            } else {
                throw new AuraHandledException('Error fetching record');
            }
        } catch (Exception e) {
            throw new AuraHandledException('Error fetching HUD AMI unique counties: ' + e.getMessage());
        }
    }
    
    /**
     * @description Retrieves unique town names related to HUD AMI data based on the record's zip code and county name.
     * @param recordId The Id of the record to fetch HUD AMI data.
     * @param objectApiName The API name of the object the record belongs to.
     * @param countyName The name of the county.
     * @return List of HUDAMIData__c records representing unique towns.
     * @throws AuraHandledException if an error occurs during the retrieval process.
     */
    @AuraEnabled(cacheable=true)
    public static List<HUDAMIData__c> getHudAmiUniquetowns(Id recordId, String objectApiName, String countyName) {
        try {
            SObject obj = getRecord(recordId, objectApiName);
            if (obj != null) {
                String zipCodeField = (objectApiName == Intake__c.SObjectType.getDescribe().getName()) ? 'Address__PostalCode__s' :
                                      (objectApiName == Contact.SObjectType.getDescribe().getName()) ? 'MailingPostalCode' :
                                      (objectApiName == ClientCase__c.SObjectType.getDescribe().getName()) ? 'Address__PostalCode__s' :
                                      null;
                if (String.isNotBlank(zipCodeField)) {
                    String zipCode = (String)obj.get(zipCodeField);
                    return [SELECT Id, CountyName__c, TownName__c, MedianFamilyIncome__c, 
                            il_metro_name__c, Areaname__c, Zipcode__c, StateCode__c, StateName__c,
                            il30p1__c, il30p2__c, il30p3__c, il30p4__c, il30p5__c, il30p6__c, il30p7__c, il30p8__c,
                            il50p1__c, il50p2__c, il50p3__c, il50p4__c, il50p5__c, il50p6__c, il50p7__c, il50p8__c,
                            il80p1__c, il80p2__c, il80p3__c, il80p4__c, il80p5__c, il80p6__c, il80p7__c, il80p8__c
                            FROM HUDAMIData__c WHERE Zipcode__c = :zipCode AND CountyName__c = :countyName WITH SECURITY_ENFORCED ORDER BY TownName__c ASC];
                } else {
                    throw new AuraHandledException('Invalid object API name or missing zip code field.');
                }
            } else {
                throw new AuraHandledException('Error fetching record');
            }
        } catch (Exception e) {
            throw new AuraHandledException('Error fetching HUD AMI unique towns: ' + e.getMessage());
        }
    }
    
    /**
     * @description Calculates the Household Area Median Income (AMI) based on the given inputs and updates the record.
     * @param recordId The Id of the record to update.
     * @param hudamiId The Id of the HUD AMI data record.
     * @param objectApiName The API name of the object the record belongs to.
     * @return String indicating the status of the update operation.
     * @throws AuraHandledException if an error occurs during the calculation or update process.
     */
    @AuraEnabled
    public static String calculateAMIandCommit(Id recordId, Id hudamiId, String objectApiName) {
        System.debug('Method Entry');
        String NWC2NameSpace = Utility.getNwc2NameSpace();
        try {
            SObject obj = getRecord(recordId, objectApiName);
            String zipCodeField = null;
            String HouseholdMonthlyIncome = null;
            
            if (objectApiName == Intake__c.SObjectType.getDescribe().getName()) {
                zipCodeField = 'Address__PostalCode__s';
                HouseholdMonthlyIncome = 'HouseholdMonthlyIncome__c';
            } 
            else if (objectApiName == Contact.SObjectType.getDescribe().getName()) {
                zipCodeField = 'MailingPostalCode';
                HouseholdMonthlyIncome = 'HouseholdMonthlyIncome1__c';
            } 
            else if (objectApiName == ClientCase__c.SObjectType.getDescribe().getName()) {
                zipCodeField = 'Address__PostalCode__s';
                HouseholdMonthlyIncome = 'HouseholdMonthlyIncome1__c';
            } else {
                throw new AuraHandledException('Unsupported objectApiName: ' + objectApiName);
            }
            
            if (obj != null && obj.get(NWC2NameSpace+'HouseholdSize__c') != null && obj.get(NWC2NameSpace+'AnnualHouseholdIncome__c') != null && obj.get(NWC2NameSpace+HouseholdMonthlyIncome) != null) {
                HUDAMIData__c hud = [SELECT Id, CountyName__c, TownName__c, MedianFamilyIncome__c, 
                                     il_metro_name__c, Areaname__c, Zipcode__c, StateCode__c, StateName__c,
                                     il30p1__c, il30p2__c, il30p3__c, il30p4__c, il30p5__c, il30p6__c, il30p7__c, il30p8__c,
                                     il50p1__c, il50p2__c, il50p3__c, il50p4__c, il50p5__c, il50p6__c, il50p7__c, il50p8__c,
                                     il80p1__c, il80p2__c, il80p3__c, il80p4__c, il80p5__c, il80p6__c, il80p7__c, il80p8__c
                                     FROM HUDAMIData__c WHERE Id = :hudamiId WITH SECURITY_ENFORCED];
                
                if (hud != null) {
                    HUDAMICalculationService.HUDAMIServiceWrapper wrapper = HUDAMICalculationService.getHudAmiCalculatedWrapper(
                        hud, 
                        Integer.valueOf(((Decimal)obj.get(NWC2NameSpace+'HouseholdSize__c')).intValue()), 
                        (Decimal)obj.get(NWC2NameSpace+'AnnualHouseholdIncome__c')
                    );
                    
                    if (String.isBlank(wrapper.error)) {
                        obj.put(NWC2NameSpace+'County__c', wrapper.countyName != null ? wrapper.countyName : '');
                        obj.put(NWC2NameSpace+'MetropolitanStatisticalArea__c', wrapper.metropolitanStatisticalArea != null ? wrapper.metropolitanStatisticalArea : '');
                        // obj.put('AreaName__c', wrapper.areaname != null ? wrapper.areaname : ''); //create this field if this assignment required
                        obj.put(NWC2NameSpace+'Town__c', wrapper.townName != null ? wrapper.townName : '');
                        obj.put(zipCodeField, wrapper.zipcode != null ? wrapper.zipcode : '');
                        obj.put(NWC2NameSpace+'DateAMILastCalculated__c', System.now());
                        Decimal il50p4 = hud.get(NWC2NameSpace+'il50p4__c') != null ? Decimal.valueOf((String)hud.get(NWC2NameSpace+'il50p4__c')) : null;
                        obj.put(NWC2NameSpace+'HouseholdofAMI__c', calculateHouseholdAMI(
                            (Decimal)obj.get(NWC2NameSpace+'HouseholdSize__c'), 
                            (Decimal)obj.get(NWC2NameSpace+'AnnualHouseholdIncome__c'), 
                            il50p4
                        ));                      
                        obj.put(NWC2NameSpace+'AreaMedianIncome__c', getpicklistvalonHami((Decimal)obj.get(NWC2NameSpace+'HouseholdofAMI__c')));
                        obj.put(NWC2NameSpace+'EvaluateHUDAMI__c', false);
                        update obj; 
                        
                        System.debug('### Success');
                        return 'RECORD_UPDATED';
                    }
                }
            }
            
            return 'FIELD_VALIDATION_FAILED';
        } catch (Exception e) {
            throw new AuraHandledException('Error calculating AMI and committing: ' + e.getMessage());
        }
    }
    
    /**
     * @description Calculates the Household Area Median Income (AMI) based on household size and income.
     * @param hhsize The household size.
     * @param annualIncome The annual household income.
     * @param averageIlincome The average income for the area.
     * @return The calculated household AMI.
     */
    public static Decimal calculateHouseholdAMI(Decimal hhsize, Decimal annualIncome, Decimal averageIlincome){
        Decimal householdAmi = 0.00;
        Decimal halfincomeofhhentered = 0.00;
        Decimal halfincomeofhhenteredroundtofifty = 0.00;
        Decimal exactAmi = 0.00;
        
        switch on Integer.valueOf(hhsize) {
            when 1 {
                halfincomeofhhentered = 0.7 * averageIlincome;
                halfincomeofhhenteredroundtofifty = roundUptofifty(math.mod(Integer.valueOf(halfincomeofhhentered),50),halfincomeofhhentered).round(System.RoundingMode.CEILING);
            }
            when 2 {
                halfincomeofhhentered = 0.8 * averageIlincome;
                halfincomeofhhenteredroundtofifty = roundUptofifty(math.mod(Integer.valueOf(halfincomeofhhentered),50),halfincomeofhhentered).round(System.RoundingMode.CEILING);
            }
            when 3 {
                halfincomeofhhentered = 0.9 * averageIlincome;
                halfincomeofhhenteredroundtofifty = roundUptofifty(math.mod(Integer.valueOf(halfincomeofhhentered),50),halfincomeofhhentered).round(System.RoundingMode.CEILING);
            }
            when 4 {
                halfincomeofhhentered = 1 * averageIlincome;
                halfincomeofhhenteredroundtofifty = rounddowntofifty(math.mod(Integer.valueOf(halfincomeofhhentered),50),halfincomeofhhentered).round(System.RoundingMode.FLOOR);
            }
            when else {
                if(Integer.valueOf(hhsize) > 4){
                    Decimal ratio =  ((Integer.valueOf(hhsize) - 4) * 0.08) + 1;
                    halfincomeofhhentered = ratio * averageIlincome;
                    halfincomeofhhenteredroundtofifty = roundUptofifty(math.mod(Integer.valueOf(halfincomeofhhentered),50),halfincomeofhhentered).round(System.RoundingMode.CEILING);
                }
            }
        }
        
        exactAmi = (annualIncome * 50) / halfincomeofhhenteredroundtofifty;
        householdAmi = exactAmi.round(System.RoundingMode.CEILING);
        return householdAmi;
    }
    
    /**
     * @description Returns the Area Median Income (AMI) picklist value based on the calculated household AMI.
     * @param hhami The calculated household AMI.
     * @return The corresponding picklist value for the AMI range.
     */
    public static String getpicklistvalonHami(Decimal hhami){
        String str = '';
        if(hhami < 30){
            str = 'Below 30% of AMI';
        } else if(hhami >= 30 && hhami <= 49){
            str = '30 - 49% of AMI';
        } else if(hhami >= 50.00 && hhami <= 79.00){
            str = '50 - 79% of AMI';
        } else if(hhami >= 101.00 && hhami <= 120.00){
            str = '101% - 120% of AMI';
        } else if(hhami >= 121.00){
            str = 'Above 120% of AMI';
        } else {
            str = 'Chose not to respond';
        }
        return str;
    }
    
    /**
     * @description Rounds up to the nearest fifty.
     * @param modvalue The modulo value.
     * @param halfincome The half income value.
     * @return The rounded up value to the nearest fifty.
     */
    public static Decimal roundUptofifty(Integer modvalue,Decimal halfincome){
        return  halfincome + Decimal.valueOf(50 - modvalue) ;
    }
    
    /**
     * @description Rounds down to the nearest fifty.
     * @param modvalue The modulo value.
     * @param halfincome The half income value.
     * @return The rounded down value to the nearest fifty.
     */
    public static Decimal rounddowntofifty(Integer modvalue,Decimal halfincome){
        return  halfincome - Decimal.valueOf(modvalue)  ;
    }
}