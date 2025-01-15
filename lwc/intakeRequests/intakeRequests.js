import { LightningElement, api, track,wire } from 'lwc';
import retrieveIntakeRequests from '@salesforce/apex/IntakeCaseController.retrieveIntakeRequests';
import intakeMsgChannel from "@salesforce/messageChannel/IntakeMsgChannel__c";
import {publish,subscribe,APPLICATION_SCOPE, MessageContext} from 'lightning/messageService';
import IntakeRequstSelectMsg from "@salesforce/label/c.IntakeRequstSelectMsg";

const columns = [
    { label: 'Intake Name', fieldName: 'caseLink', type: 'url', typeAttributes: { label: { fieldName: 'IntakeRequestName__c' }, target: '_blank' }, sortable: "true" },
    { label: 'Intake Owner', fieldName: 'ownerName', sortable: "true" },
    { label: 'Intake Type', fieldName: 'caseTypeName', sortable: "true" },
    { label: 'Intake Status', fieldName: 'Status__c', sortable: "true" },
    { label: 'Last ModifiedDate', fieldName: 'LastModifiedDate',type: 'date', sortable: "true"}    
];

export default class IntakeRequests extends LightningElement {
    @track data;
    @track error;
    @track columns = columns;
    @api contactIds;
    subscription = null;
    message;
    isSearch = false;

    label = { IntakeRequstSelectMsg };
    
    @wire(MessageContext)
    messageContext;
    sortBy = "Name";
    sortDirection = "asc";
 
    
    
    @wire(retrieveIntakeRequests,{contactIds: '$contactIds'})
    wiredClientCase({ error, data }) {
        if (data) {
            if((data.length == 0 || data == null) && this.contactIds.length > 0) this.message = 'No Intake Requests found for selected Contact!';
            else this.message = null;
            let resData = JSON.parse(JSON.stringify(data));
            resData.forEach(res => {
                res.caseLink = '/' + res.Id;
                res.ownerName = res.OwnerId ? res.Owner.Name : '';
                res.caseTypeName = res.CaseType__c ? res.CaseType__r.Name : '';
            });
            console.log('Response recieved : ', resData);
            this.data = resData;
            this.error = undefined;
        } else if (error){
            alert(JSON.stringify(error));
            this.error = error;
            this.data = undefined;
        }
    }

    /**
     * 
     * @description :  Sorts the table Data
     */
    doSorting(event) {
        this.sortBy = event.detail.fieldName;
        this.sortDirection = event.detail.sortDirection;
        
        let parseData = JSON.parse(JSON.stringify(this.data));
        let keyValue = (a) => {
            return a[this.sortBy];
        };
        let isReverse = this.sortDirection === 'asc' ? 1: -1;
        parseData.sort((x, y) => {
        x = keyValue(x) ? keyValue(x) : ''; 
        y = keyValue(y) ? keyValue(y) : '';
        return isReverse * ((x > y) - (y > x));
        });  
        this.data = parseData;
    }
}