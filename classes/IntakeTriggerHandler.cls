/**
* @desc: Handler class for Intake__c triggers to manage field population and automation logic.
*/
public inherited sharing class IntakeTriggerHandler {
    
    /**
* @desc: Handles the logic before inserting new Intake__c records.
* @param newIntakeList: List of new Intake__c records being inserted.
*/
    public static void beforeInsert(List<Intake__c> newIntakeList) {
        populateFieldsOnIntake(newIntakeList, New Map<Id, Intake__c>(), true);
    }
    
    /**
* @desc: Handles the logic before updating existing Intake__c records.
* @param newIntakeList: List of new Intake__c records being updated.
* @param oldIntakeMap: Map of old Intake__c records being updated.
*/
    public static void beforeUpdate(List<Intake__c> newIntakeList, Map<Id, Intake__c> oldIntakeMap) {
        try {
            populateFieldsOnIntake(newIntakeList, oldIntakeMap, false);
        } catch (Exception e) {
            System.debug('IntakeTriggerHandler Error in beforeUpdate: ' + e.getMessage());
        }
    }
    
    /**
* @desc: Populates fields on Intake__c records based on HUDAMI data.
* @param newIntakeList: List of new Intake__c records.
* @param oldIntakeMap: Map of old Intake__c records.
* @param isNew: Boolean indicating if the records are new.
*/
    public static void populateFieldsOnIntake(List<Intake__c> newIntakeList, Map<Id, Intake__c> oldIntakeMap, Boolean isNew) {
        Map<String, List<HUDAMIData__c>> hudamiDataMap = new Map<String, List<HUDAMIData__c>>();
        Set<String> zipCodes = new Set<String>();
        Set<String> townCountyZipKeys = new Set<String>();

        List<Intake__c> validZipIntakeList = new List<Intake__c>(); 
        List<Intake__c> changedMonthlyIncomeIntakelist = new List<Intake__c>();
        
        if (isNew) {
            for (Intake__c newIntake : newIntakeList) {
                newIntake.IntakeDate__c = Date.today();
                if (newIntake.Address__PostalCode__s != null && (newIntake.County__c == null && newIntake.Town__c == null)) {
                    zipCodes.add(newIntake.Address__PostalCode__s);
                    validZipIntakeList.add(newIntake);
                } else {
                    String townCountyZipKey = 
                    (String.isBlank(newIntake.Town__c) ? '' : newIntake.Town__c) + '-' + 
                    (String.isBlank(newIntake.County__c) ? '' : newIntake.County__c) + '-' + 
                    (String.isBlank(newIntake.Address__PostalCode__s) ? '' : newIntake.Address__PostalCode__s);
                    townCountyZipKeys.add(townCountyZipKey);
                    validZipIntakeList.add(newIntake);
                }
            }
            RecalculateIncome(newIntakeList, false);
        }
        else {
            for (Intake__c newIntake : newIntakeList) {
                Intake__c oldIntake = oldIntakeMap.get(newIntake.Id);
                if (oldIntake != null) {
                    if (newIntake.Address__PostalCode__s != oldIntake.Address__PostalCode__s) {
                        if (newIntake.Town__c != oldIntake.Town__c && newIntake.County__c != oldIntake.County__c) {
                            // Handle logic if both town and county changed.
                        } else {
                            zipCodes.add(newIntake.Address__PostalCode__s);
                            validZipIntakeList.add(newIntake);  
                        }
                    } else if (newIntake.HouseholdMonthlyIncome__c != oldIntake.HouseholdMonthlyIncome__c ||
                               newIntake.MonthlyIncome__c != oldIntake.MonthlyIncome__c ||
                               newIntake.HouseholdSize__c != oldIntake.HouseholdSize__c ||
                               newIntake.County__c != oldIntake.County__c ||
                               newIntake.Town__c != oldIntake.Town__c) {
                                   String townCountyZipKey = 
                                       (String.isBlank(newIntake.Town__c) ? '' : newIntake.Town__c) + '-' + 
                                       (String.isBlank(newIntake.County__c) ? '' : newIntake.County__c) + '-' + 
                                       (String.isBlank(newIntake.Address__PostalCode__s) ? '' : newIntake.Address__PostalCode__s);
                                   townCountyZipKeys.add(townCountyZipKey);
                                   validZipIntakeList.add(newIntake);  
                               }
                    if(newIntake.MonthlyIncome__c != oldIntake.MonthlyIncome__c )
                    {
                        changedMonthlyIncomeIntakelist.add(newIntake);
                    }
                }
            }
            if (!changedMonthlyIncomeIntakelist.isEmpty()) {
                RecalculateIncome(changedMonthlyIncomeIntakelist, false);
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

        if (!validZipIntakeList.isEmpty()) {         
            newIntakeList = validZipIntakeList;      
        } else {                                     
            newIntakeList = new List<Intake__c>();   
        }                                            
        
        for (Intake__c intake : newIntakeList) {
            if (!hudamiDataMap.isEmpty()) {
                processIntakeRecord(intake, hudamiDataMap);
            }                                                
            else {                                           
                intake.isInvalidZip__c = true;               
                // intake.EvaluateHUDAMI__c = false;            
                intake.County__c = null;                
                intake.Town__c = null;                  
                intake.MetropolitanStatisticalArea__c = null;  
                intake.AreaMedianIncome__c = null;            
                intake.DateAMILastCalculated__c = null;      
                intake.HouseholdOfAMI__c = null;             
                System.debug('IntakeTriggerHandler: Invalid Zip Code Entered');    
            }                                                
        }
    }
    
    /**
* @desc: Adds HUDAMI data records to the HUDAMI data map.
* @param hudamiDataMap: Map of HUDAMI data grouped by keys.
* @param records: List of HUDAMI data records to add to the map.
*/
    private static void addToHudamiDataMap(Map<String, List<HUDAMIData__c>> hudamiDataMap, List<HUDAMIData__c> records) {
        for (HUDAMIData__c hud : records) {
            String zipKey = hud.Zipcode__c;
            
            if (!hudamiDataMap.containsKey(zipKey)) {
                hudamiDataMap.put(zipKey, new List<HUDAMIData__c>());
            }
            hudamiDataMap.get(zipKey).add(hud);
            
            if (!hudamiDataMap.containsKey(hud.UniqueKey__c)) {
                hudamiDataMap.put(hud.UniqueKey__c, new List<HUDAMIData__c>());
            }
            hudamiDataMap.get(hud.UniqueKey__c).add(hud);
        }
    }
    
    /**
* @desc: Processes an Intake__c record to populate fields based on HUDAMI data.
* @param intake: The Intake__c record to process.
* @param hudamiDataMap: Map of HUDAMI data grouped by keys.
*/
    private static void processIntakeRecord(Intake__c intake, Map<String, List<HUDAMIData__c>> hudamiDataMap) {
        String zipKey = intake.Address__PostalCode__s;
        String townCountyZipKey = (String.isBlank(intake.Town__c) ? '' : intake.Town__c) + '-' + 
            (String.isBlank(intake.County__c) ? '' : intake.County__c) + '-' + 
            (String.isBlank(intake.Address__PostalCode__s) ? '' : intake.Address__PostalCode__s);

        if (hudamiDataMap.containsKey(zipKey) && hudamiDataMap.get(zipKey).size() > 1) {
            intake.EvaluateHUDAMI__c = true;
            intake.isInvalidZip__c = false;           
            intake.County__c = null;
            intake.Town__c = null;
            intake.MetropolitanStatisticalArea__c = null;
            intake.AreaMedianIncome__c = null;
            intake.DateAMILastCalculated__c = null;
            intake.HouseholdOfAMI__c = null;
        } else if (hudamiDataMap.containsKey(zipKey) && hudamiDataMap.get(zipKey).size() == 1) {
            HUDAMIData__c hudRec = hudamiDataMap.get(zipKey)[0];
            updateIntakeRecord(intake, hudRec);
            intake.EvaluateHUDAMI__c = false;
            intake.isInvalidZip__c = false;        
        } else if (hudamiDataMap.containsKey(townCountyZipKey)) {
            HUDAMIData__c hudRec = hudamiDataMap.get(townCountyZipKey)[0];
            updateIntakeRecord(intake, hudRec);
            intake.EvaluateHUDAMI__c = false;
            intake.isInvalidZip__c = false;         
        } 
        else {                                      
            intake.isInvalidZip__c = true;          
            // intake.EvaluateHUDAMI__c = false;       
        }                                           
    }
    
    /**
* @desc: Updates an Intake__c record with data from a HUDAMIData__c record.
* @param intake: The Intake__c record to update.
* @param hudRec: The HUDAMIData__c record containing the data.
*/
    private static void updateIntakeRecord(Intake__c intake, HUDAMIData__c hudRec) {
        Decimal annualHouseholdIncome = (intake.HouseholdMonthlyIncome__c != null) ? (intake.HouseholdMonthlyIncome__c  * 12): 0;
        Integer householdSize = (intake.HouseholdSize__c != null) ? intake.HouseholdSize__c.intValue() : 0;
        if(!intake.ChoseNottoProvideIncome__c){
            HUDAMICalculationService.HUDAMIServiceWrapper wrapper =
                HUDAMICalculationService.getHudAmiCalculatedWrapper(hudRec, householdSize, annualHouseholdIncome);
            
            if (String.isBlank(wrapper.error)) {
                intake.County__c = wrapper.countyName != null ? wrapper.countyName : '';
                intake.MetropolitanStatisticalArea__c = wrapper.metropolitanStatisticalArea != null ? wrapper.metropolitanStatisticalArea : '';
                intake.AreaMedianIncome__c = wrapper.areaMedianIncome != null ? wrapper.areaMedianIncome : '';
                //intake.AreaName__c = wrapper.areaname != null ? wrapper.areaname : ''; // Field needs to be created if required
                intake.Town__c = wrapper.townName != null ? wrapper.townName : '';
                //intake.Address__PostalCode__s = wrapper.zipcode != null ? wrapper.zipcode : '';
                //intake.Address__StateCode__s = wrapper.stateCode != null ? wrapper.stateCode : '';
                intake.DateAMILastCalculated__c = System.now();
                intake.HouseholdOfAMI__c = wrapper.householdOfAMI != null ? wrapper.householdOfAMI : 0.0;
            } else {
                System.debug('IntakeTriggerHandler: Error in wrapper: ' + wrapper.error);
            }
        }
    } 
    
    
/**
* @desc: Recalculate Household Monthly Income on intake
*/
    
    public static void RecalculateIncome(List<Intake__c> intakes, Boolean isFromContact) {

        List<CoApplicant__c> coApplicants = [
            SELECT Id, IntakeRequest__c, Contact__r.TotalMonthlyIncome__c 
            FROM CoApplicant__c 
            WHERE IntakeRequest__c IN :intakes
        ];
        
        Map<Id, Decimal> intakeToCoApplicantIncomeMap = new Map<Id, Decimal>();
        for (CoApplicant__c coApplicant : coApplicants) {
            if (coApplicant.IntakeRequest__c != null && coApplicant.Contact__r.TotalMonthlyIncome__c != null) {
                if (!intakeToCoApplicantIncomeMap.containsKey(coApplicant.IntakeRequest__c)) {
                    intakeToCoApplicantIncomeMap.put(coApplicant.IntakeRequest__c, 0);
                }
                intakeToCoApplicantIncomeMap.put(coApplicant.IntakeRequest__c, 
                                                 intakeToCoApplicantIncomeMap.get(coApplicant.IntakeRequest__c) + coApplicant.Contact__r.TotalMonthlyIncome__c);
            } else {
                System.debug('IntakeTriggerHandler: CoApplicant or Monthly Income is null for Id: ' + coApplicant.Id);
            }
        }
        
        for (Intake__c intake : intakes) {
            if(!intake.ChoseNottoProvideIncome__c){
                Decimal totalIncome = 0;
                
                if (intake.MonthlyIncome__c != null) {
                    totalIncome += intake.MonthlyIncome__c;
                }
                
                if (intakeToCoApplicantIncomeMap.containsKey(intake.Id)) {
                    totalIncome += intakeToCoApplicantIncomeMap.get(intake.Id);
                }
                intake.HouseholdMonthlyIncome__c = (totalIncome > 0 ? totalIncome : null);
            }
        }
        if (isFromContact == true) {
            update intakes;
        }
    }
    
}