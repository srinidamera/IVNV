import { api, LightningElement, track, wire } from 'lwc';
import fetchFinancialSnapshots from '@salesforce/apex/CreateFinancialSnapshotsController.fetchFinancialSnapshots';
import getFinacialMetricsDetails from '@salesforce/apex/CreateFinancialSnapshotsController.getFinacialMetricsDetails';
import { getRecord } from 'lightning/uiRecordApi';

export default class ClientFinancialMetrics extends LightningElement {

    @api recordId;

    get reactiveRecordId() {
        return this.recordId;
    }
    @track SnapshotOptions = [];
    @track selectedValue;

    snapshotRecords = [];
    @track selectedSnapshotRec = {};
    @track currentValues = {};
    @track changeValue = {};
    @track goals = {};
    @track overUnderGoalValues = {};

    @wire(getRecord, { recordId: '$reactiveRecordId', fields: ['ClientCase__c.Name'] })
        wiredRecord(result) {
            if (result.data) {
                this.getUpdatesValues();
            }
        }

    async connectedCallback() {
        console.log('ConnectedCallback.....');
        
        await fetchFinancialSnapshots({clientCaseId: this.recordId}).then(result => {
            console.log('result !@# 33 ',result);
            if (result) {
                this.SnapshotOptions = result.picklistValues ? result.picklistValues : [];
                this.snapshotRecords = result.financialSnapshotRecords ? result.financialSnapshotRecords : [];
                this.selectedValue = result.picklistValues ? result.picklistValues[0].value : null;
                this.selectedSnapshotRec = this.snapshotRecords ? this.snapshotRecords.find(opt => opt.Id === this.selectedValue) : null;
                console.log('this.selectedSnapshotRec !@# 41 ',this.selectedSnapshotRec);
                
                if (this.selectedSnapshotRec) {
                    console.log('this.snapshotRecords !@# 44 ',this.snapshotRecords);
                    console.log('this.snapshotRecords.find(opt => opt.Id === this.selectedValue) !@# 45 ',this.snapshotRecords.find(opt => opt.Id === this.selectedValue));
                    this.selectedSnapshotRec['Name'] = this.snapshotRecords ? this.snapshotRecords.find(opt => opt.Id === this.selectedValue) ? this.snapshotRecords.find(opt => opt.Id === this.selectedValue).Name.split(' ')[0] : null : null;
                }
            }  
        });
        // console.log('SnapshotOptions ',this.SnapshotOptions);
        // console.log('selectedValue ',this.selectedValue);
        // console.log('snapshotRecords ',this.snapshotRecords);
        

        await this.getFinacialMetricsDetails();

        this.calculateChangeValue();

        this.calculateOverUnderGoal();
    }

    async getFinacialMetricsDetails() {
        await getFinacialMetricsDetails({clientCaseId: this.recordId}).then(result => {
            console.log('result getFinacialMetricsDetails 38 ',result);
            console.log('result type 38 ',typeof result);
            if (result) {
                this.currentValues = result.currentValues;
                this.goals = result.goal;
            }
        });
        console.log('currentValues ',this.currentValues);
    }

