import { LightningElement, api, track, wire } from 'lwc';
import { getObjectInfo } from "lightning/uiObjectInfoApi";
import getPicklistValues from '@salesforce/apex/IntakeFormController.getPicklistValues';
import getCaseTypes from '@salesforce/apex/IntakeFormController.getCaseTypes';

export default class IntakeCaseForm extends LightningElement {


    @track householdTypeValues;
    @track ruralStatusHouseholdValues;
    @track referralSourceValues = [
        {
            label: 'Flyer',
            value: 'Flyer'
        },
        {
            label: 'Friend/Family',
            value: 'Friend/Family'
        },
    ];

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




    @track allHelpTextHidden = false;

    @track pickListMap = {}

    @api caseRecord;
    @api contactData;

    availableRecordTypes;

    /*
    * @description   Getter method for record types fetched
    */
    get recordTypes() {
        return this.availableRecordTypes;
    }

    /*
    * @description   to fetch and store the recordTypes
    */
    @wire(getObjectInfo, { objectApiName: 'ClientCase__c' }) fetchObjectDetails({ error, data }) {
        if (error) {
            console.log('Error = ' + JSON.stringify(error));
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
                this.availableRecordTypes.push({ 'label': caseTypes[i].Name, 'value': caseTypes[i].Id });
            }

        }
    }

    /*
    * @description   to fetch picklist values for fields on Client Case
    */
    @wire(getPicklistValues, { fieldNames: ['HouseholdType__c', 'RuralAreaStatus__c'], objectApiName: 'ClientCase__c' })
    fetchPickListValues({ error, data }) {
        if (error) {
            console.log('Error = ' + JSON.stringify(error));
        }
        if (data) {
            console.log('Data : ' + JSON.stringify(data));
            this.householdTypeValues = this.getHouseholdTypePicklistValues();
            this.ruralStatusHouseholdValues = data.RuralAreaStatus__c;
        }
    }

    getHouseholdTypePicklistValues() {
        let val = this.contactData['MaritalStatus__c'];
        console.log('Marital Status = ' + val);
        let picklistVal = [];
        if (val === 'Married') {
            picklistVal = [
                {
                    label: 'Married with children',
                    value: 'Married with children'
                },
                {
                    label: 'Married without children',
                    value: 'Married without children'
                },
                {
                    label: 'Domestic partnership',
                    value: 'Domestic partnership'
                },
                {
                    label: 'Two or more unrelated adults',
                    value: 'Two or more unrelated adults'
                },
                {
                    label: 'Other',
                    value: 'Other'
                }
            ];
        } else if (val === 'Legally Separated') {
            picklistVal = [
                {
                    label: 'Married with children',
                    value: 'Married with children'
                },
                {
                    label: 'Married without children',
                    value: 'Married without children'
                },
                {
                    label: 'Two or more unrelated adults',
                    value: 'Two or more unrelated adults'
                },
                {
                    label: 'Other',
                    value: 'Other'
                }
            ];
        } else if (val === 'Single') {
            picklistVal = [
                {
                    label: 'Domestic partnership',
                    value: 'Domestic partnership'
                },
                {
                    label: 'Female-headed single parent household/Head of Household',
                    value: 'Female-headed single parent household/Head of Household'
                },
                {
                    label: 'Male-headed single parent household/Head of Household',
                    value: 'Male-headed single parent household/Head of Household'
                },
                {
                    label: 'Single adult',
                    value: 'Single adult'
                },
                {
                    label: 'Two or more unrelated adults',
                    value: 'Two or more unrelated adults'
                },
                {
                    label: 'Other',
                    value: 'Other'
                }
            ];
        } else if (val === 'Divorced') {
            picklistVal = [
                {
                    label: 'Female-headed single parent household/Head of Household',
                    value: 'Female-headed single parent household/Head of Household'
                },
                {
                    label: 'Male-headed single parent household/Head of Household',
                    value: 'Male-headed single parent household/Head of Household'
                },
                {
                    label: 'Single adult',
                    value: 'Single adult'
                },
                {
                    label: 'Two or more unrelated adults',
                    value: 'Two or more unrelated adults'
                },
                {
                    label: 'Other',
                    value: 'Other'
                }
            ];
        } else if (val === 'Widowed') {
            picklistVal = [
                {
                    label: 'Female-headed single parent household/Head of Household',
                    value: 'Female-headed single parent household/Head of Household'
                },
                {
                    label: 'Male-headed single parent household/Head of Household',
                    value: 'Male-headed single parent household/Head of Household'
                },
                {
                    label: 'Single adult',
                    value: 'Single adult'
                },
                {
                    label: 'Two or more unrelated adults',
                    value: 'Two or more unrelated adults'
                },
                {
                    label: 'Other',
                    value: 'Other'
                }
            ];
        }
        return picklistVal;
    }

    /*
    * @description  connected callback for intakeCaseFrom LWC
    */
    connectedCallback() {
        //console.log('Case Record : ',JSON.parse(JSON.stringify(this.caseRecord)))
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
        let feilds = this.template.querySelectorAll('.caseFields');
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

        //Check Validity for custom select

        // let selectedValues = JSON.parse(JSON.stringify(this.template.querySelector('c-custom-select').getSelectedValue()));
        // if (!(selectedValues && Array.isArray(selectedValues) && selectedValues.length > 0)) {
        //     this.template.querySelector('c-custom-select').reportError('Please select at least one value.');
        //     caseRecord['caseType'] = [];
        //     allValid = false;
        // } else {
        //     caseRecord['caseType'] = selectedValues;
        // }
        this.caseRecord = caseRecord;
        return { 'allValid': allValid, 'case': caseRecord };
    }

    @api
    handlePrevious() {
        let feilds = this.template.querySelectorAll('.caseFields');
        let caseRecord = {};

        feilds.forEach(inputField => {
            const fieldName = inputField.name;
            const value = inputField.value;
            if (value) {
                caseRecord[fieldName] = value;
            }

        })
        // let selectedValues = JSON.parse(JSON.stringify(this.template.querySelector('c-custom-select').getSelectedValue()));
        // if (selectedValues && Array.isArray(selectedValues) && selectedValues.length > 0) {
        //     caseRecord['caseType'] = selectedValues;
        // }
        this.caseRecord = caseRecord;
        return caseRecord;
    }
}