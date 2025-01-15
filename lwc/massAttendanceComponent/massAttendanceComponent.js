import { LightningElement, wire, api, track } from 'lwc';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import { refreshApex } from '@salesforce/apex';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getAttendees from '@salesforce/apex/MassAttendanceComponentController.getAttendees';
import getCourseSeries from '@salesforce/apex/MassAttendanceComponentController.getCourseSeries';
import getContactDetail from '@salesforce/apex/MassAttendanceComponentController.getContactDetail';
import getCourses from '@salesforce/apex/IntakeCaseController.getCourses';
import SUMO_EVENT_FIELD from '@salesforce/schema/sumoapp__AdditionalInfo__c.Id';
import SUMO_Parent from '@salesforce/schema/sumoapp__AdditionalInfo__c.IsParent__c';
import ATTENDEE_OBJECT from '@salesforce/schema/sumoapp__Attendee__c';
import updateAttendeeAttendance from '@salesforce/apex/AttendeeController.updateAttendeeAttendance';
import { NavigationMixin } from 'lightning/navigation';
import CONTACT_REL from '@salesforce/schema/sumoapp__Attendee__c.sumoapp__ContactRelation__c';
import HOUSEHOLD_OF_AMI from '@salesforce/schema/sumoapp__Attendee__c.HouseholdofAMI__c';
import AREA_MEDIAN_INCOME from '@salesforce/schema/sumoapp__Attendee__c.AreaMedianIncome__c';
import RURAL_AREA_STATUS from '@salesforce/schema/sumoapp__Attendee__c.RuralAreaStatus__c';
import ATTENDANCE_STATUS from '@salesforce/schema/sumoapp__Attendee__c.Attendance_Status__c';
import NOTES from '@salesforce/schema/sumoapp__Attendee__c.Notes__c';
import DECLINE_REASON from '@salesforce/schema/sumoapp__Attendee__c.sumoapp__DeclineReason__c';
import DECLINE_REASONOPTION from '@salesforce/schema/sumoapp__Attendee__c.sumoapp__DeclineReasonOption__c';
import { updateRecord } from "lightning/uiRecordApi";
import { notifyRecordUpdateAvailable } from 'lightning/uiRecordApi';
import isIntakeStaff from '@salesforce/customPermission/IntakeStaff';

const ATTENDANCE_STATUS_OPTIONS = [
    { label: 'No Show', value: 'No Show' },
    { label: 'Attended - Incomplete', value: 'Attended - Incomplete' },
    { label: 'Attended - Complete', value: 'Attended - Complete' } 
];

const COURSE_ATTENDANCE_STATUS_OPTIONS = [
    { label: 'Course Complete', value: 'Course Complete' },
    { label: 'Course Incomplete', value: 'Course Incomplete' } 
];

const actions = [
     { label: 'View', name: 'view' },
  ];

const columns = [
    {
        type: 'button-icon',
        initialWidth: 5,
        typeAttributes:
        {
            iconName: 'utility:user',
            name: 'userHistory',
            iconClass: { fieldName: 'iconClass' },
            variant: 'bare'
        }
    },
    
    {label: 'Household',fieldName: 'accountName' , type: 'text'},
    {label: 'Name',fieldName: 'attendeeName' , type: 'text'},
    {label: 'Type',fieldName: 'Type' , type: 'text'},
    {label: 'Attendance Status',fieldName: 'Attendance_Status__c' , type: 'text', sortable: true },
    {label: 'Notes',fieldName: 'Notes__c' , type: 'text', sortable: true },
    {
        initialWidth: 34,
        type: 'button-icon',
        typeAttributes:
        {
            iconName: 'utility:edit',
            name: 'edit',
            title: 'Edit',
            variant: 'container',
            hideLabel: true,
        }
    },
    {
        type: 'action',
        typeAttributes: {
            rowActions: actions,
            menuAlignment: 'right'
        }
    }
];


const prospectColumns = [
    {label: 'Name', type: 'text', fieldName: 'Name', hideDefaultActions: true},
    {label: 'Type', type: 'text', fieldName: 'Type', hideDefaultActions: true}
];

const FIELDS = ["sumoapp__AdditionalInfo__c.Id", "sumoapp__AdditionalInfo__c.IsParent__c", "sumoapp__AdditionalInfo__c.sumoapp__RegisteredAttendeeCount__c", "sumoapp__AdditionalInfo__c.sumoapp__Capacity__c", "sumoapp__AdditionalInfo__c.TotalEnrolled__c", "sumoapp__AdditionalInfo__c.Open_Seats__c", "sumoapp__AdditionalInfo__c.RecordType.DeveloperName", "sumoapp__AdditionalInfo__c.sumoapp__IsRecurring__c"];


