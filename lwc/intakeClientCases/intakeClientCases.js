import { LightningElement, api, track,wire } from 'lwc';
import retrieveClientCase from '@salesforce/apex/IntakeCaseController.retrieveClientCase';
import intakeMsgChannel from "@salesforce/messageChannel/IntakeMsgChannel__c";
import {publish,subscribe,APPLICATION_SCOPE, MessageContext} from 'lightning/messageService';
import IntakeClientCaseSelectMsg from "@salesforce/label/c.IntakeClientCaseSelectMsg";

const columns = [
    { label: 'Case Name', fieldName: 'caseLink', type: 'url', typeAttributes: { label: { fieldName: 'ClientCaseName__c' }, target: '_blank' }, sortable: "true" },
    { label: 'Case Owner', fieldName: 'ownerName', sortable: "true" },
    { label: 'Case Type', fieldName: 'caseTypeName', sortable: "true" },
    { label: 'Case Status', fieldName: 'ClientCaseStatus__c', sortable: "true" },
    { label: 'Last ModifiedDate', fieldName: 'LastModifiedDate',type: 'date', sortable: "true"}    
];

export default class IntakeClientCases extends LightningElement {
    @track data;
    @track error;
    @track columns = columns;
    @api contactIds;
    subscription = null;
    message;
    isSearch = false;

    label = { IntakeClientCaseSelectMsg };
    
    @wire(MessageContext)
    messageContext;
    sortBy = "Name";
    sortDirection = "asc";
 
    
    
    @wire(retrieveClientCase,{contactIds: '$contactIds'})
    wiredClientCase({ error, data }) {
        if (data) {
            if((data.length == 0 || data == null) && this.contactIds.length > 0) this.message = 'No Client cases found for selected Contact!';
            else this.message = null;
            let resData = JSON.parse(JSON.stringify(data));
            resData.forEach(res => {
                res.caseLink = '/' + res.Id;
                res.ownerName = res.OwnerId ? res.Owner.Name : '';
                res.caseTypeName = res.CaseType__c ? res.CaseType__r.Name : '';
            });
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
     * @description : Sorts the elements of the grid
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