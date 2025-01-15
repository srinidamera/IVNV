import { LightningElement, api, track, wire } from 'lwc';
import getPotentialDuplicates from '@salesforce/apex/IntakeContactFormController.getPotentialDuplicates';
import getCountyNamesBasedOnZip from '@salesforce/apex/HUDAMICalculationService.getCountyNamesBasedOnZip';
import getPicklistValues from '@salesforce/apex/IntakeFormController.getPicklistValues';
import getCaseTypes from '@salesforce/apex/IntakeFormController.getCaseTypes';
import getDependencyMatrixApex from '@salesforce/apex/DependencyMatrixGenerator.getDependencyMatrix';
import LightningAlert from 'lightning/alert';


import REVERSE_MORTGAGE_VALIDATION from '@salesforce/label/c.IntakeReverseMortgageValidation';

export default class IntakeContactForm extends LightningElement {
    @api contact;
    @api caseRecord;

    duplicateDetected = false;
    proceedForward = false;
    duplicateTableData = [];
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
    @track farmWorkerValues;
    @track coloniasResidenceValues;
    @track disableStatusValues;
    @track clientHUDAssistanceValues;
    @track employmentStatusValues;
    @track ruralAreaStatusValues;
    @track countyNames = [];
    @track countyTownData;
    @track townNames = [];
    @track townReadOnly = true;
    @track showWarning = false;
    @api editMode;
    @track townRequired = false;
    @track countyRequired = false;
    @track countyReadOnly = true;
    @track showSpinner = false;
    @track firstRunDone = false;
    @track toggleSubCaseType = false;
    @track caseSubTypeValues;
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

    label = {
        REVERSE_MORTGAGE_VALIDATION
    }


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

    @api
    set zipcodeData(value) {
        if (value) {
            let { county, MailingPostalCode, ...countyData } = value;

            if (countyData && Object.keys(countyData).length > 0) {
                this.countyTownData = countyData;
                this.countyNames = Object.keys(countyData).map(elt => {

                    return {
                        label: elt,
                        value: elt
                    }
                })
                if (county)
                    this.handleCountyChange(county);
            }

        }

    }

    get zipcodeData() {
        return this.countyTownData;
    }

    @track referralSourceValues;

    @track currentResidenceValues = [
        {
            label: 'Own',
            value: 'Own'
        },
        {
            label: 'Rent',
            value: 'Rent'
        },
        {
            label: 'Others',
            value: 'Others'
        }
    ];

    availableRecordTypes;

    /*
    * @description   Getter method for record types fetched
    */
    get recordTypes() {
        return this.availableRecordTypes;
    }

    connectedCallback() {
        if (this.contact) {
            // let feilds = this.template.querySelectorAll('.contactField');
            // console.log('feilds connectedCallback'+JSON.stringify(feilds));
            // feilds.forEach(inputField => {
            //     let propertyName = inputField.name;
            //     if (this.contact[propertyName]) {
            //         inputField.value = this.contact[propertyName];
            //     }

            // });
            // this.age = this.contact['Age'];
            this.handleMaritalStatusChange(this.contact?.MaritalStatus__c, true);
            if(this.contact && this.contact?.MailingPostalCode) {
                this.fetchCountyNames(this.contact?.MailingPostalCode);
            }
            this.choseNottoProvideIncome = this.contact.ChoseNottoProvideIncome__c;
            this.totalMonthlyIncome = this.contact.TotalMonthlyIncome__c;
        } else {
            this.contact = {
                'ChoseNottoProvideIncome__c': false,
                'PreferredLanguage__c': 'English',
                'MarketingCommunicationsOptOut__c': true
            };
        }

        if (!this.caseRecord) {
            this.caseRecord = {};
        }

    }

    @wire(getCaseTypes)
    processCaseTypes({ error, data }) {
        if (error) {

        }
        if (data) {
            const caseTypes = JSON.parse(JSON.stringify(data));
            this.availableRecordTypes = [];

            for (let i = 0; i < caseTypes.length; i++) {
                this.availableRecordTypes.push({ 'label': caseTypes[i].Name, 'value': caseTypes[i].Id, 'isReverseMortgage': caseTypes[i].is_Reverse_Mortage__c });
            }

        }
    }

