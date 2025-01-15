import { LightningElement, api, track, wire } from 'lwc';
import getPotentialDuplicates from '@salesforce/apex/IntakeContactFormController.getPotentialDuplicates';
import getCaseTypes from '@salesforce/apex/EmergencyTriageController.getCaseTypes';
import { getObjectInfo, getPicklistValues, getPicklistValuesByRecordType } from 'lightning/uiObjectInfoApi';
import CONTACT_OBJECT from '@salesforce/schema/Contact';
import HOUSEHOLDTYPE_FIELD from '@salesforce/schema/Contact.HouseholdType__c';
import MaritalStatus__FIELD from '@salesforce/schema/Contact.MaritalStatus__c';

export default class EmergencyContactForm extends LightningElement {
    @api contact;
    duplicateDetected = false;
    proceedForward = false;
    duplicateTableData = [];
    @api existingMode;
    @track age;
    @track raceValues;
    @track ethnicityValues;
    @track genderValues;
    @track educationValues;
    @track maritalStatusValues;
    @track householdTypeValues;
    @track firstTimeHomebuyerValues;
    @track ruralStatusHouseholdValues;
    @track englishProficiencyValues;
    @track activeMilitaryValues;
    @track veteranValues;
    @track bestTimeToContactValues;
    @track preferredLanguageValues;
    @track mailingStateValues;
    @track showWarning = false;
    @track contactRecordTypeId;
    @track availableRecordTypes;
    @track suffixValues = [
        {
            label: 'Sr.',
            value: 'Sr.'
        },
        {
            label: 'Jr.',
            value: 'Jr.'
        },
        {
            label: 'III',
            value: 'III'
        },
        {
            label: 'IV',
            value: 'IV'
        }
    ];

    maritalStatusPickVals;
    householdTypePickVals;

    @track recordTypeId;


    @wire(getObjectInfo, { objectApiName: CONTACT_OBJECT }) contactInfoProcess({error, data}) {
        if(data) {
            console.log('Object Info Data : ', data);
            for(let typeID in data.recordTypeInfos) {
                let recordTypeInfo = data.recordTypeInfos[typeID];
                if(recordTypeInfo.name==='Prospect') {
                    this.recordTypeId = recordTypeInfo.recordTypeId;
                    break;
                }
            }
        }
        if(error) {

        }
    }

    @wire(getCaseTypes)
    processCaseTypes({ error, data }) {
        if (error) {

        }
        if (data) {
            const caseTypes = JSON.parse(JSON.stringify(data));
            this.availableRecordTypes = caseTypes.map(elt => { return { 'label': elt.Name, 'value': elt.Name } })

        }
    }

    @wire(getPicklistValuesByRecordType, { objectApiName: CONTACT_OBJECT, recordTypeId: '$recordTypeId' })
    processAllPicklists({ error, data }) {
        if (error) {

        }
        if (data) {
            console.log('Data For All Picklist Values : ', data);
            let allPicklistValues = data.picklistFieldValues;
            if (data) {
                console.log('Data : ', data);
                this.raceValues = allPicklistValues.Race__c?.values;
                this.ethnicityValues = allPicklistValues.Ethnicity__c?.values;
                this.genderValues = allPicklistValues.Gender__c?.values;
                this.educationValues = allPicklistValues.Education__c?.values;
                //this.maritalStatusValues = data.MaritalStatus__c;
                this.householdTypeValues = allPicklistValues.HouseholdType__c?.values;
                this.firstTimeHomebuyerValues = allPicklistValues.X1stTimeHomeBuyer__c?.values;
                this.englishProficiencyValues = allPicklistValues.EnglishProficiency__c?.values;
                this.activeMilitaryValues = allPicklistValues.ActiveMilitary__c?.values;
                this.bestTimeToContactValues = allPicklistValues.Besttimetocontact__c?.values;
                this.preferredLanguageValues = this.sortPreferedLanguages(allPicklistValues.PreferredLanguage__c?.values);
                this.veteranValues = allPicklistValues.Veteran__c?.values;
                this.mailingStateValues = allPicklistValues.MailingStateCode?.values;

            }
        }
    }

