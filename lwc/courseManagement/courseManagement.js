import { LightningElement,track, wire } from 'lwc';
import getCourses from '@salesforce/apex/CourseManagementController.getCourses';
import getContacts from '@salesforce/apex/CourseManagementController.getContacts';
import filterRows from '@salesforce/apex/CourseManagementController.filterRows';

export default class CourseManagement extends LightningElement {
    @track data;
    @track openenroll = false;
    @track applicants;
    @track courseSelectedRows;
    @track contactSelectedRows;
    @track initialRecords;
    @track startDateFilter = new Date().getFullYear()+'-01-01';
    @track endDateFilter = new Date().getFullYear()+'-12-31';
    isLoaded = !1;
    disabledFilter = true;
    disabledReset = true;
    @track searchText = '';

    //Used for enrollment related functionality
    get options() {
        return [
            { label: 'First Name', value: 'FirstName' },
            { label: 'Last Name', value: 'LastName' },
            { label: 'Phone', value: 'Phone' },
            { label: 'Email', value: 'Email' }
        ];
    }
    
    //Columns for the Course list table
    @track columns = [
        {
            label: 'Course Name',
            fieldName: 'cName',
            type: 'url',
            wrapText: true,
            sortable: true,
			initialWidth: 300,
            typeAttributes: {label: { fieldName: 'sumoapp__EventName__c' }, target: '_self'}
        },
        { label: 'Timeframe', fieldName: 'timeframe', type: 'text'},
        { label: 'Duration (in minutes)', fieldName: 'sumoapp__DurationInMinutes__c', type: 'number', cellAttributes: { alignment: 'center' }},
        { label: 'Facilitator', fieldName: 'facilitator', type: 'text'},
        { label: 'Total Enrolled', fieldName: 'TotalEnrolled__c', type: 'text', cellAttributes: { alignment: 'center' }},
        { label: 'Open Seats', fieldName: 'Open_Seats__c', type: 'text', cellAttributes: { alignment: 'center' }},
        { label: 'Category', fieldName: 'category', type: 'text'},
        { label: 'Delivery Type', fieldName: 'sumoapp__LocationType__c', type: 'text'},
        { label: 'Cost', fieldName: 'sumoapp__Price__c', type: 'currency', cellAttributes: { alignment: 'center' }},
        { label: 'Status', fieldName: 'sumoapp__Status__c', type: 'text', cellAttributes: { alignment: 'center' }}
        
    ];

    //Used for enrollment related table
    @track applicantcolumns = [
        { label: 'Applicant Last name', fieldName: 'LastName', type: 'text' },
        { label: 'Applicant First name', fieldName: 'FirstName', type: 'text' },
        { label: 'Phone', fieldName: 'Phone', type: 'Phone' },
        { label: 'Email', fieldName: 'Email', type: 'email' }
    ];

    toggleIconName = 'utility:collapse_all';
    toggleButtonLabel = 'Collapse All';

    // Handles click on the 'Show/hide content' button
    handleToggleClick() {
        // if the current icon-name is `utility:preview` then change it to `utility:hide`
        if (this.toggleIconName === 'utility:collapse_all') {
            this.toggleIconName = 'utility:expand_all';
            this.toggleButtonLabel = 'Expand All';
        } else {
            this.toggleIconName = 'utility:collapse_all';
            this.toggleButtonLabel = 'Collapse All';
        }
    }

