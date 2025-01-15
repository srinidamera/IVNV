import { LightningElement, wire, track, api } from 'lwc';
import FORM_FACTOR from "@salesforce/client/formFactor";
import getCoApplicantContacts from '@salesforce/apex/EnrollmentFormController.getCoApplicantContacts';
//import getPicklistValues from '@salesforce/apex/EnrollmentFormController.getPicklistValues';
import {isEmptyObject, getFullName, generateUniqueId, isValidValue, formatPhoneNumber, isValidateZIPPostal, isValidPhoneNumber, getSuffixOptions} from "c/lwrUtils";
import CONTACT_OBJECT from "@salesforce/schema/Contact";
import { getObjectInfo, getPicklistValuesByRecordType  } from "lightning/uiObjectInfoApi";
export default class ServiceEnrollmentCoApplicantForm extends LightningElement {
    @track ethnicityValues;
  @track raceValues;
  @track englishProficiencyValues;
  @track genderValues;
  @track firstTimeHomeBuyerValues;
  @track communityValues;
  @track mailingStateValues;
  @track bestTimeToCallValues;
  @track preferredLanguageValues;
  @track relationshipToPrimaryApplicantValues;
  @track maritalStatusValues;
  @track educationValues;
  @track employmentStatusValues;
  @track disabledStatusValues;
  @track activeMilitaryValues;
  @track veteranValues;
  @track modalContact = {};
  @track showAddressFields = true;
  selectedRecordEditIndex = -1;

  applicantData = [];
  @track isShowModal = false;
  @track showConfirmationModal = false;
  @track contactRecordTypeId;
  @api contact;
  @api labels;
  
  get coApplicantName(){
    return this.modalContact.Name ? this.modalContact.Name : this.labels.builderCreateNewCoApplicantLabel;
  }

  @wire(getObjectInfo, { objectApiName: CONTACT_OBJECT }) wireAccountData(objectInfo,error){
    if(objectInfo){
        
        let recordTypeInfo = objectInfo?.data?.recordTypeInfos;
        if(recordTypeInfo){
            console.log('recordTypeInfo===>',JSON.stringify(recordTypeInfo));
            this.contactRecordTypeId = Object.keys(recordTypeInfo).find(rtype=>(recordTypeInfo[rtype].name === 'Co-Applicant'));
            console.log('contactRecordTypeId===>',this.contactRecordTypeId);
        }
    }
}

@wire(getPicklistValuesByRecordType, { objectApiName: CONTACT_OBJECT, recordTypeId: '$contactRecordTypeId' })
    picklistValuesHandler({ error, data }) {
        if (data) {
          //  console.log('getPicklistValuesByRecordType===>', JSON.stringify(data.picklistFieldValues));
            this.picklistValues = data.picklistFieldValues;
            //console.log('education ===>', JSON.stringify(this.picklistValues?.Education__c?.values));
            this.ethnicityValues = this.picklistValues?.Ethnicity__c?.values;
            this.mailingStateValues =  this.picklistValues?.MailingStateCode?.values;
            this.raceValues = this.picklistValues?.Race__c?.values;
            this.englishProficiencyValues =  this.picklistValues?.EnglishProficiency__c?.values;
            this.communityValues =  this.picklistValues?.RuralAreaStatus__c?.values;
            this.genderValues =  this.picklistValues?.Gender__c?.values;
            this.firstTimeHomeBuyerValues = this.picklistValues?.X1stTimeHomeBuyer__c?.values;
            this.bestTimeToCallValues =  this.picklistValues?.Besttimetocontact__c?.values;
            this.maritalStatusValues = this.picklistValues?.MaritalStatus__c?.values;
            this.educationValues = this.picklistValues?.Education__c?.values;
            this.activeMilitaryValues = this.picklistValues?.ActiveMilitary__c?.values;
            this.veteranValues = this.picklistValues?.Veteran__c?.values;
            this.employmentStatusValues = this.picklistValues?.EmploymentStatus__c?.values;
            this.disabledStatusValues = this.picklistValues?.DisabledStatus__c?.values;
            this.preferredLanguageValues =  this.picklistValues?.PreferredLanguage__c?.values;
            this.relationshipToPrimaryApplicantValues = this.picklistValues?.RelationshipToPrimaryApplicant__c?.values; 
        } else if (error) {
            console.log('getPicklistValuesByRecordType error===>', JSON.stringify(error));
            this.error = error;
        }
    }

