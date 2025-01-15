import { LightningElement,api, wire} from 'lwc';
import getValidationErrors from '@salesforce/apex/HUDValidationController.getValidationErrors';
import { refreshApex } from '@salesforce/apex';
import { getRecord } from 'lightning/uiRecordApi';


export default class HudValidationsRecordPage extends LightningElement {

    @api recordId;
    @api objectApiName;
    validationErrorsMessages = '';
    error;
    wiredAccountResult;
    dynamicObjName = this.objectApiName + '.Id';
    
    @wire(getValidationErrors, {sobjectName: '$objectApiName',recordId: '$recordId'})
    validationErrors(result){
        this. wiredAccountResult = result;
        if (result.data) {
            //console.log('error--> ',result.data['ValidationCombined__c']);
            //this.validationErrorsMessages = result.data['ValidationCombined__c'];
            console.log('error--> ',result.data);
            this.validationErrorsMessages = result.data;
            this.error = undefined;
        } else if (result.error) {
            this.error = result.error;
            this.validationErrorsMessages = '';
        }
    }

    get reactiveRecordId() {
        return this.recordId;
    }

    @wire(getRecord, { recordId: '$reactiveRecordId', fields: "$dynamicObjName" })
    wiredRecord(result) {
        if (result.data) {
            refreshApex(this. wiredAccountResult);
        }
    }

    connectedCallback(){
        console.log(this.recordId);
        console.log(this.objectApiName);
    }
    get showValErrSection(){
        return this.validationErrorsMessages != 'NO ERROR' ? true : false;
    }
}