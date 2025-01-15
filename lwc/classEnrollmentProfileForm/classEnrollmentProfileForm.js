import { LightningElement, wire, api, track } from 'lwc';
//import getPicklistValues from '@salesforce/apex/EnrollmentFormController.getPicklistValues';
import getPrimaryContactInformation from '@salesforce/apex/EnrollmentFormController.getPrimaryContactInformation';
import USER_ID from '@salesforce/user/Id';
import NAME_FIELD from "@salesforce/schema/User.Name";
import EMAIL_FIELD from "@salesforce/schema/User.Email";
import { getRecord } from 'lightning/uiRecordApi';
import {isEmptyObject, formatPhoneNumber, isValidValue, isValidPhoneNumber, isValidateZIPPostal} from'c/lwrUtils';
import CONTACT_OBJECT from "@salesforce/schema/Contact";
import { getObjectInfo, getPicklistValuesByRecordType } from "lightning/uiObjectInfoApi";
export default class ClassEnrollmentProfileForm extends LightningElement {
    userId = USER_ID;

    @api contact;
    @api labels;

    @track ethnicityValues;
    @track mailingStateValues;
    @track raceValues;
    @track englishProficiencyValues;
    @track communityValues;
    @track veteranValues;
    @track genderValues;
    @track firstTimeHomeBuyerValues;
    @track bestTimeToCallValues;
    @track disabledStatusValues;
    @track houseHoldTypeValues;
    @track activeMilitaryValues;
    @track maritalStatusValues;
    @track employmentStatusValues;
    @track user;
    @track contactRecordTypeId;
    @track picklistValues;
    @track maritalStatusSelectedValue;
    @track houseHoldTypeFieldData;

    get isChoseNottoProvideIncomeChecked(){
        console.log('in get ==>',this.contact);
        return this.contact.ChoseNottoProvideIncome__c ? true : false;  
    }

    connectedCallback() {
        if (this.contact) {
            let feilds = this.template.querySelectorAll('.contactField');
            feilds.forEach(inputField => {
                let propertyName = inputField.name;
                if (this.contact[propertyName]) {
                    inputField.value = this.contact[propertyName];
                }
            });
        } else {
            this.contact = {};
        }

    }

    @wire(getRecord, {
        recordId: '$userId',
        fields: [NAME_FIELD, EMAIL_FIELD]
    })
    wiredUser({ error, data }) {
        if (data) {
            this.user = data.fields;
            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.user = undefined;
        }
    }

    /*
    * @description   to fetch picklist values for fields on Enrollment Profile Form
    */
   /* @wire(getPicklistValues, { fieldNames: ['MailingStateCode', 'Ethnicity__c', 'Race__c', 'EnglishProficiency__c', 'RuralAreaStatus__c', 'Gender__c', 'X1stTimeHomeBuyer__c', 'Besttimetocontact__c', 'DisabledStatus__c', 'HouseholdType__c', 'ActiveMilitary__c', 'MaritalStatus__c', 'EmploymentStatus__c'], objectApiName: 'Contact' })
    fetchPickListValues({ error, data }) {
        if (error) {
            console.error('error ' + JSON.stringify(error));
        }
        if (data) {
            this.ethnicityValues = data.Ethnicity__c;
            this.mailingStateValues = data.MailingStateCode;
            console.log('mailingStateValues ==', JSON.stringify(this.mailingStateValues));
            this.raceValues = data.Race__c;
            this.englishProficiencyValues = data.EnglishProficiency__c;
            this.communityValues = data.RuralAreaStatus__c;
            this.genderValues = data.Gender__c;
            this.firstTimeHomeBuyerValues = data.X1stTimeHomeBuyer__c;
            this.bestTimeToCallValues = data.Besttimetocontact__c;
            this.disabledStatusValues = data.DisabledStatus__c;
            this.houseHoldTypeValues = data.HouseholdType__c;
            this.activeMilitaryValues = data.ActiveMilitary__c;
            this.maritalStatusValues = data.MaritalStatus__c;
            this.employmentStatusValues = data.EmploymentStatus__c;
        }
    }
*/
    @wire(getObjectInfo, { objectApiName: CONTACT_OBJECT }) wireAccountData(objectInfo,error){
        if(objectInfo){
            
            let recordTypeInfo = objectInfo?.data?.recordTypeInfos;
            if(recordTypeInfo){
                this.contactRecordTypeId = Object.keys(recordTypeInfo).find(rtype=>(recordTypeInfo[rtype].name === 'Prospect'));
            }
        }
    }

