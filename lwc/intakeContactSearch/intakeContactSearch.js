import { LightningElement, api, track, wire } from 'lwc';
import retrieveContacts from '@salesforce/apex/IntakeContactSearchController.retrieveContacts';
import intakeMsgChannel from "@salesforce/messageChannel/IntakeMsgChannel__c";
import { publish, subscribe, APPLICATION_SCOPE, MessageContext } from 'lightning/messageService';
import CONTACT_SEARCH_INFO from '@salesforce/label/c.Intake_InfoMessageForContactSearch';
import CONTACT_SEARCH_INFO_SECOND from '@salesforce/label/c.Intake_InfoMessageForContactSearchSecond';
import NO_CONTACT_FOUND from '@salesforce/label/c.Intake_NoContactFound';
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { getObjectInfo ,getPicklistValuesByRecordType} from "lightning/uiObjectInfoApi";
import CONTACT_OBJECT from "@salesforce/schema/Contact";

import ErrorModal from 'c/intakeErrorModal';



const columns = [
    {
        type: "button", label: 'Show History', typeAttributes: {
            label: 'Show History',
            name: 'show_history',
            title: 'show_history',
            disabled: false,
            value: 'show_history',
            variant: 'brand-outline'
        }
    },
    { label: 'Name', fieldName: 'conLink', type: 'url', typeAttributes: { label: { fieldName: 'Name' }, target: '_blank' }, sortable: "true" },
    { label: 'Email', fieldName: 'Email', sortable: "true" },
    { label: 'Phone', fieldName: 'Phone', type: 'phone', sortable: "true" },
    { label: 'Address', fieldName: 'Address', sortable: "true" },
    { label: 'Client Type', fieldName: 'ClientType', sortable: "true" },
    {
        type: "button", label: 'New Education Only', typeAttributes: {
            label: 'New Education Only',
            name: 'New_Education_Only',
            title: 'New Education Only',
            disabled: false,
            value: 'New_Education_Only',
            variant: 'brand-outline'
        }
    },
    {
        type: "button", label: 'New Intake', typeAttributes: {
            label: 'New Intake',
            name: 'New_Service',
            title: 'New Intake',
            disabled: false,
            value: 'New_Service',
            variant: 'brand-outline'
        }
    },
    {
        type: "button", label: 'New Emergency Triage', typeAttributes: {
            label: 'New Emergency Triage',
            name: 'New_Emergency_Traige',
            title: 'New Emergency Triage',
            disabled: false,
            value: 'New_Emergency_Traige',
            variant: 'brand-outline'
        }
    },

];


export default class IntakeContactSearch extends LightningElement {
    error;
    columns = columns;
    @api firstName;
    @api lastName;
    @api email;
    @api phone;

    @track householdMatrix;
    @track contactRecordType;
    message;
    sortBy = "Name";
    sortByForApex = "Name";
    sortDirection = "asc";
    label = {
        CONTACT_SEARCH_INFO,
        CONTACT_SEARCH_INFO_SECOND,
        NO_CONTACT_FOUND
    }

    isSearch = true;
    isModalOpen = false;

    page = 1;
    items = [];
    data = [];
    startingRecord = 1;
    endingRecord = 0;
    pageSize = 10;
    totalRecountCount = 0;
    totalPage = 0;
    selectedRows = [];
    intakeResponse;
    isIntakeComplete = false;
    isEducationIntakeComplete = false;
    isEmergencyTriageComplete = false;
    isEducationModalOpen = false;
    isEmergencyIntakeOpen = false;
    isLeadIntakeOpen = false;
    isLeadIntakeComplete = false;
    @track editIntakeId;


    @track recordsToDisplay;
    recordsperpage = 30;
    buttonsPerPage = 10;
    records;
    totalRecords;
    pageNo;
    totalPages;
    startRecord;
    endRecord;
    end = false;
    pagelinks = [];
    disablePreviousButton = false;
    disableNextButton = false;
    heapExceedError = false;

    /* @description: Wire method for getting MessageContext*/
    @wire(MessageContext)
    messageContext;


    /**
     * @description : creating matrix for 
     */
    @wire(getObjectInfo,{objectApiName: CONTACT_OBJECT}) 
    getContactObjectDetails({error,data}) {
        if(data) {
            console.log('Object Info Data :', data);
            this.contactRecordType = data?.defaultRecordTypeId;
        }
    }

