import { LightningElement, api, track, wire } from 'lwc';
import getReferrals from '@salesforce/apex/CreateReferralController.getReferrals';
import insertReferrals from '@salesforce/apex/CreateReferralController.insertReferrals';
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { RefreshEvent } from "lightning/refresh";


import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import ReferralType from '@salesforce/schema/Referral__c.ReferralType__c';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import REFERRAL_OBJECT from '@salesforce/schema/Referral__c';


const columns = [
    { label: 'Name', fieldName: 'Name', type: 'text',wrapText:true },
    { label: 'Organization', fieldName: 'accountName', type: 'text',wrapText:true },
    { label: 'Referral Type', fieldName: 'Account_Referral_Type__c', type: 'text',wrapText:true },
    { label: 'Email', fieldName: 'Email', type: 'email',wrapText:false },
    { label: 'Phone', fieldName: 'Phone', type: 'phone',wrapText:true },
    { label: 'Speciality', fieldName: 'Speciality__c', type: 'text' ,wrapText:true},
    { label: 'Address', fieldName: 'address', type: 'text' ,wrapText:true},
    {
        label: 'Notes', fieldName: '',wrapText:true, type: 'input', typeAttributes: {
            placeholder: 'Notes'
            , value: { fieldName: 'ReferralNotes__c' } // default value for Notes
            , context: { fieldName: 'Id' } // binding account Id with context variable to be returned back
        }
    }
];
export default class CreateReferralLWC extends LightningElement {



    @wire(getObjectInfo, { objectApiName: REFERRAL_OBJECT })
    leadInfo;

    @track referralTypeValues = [];

    @wire(getPicklistValues, { recordTypeId: '$leadInfo.data.defaultRecordTypeId',
            fieldApiName: ReferralType })
    wiredData({ error, data }) {
      if (data) {
        const valuesArray = data.values.map(item => item.value);
        valuesArray.unshift('All');
        this.referralTypeValues = valuesArray; 
      } else if (error) {
         console.error('Error:', error);
      }
    }




    @track referrals;
    @api recordId;
    @api objectApiName;
    referralRecords = [];
    backupReferrals;
    cols = columns;
    selectedReferral = 'All';
    allSelectedReferral;
    inputText;
    @wire(getReferrals)
    getReferralsWire({ error, data }) {
        let index = 0;
        if (data) {
            this.backupReferrals = data.map(row => {
                return { ...row, accountName: row.Account.Name, index: index++, address: this.combineAddress(row.Account.BillingAddress) }
            });
            index = 0;
            this.referrals = data.map(row => {
                return { ...row, accountName: row.Account.Name, index: index++, address: this.combineAddress(row.Account.BillingAddress) }
            });
        } else if (error) {
            console.error('Error:', error);
        }
    }


    handleReferralChange(event) {
        this.allSelectedReferral = event.detail;
        try {
            this.selectedReferral = event.detail.value;
            if(this.allSelectedReferral.includes('All')){
                this.referrals = this.backupReferrals;
            }else if (this.inputText && this.inputText.length > 0) {
                this.referrals = this.backupReferrals.filter(obj => {
                    return obj.Account_Referral_Type__c == event.detail.value && obj.Name.toLowerCase().includes(this.inputText.toLowerCase());
                });
            } else {
                this.referrals = this.backupReferrals.filter(obj => {
                    return this.allSelectedReferral.includes(obj.Account_Referral_Type__c);
                });
            }
        } catch (error) {
            console.log('OUTPUT : error', error);
        }


    }

    handleKeyUp(evt) {
        try {
            this.inputText = evt.target.value;
            const searchText = this.inputText.toLowerCase();
            if (this.selectedReferral && this.selectedReferral != 'All') {
                this.referrals = this.backupReferrals.filter(obj => {
                    return obj.Account_Referral_Type__c == this.selectedReferral && ((obj.Name && obj.Name.toLowerCase().includes(searchText)) ||
                    (obj.Account_Referral_Type__c && obj.Account_Referral_Type__c.toLowerCase().includes(searchText)) ||
                    (obj.Email && obj.Email.toLowerCase().includes(searchText)) ||
                    (obj.Phone && obj.Phone.toLowerCase().includes(searchText)) ||
                    (obj.Speciality__c && obj.Speciality__c.toLowerCase().includes(searchText)) ||
                    (obj.address && obj.address.toLowerCase().includes(searchText)) ||
                    (obj.accountName && obj.accountName.toLowerCase().includes(searchText)));//obj.Name.toLowerCase().includes(this.inputText.toLowerCase());
                });
            } else {
                this.referrals = this.backupReferrals.filter(obj => {
                    return (obj.Name && obj.Name.toLowerCase().includes(searchText)) ||
                    (obj.Account_Referral_Type__c && obj.Account_Referral_Type__c.toLowerCase().includes(searchText)) ||
                    (obj.Email && obj.Email.toLowerCase().includes(searchText)) ||
                    (obj.Phone && obj.Phone.toLowerCase().includes(searchText)) ||
                    (obj.Speciality__c && obj.Speciality__c.toLowerCase().includes(searchText)) ||
                    (obj.address && obj.address.toLowerCase().includes(searchText)) ||
                    (obj.accountName && obj.accountName.toLowerCase().includes(searchText))
                });
            }
        } catch (error) {
            console.log('OUTPUT : error', error);
        }


    }

