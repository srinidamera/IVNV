import { LightningElement, wire, track,api } from 'lwc';
import { CloseActionScreenEvent } from 'lightning/actions';
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import getContacts from '@salesforce/apex/CourseManagementController.getContacts';
import createAttendees from '@salesforce/apex/CourseManagementController.createAttendees';
import modal from "@salesforce/resourceUrl/custommodalcss";
import { loadStyle } from "lightning/platformResourceLoader";
import { refreshApex } from '@salesforce/apex';
import { notifyRecordUpdateAvailable } from 'lightning/uiRecordApi';
import { formatPhoneNumber} from "c/lwrUtils";

export default class CourseEnrolment extends LightningElement {

    @api recordid;
    @track eventId;
    @track applicants;
    @track initialRecords;
    @track contactSelectedRows = [];
    @track selectedContactIds = [];
    @track removedContactIds = [];
    @track selectedOption = '';
    @track items = [];
    @api isParent;
    @api cousename;
    @api totalEnrolled;
    @api totalSeats;
    @api openSeats;
    @api courseComplete;
    @api courseIncomplete;
    @api attendeeIds;
    wiredResult;
    isSelected = false;
    buttonVariant = 'neutral';
    classSelection = true;
    contactSelection = false;
    sortedDirection = 'asc';
    sortBy = 'CreatedDate';
    showSpinner = true;

    connectedCallback() {
        this.eventId = this.recordid;
         loadStyle(this, modal);
      }

    get classCBoptions() {
        return [
            { label: 'Entire Course', value: 'Entire Course' },
            { label: 'Day 1 - 06/03/2024', value: 'Day 1 - 06/03/2024' },
            { label: 'Day 2 - 06/03/2024', value: 'Day 2 - 06/03/2024' },
            { label: 'Day 3 - 06/03/2024', value: 'Day 3 - 06/03/2024' },
            { label: 'Day 4 - 06/03/2024', value: 'Day 4 - 06/03/2024' },
            { label: 'Day 5 - 06/03/2024', value: 'Day 5 - 06/03/2024' },
            { label: 'Day 6 - 06/03/2024', value: 'Day 6 - 06/03/2024' },
            { label: 'Day 7 - 06/03/2024', value: 'Day 7 - 06/03/2024' },
            { label: 'Day 8 - 06/03/2024', value: 'Day 8 - 06/03/2024' },
            { label: 'Day 9 - 06/03/2024', value: 'Day 9 - 06/03/2024' },
            { label: 'Day 10 - 06/03/2024', value: 'Day 10 - 06/03/2024' },  
            { label: 'Day 11 - 06/03/2024', value: 'Day 11 - 06/03/2024' },
            { label: 'Day 12 - 06/03/2024', value: 'Day 12 - 06/03/2024' },           
        ];
    }

    @track applicantcolumns = [
        { label: 'First name', fieldName: 'FirstName', type: 'text', sortable: true},
        { label: 'Last name', fieldName: 'LastName', type: 'text', sortable: true},
        { label: 'Type', fieldName: 'Type', type: 'text', sortable: true},
        { label: 'Phone', fieldName: 'Phone', type: 'Phone', sortable: true},
        { label: 'Email', fieldName: 'Email', type: 'email', sortable: true}
        
    ];
    
    get options() {
        return [
            { label: 'First Name', value: 'FirstName' },
            { label: 'Last Name', value: 'LastName' },
            { label: 'Phone', value: 'Phone' },
            { label: 'Email', value: 'Email' }
        ];
    }

    get classOptions() {
        return [
						{ label: 'Series', value: 'Series' },
            { label: 'Class 1', value: 'option1' },
            { label: 'Class 2', value: 'option2' },
            { label: 'Class 3', value: 'option3' },
            { label: 'Class 4', value: 'option4' },
            { label: 'Class 5', value: 'option5' },
        ];
    } 

    get disableSave(){
        return !this.contactSelectedRows || this.contactSelectedRows.length == 0;
    }

    

    @wire(getContacts, {eventId: '$eventId'})
    wiredContacts(result){
        console.log('getContacts');
        this.wiredResult = result;
        if(this.wiredResult.data){
            console.log('data is '+JSON.stringify(this.wiredResult.data));
            let recs = JSON.parse(JSON.stringify(this.wiredResult.data));
            recs.forEach(record=>{
                if(record.RecordType !== null && record.RecordType !== undefined){
                record["Type"] = record.RecordType.Name
                }
                record.Phone = formatPhoneNumber(record.Phone);
            })
            this.applicants = recs;
            this.initialRecords = recs;
            this.showSpinner = false;
        }
        if(this.wiredResult.error){
            this.showSpinner = false;

        }
    }

    

    handleRadioChange(event) {
        this.selectedOption = event.detail.value;
       // this.buttonVariant = this.selectedOption === 'series' && this.isSelected ? 'brand' : 'neutral';
    }
    handleClick() {
        this.isSelected = !this.isSelected;
        //this.buttonVariant = 'brand';//this.selectedOption === 'series' && this.isSelected ? 'brand' : 'neutral';
    }

