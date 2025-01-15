import { LightningElement,api, wire, track } from 'lwc';
import { CurrentPageReference, NavigationMixin } from 'lightning/navigation';
import LANG from "@salesforce/i18n/lang";
import getDesiredServiceRecord from "@salesforce/apex/UserServicesController.getDesiredServiceRecord";
import getEnrolledServiceDetails from "@salesforce/apex/ServiceEnrollmentFormController.getEnrolledServiceDetails";
import getIntakeDetails from '@salesforce/apex/UserServicesController.getIntakeDetails';
import {formatPhoneNumber, convertDateFormat} from'c/lwrUtils';
import { getObjectInfo, getPicklistValuesByRecordType } from "lightning/uiObjectInfoApi";
import CONTACT_OBJECT from "@salesforce/schema/Contact";
import FORM_FACTOR from '@salesforce/client/formFactor';

export default class UserIntakeDetailPage extends NavigationMixin(LightningElement) {
    @track service;
    //@track applicants;
    //@track contact;
    @track enrolledServiceData = {};
    recordId;
    serviceRecordId;
    intakeId;
    clientCasedId;
    badgeLabel;
    badgeStyle;
    @api signUpLabel;
    @api goBackLabel;
    @api servicesLabel;
    @api learnMorebreadCrumbLabel
    @api manageDocumentsLabel;
    @api uploadDocumentsLabel;
    @api contactUsBtnLabel;
    @api builderSubmissionReviewLabel;
    @api builderContactLabel;
    @api builderNameLabel;
    @api builderEmailAddressLabel;
    @api builderPhoneNumberLabel;
    @api builderBestimeToCallLabel;
    @api builderAddressLabel;
    @api builderBirthdateLabel;
    @api builderGenderLabel;
    @api builderRaceLabel;
    @api builderEthnicityLabel;
    @api builderCommunityLabel;
    @api builderFluencyInEnglishLabel;
    @api builderMaritalStatusLabel;
    @api builderEducationLabel;
    @api builder1stTimeHomebuyerLabel;
    @api builderLegallyDisabledLabel;
    @api builderHouseholdSizeLabel;
    @api builderHouseholdTypeLabel;
    @api builderHouseholdTypeOnlyLabel;
    @api builderActiveMilitaryLabel;
    @api builderVeteranStatusLabel;
    @api builderTotalMonthlyIncomeLabel;
    @api builderNumberOfDependentsLabel;
    @api builderEmploymentStatusLabel;
    @api builderCreditScoreLabel;
    @api builderCoApplicantLabel;
    @api builderPreferredCommunicationLanguageLabel;
    @api builderRelationshipToClientLabel;
    @api submittedDateLabel;
    @api viewMyServicesLabel;
    @api labelOpen;
    @api labelCompleted;
    @api labelIncomplete;
    @api labelOnHold;
    viewModeCollapsed = false;
    isShowModal = false;
    picklistValues;

   /* statusToBadgeStyle = Object.freeze({
        New: "slds-badge_inverse badge-width font-weight-700 font-white",
        "On Hold": "bg-yellow badge-width font-weight-700 font-black",
        Converted: "bg-green badge-width font-weight-700 font-white",
        "Closed - Incomplete":
        "slds-badge slds-theme_error badge-width font-weight-700 font-white"
    });
*/

    statusToBadgeStyle = Object.freeze({
        Open: "slds-badge_inverse badge-width font-weight-700",
        "On Hold": "slds-theme_warning  badge-width font-weight-700",
        Completed: "slds-theme_success badge-width font-weight-700",
        Incomplete: "bg-yellow badge-width font-weight-700"
    });

    @wire(getObjectInfo, { objectApiName: CONTACT_OBJECT })
    objectInfo;
    
    @wire(getPicklistValuesByRecordType, { objectApiName: CONTACT_OBJECT, recordTypeId: '$objectInfo.data.defaultRecordTypeId' })
    picklistValuesHandler({ error, data }) {
        if (data) {
            this.picklistValues = data.picklistFieldValues;
            if(this.enrolledServiceData != {}){
                let tempContactData = this.prepareContact();
                this.enrolledServiceData.contact = tempContactData;
                let tempApplicants = this.prepareApplicant();
                this.enrolledServiceData.applicants  = tempApplicants;
            }
        } else if (error) {
            console.log('getPicklistValuesByRecordType error===>', JSON.stringify(error));
            this.error = error;
        }
    }


