import { LightningElement, api, track, wire } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';

export default class Hud9902SummaryPdf extends LightningElement {
    //@api recordId;
    recordId;
    hud9902SummaryVfUrl;
    @track height = '900px';
    @track referrerPolicy = 'no-referrer';
    @track sandbox = '';
    @track width = '100%';

    /*This method fetches service record id on which user clicked on learn more*/
    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
       if(currentPageReference && currentPageReference.state) {
            this.recordId = currentPageReference.state.recordId;
            this.hud9902SummaryVfUrl = '/apex/HUD9902Summary?recId='+this.recordId;
       }
    }
}