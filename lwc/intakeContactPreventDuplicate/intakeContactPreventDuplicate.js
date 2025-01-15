import { api,LightningElement } from 'lwc';

const columns = [
    { label: 'Client Id', fieldName: 'ClientId', hideDefaultActions: true},
    { label: 'Name', fieldName: 'conLink', type: 'url', typeAttributes: { label: { fieldName: 'Name' }, target: '_blank'}, hideDefaultActions: true},
    { label: 'Email', fieldName: 'Email', sortable: "true", hideDefaultActions: true},
    { label: 'Phone', fieldName: 'Phone', type: 'phone', hideDefaultActions: true},
    { label: 'Address', fieldName: 'Address', hideDefaultActions: true}
    ];

export default class IntakeContactPreventDuplicate extends LightningElement {
    @api duplicateDetected = false;
    @api tabledata = []; 
    data = [];
    columns = columns;

    /* @description: connectedCallback method to set data in datatable*/
    connectedCallback() {
        this.data = this.tabledata;
    }

    /* @description: Handler method to close duplicate modal popup */
    closeModal(){
        this.duplicateDetected = false;
        let ev = new CustomEvent('setduplicatedetected', {detail : {value : this.duplicateDetected}});
        this.dispatchEvent(ev);
    }

    /* @description: Handler method to set proceed Forward */
    handleProceed(event){
        this.closeModal();
        let ev = new CustomEvent('proceed', {detail : null});
        this.dispatchEvent(ev);
    }

    /* @description: Handler method to close */
    handleGoBack(event){
        this.closeModal();
    }
}