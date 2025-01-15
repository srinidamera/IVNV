import { LightningElement, api, track } from 'lwc';
import storeEducationIntake from '@salesforce/apex/EducationalIntakeController.storeEducationIntake';
import getIntakeDetails from '@salesforce/apex/EducationalIntakeController.getIntakeDetails';
import getDependencyMatrixApex from '@salesforce/apex/DependencyMatrixGenerator.getDependencyMatrix';

export default class IntakeEducationForm extends LightningElement {

    @api ismodalopen;

    @api
    editExisting;

    editMode;

    currentStepIndex = 0;

    formData = {};
    @track zipCodeData

    @track
    dependencyMatrix;
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

    /**
     * @description : connected call back for component
     */
    async connectedCallback() {
        console.log('Modal State : ', this.ismodalopen);
        if (this.editExisting) {
            try {
                let intakeData = await getIntakeDetails({ 'contactId': this.editExisting });


                let { zipcodeData, ...formData } = intakeData;
                zipcodeData = { ...zipcodeData, 'MailingPostalCode': formData.contact.MailingPostalCode, 'county': formData.contact.County__c };
                console.log('Data received from - EducationalIntakeController.getIntakeDetails : ', JSON.parse(JSON.stringify(formData)));
                
                let dependencyMatrix = await getDependencyMatrixApex({
                    dependentField: 'HouseholdType__c',
                    controllingField: 'MaritalStatus__c',
                    objectName: 'Contact'
                })

                console.log('Dependency Matrix : ', dependencyMatrix);
                //this.dependencyMatrix = dependencyMatrix;

                //for householdType 
                this.dependencyMatrix = {'householdTypeValues':dependencyMatrix[formData.contact?.MaritalStatus__c]}

                
                this.transformPhoneNumberForContacts(formData);
                
                this.formData = formData;
                this.editMode = true;
                if (zipcodeData) {
                    this.zipCodeData = zipcodeData;
                }
            } catch (e) {
                console.log('Error occurred while executing Apex : EducationalIntakeController.getIntakeDetails', e);
            }
        }
    }

    /**
     * @description : resets the values after form is closed
     * 
     */
    resetValues() {
        this.currentStepIndex = 0;
        this.transformSteps();
        this.formData = {};
    }

    /**
     * @description : closes the edication form wizard
     * 
     */
    closeModal() {
        this.resetValues();
        this.dispatchEvent(new CustomEvent("close"))
    }

    /**
     * @description : submits details to store education intake.
     * 
     */
    submitDetails() {
        this.dispatchEvent(new CustomEvent("close"));
    }

    /**
     * @description : handling the previous button on wizard. 
     * 
     */
    handlePrevious() {
        console.log('inside intakeEducationForm');
        if (this.stages[this.currentStepIndex].currentStepName === 'Contact') {
            let response = this.template.querySelector('c-educational-contact-form').handlePrevious();
            if (response) {
                this.formData = { ...this.formData, 'contact': response }
            }
        } else if (this.stages[this.currentStepIndex].currentStepName === 'Co-Applicants') {
            let response = this.template.querySelector('c-educational-co-applicant')?.handlePrevious();
            if (response) {
                this.formData = { ...this.formData, 'contacts': response }
            }
        }
        this.currentStepIndex = this.currentStepIndex - 1;
        this.transformSteps();
    }

    /**
     * @description : proceeds to next stage.
     * 
     */
    proceedToNextStage(event) {
        this.currentStepIndex = this.currentStepIndex + 1;
        this.transformSteps();
        this.formData = { ...this.formData, 'contact': event.detail.contact }
    }