    async getUpdatesValues() {

        await fetchFinancialSnapshots({clientCaseId: this.recordId}).then(result => {
            console.log('result 25 ',result);
            console.log('result type 25 ',typeof result);
            if (result) {
                this.SnapshotOptions = result.picklistValues;
                this.snapshotRecords = result.financialSnapshotRecords;
                this.selectedValue = result.picklistValues ? result.picklistValues[0].value : null;
                this.selectedSnapshotRec = this.snapshotRecords ? this.snapshotRecords.find(opt => opt.Id === this.selectedValue) : null;
                console.log('this.selectedSnapshotRec !@# 84 ',this.selectedSnapshotRec);
                
                if (this.selectedSnapshotRec !== null) {
                    console.log('this.snapshotRecords !@# 87 ',this.snapshotRecords);
                    console.log('this.snapshotRecords.find(opt => opt.Id === this.selectedValue) !@# 88 ',this.snapshotRecords.find(opt => opt.Id === this.selectedValue));
                    this.selectedSnapshotRec['Name'] = this.snapshotRecords ? this.snapshotRecords.find(opt => opt.Id === this.selectedValue) ? this.snapshotRecords.find(opt => opt.Id === this.selectedValue).Name.split(' ')[0] : null : null;
                }
            }  
        });

        await getFinacialMetricsDetails({clientCaseId: this.reactiveRecordId}).then(result => {
            console.log('result getFinacialMetricsDetails 38 ',result);
            console.log('result type 38 ',typeof result);
            if (result) {
                this.currentValues = result.currentValues;
                this.goals = result.goal;
            }
        });

        this.calculateChangeValue();
        console.log('this.goals getUpdatesValues before 92 ',this.goals);
        console.log('this.currentValues getUpdatesValues before 92 ',this.currentValues);
        this.calculateOverUnderGoal();

        console.log('this.overUnderGoalValues getUpdatesValues 92 ',this.overUnderGoalValues);
        console.log('this.goals getUpdatesValues 92 ',this.goals);
        console.log('this.currentValues getUpdatesValues 92 ',this.currentValues);
        
    }

    calculateChangeValue() {
        if (this.currentValues && this.selectedSnapshotRec) {
            this.changeValue.creditScore = this.currentValues.creditScore != null && this.selectedSnapshotRec.CreditScore__c != null ? this.currentValues.creditScore - this.selectedSnapshotRec.CreditScore__c : null;
            this.changeValue.coAppCreditScore = this.currentValues.coAppCreditScore != null && this.selectedSnapshotRec.CoAppCreditScore__c != null ? this.currentValues.coAppCreditScore - this.selectedSnapshotRec.CoAppCreditScore__c : null;
            this.changeValue.savings = this.currentValues.savings != null && this.selectedSnapshotRec.Savings__c != null ? this.currentValues.savings - this.selectedSnapshotRec.Savings__c : null;
            this.changeValue.grossMonthlyIncome = this.currentValues.grossMonthlyIncome != null && this.selectedSnapshotRec.GrossMonthlyIncome__c != null ? this.currentValues.grossMonthlyIncome - this.selectedSnapshotRec.GrossMonthlyIncome__c : null;
            this.changeValue.netMonthlyIncome = this.currentValues.netMonthlyIncome != null && this.selectedSnapshotRec.NetMonthlyIncome__c != null ? this.currentValues.netMonthlyIncome - this.selectedSnapshotRec.NetMonthlyIncome__c : null;
            this.changeValue.currentlyMonthlyDebtObligation = this.currentValues.currentlyMonthlyDebtObligation != null && this.selectedSnapshotRec.CurrentMonthlyDebtObligation__c != null ? this.currentValues.currentlyMonthlyDebtObligation - this.selectedSnapshotRec.CurrentMonthlyDebtObligation__c : null;
            this.changeValue.housingExpense = this.currentValues.housingExpense != null && this.selectedSnapshotRec.HousingExpense__c != null ? this.currentValues.housingExpense - this.selectedSnapshotRec.HousingExpense__c : null;
            this.changeValue.netWorth = this.currentValues.netWorth != null && this.selectedSnapshotRec.NetWorth__c != null ? this.currentValues.netWorth - this.selectedSnapshotRec.NetWorth__c : null;
            this.changeValue.totalDebt = this.currentValues.totalDebt != null && this.selectedSnapshotRec.TotalDebt__c != null ? this.currentValues.totalDebt - this.selectedSnapshotRec.TotalDebt__c : null;
            this.changeValue.totalAssets = this.currentValues.totalAssets != null && this.selectedSnapshotRec.TotalAssets__c != null ? this.currentValues.totalAssets - this.selectedSnapshotRec.TotalAssets__c : null;
            console.log('changeValue ',this.changeValue);
        }
        
    }

