import { LightningElement, track } from 'lwc';
export default class NwqrReports extends LightningElement {

    @track orsEducation = true;
    @track orsCounseling = false;
    @track financialCapabilityReport = false;
    @track nwqrClients = false;
    @track nwqrFinancing = false;
    @track foreclosureIntake = false;

    handleSelect(event) {
        const selectedName = event.detail.name;
        this.resetAll();
        if(selectedName == 'NWQR Education'){
            this.orsEducation = true;
        }else if(selectedName == 'NWQR Counseling'){
            this.orsCounseling = true;
        }else if(selectedName == 'NWQR Financial Capability'){
            this.financialCapabilityReport = true;
        }else if(selectedName == 'NWQR Clients'){
            this.nwqrClients = true;
        }else if(selectedName == 'NWQR Financing'){
            this.nwqrFinancing = true;
        }else if(selectedName == 'NWQR Summary'){
            this.foreclosureIntake = true;
        }
    }

    resetAll(){
        this.orsEducation = false;
        this.orsCounseling = false;
        this.financialCapabilityReport = false;
        this.nwqrFinancing = false;
        this.nwqrClients = false;
        this.foreclosureIntake = false;
    }

}