    /**
     * @description : goes back to previous step
     * 
     */
    handleNext() {

        console.log('step ' + this.stages[this.currentStepIndex].currentStepName);

        if (this.stages[this.currentStepIndex].currentStepName === 'Contact') {
            let response = this.template.querySelector('c-educational-contact-form').handleNext();
            if (response?.allValid) {
                this.currentStepIndex = this.currentStepIndex + 1;
                this.transformSteps();
                this.formData = { ...this.formData, 'contact': response.contact }
            }
        }
        else if (this.stages[this.currentStepIndex].currentStepName === 'Co-Applicants') {
            let response = this.template.querySelector('c-educational-co-applicant').handleNext();
            console.log('contacts Response : ', JSON.parse(JSON.stringify(response)));
            if (response?.allValid) {
                this.currentStepIndex = this.currentStepIndex + 1;
                this.transformSteps();
                this.formData = { ...this.formData, 'contacts': response.contacts }
            }

        }
        else {
            this.currentStepIndex = this.currentStepIndex + 1;
            this.transformSteps();
        }
    }

    /**
     * @description : executed after step is moved ahead or moved back.
     * 
     */
    transformSteps() {
        let currIndex = this.currentStepIndex;
        let newStages = [];
        for (let i = 0; i < this.stages.length; i++) {
            if (i === currIndex) {
                newStages.push({ ...this.stages[i], isCurrent: true, isCompleted: false, isDue: false })
            } else if (i > currIndex) {
                newStages.push({ ...this.stages[i], isCurrent: false, isCompleted: false, isDue: true })
            } else {
                newStages.push({ ...this.stages[i], isCurrent: false, isCompleted: true, isDue: false })
            }
        }
        this.stages = newStages;
    }

    get showContactPage() {
        return this.stages[this.currentStepIndex]?.currentStepName === 'Contact';
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
     * @description : handles submit on education form
     * 
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
            if (contact.hasOwnProperty('Phone')) {
                let Phone = contact.Phone.replaceAll("(", "").replaceAll(")", "").replaceAll(" ", "").replaceAll("-", "").replaceAll(".", "");
                
                contact = { ...contact, Phone };
            }
            
            intakeFormRequest['contact'] = contact;
        }
        if (this.formData.hasOwnProperty('contacts') && Array.isArray(this.formData.contacts) && this.formData.contacts.length > 0) {
            let contactList = [];
            let contactsEntered = JSON.parse(JSON.stringify(this.formData.contacts));
            for (let i = 0; i < contactsEntered.length; i++) {
                let { RecordType, RecordTypeId, index, checked, openModal, BirthDate, Phone, ...trimmedContact } = contactsEntered[i];
                trimmedContact['Birthdate'] = BirthDate;
                if(Phone) {
                    trimmedContact['Phone'] = Phone.replaceAll("(", "").replaceAll(")", "").replaceAll(" ", "").replaceAll("-", "").replaceAll(".", "");
                }

                contactList.push(trimmedContact);
            }
            intakeFormRequest['contacts'] = contactList;
        }

        console.log('Submit Wrapper : ', JSON.parse(JSON.stringify(intakeFormRequest)));

        storeEducationIntake({ 'requestWrapper': intakeFormRequest }).then(data => {
            this.resetValues();
            this.dispatchEvent(new CustomEvent("submit", { detail: JSON.parse(JSON.stringify(data)) }));
        }).catch(e => {
            console.log('Error Occurred : ', e)
            let errorPayLoad = {
                'errorMessage': e.body?.message
            }
            this.dispatchEvent(new CustomEvent("error", { detail: errorPayLoad }));
        }).finally (() => {
            this.showSpinner = false;
        });
    }

    get showNextButton() {
        return !(this.currentStepIndex === this.stages.length - 1);
    }

    /**
     * @description : Returns boolean to display wether to show cancel button
     *                on footer or not
     */
    get showCancelButton() {
        return this.currentStepIndex === 0;
    }

    transformPhoneNumberForContacts(formData) {
        if(formData.contact.hasOwnProperty('Phone') && formData.contact.Phone){
            formData.contact.Phone = this.formatPhoneNumber(formData.contact.Phone);
        }

        if(formData.contacts){
            formData.contacts.forEach(con=>{
                if(con.Phone) {
                    con.Phone = this.formatPhoneNumber(con.Phone);
                }
                
            })
        }
    }

    /**
     * 
     * @description : Formates the Phone Number
     */
    formatPhoneNumber(s) {
        return '('+s.substr(0,3)+') '+s.substr(3,3)+'-'+s.substr(6);
    }
}