    //Queries the courses on load
   @wire(getCourses)
    wiredCourses({ error, data }) {
    if ( data ) {
            let tempList = [];
            data.forEach((record) => {
                let tempRec = Object.assign({}, record);  
                tempRec.cName = '/' + tempRec.Id;
                if(tempRec.RecordType?.DeveloperName !== 'Event'){
                    tempRec.sumoapp__DurationInMinutes__c = tempRec.Total_Duration_In_Minutes__c;
                }
                
                //tempRec.sumoapp__StartDatetime__c = tempRec.sumoapp__StartDatetime__c+tempRec.sumoapp__EndDatetime__c;
                tempList.push(tempRec);
            });
        var tempData = JSON.parse( JSON.stringify( tempList ) );
        for ( var i = 0; i < tempData.length; i++ ) {
            var cons = tempData[ i ][ 'sumoapp__ChildEvents__r' ];
            if ( cons ) {
                let tempChildList = [];
                cons.forEach((record) => {
                    let tempRec = Object.assign({}, record);
                    tempRec.cName = '/' + tempRec.Id;
                    tempRec.timeframe = this.getformattedDate(tempRec.sumoapp__StartDatetime__c) + ' - ' + this.getformattedTime(tempRec.sumoapp__EndDatetime__c);
                    tempRec.facilitator = tempRec.Facilitator__c ? tempRec.Facilitator__r.Name : '';
                    tempRec.category = tempRec.sumoapp__Category__c ? tempRec.sumoapp__Category__r.sumoapp__Label__c : '';
                    tempChildList.push(tempRec);
                });
                tempData[ i ]._children = tempChildList;
                delete tempData[ i ].sumoapp__ChildEvents__r;
            } else {
                tempData[i].timeframe = this.getformattedDate(tempData[i].sumoapp__StartDatetime__c) + ' - ' + this.getformattedTime(tempData[i].sumoapp__EndDatetime__c);
                tempData[i].facilitator = tempData[i].Facilitator__c ? tempData[i].Facilitator__r.Name : '';
                tempData[i].category =  tempData[i].sumoapp__Category__c ? tempData[i].sumoapp__Category__r.sumoapp__Label__c : '';
            }
        }
        this.data = tempData;
    } else if ( error ) {
        console.log(JSON.stringify(error));
        if ( Array.isArray( error.body ) ){}
        else if ( typeof error.body.message === 'string' ){}
    }
}; 

//Used to initially expand all sections: on render 
renderedCallback(){
    if(this.data){
        if(this.toggleButtonLabel === 'Collapse All'){
            const grid =  this.template.querySelector('lightning-tree-grid');
            grid.expandAll();
        }else{
            const grid =  this.template.querySelector('lightning-tree-grid');
            grid.collapseAll();
        }
    }
}

//Used for enrollment related functionality
addEnrollment(){
    this.openenroll = true;
    getContacts()
    .then((result) => {
        this.applicants = result;
        this.initialRecords = result;
    })
    .catch((error) => {
    });
}

//hides the enrollment section
handleClose(){
    this.openenroll = false;
}

//Handler when course is selected
onCourseSelection(event){
    this.courseSelectedRows = event.detail.selectedRows;
}

//Handler when course is enrolled
onEnrolRow(event){
    this.contactSelectedRows = event.detail.selectedRows;    
}

//Handles combobox change 
handleChange(event){
}

//handles Search Contact
handleSearch(event) {
    const searchKey = event.target.value.toLowerCase();
    if (searchKey) {
        this.applicants = this.initialRecords;
        if (this.applicants) {
            let searchRecords = [];

            for (let record of this.applicants) {
                let valuesArray = Object.values(record);

                for (let val of valuesArray) {
                    let strVal = String(val);

                    if (strVal) {

                        if (strVal.toLowerCase().includes(searchKey)) {
                            searchRecords.push(record);
                            break;
                        }
                    }
                }
            }
            this.applicants = searchRecords;
        }
    } else {
        this.applicants = this.initialRecords;
    }
}

//Filters courses based on start and end date
    filterRows( e ){
        filterRows({searchKeyword: this.searchText, startDate: this.startDateFilter, endDate: this.endDateFilter })
		.then(result => {
            let tempList = [];
            result.forEach((res) => {
                let tempRec = Object.assign({}, res);  
                tempRec.cName = '/' + tempRec.Id;
                if(tempRec.RecordType?.DeveloperName !== 'Event'){
                    tempRec.sumoapp__DurationInMinutes__c = tempRec.Total_Duration_In_Minutes__c;
                }
                //tempRec.sumoapp__StartDatetime__c = tempRec.sumoapp__StartDatetime__c+tempRec.sumoapp__EndDatetime__c;
                tempList.push(tempRec);
                
            });
            var tempData = JSON.parse( JSON.stringify( tempList ) );
            for ( var i = 0; i < tempData.length; i++ ) {
                var cons = tempData[ i ][ 'sumoapp__ChildEvents__r' ];
                if ( cons ) {
                    let tempChildList = [];
                    cons.forEach((record) => {
                        let tempRec = Object.assign({}, record);  
                        tempRec.cName = '/' + tempRec.Id;
                        tempRec.timeframe = this.getformattedDate(tempRec.sumoapp__StartDatetime__c) + ' - ' + this.getformattedTime(tempRec.sumoapp__EndDatetime__c);
                        tempRec.facilitator = tempRec.Facilitator__c ? tempRec.Facilitator__r.Name : '';
                        tempRec.category = tempRec.sumoapp__Category__c ? tempRec.sumoapp__Category__r.sumoapp__Label__c : '';
                        tempChildList.push(tempRec);
                    });
                    tempData[ i ]._children = tempChildList;
                    delete tempData[ i ].sumoapp__ChildEvents__r;
                } else {
                    tempData[i].timeframe = this.getformattedDate(tempData[i].sumoapp__StartDatetime__c) + ' - ' + this.getformattedTime(tempData[i].sumoapp__EndDatetime__c);
                    tempData[i].facilitator = tempData[i].Facilitator__c ? tempData[i].Facilitator__r.Name : '';
                    tempData[i].category = tempData[i].sumoapp__Category__c ? tempData[i].sumoapp__Category__r.sumoapp__Label__c : '';
                }
            }
            this.data = tempData;
            this.toggleIconName = 'utility:collapse_all';
            this.toggleButtonLabel = 'Collapse All';
		})
		.catch(error => {
			if ( Array.isArray( error.body ) ){}
            else if ( typeof error.body.message === 'string' ){}
		})
    }
    //Populates startDateFilter on change
    startDateChange(event){
        this.startDateFilter= event.target.value;
        if(this.startDateFilter && this.endDateFilter){
            this.disabledFilter = false;
        }else{
            this.disabledFilter = true;
        }
        this.disabledReset = false;
    }
    //Populates endDateFilter on change
    endDateChange(event){
        this.endDateFilter= event.target.value;
        if(this.startDateFilter && this.endDateFilter){
            this.disabledFilter = false;
        }else{
            this.disabledFilter = true;
        }
        this.disabledReset = false;
    }
    //Returns datetime in formet: Aug 5, 2024, 10:30PM
    getformattedDate(dtTime){
        let dt = new Date(dtTime);
        let mnth = dt.toLocaleString('default', { month: 'short' });
        let formattedDate;
        formattedDate = mnth + ' ' + dt.getDate() + ', ' + dt.getFullYear() + ', ' + this.getformattedTime(dtTime);
        return formattedDate;
    }
    //Returns time in format: 11:30PM
    getformattedTime(dtTime){
        let dt = new Date(dtTime);
        var hours = dt.getHours();
        var minutes = dt.getMinutes();
        var ampm = hours >= 12 ? 'PM' : 'AM';
        hours = hours % 12;
        hours = hours ? hours : 12; // the hour '0' should be '12'
        minutes = minutes < 10 ? '0'+minutes : minutes;
        var strTime = hours + ':' + minutes + ampm;
        return strTime;
    }

    searchRecords(event){
        this.searchText = event.detail.value;
        this.filterRows(event);
        this.disabledReset = false;
        console.log('this.searchText : '+this.searchText);
        if(this.searchText != ''){
            this.disabledReset = false;
        } else {
            this.disabledReset = true;
        }
    }

    resetRows(event){
        this.startDateFilter = new Date().getFullYear()+'-01-01';
        this.endDateFilter = new Date().getFullYear()+'-12-31';
        this.searchText = '';
        this.filterRows(event);
        this.disabledFilter = true;
        this.disabledReset = true;
    }
}