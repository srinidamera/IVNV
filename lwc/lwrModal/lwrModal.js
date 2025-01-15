import { api } from 'lwc';
import LightningModal from 'lightning/modal';

export default class LwrModal extends LightningModal {
    @api content;
    @api richContent;
    @api headerText;
    @api cancelButtonTitle;
    @api saveButtonTitle;
    handleCancel() { 
        this.close('cancel'); 
        
    }
    handleSave() {
        this.close('save');  
    }
}