export default class massAttendanceManagement extends NavigationMixin (LightningElement){
 
    @track gridColumns = [
        { label: 'Course Name', fieldName: 'courseLink', type: 'url', typeAttributes: { label: { fieldName: 'courseName' }, target: '_blank' }, sortable: "true" },
        { label: 'Date', fieldName: 'startDate', sortable: "true", type: 'date' },
        { label: 'Attendance Status', fieldName: 'status', sortable: "true" },
        { label: 'Facilitator', fieldName: 'facilitator', sortable: "true" },
        { label: 'Notes', fieldName: 'notes', sortable: "true" }
    ];

    @track expandedRows;
    @api recordId;
    @track attendees = [];
    @track session;
    @track error;
    @track shouldShowSearch = false;
    @track searchKey = '';
    @track numOfFilteredAttendees = 0;
    @track cardheading = 'Course Attendance';
    @track notes;
    @track isParent;
    @track isRecurring;
    @track totalEnrolled;
    @track totalSeats;
    @track openSeats;
    @track courseComplete;
    @track courseIncomplete;
    @track isModalOpen = false;
    @track isEnrollmentModalOpen = false;
    isAttendanceStatus = false;
    saveDraftValues = [];
    columns = columns;
    prospectColumns = prospectColumns;
    @track prospectData = [];
    @track checkboxValue;
    @track isCheckDisabled = true;
    prospectContactIds = [];
    prospectAndPrimaryClientContactIds = [];
    enableSaveAtteendance = true;
    selectedRows = [];
    selectedRowIds = [];
    wiredResult;
    wiredGetAddInfoCurrentRecord;
    attendanceStatus;

    modalHeader = 'Add Notes';
    isEdit = false;
    isUserHistorty = false;
    modalClass = 'slds-modal slds-fade-in-open';

    objectApiName = 'sumoapp__Attendee__c';
    currentRowId;
    householdField = HOUSEHOLD_OF_AMI;
    amiField = AREA_MEDIAN_INCOME;
    ruralStatusField = RURAL_AREA_STATUS;
    attendStatusField = ATTENDANCE_STATUS;
    notesField = NOTES;
    declineReasonField = DECLINE_REASON;
    declineOptionField = DECLINE_REASONOPTION;

    @track attendeeId = [];
    


    objectApiName = 'sumoapp__Attendee__c';

    conRelaField = CONTACT_REL;

    get disableSaveAtteendance(){
        return !this.selectedRows || this.selectedRows.length == 0 || isIntakeStaff;
    }

    openEnrollmentModal() {
        this.isEnrollmentModalOpen = true;
    }

    closeEnrollmentModal() {
        this.isEnrollmentModalOpen = false;       
        refreshApex(this.wiredResult);

    }

    @wire(getRecord, {
        recordId: "$recordId",
        fields: ["sumoapp__AdditionalInfo__c.IsParent__c","sumoapp__AdditionalInfo__c.SessionName__c","sumoapp__AdditionalInfo__c.sumoapp__EventName__c"]
    })
    getCurrentRecord({data, error}){
        console.log('record data '+JSON.stringify(data));
        if(data!=undefined) {
            if(data.fields.IsParent__c.value === true){
                //this.isParent = true;
                this.session = data.fields.sumoapp__EventName__c.value;
            }else{
                //this.isParent = false;
                this.session = data.fields.SessionName__c.value;
            }

        }
    }

    handleFormSubmitted(event){
        event.preventDefault();
        this.template.querySelector("lightning-record-edit-form").submit();
    }

     handleSuccess(event){
        console.log('enter handle success');
        refreshApex(this.wiredResult);
        this.isEdit = false;
        this.isModalOpen = false;
        const toastEvent = new ShowToastEvent({
            title: 'Success',
            message: 'Attendance saved successfully',
            variant: 'success',
        });
        this.dispatchEvent(toastEvent); 
        this.showSpinner = false;
    }

    handleError(event){
        console.log('enter handle error');
    }

    /**
     * Updates Attendee Data
     */
    updateDataValues(updateItem) {
        let copyData = [... this.attendees];
        copyData.forEach(item => {
            if (item.Id === updateItem.Id) {
                for (let field in updateItem) {
                    item[field] = updateItem[field];
                }
            }
        });

        this.attendees = [...copyData];
    }

