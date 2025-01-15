import { LightningElement, api, track, wire } from 'lwc';
import getPotentialDuplicates from '@salesforce/apex/IntakeContactFormController.getPotentialDuplicates';
import getCountyNamesBasedOnZip from '@salesforce/apex/HUDAMICalculationService.getCountyNamesBasedOnZip';
import { getObjectInfo, getPicklistValues, getPicklistValuesByRecordType } from 'lightning/uiObjectInfoApi';
import CONTACT_OBJECT from '@salesforce/schema/Contact';
import HOUSEHOLDTYPE_FIELD from '@salesforce/schema/Contact.HouseholdType__c';
import MaritalStatus__FIELD from '@salesforce/schema/Contact.MaritalStatus__c';
import getDependencyMatrixApex from '@salesforce/apex/DependencyMatrixGenerator.getDependencyMatrix';

export default class EducationalContactForm extends LightningElement {
    @api contact;
    duplicateDetected = false;
    proceedForward = false;
    duplicateTableData = [];
    @api editMode;
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
    @track disabledStatusValues
    @track mailingStateValues;
    @track showWarning = false;
    @track contactRecordTypeId;
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


    @api set dependencyMatrix(value) {
        if (value) {
            console.log('Seeting Dependency : ', value)
            for (let key in value) {
                this[key] = value[key];
            }
            console.log('Setting dependencies');
        }

    }

    get dependencyMatrix() {
        return null;
    }

    @track maritalStatusPickVals;
    @track householdTypePickVals;
    @track houseHoldMaritalMap

    @track recordTypeId;
    @track showSpinner = false;
    @track countyNames = [];
    @track countyTownData;
    @track townNames = [];
    @track townReadOnly = true;
    @track townRequired = false;
    @track countyRequired = false;
    @track countyReadOnly = true;
    @track firstRunDone = false;
    @track employmentStatusValues;

    @api
    set zipcodeData(value) {
        if(value) {
            let {county, MailingPostalCode, ...countyData} = value;
            
            if(Object.keys(countyData).length>0) {
                this.countyTownData = countyData;
                this.countyNames = Object.keys(countyData).map(elt=>{

                    return {
                        label: elt,
                        value: elt
                    }
                })
    
                this.handleCountyChange(county);
            }
            
        }
            
    }

    get zipcodeData() {
        return this.countyTownData;
    }


    @wire(getObjectInfo, { objectApiName: CONTACT_OBJECT }) contactInfoProcess({ error, data }) {
        if (data) {
            console.log('Object Info Data : ', data);
            for (let typeID in data.recordTypeInfos) {
                let recordTypeInfo = data.recordTypeInfos[typeID];
                if (recordTypeInfo.name === 'Prospect') {
                    this.recordTypeId = recordTypeInfo.recordTypeId;
                    break;
                }
            }
        }
        if (error) {

        }
    }

    @wire(getDependencyMatrixApex, { objectName: 'Contact', controllingField: 'MaritalStatus__c', dependentField: 'HouseholdType__c' })
    processHouseholdDependency({ error, data }) {
        this.houseHoldMaritalMap = data;
    }

    @wire(getPicklistValuesByRecordType, { objectApiName: CONTACT_OBJECT, recordTypeId: '$recordTypeId' })
    processAllPicklists({ error, data }) {
        if (error) {

        }
        if (data) {
            console.log('Data For All Picklist Values : ', data);
            let allPicklistValues = data.picklistFieldValues;
            if (data) {
                /*
                if((this.contact.County__c && !this.firstRunDone) || (this.editMode && !this.firstRunDone)){
                    this.showSpinner = true;
                    this.handlePrevious();
                    //this.fetchCountyNames(this.contact.MailingPostalCode,true);
                }
                if(!this.firstRunDone){
                    this.firstRunDone = true;
                }
                */
                this.raceValues = allPicklistValues.Race__c?.values;
                this.ethnicityValues = allPicklistValues.Ethnicity__c?.values;
                this.genderValues = allPicklistValues.Gender__c?.values;
                this.educationValues = allPicklistValues.Education__c?.values;
                this.maritalStatusValues = allPicklistValues.MaritalStatus__c.values;
                //this.householdTypeValues = allPicklistValues.HouseholdType__c?.values;
                this.firstTimeHomebuyerValues = allPicklistValues.X1stTimeHomeBuyer__c?.values;
                this.englishProficiencyValues = allPicklistValues.EnglishProficiency__c?.values;
                this.activeMilitaryValues = allPicklistValues.ActiveMilitary__c?.values;
                this.bestTimeToContactValues = allPicklistValues.Besttimetocontact__c?.values;
                this.preferredLanguageValues = this.sortLanguages(allPicklistValues.PreferredLanguage__c?.values);
                this.veteranValues = allPicklistValues.Veteran__c?.values;
                this.mailingStateValues = allPicklistValues.MailingStateCode?.values;
                this.disabledStatusValues = allPicklistValues.DisabledStatus__c?.values;
                this.employmentStatusValues = allPicklistValues.EmploymentStatus__c?.values;
                this.ruralStatusHouseholdValues = allPicklistValues.RuralAreaStatus__c?.values;

            }

        }
    }

