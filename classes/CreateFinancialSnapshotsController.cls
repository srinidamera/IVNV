/**
 * @description       : Controller Class for CreateFinancialSnapshot  & ClientFinancialMetrics Component.
 **/
public with sharing class CreateFinancialSnapshotsController {

    /**
     * @description       : Get Current Values.
    **/
    @AuraEnabled
    public static FinancialSnapshotWrapper getCurrentValues(String clientCaseId) {

        System.debug('clientCaseId 6 '+clientCaseId);
        FinancialSnapshotWrapper wrapper = new FinancialSnapshotWrapper();

        ClientCase__c clientCaseRec = [SELECT Id, CreditScore__c FROM ClientCase__c WHERE Id =: clientCaseId];
        System.debug('clientCaseRec '+clientCaseRec);

        if (clientCaseRec != null) {
            Decimal creditScoreVal = 0.00;
            if (clientCaseRec.CreditScore__c != null) {
                creditScoreVal = clientCaseRec.CreditScore__c;
            }
            wrapper.creditScore = creditScoreVal;

            List<cic_credit__Credit_Report__c> creditReportList = new List<cic_credit__Credit_Report__c>();
            creditReportList = [SELECT Id, ClientCase__c FROM cic_credit__Credit_Report__c WHERE ClientCase__c =: clientCaseId ORDER BY CreatedDate DESC];
            System.debug('creditReportList 27 @@ '+creditReportList);
            List<cic_credit__Credit_Score__c> creditScoreList = new List<cic_credit__Credit_Score__c>();
            if (!creditReportList.isEmpty()) {
                creditScoreList = [SELECT Id, cic_credit__Credit_Report__c, cic_credit__Relationship__c, cic_credit__Score__c FROM cic_credit__Credit_Score__c WHERE cic_credit__Relationship__c = 'Co Borrower' AND cic_credit__Credit_Report__c =: creditReportList[0].Id ORDER BY cic_credit__Score__c DESC];
                System.debug('creditScoreList 27 @@ '+creditScoreList);
                if (!creditScoreList.isEmpty()) {
                    if (creditScoreList.size() == 1) {
                        wrapper.coAppCreditScore = creditScoreList[0].cic_credit__Score__c;
                    } else if (creditScoreList.size() == 2) {
                        wrapper.coAppCreditScore = creditScoreList[0].cic_credit__Score__c;
                    } else if (creditScoreList.size() == 3) {
                        wrapper.coAppCreditScore = creditScoreList[1].cic_credit__Score__c;
                    }
                }
            }

            System.debug('creditReportList '+creditReportList);

            // wrapper.coAppCreditScore = 0.00;     // Hardcoded for now

            List<ClientAsset__c> clientAssetList = new List<ClientAsset__c>();
            clientAssetList = [SELECT AccountBalance__c, CashDeposit__c, PresentMarketValue__c, Value__c, CashValue__c FROM ClientAsset__c WHERE ClientCase__c =: clientCaseId];

            System.debug('clientAssetList '+clientAssetList);


            Decimal savingValue = 0.00;
            Decimal totalAssetValue = 0.00;
            for (ClientAsset__c clientAsset : clientAssetList) {
                if (clientAsset.AccountBalance__c != null) {
                    savingValue += clientAsset.AccountBalance__c;
                    totalAssetValue += clientAsset.AccountBalance__c;
                }
                if (clientAsset.CashDeposit__c != null) {
                    savingValue += clientAsset.CashDeposit__c;
                    totalAssetValue += clientAsset.CashDeposit__c;
                }

                if (clientAsset.PresentMarketValue__c != null) {
                    totalAssetValue += clientAsset.PresentMarketValue__c;
                }
                if (clientAsset.Value__c != null) {
                    totalAssetValue += clientAsset.Value__c;
                }
                if (clientAsset.CashValue__c != null) {
                    totalAssetValue += clientAsset.CashValue__c;
                }
            }

            wrapper.savings = savingValue;
            wrapper.totalAssets = totalAssetValue;

            List<Liability__c> liablityList = new List<Liability__c>();
            liablityList = [SELECT Id, AccountBalance__c, MinimumMonthlyPayment__c FROM Liability__c WHERE ClientCase__c =: clientCaseId];

            System.debug('liablityList '+liablityList);

            Decimal totalDebtValue = 0.00;
            Decimal currentMDeptOblValue = 0.00;

            for (Liability__c lbty : liablityList) {
                if (lbty.AccountBalance__c != null) {
                    totalDebtValue += lbty.AccountBalance__c;
                }
                if (lbty.MinimumMonthlyPayment__c != null) {
                    currentMDeptOblValue += lbty.MinimumMonthlyPayment__c;
                }
            }
            wrapper.currentlyMonthlyDebtObligation = currentMDeptOblValue;
            wrapper.totalDebt = totalDebtValue;

            List<Income__c> incomeList = new List<Income__c>();
            incomeList = [SELECT Id, MonthlyGrossIncome__c, MonthlyNetIncome__c FROM Income__c WHERE ClientCase__c =: clientCaseId];

            System.debug('incomeList '+incomeList);

            Decimal grossMonthlyIncomeVal = 0.00;
            Decimal netMonthlyIncomeVal = 0.00;
            for (Income__c income : incomeList) {
                if (income.MonthlyGrossIncome__c != null) {
                    grossMonthlyIncomeVal += income.MonthlyGrossIncome__c;
                }
                if (income.MonthlyNetIncome__c != null) {
                    netMonthlyIncomeVal += income.MonthlyNetIncome__c;
                }
            }

            wrapper.grossMonthlyIncome = grossMonthlyIncomeVal;
            wrapper.netMonthlyIncome = netMonthlyIncomeVal;

            List<Budget__c> budgetList = new List<Budget__c>();

            budgetList = [SELECT Id, HousingActualCost__c FROM Budget__c WHERE ClientCase__c =: clientCaseId ORDER BY CreatedDate DESC];
            System.debug('budgetList '+budgetList);
            if (!budgetList.isEmpty()) {
                wrapper.housingExpense = budgetList[0].HousingActualCost__c;
            }
            wrapper.netWorth = totalAssetValue - totalDebtValue;
        }
        System.debug('wrapper '+wrapper);

        if (wrapper != null) {
            System.debug('wrapper 92 '+wrapper);
            return wrapper;
        }
        return null;
    }

    /**
     * @description       : Save Financial Snapshot record with current values.
    **/
    @AuraEnabled
    public static String createFinancialSnapshot(FinancialSnapshot__c finSnapshot) {
        if (finSnapshot != null) {
            insert finSnapshot;
            return 'success';
        }
        return null;
    }

    /**
     * @description       : Fetch Financial Snapshot records and get Picklist values.
    **/
    @AuraEnabled
    public static FinancialSnapshotDetailsWrapper fetchFinancialSnapshots(String clientCaseId) {
        FinancialSnapshotDetailsWrapper detailWrapper = new FinancialSnapshotDetailsWrapper();
        List<PicklistValuesWrapper> wrapper = new List<PicklistValuesWrapper>();

        List<FinancialSnapshot__c> finSnapshotList = new List<FinancialSnapshot__c>();

        finSnapshotList = [SELECT Id, Name, ClientCase__c, CreditScore__c, CoAppCreditScore__c, Savings__c, GrossMonthlyIncome__c, NetMonthlyIncome__c, 
        CurrentMonthlyDebtObligation__c, HousingExpense__c, NetWorth__c, TotalAssets__c, TotalDebt__c FROM FinancialSnapshot__c WHERE ClientCase__c =: clientCaseId ORDER BY CreatedDate DESC];

        System.debug('finSnapshotList '+finSnapshotList);
        System.debug('finSnapshotList size '+finSnapshotList.size());

        for (FinancialSnapshot__c Snapshot : finSnapshotList) {
            PicklistValuesWrapper wrapperObj = new PicklistValuesWrapper();
            wrapperObj.label = Snapshot.Name;
            wrapperObj.value = Snapshot.Id;
            wrapper.add(wrapperObj);
        }
        
        if (!finSnapshotList.isEmpty()) {
            detailWrapper.financialSnapshotRecords = finSnapshotList;
        }
        if (!wrapper.isEmpty()) {
            detailWrapper.picklistValues = wrapper;
        }
        if (detailWrapper != null) {
            return detailWrapper;
        }
        return null;

    }

    /**
     * @description       : Fetch Financial Goals.
    **/
    @AuraEnabled
    public static ClientCase__c fetchGoals(String clientCaseId) {
        List<ClientCase__c> clientCaseList = new List<ClientCase__c>();
        clientCaseList = [SELECT Id, CreditScoreGoal__c, PrimaryCoAppCreditScoreGoal__c, SavingsGoal__c, TotalAssetsGoal__c, TotalDebtGoal__c, 
        NetWorthGoal__c, HousingExpense__c, NetMonthlyIncomeGoal__c, GrossMonthlyIncomeGoal__c, CurrentMonthlyDebtObligationGoal__c FROM ClientCase__c WHERE Id =: clientCaseId];

        if (!clientCaseList.isEmpty()) {
            return clientCaseList[0];
        }
        return null;
    }

    /**
     * @description       : Get Financial Metrics Details to show on Financial Metrics table.
    **/
    @AuraEnabled
    public static FinancialMetricsDetailWrapper getFinacialMetricsDetails(String clientCaseId) {

        FinancialMetricsDetailWrapper wrapper = new FinancialMetricsDetailWrapper();
        wrapper.currentValues = getCurrentValues(clientCaseId);
        wrapper.goal = fetchGoals(clientCaseId);

        if (wrapper != null) {
            return wrapper;
        }
        return null;
    }
    
    public class FinancialSnapshotWrapper {
        @AuraEnabled public Decimal creditScore;
        @AuraEnabled public String coAppCreditScore;
        @AuraEnabled public Decimal savings;
        @AuraEnabled public Decimal grossMonthlyIncome;
        @AuraEnabled public Decimal netMonthlyIncome;
        @AuraEnabled public Decimal currentlyMonthlyDebtObligation;
        @AuraEnabled public Decimal housingExpense;
        @AuraEnabled public Decimal netWorth;
        @AuraEnabled public Decimal totalDebt;
        @AuraEnabled public Decimal totalAssets;
    }

    public class FinancialMetricsDetailWrapper {
        @AuraEnabled public FinancialSnapshotWrapper currentValues;
        @AuraEnabled public ClientCase__c goal;
    }

    public class PicklistValuesWrapper {
        @AuraEnabled public String label;
        @AuraEnabled public String value;
        @AuraEnabled public List<FinancialSnapshot__c> financialSnapshotRecords;
    }

    public class FinancialSnapshotDetailsWrapper {
        @AuraEnabled public List<PicklistValuesWrapper> picklistValues;
        @AuraEnabled public List<FinancialSnapshot__c> financialSnapshotRecords;
    }
}