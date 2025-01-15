import { LightningElement, api,track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import getIntakeName from '@salesforce/apex/EmergencyTriageController.getIntakeName';

export default class IntakeEmergencySuccessPage extends NavigationMixin(LightningElement) {


    @track _intakeResponse;
    @track intakeName;
    connectedCallback() {
        console.log('this._intakeResponse.intakeId = '+this._intakeResponse.intakeId)
        getIntakeName({ 'intakeId': this._intakeResponse.intakeId }).then(data => {
            this.intakeName = data;
            console.log('data = '+data)
        }).catch(e => {
            console.log('Error occurred while executing Apex : EmergencyTriageController.getIntakeName', e);
        })
    }
    /* @description: setter for setting intake success Response */
    @api set intakeResponse(value) {
        console.log('Response Recieved : ' + JSON.stringify(value))
        this._intakeResponse = value;
    }

    /* @description: getter for getting intake success Response */
    get intakeResponse() {
        return this._intakeResponse
    }

    /* @description: navigate to record page based on object api name and  record id*/
    navigateToRecordPage(event) {
        let recordId = event.target.dataset.id;
        let objecApiName = event.target.dataset.object;
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: recordId,
                objectApiName: objecApiName,
                actionName: 'view'
            },
        });
    }
}