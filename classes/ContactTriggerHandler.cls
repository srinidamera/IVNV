/**
 * @desc: ContactTriggerHandler is used to handle trigger events for Contact objects.
 */
public inherited sharing class ContactTriggerHandler {
    static Id coappRecTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName()
        .get('CoApplicant')
        .getRecordTypeId();
    static Id primaryClientRecTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName()
        .get('PrimaryClient')
        .getRecordTypeId();
    static Id prospectRecTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName()
        .get('Prospect')
        .getRecordTypeId();
    public static Map<String, Set<Id>> recursiveMap = new Map<String, Set<Id>>();
    public static Map<Id, Contact> contactToUpdateMap = new Map<Id, Contact>();
    public static boolean flag = true;
    public static boolean isInvalidKey = false;
    public static Set<String> ZipKeys = new Set<String>();

    
    /**
     * @desc:Handles before insert trigger events for Contact.
     */
    public static void beforeInsert(List<Contact> newContactList) {
        for(Contact con:newContactList){
            if(String.isNotBlank(con.SSN__c)){
                con.cic_credit__SSN__c = con.SSN__c;
            }
        }
    }
    
    /**
     * @desc:Handles before update trigger events for Contact.
     */
    public static void beforeUpdate(List<Contact> newContactList, Map<Id, Contact> oldContactMap) {
        for(Contact con:newContactList){
            if(String.isNotBlank(con.SSN__c) && con.SSN__c != oldContactMap.get(con.Id).SSN__c){
                con.cic_credit__SSN__c = con.SSN__c;
            }
        }
    }
    
    /**
     * @desc:Handles after insert trigger events for Contact.
     */
    public static void afterInsert(List<Contact> newContactList) {
        processContacts(getAccountsToRecomputeHudAmi(newContactList, null));
    }

    /**
     * @desc:Handles after update trigger events for Contact.
     */
    public static void afterUpdate(
        List<Contact> newContactList,
        Map<Id, Contact> oldContactMap
    ) {
        calculateHouseholdIncome(newContactList, oldContactMap);
        processContacts(
            getAccountsToRecomputeHudAmi(newContactList, oldContactMap)
        );
    }

    /**
     * @desc:Calculate Household Income of Intake/ClientCase for co-applicants.
     */
    private static void calculateHouseholdIncome(
        List<Contact> newContactList,
        Map<Id, Contact> oldContactMap
    ) {
        List<CoApplicant__c> coAppList = new List<CoApplicant__c>();
        Set<Id> conIds = new Set<Id>();
        for (Contact newCon : newContactList) {
            Contact oldCon = oldContactMap.get(newCon.Id);
            if (newCon.RecordTypeId == coappRecTypeId && newCon.TotalMonthlyIncome__c != oldCon.TotalMonthlyIncome__c) {
                conIds.add(newCon.Id);
            }
        }

        Set<Id> clientCaseIds = new Set<Id>();
        Set<Id> intakeIds = new Set<Id>();

        if (conIds.size() > 0) {
            coAppList = [
                SELECT Id, ClientCase__c, Contact__c, IntakeRequest__c
                FROM CoApplicant__c
                WHERE Contact__c IN :conIds WITH SECURITY_ENFORCED
            ];

            for (CoApplicant__c coApp : coAppList) {
                if (coApp.IntakeRequest__c != null) {
                    intakeIds.add(coApp.IntakeRequest__c);
                }
                if (coApp.ClientCase__c != null) {
                    clientCaseIds.add(coApp.ClientCase__c);
                }
            }

            List<Intake__c> intakeList = new List<Intake__c>();
            List<ClientCase__c> clientCaseList = new List<ClientCase__c>();
            intakeList = [SELECT Id, MonthlyIncome__c, HouseholdMonthlyIncome__c FROM Intake__c WHERE Id IN :intakeIds AND Status__c = 'Open Intake' WITH SECURITY_ENFORCED];

            if (!intakeList.isEmpty()) {
                IntakeTriggerHandler.RecalculateIncome(intakeList, true);
            }
            
            clientCaseList = [SELECT Id, MonthlyIncome__c, HouseholdMonthlyIncome1__c FROM ClientCase__c WHERE Id IN :clientCaseIds AND ClientCaseStatus__c = 'In Progress' WITH SECURITY_ENFORCED];
            
            if (!clientCaseList.isEmpty()) {
                ClientCaseTriggerHandler.RecalculateIncome(clientCaseList, true);
            }
        }
    }

    /**
     * @desc:Gets accounts to recompute HUD AMI.
     */
    private static Set<Id> getAccountsToRecomputeHudAmi(
        List<Contact> newContactList,
        Map<Id, Contact> oldContactMap
    ) {
        Set<Id> accIdSet = new Set<Id>();

        for (Contact newCon : newContactList) {
            if (oldContactMap == null) {
                if (
                    (newCon.RecordTypeId == coappRecTypeId ||
                    newCon.RecordTypeId == primaryClientRecTypeId ||
                    newCon.RecordTypeId == prospectRecTypeId) && (newCon.MailingPostalCode != null || newCon.County__c != null || newCon.Town__c != null || newCon.TotalMonthlyIncome__c > 0)
                ) {
                    System.debug('newCon.MailingPostalCode GuestUser 130 '+newCon.MailingPostalCode);
                    System.debug('newCon.CorrespondingPortalUser__c GuestUser 130 '+newCon.CorrespondingPortalUser__c);
                    if (newCon.MailingPostalCode != null && (newCon.County__c == null && newCon.Town__c == null) && (newCon.RecordTypeId == primaryClientRecTypeId ||
                    newCon.RecordTypeId == prospectRecTypeId)) {
                        System.debug('newCon.MailingPostalCode GuestUser 133 '+newCon.MailingPostalCode);
                        ZipKeys.add(newCon.MailingPostalCode);
                    }
                    accIdSet.add(newCon.AccountId);
                }
            } else {
                Contact oldCon = oldContactMap.get(newCon.Id);
                if (newCon.RecordTypeId == coappRecTypeId) {
                    if (newCon.MailingPostalCode != oldCon.MailingPostalCode) {
                        System.debug('newCon change zip GuestUser 141'+newCon);
                        accIdSet.add(newCon.AccountId);
                        ZipKeys.add(newCon.MailingPostalCode);
                    } else if (
                        newCon.isActive__c != oldCon.isActive__c ||
                        newCon.AccountId != oldCon.AccountId ||
                        newCon.TotalMonthlyIncome__c !=
                        oldCon.TotalMonthlyIncome__c
                    ) {
                        System.debug('newCon GuestUser 150'+newCon);
                        accIdSet.add(newCon.AccountId);
                        accIdSet.add(oldCon.AccountId);
                    }
                } else if (newCon.RecordTypeId == primaryClientRecTypeId || newCon.RecordTypeId == prospectRecTypeId) {
                    if (newCon.MailingPostalCode != oldCon.MailingPostalCode) {
                        System.debug('newCon change zip GuestUser 157'+newCon);
                        accIdSet.add(newCon.AccountId);
                        ZipKeys.add(newCon.MailingPostalCode);
                    } else if (
                        // newCon.RecordTypeId != oldCon.RecordTypeId ||
                        newCon.County__c != oldCon.County__c ||
                        newCon.AccountId != oldCon.AccountId ||
                        newCon.HouseholdMonthlyIncome1__c !=
                        oldCon.HouseholdMonthlyIncome1__c ||
                        newCon.Town__c != oldCon.Town__c ||
                        newCon.HouseholdSize__c != oldCon.HouseholdSize__c ||
                        newCon.AnnualHouseholdIncome__c !=
                        oldCon.AnnualHouseholdIncome__c ||
                        newCon.TotalMonthlyIncome__c !=
                        oldCon.TotalMonthlyIncome__c
                    ) {
                        accIdSet.add(newCon.AccountId);
                        accIdSet.add(oldCon.AccountId);
                        isInvalidKey = true;
                    }
                }
            }
        }
        return accIdSet;
    }

    /**
     * @desc:Processes the given set of account IDs.
     */
    private static void processContacts(Set<Id> accountIds) {
        if (accountIds.isEmpty()) {
            return;
        }
        System.debug('accountIds GuestUser '+accountIds);
        Map<Id, List<Contact>> accountToListOfCoAppMap = new Map<Id, List<Contact>>();
        Map<Id, Contact> accountToPrimaryContactMap = new Map<Id, Contact>();

        List<Contact> allContacts = [
            SELECT
                Id,
                TotalMonthlyIncome__c,
                County__c,
                Town__c,
                HouseholdSize__c,
                AccountId,
                RecordTypeId,
                MailingPostalCode,
                ChoseNottoProvideIncome__c 
            FROM Contact
            WHERE
                AccountId IN :accountIds
                AND ((RecordTypeId = :coappRecTypeId
                AND isActive__c = TRUE)
                OR RecordTypeId = :primaryClientRecTypeId
                OR RecordTypeId = :prospectRecTypeId)
                WITH SECURITY_ENFORCED
        ];

        Set<String> townCountyZipKeys = new Set<String>();
        System.debug('allContacts GuestUser '+allContacts);

        for (Contact con : allContacts) {
            if (
                con.RecordTypeId == primaryClientRecTypeId ||
                con.RecordTypeId == prospectRecTypeId
            ) {
                accountToPrimaryContactMap.put(con.AccountId, con);
            } else {
                if (!accountToListOfCoAppMap.containsKey(con.AccountId)) {
                    accountToListOfCoAppMap.put(
                        con.AccountId,
                        new List<Contact>()
                    );
                }
                accountToListOfCoAppMap.get(con.AccountId).add(con);
            }

            String townCountyZipKey =
                (String.isBlank(con.Town__c) ? '' : con.Town__c) +
                '-' +
                (String.isBlank(con.County__c) ? '' : con.County__c) +
                '-' +
                (String.isBlank(con.MailingPostalCode)
                    ? ''
                    : con.MailingPostalCode);
            townCountyZipKeys.add(townCountyZipKey);
        }

        Map<String, List<HUDAMIData__c>> hudamiDataMap = new Map<String, List<HUDAMIData__c>>();
        if (!ZipKeys.isEmpty()) {
            List<HUDAMIData__c> zipKeyHudamiRecords = Utility.getHUDAMIData(ZipKeys, new Set<String>());

            for (HUDAMIData__c hud : zipKeyHudamiRecords) {
                String key = hud.Zipcode__c;

                if (!hudamiDataMap.containsKey(key)) {
                    hudamiDataMap.put(key, new List<HUDAMIData__c>());
                }
                hudamiDataMap.get(key).add(hud);
            }
        }
        System.debug('townCountyZipKeys GuestUser '+townCountyZipKeys);

        if (!townCountyZipKeys.isEmpty()) {
            List<HUDAMIData__c> townCountyZipKeyHudamiRecords = Utility.getHUDAMIData(new Set<String>(), townCountyZipKeys);

            for (HUDAMIData__c hud : townCountyZipKeyHudamiRecords) {
                    String key =
                    (String.isBlank(hud.TownName__c) ? '' : hud.TownName__c) + '-' + 
                            (String.isBlank(hud.CountyName__c) ? '' : hud.CountyName__c) + '-' + 
                            (String.isBlank(hud.Zipcode__c) ? '' : hud.Zipcode__c);
                if (!hudamiDataMap.containsKey(key)) {
                    hudamiDataMap.put(key, new List<HUDAMIData__c>());
                }
                hudamiDataMap.get(key).add(hud);
            }
        }

        for (Id accId : accountIds) {
            Double totalIncome = 0;
            if (accountToListOfCoAppMap.containsKey(accId)) {
                for (Contact con : accountToListOfCoAppMap.get(accId)) {
                    if(con.TotalMonthlyIncome__c != NULL){
                        totalIncome += con.TotalMonthlyIncome__c;
                    }
                }
            }

            Contact primaryCon = accountToPrimaryContactMap.get(accId);
            System.debug('primaryCon GuestUser '+primaryCon);
            if (primaryCon != null) {
                totalIncome += primaryCon.TotalMonthlyIncome__c != null ? primaryCon.TotalMonthlyIncome__c : 0;
                primaryCon.HouseholdMonthlyIncome1__c = (totalIncome > 0 ? totalIncome : null);
                contactToUpdateMap.put(primaryCon.Id, primaryCon);
            }
            // System.debug('primaryCon.HouseholdMonthlyIncome1__c GuestUser '+primaryCon.HouseholdMonthlyIncome1__c);

            if (
                primaryCon != null &&
                primaryCon.HouseholdSize__c != null
            ) {
                String countyTownZipKey =
                    (String.isBlank(primaryCon.Town__c)
                        ? ''
                        : primaryCon.Town__c) +
                    '-' +
                    (String.isBlank(primaryCon.County__c)
                        ? ''
                        : primaryCon.County__c) +
                    '-' +
                    (String.isBlank(primaryCon.MailingPostalCode)
                        ? ''
                        : primaryCon.MailingPostalCode);

                String zipKey = primaryCon.MailingPostalCode;
                if (hudamiDataMap.containsKey(zipKey)) {
                    List<HUDAMIData__c> hudamiRecords = hudamiDataMap.get(
                        zipKey
                    );
                    processHUDAMIData(primaryCon, hudamiRecords);
                } else if (hudamiDataMap.containsKey(countyTownZipKey)) {
                    List<HUDAMIData__c> hudamiRecords = hudamiDataMap.get(
                        countyTownZipKey
                    );
                    processHUDAMIData(primaryCon, hudamiRecords);
                } else {
                    System.debug(
                        '#Contact No HUD AMI Records found for ZIP or County-Town-ZIP combination'
                    );
                    // primaryCon.EvaluateHUDAMI__c = false;
                    if (isInvalidKey == false) {
                        primaryCon.isInvalidZip__c = true;
                        primaryCon.County__c = null;
                        primaryCon.Town__c = null;
                        primaryCon.MetropolitanStatisticalArea__c = null;
                        primaryCon.AreaMedianIncome__c = null;
                        primaryCon.DateAMILastCalculated__c = null;
                        primaryCon.HouseholdOfAMI__c = null;
                    }
                }
            }

            if (!contactToUpdateMap.isEmpty()) {
                Database.SaveResult[] updateResults = Database.update(
                    contactToUpdateMap.values(),
                    false
                );
                for (Database.SaveResult sr : updateResults) {
                    if (!sr.isSuccess()) {
                        for (Database.Error err : sr.getErrors()) {
                            EventLog__e l = new EventLog__e();
                            l.ExceptionMessage__c = err.getMessage();
                            EventBus.publish(l);
                            System.debug(
                                'Error updating Contact: ' +
                                    err.getStatusCode() +
                                    ': ' +
                                    err.getMessage()
                            );
                        }
                    }
                }
            }
        }
    }

    /**
     * @desc:Processes HUD AMI data for the given contact.
     */
    private static void processHUDAMIData(
        Contact primaryCon,
        List<HUDAMIData__c> hudamiRecords
    ) {
        List<Contact> contactsToUpdate = new List<Contact>();
        if(!primaryCon.ChoseNottoProvideIncome__c){
            if (hudamiRecords.size() > 1) {
                primaryCon.EvaluateHUDAMI__c = true;
                primaryCon.isInvalidZip__c = false;
                primaryCon.County__c = null;
                primaryCon.Town__c = null;
                primaryCon.MetropolitanStatisticalArea__c = null;
                primaryCon.AreaMedianIncome__c = null;
                primaryCon.DateAMILastCalculated__c = null;
                primaryCon.HouseholdOfAMI__c = null;
            } else {
                HUDAMIData__c hudamiRecord = hudamiRecords[0];
    
                HUDAMICalculationService.HUDAMIServiceWrapper wrapper = new HUDAMICalculationService.HUDAMIServiceWrapper();
    
    		if(primaryCon.HouseholdMonthlyIncome1__c != null){    
                wrapper = HUDAMICalculationService.getHudAmiCalculatedWrapper(
                    hudamiRecord,
                    (Integer) primaryCon.HouseholdSize__c,
                    Math.round(primaryCon.HouseholdMonthlyIncome1__c * 12)
                );
            } 
                System.debug('String.isBlank(wrapper.error) '+ wrapper.error);
                if (String.isBlank(wrapper.error)) {
                    primaryCon.County__c = wrapper.countyName != null
                        ? wrapper.countyName
                        : '';
                    primaryCon.MetropolitanStatisticalArea__c = wrapper.metropolitanStatisticalArea !=
                        null
                        ? wrapper.metropolitanStatisticalArea
                        : '';
                    primaryCon.AreaMedianIncome__c = wrapper.areaMedianIncome !=
                        null
                        ? wrapper.areaMedianIncome
                        : '';
                    primaryCon.Town__c = wrapper.townName != null
                        ? wrapper.townName
                        : '';
                    primaryCon.DateAMILastCalculated__c = wrapper.aMILastCalculatedDate !=
                        null
                        ? wrapper.aMILastCalculatedDate
                        : null;
                    primaryCon.EvaluateHUDAMI__c = false;
                    primaryCon.isInvalidZip__c = false;
                    primaryCon.HouseholdOfAMI__c = wrapper.householdOfAMI != null
                        ? wrapper.householdOfAMI
                        : 0.0;
                }
            }
            contactToUpdateMap.put(primaryCon.Id, primaryCon);
        }
    }
}