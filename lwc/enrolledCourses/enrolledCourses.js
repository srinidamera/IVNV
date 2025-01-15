import { LightningElement, api, track, wire } from 'lwc';
import retrieveIntakeRequests from '@salesforce/apex/IntakeCaseController.retrieveIntakeRequests';
import getCourses from '@salesforce/apex/IntakeCaseController.getCourses';
import intakeMsgChannel from "@salesforce/messageChannel/IntakeMsgChannel__c";
import { publish, subscribe, APPLICATION_SCOPE, MessageContext } from 'lightning/messageService';
import CoursesSelectMessage from "@salesforce/label/c.CoursesSelectMessage";

const columns = [
    { label: 'Course Name', fieldName: 'courseLink', type: 'url', typeAttributes: { label: { fieldName: 'courseName' }, target: '_blank' }, sortable: "true" },
    { label: 'Date', fieldName: 'startDate', sortable: "true", type: 'date' },
    { label: 'Attendance Status', fieldName: 'status', sortable: "true" },
    { label: 'Notes', fieldName: 'notes', sortable: "true" },
    { label: 'Facilitator', fieldName: 'facilitator', sortable: "true" },
    { label: 'Delivery Type', fieldName: 'deliveryType', sortable: "true" },

];

export default class EnrolledCourses extends LightningElement {
    @track data;
    @track error;
    @track columns = columns;
    @api contactIds;
    @track expandedRows;
    subscription = null;
    message;
    isSearch = false;

    label = { CoursesSelectMessage };

    @wire(MessageContext)
    messageContext;
    sortBy = "Name";
    sortDirection = "asc";

    connectedCallback() {
        
        this.expandedRows=[];
    }



    @wire(getCourses, { contactIds: '$contactIds' })
    wiredCourses({ error, data }) {
        if (data) {
            if ((data.length == 0 || data == null) && this.contactIds.length > 0) this.message = 'No Courses found for selected Contact!';
            else this.message = null;
            console.log('Data For Courses : ', data);
            console.log('Data For Courses : ' + JSON.stringify(data));
            let parentRows = [];
            let gridData = data.map(elt => {
                if (elt.hasOwnProperty('children') && Array.isArray(elt.children) && elt.children.length>0) {
                    parentRows.push(elt.recordId);
                    let { children, ...transformedData } = elt;
                    transformedData = { ...transformedData, '_children': children };
                    return transformedData;
                }
                return elt;

            })
            console.log('Grid Data : ', gridData);
            this.data = gridData;
            this.expandedRows = parentRows;
            this.error = undefined;
        }

        if (error) {
            console.error('Error occurred while calling apex : IntakeCaseController.getCourses : ', error);
            this.error = error;
            this.data = undefined
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
        let isReverse = this.sortDirection === 'asc' ? 1 : -1;
        parseData.sort((x, y) => {
            x = keyValue(x) ? keyValue(x) : '';
            y = keyValue(y) ? keyValue(y) : '';
            return isReverse * ((x > y) - (y > x));
        });
        this.data = parseData;
    }
}