    sortLanguages(values) {
        let spanishVal;
        let englishVal;
        let allLanguages = [];
        values.forEach(elt => {
            if (elt.value === 'English') {
                englishVal = elt;
            }
            else if (elt.value === 'Spanish') {
                spanishVal = elt;
            }
            else {
                allLanguages.push(elt);
            }
        })

        if (spanishVal) {
            allLanguages.unshift(spanishVal);
        }
        if (englishVal) {
            allLanguages.unshift(englishVal);
        }
        return allLanguages;
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
            console.log('contact : ' + JSON.stringify(this.contact));
            let feilds = this.template.querySelectorAll('.contactField');
            console.log('feilds connectedCallback' + JSON.stringify(feilds));
            feilds.forEach(inputField => {
                let propertyName = inputField.name;
                if (this.contact[propertyName]) {
                    inputField.value = this.contact[propertyName];
                }

            });
            this.age = this.contact['Age'];
            this.handleMaritalStatusChange(this.contact?.MaritalStatus__c, true);
            this.choseNottoProvideIncome = this.contact.ChoseNottoProvideIncome__c;
            this.totalMonthlyIncome = this.contact.TotalMonthlyIncome__c;
        } else {
            this.contact = {
                'ChoseNottoProvideIncome__c': false,
                'MarketingCommunicationsOptOut__c': true,
                'PreferredLanguage__c': 'English'
            };
        }
    }

    /* @description: Handler method for Next button on Intake Screen to validate and save contact detail and move to next screen*/
    @api
    handleNext() {
        let allValid = true;
        let feilds = this.template.querySelectorAll('.contactField');
        console.log('feilds ' + JSON.stringify(feilds));
        let contactUpdate = {};
        if (this.contact && this.contact?.Id) {
            contactUpdate = { ...contactUpdate, 'Id': this.contact?.Id };
        }
        feilds.forEach(inputField => {
            let propertyName = inputField.name;
            if (inputField.type==='checkbox') {
                contactUpdate[propertyName] = inputField.checked;
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
        if (this.editMode) {
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
        let contactUpdate = {};

        feilds.forEach(inputField => {
            let propertyName = inputField.name;
            contactUpdate[propertyName] = inputField.value;
        })
        this.contact = contactUpdate;
        this.choseNottoProvideIncome = !this.choseNottoProvideIncome;
        this.choseNottoProvideIncome = this.contact.ChoseNottoProvideIncome__c;
        this.totalMonthlyIncome = this.contact.TotalMonthlyIncome__c;
        console.log('this.choseNottoProvideIncome : '+this.choseNottoProvideIncome);
        console.log('this.totalMonthlyIncome : '+this.totalMonthlyIncome);
        return contactUpdate;
    }
    
    @track choseNottoProvideIncome = false;
    @track totalMonthlyIncome;

    get choseNottoProvideIncomeVal() {
        console.log('this.choseNottoProvideIncome : '+this.choseNottoProvideIncome);
        return this.choseNottoProvideIncome;
    }
    get totalMonthlyIncomeVal() {
        return this.totalMonthlyIncome;
    }
    /* @description: Handler method for input fields */
    handleInputChange(event) {
        console.log('Proxy issue sorted in handleInputChange');
        if (event.target.name === 'ChoseNottoProvideIncome__c') {
            var con = this.contact;
            this.contact = null;
            this.contact = {...con};
            this.choseNottoProvideIncome = event.detail.checked;
            this.contact.ChoseNottoProvideIncome__c = event.detail.checked;
            if(this.choseNottoProvideIncome){
                this.contact.TotalMonthlyIncome__c = null;
                this.totalMonthlyIncome = null;
            }
        }
        if (event.target.name === 'TotalMonthlyIncome__c') {
            var con = this.contact;
            this.contact = null;
            this.contact = {...con};
            this.contact.TotalMonthlyIncome__c = event.detail.value;
            this.totalMonthlyIncome = event.detail.value;
        }
        if (event.target.name === 'FirstName') {
            this.validateNameInput(event);
        }

        

        if (event.target.name === 'LastName') {
            this.validateNameInput(event);
        }
        
        if (event.target.name === 'County__c') {
            let data = '';
            data = event.target.value;
            this.handleCountyChange(data);
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
        if (event.target.name === 'MaritalStatus__c') {
            this.handleMaritalStatusChange(event.detail.value);
        }

        if(event.target.name==='CreditScore__c') {
            this.handleCreditScoreChange(event);
        }

        if (event.target.name === 'MailingPostalCode') {
            //this.validateZIPOnChange(event);
            
            if(this.validateZIPOnChange(event)){
                //this.showSpinner = true;
                this.fetchCountyNames(event.detail.value);
            } else {
                this.resetCountyTownData();
            }
            
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
            this.contact = {...this.contact,'Age':this.age};
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
        if (ssnDigitsOnly==='' || (event.target.value.match(/^\(?\d{3}\)?[\s.-]?\d{2}[\s.-]?\d{4}$/) && ssnDigitsOnly.length === 9)) {
            event.target.setCustomValidity("");
            event.target.value=this.formatSSNNumber(s);
        } else {
            event.target.setCustomValidity('Must be 9 digit');
            event.target.value=ssnDigitsOnly;
        }
        event.target.reportValidity();
    }

    handleCreditScoreChange(event) {
        if(event.detail.value?.length!==3) {
            event.target.setCustomValidity("Must be 3 digits");
        } else {
            event.target.setCustomValidity("");
        }
        event.target.reportValidity();
    }

    validateZIPOnChange(event) {
        if (!event.target.value.match(/^[0-9]+$/) || event.target.value.length < 5) {
            event.target.setCustomValidity("Enter only 5 digit numbers");
            return false;
        } else {
            event.target.setCustomValidity("");
            return true;
        }
    }
    
    async fetchCountyNames(zip){
        try{
            console.log('zip : '+zip);
            this.countyTownData = await getCountyNamesBasedOnZip({zipCode : zip});
            let countyTownData = JSON.parse(JSON.stringify(this.countyTownData));
            console.log(countyTownData);
            if(Object.keys(countyTownData).length===0) {
                this.resetCountyTownData();
                return false;
            }
            this.countyNames = Object.keys(countyTownData).map(elt=>{

                return {
                    label: elt,
                    value: elt
                }
            })
            
            return true;
        } catch (error){
            this.resetCountyTownData();
            console.error(error);
            return false;
        }
    }

    resetCountyTownData() {
        this.countyTownData=null;
        this.countyNames=null;
        this.townNames=null;
    }

    handleCountyChange(value) {
        let countyData = JSON.parse(JSON.stringify(this.countyTownData));
        this.townNames = countyData[value].map(elt=>{return {label: elt, value: elt}});
        if(this.townNames.length===1) {
            this.contact = {...JSON.parse(JSON.stringify(this.contact)), 'Town__c':this.townNames[0]?.value}
        }
    }

    get showCountyFields() {
        return this.countyTownData!=null
    }

    /* @description : changing Marital Status based on household type*/
    handleMaritalStatusChange(val, retainValue) {
        if(!retainValue){
            this.contact = { ...this.contact, 'HouseholdType__c': null }
        }
        
        let householdValues = this.houseHoldMaritalMap[val];
        this.householdTypeValues = householdValues;

    }

    /**
     * 
     * @description format phone number to given format
     * 
     */
    formatPhoneNumber(s) {
        return '('+s.substr(0,3)+') '+s.substr(3,3)+'-'+s.substr(6);
    }

    /**
     * 
     * @description format SSN number to given format
     * 
     */
    formatSSNNumber(s) {
        return (s && s.length> 0)?s.substr(0,3)+'-' + s.substr(3,2) + '-' + s.substr(5):'';
    }

    /**
     * @description boolean getter for show town names
     */

    get showTownNames() {
        return this.townNames && Array.isArray(this.townNames) && this.townNames.length>0;
    }
}