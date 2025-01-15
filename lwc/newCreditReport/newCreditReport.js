import { LightningElement,track,api } from 'lwc';
import { CloseActionScreenEvent } from 'lightning/actions';
import { ShowToastEvent } from "lightning/platformShowToastEvent";
export default class NewCreditReport extends LightningElement {
    //Boolean tracked variable to indicate if modal is open or not default value is false as modal is closed when page is loaded 
    @track isModalOpen = false;
    @api recordId;

    openModal() {
        // to open modal set isModalOpen tarck value as true
        this.isModalOpen = true;
    }
    closeModal() {
        // to close modal set isModalOpen tarck value as false
        this.isModalOpen = false;
    }
    submitDetails() {
        // to close modal set isModalOpen tarck value as false
        //Add your code to call apex method or do some processing
        this.isModalOpen = false;
    }

    get inputVariables() {
        return [
            {
                name: 'recordId',
                type: 'String',
                value: this.recordId
            }
        ];
    }

    handleStatusChange(event) {
        console.log('status '+event.detail.status);
        if(event.detail.status === 'FINISHED') {
            //Action after a flow has finished
            this.dispatchEvent(new CloseActionScreenEvent());
            this.isModalOpen = false;
            const evt = new ShowToastEvent({
                title: 'Success!!',
                message: 'Credit Report Successfully Created',
                variant: 'success',
                });
            
        this.dispatchEvent(evt);
        }
    }
}