    @wire(getPicklistValuesByRecordType, {objectApiName: CONTACT_OBJECT, recordTypeId: '$contactRecordType'}) 
    processPicklist({error, data})
    {
        if(data) {
            console.log('Picklist Values : ', data);
        }
    }

    /* @description: Handler method for Record search which will triggered on input change in filter inputs and will fetch records from server and show on table*/
    handleSearch() {
        retrieveContacts({
            firstName: this.firstName,
            lastName: this.lastName,
            email: this.email,
            phone: this.phone,
            sortBy: this.sortByForApex,
            sortOrder: this.sortDirection
        })
            .then((result) => {
                var flag = true;
                this.heapExceedError = false;
                if (result.length == 0 || result == null) {
                    this.message = this.label.NO_CONTACT_FOUND;
                    flag = false;
                } else {
                    this.message = null;
                    if (result.length == 301) {
                        result = result.slice(0, 300);
                        this.heapExceedError = true;
                    }
                }
                let resData = JSON.parse(JSON.stringify(result));
                resData.forEach(res => {
                    res.conLink = '/' + res.Id;
                    res.PrimaryApplicant = res.Primary_Applicant__r ? res.Primary_Applicant__r.Name : '';
                    res.ClientId = res.Client__c ? res.Client__c : '';
                    res.ClientType = res.RecordTypeId ? res.RecordType.Name : '';
                    res.MailingAddress = res.MailingAddress;
                    var add = '';
                    if (res.MailingStreet) {
                        add = res.MailingStreet;
                    }
                    if (res.MailingCity) {
                        add = (add != '') ? (add + ', ' + res.MailingCity) : res.MailingCity;
                    }
                    if (res.MailingCountry) {
                        add = (add != '') ? (add + ', ' + res.MailingCountry) : res.MailingCountry;
                    }
                    if (res.MailingPostalCode) {
                        add = (add != '') ? (add + ', ' + res.MailingPostalCode) : res.MailingPostalCode;
                    }
                    res.Address = add;
                });

                this.items = resData;
                this.totalRecountCount = resData ? resData.length : 0;
                this.totalPage = Math.ceil(this.totalRecountCount / this.pageSize);
                this.data = this.items.slice(0, this.pageSize);
                this.endingRecord = this.pageSize;

                this.records = this.items;
                this.totalRecords = this.records.length;
                this.pageNo = 1;
                this.totalPages = Math.ceil(this.totalRecords / this.recordsperpage);
                this.preparePaginationList();
                this.pagelinks = [];

                if (this.totalPages > parseInt(this.buttonsPerPage)) {
                    for (let i = 1; i <= this.buttonsPerPage; i++) {
                        this.pagelinks.push(i);
                    }
                } else {
                    for (let i = 1; i <= this.totalPages; i++) {
                        this.pagelinks.push(i);
                    }
                }

                this.error = undefined;
                const message = {
                    messageBody: flag,
                    Type: "SearchDone",
                };
                publish(this.messageContext, intakeMsgChannel, message);
                this.isSearch = false;
            })
            .catch((error) => {
                this.error = error;
                this.data = undefined;
                this.showToast('Error', error.body.message, 'error');
            });
    }

    /* @description: Handler method for handling page number click in pagination*/
    handlePage(button) {
        this.pageNo = button.target.label;
        this.preparePaginationList();
    }

    /* @description: Generic Handler method for all buttons clicked in pagination*/
    handleClick(event) {
        let label = event.target.label;
        if (label === "Previous") {
            this.handlePrevious();
        } else if (label === "Next") {
            this.handleNext();
        }
    }

    /* @description: Handler method for next button in pagination*/
    handleNext() {
        this.pageNo += 1;
        this.preparePaginationList();
    }

    /* @description: Handler method for previous button in pagination*/
    handlePrevious() {
        this.pageNo -= 1;
        this.preparePaginationList();
    }

