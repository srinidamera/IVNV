import { LightningElement, api,track } from 'lwc';
import storeIntakeForm from '@salesforce/apex/IntakeFormController.storeIntakeForm';
import getIntakeDetails from '@salesforce/apex/IntakeFormController.getIntakeDetails';
import getDependencyMatrix from '@salesforce/apex/DependencyMatrixGenerator.getDependencyMatrix';

export default class IntakeForm extends LightningElement {

    @api
    ismodalopen;

    currentStepIndex = 0;

    @api
    editExisting;

    formData = {};
    @track zipcodeData;

    @track
    dependencyMatrix;

    editEnabled = false;
    showSpinner = false;

    stages = [
        {
            currentStepName: 'Contact',
            isCompleted: false,
            isCurrent: true,
            isDue: false,
        },
        {
            currentStepName: 'Co-Applicants',
            isCompleted: false,
            isCurrent: false,
            isDue: true,
        },
        // {
        //     currentStepName: 'Household Info',
        //     isCompleted: false,
        //     isCurrent: false,
        //     isDue: true,
        // },
        {
            currentStepName: 'Review',
            isCompleted: false,
            isCurrent: false,
            isDue: true,
        },

    ]

    get options() {
        return [
            { label: 'New', value: 'new' },
            { label: 'In Progress', value: 'inProgress' },
            { label: 'Finished', value: 'finished' },
        ];
    }

    /**
     * @description : connected call back for component
     */
    async connectedCallback() {
        console.log('Modal State : ', this.ismodalopen);
        if (this.editExisting) {
            console.log('Contact Id : ', this.editExisting);

            try{
                let intakeData = await getIntakeDetails({ contactId: this.editExisting });
            
                let transformedData = intakeData;
                console.log('Data Received : ', intakeData);
                this.editEnabled = true;
                if (intakeData.hasOwnProperty('clientCase')) {
                    let { clientCase, ...newData } = intakeData;
                    let clienCaseObj = clientCase.clientCase;
                    clienCaseObj = { ...clienCaseObj, 'caseType': clientCase.recordTypes }
                    newData['case'] = clienCaseObj;
                    transformedData = newData;
                }
                let { contact, contacts, zipcodeData } = transformedData;
                zipcodeData = {...zipcodeData, 'MailingPostalCode' : contact.MailingPostalCode, 'county':contact.County__c};
                let dependencyMatrix = await getDependencyMatrix({
                    dependentField: 'HouseholdType__c',
                    controllingField: 'MaritalStatus__c',
                    objectName: 'Contact'
                })

                console.log('Dependency Matrix : ', dependencyMatrix);
                //this.dependencyMatrix = dependencyMatrix;

                //for householdType 
                this.dependencyMatrix = {'householdTypeValues':dependencyMatrix[contact.MaritalStatus__c]}

                contact = {...contact, 'Age' : this.calculateAge(contact.Birthdate)};
                if(contact.Phone) {
                    contact.Phone = this.formatPhoneNumber(contact.Phone);
                }

                if(contact.SSN__c) {
                    contact.SSN__c = this.formatSSNNumber(contact.SSN__c);
                }
                transformedData = {...transformedData,contact}

                contacts = contacts.map((elt, index) => {
                    let {Birthdate,RecordTypeId,RecordType,Phone,SSN__c, ...transformed} = elt;
                    if(Phone) {
                        Phone = this.formatPhoneNumber(Phone);

                    }
                    if(SSN__c) {
                        SSN__c = this.formatSSNNumber(SSN__c);
                    }
                    
                    return { ...transformed, 'Age': this.calculateAge(Birthdate), 'index': index+1, 'BirthDate' : Birthdate, Phone,SSN__c }
                })

                transformedData = {...transformedData, contacts}

                



                this.formData = JSON.parse(JSON.stringify(transformedData));
                this.zipcodeData = zipcodeData;
                console.log('Transformed Data : ', JSON.parse(JSON.stringify(this.formData)));
            } catch(e) {
                console.log('Error Occurred : ', e);
            }
            
            
                
            
        }


    }