    /**
     * Updates Selected draft values
     */
    updateDraftValues(updateItem) {
        let draftValueChanged = false;
        let copyDraftValues = [...this.saveDraftValues];
        copyDraftValues.forEach(item => {
            if (item.Id === updateItem.Id) {
                for (let field in updateItem) {
                    item[field] = updateItem[field];
                }
                draftValueChanged = true;
            }
        });

        if (draftValueChanged) {
            this.saveDraftValues = [...copyDraftValues];
        } else {
            this.saveDraftValues = [...copyDraftValues, updateItem];
        }
    }

    handleAttendanceSave() {
        this.modalHeader = 'Attendance Status';
        this.isModalOpen = true;
        this.isEdit = false;
        this.isAttendanceStatus = true;
    }

    closeModal(){
        this.isModalOpen = false;
        this.isAttendeeModalOpen = false;
    }

    handleAttendanceStatusChange(event) {
        const attendeeId = event.target.dataset.key;
        this.attendanceStatus =  event.detail.value;
        this.isAttendanceStatus = true;
        if(this.attendanceStatus === 'Course Complete' || this.attendanceStatus === 'Attended - Complete'){
            this.isCheckDisabled = false;
        }else{
            this.isCheckDisabled = true;
            this.checkBoxValue = false;
        }
    }

    saveRow(event){
        console.log(this.attendanceStatus);
        if(this.isAttendanceStatus){
            updateAttendeeAttendance({attendeeIds: this.selectedRowIds, status : this.attendanceStatus,
                convertProspect : this.checkboxValue, 
                prospectContactIds: this.prospectContactIds,
                prospectAndPrimaryClientContactIds: this.prospectAndPrimaryClientContactIds })
            .then(result=>{
                notifyRecordUpdateAvailable([{recordId: this.recordId}]);
                console.log('result '+JSON.stringify(result));
                refreshApex(this.wiredResult);
                refreshApex(this.wiredAdditionalInfo);
                refreshApex(this.wiredGetAddInfoCurrentRecord);

                const toastEvent = new ShowToastEvent({
                    title: 'Success',
                    message: 'Attendance saved successfully',
                    variant: 'success',
                });
                this.dispatchEvent(toastEvent); 
                this.selectedRowIds = [];
                this.selectedRows = [];
                this.isModalOpen = false;
                refreshApex(this.wiredResult);
            })
            .catch(error=>{
                console.log('error->'+ JSON.stringify(error));
            })
        }

    }

    /**
     * Handles picklist change in datatable
     */
    picklistChanged(event) {
        event.stopPropagation();
        this.enableSaveAtteendance = false;
        let dataRecieved = event.detail.data;
        let updatedItem = { Id: dataRecieved.context, Attendance_Status__c: dataRecieved.value };
        this.updateDraftValues(updatedItem);
        this.updateDataValues(updatedItem);
    }
    /**
     * Handles input change in datatable
     */
    inputChanged(event) {
        event.stopPropagation();
        this.enableSaveAtteendance = false;
        let dataRecieved = event.detail.data;
        let updatedItem = { Id: dataRecieved.context, Notes__c: dataRecieved.value };
        this.updateDraftValues(updatedItem);
        this.updateDataValues(updatedItem);
    }

    getSelectedRows(event) {
        this.selectedRows = event.detail.selectedRows;
        this.selectedRowIds = [];
        this.prospectData = [];
        this.prospectContactIds = [];
        this.prospectAndPrimaryClientContactIds = [];
        this.selectedRows.forEach(record=>{
            this.selectedRowIds.push(record.Id);
            if(record.sumoapp__ContactRelation__r.RecordType.Name === 'Prospect'){
                this.prospectContactIds.push(record.sumoapp__ContactRelation__r.Id);
                this.prospectData.push({'Id':record.sumoapp__ContactRelation__r.Id, 'Name':record.sumoapp__ContactRelation__r.Name , 'Type':'Prospect'});
            }
            if(record.sumoapp__ContactRelation__r.RecordType.Name === 'Prospect' || record.sumoapp__ContactRelation__r.RecordType.Name === 'Primary Client'){
                this.prospectAndPrimaryClientContactIds.push(record.sumoapp__ContactRelation__r.Id);
            }
        })
        console.log('selectedRows '+JSON.stringify(this.selectedRows));
    }

    handleCheckboxValue(event){
        this.checkboxValue = event.detail.checked;
    }
    
    /**
     * Handles cell change in datatable
     */
    handleCellChange(event) {
        this.updateDraftValues(event.detail.draftValues[0]);
    }

    /**
     * Gets the attendees for the event
     */
    @wire(getAttendees, { additionalInfoId: '$recordId'}) 
    wiredAdditionalInfo(result) {
        
        this.wiredResult = result;
        const {data, error} = result;
        
        if (data) {
            this.additionalInfoRecord = JSON.parse(JSON.stringify(data));
            this.loadAttendees();
        } else if (error) {
            this.error = error;
        }
    } 

