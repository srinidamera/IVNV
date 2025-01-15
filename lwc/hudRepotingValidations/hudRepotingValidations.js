import { LightningElement,api, wire} from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import getValidationErrors from '@salesforce/apex/HudGenerateAndSubmitController.getValidationErrors';

const validationTableColumns = [
    { label: 'Name', fieldName: 'NameURL', type: 'url', typeAttributes: {label: { fieldName: 'Name' }, target: '_blank'}  },
    { label: 'Error Message', fieldName: 'ErrorMessage', type: 'text', wrapText: true },
    { label: 'Record Type', fieldName: 'Report', type: 'text' }
];

export default class HudRepotingValidations extends NavigationMixin(LightningElement) {
    @api recordId;
    @api objectApiName;
    //validationErrorsMessages = [];
    showValidationErrorsection = false;
    validationTableData = [];
    validationTableColumns = validationTableColumns;
    error;

    @wire(getValidationErrors, {sobjectName: '$objectApiName',recordId: '$recordId'})
    validationErrors({ error, data }){
        if (data) {
            if(data.hasOwnProperty('AgencyProfile__c') && data['AgencyProfile__c'] && data['AgencyProfile__c'].length > 0){
                this.updateValidationError(data['AgencyProfile__c'], 'Agency Profile');
            }
            if(data.hasOwnProperty('Contact') && data['Contact'] && data['Contact'].length > 0){
                this.updateValidationError(data['Contact'], 'Contact');
            }
            if(data.hasOwnProperty('User') && data['User'] && data['User'].length > 0){
                this.updateValidationError(data['User'], 'User');
            }
            if(data.hasOwnProperty('ClientCase__c') && data['ClientCase__c'] && data['ClientCase__c'].length > 0){
                this.updateValidationError(data['ClientCase__c'], 'Client Case');
            }
            if(data.hasOwnProperty('CounselorTraining__c') && data['CounselorTraining__c'] && data['CounselorTraining__c'].length > 0){
                this.updateValidationError(data['CounselorTraining__c'], 'Counselor Training');
            }
            if(data.hasOwnProperty('sumoapp__AdditionalInfo__c') && data['sumoapp__AdditionalInfo__c'] && data['sumoapp__AdditionalInfo__c'].length > 0){
                this.updateValidationError(data['sumoapp__AdditionalInfo__c'], 'Course');
            }
            if(data.hasOwnProperty('sumoapp__Attendee__c') && data['sumoapp__Attendee__c'] && data['sumoapp__Attendee__c'].length > 0){
                this.updateValidationError(data['sumoapp__Attendee__c'], 'Attendee');
            }
        } else if (error) {
            this.error = error;
            this.contacts = undefined;
        }
    }
    
    connectedCallback(){
        console.log(this.recordId);
        console.log(this.sobjectName);
        if(this.validationTableData && this.validationTableData.length > 0){
            this.showValidationErrorsection = true;
        }
    }

    updateValidationError(data, type){
        let validationTableDataTemp = [];
        Object.keys(data).forEach(function(key,index) {
            if(data[index]['ValidationCombined__c'] != null && data[index]['ValidationCombined__c'] !== 'NO ERROR'){
                validationTableDataTemp.push({
                    ErrorMessage: data[index]['ValidationCombined__c'].substring(0, data[index]['ValidationCombined__c'].length - 1), 
                    Id: data[index]['Id'], 
                    Name: data[index]['Name'], 
                    Report: type, 
                    NameURL: '/'+data[index]['Id'] 
                });
            }
        });
        this.validationTableData.push(...validationTableDataTemp);
        if(this.validationTableData && this.validationTableData.length > 0){
            this.showValidationErrorsection = true;
        }else{
            this.showValidationErrorsection = false;
        }
        this.error = undefined;
    }
    
    navigateToRecord(event) {
        event.preventDefault();
        var href = event.currentTarget.getAttribute('href');
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: href,
                actionName: 'view'
            }
        });
    }

    get showValErrSection(){
        return this.validationTableData.length > 0 ? true : false;
    }
}