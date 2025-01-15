import { LightningElement, api, track, wire } from 'lwc';
import INTAKE_OBJECT from "@salesforce/schema/Intake__c";
import { getObjectInfo, getPicklistValuesByRecordType  } from "lightning/uiObjectInfoApi";
import getCaseTypes from '@salesforce/apex/IntakeFormController.getCaseTypes';

export default class IntakeCaseForm extends LightningElement {


    @api caseRecord;
    @api contactData;

    @track householdTypes;
    @track ruralAreaStatuses;
    @track currentResidenceValues;

    @wire(getObjectInfo, {objectApiName: INTAKE_OBJECT}) intakeObject;

    @wire(getPicklistValuesByRecordType , {objectApiName : INTAKE_OBJECT, recordTypeId: '$intakeObject.data.defaultRecordTypeId'}) 
    processPickList({error, data}) {
        if(error) {

        }
        if(data) {
            console.log('PickList values : ',data.picklistFieldValues);
            let picklistValues = data.picklistFieldValues;
            this.householdTypes = picklistValues?.HouseholdType__c?.values;
            this.ruralAreaStatuses = picklistValues?.RuralAreaStatus__c?.values;
            this.currentResidenceValues = picklistValues?.CurrentResidence__c?.values;
        }
    }

    availableRecordTypes;

    /*
    * @description   Getter method for record types fetched
    */


    /*
    * @description  connected callback for intakeCaseFrom LWC
    */
    connectedCallback() {
        if (!this.caseRecord) {
            this.caseRecord = {};
        }
        if (!this.contactData) {
            this.contactData = {};
        }
    }


    /*
    * @description  public method to validate and update caseRecord instance for entire intakeForm
    */
    @api
    handleNext() {
        let feilds = this.template.querySelectorAll('.intakeFields');
        let allValid = true;
        let caseRecord = {};
        feilds.forEach(inputField => {
            const fieldName = inputField.name;
            const value = inputField.value;
            if (!inputField.checkValidity()) {
                inputField.reportValidity();
                allValid = false;
            }

            if (value) {
                caseRecord[fieldName] = value;
            }
        })


        this.caseRecord = caseRecord;
        return { 'allValid': allValid, 'case': caseRecord };
    }

    @api
    handlePrevious() {
        let feilds = this.template.querySelectorAll('.intakeFields');
        let caseRecord = {};

        feilds.forEach(inputField => {
            const fieldName = inputField.name;
            const value = inputField.value;
            if (value) {
                caseRecord[fieldName] = value;
            }

        })
        this.caseRecord = caseRecord;
        return caseRecord;
    }

    @wire(getCaseTypes)
    processCaseTypes({ error, data }) {
        if (error) {

        }
        if (data) {
            const caseTypes = JSON.parse(JSON.stringify(data));
            this.availableRecordTypes = caseTypes.map(elt => { return { 'label': elt.Name, 'value': elt.Id } })

        }
    }

    get recordTypes() {
        return this.availableRecordTypes;
    }
}