    /* @description: Handler method for preparing data to be displayed in pagination*/
    preparePaginationList() {
        this.disablePreviousButton = false;
        this.disableNextButton = false;
        if (this.pageNo === 1) {
            this.disablePreviousButton = true;
        }
        if (this.pageNo === this.totalPages) {
            this.disableNextButton = true;
        }

        let begin = (this.pageNo - 1) * parseInt(this.recordsperpage);
        let end = parseInt(begin) + parseInt(this.recordsperpage);
        this.recordsToDisplay = this.records.slice(begin, end);

        this.startRecord = begin + parseInt(1);
        this.endRecord = end > this.totalRecords ? this.totalRecords : end;
        this.end = end > this.totalRecords ? true : false;
    }

    get showPagination() {
        return (this.data.length > 0);
    }

    /* @description: Handler method for input fields provided for filter*/
    handleSearchChange(event) {
        if (event.target.name == 'FirstName') {
            this.firstName = event.target.value;
        }
        else if (event.target.name == 'LastName') {
            this.lastName = event.target.value;
        }
        else if (event.target.name == 'Phone') {
            this.phone = event.target.value;
        }
        else {
            this.email = event.target.value;
        }
        if ((this.firstName != '' && this.firstName != null && this.firstName.length > 0) || (this.lastName != '' && this.lastName != null && this.lastName.length > 0) || (this.email != '' && this.email != null && this.email.length > 0) || (this.phone != '' && this.phone != null && this.phone.length > 0)) {
            this.handleSearch();
        }
        else {
            this.items = [];
            this.data = [];
        }
        this.selectedRows = [];
        this.fireClientCaseTableResetEvent();
    }

    /* @description: Handler method for row selection in datatable and get selected records*/
    onRowSelection(selectedItems) {
        //const selectedItems = event.detail.selectedRows;

        if (selectedItems != '' && selectedItems != null) {
            this.isSearch = false;
            this.selectedRows = [];

            this.selectedRows.push(selectedItems.Id);

            const message = {
                messageBody: [selectedItems],
                Type: "SearchClientCase",
            };
            publish(this.messageContext, intakeMsgChannel, message);
        }
    }

    /* @description: Handler for New Intake Button which opens popup modal for new Intake Screen*/
    openWizardModal(event) {
        this.isModalOpen = true;
    }

    /* @description: Handler for New Intake Button which opens popup modal for new Eduction Screen*/
    openEducationWizardModal(event) {
        this.isEducationModalOpen = true;
    }

    /* @description: Handler for New Intake Button which opens popup modal for new Emergency Screen*/
    openEmergencyWizardModal(event) {
        this.isEmergencyIntakeOpen = true;
    }

    openLeadIntakeWizard() {
        this.isLeadIntakeOpen = true;
    }

    /* @description: closes popup modal for new Intake Screen*/
    closeModal() {
        this.isModalOpen = false;
        this.editIntakeId = null;
        this.isEducationModalOpen = false;
        this.isEmergencyIntakeOpen = false;
        this.isLeadIntakeOpen = false
    }

    /* @description: handles backend response once intake form is submitted */
    handleIntakeSubmit(event) {
        this.isModalOpen = false;
        this.editIntakeId = null;
        this.intakeResponse = JSON.parse(JSON.stringify(event.detail));
        console.log('Response : ' + JSON.stringify(event.detail));
        this.isIntakeComplete = true;
    }

    /**
     * 
     * @description: handles backend response once education form is submitted 
     */
    handleEducationalIntakeSubmit(event) {
        this.isEducationModalOpen = false;
        this.intakeResponse = JSON.parse(JSON.stringify(event.detail));
        console.log('Response : ' + JSON.stringify(event.detail));
        this.isEducationIntakeComplete = true;
    }


    /**
     * 
     * @description: handles backend response once emergency form is submitted 
     */
    handleEmergencyIntakeSubmit(event) {
        this.isEmergencyIntakeOpen = false;
        this.intakeResponse = JSON.parse(JSON.stringify(event.detail));
        console.log('Response : ' + JSON.stringify(event.detail));
        this.isEmergencyTriageComplete = true;
    }

    handleLeadIntakeSubmit(event) {
        this.isLeadIntakeOpen = false;
        this.intakeResponse = JSON.parse(JSON.stringify(event.detail));
        console.log('Response : ' + JSON.stringify(event.detail));
        this.isLeadIntakeComplete = true;
    }