    @wire(getDependencyMatrixApex, { objectName: 'Contact', controllingField: 'MaritalStatus__c', dependentField: 'HouseholdType__c' })
    processHouseholdDependency({ error, data }) {
        this.houseHoldMaritalMap = data;
    }



    /*
    * @description   to fetch picklist values for fields on Client Case
    */
    @wire(getPicklistValues, { fieldNames: ['ReferralSource__c', 'RuralAreaStatus__c', 'CurrentResidence__c', 'EmploymentStatus__c', 'ClientHUDAssistance__c', 'DisabledStatus__c', 'ColoniasResidence__c', 'FarmWorker__c', 'Race__c', 'Ethnicity__c', 'Gender__c', 'Education__c', 'MaritalStatus__c', 'HouseholdType__c', 'X1stTimeHomeBuyer__c', 'EnglishProficiency__c', 'ActiveMilitary__c', 'Veteran__c', 'Besttimetocontact__c', 'PreferredLanguage__c', 'MailingStateCode'], objectApiName: 'Contact' })
    fetchPickListValues2({ error, data }) {
        console.log('Inside Wire method')
        if (error) {
            console.log('error ' + JSON.stringify(error));
        }
        if (data) {
            console.log('Data updated : ', data);
            /*
            if(this.contact?.County__c && !this.firstRunDone){
                    this.showSpinner = true;
                    let feilds = this.template.querySelectorAll('.contactField');
                    console.log('feilds from wire : ' + JSON.stringify(feilds));
                    //this.handlePrevious();
                    this.fetchCountyNames(this.contact.MailingPostalCode,true);
            }
            if(!this.firstRunDone){
                    this.firstRunDone = true;
            }
            */
            this.raceValues = data.Race__c;
            this.ethnicityValues = data.Ethnicity__c;
            this.genderValues = data.Gender__c;
            this.educationValues = data.Education__c;
            this.maritalStatusValues = data.MaritalStatus__c;
            //this.householdTypeValues = data.HouseholdType__c;
            this.firstTimeHomebuyerValues = data.X1stTimeHomeBuyer__c;
            this.englishProficiencyValues = data.EnglishProficiency__c;
            this.activeMilitaryValues = data.ActiveMilitary__c;
            this.bestTimeToContactValues = data.Besttimetocontact__c;
            this.preferredLanguageValues = data.PreferredLanguage__c;
            this.veteranValues = data.Veteran__c;
            this.mailingStateValues = data.MailingStateCode;
            //New field  Values
            this.farmWorkerValues = data.FarmWorker__c;
            this.coloniasResidenceValues = data.ColoniasResidence__c;
            this.disableStatusValues = data.DisabledStatus__c;
            this.clientHUDAssistanceValues = data.ClientHUDAssistance__c;
            this.employmentStatusValues = data.EmploymentStatus__c;
            this.ruralAreaStatusValues = data.RuralAreaStatus__c;
            this.referralSourceValues = data.ReferralSource__c;
        
        }
    }

    /*
    * @description   to fetch picklist values for fields on Client Case
    */
    @wire(getPicklistValues, { fieldNames: ['CaseSubType__c'], objectApiName: 'Intake__c' })
    fetchPickListValues({ error, data }) {
        if (error) {
            console.log('error ' + JSON.stringify(error));
        }
        if (data) {
            console.log('caseSubTypeValues ==>',data.CaseSubType__c);
            this.caseSubTypeValues = data.CaseSubType__c;
        }
    }

