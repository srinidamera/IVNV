/**
* @desc: Handles trigger logic and data processing for ClientCase__c object.
*/
public inherited sharing class ClientCaseTriggerHandler {
    
    /**
* @desc: Executes before inserting new ClientCase__c records.
* @param newClientCase: List of new ClientCase__c records being inserted.
*/
    public static void beforeInsert(List<ClientCase__c> newClientCase) {
        populateFieldsOnClientCase(newClientCase, new Map<Id, ClientCase__c>(), true);
    }
    
    /**
* @desc: Executes before updating existing ClientCase__c records.
* @param newClientCase: List of new ClientCase__c records being updated.
* @param oldClientCase: Map of old ClientCase__c records being updated.
*/
    public static void beforeUpdate(List<ClientCase__c> newClientCase, Map<Id, ClientCase__c> oldClientCase) {
        try {
            populateFieldsOnClientCase(newClientCase, oldClientCase, false);
        } catch (Exception e) {
            System.debug('Error in beforeUpdate: ' + e.getMessage());
        }
    }
    
    public static List<ClientCase__c> populateUniqueClientId(List<ClientCase__c> ccList){
        Set<String> uniqueValuesSet = new Set<String>();
        String uniqueId;
        Boolean isUnique = false;
        while(!isUnique){
            while(uniqueValuesSet.size() < ccList.size()){
                uniqueValuesSet.add(Utility.getNewUniqueId());
            }
            List<ClientCase__c> ccListDump = checkDuplicacy(uniqueValuesSet);
            if(ccListDump.size() > 0){
                uniqueValuesSet = new Set<String>();
            } else {
                isUnique = true;
            }
        }
        Integer index = 0;
        List<String> uniqueValuesList = new List<String>(uniqueValuesSet);
        for(ClientCase__c cc : ccList){
            cc.Name = uniqueValuesList[index];
            index++;
        }
        if(!Trigger.isExecuting){
            Database.update(ccList,false);
        }
        return ccList;
    }
    
    public static List<ClientCase__c> checkDuplicacy(Set<String> uniqueValuesSet){
        return new List<ClientCase__c>([Select id from ClientCase__c where Name in: uniqueValuesSet limit 1]);
    }
    
    /**
* @desc: Populates additional fields on ClientCase__c records based on related HUDAMIData__c.
* @param newClientCase: List of new ClientCase__c records to process.
* @param oldClientCase: Map of old ClientCase__c records to check for changes.
* @param IsNew: Boolean flag indicating if the records are new.
*/
    public static void populateFieldsOnClientCase(List<ClientCase__c> newClientCase, Map<Id, ClientCase__c> oldClientCase, Boolean IsNew) {
        Map<String, List<HUDAMIData__c>> hudamiDataMap = new Map<String, List<HUDAMIData__c>>();
        Set<String> zipCodes = new Set<String>();
        Set<String> townCountyZipKeys = new Set<String>();
        List<ClientCase__c> validZipClientCaseList = new List<ClientCase__c>(); 
        List<ClientCase__c> changedMonthlyIncomeCClist = new List<ClientCase__c>(); 

        if (IsNew) {
            for (ClientCase__c newCC : newClientCase) {
                if (newCC.Address__PostalCode__s != null && (newCC.County__c == null && newCC.Town__c == null)) {
                    zipCodes.add(newCC.Address__PostalCode__s);
                    validZipClientCaseList.add(newCC);
                } else {
                    String townCountyZipKey = 
                        (String.isBlank(newCC.Town__c) ? '' : newCC.Town__c) + '-' + 
                        (String.isBlank(newCC.County__c) ? '' : newCC.County__c) + '-' + 
                        (String.isBlank(newCC.Address__PostalCode__s) ? '' : newCC.Address__PostalCode__s);
                    townCountyZipKeys.add(townCountyZipKey);
                    validZipClientCaseList.add(newCC);  
                }
            }
            populateUniqueClientId(newClientCase);
            RecalculateIncome(newClientCase, false);
        } else {
            for (ClientCase__c newCC : newClientCase) {
                ClientCase__c oldCC = oldClientCase.get(newCC.Id);
                if (oldCC != null) {
                    if (newCC.Address__PostalCode__s != oldCC.Address__PostalCode__s) {
                        if (newCC.Town__c != oldCC.Town__c && newCC.County__c != oldCC.County__c) {
                            System.debug('With Zip code, town and county have also been updated');
                        } else {
                            zipCodes.add(newCC.Address__PostalCode__s);
                            validZipClientCaseList.add(newCC);  
                        }
                        System.debug('if zipCode Changes');
                    } else if (newCC.MonthlyIncome__c != oldCC.MonthlyIncome__c || newCC.HouseholdMonthlyIncome1__c != oldCC.HouseholdMonthlyIncome1__c || newCC.HouseholdSize__c != oldCC.HouseholdSize__c || newCC.County__c != oldCC.County__c || newCC.Town__c != oldCC.Town__c) {
                        String townCountyZipKey = 
                            (String.isBlank(newCC.Town__c) ? '' : newCC.Town__c) + '-' + 
                            (String.isBlank(newCC.County__c) ? '' : newCC.County__c) + '-' + 
                            (String.isBlank(newCC.Address__PostalCode__s) ? '' : newCC.Address__PostalCode__s);
                        townCountyZipKeys.add(townCountyZipKey);
                        validZipClientCaseList.add(newCC);  
                        System.debug('if else Other fields Changes');
                    }
                    if(newCC.MonthlyIncome__c != oldCC.MonthlyIncome__c )
                    {
                        changedMonthlyIncomeCClist.add(newCC);
                        // validZipClientCaseList.add(newCC);  
                    }
                }
            }
            if (!changedMonthlyIncomeCClist.isEmpty()) {
                RecalculateIncome(changedMonthlyIncomeCClist, false);
            }
        }
        
        List<HUDAMIData__c> hudamiRecordsByZip = new List<HUDAMIData__c>();
        List<HUDAMIData__c> hudamiRecordsByTownCountyZip = new List<HUDAMIData__c>();
        
        if (!zipCodes.isEmpty()) {
            hudamiRecordsByZip = Utility.getHUDAMIData(zipCodes, new Set<String>());
        }
        
        if (!townCountyZipKeys.isEmpty()) {
            hudamiRecordsByTownCountyZip = Utility.getHUDAMIData(new Set<String>(), townCountyZipKeys);
        }

        addToHudamiDataMap(hudamiDataMap, hudamiRecordsByZip);
        addToHudamiDataMap(hudamiDataMap, hudamiRecordsByTownCountyZip);

        if (!validZipClientCaseList.isEmpty()) {         
            newClientCase = validZipClientCaseList;      
        } else {                                     
            newClientCase = new List<ClientCase__c>();   
        }                                            

        for (ClientCase__c clientcase : newClientCase) {
            if (!hudamiDataMap.isEmpty()) {                  
                processIntakeRecord(clientcase, hudamiDataMap);  
            }                                                
            else {                                           
                clientcase.isInvalidZip__c = true;               
                // clientcase.EvaluateHUDAMI__c = false;            
                clientcase.County__c = null;                
                clientcase.Town__c = null;                  
                clientcase.MetropolitanStatisticalArea__c = null;  
                clientcase.AreaMedianIncome__c = null;            
                clientcase.DateAMILastCalculated__c = null;      
                clientcase.HouseholdOfAMI__c = null;             
                System.debug('Invalid Zip Code Entered');    
            }                                                
        }
    }
    
    /**
* @desc: Adds HUDAMIData__c records to the hudamiDataMap.
* @param hudamiDataMap: Map containing HUDAMIData__c records keyed by Zipcode and Town-County-Zip keys.
* @param records: List of HUDAMIData__c records to add to the map.
*/
    private static void addToHudamiDataMap(Map<String, List<HUDAMIData__c>> hudamiDataMap, List<HUDAMIData__c> records) {
        for (HUDAMIData__c hud : records) {
            String zipKey = hud.Zipcode__c;
            String townCountyZipKey = hud.TownName__c + '-' + hud.CountyName__c + '-' + hud.Zipcode__c;
            if (!hudamiDataMap.containsKey(zipKey)) {
                hudamiDataMap.put(zipKey, new List<HUDAMIData__c>());
            }
            hudamiDataMap.get(zipKey).add(hud);
            
            if (!hudamiDataMap.containsKey(townCountyZipKey)) {
                hudamiDataMap.put(townCountyZipKey, new List<HUDAMIData__c>());
            }
            hudamiDataMap.get(townCountyZipKey).add(hud);
        }
    }
    
    /**
* @desc: Processes each ClientCase__c record to determine if HUDAMI evaluation is required and updates fields accordingly.
* @param clientcase: ClientCase__c record to process.
* @param hudamiDataMap: Map containing HUDAMIData__c records keyed by Zipcode and Town-County-Zip keys.
*/
    private static void processIntakeRecord(ClientCase__c clientcase, Map<String, List<HUDAMIData__c>> hudamiDataMap) {
        String zipKey = clientcase.Address__PostalCode__s;
        String townCountyZipKey = (String.isBlank(clientcase.Town__c) ? '' : clientcase.Town__c) + '-' + 
            (String.isBlank(clientcase.County__c) ? '' : clientcase.County__c) + '-' + 
            (String.isBlank(clientcase.Address__PostalCode__s) ? '' : clientcase.Address__PostalCode__s);
        if (hudamiDataMap.containsKey(zipKey) && hudamiDataMap.get(zipKey).size() > 1) {
            clientcase.EvaluateHUDAMI__c = true;
            clientcase.isInvalidZip__c = false;      
            clientcase.County__c = null;
            clientcase.Town__c = null;
            clientcase.MetropolitanStatisticalArea__c = null;
            clientcase.AreaMedianIncome__c = null;
            clientcase.DateAMILastCalculated__c = null;
            clientcase.HouseholdOfAMI__c = null;
        } else if (hudamiDataMap.containsKey(zipKey) && hudamiDataMap.get(zipKey).size() == 1) {
            HUDAMIData__c hudRec = hudamiDataMap.get(zipKey)[0];
            updateIntakeRecord(clientcase, hudRec);
            clientcase.isInvalidZip__c = false;        
            clientcase.EvaluateHUDAMI__c = false;       
        } else if (hudamiDataMap.containsKey(townCountyZipKey)) {
            HUDAMIData__c hudRec = hudamiDataMap.get(townCountyZipKey)[0];
            updateIntakeRecord(clientcase, hudRec);
            clientcase.isInvalidZip__c = false;     
            clientcase.EvaluateHUDAMI__c = false;       
        }                                    
    }
    
    /**
* @desc: Updates ClientCase__c fields with HUDAMIData__c values.
* @param clientcase: ClientCase__c record to update.
* @param hudRec: HUDAMIData__c record containing data to update ClientCase__c.
*/
    private static void updateIntakeRecord(ClientCase__c clientcase, HUDAMIData__c hudRec) {
        Decimal annualHouseholdIncome = (clientcase.HouseholdMonthlyIncome1__c != null) ? (clientcase.HouseholdMonthlyIncome1__c * 12) : 0;
        Integer householdSize = (clientcase.HouseholdSize__c != null) ? clientcase.HouseholdSize__c.intValue() : 0;
        if(!clientcase.ChoseNottoProvideIncome__c){
            HUDAMICalculationService.HUDAMIServiceWrapper wrapper =
                HUDAMICalculationService.getHudAmiCalculatedWrapper(hudRec, householdSize, annualHouseholdIncome);
            
            if (String.isBlank(wrapper.error)) {
                clientcase.County__c = wrapper.countyName != null ? wrapper.countyName : '';
                clientcase.MetropolitanStatisticalArea__c = wrapper.metropolitanStatisticalArea != null ? wrapper.metropolitanStatisticalArea : '';
                clientcase.AreaMedianIncome__c = wrapper.areaMedianIncome != null ? wrapper.areaMedianIncome : '';
                //clientcase.AreaName__c = wrapper.areaname != null ? wrapper.areaname : ''; //fields needs to be created if required
                clientcase.Town__c = wrapper.townName != null ? wrapper.townName : '';
                //clientcase.Address__PostalCode__s = wrapper.zipcode != null ? wrapper.zipcode : '';
                //clientcase.Address__StateCode__s = wrapper.stateCode != null ? wrapper.stateCode : '';
                clientcase.DateAMILastCalculated__c = System.now();
                clientcase.HouseholdOfAMI__c = wrapper.householdOfAMI != null ? wrapper.householdOfAMI : 0.0;
            } else {
                System.debug('Error in wrapper: ' + wrapper.error);
            }
        }
    } 
    
/**
* @desc: Recalculate Household Monthly Income on intake
*/
    
    public static void RecalculateIncome(List<ClientCase__c> clientCases, Boolean isFromContact) {
        List<CoApplicant__c> coApplicants = [
            SELECT Id, IntakeRequest__c, ClientCase__c, Contact__r.TotalMonthlyIncome__c  
            FROM CoApplicant__c 
            WHERE ClientCase__c IN :clientCases
        ];
        
        Map<Id, Decimal> clientCaseToCoApplicantIncomeMap = new Map<Id, Decimal>();
        
        for (CoApplicant__c coApplicant : coApplicants) {
            if (coApplicant.ClientCase__c != null && coApplicant.Contact__r.TotalMonthlyIncome__c != null) {
                if (!clientCaseToCoApplicantIncomeMap.containsKey(coApplicant.ClientCase__c)) {
                    clientCaseToCoApplicantIncomeMap.put(coApplicant.ClientCase__c, 0);
                }
                clientCaseToCoApplicantIncomeMap.put(coApplicant.ClientCase__c, 
                                                     clientCaseToCoApplicantIncomeMap.get(coApplicant.ClientCase__c) + coApplicant.Contact__r.TotalMonthlyIncome__c );
            } else {
                System.debug('CoApplicant or Monthly Income is null for Id: ' + coApplicant.Id);
            }
        }
                
        for (ClientCase__c cc : clientCases) {
            Decimal totalIncome = 0;
            if (cc.MonthlyIncome__c != null) {
                totalIncome += cc.MonthlyIncome__c;
            }
            
            if (clientCaseToCoApplicantIncomeMap.containsKey(cc.Id)) {
                totalIncome += clientCaseToCoApplicantIncomeMap.get(cc.Id);
            }

            cc.HouseholdMonthlyIncome1__c = (totalIncome > 0 ? totalIncome : null);
        }

        if (isFromContact == true) {
            update clientCases;
        }
    }
}