  @wire(getCoApplicantContacts)
  getApplicantWired({ error, data }) {
    if (isEmptyObject(this.applicantData) && data) {
      this.applicantData = data.map(item => {
        return { ...item, uniqueId: generateUniqueId(), sameAsPrimaryContact: true, MailingStreet : this.contact.MailingStreet, MailingAddressLine2__c : this.contact.MailingAddressLine2__c, MailingCity : this.contact.MailingCity, MailingStateCode : this.contact.MailingStateCode, MailingPostalCode : this.contact.MailingPostalCode, MailingCountryCode : this.contact.MailingCountryCode};
      });
    } else if (error) {
      console.error('Error:', error);
    }
  }

  /*
    * @description   to fetch picklist values for fields on Enrollment Profile Form
    */
  /*@wire(getPicklistValues, { fieldNames: ['Ethnicity__c', 'Race__c', 'EnglishProficiency__c', 'Gender__c', 'X1stTimeHomeBuyer__c', 'RuralAreaStatus__c', 'MailingStateCode', 'Besttimetocontact__c', 'PreferredLanguage__c', 'RelationshipToPrimaryApplicant__c','MaritalStatus__c', 'Education__c', 'EmploymentStatus__c', 'DisabledStatus__c', 'ActiveMilitary__c'], objectApiName: 'Contact' })
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
      this.bestTimeToCallValues = data.Besttimetocontact__c;
      this.preferredLanguageValues = data.PreferredLanguage__c;
      this.relationshipToPrimaryApplicantValues = data.RelationshipToPrimaryApplicant__c;
      this.maritalStatusValues = data.MaritalStatus__c;
      this.educationValues = data.Education__c;
      this.employmentStatusValues = data.EmploymentStatus__c;
      this.disabledStatusValues = data.DisabledStatus__c;
      this.activeMilitaryValues = data.ActiveMilitary__c;
    }
  }
*/
  handleSelection(event) {
    let lenghtOfSelectedRecords = 0;
    let previousSelctedApplicants = this.selectedApplicants.length;
    this.applicantData = this.applicantData.map(obj => {
      if (event.detail.includes(obj.Name)) {
        lenghtOfSelectedRecords++;
      }
      return { ...obj, selected: event.detail.includes(obj.Name) ? true : false };
    });
    //Show toast on selection of co-applicants from combobox
    if (lenghtOfSelectedRecords > previousSelctedApplicants) {
      this.showToast('theme', this.labels.builderContactSavedToMyProfileLabel, '', 'standard:task2', true, 2000);
    }
  }

  handleRemoveApplicant() {
    this.toggleModal();
    this.showConfirmationModal = !this.showConfirmationModal;
  }

  removeApplicant(event) {
    const recordName = event.target.dataset.recordName;    
    this.applicantData = this.applicantData.map(obj => {
      if (recordName == obj.Name) {
        return { ...obj, selected: false };
      }
      return { ...obj };
    });
    this.showConfirmationModal = !this.showConfirmationModal;
    this.showToast('error', this.labels.builderCoApplicantRemovedLabel, '', 'action:delete', true, 2000); //'utility:error'
  }

  @api
  set applicants(value) {
    this.applicantData = (value) ? value : [...this.applicantData];
  }

  get suffixValues(){
    return getSuffixOptions();
  }

  get applicants() {
    return this.applicantData;
  }

  /*new method to return selection options */
  get selectedApplicantOptions() {
    return this.applicantData.filter(obj => obj && obj.selected).map(obj => obj.Name);
  }

  get applicantOptions() {
    return this.applicantData.filter(obj => obj && obj.Name).map(obj => obj.Name);
  }

  get selectedApplicants() {
    return this.applicantData.filter(item => item.selected == true);
  }

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

  showToast(variant, title, message, iconName, autoClose, autoCloseTime) {
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
    this.dispatchEvent(selectedEvent);
  }

