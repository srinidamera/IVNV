import { LightningElement, api, wire, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import getEvents from '@salesforce/apex/ActivityTimelineController.getEvents';
import getAppointmentRecordTypeId from '@salesforce/apex/ActivityTimelineController.getAppointmentRecordTypeId';
import { getRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { notifyRecordUpdateAvailable } from 'lightning/uiRecordApi';
import updateAppointmentNotes from '@salesforce/apex/ActivityTimelineController.updateAppointmentNotes';
import isIntakeStaffUser from "@salesforce/apex/ActivityTimelineController.isIntakeStaffUser";

import { getObjectInfo, getPicklistValuesByRecordType } from 'lightning/uiObjectInfoApi';
import EVENT_OBJECT from '@salesforce/schema/Event';


export default class ActivityTimeline extends NavigationMixin(LightningElement) {

    @api recordId;
    @api objectApiName;
    showCaseManagement = true
    showAppointment = true
    showCourse = true

    showModal = false;
    selectedRecord = {};
    durationOptions = [];
    typeOptions = [];
    showAppointmentModal = false;
    @track eventData;
    @track masterData;
    activeSections;
    clientName;
    parentContact;

    @track eventRecordTypeId;

    @track purposeValues;
    @track outcomeMatrix;

    @track outcomeValues;
    @track appointmentStatusValue;
    @track selectedOutcomes = [];


    // Updated
    @track actionPlans = [];
    showSpinner = false;
    showSpinnerPopup = false;
    @track actionPlanWrapper;
    showNewOrEditModal = false;
    @track selectedRecord;
    @track goalTypePicklistOptions = [];
    @track goalStatusPicklistOptions = [];
    @track goalDefaultValuesPicklistOptions = [];
    @track showPrintActionModal = false;
    @track solutionStatusPicklistOptions = [];
    @track solutionDefaultValuesPicklistOptions = [];
    @track obstacleDefaultValuesPicklistOptions = [];
    @track appointmentStatusValues=[];
    @track hudActivityValues=[];

    @track height = '900px';
    @track referrerPolicy = 'no-referrer';
    @track sandbox = '';
    @track width = '100%';
    // till this

    isClientCase = false;
    showPrintButton = false;

    notesLabel = 'Notes';
    newNotesLabel = 'New Notes';
    hideNotesToggle = false;

    @wire(getAppointmentRecordTypeId) 
    processEventObject({error, data}) {
        if(data) {
            console.log('Object Info : ',JSON.parse(JSON.stringify(data)))
            this.eventRecordTypeId = data;
        }
    }

    @wire(getRecord, { recordId: '$recordId', layoutTypes: ["Full"]})
    wiredRecord({ error, data }) {
        if (data && data.apiName === 'ClientCase__c') {
            console.log('Data : ', data);
            this.isClientCase = true;
            this.notesLabel = 'Case Managment Note';
            this.newNotesLabel = 'New Case Managment Note';
            this.clientName = data?.fields?.ClientCaseName__c?.value;
            this.parentContact = data?.fields?.PrimaryClient__c?.value;
        }

        if(data && (data.apiName==='ClientCase__c' || data.apiName==='Contact')) {
            this.showPrintButton =true;
        }
    }

    get isIntakeClientCase(){
        if(this.objectApiName == 'ClientCase__c' || this.objectApiName == 'Intake__c'){
            this.showCourse = false;
            return true;
        }
        return false;
    }

    @wire(getPicklistValuesByRecordType, { objectApiName: EVENT_OBJECT, recordTypeId: '$eventRecordTypeId' })
    processAllPicklists({ error, data }) {
        if (data) {
            console.log('Data for Picklist Values : ', JSON.parse(JSON.stringify(data)))
            let outcomeValues = data.picklistFieldValues?.Outcome__c?.values;
            let purposeValues = data.picklistFieldValues?.Purpose__c.values;
            this.appointmentStatusValues = data.picklistFieldValues?.AppointmentStatus__c.values;
            this.hudActivityValues = data.picklistFieldValues?.HUDActivityType__c.values;

            let controllingMap = {}
            let dependencyMatrix = {};
            let controllingValues = data.picklistFieldValues?.Outcome__c?.controllerValues;
            for (let key in controllingValues) {
                let value = controllingValues[key];
                controllingMap[value] = key;

                dependencyMatrix[key] = [];
            }



            data.picklistFieldValues?.Outcome__c?.values.forEach(elt => {
                elt.validFor.forEach(ind => {
                    dependencyMatrix[controllingMap[ind]].push(elt);
                })
            })

            console.log('Dependency Matrix', dependencyMatrix);

            this.outcomeMatrix = dependencyMatrix;
            this.purposeValues = purposeValues;




            console.log('Outcome Values : ', outcomeValues);
            console.log('Purpose Values : ', purposeValues);
            console.log('Controlling Map : ', controllingMap);


        }
    }

    connectedCallback() {
        if(this.objectApiName === 'Intake__c'){
            this.hideNotesToggle = true;
            this.showCaseManagement = false;
        }
        
        this.fetchAndPopulateData();
        this.isIntakeStaffUser();
    }
    /*
    renderedCallback() {
        if(this.objectApiName == 'Contact'){
            let notesToggle = this.template.querySelector(".notesToggle");
            notesToggle.checked = false;
        }
    }
    */

    @track isIntakeUser = false;
    isIntakeStaffUser() {
        isIntakeStaffUser().then((result) => {
        this.isIntakeUser = result;
        if(this.isIntakeUser && this.objectApiName == 'ClientCase__c'){
            this.showCaseManagement = false;
        }
        
        }).catch((error) => {
        console.log('ERROR !!!'+JSON.stringify(error))
        });
    }

    fetchAndPopulateData() {
        getEvents({ recordId: this.recordId }).then((data) => {
            this.activeSections = data.map((elt) => elt.title);
            this.masterData = JSON.parse(JSON.stringify(data));
            this.eventData = JSON.parse(JSON.stringify(data));
            console.log('Data from Callout : ', JSON.parse(JSON.stringify(data)));
        }).catch(e => {
            console.log('Error : ', e)
        })


    }

    //@description : To Display related details for the given record
    handleActivityDisplay(event) {
        let locator = event.target.dataset.locator;
        //console.log('Locator : ', locator);
        let mainDiv = this.template.querySelector(`[data-id="${locator}"]`);

        let classList = mainDiv.classList;
        classList.toggle('slds-is-open');
        let iconName = event.target.iconName;
        if (iconName === 'utility:chevrondown') {
            event.target.iconName = 'utility:chevronright';
        } else {
            event.target.iconName = 'utility:chevrondown';
        }
    }

    //@description : to Handle display of Notes
    handleCaseManagementToggle(event) {
        console.log('Event Checked : ' + event);
        console.log(event.detail.checked);
        this.showCaseManagement = event.detail.checked;
    }

    //@description : to Handle display of Appointments
    handleAppointmentToggle(event) {
        console.log(event.detail.checked);
        this.showAppointment = event.detail.checked;
    }

    //@description : to Handle display of Courses
    handleCoursesToggle(event) {
        console.log(event.detail.checked);
        this.showCourse = event.detail.checked;
        //this.processVisibility();
    }

    //@Description : Close the modal without saving changes
    handleCancel() {
        this.selectedRecord = {};
        this.showModal = false;
    }

    //@Description : Save counselor Note with ClientCase and Contact
    handleSave() {
        console.log('Inside Save : ');
        this.template.querySelector('lightning-record-edit-form').submit();
        this.refs.noteSaveForm.submit();

    }

    //@Description : Save Appointment with ClientCase and Contact
    handleNoteCreateSubmit(event) {
        event.preventDefault();
        let fields = event.detail.fields;
        console.log('Event Fields : ' + fields);
        fields["ClientCase__c"] = this.recordId;
        fields["Contact__c"] = this.parentContact;
        this.refs.noteSaveForm.submit(fields);
    }

    //@Description : Show Success Toast, and re fetch the data.
    handleNoteCreationSuccess(event) {
        this.fetchAndPopulateData();
        this.handleCancel();
        const toast = new ShowToastEvent({
            title: 'Success!',
            message: 'Counselor Note Created Successfully',
            variant: 'success'
        });
        this.dispatchEvent(toast);
    }

    //@description : Open the modal for adding new notes
    handleNew() {
        this.showModal = true;
    }

    //@description : To edit Notes
    handleEditNote() {
        this.selectedRecord = this.noteRecord;
        this.showModal = true;
    }

    @track notesInputObj = {
        eventId: '',
        contactName: '',
        funder: '',
        outcome: '',
        purpose: '',
        hudActivity: '',
        durationInMin: undefined,
        notes: '',
        sumoAdditionalInfoRecId: undefined,
        notesDurationDate: '',
        appointmentStatus:''
    };

    //@description : To edit Apointment related information
    openAppointmentModal(event) {
        console.log('inside openAppointmentModal');
        const index = event.currentTarget.dataset.index;
        const parentIndex = event.currentTarget.dataset.parentIndex;
        console.log('123 : ' + parentIndex);
        this.selectedRecord = this.eventData[parentIndex].eventList[index];
        console.log('123 : ' + JSON.stringify(this.selectedRecord));
        this.notesInputObj.eventId = this.selectedRecord.recordId;
        this.notesInputObj.contactName = this.selectedRecord.contactName;
        /*this.notesInputObj.funder = this.selectedRecord.funder;
        this.notesInputObj.outcome = this.selectedRecord.outcome;
        this.notesInputObj.purpose = this.selectedRecord.purpose;*/
        this.notesInputObj.durationInMin = this.selectedRecord.durationInMin;
        this.notesInputObj.notes = this.selectedRecord.notes;
        this.notesInputObj.sumoAdditionalInfoRecId = this.selectedRecord.relatedId;
        this.notesInputObj.notesDurationDate = this.selectedRecord.notesDurationDate;
        this.showAppointmentModal = true;
        this.notesInputObj.purpose = this.selectedRecord.purpose;
        console.log('this.notesInputObj.purpose : ' + this.notesInputObj.purpose);
        this.notesInputObj.outcome = this.selectedRecord.outcome
        this.notesInputObj.hudActivity = this.selectedRecord.hudActivity
        this.notesInputObj.appointmentStatus = this.selectedRecord.appointmentStatus;
        console.log('this.showAppointmentModal : ' + this.showAppointmentModal);
        this.handlePurposeChange(this.notesInputObj.purpose);
        this.purposeValues = [
        { value: 'Not HUD-Reportable', label: 'Not HUD-Reportable'},
        { value: this.selectedRecord.caseTypePurposeApiValue, label: this.selectedRecord.caseTypePurposeLabel}];

    }

    //@description : To close appointment record edit
    handleAppointmentCancel() {
        this.selectedRecord = {};
        this.notesInputObj = {
            eventId: '',
            contactName: '',
            funder: undefined,
            outcome: '',
            purpose: '',
            durationInMin: undefined,
            notes: '',
            sumoAdditionalInfoRecId: undefined,
            appointmentStatus:''

        };
        this.showAppointmentModal = false;
    }
    showCancelSpinner = false;
    updateAppointmentNotes() {
        this.showCancelSpinner = true;

        this.getSelectedOutcomes(this.notesInputObj);

        updateAppointmentNotes(this.notesInputObj)
            .then(result => {
                console.log('success updateAppointmentNotes');
                this.fetchAndPopulateData();
                notifyRecordUpdateAvailable([{ recordId: this.notesInputObj.eventId }]);
                notifyRecordUpdateAvailable([{ recordId: this.notesInputObj.sumoAdditionalInfoRecId }]);
                this.handleAppointmentCancel();
                this.showCancelSpinner = false;
                this.template.querySelectorAll('c-activity-tile-view').forEach(element => {
                    element.refreshNotes();
                });
                const toast = new ShowToastEvent({
                    title: 'Success!',
                    message: '',
                    variant: 'success',
                    mode: 'dismissable'
                });
                this.dispatchEvent(toast);
            })
            .catch(error => {
                console.log('updateAppointmentNotes->error->' + JSON.stringify(error));
                this.showCancelSpinner = false;
                const toast = new ShowToastEvent({
                    title: 'Error!',
                    message: error.body.message,
                    variant: 'error',
                    mode: 'sticky'
                });
                this.dispatchEvent(toast);
            })
    }

    handleInputChange(event) {
        this.notesInputObj[event.target.name] = event.detail.value;
        if (event.target.name === 'purpose') {
            this.handlePurposeChange(event.target.value, true);
        }
        if(event.target.name ==='appointmentStatus' && event.target.value==='No Show') {
            this.notesInputObj['durationInMin']=0;
        }
    }

    //@description : To display records on click of the record headers.
    viewRecord(event) {
        console.log('Inisde view Record')
        let recordId = event.target.dataset.id;
        let objectApi = event.target.dataset.object;
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: recordId,
                objectApiName: objectApi,
                actionName: 'view'
            }
        });
    }

    /**
     * @description : To change value of outcome list on basis of purpose
     */
    handlePurposeChange(value, clearOutcomes) {
        if (clearOutcomes) {
            this.notesInputObj.outcome = '';
        }
        //this.refs.outcome.value=preSelectedValues;
        this.outcomeValues = this.outcomeMatrix[value];
    }

    get actionPlanPrintUrl() {
        if (this.objectApiName == 'Contact') {
            return '/apex/ActivityTimelineContactPDF?Id=' + this.recordId;
        } else if (this.objectApiName == 'ClientCase__c') {
            return '/apex/ActivityTimelineCasePDF?Id=' + this.recordId;
        } else {
            // Handle other cases or return a default URL
            return null;
        }
    }
    
    /* @description: handler method for showing print  popup*/
    showPrintActionPlanModal() {
        this.showPrintActionModal = true;
    }
    /* @description: handler method for hiding print goal popup*/
    closePrintActionPlanModal() {
        this.showPrintActionModal = false;
    }
    /**
     * @description : Storing selected outcomes.
     */
    getSelectedOutcomes() {
        let selectedOutcomes = this.refs.outcome.value;
        console.log('Selected Values L::: ', selectedOutcomes);
        if (selectedOutcomes ) {
            if(Array.isArray(selectedOutcomes) && selectedOutcomes.length > 0) {
                this.notesInputObj.outcome = selectedOutcomes.map(elt => elt.value).join(';');
            }
            else if(typeof selectedOutcomes == 'string' || selectedOutcomes instanceof String) {
                this.notesInputObj.outcome = selectedOutcomes;
            }
            else {
                this.notesInputObj.outcome = null;
            }
            
        }
        else {
            this.notesInputObj.outcome = null;
        }


    }
}