    /**
     * Gets Attendee object info
     */
    @wire(getObjectInfo, { objectApiName: ATTENDEE_OBJECT }) attendeeObjectInfo;

    /**
     * Gets the current event data and metrics
     */
    @wire(getRecord, {
        recordId: "$recordId",
        fields: FIELDS
    })
    getAddInfoCurrentRecord(result){
        this.wiredGetAddInfoCurrentRecord = result;
        const {data, error} = result;
        if(data) {
            this.isRecurring = data.fields.sumoapp__IsRecurring__c.value;
            if(data.fields.IsParent__c.value === true && data.fields.RecordType.displayValue !== 'Event'){
                this.isParent = true;
                getCourseSeries({ 
                    additionalInfoId: this.recordId
                })
                .then(result =>{ 
                    this.courseComplete = result.totalCourseComplete;
                    this.courseIncomplete = result.totalCourseIncomplete;
                    
                } 
                    ) 
                    .catch(error =>{ 
                        
                    }) 
                

            }else{
                this.isParent = false;
                this.totalEnrolled = data.fields.TotalEnrolled__c.value;
                this.totalSeats = data.fields.sumoapp__Capacity__c.value;
                this.openSeats = data.fields.Open_Seats__c.value;
            }
        } if(error){
            console.log(JSON.stringify(error));
        }
    }

    get attendanceStatusOptions(){
        if(this.isParent)
        {
            this.cardheading = 'Course Attendance';
            return COURSE_ATTENDANCE_STATUS_OPTIONS;
        } 
        else{
            this.cardheading = 'Class Attendance';
            return ATTENDANCE_STATUS_OPTIONS;
        } 
    }

    /**
     * Maps Attendees
     */
    loadAttendees() {
        if (this.additionalInfoRecord) {
                try {
                   this.additionalInfoRecord.forEach(attendee => {
                       this.attendeeId.push(attendee.Id);
                       attendee.Type = attendee.sumoapp__ContactRelation__r.RecordType.Name;
                       attendee.attendeeName = attendee.sumoapp__ContactRelation__r.Name; 
                       attendee.accountName = attendee.sumoapp__ContactRelation__r.Account.Name
                       if(attendee.sumoapp__Status__c === 'BOOKED'){
                        attendee.status = 'Registered';
                       }else{
                       attendee.status = attendee.sumoapp__Status__c; // Default status to 'Registered'
                       }
                       attendee.isSelected = false; 
                       attendee.isVariant =  'success';
                       attendee.iconClass = '';
                       attendee.isSize = 'small';
                   });
                   
                   this.attendees = this.additionalInfoRecord;
                } catch (error) {
                    this.error = error.body.message;
                }
        }
    }

    handleRowLevelAct(event) {
        const recordId = event.detail.row.Id
        const actionName = event.detail.action.name;
        console.log('row =>',actionName);
        const row = event.detail.row;
        this.currentRowId = row.Id;
        this.actionType = event.detail.action.name;
        console.log('currentRowId= '+this.currentRowId);
        console.log('row '+JSON.stringify(row));
        
        this.modalClass = 'slds-modal slds-fade-in-open';
            switch (actionName) {
                case 'view':
                    this[NavigationMixin.Navigate]({
                        type: 'standard__recordPage',
                        attributes: {
                            recordId: recordId,
                            objectApiName: 'sumoapp__Attendee__c',
                            actionName: 'view'
                        }
                    });
                break;
                case 'edit':
                this.isEdit = true;
                this.isUserHistorty = false;
                this.isAttendanceStatus = false;
                this.modalHeader = 'Edit Attendee Record';
                this.isModalOpen = true;
                break;
                case 'userHistory':
                this.isNotes = false;
                this.isEdit = false;
                this.isDecline = false;
                this.isUserHistorty = true;
                this.isAttendanceStatus = false;
                this.modalClass = 'slds-modal slds-fade-in-open slds-modal_large';
                this.modalHeader = 'Courses Attended';
                this.openModal(event);
                break;
        
            }
        }
    @track isAttendeeModalOpen;
    @track selectedContact;
    openModal(event){
        const row = event.detail.row;
        this.isAttendeeModalOpen = true;

        const contactId = row.sumoapp__ContactRelation__r.Id;
        this.fetchContactDetailsById(contactId);
        this.fetchCourseDetails(contactId);
    }
    
    @track gridData;