    handleNext(){
        this.classSelection = false;
        this.contactSelection = true;
    }

    handleChange(event){

    }

    handleClose(){
       
        this.dispatchEvent(new CustomEvent('close'));
        this.dispatchEvent(new CloseActionScreenEvent());
       
    }
 

    handleEnroll(){
        console.log('this.selectedContactIds##'+this.selectedContactIds);
        console.log('this.recordid###'+this.recordid);
        this.showSpinner = true;
       // const contactIds = this.selectedContactIds.map(contact => contact.Id);
        createAttendees({ contactIds: this.selectedContactIds, eventId: this.recordid , isParent: this.isParent})
            .then(result => {
                notifyRecordUpdateAvailable([{recordId: this.recordid}]);
                let message;
                if(this.isParent){
                    message = 'Successfully Enrolled into Course Series !!';
                }else{
                    message = 'Successfully Enrolled into Class !!';
                }
                refreshApex(this.wiredContacts);
                // Handle success, perhaps show a toast message
                const evt = new ShowToastEvent({
                    title: 'Success!!',
                    message: message,
                    variant: 'success',
                    });
                
            this.dispatchEvent(evt);
            this.showSpinner = false;
            this.handleClose();
            })
            .catch(error => {
                // Handle error, perhaps show a toast message
                console.log('error###'+JSON.stringify(error));
                this.showSpinner = false;
                const evt = new ShowToastEvent({
                    title: 'Error!! Unable to Enroll Contact(s).',
                    message: 'Looks like there are no seats left. Please try to enroll later or choose another course.',
                    variant: 'error',
                    });
                this.dispatchEvent(evt);
            });
        
        
    }

    onEnrolRow(event){
        this.items = [];
        this.contactSelectedRows = event.detail.selectedRows;
        console.log('contactSelectedRows '+JSON.stringify(this.contactSelectedRows));
        this.selectedContactIds = [];
        this.contactSelectedRows.forEach(record=>{
            let label = record.FirstName+' '+record.LastName;
            this.selectedContactIds.push(record.Id);
            this.removedContactIds.push(record);
            this.items.push({type: 'icon',
            label: label,
            name: record.Id,
            iconName: 'standard:contact',
            alternativeText: label,})
        });
        console.log('pillItems '+JSON.stringify(this.items));
        
    }

    async handleItemRemove(event) {
        
        const name = event.detail.item.name;
        const index = event.detail.index;
        console.log('index '+index);
        this.items.splice(index, 1);
        this.selectedContactIds.splice(index,1);
        this.selectedContactIds = [...this.selectedContactIds];
        console.log('removedContactIds remove '+JSON.stringify(this.removedContactIds));
        //this.selectedContactIds = this.removedContactIds;
        console.log('items remove '+JSON.stringify(this.items));
        console.log('rows remove '+JSON.stringify(this.selectedContactIds));
        await refreshApex(this.wiredContacts);
    }

    handleSearch(event) {
        this.items = [...this.items];
        console.log('this.items '+JSON.stringify(this.items));
        console.log('this.selectedContactIds '+JSON.stringify(this.selectedContactIds));
        const searchKey = event.target.value.toLowerCase();

        if (searchKey) {
            
            this.applicants = this.initialRecords;

            if (this.applicants) {
                let searchRecords = [];

                for (let record of this.applicants) {
                    let valuesArray = Object.values(record);

                    for (let val of valuesArray) {
                        console.log('val is ' + val);
                        let strVal = String(val);

                        if (strVal) {

                            if (strVal.toLowerCase().includes(searchKey)) {
                                searchRecords.push(record);
                                break;
                            }
                        }
                    }
                }

                console.log('Matched Accounts are ' + JSON.stringify(searchRecords));
                this.applicants = searchRecords;
            }
        } else {
            this.applicants = this.initialRecords;
        }
        //this.selectedContactIds = [...this.selectedContactIds];
    }

    sortColumns(event) {
        this.sortBy = event.detail.fieldName;
        this.sortedDirection = event.detail.sortDirection;
        this.sortData(this.sortBy, this.sortedDirection);
    }

    sortData(fieldname, direction) {
        let parseData = JSON.parse(JSON.stringify(this.initialRecords));
        // Return the value stored in the field
        let keyValue = (a) => {
            return a[fieldname];
        };
        // cheking reverse direction
        let isReverse = direction === 'asc' ? 1: -1;
        // sorting data
        parseData.sort((x, y) => {
            x = keyValue(x) ? keyValue(x) : ''; // handling null values
            y = keyValue(y) ? keyValue(y) : '';
            // sorting values based on direction
            return isReverse * ((x > y) - (y > x));
        });
        this.initialRecords = parseData;
        this.applicants = parseData;
    } 
}