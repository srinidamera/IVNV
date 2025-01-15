import { LightningElement, wire, api, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import siteId from "@salesforce/site/Id";
import { getContent } from "experience/cmsDeliveryApi";
import getAgencyProfileDetails from '@salesforce/apex/NWCompassUtilityController.getAgencyProfileDetails';
import { replaceStrings, formatPhoneNumber } from "c/lwrUtils";

export default class ContactUsComponent extends NavigationMixin (LightningElement) {
    @track content;
    @track agencyProfileDetails;
    @track contentData;
    @api contentKey;
    @api goBackLabel;

    @wire(getContent, {
        channelOrSiteId: siteId,
        contentKeyOrId: "$contentKey"
    })
    getSectionDescription(result) {
        if (result?.data?.contentBody?.Value) {
            this.contentData = result.data.contentBody.Value;
            this.updateContent();
        }
    }

    @wire(getAgencyProfileDetails)
    onGetAgencyProfileDetails(result) {
        if (result.data) {
            this.agencyProfileDetails = result.data;
            this.updateContent();
        } else if(result.error){
            console.log('getAgencyProfileDetails error str : ', JSON.stringify(result.error));
        } 
    }

    get email() {
        return this.agencyProfileDetails && this.agencyProfileDetails.EmailAddress__c ? this.agencyProfileDetails.EmailAddress__c : '';
    }

    get phone() {
        return this.agencyProfileDetails && this.agencyProfileDetails.AgencyPhoneNumber__c ? this.agencyProfileDetails.AgencyPhoneNumber__c : '';
    }

    updateContent() {
        if (this.contentData && this.agencyProfileDetails) {
            const replacements = {
                "{phoneNumber}": formatPhoneNumber(this.phone),
                "{emailAddress}": this.email
            };
            this.content = replaceStrings(this.contentData, replacements);
            console.log('Updated content:', this.content);
        }
    }

    handleGoBack() {
        this[NavigationMixin.Navigate]({
            type: "standard__webPage",
            attributes: {
                url: "/"
            }
        });
    }
}