    /*This method fetches service record id on which user clicked on learn more*/
    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
       if (currentPageReference && currentPageReference.state.iId) {
            //const decodedValues = decodeDefaultFieldValues(currentPageReference.state.sId);
           // if(!this.serviceRecordId){
          //      this.serviceRecordId = decodedValues?.sId;
           // }
            
            this.recordId = currentPageReference?.state?.iId;
            //this.clientCasedId = decodedValues?.cId;
            //this.badgeLabel = decodedValues?.status;
            //console.log('OUTPUT : intakeId',this.intakeId);
       }
    }

    /* @description: This fetches the intake details*/
    @wire(getIntakeDetails, {recordId : '$recordId'})
    wiredGetIntakeDetails({ error, data }) {
        /*const statusToLabel = {
            New: "New",
            "On Hold": "On Hold",
            Converted: "Completed",
            "Closed - Incomplete": "Incomplete"
        };*/
        const statusToLabel = {
            'Open': this.labelOpen,
            'Completed': this.labelCompleted,
            'Incomplete': this.labelIncomplete,
            'On Hold': this.labelOnHold
          };
          
        if (data) {
            let statusLabel ="";
            if (
                data.status ===
                  "Open Intake" ||
                  data.status ===
                  "Open Case" ||
                  data.status ===
                  "In Progress"
              ) {
                statusLabel = "Open";
              } else if (
                data.status ===
                  "Closed - Complete"
              ) {
                statusLabel = "Completed";
              } else if (
                data.status ===
                  "Closed - Incomplete" 
              ) {
                statusLabel = "Incomplete";
              } else if (
                data.status === "On Hold"
              ) {
                statusLabel = "On Hold";
              } else {
                statusLabel = "";
              }
            console.log('intakedetails ==>',JSON.stringify(data));
            this.badgeLabel = statusLabel ? statusToLabel[statusLabel] : '';
            this.badgeStyle = statusLabel ? this.statusToBadgeStyle[statusLabel] : '';
            this.clientCasedId = data && data.caseClientId ? data.caseClientId : '';
            this.serviceRecordId = data && data.serviceId ? data.serviceId : '';
            this.intakeId = data && data.intakeId ? data.intakeId : '';
        } else if (error) {
            console.log('error in getFileTypes->'+JSON.parse(JSON.stringify(error.body.message)));
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

    @wire(getEnrolledServiceDetails, {recordId : "$intakeId"})
    enrolledWire({ error, data }) {
        if (data) {
            console.log('OUTPUT : intakeId',this.intakeId);
            console.log('getEnrolledServiceDetails called>>', JSON.stringify(data));
            let index = 1;
            this.enrolledServiceData.submittedDate = convertDateFormat(data?.SubmittedDate);
            this.enrolledServiceData.contact = this.contact = {...data?.PrimaryContact, Phone : formatPhoneNumber(data?.PrimaryContact?.Phone)};
            this.enrolledServiceData.applicants = data?.CoApplicants?.map(currentItem => {
                let tempContact = { ...currentItem };
                if (tempContact.Phone) {
                    tempContact.Phone = formatPhoneNumber(tempContact?.Phone);
                }
                tempContact.number = index;
                index++;
                return tempContact;
            });
            if(this.picklistValues){
                let tempContactData = this.prepareContact();
                this.enrolledServiceData.contact = tempContactData;
                let tempApplicants = this.prepareApplicant();
                this.enrolledServiceData.applicants  = tempApplicants;
            }
            /*
            let tempApplicants = data?.CoApplicants;
           // this.applicants = data;//this.prepareServices(data.records[0], data.mapping);
            let index = 1;
            this.submittedDate = convertDateFormat(data?.SubmittedDate);
            this.contact = {...data?.PrimaryContact, Phone : formatPhoneNumber(data?.PrimaryContact?.Phone)};
            this.applicants = tempApplicants?.map(currentItem => {
                let tempContact = { ...currentItem };
                if (tempContact.Phone) {
                    tempContact.Phone = formatPhoneNumber(tempContact?.Phone);
                }
                tempContact.number = index;
                index++;
                return tempContact;
            });
            */

        } else if (error) {
            console.error("getEnrolledServiceDetails Error:", error);
        }
    }

    prepareContact(){
        let obj = this.enrolledServiceData.contact;
        if(obj){
            obj.Besttimetocontact__c = this.getSelectedPicklistLabel(this.picklistValues?.Besttimetocontact__c?.values, obj?.Besttimetocontact__c);
            obj.Gender__c = this.getSelectedPicklistLabel(this.picklistValues?.Gender__c?.values, obj?.Gender__c);
            obj.Race__c = this.getSelectedPicklistLabel(this.picklistValues?.Race__c?.values, obj?.Race__c);
            obj.Ethnicity__c = this.getSelectedPicklistLabel(this.picklistValues?.Ethnicity__c?.values, obj?.Ethnicity__c);
            obj.RuralAreaStatus__c = this.getSelectedPicklistLabel(this.picklistValues?.RuralAreaStatus__c?.values, obj?.RuralAreaStatus__c);
            obj.EnglishProficiency__c = this.getSelectedPicklistLabel(this.picklistValues?.EnglishProficiency__c?.values, obj?.EnglishProficiency__c);
            obj.MaritalStatus__c = this.getSelectedPicklistLabel(this.picklistValues?.MaritalStatus__c?.values, obj?.MaritalStatus__c);
            obj.Education__c = this.getSelectedPicklistLabel(this.picklistValues?.Education__c?.values, obj?.Education__c);
            obj.X1stTimeHomeBuyer__c = this.getSelectedPicklistLabel(this.picklistValues?.X1stTimeHomeBuyer__c?.values, obj?.X1stTimeHomeBuyer__c);
            obj.DisabledStatus__c = this.getSelectedPicklistLabel(this.picklistValues?.DisabledStatus__c?.values, obj?.DisabledStatus__c);
            obj.HouseholdType__c = this.getSelectedPicklistLabel(this.picklistValues?.HouseholdType__c?.values, obj?.HouseholdType__c);
            obj.ActiveMilitary__c = this.getSelectedPicklistLabel(this.picklistValues?.ActiveMilitary__c?.values, obj?.ActiveMilitary__c);
            obj.Veteran__c = this.getSelectedPicklistLabel(this.picklistValues?.Veteran__c?.values, obj?.Veteran__c);
            obj.EmploymentStatus__c = this.getSelectedPicklistLabel(this.picklistValues?.EmploymentStatus__c?.values, obj?.EmploymentStatus__c);
            return obj;
        }
    }

    prepareApplicant(){
        if(this.enrolledServiceData.applicants){
            let processedApplicants = this.enrolledServiceData.applicants.map(applicant =>{
                let obj = applicant;
                obj.Besttimetocontact__c = this.getSelectedPicklistLabel(this.picklistValues?.Besttimetocontact__c?.values, obj?.Besttimetocontact__c);
                obj.Gender__c = this.getSelectedPicklistLabel(this.picklistValues?.Gender__c?.values, obj?.Gender__c);
                obj.Race__c = this.getSelectedPicklistLabel(this.picklistValues?.Race__c?.values, obj?.Race__c);
                obj.Ethnicity__c = this.getSelectedPicklistLabel(this.picklistValues?.Ethnicity__c?.values, obj?.Ethnicity__c);
                obj.RuralAreaStatus__c = this.getSelectedPicklistLabel(this.picklistValues?.RuralAreaStatus__c?.values, obj?.RuralAreaStatus__c);
                obj.EnglishProficiency__c = this.getSelectedPicklistLabel(this.picklistValues?.EnglishProficiency__c?.values, obj?.EnglishProficiency__c);
                obj.Education__c = this.getSelectedPicklistLabel(this.picklistValues?.Education__c?.values, obj?.Education__c);
                obj.X1stTimeHomeBuyer__c = this.getSelectedPicklistLabel(this.picklistValues?.X1stTimeHomeBuyer__c?.values, obj?.X1stTimeHomeBuyer__c);
                obj.DisabledStatus__c = this.getSelectedPicklistLabel(this.picklistValues?.DisabledStatus__c?.values, obj?.DisabledStatus__c);
                obj.ActiveMilitary__c = this.getSelectedPicklistLabel(this.picklistValues?.ActiveMilitary__c?.values, obj?.ActiveMilitary__c);
                obj.Veteran__c = this.getSelectedPicklistLabel(this.picklistValues?.Veteran__c?.values, obj?.Veteran__c);
                obj.EmploymentStatus__c = this.getSelectedPicklistLabel(this.picklistValues?.EmploymentStatus__c?.values, obj?.EmploymentStatus__c);
                obj.PreferredLanguage__c = this.getSelectedPicklistLabel(this.picklistValues?.PreferredLanguage__c?.values, obj?.PreferredLanguage__c);
                obj.RelationshipToPrimaryApplicant__c = this.getSelectedPicklistLabel(this.picklistValues?.RelationshipToPrimaryApplicant__c?.values, obj?.RelationshipToPrimaryApplicant__c);
                return obj;
            });
            return processedApplicants;
        }
    }

    getSelectedPicklistLabel(picklistValues, selectedValue){
        if(selectedValue && picklistValues){
            const item = picklistValues.find(entry => entry.value === selectedValue);
            return item ? item.label : '';
        }
        return '';
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
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url: "/SelfRegister"
            }
        });
    }

    handleRequestSupport(){
        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                name: 'Contact__c'
            }
        });
    }

    goToUploadDocument(){
        let stateParams = {};
        stateParams.sId = this.serviceRecordId;
        if (this.intakeId) {
            stateParams.iId= this.intakeId;
        }
        if (this.clientCasedId) {
            stateParams.cId=this.clientCasedId;
        }

        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                name: 'UploadDocuments__c'
            },
            state: {
                ...stateParams
            }
        });
    }

    handleViewMode(){
        this.viewModeCollapsed = !this.viewModeCollapsed;
    }

    get isDesktop() {
        return FORM_FACTOR == 'Large' ? true : false;
    }

    get isMobile() {
        return FORM_FACTOR == 'Small' ? true : false;
    }

    get uploadDocSectionStyle(){
        return this.isDesktop ? 'slds-col slds-size_12-of-12 slds-small-size_12-of-12 slds-medium-size_12-of-12 slds-large-size_4-of-12 slds-p-left_small' : 
                                'slds-col slds-size_12-of-12 slds-small-size_12-of-12 slds-medium-size_12-of-12 slds-large-size_4-of-12 slds-p-top_small';
    }

    get serviceDetailSectionStyle(){
        return this.isEnrolledService ? 'slds-col slds-size_12-of-12 slds-small-size_12-of-12 slds-medium-size_12-of-12 slds-large-size_8-of-12' : 
                                'slds-col slds-size_12-of-12 slds-small-size_12-of-12 slds-medium-size_12-of-12 slds-large-size_12-of-12';
    }

    get goBackBtnStyle(){
        return this.isEnrolledService ? 'slds-col slds-m-top_small slds-p-right_xx-small slds-size_12-of-12 slds-small-size_12-of-12 slds-medium-size_12-of-12 slds-large-size_12-of-12' : 
                                'slds-col slds-m-top_small slds-p-right_xx-small slds-size_6-of-12 slds-small-size_6-of-12 slds-medium-size_6-of-12 slds-large-size_6-of-12';
    }

    get isEnrolledService(){
        return this.intakeId || this.clientCasedId;
    }

    get serviceNameLabelBreadCrumb(){
        return this.learnMorebreadCrumbLabel + ' ' + ((this.service && this.service.Name) ? this.service.Name : '');
    }

    get serviceName(){
        return this.service.Name + ' '+ this.builderSubmissionReviewLabel;
    }


    toggleModal(){
        this.isShowModal = !this.isShowModal;
    }

    /* @description: getter for check device type*/
  get getModalSize() {
    switch (FORM_FACTOR) {
      case "Large":
        return "slds-modal slds-fade-in-open slds-modal_small";
      case "Medium":
        return "slds-modal slds-fade-in-open";
      case "Small":
        return "slds-modal slds-fade-in-open slds-modal_full";
      default:
    }
  }


  // navigate to Contact Us page
  navigateToContact() {
    this[NavigationMixin.Navigate]({
      type: "standard__webPage",
      attributes: {
        url: "/contact"
      }
    });
  }
}