    /**
     * @description : connected call back for component
     */
    calculateAge(birthDateStr) {
        if (birthDateStr) {
            let birthDate = new Date(birthDateStr);
            let now = new Date();
            var diff = (now.getTime() - birthDate.getTime()) / 1000;
            // Convert the difference from milliseconds to days
            diff /= (60 * 60 * 24);
            // Calculate the approximate number of years by dividing the difference in days by the average number of days in a year (365.25)
            return Math.floor(Math.round(diff / 365.25));
        }


    }

    /**
     * @description : resetting values on closing or submiting intake form
     */
    resetValues() {
        this.currentStepIndex = 0;
        this.transformSteps();
        this.formData = {};
    }

    // handleNewIntake(event) {
    //     this.isModalOpen = true;

    // }

    /**
     * @description : closing intake form
     */
    closeModal() {
        //this.isModalOpen = false;
        this.resetValues();
        this.dispatchEvent(new CustomEvent("close"))
    }

    /**
     * @description : handles submit of intake form
     */
    submitDetails() {
        this.dispatchEvent(new CustomEvent("close"));
    }

    /**
     * @description : handles previouss of intake form
     */
    handlePrevious() {

        if (this.stages[this.currentStepIndex].currentStepName === 'Contact') {
            let response = this.template.querySelector('c-intake-contact-form').handlePrevious();
            if (response) {
                this.formData = { ...this.formData, 'contact': response?.contact, 'case' : response?.case }
            }
        } else if (this.stages[this.currentStepIndex].currentStepName === 'Co-Applicants') {
            let response = this.template.querySelector('c-intake-co-applicant')?.handlePrevious();
            if (response) {
                this.formData = { ...this.formData, 'contacts': response }
            }
        }


        this.currentStepIndex = this.currentStepIndex - 1;
        this.transformSteps();
    }

    /**
     * @description : handles proceeding of next stage
     */
    proceedToNextStage(event) {
        this.currentStepIndex = this.currentStepIndex + 1;
        this.transformSteps();
        this.formData = { ...this.formData, 'contact': event.detail.contact }
    }

    /**
     * @description : handles moving to next of intake form
     */
    async handleNext() {

        console.log('step ' + this.stages[this.currentStepIndex].currentStepName);

        if (this.stages[this.currentStepIndex].currentStepName === 'Contact') {
            let response = await this.template.querySelector('c-intake-contact-form').handleNext(false);
            //console.log('Response : ', JSON.parse(JSON.stringify(response)));
            if (response?.allValid) {
                this.currentStepIndex = this.currentStepIndex + 1;
                this.transformSteps();
                this.formData = { ...this.formData, 'contact': response?.contact, 'case' : response?.case }
            }
        }
        else if (this.stages[this.currentStepIndex].currentStepName === 'Co-Applicants') {
            let response = this.template.querySelector('c-intake-co-applicant').handleNext();
            console.log('contacts Response : ', JSON.parse(JSON.stringify(response)));
            if (response?.allValid) {
                this.currentStepIndex = this.currentStepIndex + 1;
                this.transformSteps();
                this.formData = { ...this.formData, 'contacts': response.contacts, 'idsToDelete' : response?.deleteApplicants }
            }

        }
        else {
            this.currentStepIndex = this.currentStepIndex + 1;
            this.transformSteps();
        }


    }

    /**
     * @description : To proceed without duplicate check
     */
    async proceedWithoutDuplicateCheck() {
        if (this.stages[this.currentStepIndex].currentStepName === 'Contact') {
            let response = await this.template.querySelector('c-intake-contact-form').handleNext(true);
            //console.log('Response : ', JSON.parse(JSON.stringify(response)));
            if (response?.allValid) {
                this.currentStepIndex = this.currentStepIndex + 1;
                this.transformSteps();
                this.formData = { ...this.formData, 'contact': response?.contact, 'case' : response?.case }
            }
        }
    }

    /**
     * @description : to transform the steps after step index is changed
     */
    transformSteps() {
        let currIndex = this.currentStepIndex;
        let newStages = [];
        for (let i = 0; i < this.stages.length; i++) {
            if (i === currIndex) {
                newStages.push({ ...this.stages[i], isCurrent: true, isCompleted: false, isDue: false })
            }

            else if (i > currIndex) {
                newStages.push({ ...this.stages[i], isCurrent: false, isCompleted: false, isDue: true })
            }
            else {
                newStages.push({ ...this.stages[i], isCurrent: false, isCompleted: true, isDue: false })
            }
        }

        this.stages = newStages;
    }