    @wire(getPicklistValuesByRecordType, { objectApiName: CONTACT_OBJECT, recordTypeId: '$contactRecordTypeId' })
    picklistValuesHandler({ error, data }) {
        if (data) {
            this.picklistValues = data.picklistFieldValues;
            this.ethnicityValues = this.picklistValues?.Ethnicity__c?.values;
            this.mailingStateValues = this.picklistValues?.MailingStateCode?.values;
            console.log('mailingStateValues ==', JSON.stringify(this.mailingStateValues));
            this.raceValues = this.picklistValues?.Race__c?.values;
            this.englishProficiencyValues = this.picklistValues?.EnglishProficiency__c?.values;
            this.communityValues =  this.picklistValues?.RuralAreaStatus__c?.values;
            this.veteranValues = this.picklistValues?.Veteran__c?.values;
            this.genderValues = this.picklistValues?.Gender__c?.values;
            this.firstTimeHomeBuyerValues = this.picklistValues?.X1stTimeHomeBuyer__c?.values;
            this.bestTimeToCallValues = this.picklistValues?.Besttimetocontact__c?.values
            this.disabledStatusValues = this.picklistValues?.DisabledStatus__c?.values;
           // this.houseHoldTypeValues = this.picklistValues?.HouseholdType__c?.values;
            this.activeMilitaryValues = this.picklistValues?.ActiveMilitary__c?.values;
            this.maritalStatusValues = this.picklistValues?.MaritalStatus__c?.values;
            this.employmentStatusValues = this.picklistValues?.EmploymentStatus__c?.values;
            this.houseHoldTypeFieldData = this.picklistValues?.HouseholdType__c;
        } else if (error) {
            console.log('getPicklistValuesByRecordType error===>', JSON.stringify(error));
            this.error = error;
        }
    }


    @wire(getPrimaryContactInformation)
    wiredPrimaryData({ error, data }) {
        if (isEmptyObject(this.contact) && data) {
            let newData = {...data, Phone : formatPhoneNumber(data.Phone)};
            this.contact = newData;
            this.maritalStatusSelectedValue = this.contact.MaritalStatus__c;
        } else if (error) {
            console.error('Error:', error);
        }
    }

    get userName() {
        return this.user ? this.user.Name.value : '';
    }

    get userEmail() {
        return this.user ? this.user.Email.value : '';
    }

    get houseHoldTypeOptions(){
        if(this.maritalStatusSelectedValue){
            let key = this.houseHoldTypeFieldData.controllerValues[this.maritalStatusSelectedValue];
            return this.houseHoldTypeFieldData.values.filter(opt => opt.validFor.includes(key));
        }
    }

    get isMaritalStatusBlank(){
        if(this.maritalStatusSelectedValue){
            return false;
        }
        return true;
    }

    handleChange(event) {
        if(event.target.name === 'MaritalStatus__c'){
        this.maritalStatusSelectedValue = event.target.value;
        } else if(event.target.name === "ChoseNottoProvideIncome__c"){
            //this.isChoseNottoProvideIncomeChecked = event.target.checked;
            let tempContact = {...this.contact};
            tempContact.TotalMonthlyIncome__c = '';
            tempContact.ChoseNottoProvideIncome__c = event.target.checked;
            this.contact = tempContact;
            console.log(' ChoseNottoProvideIncome__c changed ==>', tempContact);
        }else if(event.target.name === "TotalMonthlyIncome__c"){
            let tempContact = {...this.contact};
            tempContact.TotalMonthlyIncome__c = event.target.value;
            this.contact = tempContact;
        }
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
  

    /* @description: Handler method for Next button on Enrollment Profile to validate and save contact detail and move to next screen*/
    @api
    handleNext() {
        let allValid = true;
        let feilds = this.template.querySelectorAll('.contactField');

        let contactUpdate = {};
        feilds.forEach(inputField => {
            let propertyName = inputField.name;
            if (propertyName === 'Phone') {
                contactUpdate[propertyName] = inputField.value;// ? inputField.value.replace(/\D/g, "") : "";
            } else if(propertyName === 'Birthdate'){
                let birthdateField = this.template.querySelector(".birthdate-field");
                let birthdateValue = new Date(birthdateField.value);
                let today = new Date();
                today.setHours(0, 0, 0, 0);
                birthdateValue.setHours(0, 0, 0, 0);
                // Check if the birthdate is in the future
                if (birthdateValue >= today) {
                    birthdateField.setCustomValidity(this.labels.builderBirthdateValidationLabel);
                    birthdateField.reportValidity();
                    allValid = false;
                }else{
                    birthdateField.setCustomValidity('');
                    birthdateField.reportValidity(); 
                } 
                contactUpdate[propertyName] = birthdateField.value;
            } else if(propertyName === "ChoseNottoProvideIncome__c"){
                console.log('ChoseNottoProvideIncome__c ===>',inputField.checked);
                contactUpdate[propertyName] = inputField.checked;
                console.log('contactUpdate ===>',contactUpdate);
            } else {
                contactUpdate[propertyName] = inputField.value;
            }
            if (!inputField.checkValidity()) {
                inputField.reportValidity();
                allValid = false;
            }
        });
        this.contact = contactUpdate;
        return { 'allValid': allValid, 'contact': this.contact };
    }

    validateZIPOnChange(event){
        if(isValidateZIPPostal(event.target.value)){
            event.target.setCustomValidity(this.labels.enterOnly5DigitNumbersLabel);
        } else {
            event.target.setCustomValidity("");
        }
    }
}