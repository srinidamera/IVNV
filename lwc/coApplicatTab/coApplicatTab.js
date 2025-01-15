import { LightningElement, wire, track, api } from 'lwc';
import FORM_FACTOR from "@salesforce/client/formFactor";
import getCoApplicantContacts from '@salesforce/apex/EnrollmentFormController.fetchAllContactCoApplicants';
import fetchAllCoApplicants from '@salesforce/apex/EnrollmentFormController.fetchAllCoApplicants';
import isIntakeStaffUser from "@salesforce/apex/EnrollmentFormController.isIntakeStaffUser";
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import MY_Contact from '@salesforce/schema/Contact';


import getPicklistValues from '@salesforce/apex/EnrollmentFormController.getPicklistValues';

import insertCoApplicant from '@salesforce/apex/EnrollmentFormController.insertCoApplicant';

import updateRecords from '@salesforce/apex/EnrollmentFormController.updateRecords';
import deleteCoApplicant from '@salesforce/apex/EnrollmentFormController.deleteCoApplicant';
import getRecordStatus from '@salesforce/apex/EnrollmentFormController.getRecordStatus';

import { isEmptyObject, getFullName, generateUniqueId, isValidValue, formatPhoneNumber, isValidateZIPPostal, isValidPhoneNumber, getSuffixOptions } from "c/lwrUtils";
import { getRecord } from "lightning/uiRecordApi";
import PRIMARY_CLIENT from "@salesforce/schema/Intake__c.PrimaryClient__c";
import ACCOUNT_ID from '@salesforce/schema/Intake__c.Household__c';
import { refreshApex } from '@salesforce/apex';
import { NavigationMixin } from 'lightning/navigation';


const FIELDS = [PRIMARY_CLIENT, ACCOUNT_ID];