    calculateOverUnderGoal() {
        if (this.goals && this.currentValues) {
            this.overUnderGoalValues.creditScore = this.goals.CreditScoreGoal__c != null && this.currentValues.creditScore != null ? this.currentValues.creditScore - this.goals.CreditScoreGoal__c : null;
            this.overUnderGoalValues.coAppCreditScore = this.goals.PrimaryCoAppCreditScoreGoal__c != null && this.currentValues.coAppCreditScore != null ? this.currentValues.coAppCreditScore - this.goals.PrimaryCoAppCreditScoreGoal__c : null;
            this.overUnderGoalValues.savings = this.goals.SavingsGoal__c != null && this.currentValues.savings != null ? this.currentValues.savings - this.goals.SavingsGoal__c : null;
            this.overUnderGoalValues.grossMonthlyIncome = this.goals.GrossMonthlyIncomeGoal__c != null && this.currentValues.grossMonthlyIncome != null ? this.currentValues.grossMonthlyIncome - this.goals.GrossMonthlyIncomeGoal__c : null;
            this.overUnderGoalValues.netMonthlyIncome = this.goals.NetMonthlyIncomeGoal__c != null && this.currentValues.netMonthlyIncome != null ? this.currentValues.netMonthlyIncome - this.goals.NetMonthlyIncomeGoal__c : null;
            this.overUnderGoalValues.currentlyMonthlyDebtObligation = this.goals.CurrentMonthlyDebtObligationGoal__c != null && this.currentValues.currentlyMonthlyDebtObligation != null ? this.currentValues.currentlyMonthlyDebtObligation - this.goals.CurrentMonthlyDebtObligationGoal__c : null;
            this.overUnderGoalValues.housingExpense = this.goals.HousingExpense__c != null && this.currentValues.housingExpense != null ? this.currentValues.housingExpense - this.goals.HousingExpense__c : null;
            this.overUnderGoalValues.totalDebt = this.goals.TotalDebtGoal__c != null && this.currentValues.totalDebt != null ? this.currentValues.totalDebt - this.goals.TotalDebtGoal__c : null;
            this.overUnderGoalValues.totalAssets = this.goals.TotalAssetsGoal__c != null && this.currentValues.totalAssets != null ? this.currentValues.totalAssets - this.goals.TotalAssetsGoal__c : null;
            this.overUnderGoalValues.netWorth = this.goals.NetWorthGoal__c != null && this.currentValues.netWorth != null ? this.currentValues.netWorth - this.goals.NetWorthGoal__c : null;

            console.log('overUnderGoalValues #calculateOverUnderGoal ',this.overUnderGoalValues);
        }
    }

    handleSnapshotChange(event) {
        console.log('handleSnapshotChange.....');
        console.log('event.target.value ',event.target.value);
        this.selectedValue = event.target.value;

        this.selectedSnapshotRec = this.snapshotRecords ? this.snapshotRecords.find(opt => opt.Id === this.selectedValue) : null;
        console.log('this.selectedSnapshotRec !@# 153 ',this.selectedSnapshotRec);
        
        if (this.selectedSnapshotRec !== null) {
            console.log('this.snapshotRecords !@# 154 ',this.snapshotRecords);
            console.log('this.snapshotRecords.find(opt => opt.Id === this.selectedValue) !@# 156 ',this.snapshotRecords.find(opt => opt.Id === this.selectedValue));
            this.selectedSnapshotRec['Name'] = this.snapshotRecords ? this.snapshotRecords.find(opt => opt.Id === this.selectedValue) ? this.snapshotRecords.find(opt => opt.Id === this.selectedValue).Name.split(' ')[0] : null : null;
        }

        this.calculateChangeValue();

        console.log('selectedValue ',this.selectedValue);
    }
}