    sortPreferedLanguages(languages) {
        if(languages && Array.isArray(languages) && languages.length>2) {
            let sortedList=[];
            let spanishValue, englishValue;
            for(let i=0; i<languages.length; i++) {
                if(languages[i].value==='Spanish') {
                    spanishValue = languages[i];
                }
                if(languages[i].value==='English') {
                    englishValue = languages[i];
                }
                else sortedList.push(languages[i]);
            }
        
            if(spanishValue) {
                sortedList.unshift(spanishValue);
            }

            if(englishValue) {
                sortedList.unshift(englishValue);
            }
            
            return sortedList;
        } else {
            return languages;
        }
    }

    @wire(getPicklistValues, { recordTypeId: '$recordTypeId', fieldApiName: HOUSEHOLDTYPE_FIELD })
    processHouseHoldValues({ error, data }) {
        if (data) {
            console.log('HOUSEHOLDTYPE_FIELD Data : ', data.values);
            this.householdTypePickVals = data;
        }
        else if (error) {

        }
    }

    @wire(getPicklistValues, { recordTypeId: '$recordTypeId', fieldApiName: MaritalStatus__FIELD })
    processMaritalValues({ error, data }) {
        if (data) {
            console.log('MaritalStatus__FIELD Data : ', data.values);
            this.maritalStatusPickVals = data;
        }
        else if (error) {

        }
    }


    connectedCallback() {
        if (this.contact) {
            let feilds = this.template.querySelectorAll('.contactField');
            console.log('feilds connectedCallback' + JSON.stringify(feilds));
            feilds.forEach(inputField => {
                let propertyName = inputField.name;
                if (this.contact[propertyName]) {
                    inputField.value = this.contact[propertyName];
                }

            });
            this.age = this.contact['Age'];
        } else {
            this.contact = {'PreferredLanguage__c': 'English'};
        }

    }

    /*
    * @description   to fetch picklist values for fields on Client Case
    */
    //     @wire(getPicklistValuesApex, { fieldNames: ['Race__c', 'Ethnicity__c', 'Gender__c', 'Education__c', 'MaritalStatus__c', 'HouseholdType__c', 'X1stTimeHomeBuyer__c', 'EnglishProficiency__c','ActiveMilitary__c','Veteran__c', 'Besttimetocontact__c','PreferredLanguage__c','MailingStateCode'], objectApiName: 'Contact' })
    //     fetchPickListValues({ error, data }) {
    //         console.log('Inside Wire method')
    //         if (error) {
    // console.log('error '+JSON.stringify(error));
    //         }
    //         if (data) {
    //             console.log('Data : ',data);
    //             this.raceValues = data.Race__c;
    //             this.ethnicityValues = data.Ethnicity__c;
    //             this.genderValues = data.Gender__c;
    //             this.educationValues = data.Education__c;
    //             //this.maritalStatusValues = data.MaritalStatus__c;
    //             this.householdTypeValues = data.HouseholdType__c;
    //             this.firstTimeHomebuyerValues = data.X1stTimeHomeBuyer__c;
    //             this.englishProficiencyValues = data.EnglishProficiency__c;
    //             this.activeMilitaryValues = data.ActiveMilitary__c;
    //             this.bestTimeToContactValues = data.Besttimetocontact__c;
    //             this.preferredLanguageValues = data.PreferredLanguage__c;
    //             this.veteranValues = data.Veteran__c;
    //             this.mailingStateValues = data.MailingStateCode;

    //         }
    //     }

