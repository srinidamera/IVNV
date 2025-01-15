import { LightningElement, api, wire, track } from 'lwc';
import { NavigationMixin } from "lightning/navigation";
import getProfileDetails from '@salesforce/apex/ProfileDetailsController.getProfileDetails';
import { getObjectInfo, getPicklistValuesByRecordType } from "lightning/uiObjectInfoApi";
import CONTACT_OBJECT from "@salesforce/schema/Contact";
import FORM_FACTOR from '@salesforce/client/formFactor';

export default class ProfileDetails extends NavigationMixin(LightningElement) {
    
    @api requestSupportBtnLabel;
    @api goBackLabel;

    //Contact tab labels
    @api contactHeadingLabel;
    @api primaryContactLabel;
    @api nameFieldLabel;
    @api suffixLabel;
    @api emailAddressLabel;
    @api phoneNumberLabel;
    @api bestTimeToCallLabel;
    @api preferredLanguageLabel;
    @api relationshipToClientFieldLabel;
    @api coApplicantLabel;

    //Contact Address tab labels
    @api contactAddresssLabel;
    @api streetFieldLabel;
    @api addressLine2FieldLabel;
    @api cityFieldLabel;
    @api stateFieldLabel;
    @api zipCodeFieldLabel;

    //Contact Demographics tab labels
    @api contactDemographicsLabel;
    @api birthdateFieldLabel;
    @api genderFieldLabel;
    @api raceFieldLabel;
    @api ethnicityFieldLabel;
    @api communityFieldLabel;
    @api fluencyInEnglishFieldLabel;
    @api firstTimeHomeBuyerFieldLabel;
    @api householdSizeFieldLabel;
    @api householdTypeFieldLabel;
    @api maritalStatusFieldLabel;
    @api educationFieldLabel;
    @api activeMilitaryFieldLabel;
    @api legallyDisabledFieldLabel;

    //Contact Finances tab labels
    @api contactFinancesLabel;
    @api totalMonthlyIncomeFieldLabel;
    @api householdIncomeFieldLabel;
    @api noOfDependentsFieldLabel;
    @api employmentStatusFieldLabel;
    @api creditScoreFieldLabel;

    @track profileDetails ={
        SeqNo: 0,
        FullName: '',
        FirstName: '',
        MiddleName: '',
        LastName: '',
        Suffix: '',
        EmailAddress: '',
        FormattedPhoneNumber: '',
        BestTimeToCall: '',
        PreferredLanguage: '',
        
        Street: '',
        AddressLine2: '',
        City: '',
        State: '',
        PostaCode: '',

        Birthdate: '',
        Gender: '',
        Race: '',
        Ethnicity: '',
        Community: '',
        FirstTimeHomeBuyer: '',
        FluencyInEnglish: '',
        HouseholdSize: '',
        HouseholdTypeHeadOfHousehold: '',
        MaritalStatus: '',
        Education: '',
        ActiveMilitary: '',
        LegallyDisabled: 'No',

        TotalMonthlyIncome: '',
        HouseholdIncome: '',
        NoOfDependents: '',
        EmploymentStatus: '',
        CreditScore: ''
    }

    @track coApplicants;
    showSpinner = true;
    @track picklistValues;

    alignmentStyle = {
        Left: "slds-grid_align-start",
        Right: "slds-grid_align-end",
        Center: "slds-grid_align-center"
    };
    /*
    @description - fetches loggedin user details and their co-applicant details
    */
    @wire(getProfileDetails)
    userDetails({
        data,
        error
    }) {
        if (data) {
            if(data.primaryContact){
                this.profileDetails = data.primaryContact;
                if(this.picklistValues){
                    let tempContactData = this.prepareContact();
                    this.profileDetails = tempContactData;
                }
            }
            if(data.coApplicants){
                this.coApplicants = data.coApplicants;
                if(this.picklistValues){
                    let tempApplicants = this.prepareApplicant();
                    this.coApplicants  = tempApplicants;
                }
            }
            this.showSpinner = false;
        }
        if (error) {
            console.log('error->' + JSON.stringify(error))
            this.showSpinner = false;
        }
    }

    @wire(getObjectInfo, { objectApiName: CONTACT_OBJECT })
    objectInfo;

    @wire(getPicklistValuesByRecordType, { objectApiName: CONTACT_OBJECT, recordTypeId: '$objectInfo.data.defaultRecordTypeId' })
    picklistValuesHandler({ error, data }) {
        if (data) {
            this.picklistValues = data.picklistFieldValues;
            if(this.profileDetails != {}){
                let tempContactData = this.prepareContact();
                this.profileDetails = tempContactData;
            }
            if(this.coApplicants != {}){
                let tempApplicants = this.prepareApplicant();
                this.coApplicants  = tempApplicants;
            }
        } else if (error) {
            console.log('getPicklistValuesByRecordType error===>', JSON.stringify(error));
            this.error = error;
        }
    }