    get showContactPage() {
        return this.stages[this.currentStepIndex]?.currentStepName === 'Contact';
    }

    get showCasePage() {
        return this.stages[this.currentStepIndex]?.currentStepName === 'Household Info';
    }

    get showCoApplicantsPage() {
        return this.stages[this.currentStepIndex]?.currentStepName === 'Co-Applicants';
    }

    get showReviewPage() {
        return this.stages[this.currentStepIndex]?.currentStepName === 'Review';
    }

    get showPreviousButton() {
        return !(this.currentStepIndex === 0);
    }

    get showSubmitButton() {
        return (this.currentStepIndex === 2);
    }

    /**
     * @description : handles submit of intake form
     */
    handleSubmit() {
        this.showSpinner = true;
        console.log('Form Data On Submit : ', JSON.stringify(this.formData));

        let intakeFormRequest = {};
        if (this.formData.hasOwnProperty('contact')) {
            let contact = this.formData.contact;
            if (contact.hasOwnProperty('BirthDate')) {
                let Birthdate = contact.BirthDate;
                delete contact.BirthDate
                contact = { ...contact, Birthdate };
            }
            if(contact.Phone) {
                contact.Phone = contact.Phone.replaceAll("(", "").replaceAll(")", "").replaceAll(" ", "").replaceAll("-", "").replaceAll(".", "");
            }
            if(contact.SSN__c) {
                contact.SSN__c = contact.SSN__c.replaceAll("-", "");
            }
            
            contact.CountyMSA__c = this.formData.case.CountyMSA__c;
            
            intakeFormRequest['contact'] = contact;
        }
        if (this.formData.hasOwnProperty('case')) {
            let { recordType, ...caseIns } = this.formData.case;

            let caseWrap = {};
            caseWrap['clientCase'] = caseIns;
            caseWrap['recordType'] = recordType;

            intakeFormRequest['clientCase'] = caseWrap;
            if(intakeFormRequest.hasOwnProperty('contact')) {
                intakeFormRequest['clientCase']['clientCase'] = {...caseIns, 
                    'ChoseNottoProvideIncome__c': intakeFormRequest?.contact?.ChoseNottoProvideIncome__c,
                    'HouseholdType__c': intakeFormRequest?.contact?.HouseholdType__c,
                    'HouseholdSize__c': intakeFormRequest?.contact?.HouseholdSize__c,
                    'CurrentResidence__c': intakeFormRequest?.contact?.CurrentResidence__c,
                    'Occupation__c': intakeFormRequest?.contact?.Occupation__c,
                    'MonthlyCreditorsDebt__c': intakeFormRequest?.contact?.MonthlyCreditorsDebt__c,
                    'Employment_Status__c': intakeFormRequest?.contact?.EmploymentStatus__c,
                    'HouseholdMonthlyIncome__c': intakeFormRequest?.contact?.TotalMonthlyIncome__c,
                    'MonthlyIncome__c': intakeFormRequest?.contact?.MonthlyIncome__c,
                    'OccupationStartDate__c': intakeFormRequest?.contact?.OccupationStartDate__c,
                    'CreditScore__c': intakeFormRequest?.contact?.CreditScore__c,
                    'Race__c': intakeFormRequest?.contact?.Race__c,
                    'Ethnicity__c': intakeFormRequest?.contact?.Ethnicity__c,
                    'Gender__c': intakeFormRequest?.contact?.Gender__c,
                    'HouseholdType__c': intakeFormRequest?.contact?.HouseholdType__c,
                    'MaritalStatus__c': intakeFormRequest?.contact?.MaritalStatus__c,
                    'HouseholdSize__c': intakeFormRequest?.contact?.HouseholdSize__c,
                    'RuralAreaStatus__c': intakeFormRequest?.contact?.RuralAreaStatus__c,
                    'Education__c': intakeFormRequest?.contact?.Education__c,
                    'EnglishProficiency__c': intakeFormRequest?.contact?.EnglishProficiency__c,
                    'Veteran__c': intakeFormRequest?.contact?.Veteran__c,
                    'ActiveMilitary__c': intakeFormRequest?.contact?.ActiveMilitary__c,
                    'X1stTimeHomeBuyer__c': intakeFormRequest?.contact?.X1stTimeHomeBuyer__c,
                    'ColoniasResidence__c': intakeFormRequest?.contact?.ColoniasResidence__c,
                    'NumberofDependents__c': intakeFormRequest?.contact?.NumberOfDependents__c,
                    'FarmWorker__c': intakeFormRequest?.contact?.FarmWorker__c,
                    'DisabledStatus__c': intakeFormRequest?.contact?.DisabledStatus__c,
                    //Address fields :
                    'Address__Street__s' :intakeFormRequest?.contact?.MailingStreet,
                    'Address__City__s':intakeFormRequest?.contact?.MailingCity,
                    'Address__StateCode__s':intakeFormRequest?.contact?.MailingStateCode,
                    'Address__PostalCode__s':intakeFormRequest?.contact?.MailingPostalCode,
                    'AddressLine2__c' : intakeFormRequest?.contact?.MailingAddressLine2__c,
                    'Town__c':intakeFormRequest?.contact?.Town__c,
                    'County__c':intakeFormRequest?.contact?.County__c,
                    'ClientHUDAssistance__c' : intakeFormRequest?.contact?.ClientHUDAssistance__c

                    
                }
            }

            intakeFormRequest['contact'] = {...intakeFormRequest['contact'], 'ReferralSource__c':caseIns?.ReferralSource__c};

            console.log('CLient Case : ', intakeFormRequest['clientCase']);
            
        }
        if (this.formData.hasOwnProperty('contacts') && Array.isArray(this.formData.contacts) && this.formData.contacts.length > 0) {
            let contactList = [];
            let contactsEntered = JSON.parse(JSON.stringify(this.formData.contacts));
            for (let i = 0; i < contactsEntered.length; i++) {
                let { index, checked, openModal, BirthDate,Phone, SSN__c, ...trimmedContact } = contactsEntered[i];
                trimmedContact['Birthdate'] = BirthDate;
                trimmedContact['Phone'] = Phone?.replaceAll("(", "").replaceAll(")", "").replaceAll(" ", "").replaceAll("-", "").replaceAll(".", "");
                trimmedContact['SSN__c'] = SSN__c?.replaceAll("-", "");

                contactList.push(trimmedContact);
            }
            intakeFormRequest['contacts'] = contactList;
        }
        if (this.formData.hasOwnProperty('idsToDelete') && Array.isArray(this.formData.idsToDelete) && this.formData.idsToDelete.length > 0) {
            intakeFormRequest['idsToDelete'] = this.formData.idsToDelete;
        }

        console.log('Submit Wrapper : ', JSON.parse(JSON.stringify(intakeFormRequest)));

        storeIntakeForm({ 'requestWrapper': intakeFormRequest }).then(data => {
            console.log('Data Recieved : ', data);
            console.log('Data Recieved In String : ' + JSON.stringify(data));
            console.log('Received');
            this.resetValues();
            this.dispatchEvent(new CustomEvent("submit", { detail: JSON.parse(JSON.stringify(data)) }));
        }).catch(e => {
            console.log('Error Occurred : ', e)
            let errorPayLoad = {
                'errorMessage': e.body?.message
            }
            console.log('Error Payload : ', errorPayLoad);
            this.dispatchEvent(new CustomEvent("error", { detail:  errorPayLoad}));

        }).finally(() => {
            this.showSpinner = false;
        });
    }

    get showNextButton() {
        /*alert('inside showNextButton');
        alert('this.currentStepIndex : '+this.currentStepIndex);
        alert('this.stages.length : '+this.stages.length);
        alert('result : '+(!(this.currentStepIndex === this.stages.length - 1)));*/
        return !(this.currentStepIndex === this.stages.length - 1);
    }

    /**
     * @description : Returns boolean to display wether to show cancel button
     *                on footer or not
     */
    get showCancelButton() {
        return this.currentStepIndex === 0;
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
        return s.substr(0,3)+'-' + s.substr(3,2) + '-' + s.substr(5);
    }
}