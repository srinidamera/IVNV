import { LightningElement, track,api } from 'lwc';
import LightningModal from 'lightning/modal';
import isIntakeStaffUser from "@salesforce/apex/ClientCaseGuidanceController.isIntakeStaffUser";

export default class Referrals extends LightningElement {
    @track showChild = false;
    @api recordId;
    @api objectApiName;

    handleClick() {
        this.showChild = true;
        this.showModal = true;
        
    }

    connectedCallback() {
        //this.isIntakeStaffUser();//Intake staff should also see the new referral button
    }

    @track isIntakeUser = false;
    isIntakeStaffUser() {
        isIntakeStaffUser().then((result) => {
        this.isIntakeUser = result;
        }).catch((error) => {
        console.log('ERROR !!!'+JSON.stringify(error))
        });
    }

    @track showModal = false;

    openModal() {
        this.showModal = true;
    }
    
    closeModal() {
        this.showModal = false;
    }

}