    createReferral() {
        console.log('this.referralRecords '+JSON.stringify(this.referralRecords));
        if(this.referralRecords.length >0){
        insertReferrals({ referrals: this.referralRecords })
            .then(result => {
                console.log('result '+JSON.stringify(result));
                this.closeQuickAction();
                this.showNotification("Success","Referral record created successfully!!!","success");
                //eval("$A.get('e.force:refreshView').fire();");
                this.dispatchEvent(new RefreshEvent());
            })
            .catch(error => {
                console.error('Error:',JSON.stringify(error));
            });
        }else{
            this.showNotification("Error","Please Select a Contact","error");
        }
    }
    getSelectedName(event) {
        this.referralRecords = []
        const selectedRows = event.detail.selectedRows;
        for (let i = 0; i < selectedRows.length; i++) {
            console.log('selectedRows[i].ReferralNotes__c '+selectedRows[i].ReferralNotes__c);
            let record;
            if(this.objectApiName == 'ClientCase__c'){
            record = {
                sobjectType: "Referral__c",
                Name: selectedRows[i].Name,
                ReferralType__c: selectedRows[i].Account_Referral_Type__c,
                ReferredtoAgency__c: selectedRows[i].AccountId,
                ClientName__c: selectedRows[i].Id,
                ReferredtoContact__c: selectedRows[i].Id,
                ReferralNotes__c: selectedRows[i].ReferralNotes__c != undefined? selectedRows[i].ReferralNotes__c:'',
                ClientCase__c: this.recordId
            };
        }else{
            record = {
                sobjectType: "Referral__c",
                Name: selectedRows[i].Name,
                ReferralType__c: selectedRows[i].Account_Referral_Type__c,
                ReferredtoAgency__c: selectedRows[i].AccountId,
                ClientName__c: selectedRows[i].Id,
                ReferredtoContact__c: selectedRows[i].Id,
                ReferralNotes__c: selectedRows[i].ReferralNotes__c != undefined? selectedRows[i].ReferralNotes__c:'',
                IntakeRequest__c: this.recordId
            };
        }
            this.referralRecords.push(record);
        }
    }

    closeQuickAction() {
        const selectedEvent = new CustomEvent("close", { detail: true });
        this.dispatchEvent(selectedEvent);
    }

    showNotification(title,message,variant) {
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
        });
        this.dispatchEvent(evt);
    }


    inputChanged(event) {
        event.stopPropagation();
        let dataRecieved = event.detail.data;
        this.referrals.forEach(currentItem => {
            if (currentItem.Id == dataRecieved.context) {
                currentItem.ReferralNotes__c = dataRecieved.value;
            }
        });
        if(this.referralRecords){
            for (let i = 0; i < this.referralRecords.length; i++) {
                if(this.referralRecords[i].ClientName__c == dataRecieved.context){
                    this.referralRecords[i].ReferralNotes__c = dataRecieved.value;
                }

            }
        }
        
        this.backupReferrals.forEach(currentItem => {
            if (currentItem.Id == dataRecieved.context) {
                currentItem.ReferralNotes__c = dataRecieved.value;
            }
        });
        console.log('this.referralRecords '+JSON.stringify(this.referralRecords));
    }

    saveDraftValues() {

    }

    combineAddress(address) {
        // Check if address object is null or undefined
        if (!address) {
            return '';
        }

        // Extract address components
        const { street, city, state, postalCode } = address;

        // Initialize an array to hold non-empty address components
        const components = [];

        // Add non-empty address components to the array
        if (street) components.push(street);
        if (city) components.push(city);
        if (state) components.push(state);
        if (postalCode) components.push(postalCode);

        // Combine address components with a comma and space
        const combinedAddress = components.join(', ');

        return combinedAddress;
    }


}