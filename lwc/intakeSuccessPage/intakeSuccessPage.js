import { LightningElement, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

export default class IntakeSuccessPage extends NavigationMixin(LightningElement) {


    _intakeResponse;

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