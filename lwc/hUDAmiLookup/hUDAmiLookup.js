import { LightningElement, api, track, wire } from 'lwc';
import validAMI from '@salesforce/apex/HUDAmiLookupController.validAMI';
import getHudAmiUniqueCounty from '@salesforce/apex/HUDAmiLookupController.getHudAmiUniqueCounty';
import getHudAmiUniquetowns from '@salesforce/apex/HUDAmiLookupController.getHudAmiUniquetowns';
import calculateAMIandCommit from '@salesforce/apex/HUDAmiLookupController.calculateAMIandCommit';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { RefreshEvent } from 'lightning/refresh';

export default class HudAmiLookup extends LightningElement {
    // API properties to receive data from parent components or record context
    @api recordId;
    @api objectApiName;

    // Tracked properties for reactive behavior
    @track countyList = [];
    @track townList = [];
    @track slctdCounty = '';
    @track slctdTown = '';
    @track slctdTownLabel = '';
    @track showAmiLookup = true;
    @track showCounties = false;
    @track showTownnames = false;
    @track selectCounty = false;
    @track selectTown = false;
    @track spinner = false;
    @track showcalculateBtn = false;
    @track showWarning = false;
    
    // Stores object metadata
    objectInfo;
    
    // API name of the field to evaluate HUD AMI
    evaluateHUDAMIApiName = 'EvaluateHUDAMI__c';

    /**
     * @wire decorator to fetch object metadata
     * @param error - Error object if there was an error fetching object info
     * @param data - Object metadata if fetched successfully
     */
    @wire(getObjectInfo, { objectApiName: '$objectApiName' })
    wiredObjectInfo({ error, data }) {
        if (data) {
            this.objectInfo = data;
        } else if (error) {
            console.error('Error fetching object info:', error);
        }
    }

    /**
     * Lifecycle hook that is called when the component is inserted into the DOM.
     * It triggers the validation of AMI.
     */
    connectedCallback() {
        this.validateAMI();  
        this.showAmiLookup = true;
    }

    /**
     * Validates AMI for the current record and object.
     */
    validateAMI() {
        validAMI({ recordId: this.recordId, objectApiName: this.objectApiName })
            .then((result) => {
                console.log('validAMI result:', result);  // Log the result
                if (result) {
                    this.showWarning = false;
                } else {
                    this.showWarning = true;
                }
            })
            .catch((error) => {
                console.error('Error in validAMI:', error);  // Improved logging
                this.showErrorToast('System Exception Please contact administrator to resolve');
            });
    }

    /**
     * Fetches unique counties for the HUD AMI lookup.
     */
    fetchCounties() {
        this.spinner = true;
        getHudAmiUniqueCounty({ recordId: this.recordId, objectApiName: this.objectApiName })
            .then((result) => {
                if (result.length === 1) {
                    this.showCounties = false;
                    this.showAmiLookup = false;
                    this.showTownnames = false;
                    this.showcalculateBtn = false;
                    this.slctdCounty = result[0];
                    this.fetchTownName();
                } else if (result.length > 1) {
                    let optionsValues = [];
                    result.forEach((rec) => {
                        optionsValues.push({ label: rec, value: rec });
                    });
                    this.countyList = optionsValues;
                    this.showCounties = true;
                    this.showAmiLookup = false;
                } else {
                    this.showErrorToast('Invalid Zip Code. Please verify if it is correct');
                }
            })
            .catch((error) => {
                console.error('Error in fetchCounties:', error);  // Improved logging
                this.showErrorToast('System Exception Please contact administrator to resolve');
            })
            .finally(() => {
                this.spinner = false;
            });
    }

    /**
     * Fetches unique towns for the selected county.
     */
    fetchTownName() {
        if (!this.slctdCounty) {
            this.selectCounty = true;
            return;
        }
        this.spinner = true;
        this.selectCounty = false;

        getHudAmiUniquetowns({
            recordId: this.recordId,
            countyName: this.slctdCounty,
            objectApiName: this.objectApiName
        })
            .then((result) => {
                if (result.length === 1) {
                    this.slctdTown = result[0].Id;
                    this.showCounties = false;
                    this.showAmiLookup = true;
                    this.showTownnames = false;
                    this.showcalculateBtn = false;
                    this.calculateandCommit();
                } else if (result.length > 1) {
                    let optionsValues = [];
                    result.forEach((rec) => {
                        optionsValues.push({
                            label: rec.TownName__c,
                            value: rec.Id
                        });
                    });
                    this.townList = optionsValues;
                    this.showCounties = false;
                    this.showAmiLookup = false;
                    this.showTownnames = true;
                } else {
                    this.showErrorToast('No towns found.');
                }
            })
            .catch((error) => {
                console.error('Error in fetchTownName:', error);  // Improved logging
                this.showErrorToast('System Exception Please contact administrator to resolve');
            })
            .finally(() => {
                this.spinner = false;
            });
    }