    fetchCourseDetails(contactId){
        let contactIdsList = [];
        contactIdsList.push(contactId)
        getCourses({ contactIds:  contactIdsList})
        .then(data => {
            console.log('data ==>',data);
            if (data) {
                if ((data.length == 0 || data == null) && this.contactIds.length > 0) this.message = 'No Courses found for selected Contact!';
                else this.message = null;
                console.log('Data For Courses : ', data);
                console.log('Data For Courses : ' + JSON.stringify(data));
                let parentRows = [];
                let tempGgridData = data.map(elt => {
                    if (elt.hasOwnProperty('children') && Array.isArray(elt.children) && elt.children.length>0) {
                        parentRows.push(elt.recordId);
                        let { children, ...transformedData } = elt;
                        transformedData = { ...transformedData, '_children': children };
                        return transformedData;
                    }
                    return elt;
    
                })
                console.log('Grid Data : ', tempGgridData);
                this.gridData = tempGgridData;
                this.expandedRows = parentRows;
                this.error = undefined;
            }
        })
        .catch(error => {
            console.error('Error:', error);
        });
    }

    fetchContactDetailsById(contactId) {
        getContactDetail({ contactId:  contactId})
        .then(result => {
            console.log('res ==>', result);
            if(result){
                this.selectedContact = result;
            }
        })
        .catch(error => {
            console.error('Error:', error);
        });
    }

    get contactName(){
        if(this.selectedContact){
            return this.selectedContact.Name;
        }
        return '';
    }

    get contactHouseHold(){
        if(this.selectedContact && this.selectedContact.Account){
            return this.selectedContact.Account.Name;
        }
        return '';
    }
    showRosterPdf = false;
    rosterUrl;
    @track height = '900px';
    @track referrerPolicy = 'no-referrer';
    @track sandbox = '';
    @track width = '100%';
    /**
     * Handles Roster for the event
     */
    handleRoster() {
        this.rosterUrl = '/apex/printRosterPdf?Id=' + this.recordId;
        this.showRosterPdf = true;
    }

    closePrintRosterModal(){
        this.showRosterPdf = false;
    }

    /**
     * Handles key search in datatable
     */
    handleSearchChange(event) {
        this.searchKey = event.target.value.toLowerCase();
    }

    showPrintCertificateModal = false;
    certificateUrl;
    certificateUrls = [];

    handlePrintCertificate(event){
        let attendesByHousehold = new Map();
        let primaryAttendeeByHousehold = new Map();
        
        this.selectedRows.forEach(record=>{
            if(record.sumoapp__ContactRelation__c && record.sumoapp__ContactRelation__r.AccountId){
                if(attendesByHousehold.has(record.sumoapp__ContactRelation__r.AccountId)){
                    attendesByHousehold.set(record.sumoapp__ContactRelation__r.AccountId, (attendesByHousehold.get(record.sumoapp__ContactRelation__r.AccountId) + ';;;;' + record.sumoapp__ContactRelation__c));
                } else {
                    attendesByHousehold.set(record.sumoapp__ContactRelation__r.AccountId, record.sumoapp__ContactRelation__c);
                }

                if(record.Type == 'Primary Client' || !primaryAttendeeByHousehold.has(record.sumoapp__ContactRelation__r.AccountId)){
                    primaryAttendeeByHousehold.set(record.sumoapp__ContactRelation__r.AccountId, record.Id);
                } 
            }
        })

        if(attendesByHousehold && attendesByHousehold.keys() && attendesByHousehold.keys()){
            Array.from(attendesByHousehold.keys()).forEach(record=>{
                let attendeeId= primaryAttendeeByHousehold.has(record) ? primaryAttendeeByHousehold.get(record) : '';
                this.certificateUrls.push('/apex/CourseCompletionCertificate?attendeeId='+ attendeeId +'&Ids=' + attendesByHousehold.get(record));
            })
            this.showPrintCertificateModal = true;
        }

        /*attendesByHousehold.keys().forEach(record=>{
            let attendeeId= primaryAttendeeByHousehold.has(record) ? primaryAttendeeByHousehold.get(record) : '';
            this.certificateUrls.push('/apex/CourseCompletionCertificate?attendeeId='+ attendeeId +'&Ids=' + attendesByHousehold.get(record));
        })
        this.showPrintCertificateModal = true;*/
    }

    closePrintCertificateModal(){
        this.certificateUrls = [];
        this.showPrintCertificateModal = false;
    }

    get disablePrintCertificate(){
        return !this.selectedRows || this.selectedRows.length == 0 || isIntakeStaff;
    }

    get showPrintCertificate(){
        return this.isParent || !this.isRecurring;
    }
}