    prepareContact(){
        let obj = { ...this.profileDetails };
        if(obj){
            obj.BestTimeToCall = this.getSelectedPicklistLabel(this.picklistValues?.Besttimetocontact__c?.values, obj?.BestTimeToCall);
            obj.PreferredLanguage = this.getSelectedPicklistLabel(this.picklistValues?.PreferredLanguage__c?.values, obj?.PreferredLanguage);
            obj.Gender = this.getSelectedPicklistLabel(this.picklistValues?.Gender__c?.values, obj?.Gender);
            obj.Race = this.getSelectedPicklistLabel(this.picklistValues?.Race__c?.values, obj?.Race);
            obj.Ethnicity = this.getSelectedPicklistLabel(this.picklistValues?.Ethnicity__c?.values, obj?.Ethnicity);
            obj.Community = this.getSelectedPicklistLabel(this.picklistValues?.RuralAreaStatus__c?.values, obj?.Community);
            obj.FluencyInEnglish = this.getSelectedPicklistLabel(this.picklistValues?.EnglishProficiency__c?.values, obj?.FluencyInEnglish);
            obj.FirstTimeHomeBuyer = this.getSelectedPicklistLabel(this.picklistValues?.X1stTimeHomeBuyer__c?.values, obj?.FirstTimeHomeBuyer);
            obj.HouseholdTypeHeadOfHousehold = this.getSelectedPicklistLabel(this.picklistValues?.HouseholdType__c?.values, obj?.HouseholdTypeHeadOfHousehold);
            obj.MaritalStatus = this.getSelectedPicklistLabel(this.picklistValues?.MaritalStatus__c?.values, obj?.MaritalStatus);
            obj.Education = this.getSelectedPicklistLabel(this.picklistValues?.Education__c?.values, obj?.Education);
            obj.ActiveMilitary = this.getSelectedPicklistLabel(this.picklistValues?.ActiveMilitary__c?.values, obj?.ActiveMilitary);
            obj.LegallyDisabled = this.getSelectedPicklistLabel(this.picklistValues?.DisabledStatus__c?.values, obj?.LegallyDisabled);
            obj.EmploymentStatus = this.getSelectedPicklistLabel(this.picklistValues?.EmploymentStatus__c?.values, obj?.EmploymentStatus);
            return obj;
        }
    }

    prepareApplicant(){
        if(this.coApplicants){
            let processedApplicants = [];
            let tempApplicants = [...this.coApplicants];
            for(let i = 0; i < tempApplicants.length; i++){
                let obj = { ...tempApplicants[i] };
                obj.BestTimeToCall = this.getSelectedPicklistLabel(this.picklistValues?.Besttimetocontact__c?.values, obj?.BestTimeToCall);
                obj.Gender = this.getSelectedPicklistLabel(this.picklistValues?.Gender__c?.values, obj?.Gender);
                obj.Race = this.getSelectedPicklistLabel(this.picklistValues?.Race__c?.values, obj?.Race);
                obj.Ethnicity = this.getSelectedPicklistLabel(this.picklistValues?.Ethnicity__c?.values, obj?.Ethnicity);
                obj.Community = this.getSelectedPicklistLabel(this.picklistValues?.RuralAreaStatus__c?.values, obj?.Community);
                obj.FluencyInEnglish = this.getSelectedPicklistLabel(this.picklistValues?.EnglishProficiency__c?.values, obj?.FluencyInEnglish);
                obj.Education = this.getSelectedPicklistLabel(this.picklistValues?.Education__c?.values, obj?.Education);
                obj.FirstTimeHomeBuyer = this.getSelectedPicklistLabel(this.picklistValues?.X1stTimeHomeBuyer__c?.values, obj?.FirstTimeHomeBuyer);
                obj.LegallyDisabled = this.getSelectedPicklistLabel(this.picklistValues?.DisabledStatus__c?.values, obj?.LegallyDisabled);
                obj.ActiveMilitary = this.getSelectedPicklistLabel(this.picklistValues?.ActiveMilitary__c?.values, obj?.ActiveMilitary);
                obj.EmploymentStatus = this.getSelectedPicklistLabel(this.picklistValues?.EmploymentStatus__c?.values, obj?.EmploymentStatus);
                obj.PreferredLanguage = this.getSelectedPicklistLabel(this.picklistValues?.PreferredLanguage__c?.values, obj?.PreferredLanguage);
                obj.RelationshipToClient = this.getSelectedPicklistLabel(this.picklistValues?.RelationshipToPrimaryApplicant__c?.values, obj?.RelationshipToClient);
                processedApplicants.push(obj);
            }
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

    /*This utility method to go back to pervious page */
    gotoPage(){
        window.history.back();
    }

    handleRequestSupport(){
        this[NavigationMixin.Navigate]({
            type: "standard__webPage",
            attributes: {
                url: "/contact"
            }
        });
    }

    /*This utility method to show toast notification */
    showToast(event){
        const toast = this.refs.toast;
        toast.showToastMessage({
            title: event.detail.title,
            message: event.detail.message,
            toastVariant: event.detail.variant,
            iconName: event.detail.iconName,
            autoClose: event.detail.autoClose,
            autoCloseTime: event.detail.autoCloseTime,
            mergeFields: {}
        }); 
    }

    get isDesktop() {
        return FORM_FACTOR == 'Large' ? true : false;
    }

    get isMobile() {
        return FORM_FACTOR == 'Small' ? true : false;
    }

    get horizontalAlign(){
        return this.isDesktop ? 'Right' : 'Center';
    }

    get gridStyle() {
        return (
        "slds-grid slds-gutters_xx-small slds-wrap slds-p-top_small " +
        this.alignmentStyle[this.horizontalAlign]
        );
    }
}