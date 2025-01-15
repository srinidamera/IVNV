import { LightningElement, api , track } from 'lwc';
export default class IntakeReviewForm extends LightningElement {

	@api contact;
	@api casedata;
	@api coapplicantlist = [];
	@track firstrun = true;
	hideCaseData = false;

	connectedCallback() {
		if(!this.casedata){
			this.hideCaseData = true;
		}
	}

	/**
     * @desc: method to concatenate and return case type string values with a ':'
     */
	get caseTypesString() {
		return this.casedata?.caseType ? JSON.parse(JSON.stringify(this.casedata.caseType)).join(' : ') : '';
	}

	get isFirstRun() {
		if(this.firstrun){
			this.firstrun = false;
			return true;
		}
		return this.firstrun;
	}

	get computeage(){
		console.log('cont 1 : '+this.contact);
		console.log('cont 2 : ',this.contact);
		console.log('cont 3 : '+JSON.stringify(this.contact));
		let d1 = new Date(this.contact.Birthdate);
		let d2 = new Date();
		let varAge = d2.getYear() - d1.getYear();
        if ( d1.getUTCMonth() < d2.getUTCMonth() ) {
            -varAge;
        } else if ( d1.getUTCMonth() === d2.getUTCMonth() ) {            
            if ( d1.getUTCDate() < d2.getUTCDate() ){
                -varAge;
			}
        }
        return JSON.stringify(varAge);
	}
}