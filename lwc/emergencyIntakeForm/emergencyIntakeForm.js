import { LightningElement, api, track } from 'lwc';
import storeLeadIntake from '@salesforce/apex/EmergencyTriageController.storeLeadIntake';
import getIntakeDetails from '@salesforce/apex/EmergencyTriageController.getIntakeDetails';

export default class EmergencyIntakeForm extends LightningElement {

    @api
    ismodalopen;

    @api
    editExisting;

    existingMode = false;

    currentStepIndex = 0;

    formData = {};
    showSpinner = false;


    stages = [
        {
            currentStepName: 'Contact',
            isCompleted: false,
            isCurrent: true,
            isDue: false,
        },
        {
            currentStepName: 'Review',
            isCompleted: false,
            isCurrent: false,
            isDue: true,
        }

    ]

    get options() {
        return [
            { label: 'New', value: 'new' },
            { label: 'In Progress', value: 'inProgress' },
            { label: 'Finished', value: 'finished' },
        ];
    }

    connectedCallback() {
        console.log('Modal State : ', this.ismodalopen);
        if (this.editExisting) {
            getIntakeDetails({ 'contactId': this.editExisting }).then(data => {
                console.log('Data received from - EmergencyTriageController.getIntakeDetails : ', JSON.parse(JSON.stringify(data)));
                let { intakeCaseType, contact } = data;
                if(contact.Phone) {
                    contact.Phone = this.formatPhoneNumber(contact.Phone);
                }
    
                if(contact.SSN__c) {
                    contact.SSN__c = this.formatSSNNumber(contact.SSN__c);
                }
                let formDataFromRes = { ...contact, 'recordType': intakeCaseType }
                
                this.formData = { 'contact': formDataFromRes };
                this.existingMode = true;

            })
                .catch(e => {
                    console.log('Error occurred while executing Apex : EmergencyTriageController.getIntakeDetails', e);
                })
        }
    }

    resetValues() {
        this.currentStepIndex = 0;
        this.transformSteps();
        this.formData = {};
    }

    // handleNewIntake(event) {
    //     this.isModalOpen = true;

    // }

    closeModal() {
        //this.isModalOpen = false;
        this.resetValues();
        this.dispatchEvent(new CustomEvent("close"))
    }

    submitDetails() {
        this.dispatchEvent(new CustomEvent("close"));
    }

    handlePrevious() {

        if (this.stages[this.currentStepIndex].currentStepName === 'Contact') {
            let response = this.template.querySelector('c-emergency-contact-form').handlePrevious();
            if (response) {
                this.formData = { ...this.formData, 'contact': response }
            }
            // } else if (this.stages[this.currentStepIndex].currentStepName === 'Case') {
            //     let response = this.template.querySelector('c-intake-case-form').handlePrevious();
            //     if (response) {
            //         this.formData = { ...this.formData, 'intake': response }
            //     }
        }
        this.currentStepIndex = this.currentStepIndex - 1;
        this.transformSteps();
    }

    proceedToNextStage(event) {
        this.currentStepIndex = this.currentStepIndex + 1;
        this.transformSteps();
        this.formData = { ...this.formData, 'contact': event.detail.contact }
    }

    handleNext() {

        console.log('step ' + this.stages[this.currentStepIndex].currentStepName);

        if (this.stages[this.currentStepIndex].currentStepName === 'Contact') {
            let response = this.template.querySelector('c-emergency-contact-form').handleNext();
            //console.log('Response : ', JSON.parse(JSON.stringify(response)));
            if (response?.allValid) {
                this.currentStepIndex = this.currentStepIndex + 1;
                this.transformSteps();
                this.formData = { ...this.formData, 'contact': response.contact }
            }
        }
        // else if (this.stages[this.currentStepIndex].currentStepName === 'Case') {
        //     let response = this.template.querySelector('c-emergency-intake-case-form').handleNext();
        //     console.log('Case Response : ', JSON.parse(JSON.stringify(response)));
        //     if (response?.allValid) {
        //         this.currentStepIndex = this.currentStepIndex + 1;
        //         this.transformSteps();
        //         this.formData = { ...this.formData, 'intake': response.case }
        //     }
        // }
        else {
            this.currentStepIndex = this.currentStepIndex + 1;
            this.transformSteps();
        }


    }

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

    // get showCasePage() {
    //     return this.stages[this.currentStepIndex]?.currentStepName === 'Case';
    // }

    get showReviewPage() {
        return this.stages[this.currentStepIndex]?.currentStepName === 'Review';
    }

    get showPreviousButton() {
        return !(this.currentStepIndex === 0);
    }

    get showSubmitButton() {
        return (this.currentStepIndex === 1);
    }

    get showCovertPdfButton() {
        return (this.currentStepIndex === 1);
    }

    handleSubmit() {
        this.showSpinner = true;
        console.log('Form Data On Submit : ', JSON.stringify(this.formData));

        let intakeFormRequest = {};
        let intakeCaseType;
        if (this.formData.hasOwnProperty('contact')) {
            let contactObj = this.formData.contact;
            let { recordType, ...contact } = contactObj;

            console.log('Record Type : ', recordType);

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

            

            
            intakeFormRequest['contact'] = contact;
            intakeFormRequest = { ...intakeFormRequest, 'intakeCaseType': recordType };
        }

        console.log('Submit Wrapper : ', JSON.parse(JSON.stringify(intakeFormRequest)));

        storeLeadIntake({ 'requestWrapper': intakeFormRequest }).then(data => {
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

        }).finally (() => {
            this.showSpinner = false;
        })
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