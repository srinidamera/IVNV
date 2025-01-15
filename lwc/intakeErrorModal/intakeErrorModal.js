import LightningModal from 'lightning/modal';
import { api } from 'lwc';

export default class IntakeErrorModal extends LightningModal  {

    @api
    errorMessage

    handleOkay(){
        this.close('clicked OK');
    }
}