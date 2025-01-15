import { LightningElement, api, track, wire } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';

export default class ShowPdfModal extends LightningElement {
    @api recordId;
    @track isModalOpen = false;

    // wire method to get record id stored
    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        this.recordId = currentPageReference?.state?.recordId;
    }

    //open modal when the button is clicked
    connectedCallback(){
        this.isModalOpen = true;
    }

    //api call for VF page
    get IntakePrintUrl() {
        if(this.recordId){
            return `/apex/printIntakeVf?Id=${this.recordId}`
        }
        else{
            console.log("error");
        }
    }

    //handle close modal once clicked 'x'
    closeModal() {
        this.isModalOpen = false;
    }
}