  handleViewEditApplicant(event) {
    this.selectedRecordEditIndex = event.currentTarget.dataset.index;
    let tempModalContact = this.selectedApplicants[event.currentTarget.dataset.index];
    this.modalContact = {...tempModalContact};
    this.toggleModal();
  }

  handleCancel() {
    this.selectedRecordEditIndex = -1;
    this.toggleModal();
  }

  handleCancleConfirmationModal() {
      this.showConfirmationModal = !this.showConfirmationModal;
  }

  @api
  handleNewApplicant() {
    this.modalContact = {sameAsPrimaryContact: true, MailingStreet : this.contact.MailingStreet, MailingAddressLine2__c : this.contact.MailingAddressLine2__c, MailingCity : this.contact.MailingCity, MailingStateCode : this.contact.MailingStateCode, MailingPostalCode : this.contact.MailingPostalCode, MailingCountryCode : this.contact.MailingCountryCode};
    this.toggleModal();
  }

  handleSaveApplicant() {
    try {
      let allValid = true;
      let feilds = this.template.querySelectorAll('.contactField');
      let contactUpdate = {selected: true };
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
        } else if(propertyName === 'sameAsPrimaryContact'){
          contactUpdate[propertyName] = inputField.checked;
        } else if(propertyName === 'Birthdate'){
          let birthdateField = this.template.querySelector(".birthdate-field");
          let birthdateValue = new Date(birthdateField.value);
          let today = new Date();
          today.setHours(0, 0, 0, 0);
          birthdateValue.setHours(0, 0, 0, 0);
          // Check if the birthdate is in the future
            if (birthdateValue >= today) {
                birthdateField.setCustomValidity(this.labels.builderBirthdateValidationLabel);
                allValid = false;
            } else{
              birthdateField.setCustomValidity('');
              birthdateField.reportValidity(); 
              allValid = true;
            }
          contactUpdate[propertyName] = birthdateField.value;
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
      }
      contactUpdate.Name = getFullName(contactUpdate);
      console.log('contactUpdate ===>', JSON.stringify(contactUpdate));
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
      this.selectedRecordEditIndex = -1;
      this.toggleModal();
      this.showToast('theme', this.labels.builderContactSavedToMyProfileLabel, '', 'standard:task2', true, 2000);
    } catch (e) {
      console.error('handleSaveApplicant error : ', e);
    }

  }

  /* @description: Handler method for Next button on Enrollment Profile to validate and save contact detail and move to next screen*/
  @api
  handleNext() {
    return { 'applicants': this.applicantData };
  }

  @api
  handlePrevious() {
    return { 'applicants': this.applicantData };
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
      phonefield.setCustomValidity(this.labels.builderPhoneNumberValidationLabel);
    } else {
      phonefield.setCustomValidity("");
    }
    this.refs.phonefield.value = formattedValue;
    phonefield.reportValidity();
  }
  
  handleChange(event){
    const isChecked = event.target.checked;
    if(isChecked){
      let tempModalContact = {...this.modalContact, sameAsPrimaryContact : isChecked, MailingStreet : this.contact.MailingStreet, MailingAddressLine2__c : this.contact.MailingAddressLine2__c, MailingCity : this.contact.MailingCity, MailingStateCode : this.contact.MailingStateCode, MailingPostalCode : this.contact.MailingPostalCode};
      this.modalContact = {...tempModalContact};
    } else{
      let tempModalContact = {...this.modalContact,sameAsPrimaryContact : isChecked, MailingStreet : '', MailingAddressLine2__c : '', MailingCity : '', MailingStateCode : '', MailingPostalCode : ''};
      this.modalContact = {...tempModalContact};
    }
  }
  
  validateZIPOnChange(event){
    if(isValidateZIPPostal(event.target.value)){
      event.target.setCustomValidity(this.labels.enterOnly5DigitNumbersLabel);
    } else {
      event.target.setCustomValidity("");
    }
  }
    
  get toggleAddress(){
    if(this.modalContact.sameAsPrimaryContact){
      return true;
    }
    return false;
  }

  handleConfirmationModal() {
    this.showConfirmationModal = !this.showConfirmationModal;
    this.toggleModal();
  }
}