    /* @description: Handler method for Next button on Intake Screen to validate and save contact detail and move to next screen*/
    @api
    handleNext() {
        let allValid = true;
        let feilds = this.template.querySelectorAll('.contactField');
        console.log('feilds ' + JSON.stringify(feilds));
        let contactUpdate = {};
        if(this.contact && this.contact?.Id) {
            contactUpdate = {...contactUpdate, 'Id':this.contact?.Id};
        }
        feilds.forEach(inputField => {
            let propertyName = inputField.name;
            if (propertyName === 'Phone') {
                contactUpdate[propertyName] = inputField.value ? inputField.value.replaceAll("(", "").replaceAll(")", "").replaceAll(" ", "").replaceAll("-", "").replaceAll(".", "") : "";
            } else {
                contactUpdate[propertyName] = inputField.value;
            }

            if (!inputField.checkValidity()) {
                inputField.reportValidity();
                allValid = false;
            }
        });

        if (this.duplicateDetected === true) {
            this.duplicateDetected = false;
        }
        this.contact = contactUpdate;
        console.log('next ' + JSON.stringify(this.contact));
        if (this.proceedForward === true) {
            let ev = new CustomEvent('moveforward', { detail: { contact: this.contact } });
            this.dispatchEvent(ev);
            return null;
        }
        if (this.existingMode) {
            this.proceed(null); 
        }
        if (allValid === true) {
            getPotentialDuplicates({
                con: this.contact
            })
                .then((result) => {
                    if (result != null && result.length > 0) {
                        let resData = JSON.parse(JSON.stringify(result));
                        resData.forEach(res => {
                            res.ClientId = res.Client__c ? res.Client__c : '';
                            res.conLink = '/' + res.Id;
                            res.Email = res.Email ? res.Email : '';
                            res.Phone = res.Phone ? res.Phone : '';
                            var add = '';
                            if (res.MailingStreet) {
                                add += res.MailingStreet;
                            }
                            if (res.MailingCity) {
                                add += add != '' ? add + ', ' + res.MailingCity : res.MailingCity;
                            }
                            if (res.MailingCountry) {
                                add += add != '' ? add + ', ' + res.MailingCountry : res.MailingCountry;
                            }
                            if (res.MailingPostalCode) {
                                add += add != '' ? add + ', ' + res.MailingPostalCode : res.MailingPostalCode;
                            }
                            res.Address = add;
                        });

                        this.duplicateTableData = resData;
                        this.duplicateDetected = true;
                        console.log('contactUpdate ' + JSON.stringify(contactUpdate));
                        return { 'allValid': false, 'contact': contactUpdate };
                    }
                })
                .catch((error) => {
                    this.duplicateTableData = undefined;

                })
                .finally(() => {
                    if (!this.duplicateDetected === true) {
                        this.proceed(null);
                    }
                })
        } else {
            return { 'allValid': allValid, 'contact': this.contact };
        }
    }

    /* @description: Handler method to set DuplicateDetected var's value */
    setDuplicateDetected(event) {
        this.duplicateDetected = event.detail.value;
    }

    /* @description: Handler method to set proceedForward var's value */
    proceed(event) {
        this.proceedForward = true;
        this.handleNext();
    }

    /* @description: Handler method for Previous button on Intake Screen to go back on previous screen */
    @api
    handlePrevious() {
        let feilds = this.template.querySelectorAll('.contactField');
        console.log('feilds ' + JSON.stringify(feilds));
        let contactUpdate = {};

        if(this.contact && this.contact?.Id) {
            contactUpdate = {...contactUpdate, 'Id':this.contact?.Id};
        }

        feilds.forEach(inputField => {
            let propertyName = inputField.name;
            contactUpdate[propertyName] = inputField.value;
        })

        this.contact = contactUpdate;

        return contactUpdate;
    }

    get recordTypes() {
        return this.availableRecordTypes;
    }

    /* @description: Handler method for input fields */
    handleInputChange(event) {
        if (event.target.name === 'FirstName') {
            this.validateNameInput(event);
        }

        if (event.target.name === 'HouseholdType__c') {
            this.handleHouseHoldChange(event);
        }

        if (event.target.name === 'LastName') {
            this.validateNameInput(event);
        }

        if (event.target.name === 'Phone') {
            this.validatePhoneInput(event);
        }

        if (event.target.name === 'Email') {
            this.validateEmailInput(event);
        }

        if (event.target.name === 'SSN__c') {
            this.validateSSNOnChange(event);
        }

        if (event.target.name === 'MailingPostalCode') {
            this.validateZIPOnChange(event);
        }

        if (event.target.name === 'Birthdate') {
            this.showWarning = false;
            console.log(event.detail.value);
            let d1 = new Date(event.detail.value);
            let d2 = new Date();

            let varAge = d2.getYear() - d1.getYear();
            console.log(varAge);

            if (d1.getUTCMonth() < d2.getUTCMonth()) {

                console.log('Month');
                -varAge;

            } else if (d1.getUTCMonth() === d2.getUTCMonth()) {

                console.log('Day');
                console.log(d1.getUTCDate());
                console.log(d2.getUTCDate());

                if (d1.getUTCDate() < d2.getUTCDate())
                    -varAge;
            }
            console.log('varAge ' + varAge);
            this.age = varAge;
            console.log('this.age ' + this.age);
            this.contact['Age'] = this.age;
            console.log('this.contact[Age] ' + this.contact['Age']);
            if (this.age < 18) {
                this.showWarning = true;
            }
            console.log('age' + varAge);

        }

    }

