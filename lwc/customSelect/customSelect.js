import { LightningElement, api, track } from 'lwc';

export default class CustomSelect extends LightningElement {

    _picklistvalues = [];

    @api label;

    @api required = false;


    @track _selectedValues = [];

    @track pickListObj;

    @track errorMessage;

    initialLoaded = false

    isDropdownOpen

    @api placeholder;
    @api selectedCountLabel;
    _handler;

    /*
    * @description  public method to set picklist values.
    */
    @api set picklistvalues(value) {
        this._picklistvalues = value;
        this.transformDropdownOption();
        this.storeSelectedOptions();

    }

    @api set selectedValues(value) {
        //console.log('Setting Selected Values : ', JSON.stringify(value))
        if(value === undefined || value === null){
            value = [];
        }
        this._selectedValues = JSON.parse(JSON.stringify(value));
        this.transformDropdownOption();
        this.storeSelectedOptions();

    }

    get selectedValues() {
        return this._selectedValues;
    }

    get picklistvalues() {
        return this._picklistvalues;
    }

    handleOnClick(event) {
        event.stopPropagation();
        console.log('Inside Click');
        this.template.querySelector('[data-id="combobox-drop-down-id-137-custom"]')?.classList?.toggle('slds-is-open');
    }

    connectedCallback() {
        //this.transformDropdownOption();
        //this.storeSelectedOptions();
        //console.log('Values obtained : ', JSON.stringify(this._picklistvalues));
        document.addEventListener('click', this._handler = this.close.bind(this));

    }


    get recordTypeOptions() {

        return this.pickListObj;
    }

    close() {
        //console.log('we should close now');
        this.template.querySelector('[data-id="combobox-drop-down-id-137-custom"]')?.classList?.remove('slds-is-open');

    }

    disconnectedCallback() {
        document.removeEventListener('click', this._handler);
    }

    toggleSelect(event) {
        event.stopPropagation();
        let optionSelected = event.currentTarget.dataset.id;
        this.pickListObj.forEach((elt, index, arr) => {
            if (elt.value === optionSelected) {
                elt.isSelected = !elt.isSelected;
            }
        })
        this.storeSelectedOptions();
        let payload = this._selectedValues;
        const selectedEvent = new CustomEvent("selection", { detail: JSON.parse(JSON.stringify(payload)) });
        this.dispatchEvent(selectedEvent);
    }

    storeSelectedOptions() {
        if (this.pickListObj) {
            
            this._selectedValues = this.pickListObj.filter((elt, index, arr) => {
                return elt.isSelected;
            }).map((elt, index, arr) => {
                return elt.value;
            })

            if (this.errorMessage && this._selectedValues && Array.isArray(this._selectedValues) && this._selectedValues.length>0) {
                this.errorMessage = null;
                this.template.querySelector('div[data-id="combobox-main-div"]').classList.remove('slds-has-error');
            }
        }

    }

    transformDropdownOption() {
        if (this._picklistvalues && Array.isArray(this._picklistvalues) && this._picklistvalues.length > 0) {
            let pickListObj = this._picklistvalues.map((elt, index, arr) => {
                var obj = {};
                //obj = { ...obj, isSelected: this._selectedValues.includes(elt.value), value: elt };
                obj = { ...obj, isSelected: this._selectedValues.includes(elt), value: elt };
                return obj;
            })
            this.pickListObj = pickListObj;

        }

    }

    handleRemove(event) {
        let optionSelected = event.currentTarget.dataset.id;
        this.pickListObj.forEach((elt, index, arr) => {
            if (elt.value === optionSelected) {
                elt.isSelected = false;
            }
        })
        this.storeSelectedOptions();
    }

    @api
    getSelectedValue() {
        return this._selectedValues;
    }

    @api
    reportError(errorMessage) {
        console.log('Report Error Message :: ', errorMessage);
        this.errorMessage = errorMessage;
        this.template.querySelector('div[data-id="combobox-main-div"]').classList.add('slds-has-error');
    }

    get showSelectedCount() {
        if(this._selectedValues && Array.isArray(this._selectedValues) && this._selectedValues.length>0) {
            //return `${this._selectedValues.length} Option(s) Selected`;
            return this._selectedValues.length + ' ' + (this.selectedCountLabel ? this.selectedCountLabel : 'Option(s) Selected');
        } else {
            return null;
        }
    }




}