    /* @description: Handler method for Next button on Intake Screen to validate and save contact detail and move to next screen*/
    @api
    async handleNext(noDuplicateCheck) {
        //Check all the contact details
        let allValid = true;
        let isUpdate = false;
        let feilds = this.template.querySelectorAll('.contactField');
        console.log('feilds ' + JSON.stringify(feilds));
        let contactUpdate = {};
        if (this.contact && this.contact?.Id) {
            isUpdate = true;
            contactUpdate = { ...contactUpdate, 'Id': this.contact?.Id };
        }
        feilds.forEach(inputField => {
            let propertyName = inputField.name;
            if (inputField.type === 'checkbox') {
                contactUpdate[propertyName] = inputField.checked;
            } else {
                contactUpdate[propertyName] = inputField.value;
            }

            if (!inputField.checkValidity()) {
                inputField.reportValidity();
                allValid = false;
            }
        });

        this.contact = contactUpdate;

        if (!isUpdate && !noDuplicateCheck && allValid) {
            let duplicates = await getPotentialDuplicates({ con: this.contact });
            console.log('Duplicate Records : ', duplicates);
            if (duplicates && Array.isArray(duplicates) && duplicates.length > 0) {
                allValid = false;
                let resData = JSON.parse(JSON.stringify(duplicates));
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
            }
        }

        //check all the case fields
        let caseFields = this.template.querySelectorAll('.caseFields');
        let checkAgeForValidation = false;
        let caseRecord = {};
        caseFields.forEach(inputField => {
            const fieldName = inputField.name;
            const value = inputField.value;
            if (fieldName === 'recordType') {
                if (value) {
                    let selectedCaseType = this.availableRecordTypes.find(elt => elt.value == value);
                    let caseType = selectedCaseType?.label
                    checkAgeForValidation = selectedCaseType?.isReverseMortgage;
                    caseRecord['recordTypeLabel'] = caseType;

                }
            }

            if (!inputField.checkValidity()) {
                inputField.reportValidity();
                allValid = false;
            }

            if (value) {
                caseRecord[fieldName] = value;
            }
        })

        this.caseRecord = caseRecord;

        //handle reverse mortgage validation
        if (checkAgeForValidation) {
            let validation = this.handleReverseMortgageAgeValidation(contactUpdate);
            if (validation) {
                allValid = false;
                await LightningAlert.open({
                    message: this.label.REVERSE_MORTGAGE_VALIDATION,
                    theme: 'error',
                    label: 'Error!'
                })
            }
        }


        return { allValid, 'contact': contactUpdate, 'case': caseRecord }


    }

    /* @description: Handler method to set DuplicateDetected var's value */
    setDuplicateDetected(event) {
        this.duplicateDetected = event.detail.value;
    }

    /* @description: Handler method to set proceedForward var's value */
    async proceed(event) {
        this.proceedForward = true;
        this.dispatchEvent(new CustomEvent("moveforward"));
    }

    /* @description: Handler method for Previous button on Intake Screen to go back on previous screen */
    @api
    async handlePrevious() {

        let feilds = this.template.querySelectorAll('.contactField');
        let contactUpdate = {};

        console.log('this.contact : ' + JSON.stringify(this.contact));
        console.log('feilds : ' + JSON.stringify(feilds));
        feilds.forEach(inputField => {
            let propertyName = inputField.name;
            console.log('propertyName : ' + propertyName + '  || val : ' + inputField.value);
            contactUpdate[propertyName] = inputField.value;
            console.log('contactUpdate : ' + JSON.stringify(contactUpdate));
        });
        console.log('contactUpdate : ' + JSON.stringify(contactUpdate));
        this.contact = contactUpdate;
        console.log('this.contact : ' + JSON.stringify(this.contact));


        return contactUpdate;
    }
    
    @track choseNottoProvideIncome = false;
    @track totalMonthlyIncome;

