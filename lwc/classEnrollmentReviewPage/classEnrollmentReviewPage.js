import { LightningElement, api, track } from 'lwc';
import { formatPhoneNumber } from 'c/lwrUtils';
export default class ClassEnrollmentReviewPage extends LightningElement {
    @track applicantData;
    @track contactData;
    @api course;
    @api labels;
    
    @api
    set contact(value) {
        if (value) {
            let tempContact = { ...value };
            tempContact.Phone = formatPhoneNumber(tempContact.Phone);
            this.contactData = tempContact;
        }
    }

    get contact() {
        return this.contactData;
    }

    @api
    set applicants(value) {
        let tempApplicantsData = value;
        this.applicantData = tempApplicantsData.map(currentItem => {
            let tempContact = { ...currentItem };
            if (tempContact.Phone) {
                tempContact.Phone = formatPhoneNumber(tempContact.Phone);
            }
            return tempContact;
        });
    }

    get applicants() {
        return this.applicantData;
    }

     get showCoApplicantDetails() {
        let filteredData = this.applicantData.filter(item => item.selected);
        return filteredData.length > 0;
    }
}