    /* @description: Helper method for first name and last name input validation*/
    validateNameInput(event) {
        let nameInput;
        if (event.target.name === 'FirstName') {
            nameInput = this.template.querySelector(".firstNameField");
        } else if (event.target.name === 'LastName') {
            nameInput = this.template.querySelector(".lastNameField");
        }

        if (nameInput.value.match(/^[\p{L}\p{M}' !@#$%\d-]+$/u)) {
            nameInput.setCustomValidity("");
        } else {
            nameInput.setCustomValidity('Must only contains letter characters');
        }
        nameInput.reportValidity();
    }

    /* @description : changing Marital Status based on household type*/
    handleHouseHoldChange(event) {
        let householdType = event.detail.value;
        let index = this.maritalStatusPickVals.controllerValues[householdType];
        this.maritalStatusValues = this.maritalStatusPickVals.values.filter(opt => {
            return opt.validFor.includes(index);
        }).map(opt1 => {
            return { 'label': opt1.label, 'value': opt1.value }
        })
    }

    /* @description: Helper method for phone input validation*/
    validatePhoneInput(event) {
        let phoneCMP = this.template.querySelector(".phoneField");//^\d{10}$
        let phnDigitsOnly = event.detail.value ? (event.detail.value).replaceAll("(", "").replaceAll(")", "").replaceAll(" ", "").replaceAll("-", "").replaceAll(".", "") : "";
        if (phoneCMP.value.match(/^\(?\d{3}\)?[\s.-]?\d{3}[\s.-]?\d{4}$/) && phnDigitsOnly.length === 10) {
            phoneCMP.setCustomValidity("");
            phoneCMP.value = this.formatPhoneNumber(phnDigitsOnly);
        }
        else if(phnDigitsOnly.length === 0) {
            phoneCMP.setCustomValidity("");
            phoneCMP.value = '';
        } else {
            phoneCMP.setCustomValidity('Must be 10 digit');
            phoneCMP.value = phnDigitsOnly;
        }
        phoneCMP.reportValidity();
    }

    /* @description: Helper method for email input validation*/
    validateEmailInput(event) {
        let emailCMP = this.template.querySelector(".emailField");
        if (!emailCMP.value || !emailCMP.value.includes('@')) {
            emailCMP.setCustomValidity('You have entered an invalid format.');
        } else if (emailCMP.value.match(/^[a-zA-Z0-9_-]+[a-zA-Z0-9._-]+@[a-zA-Z0-9-]+(\.[a-zA-Z]{2,6})+$/)) {
            emailCMP.setCustomValidity("");
        } else {
            emailCMP.setCustomValidity('You have entered an invalid format');
        }
        emailCMP.reportValidity();
    }

    /*
     * @description  Validate SSN on value change
     */
    validateSSNOnChange(event) {
        let ssnDigitsOnly = event.target.value ? (event.target.value).replaceAll("-", "") : "";
        if (ssnDigitsOnly === '' || (event.target.value.match(/^\(?\d{3}\)?[\s.-]?\d{2}[\s.-]?\d{4}$/) && ssnDigitsOnly.length === 9)) {
            event.target.setCustomValidity("");
            event.target.value = this.formatSSNNumber(ssnDigitsOnly);
        } else {
            event.target.setCustomValidity('Must be 9 digit');
            event.target.value = ssnDigitsOnly;
        }
        event.target.reportValidity();
    }

    validateZIPOnChange(event) {
        if (!event.target.value.match(/^[0-9]+$/) || event.target.value.length < 5) {
            event.target.setCustomValidity("Enter only 5 digit numbers");
        } else {
            event.target.setCustomValidity("");
        }
    }

    /**
     * 
     * @description format SSN number to given format
     * 
     */
    formatSSNNumber(s) {
        return (s && s.length>0) ? s.substr(0,3)+'-' + s.substr(3,2) + '-' + s.substr(5):'';
    }

    /**
     * 
     * @description format phone number to given format
     * 
     */
    formatPhoneNumber(s) {
        return '('+s.substr(0,3)+') '+s.substr(3,3)+'-'+s.substr(6);
    }
}