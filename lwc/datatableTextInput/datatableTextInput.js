import { LightningElement, api } from 'lwc';

export default class DatatableTextInput extends LightningElement {

    @api label;
    @api placeholder;
    @api value;
    @api context;

    handleChange(event) {
        //show the selected value on UI
        this.value = event.detail.value;

        //fire event to send context and selected value to the data table
        this.dispatchEvent(new CustomEvent('inputchanged', {
            composed: true,
            bubbles: true,
            cancelable: true,
            detail: {
                data: { context: this.context, value: this.value }
            }
        }));
    }
}