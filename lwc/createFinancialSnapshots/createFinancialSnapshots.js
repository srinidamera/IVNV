import { api, LightningElement, track, wire } from 'lwc';
import getCurrentValues from '@salesforce/apex/CreateFinancialSnapshotsController.getCurrentValues';
import createFinancialSnapshot from '@salesforce/apex/CreateFinancialSnapshotsController.createFinancialSnapshot';
import fetchFinancialSnapshots from '@salesforce/apex/CreateFinancialSnapshotsController.fetchFinancialSnapshots';
import { getRecord } from 'lightning/uiRecordApi';

import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class CreateFinancialSnapshots extends LightningElement {

    @api recordId;

    @track currentValuesWrapper = {};
    financialSnapshotRecord = {};
    showModal = false;
    @track primaryContact;
    @track primaryContactName;
    @track clientCaseName;

    @wire(getRecord, { recordId: '$recordId', fields: ['ClientCase__c.PrimaryClient__r.Name', 'ClientCase__c.ClientCaseName__c'] })
    wiredRecord(result) {
        console.log('result 27 ', result);
        if (result.data) {
            this.primaryContactName = result.data.fields.PrimaryClient__r.value.fields.Name.value;
            this.primaryContact = result.data.fields.PrimaryClient__r.value.id;
            this.clientCaseName = result.data.fields.ClientCaseName__c.value;
        }
    }

    connectedCallback() {
        console.log('recordId 13 ',this.recordId);

        this.getValues();
    }

    getValues() {
        getCurrentValues({clientCaseId: this.recordId}).then(result => {
            console.log('result 25 ',result);
            console.log('result type 25 ',typeof result);
            
            if (result) {
                this.currentValuesWrapper = result;
            }
        });
    }
    
    formatDate() {
        const now = new Date();
    
        // Array of month names
        const months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
    
        // Extract components of the date
        const month = months[now.getMonth()];
        const day = now.getDate();
        const year = now.getFullYear();
        let hours = now.getHours();
        const minutes = now.getMinutes();
        
        // Determine AM or PM
        const ampm = hours >= 12 ? 'PM' : 'AM';
    
        // Convert hours from 24-hour format to 12-hour format
        hours = hours % 12;
        hours = hours ? hours : 12; // The hour '0' should be '12'
    
        // Add leading zero to minutes if necessary
        const minuteString = minutes < 10 ? '0' + minutes : minutes;
    
        // Format the date string
        return `${month} ${day} ${year} ${hours}:${minuteString}${ampm}`;
    }

    async handleSaveClick() {
        console.log('currentValuesWrapper 33 ',this.currentValuesWrapper);
        let snapshotSize = 0;
        await fetchFinancialSnapshots({clientCaseId: this.recordId}).then(result => {
            console.log('result 25 ',result);
            console.log('result type 25 ',typeof result);
            if (result) {
                snapshotSize = result.financialSnapshotRecords ? result.financialSnapshotRecords.length : 0;
            }  
        });
        if (this.financialSnapshotRecord) {
            this.financialSnapshotRecord.Name = '#' + (parseInt(snapshotSize)+1) + ' ' + this.formatDate();
            this.financialSnapshotRecord.CreditScore__c = this.currentValuesWrapper ? this.currentValuesWrapper.creditScore : null;
            this.financialSnapshotRecord.CoAppCreditScore__c = this.currentValuesWrapper ? this.currentValuesWrapper.coAppCreditScore : null;
            this.financialSnapshotRecord.Savings__c = this.currentValuesWrapper ? this.currentValuesWrapper.savings : null;
            this.financialSnapshotRecord.GrossMonthlyIncome__c = this.currentValuesWrapper ? this.currentValuesWrapper.grossMonthlyIncome : null;
            this.financialSnapshotRecord.NetMonthlyIncome__c = this.currentValuesWrapper ? this.currentValuesWrapper.netMonthlyIncome : null;
            this.financialSnapshotRecord.CurrentMonthlyDebtObligation__c = this.currentValuesWrapper ? this.currentValuesWrapper.currentlyMonthlyDebtObligation : null;
            this.financialSnapshotRecord.HousingExpense__c = this.currentValuesWrapper ? this.currentValuesWrapper.housingExpense : null;
            this.financialSnapshotRecord.NetWorth__c = this.currentValuesWrapper ? this.currentValuesWrapper.netWorth : null;
            this.financialSnapshotRecord.TotalDebt__c = this.currentValuesWrapper ? this.currentValuesWrapper.totalDebt : null;
            this.financialSnapshotRecord.TotalAssets__c = this.currentValuesWrapper ? this.currentValuesWrapper.totalAssets : null;
            this.financialSnapshotRecord.ClientCase__c = this.recordId;
            this.financialSnapshotRecord.PrimaryContact__c = this.primaryContact ? this.primaryContact : null;

            console.log('financialSnapshotRecord 47 ',this.financialSnapshotRecord);
        }
        

        createFinancialSnapshot({finSnapshot: this.financialSnapshotRecord}).then(result => {
            console.log('result 51 ',result);
            console.log('result type 51 ',typeof result);
            
            if (result = 'success') {
                    const evt = new ShowToastEvent({
                        title: 'Success',
                        message: 'Snapshot was added Successfully!',
                        variant: 'success',
                        mode: 'dismissable'
                    });
                    this.dispatchEvent(evt);
            }
        });
        this.showModal = false;

        eval("$A.get('e.force:refreshView').fire();");
    }

    handleCancelClick() {
        console.log('10');
        this.showModal = false;
    }

    openModal() {
        this.showModal = true;
        this.getValues();
    }

    
}