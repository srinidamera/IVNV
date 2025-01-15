import { LightningElement, api , track } from 'lwc';
export default class EducationalReviewForm extends LightningElement {

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

	/**
     * @desc: getter method for identifying firstrun
     */
	get isFirstRun() {
		if(this.firstrun){
			this.firstrun = false;
			return true;
		}
		return this.firstrun;
	}

	/**
     * @desc: getter method for computeage
     */
	get computeage(){
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