    get choseNottoProvideIncomeVal() {
        return this.choseNottoProvideIncome;
    }
    get isTotalMonthlyIncomeReq() {
        return !this.choseNottoProvideIncome;
    }
    get totalMonthlyIncomeVal() {
        return this.totalMonthlyIncome;
    }
    /* @description: Handler method for input fields */
    handleInputChange(event) {
        if (event.target.name === 'ChoseNottoProvideIncome__c') {
            var con = this.contact;
            this.contact = null;
            this.contact = {...con};
            this.contact.ChoseNottoProvideIncome__c = event.detail.checked;
            this.choseNottoProvideIncome = event.detail.checked;
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
            //this.contact.County__c = '';
            //this.contact.County__c = 'ABC';
            //this.contact.County__c = data.valueOf();
            this.handleCountyChange(data);
        }

        /*if (event.target.name === 'Town__c') {
            this.contact.Town__c = event.target.value;
        }
        */
        if (event.target.name === 'Phone') {
            this.validatePhoneInput(event);
        }

        if (event.target.name === 'Email') {
            this.validateEmailInput(event);
        }

        if (event.target.name === 'SSN__c') {
            this.validateSSNOnChange(event);
        }

        if (event.target.name === 'CreditScore__c') {
            this.handleCreditScoreChange(event);
        }

        if (event.target.name === 'MailingPostalCode') {
            //this.validateZIPOnChange(event);

            if (this.validateZIPOnChange(event)) {
                //this.showSpinner = true;
                this.fetchCountyNames(event.detail.value);
            } else {
                this.resetCountyTownData();
            }

        }

        if (event.target.name === 'MaritalStatus__c') {
            this.handleMaritalStatusChange(event.detail.value);
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
            this.contact = { ...this.contact, 'Age': this.age };
            console.log('this.contact[Age] ' + this.contact['Age']);
            if (this.age < 18) {
                this.showWarning = true;
            }
            console.log('age' + varAge);

        }
        if(event.target.name === 'recordType'){
            let foundRecordType = this.recordTypes.find(item => item.value === event.target.value);
            if(foundRecordType && foundRecordType.label == 'Homeowner Counseling'){
                this.toggleSubCaseType = true;
            }else{
                this.toggleSubCaseType = false;
            }
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

    /* @description: Helper method for phone input validation*/
    validatePhoneInput(event) {
        let phoneCMP = this.template.querySelector(".phoneField");//^\d{10}$
        let phnDigitsOnly = event.detail.value ? (event.detail.value).replaceAll("(", "").replaceAll(")", "").replaceAll(" ", "").replaceAll("-", "").replaceAll(".", "") : "";

        if (phoneCMP.value.match(/^\(?\d{3}\)?[\s.-]?\d{3}[\s.-]?\d{4}$/) && phnDigitsOnly.length === 10) {
            phoneCMP.setCustomValidity("");
            phoneCMP.value = this.formatPhoneNumber(phnDigitsOnly);

        } else if (phnDigitsOnly.length === 0) {
            console.log('On empty phone number ;;;')
            phoneCMP.setCustomValidity("");
            phoneCMP.value = '';
        } else {
            phoneCMP.setCustomValidity('Must be 10 digit');
            phoneCMP.value = phnDigitsOnly;
        }

        phoneCMP.reportValidity();
    }

    /**
     * 
     * @description : Validate credit score change.
     */
    handleCreditScoreChange(event) {
        if (event.detail.value?.length !== 3) {
            event.target.setCustomValidity("Must be 3 digits");
        } else {
            event.target.setCustomValidity("");
        }
        event.target.reportValidity();
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
        if (ssnDigitsOnly === "" || (event.target.value.match(/^\(?\d{3}\)?[\s.-]?\d{2}[\s.-]?\d{4}$/) && ssnDigitsOnly.length === 9)) {
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
            return false;
        } else {
            event.target.setCustomValidity("");
            return true;
        }
    }

    async fetchCountyNames(zip) {
        try {
            console.log('zip : ' + zip);
            this.countyTownData = await getCountyNamesBasedOnZip({ zipCode: zip });
            let countyTownData = JSON.parse(JSON.stringify(this.countyTownData));
            console.log(countyTownData);
            if (Object.keys(countyTownData).length === 0) {
                this.resetCountyTownData();
                return false;
            }
            this.countyNames = Object.keys(countyTownData).map(elt => {

                return {
                    label: elt,
                    value: elt
                }
            })

            return true;
        } catch (error) {
            this.resetCountyTownData();
            console.error(error);
            return false;
        }
    }

    resetCountyTownData() {
        this.countyTownData = null;
        this.countyNames = null;
        this.townNames = null;
    }

    handleCountyChange(value) {
        let countyData = JSON.parse(JSON.stringify(this.countyTownData));
        this.townNames = countyData[value].map(elt => { return { label: elt, value: elt } });
        if (this.townNames.length === 1) {
            this.contact = { ...JSON.parse(JSON.stringify(this.contact)), 'Town__c': this.townNames[0]?.value }
        }
    }

    get showCountyFields() {
        return this.countyTownData != null
    }

    /*setCountyAndTownPicklistValues(fromPrevious){
        console.log('this.countyTownData : '+JSON.stringify(this.countyTownData));console.log('this.contact.County__c : '+this.contact.County__c);
        let countyList = [];console.log('this.contact.Town__c : '+this.contact.Town__c);
        for (var key in this.countyTownData) {
            const val = { label: key , value: key };
            countyList.push(val);
        }
        this.countyNames = countyList;
        console.log('this.countyNames : '+JSON.stringify(this.countyNames));
        console.log('this.countyReadOnly : '+this.countyReadOnly);
        console.log('this.countyRequired : '+this.countyRequired);
        if(fromPrevious && this.contact.County__c){
            this.countyReadOnly = countyList.length > 1 ? false : true;
            this.countyRequired = countyList.length > 1 ? true : false;;
        } else {
            if(countyList.length > 1){
                this.contact.County__c = '';
                this.countyReadOnly = false;
                this.countyRequired = true;
            } else {
                this.contact.County__c = countyList.length == 0 ? '' : countyList[0].value;
                this.countyReadOnly = true;
                this.countyRequired = false;
            }
        }
        let townList = [];
        for (var key in this.countyTownData) {
            if(key == this.contact.County__c){
                for (var townkey in this.countyTownData[key]) {
                    let dataList = this.countyTownData[key];
                    const val = { label: dataList[townkey] , value: dataList[townkey]};
                    townList.push(val);
                }
            }  
        }
        this.townNames = townList;
        //this.contact.Town__c = townList.length == 0 ? '' : townList[0].value;
        if(fromPrevious && this.contact.Town__c){
            this.townReadOnly = townList.length > 1 ? false : true;
            this.townRequired = townList.length > 1 ? true : false;;
        } else {
            if(townList.length > 1){
                this.contact.Town__c = '';
                this.townReadOnly = false;
                this.townRequired = true;
            } else {
                this.contact.Town__c = townList.length == 0 ? '' : townList[0].value;
                this.townReadOnly = true;
                this.townRequired = false;
            }
        }
        this.showSpinner = false;

        console.log(JSON.stringify(this.countyNames));
    }

    countyChanged(){
        let townList = [];
        for (var key in this.countyTownData) {
            if(key == this.contact.County__c){
                for (var townkey in this.countyTownData[key]) {
                    let dataList = this.countyTownData[key];
                    const val = { label: dataList[townkey] , value: dataList[townkey]};
                    townList.push(val);
                }
            }  
        }
        this.townNames = townList;
        if(townList.length > 1){
            this.contact.Town__c = '';
            this.townReadOnly = false;
            this.townRequired = true;
        } else {
            this.contact.Town__c = townList.length == 0 ? '' : townList[0].value;
            this.townReadOnly = true;
            this.townRequired = false;
        }
    }
    */

    /* @description : changing Marital Status based on household type*/
    handleMaritalStatusChange(val, retainValue) {
        if (!retainValue) {
            this.contact = { ...this.contact, 'HouseholdType__c': null }
        }
        if (val) {
            let householdValues = this.houseHoldMaritalMap[val];
            this.householdTypeValues = householdValues;
        }


    }

    /**
     * 
     * @description format phone number to given format
     * 
     */
    formatPhoneNumber(s) {
        return '(' + s.substr(0, 3) + ') ' + s.substr(3, 3) + '-' + s.substr(6);
    }

    /**
     * 
     * @description format SSN number to given format
     * 
     */
    formatSSNNumber(s) {
        return s.length > 0 ? s.substr(0, 3) + '-' + s.substr(3, 2) + '-' + s.substr(5) : '';
    }

    
    /**
     * 
     * @description to throw validation for reverse mortgage age
     */
    handleReverseMortgageAgeValidation(contact) {
        return contact.hasOwnProperty("Age") && (contact.Age < 62)

    }

    /**
     * @description boolean getter for show town names
     */

    get showTownNames() {
        return this.townNames && Array.isArray(this.townNames) && this.townNames.length > 0;
    }

}