import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class CoApplicatTab extends  NavigationMixin  (LightningElement) {
  @track ethnicityValues;
  @track raceValues;
  @track englishProficiencyValues;
  @track genderValues;
  @track firstTimeHomeBuyerValues;
  @track communityValues;
  @track mailingStateValues;
  @track modalContact = {};
  @track showAddressFields = true;
  @track isEditMode = false;
  @track contactId;
  @track coApplicantLabel = 'Co-Applicants (number)';
  selectedRecordEditIndex = -1;
  selectedCoApplicants = [];
  selectedCoAPplicantId;

  applicantData = [];
  @track isShowModal = false;
  @track showConfirmationModal = false;
  @track showDataModal = false;
  @track disableMenu;
  @track status;

  @api contact;
  @api recordId;
  @api labels;
  @api objectApiName;


     accountIdval = ACCOUNT_ID;
      
  connectedCallback() {
    this.isIntakeStaffUser();
  }

  isIntakeStaffUser() {
    isIntakeStaffUser().then((result) => {
      this.disableMenu = result && this.objectApiName !== 'Intake__c';
    }).catch((error) => {
      console.log('ERROR !!!'+JSON.stringify(error))
    });
  }

  get coApplicantHeaderLabel() {
    return this.coApplicantLabel.replace('number', this.selectedCoApplicants.length);
  }

     @wire(getRecord, { recordId: "$recordId", fields: FIELDS })
   intake;

  @wire(getRecord, {
    recordId: "$recordId",
    fields: FIELDS
  })
  intake;

  showSpinner = false;

  get accountId() {
    console.log('accountId ===>', JSON.stringify(this.intake));
    return this.intake?.data?.fields?.Household__c?.value;
  }

  get primaryClient() {
    return this.intake?.data?.fields?.PrimaryClient__c?.value;
  }


  get coApplicantName() {
    return this.modalContact?.Name ? this.modalContact?.Name : '';
  }

  get showAddCoApplicantBtn(){
    if(
      this.disableMenu 
      || this.status === 'Closed - Incomplete' 
      || this.status === 'Open Case' 
      || this.status === 'Closed - Complete'
    ){
      return true;
    }
    return false;
  }

 handleSubmit(event) {
    //event.preventDefault();
    const fields = event.detail.fields;
    // Set a default AccountId for testing
    fields.AccountId = this.accountId; // Replace with a valid Account ID
    console.log('OUTPUT : this.accountId',this.accountId);
    this.template.querySelector('lightning-record-edit-form').submit(fields);
}

  /*
    @wire(getCoApplicantContacts, { recordId: "$recordId" })
    getApplicantWired122({ error, data }) {
      console.log('getCoApplicantContacts called');
      if (data) {
        console.log('getCoApplicantContacts : data.Pdata', JSON.stringify(data));
        this.applicantData = data;
      } else if (error) {
        console.error('getCoApplicantContacts Error:', error);
      }
    }
  
    @wire(fetchAllCoApplicants, { recordId: "$recordId" })
    getApplicantWired({ error, data }) {
      if (data) {
        //console.log('getApplicantWired called0', data);
        console.log('fetchAllCoApplicants : data.Pdata', JSON.stringify(data));
        this.selectedCoApplicants = data;
      } else if (error) {
        console.error('fetchAllCoApplicants Error:', error);
      }
    }
  */

  wiredCoApplcantResult;
  wiredCoApplcantResult2;
  @wire(getCoApplicantContacts, { recordId: "$recordId" })
  getApplicantWired122(result) {
    
    this.wiredCoApplcantResult = result;
    if (result.data) {
      this.applicantData = result.data;
    } else if (result.error) {
      console.error('getCoApplicantContacts Error:', result.error);
    }
  }

  @wire(fetchAllCoApplicants, { recordId: "$recordId" })
  getApplicantWired(result) {
    console.log('fetchAllCoApplicants called', result);
    this.wiredCoApplcantResult2 = result;
    if (result.data) {
      console.log('in if',  result.data);
      this.selectedCoApplicants = result.data;
      this.selectedCoApplicants = this.selectedCoApplicants.map((contact, idx) => {
        return { ...contact, index: idx + 1 };
      });
    } else if (result.error) {
      console.error('fetchAllCoApplicants Error:', result.error);
    }
  }

  @wire(getRecordStatus, { recordId: "$recordId" })
  getRecordStatusWired(result){
    if (result.data) {
      this.status = result.data;
    } else if (result.error) {
      console.error('getRecordStatus Error:', result.error);
    }
  }

  handleApplicantChange(event) {
    this.value = '';
    this.selectedContactId = event.detail.value;

  }

  insertCoApplicantJS() {
    console.log('in insertCoApplicantJS');
    this.showSpinner = true
    insertCoApplicant({ intakeId: this.recordId, contactId: this.selectedContactId })
      .then(result => {
        console.log('insertCoApplicant Result', JSON.stringify(result));
        this.showToast('success', 'Contact saved to My Profile', '', 'standard:task2', true, 2000);
        this.isShowModal = false;
        this.showDataModal = false;
        this.showSpinner = false
        refreshApex(this.wiredCoApplcantResult);
        refreshApex(this.wiredCoApplcantResult2);
      })
      .catch(error => {
        this.isShowModal = false;
        this.showDataModal = false;
        this.showSpinner = false
        console.error('Error:', error);
        this.handleResponse(error);
      });
  }



  handleResponse(response) {
        if (!response.ok) {
            if (response.body && response.body.pageErrors && response.body.pageErrors.length > 0) {
                const error = response.body.pageErrors[0];
                if (error.message) {
                    this.errorMessage = error.message;
                    //variant, title, message,
                    this.showToast('error','Error', this.errorMessage);
                }
            } else {
                this.showToast('error','Error','Unknown error occurred');
            }
        }
    }





  /*
    * @description   to fetch picklist values for fields on Enrollment Profile Form
    */
  @wire(getPicklistValues, { fieldNames: ['Ethnicity__c', 'Race__c', 'EnglishProficiency__c', 'Gender__c', 'X1stTimeHomeBuyer__c', 'RuralAreaStatus__c', 'MailingStateCode'], objectApiName: 'Contact' })
  fetchPickListValues({ error, data }) {
    if (error) {
      console.error('error ' + JSON.stringify(error));
    }
    if (data) {
      this.ethnicityValues = data.Ethnicity__c;
      this.raceValues = data.Race__c;
      this.englishProficiencyValues = data.EnglishProficiency__c;
      this.genderValues = data.Gender__c;
      this.firstTimeHomeBuyerValues = data.X1stTimeHomeBuyer__c;
      this.communityValues = data.RuralAreaStatus__c;
      this.mailingStateValues = data.MailingStateCode;
    }
  }

  handleSelection(event) {
    try {
      let lenghtOfSelectedRecords = 0;
      console.log('OUTPUT : handleSelectioncalled', this.selectedApplicants);
      let previousSelctedApplicants = this.selectedApplicants.length;
      this.applicantData = this.applicantData.map(obj => {
        if (event.detail.includes(obj.Name)) {
          lenghtOfSelectedRecords++;
        }
        return { ...obj, selected: event.detail.includes(obj.Name) ? true : false };
      });
      //Show toast on selection of co-applicants from combobox
      if (lenghtOfSelectedRecords > previousSelctedApplicants) {
        this.showToast('success', 'Contact saved to My Profile', '', 'standard:task2', true, 2000);
      }

    } catch (e) {
      console.log('OUTPUT : handleselection failed', e);
    }

  }

  handleRemoveApplicant() {
    this.toggleModal();
    this.showConfirmationModal = !this.showConfirmationModal;
  }

  toggleSpinner() {
    this.showSpinner = !this.showSpinner;
  }

  removeApplicant(event) {
    this.toggleSpinner();
    /*
    const recordName = event.target.dataset.recordName;
    this.applicantData = this.applicantData.map(obj => {
      if (recordName == obj.Name) {
        return { ...obj, selected: false };
      }
      return { ...obj };
    });
    this.showConfirmationModal = !this.showConfirmationModal;
    this.showToast('error', 'Co-Applicant Removed from Class Enrollment', '', 'action:delete', true, 2000); //'utility:error'
    */
    // this.toggleSpinner();
    deleteCoApplicant({ recordId: event.currentTarget.dataset.coappid })
      .then(result => {
        console.log('deleteCoApplicantResult', result);
        this.showConfirmationModal = false;
        this.showToast('success', 'Co-Applicant Removed', '', 'action:check', true, 2000); //'utility:error'
        //  refreshApex(this.applicantData);
        //  refreshApex(this.selectedCoApplicants);
        this.toggleSpinner();
        refreshApex(this.wiredCoApplcantResult);
        refreshApex(this.wiredCoApplcantResult2);
      })
      .catch(error => {
        this.toggleSpinner();
        this.showConfirmationModal = false;
        console.error('Error: deleteCoApplicant', error);
      });
  }

  get suffixValues() {
    return getSuffixOptions();
  }

  /*
    /*new method to return selection options 
    get selectedApplicantOptions() {
      return this.applicantData.filter(obj => obj && obj.selected).map(obj => obj.Name);
    }*/

  get applicantOptions() {
    //return this.applicantData.filter(obj => obj && obj.Name).map(obj => obj.Name);
    return  this.applicantData.map(item => ({
        label: item.Name,
        value: item.Id
      }));
  }

  /*
    get selectedApplicants() {
      return this.applicantData.filter(item => item.selected == true);
    }*/

  /* @description: getter for check device type*/
  get getModalSize() {
    switch (FORM_FACTOR) {
      case "Large":
        return "slds-modal slds-fade-in-open slds-modal_small";
      case "Medium":
        return "slds-modal slds-fade-in-open";
      case "Small":
        return "slds-modal slds-fade-in-open slds-modal_full";
      default:
    }
  }

  @api toggleModal() {
    this.isShowModal = !this.isShowModal;
  }

  handleNewCoApplicant() {
    this.toggleModal();
    this.modalContact = {};
  }

  handleAddCoApplicant() {
    console.log('hellow');
    this.showDataModal = true;
  }

  showToast(variant, title, message, iconName, autoClose, autoCloseTime) {
    const event = new ShowToastEvent({
      title: title,
      message: message,
      variant: variant,
      mode: 'dismissable'
    });
    this.dispatchEvent(event);
    /*
    const selectedEvent = new CustomEvent('triggertoast', {
      detail: {
        variant: variant,
        title: title,
        message: message,
        iconName: iconName,
        autoClose: autoClose,
        autoCloseTime: autoCloseTime
      }
    });
    this.dispatchEvent(selectedEvent);*/

  }

  handleViewEditApplicant(event) {
    this.isEditMode = true;
    try {
      this.isShowModal = true;
      this.selectedCoAPplicantId = event.currentTarget.dataset.coappid;
      this.contactId = event.currentTarget.dataset.id;
      console.log('contact Id', this.contactId);
      console.log('handleViewEditApplicant called', event.currentTarget.dataset.id);
      console.log('OUTPUT : this.applicantData', JSON.stringify(this.applicantData));
      this.modalContact = this.applicantData.filter(item => {
        return item.Id == event.currentTarget.dataset.id;
      })[0];
      console.log('modalContact ==>', JSON.stringify(this.modalContact));
      //  this.toggleModal();
    } catch (e) {
      console.log('handleViewEditApplicant failed ', e);
    }

    /*
    this.selectedRecordEditIndex = event.currentTarget.dataset.index;
    let tempModalContact = this.selectedApplicants[event.currentTarget.dataset.index];
    this.modalContact = {...tempModalContact};
    this.toggleModal();*/
  }

  handleCancel() {
    this.selectedRecordEditIndex = -1;
    this.toggleModal();
    this.isEditMode = false;
  }

  handleCancleConfirmationModal() {
    this.showConfirmationModal = !this.showConfirmationModal;
  }

  @api
  handleNewApplicant() {
    this.modalContact = {};//{sameAsPrimaryContact: true, MailingStreet : this.contact?.MailingStreet, MailingAddressLine2__c : this.contact.MailingAddressLine2__c, MailingCity : this.contact.MailingCity, MailingStateCode : this.contact.MailingStateCode, MailingPostalCode : this.contact.MailingPostalCode, MailingCountryCode : this.contact.MailingCountryCode};
    this.toggleModal();
  }

  @track
  recordTypeId;

  @wire(getObjectInfo, { objectApiName: MY_Contact })
  handleObjectInfo({ error, data }) {
    if (data) {
      const rtis = data.recordTypeInfos;
      this.recordTypeId = Object.keys(rtis).find(rti => rtis[rti].name === 'Co-Applicant');
    }
  }

  handleSuccess(event) {
    console.log('===========>', this.showSpinner);
    this.showSpinner = true;
    //  this.toggleSpinner();
    console.log('onsuccess event recordEditForm', event.detail.id);
    this.selectedContactId = event.detail.id;
    console.log('this.selectedContactId ====>', this.selectedContactId);
    console.log('this.contactId ====>', this.contactId);
    console.log('this.isEditMode ====>', this.isEditMode);
    if (!this.isEditMode) {
      this.insertCoApplicantJS();
    } else {
      this.showToast('success', 'Contact updated to My Profile', '', 'standard:task2', true, 2000);
      this.isShowModal = false;
      this.showSpinner = false;
      this.isEditMode = false;
      refreshApex(this.wiredCoApplcantResult);
      refreshApex(this.wiredCoApplcantResult2);
    }

    //this.toggleSpinner();
    ///this.toggleModal();
  }
/*
  handleSubmit(event) {
    console.log('onsubmit event recordEditForm'+ JSON.stringify(event.detail.fields));
    
  }*/

  handleCreateNewApplicant() {

    const submitButton = this.template.querySelector('.type-submit');
    submitButton.click();
    /*
    console.log('in handleCreateNewApplicant', this.isEditMode);
    const inputFields = this.template.querySelectorAll('lightning-input-field');
    console.log('input fields===>', JSON.stringify(inputFields));
    // Iterate through each field and get the values
    inputFields.forEach(field => {
        console.log(`Field Name: ${field.fieldName}, Value: ${field.value}`);
    });
    console.log('OUTPUT fields: ====>', this.template.querySelectorAll('lightning-record-edit-form')[0].fields);

    if (this.isEditMode) {
      console.log('in if ==>', JSON.stringify(this.template.querySelectorAll('lightning-record-edit-form')));
      let component = this.template.querySelectorAll('lightning-record-edit-form');
      component[0].submit();
      // this.template.querySelector('#updateForm').submit();

    } else {
      console.log('in else ==>', JSON.stringify(this.template.querySelectorAll('lightning-record-edit-form')));
      let component = this.template.querySelectorAll('lightning-record-edit-form');
      component[0].submit();
      //this.template.querySelector('#createForm').submit();
      // this.template.querySelector('lightning-record-edit-form').submit();
    }
    */
  }

  handleSaveApplicant() {

    try {
      let allValid = true;
      let feilds = this.template.querySelectorAll('.contactField');
      let contactUpdate = {}// { selected: true };
      feilds.forEach(inputField => {
        let propertyName = inputField.name;
        if (propertyName === 'Phone') {
          contactUpdate[propertyName] = inputField.value ? inputField.value.replace(/\D/g, "") : "";
        } else if (propertyName === 'Id') {
          if (inputField.value !== 'undefined' && inputField.value !== undefined) {
            contactUpdate[propertyName] = inputField.value;
          } else {
            delete contactUpdate.Id;
          }
        } else if (propertyName === 'sameAsPrimaryContact') {
          //    contactUpdate[propertyName] = inputField.checked;
        } else {
          contactUpdate[propertyName] = inputField.value;
        }
        if (!inputField.checkValidity()) {
          inputField.reportValidity();
          allValid = false;
        }
      });
      if (!allValid) {
        return;
      } else {
        // this.toggleSpinner();
        updateRecords({ contactRec: contactUpdate, recordId: this.recordId })
          .then(result => {
            console.log('updateRecords Result', result);
            refreshApex(this.wiredCoApplcantResult);
            refreshApex(this.wiredCoApplcantResult2);
            this.toggleModal();
            //  this.toggleSpinner();
            this.showToast('success', 'Contact saved to My Profile', '', 'standard:task2', true, 2000);
          })
          .catch(error => {
            //  this.toggleSpinner();
            console.error('updateRecords Error: ', error);
            this.showToast('error', error.body.pageErrors[0].message, '', 'action:delete', true, 2000); //'utility:error'
            this.toggleModal();
          });
      }

      //  contactUpdate.Name = getFullName(contactUpdate);
      /*
        if (this.selectedRecordEditIndex >= 0) {
          const index = this.applicantData.findIndex(obj => obj.uniqueId === contactUpdate.uniqueId);
          if (index !== -1) {
            let tempAppData = JSON.parse(JSON.stringify(this.applicantData));
            tempAppData[index] = contactUpdate;
            this.applicantData = tempAppData;
          }
        } else {
          contactUpdate = { ...contactUpdate, uniqueId: generateUniqueId() };
          this.applicantData = [...this.applicantData, contactUpdate];
        }
        this.selectedRecordEditIndex = -1;*/








      //  console.log('OUTPUT : in save', JSON.stringify(contactUpdate));
    } catch (e) {
      console.error('handleSaveApplicant error : ', e);
    }

  }


  removeNonSalesforceMembers(applicants) {
    /*
    return applicants.map(obj => {
        const { Name, uniqueId, selected, ...newObj } = obj;
        return newObj;
      });*/
  }


  /*This method handles changes in the phone number input field. It formats the input value, validates it, 
 sets custom validity if it's not valid, updates the formatted value in the input field, and reports validity.*/
  handlePhoneNumberChange(event) {
    let inputValue = event.target.value.replace(/\D/g, ""); // Remove non-numeric characters
    let formattedValue = formatPhoneNumber(inputValue);
    let phonefield = this.template.querySelector(".phone-field");
    if (!isValidValue(inputValue)) {
      phonefield.setCustomValidity("");
    } else if (!isValidPhoneNumber(inputValue)) {
      phonefield.setCustomValidity('The phone number must be 10 digits');
    } else {
      phonefield.setCustomValidity("");
    }
    this.refs.phonefield.value = formattedValue;
    phonefield.reportValidity();
  }

  handleChange(event) {
    const isChecked = event.target.checked;
    if (isChecked) {
      //    let tempModalContact = {...this.modalContact, sameAsPrimaryContact : isChecked, MailingStreet : this.contact?.MailingStreet, MailingAddressLine2__c : this.contact.MailingAddressLine2__c, MailingCity : this.contact.MailingCity, MailingStateCode : this.contact.MailingStateCode, MailingPostalCode : this.contact.MailingPostalCode};
      //   this.modalContact = {...tempModalContact};
    } else {
      let tempModalContact = { ...this.modalContact, sameAsPrimaryContact: isChecked, MailingStreet: '', MailingAddressLine2__c: '', MailingCity: '', MailingStateCode: '', MailingPostalCode: '' };
      this.modalContact = { ...tempModalContact };
    }
  }

  validateZIPOnChange(event) {
    if (isValidateZIPPostal(event.target.value)) {
      event.target.setCustomValidity("Enter only 5 digit numbers");
    } else {
      event.target.setCustomValidity("");
    }
  }

  get toggleAddress() {
    if (!this.modalContact.sameAsPrimaryContact) {
      return 'display: block';
    }
    return 'display: none';
  }

  handleConfirmationModal() {
    this.showConfirmationModal = false;
    this.showDataModal = false;
    this.isShowModal = false;
    //this.toggleModal();
  }


  handleNewModalApplicant() {
    this.showDataModal = true;
  }

  hideDataModal() {
    this.showDataModal = false;
  }

  navigateToRecord(event) {
    console.log('OUTPUT : navigateToRecord called',event.currentTarget.dataset.id );
   // const recordId = event.currentTarget.dataset.id;
    
    this[NavigationMixin.Navigate]({
        type: 'standard__recordPage',
        attributes: {
            recordId: event.currentTarget.dataset.id,
            actionName: 'view'
        }
    });
}


}