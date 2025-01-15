/**
  JS for Co Applicant Screen
 **/
import { LightningElement, track, api, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import getPicklistValues from '@salesforce/apex/IntakeFormController.getPicklistValues';
export default class intakeCoApplicant extends NavigationMixin(
    LightningElement
) {
    @track relationshipValues;
    @track raceValues;
    @track ethnicityValues;
    @track genderValues;
    @track householdValues;
    @track languageValues;
    @track bestTimeToContactValues;
    @track mailingStateValues;
    @track employeeStatusValues;

    @api primaryApplicant;
    @api deleteApplicants;
    @track _contacts;
    @track showCoApplicant = true;

    @track allValid = true;
    @track isValid = true;
    @track isfocused = false;

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

    connectedCallback() {
        if (!this.deleteApplicants) {
            this.deleteApplicants = [];
        }
    }

    /**
     * To Add Co Applicant and Initialize data
     */
    initData() {
        this.showCoApplicant = false;
        let _contacts = [];
        this.createRow(_contacts);
        this._contacts = _contacts;

    }

    @api get contacts() {
        return this._contacts;
    }
    set contacts(value) {
        if (value) {
            this._contacts = JSON.parse(JSON.stringify(value));
        }
    }

    /**
     * Adds a new row with blank fields
     */
    createRow(_contacts) {
        let contactObject = {};
        if (_contacts.length > 0) {
            contactObject.index = _contacts[_contacts.length - 1].index + 1;
        } else {
            contactObject.index = 1;
        }
        contactObject.FirstName = null;
        contactObject.LastName = null;
        contactObject.MiddleName = null;
        contactObject.Suffix = null;
        contactObject.Email = null;
        contactObject.Phone = null;
        contactObject.BirthDate = null;
        contactObject.Age = null;
        contactObject.Besttimetocontact__c = null;
        contactObject.showWarning = false;
        contactObject.RelationshipToPrimaryApplicant__c = null;
        contactObject.PreferredLanguage__c = null;
        contactObject.SSN__c = null;
        contactObject.Race__c = null;
        contactObject.Ethnicity__c = null;
        contactObject.Gender__c = null;
        contactObject.HouseholdType__c = null;
        contactObject.MonthlyIncome__c = null;
        contactObject.MailingStreet = this.primaryApplicant.MailingStreet;
        contactObject.MailingCity = this.primaryApplicant.MailingCity;
        contactObject.MailingStateCode = this.primaryApplicant.MailingStateCode;
        contactObject.MailingPostalCode = this.primaryApplicant.MailingPostalCode;
        contactObject.MailingCountry = this.primaryApplicant.MailingCountry;
        contactObject.MailingAddressLine2__c = this.primaryApplicant.MailingAddressLine2__c;
        contactObject.togglechecked = true;
        contactObject.openModal = false;
        _contacts.push(contactObject);
    }

    /**
     * Adds a new row
     */
    addNewRow() {
        this.createRow(this._contacts);
    }

    /**
     * Removes the selected row
     */
    removeRow(event) {

        if (this._contacts.length == 1) {
            this.showCoApplicant = true;
        }

        let toBeDeletedRowIndex = event.target.name;
        let _contacts = [];
        for (let i = 0; i < this._contacts.length; i++) {
            let tempRecord = Object.assign({}, this._contacts[i]); //cloning object
            if (tempRecord.index !== toBeDeletedRowIndex) {
                _contacts.push(tempRecord);
            } else {
                if (tempRecord?.Id) {
                    this.deleteApplicants.push(tempRecord?.Id);
                }
            }
        }
        for (let i = 0; i < _contacts.length; i++) {
            _contacts[i].index = i + 1;
        }
        this._contacts = _contacts;
        console.log('contacts ' + this._contacts);
    }

    /**
     * Handles when a change in lightning input
     */
    handleInputChange(event) {
        this.isValid = true;
        let index = event.target.dataset.id;
        let fieldName = event.target.name;
        
        let age;
        let showWarning = false;
        if (
            fieldName == 'FirstName' ||
            fieldName == 'LastName'
        ) {
            this.validateNameOnChange(event);
        }

        if (fieldName == 'Phone') {
            this.validatePhoneOnChange(event);
        }

        if (fieldName == 'Email') {
            this.validateEmailOnChange(event);
        }

        if (fieldName == 'CreditScore__c') {
            this.handleCreditScoreChange(event);
        }

        if (fieldName == 'SSN__c') {
            this.validateSSNOnChange(event);
        }

        let value = event.target.value;

        if (fieldName == 'BirthDate') {

            console.log(value);
            let d1 = new Date(value);
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

            age = varAge;
            if (age < 18) {
                showWarning = true;
            }
            console.log('age' + varAge);
            this.validateBirthDateOnChange(event);

        }

        if (fieldName == 'MonthlyIncome__c') {
            this.validateMonthlyIncomeOnChange(event);
        }

        if (fieldName === 'MailingPostalCode') {
            this.validateZIPOnChange(event);
        }

        for (let i = 0; i < this._contacts.length; i++) {
            if (this._contacts[i].index === parseInt(index)) {
                this._contacts[i][fieldName] = value;
                if (fieldName === 'Besttimetocontact__c') {
                    console.log('best ' + this._contacts[i][fieldName]);
                }
                if (fieldName == 'BirthDate') {

                    this._contacts[i]['Age'] = age;
                    this._contacts[i]['showWarning'] = showWarning;
                }
            }
        }
    }

    /**
     * Toggle for Same as Primary Contact
     */
    handleSameAsPrimary(event) {
        let toUpdatePrimaryApplicantIndex = event.target.name;
        for (let i = 0; i < this._contacts.length; i++) {
            if (this._contacts[i].index == toUpdatePrimaryApplicantIndex) {
                if (event.currentTarget.checked) {
                    if (
                        (this._contacts[i].MailingStreet === null || this._contacts[i].MailingStreet === '') &&
                        (this._contacts[i].MailingCity === null || this._contacts[i].MailingCity === '') &&
                        (this._contacts[i].MailingStateCode === null || this._contacts[i].MailingStateCode === '') &&
                        (this._contacts[i].MailingPostalCode === null || this._contacts[i].MailingPostalCode === '') &&
                        (this._contacts[i].MailingAddressLine2__c === null || this._contacts[i].MailingAddressLine2__c === '')
                    ) {
                        this.handleOverWrite(event);

                    } else {
                        this._contacts[i].togglechecked = true;
                        this._contacts[i].openModal = true;
                    }
                } else {
                    this._contacts[i].MailingStreet = '';
                    this._contacts[i].MailingCity = '';
                    this._contacts[i].MailingStateCode = '';
                    this._contacts[i].MailingPostalCode = '';
                    this._contacts[i].MailingAddressLine2__c = '';
                    this._contacts[i].openModal = false;
                    this._contacts[i].togglechecked = false;
                }
            }
        }
    }

    /**
     * Confirmation whether to override address
     */
    handleOverWrite(event) {
        let toUpdatePrimaryApplicantIndex = event.target.name;

        for (let i = 0; i < this._contacts.length; i++) {
            if (this._contacts[i].index == toUpdatePrimaryApplicantIndex) {
                this._contacts[i].MailingStreet =
                    this.primaryApplicant.MailingStreet;
                this._contacts[i].MailingCity =
                    this.primaryApplicant.MailingCity;
                this._contacts[i].MailingStateCode =
                    this.primaryApplicant.MailingStateCode;
                this._contacts[i].MailingPostalCode =
                    this.primaryApplicant.MailingPostalCode;
                this._contacts[i].MailingAddressLine2__c =
                    this.primaryApplicant.MailingAddressLine2__c;
                this._contacts[i].togglechecked = true;
                this._contacts[i].openModal = false;
            }
        }
    }
    /**
     * Confirmation not to override address
     */
    handleOverWriteCancel(event) {
        let toUpdatePrimaryApplicantIndex = event.target.name;
        console.log('event ' + JSON.stringify(event.target));

        for (let i = 0; i < this._contacts.length; i++) {
            if (this._contacts[i].index === toUpdatePrimaryApplicantIndex) {

                this._contacts[i].openModal = false;
                this._contacts[i].togglechecked = false;
            }
        }
    }

    /*
     * @description  get the picklist values for fields on contact
     */
    @wire(getPicklistValues, {
        fieldNames: [
            'RelationshipToPrimaryApplicant__c',
            'PreferredLanguage__c',
            'Race__c',
            'Ethnicity__c',
            'Gender__c',
            'HouseholdType__c',
            'Besttimetocontact__c',
            'MailingStateCode',
            'EmploymentStatus__c'
        ],
        objectApiName: 'Contact'
    })

    /**
     * To fetch all picklist values
     */
    fetchPickListValues({ error, data }) {
        if (error) {
        }
        if (data) {
            this.raceValues = data.Race__c;
            this.ethnicityValues = data.Ethnicity__c;
            this.genderValues = data.Gender__c;
            this.relationshipValues = data.RelationshipToPrimaryApplicant__c;
            this.householdValues = data.HouseholdType__c;
            this.languageValues = data.PreferredLanguage__c;
            this.bestTimeToContactValues = data.Besttimetocontact__c;
            this.mailingStateValues = data.MailingStateCode;
            this.employeeStatusValues = data.EmploymentStatus__c;
        }
    }

    /*
     * @description  Validate FirstName and LastName on click of next
     */
    validateName(inputField) {
        if (inputField.value.match(/^[\p{L}\p{M}' !@#$%\d-]+$/u)) { ///^[A-Za-z-' !@#$%0-9ñàù]+$/
            inputField.setCustomValidity("");
            this.allValid = true;
        } else {
            inputField.setCustomValidity('Must only Contain Letter Characters');
            this.isValid = false;
            this.allValid = false;
        }
        inputField.reportValidity();
    }

    /*
     * @description  Validate FirstName and LastName on value change
     */
    validateNameOnChange(event) {

        if (event.target.value.match(/^[\p{L}\p{M}' !@#$%\d-]+$/u)) { ///^[A-Za-z-' !@#$%0-9ñàù]+$/
            event.target.setCustomValidity("");
        } else {
            event.target.setCustomValidity('Must only Contain Letter Characters');
        }
        event.target.reportValidity();
    }

    /*
     * @description  Validate Phone on value change
     */
    validatePhoneOnChange(event) {

        let phnDigitsOnly = event.target.value ? (event.target.value).replaceAll("(", "").replaceAll(")", "").replaceAll(" ", "").replaceAll("-", "").replaceAll(".", "") : "";
        if (event.target.value === '' || event.target.value === null || (event.target.value.match(/^\(?\d{3}\)?[\s.-]?\d{3}[\s.-]?\d{4}$/) && phnDigitsOnly.length === 10)) {
            event.target.setCustomValidity("");
            event.target.value = this.formatPhoneNumber(phnDigitsOnly)
        } else {
            event.target.setCustomValidity('Must be 10 digit');
            event.target.value= phnDigitsOnly;
        }
        event.target.reportValidity();
    }

    /*
     * @description  Validate Email on value change
     */
    validateEmailOnChange(event) {
        if (!event.target.value || !event.target.value.includes('@')) {
            event.target.setCustomValidity('You have entered an invalid format.');
        } else if (event.target.value.match(/^[a-zA-Z0-9._-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$/)) {
            event.target.setCustomValidity("");
        } else {
            event.target.setCustomValidity('You have entered an invalid format');
        }
        event.target.reportValidity();
    }

    /*
     * @description  Validate SSN on value change
     */
    validateSSNOnChange(event) {
        let ssnDigitsOnly = event.target.value ? (event.target.value).replaceAll("-", "") : "";
        if (event.target.value === '' || event.target.value === null || (event.target.value.match(/^\(?\d{3}\)?[\s.-]?\d{2}[\s.-]?\d{4}$/) && ssnDigitsOnly.length === 9)) {
            event.target.setCustomValidity("");
            event.target.value = this.formatSSNNumber(ssnDigitsOnly);
        } else {
            event.target.setCustomValidity('Must be 9 digit');
            
            event.target.value=ssnDigitsOnly;
        }
        event.target.reportValidity();
    }

    /**
     * 
     * @description : Validate credit score change.
     */
    handleCreditScoreChange(event) {
        if(event.detail.value?.length!==3) {
            event.target.setCustomValidity("Must be 3 digits");
        } else {
            event.target.setCustomValidity("");
        }
        event.target.reportValidity();
    }

    /*
     * @description  Validate BirthDate on value change
     */
    validateBirthDateOnChange(event) {

        var today = new Date();

        var dd = String(today.getDate()).padStart(2, '0');
        var mm = String(today.getMonth() + 1).padStart(2, '0'); //January is 0!
        var yyyy = today.getFullYear();

        today = yyyy + '-' + mm + '-' + dd;

        if (event.target.value >= today) {
            event.target.setCustomValidity("Date cannot be today or future");
        } else {
            event.target.setCustomValidity('');

        }
        event.target.reportValidity();
    }

    /*
     * @description  Validate Monthly Income on value change
     */
    validateMonthlyIncomeOnChange(event) {
        if (event.target.value.match(/^\d+$/)) {
            event.target.setCustomValidity("");
        } else {
            event.target.setCustomValidity('Cannot contain letters or special characters');
        }
        event.target.reportValidity();
    }

    /**
     * 
     * @description format SSN number to given format
     * 
     */
    formatSSNNumber(s) {
        return (s && s.length>0) ? s.substr(0,3)+'-' + s.substr(3,2) + '-' + s.substr(5): '';
    }

    /**
     * 
     * @description format phone number to given format
     * 
     */
    formatPhoneNumber(s) {
        return (s && s.length>0) ? '('+s.substr(0,3)+') '+s.substr(3,3)+'-'+s.substr(6):'';
    }

    validateZIPOnChange(event) {
        if (!event.target.value.match(/^[0-9]+$/) || event.target.value.length < 5) {
            event.target.setCustomValidity("Enter only 5 digit numbers");
        } else {
            event.target.setCustomValidity("");
        }
    }

    /**
     * To be called from parent to send values to Review Screen
     */
    @api
    handleNext() {
        this.isValid = true;
        this.isfocused = false;
        let fields = this.template.querySelectorAll('.contactField');
        fields.forEach((inputField) => {
            console.log('inputField ' + JSON.stringify(inputField));
            console.log('inputField.checkValidity() ' + inputField.checkValidity());

            if (
                inputField.name == 'FirstName' ||
                inputField.name == 'LastName'
            ) {
                this.validateName(inputField);
            }

            if (!inputField.checkValidity() || !this.isValid) {
                inputField.reportValidity();
                this.allValid = false;
            }
            if (!inputField.checkValidity() && !this.isfocused) {
                inputField.focus();
                this.isfocused = true;
            }
        });
        console.log('allValid ' + this.allValid);
        console.log('contacts ' + JSON.stringify(this._contacts));
        let responsePayload = { allValid: this.allValid, contacts: this._contacts };
        if(this.deleteApplicants && Array.isArray(this.deleteApplicants) && this.deleteApplicants.length>0) {
            responsePayload = {...responsePayload, 'deleteApplicants' : this.deleteApplicants };
        }
        return responsePayload;
    }

    /**
     * To be called from parent when clicked on Previous
     */
    @api
    handlePrevious() {
        return this._contacts;
    }
}