    /**
     * Prepares the component for calculating the AMI.
     */
    calculateZone() {
        this.showCounties = false;
        this.showAmiLookup = false;
        if (!this.slctdTown) {
            this.selectTown = true;
            this.showTownnames = true;
            this.showcalculateBtn = false;
            return;
        }
        this.selectTown = false;
        this.showTownnames = false;
        this.showcalculateBtn = true;
    }

    /**
     * Calculates the AMI and commits the changes to the record.
     */
    calculateandCommit() {
        this.spinner = true;

        calculateAMIandCommit({ recordId: this.recordId, hudamiId: this.slctdTown, objectApiName: this.objectApiName })
            .then(result => {
                console.log('calculateAMIandCommit result:', result);  // Log the result
                if (result === 'RECORD_UPDATED') {
                    this.showSuccessToast('Record is updated with AMI data successfully');
                    this.showWarning = false;
                    this.spinner = false;
                    this.dispatchEvent(new RefreshEvent());
                } else if (result === 'FIELD_VALIDATION_FAILED') {
                    this.showErrorToast('Missing Annual Household Income /Current Household Gross Monthly Income and Household size');
                    this.spinner = false;
                } else if (result === 'EXCEPTION') {
                    this.showErrorToast('System Exception Please contact administrator to resolve');
                    this.spinner = false;
                }
            })
            .catch(error => {
                console.error('Error in calculateandCommit:', error);  // Improved logging
                this.showErrorToast('System Exception Please contact administrator to resolve');
                this.spinner = false;
            });
        this.showCounties = false;
        this.showAmiLookup = true;
        this.showTownnames = false;
        this.slctdCounty = '';
        this.slctdTown = '';
        this.showcalculateBtn = false;
        this.selectCounty = false;
        this.selectTown = false;
    }

    /**
     * Updates the EvaluateHUDAMI field to false.
     */
    updateEvaluateHUDAMI() {
        const fields = {};
        fields['Id'] = this.recordId;
        fields[this.evaluateHUDAMIApiName] = false; 

        const recordInput = { fields };

        this.updateRecord(recordInput);
    }

    /**
     * Dispatches a custom event to update the record.
     * @param {Object} recordInput - The record input object to update.
     */
    updateRecord(recordInput) {
        this.spinner = true;
        this.dispatchEvent(
            new CustomEvent('updaterecord', { detail: recordInput })
        );
    }

    /**
     * Handles the change event for the county selection.
     * @param {Event} event - The change event object.
     */
    handleCountyChange(event) {
        this.slctdCounty = event.target.value;
    }

    /**
     * Handles the change event for the town selection.
     * @param {Event} event - The change event object.
     */
    handleTownChange(event) {
    const selectedTownId = event.detail.value;
    console.log('selectedTownId', selectedTownId);

    const selectedTown = this.townList.find(town => town.value === selectedTownId);
    if (selectedTown) {
        this.slctdTown = selectedTown.value;  
        this.slctdTownLabel = selectedTown.label; 
        console.log('slctdTown', this.slctdTown);
        console.log('slctdTownLabel', this.slctdTownLabel);
    } else {
        this.slctdTown = ''; 
        this.slctdTownLabel = '';
    }
       }

    /**
     * Cancels all operations and resets the component state.
     */
    cancelAll() {
        this.showAmiLookup = true;
        this.showCounties = false;
        this.showTownnames = false;
        this.spinner = false;
        this.selectCounty = false;
        this.showcalculateBtn = false;
        this.selectTown = false;
        this.slctdCounty = '';
        this.slctdTown = '';
        this.countyList = [];
        this.townList = [];
    }

    /**
     * Shows an error toast message.
     * @param {String} message - The error message to display.
     */
    showErrorToast(message) {
        const evt = new ShowToastEvent({
            title: 'Error',
            message: message,
            variant: 'error'
        });
        this.dispatchEvent(evt);
    }

    /**
     * Shows a success toast message.
     * @param {String} message - The success message to display.
     */
    showSuccessToast(message) {
        const evt = new ShowToastEvent({
            title: 'Success',
            message: message,
            variant: 'success'
        });
        this.dispatchEvent(evt);
    }
}