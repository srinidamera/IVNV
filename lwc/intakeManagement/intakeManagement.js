import { LightningElement,wire,track } from 'lwc';
import intakeMsgChannel from "@salesforce/messageChannel/IntakeMsgChannel__c";
import {publish,subscribe,APPLICATION_SCOPE, MessageContext} from 'lightning/messageService';
import RELEVANT_CLIENT_CASE_SELECTION_INFO from '@salesforce/label/c.Intake_RelevanClientCaseSelectionInfo';

export default class IntakeManagement extends LightningElement {
    isSearch = false;
    isModalOpen = false;
    selectedContact ;
    @track selectedContactList;
    showSelectMessage;
    label = {
        RELEVANT_CLIENT_CASE_SELECTION_INFO
    }

    @wire(MessageContext)
    messageContext;
    
    /**
     * @description : connected call back to component
     */
    connectedCallback() {
        this.handleSubscribe();
    }

    /**
     * @description : subscribtion method to Message channel
     */
    handleSubscribe() {
        if (this.subscription) {
            return;
        }
        this.subscription = subscribe(this.messageContext, intakeMsgChannel, (message) => {
            //this.showSelectMessage = null;
            if(message.Type == "SearchDone"){
                this.isSearch = message.messageBody;
            }
            if(message.Type == "OpenModal"){
                this.isModalOpen = message.messageBody;
            }
            if(message.Type == "SearchClientCase"){    
                this.selectedContactList = message.messageBody.map(elt=>elt?.Id);
                this.selectedContact = message.messageBody[0];
                console.log(JSON.parse(JSON.stringify(this.selectedContactList)));
                this.showSelectMessage = null;
            } 
            if(message.Type === 'SearchReset') {
                this.showSelectMessage = 'Please select a contact to show their relevant Client Cases/ Intake Requests/ Show History.'
            }  
        });
    }

    /**
     * 
     * @description : to open show history wizard
     */
    openWizardModal(event) {
        this.isModalOpen = true;
    }

    /**
     * 
     * @description : to close show history wizard
     */
    closeModal() {
        this.isModalOpen = false;
    }

    /**
     * 
     * @description : to close show history wizard
     */
    closeSHowHistoryModal(){
        this.selectedContact=null;
        this.selectedContactList = null;
    }

    get showHistoryModal() {
        return this.selectedContactList && Array.isArray(this.selectedContactList) && this.selectedContactList.length>0;
    }
}