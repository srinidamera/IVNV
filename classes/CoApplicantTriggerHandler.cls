/**
* Handler class for CoApplicant trigger.
*/
public class CoApplicantTriggerHandler {
    
    /**
* @desc:Handles after insert trigger events for CoApplicant__c.
*/
    public static void afterInsert(List<CoApplicant__c> newCoApplicants) {
        calculateHouseholdIncome(newCoApplicants, null);
    }
    
    /**
* @desc:Handles after update trigger events for CoApplicant__c.
*/
    public static void afterDelete(List<CoApplicant__c> newCoApplicants, Map<Id, CoApplicant__c> oldCoApplicants) {
        calculateHouseholdIncome(newCoApplicants, oldCoApplicants);
    }
    
    /**
* @desc:Handles after update trigger events for CoApplicant__c.
*/
    public static void afterUpdate(List<CoApplicant__c> newCoApplicants, Map<Id, CoApplicant__c> oldCoApplicants) {
        calculateHouseholdIncome(newCoApplicants, null);
    }

/**
* Calculates household income for CoApplicants.
*/
    public static void calculateHouseholdIncome(List<CoApplicant__c> newCoApplicants, Map<Id, CoApplicant__c> oldCoApplicantsMap) {
        Set<Id> intakeIds = new Set<Id>();
        Set<Id> clientCaseIds = new Set<Id>();
        
        if (oldCoApplicantsMap == null) {
            for (CoApplicant__c coApplicant : newCoApplicants) {
                
                if (coApplicant.IntakeRequest__c != null) {
                    intakeIds.add(coApplicant.IntakeRequest__c);
                }
                if (coApplicant.ClientCase__c != null) {
                    clientCaseIds.add(coApplicant.ClientCase__c);
                }
            }
        }
        else
        {
            for (Id oldCoApplicantId : oldCoApplicantsMap.keySet()) {
                
                
                CoApplicant__c oldCoApplicant = oldCoApplicantsMap.get(oldCoApplicantId);
                
                if (oldCoApplicant.IntakeRequest__c != null) {
                    intakeIds.add(oldCoApplicant.IntakeRequest__c);
                }
                if (oldCoApplicant.ClientCase__c != null) {
                    clientCaseIds.add(oldCoApplicant.ClientCase__c);
                }
            }
        } 
        
        
        if (!intakeIds.isEmpty()) {
            List<CoApplicant__c> coApplicants = [
                SELECT Id, IntakeRequest__c, Contact__r.TotalMonthlyIncome__c 
                FROM CoApplicant__c 
                WHERE IntakeRequest__c IN :intakeIds
            ];
            
            Map<Id, Decimal> intakeToCoApplicantIncomeMap = new Map<Id, Decimal>();
            for (CoApplicant__c coApplicant : coApplicants) {
                if (coApplicant.IntakeRequest__c != null && coApplicant.Contact__r.TotalMonthlyIncome__c != null) {
                    if (!intakeToCoApplicantIncomeMap.containsKey(coApplicant.IntakeRequest__c)) {
                        intakeToCoApplicantIncomeMap.put(coApplicant.IntakeRequest__c, 0);
                    }
                    intakeToCoApplicantIncomeMap.put(coApplicant.IntakeRequest__c, 
                                                     intakeToCoApplicantIncomeMap.get(coApplicant.IntakeRequest__c) + coApplicant.Contact__r.TotalMonthlyIncome__c );
                } else {
                    System.debug('CoApplicant or Monthly Income is null for Id @%@: ' + coApplicant.Id);
                }
            }
            
            
            List<Intake__c> intakes = [
                SELECT Id, MonthlyIncome__c, HouseholdMonthlyIncome__c , primaryClient__r.TotalMonthlyIncome__c, ChoseNottoProvideIncome__c
                FROM Intake__c 
                WHERE Id IN :intakeIds
            ];
            
            List<Intake__c> intakesToUpdate = new List<Intake__c>();
            for (Intake__c intake : intakes) {
                Decimal totalIncome = 0;
                if(!intake.ChoseNottoProvideIncome__c){
                    if (intake.MonthlyIncome__c != null) {
                        totalIncome += intake.MonthlyIncome__c;
                    }
                    
                    if (intakeToCoApplicantIncomeMap.containsKey(intake.Id)) {
                        totalIncome += intakeToCoApplicantIncomeMap.get(intake.Id);
                    }
                }                
                intake.HouseholdMonthlyIncome__c = (totalIncome > 0 ? totalIncome : null);
                intakesToUpdate.add(intake);
            }
            if (!intakesToUpdate.isEmpty()) {
                update intakesToUpdate;
            }
        }
        
        if (!clientCaseIds.isEmpty()) {
            List<CoApplicant__c> coApplicants = [
                SELECT Id, IntakeRequest__c, ClientCase__c, Contact__r.TotalMonthlyIncome__c  
                FROM CoApplicant__c 
                WHERE ClientCase__c IN :clientCaseIds
            ];
            System.debug('coApplicants. @%@ '+coApplicants);
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
            System.debug('clientCaseToCoApplicantIncomeMap @%@ '+clientCaseToCoApplicantIncomeMap);

            List<ClientCase__c> CCToUpdate = [
                SELECT Id, AnnualHouseholdIncome__c, MonthlyIncome__c,HouseholdMonthlyIncome1__c, HouseholdSize__c, County__c, Town__c, PrimaryClient__r.TotalMonthlyIncome__c, ChoseNottoProvideIncome__c
                FROM ClientCase__c
                WHERE Id IN :clientCaseIds
            ];
            
            List<ClientCase__c> clientCasesToUpdate = new List<ClientCase__c>();
            for (ClientCase__c cc : CCToUpdate) {
                Decimal totalIncome = 0;
                if(!cc.ChoseNottoProvideIncome__c){
                    if (cc.MonthlyIncome__c != null) {
                        totalIncome += cc.MonthlyIncome__c;
                    }
                    
                    if (clientCaseToCoApplicantIncomeMap.containsKey(cc.Id)) {
                        totalIncome += clientCaseToCoApplicantIncomeMap.get(cc.Id);
                    }
                }
                cc.HouseholdMonthlyIncome1__c = (totalIncome > 0 ? totalIncome : null);
                clientCasesToUpdate.add(cc);
            }
            
            if (!clientCasesToUpdate.isEmpty()) {
                update clientCasesToUpdate;
            }
        }
    }
}