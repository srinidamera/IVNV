import { LightningElement, api , track } from 'lwc';
export default class EmergencyReviewForm extends LightningElement {

	@api contact;
	@api intake;

	connectedCallback() {
		console.log('Contact : ',JSON.parse(JSON.stringify(this.contact)));
	}

	/**
     * @desc: method to concatenate and return case type string values with a ':'
     */
	get caseTypesString() {
		return this.casedata?.caseType ? JSON.parse(JSON.stringify(this.casedata.caseType)).join(' : ') : '';
	}

	

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