    /* @description: handles closing of modal for intake Success */
    handleSuccessClose() {
        this.isIntakeComplete = false;
        this.isEducationIntakeComplete = false;
        this.isEmergencyTriageComplete = false;
        this.isLeadIntakeComplete = false;
        this.intakeResponse = {};
    }

    /* @description: Handler method for reset button which resets all inputs and clear the table data*/
    handleTableReset(event) {
        let dataTableCmp = this.template.querySelector('lightning-datatable');
        if(dataTableCmp){
            dataTableCmp.selectedRows = [];
        }
        this.isSearch = true;
        this.firstName = null;
        this.lastName = null;
        this.email = null;
        this.phone = null;
        this.data = [];
        this.items = [];
        this.page = 1;

        this.startingRecord = 1;
        this.endingRecord = 0;
        this.totalRecountCount = 0;
        this.totalPage = 0;
        this.fireClientCaseTableResetEvent();
        this.message = '';
        this.selectedRows = [];
        const message = {
            messageBody: false,
            Type: "SearchDone",
        };
        publish(this.messageContext, intakeMsgChannel, message);
    }

    /* @description: Publish message in channel to reset Client Case table*/
    fireClientCaseTableResetEvent() {
        const message = {
            messageBody: false,
            Type: "SearchReset",
        };
        publish(this.messageContext, intakeMsgChannel, message);
    }

    /* @description: Handler method for sorting records in table based on column clicked and get sorted records from apex*/
    doSorting(event) {
        if (event.detail.fieldName === "ClientId") {
            this.sortByForApex = "Client__c";
        } else if (event.detail.fieldName === "conLink") {
            this.sortByForApex = "Name";
        } else if (event.detail.fieldName === "ClientType") {
            //this.sortByForApex = "RecordType.Name";
            return;
        } else if (event.detail.fieldName === "Address") {
            this.sortByForApex = "MailingStreet";
        } else {
            this.sortByForApex = event.detail.fieldName;
        }
        this.sortBy = event.detail.fieldName;
        this.sortDirection = event.detail.sortDirection;
        this.handleSearch();
    }

    /* @description: Handler method for performing actions*/
    handleRowAction(event) {
        const actionName = event.detail.action.name;
        const row = event.detail.row;
        console.log('Action name : ', actionName);
        console.log('Row name : ', row);
        switch (actionName) {
            case 'New_Service':
                this.editIntakeId = row?.Id;
                this.openWizardModal();
                break;
            case 'New_Education_Only':
                this.editIntakeId = row?.Id;
                this.openEducationWizardModal();
                break;
            case 'New_Emergency_Traige':
                this.editIntakeId = row?.Id;
                this.openEmergencyWizardModal();
                break;
            case 'show_history':
                this.onRowSelection(row);
                break;
        }
    }

    /* @description: Handler method for previous button in pagination*/
    previousHandler() {
        if (this.page > 1) {
            this.page = this.page - 1;
            this.displayRecordPerPage(this.page);
        }
    }

    /* @description: Handler method for next button in pagination*/
    nextHandler() {
        if ((this.page < this.totalPage) && this.page !== this.totalPage) {
            this.page = this.page + 1;
            this.displayRecordPerPage(this.page);
        }
    }

    /* @description: method for getting records based on pagination*/
    displayRecordPerPage(page) {
        this.startingRecord = ((page - 1) * this.pageSize);
        this.endingRecord = (this.pageSize * page);
        this.endingRecord = (this.endingRecord > this.totalRecountCount)
            ? this.totalRecountCount : this.endingRecord;
        this.data = this.items.slice(this.startingRecord, this.endingRecord);
        this.startingRecord = this.startingRecord + 1;
        this.template.querySelector('[data-id="datatable"]').selectedRows = this.selectedRows;
    }

    /* @description: method for showing toast message*/
    showToast(title, message, variant) {
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
        });
        this.dispatchEvent(evt);
    }

    /**
     * @description : Method to show modal for error in intake registration
     */
    async openErrorModal(event) {
        console.log('Error Registered : ',event.detail);
        // this.isModalOpen = false;
        // this.editIntakeId = null;
        const result = await ErrorModal.open({
            size: 'small',
            description: 'Modal is Used to show error in intake',
            errorMessage: event?.detail?.errorMessage
        });

        console.log(result);
    }
}