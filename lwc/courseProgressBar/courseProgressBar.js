import { LightningElement, api,wire, track } from 'lwc';
import getParentAndChildRecords from '@salesforce/apex/courseProgressBarController.getParentAndChildRecords';
import { getRecord } from 'lightning/uiRecordApi';
import { NavigationMixin } from 'lightning/navigation';

export default class courseProgressBar extends NavigationMixin(LightningElement) {

    @api stages;
    @api recordId; 
    selectedItemValue;
    items = [];
    parentId;
    @track isActive = true;
    @track isSession = false;

    /**
     * Gets the Course records
     */
    @wire(getParentAndChildRecords, { recordId: '$recordId' })
    wiredRecords({ error, data }) {
        if (data) {
            if(data !== undefined){
                if(data.length > 0){
                    this.items = data;
                    this.parentId = data[0].parentId;
                }
            }
        } else if (error) {
            
        }
    }

    /**
     * Gets current Course record details
     */
    @wire(getRecord, {
        recordId: "$recordId",
        fields: ["sumoapp__AdditionalInfo__c.IsParent__c","sumoapp__AdditionalInfo__c.RecordType.DeveloperName"]
    })
    getAddInfoCurrentRecord({data, error}){
        if(data){
            this.isActive = data.fields.IsParent__c.value;
            if(data.fields.RecordType.displayValue === 'Event'){
                this.isSession = true;
            }
        }

    }

    /**
     * Handles navigation to class page when clicked on path
     */
    navigateToRecordPage(event) {
        
        let recordId = event.target.dataset.id;
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: recordId,
                actionName: 'view'
            }
        });
    }

    /**
     * Handles navigation to course page when clicked on path
     */
    handleCourseButtonClick(event){
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.parentId,
                actionName: 'view'
            }
        });
    }
}