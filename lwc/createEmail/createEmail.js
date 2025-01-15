import { LightningElement, api, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { encodeDefaultFieldValues } from 'lightning/pageReferenceUtils';
import getContactEmailAddress from '@salesforce/apex/EmailController.getContactEmailAddress';
import getEmailAddress from '@salesforce/apex/EmailContactController.getEmailAddress';
import getIntakeEmailAddress from '@salesforce/apex/EmailController.getIntakeEmailAddress';

export default class CreateEmail extends NavigationMixin(LightningElement) {

    @api recordId;
    contactEmailAddress;
    emailAddress;
    intakeEmailAddress;

    //fetch Client_case Emails
    @wire(getContactEmailAddress, { parentId: '$recordId' })
    wiredContactEmailAddress({ error, data }) {
        if (data) {
            this.contactEmailAddress = data;
        } 
    }

    //fetch Contact Emails
    @wire(getEmailAddress, { parentId: '$recordId' })
    wiredEmailAddress({ error, data }) {
        if (data) {
            this.emailAddress = data;
        }
    }

    //fetch Intake Email
    @wire(getIntakeEmailAddress, { parentId: '$recordId' })
    wiredIntakeEmailAddress({ error, data }) {
        if (data) {
            this.intakeEmailAddress = data;
        } 
    }

    @api invoke() {
        if (this.contactEmailAddress) {
            var pageRef = {
                type: "standard__quickAction",
                attributes: {
                    apiName: "Global.SendEmail",
                },
                state: {
                    recordId: this.recordId,
                    defaultFieldValues: encodeDefaultFieldValues({
                        ToAddress: this.contactEmailAddress,
                    }),
                },
            };
            this[NavigationMixin.Navigate](pageRef);
        }
        else if (this.emailAddress) {
            var pageRef = {
                type: "standard__quickAction",
                attributes: {
                    apiName: "Global.SendEmail",
                },
                state: {
                    recordId: this.recordId,
                    defaultFieldValues: encodeDefaultFieldValues({
                        ToAddress: this.emailAddress,
                    }),
                },
            };
            this[NavigationMixin.Navigate](pageRef);
        }
        else if (this.intakeEmailAddress) {
            var pageRef = {
                type: "standard__quickAction",
                attributes: {
                    apiName: "Global.SendEmail",
                },
                state: {
                    recordId: this.recordId,
                    defaultFieldValues: encodeDefaultFieldValues({
                        ToAddress: this.intakeEmailAddress,
                    }),
                },
            };
            this[NavigationMixin.Navigate](pageRef);
        }
         else {
             var pageRef = {
                type: "standard__quickAction",
                attributes: {
                    apiName: "Global.SendEmail",
                },
                state: {
                    recordId: this.recordId,
                },
            };
            this[NavigationMixin.Navigate](pageRef);
        }
    }
}