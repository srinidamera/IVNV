import { LightningElement,api, wire, track } from 'lwc';
import { CurrentPageReference, NavigationMixin } from 'lightning/navigation';
import LANG from "@salesforce/i18n/lang";
import getDesiredServiceRecord from "@salesforce/apex/UserServicesController.getDesiredServiceRecord";
import isguest from "@salesforce/user/isGuest";

export default class UserServicesTabSection extends NavigationMixin(LightningElement) {
    @track service;
    serviceRecordId;
    @api signUpLabel;
    @api goBackLabel;
    @api servicesLabel;
    @api learnMorebreadCrumbLabel;

    /*This method fetches service record id on which user clicked on learn more*/
    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
       if(currentPageReference && currentPageReference.state) {
            this.serviceRecordId = currentPageReference.state.sId;
       }
    }

    /*This method fetches desired services data from the CaseType__c Object */
    @wire(getDesiredServiceRecord, {recordId : "$serviceRecordId"})
    wiredData({ error, data }) {
        if (data && data.records && data.records.length > 0) {
            this.service = this.prepareServices(data.records[0], data.mapping);
        } else if (error) {
            console.error("getDesiredServices Error:", error);
        }
    }

    /*Prepares the service data for rendering based on the device type and language. */
    prepareServices(service, fieldMappings) {
        if (!service) {
            return;
        }
        
        let userLanguageMapping = (LANG === 'en-US') ? fieldMappings.English : fieldMappings.Spanish;
        let serviceTemp = {Name: service[userLanguageMapping.Name], 
                            Description: service[userLanguageMapping.Description], 
                            FAQ: service[userLanguageMapping.FAQ],
                            ShortDescription: service[userLanguageMapping.ShortDescription],
                            Highlights: service[userLanguageMapping.Highlights],
                            RequiredDocuments: service[userLanguageMapping.RequiredDocuments]};
        return serviceTemp;
    }

    /*This utility method to go back to service record */
    handleGoBack(){
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url: '/service'
            }
        });
    }
    /*Navigates to the registration page when triggered, directing users to a self-registration page with a previous parameter indicating the source. */
  redirectToRegister(e) { 
    if (isguest) {
      this[NavigationMixin.Navigate]({
        type: "standard__webPage",
        attributes: {
          url: "/SelfRegister?previous=service"
        }
      });
    } else {
      this[NavigationMixin.Navigate]({
        type: "standard__webPage",
        attributes: {
          url: "/service-enrollment?Id=" + this.serviceRecordId
        }
      });
    }
  }
}