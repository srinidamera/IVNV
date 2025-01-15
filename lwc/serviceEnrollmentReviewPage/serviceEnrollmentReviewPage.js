import { LightningElement, api, track, wire } from 'lwc';
import { formatPhoneNumber } from 'c/lwrUtils';
import { getObjectInfo, getPicklistValuesByRecordType } from "lightning/uiObjectInfoApi";
import CONTACT_OBJECT from "@salesforce/schema/Contact";
export default class ServiceEnrollmentReviewPage extends LightningElement {
    @track applicantData;
    @track contactData;
    @api service;
    @api labels;
   // coApplicantIndexing = 1;
    @api
    set contact(value) {
        if (value) {
            let tempContact = { ...value };
            tempContact.Phone = formatPhoneNumber(tempContact.Phone);
            this.contactData = tempContact;
            if(this.picklistValues){
                let dummyContact = this.prepareContact();
                this.contactData = dummyContact;
            }
        }
    }

    get contact() {
        return this.contactData;
    }
/*
    get coApplicantIndex(){
        console.log('in get conapp ==> ', this.coApplicantIndexing);
        return this.coApplicantIndexing++;
    }*/

    @api
    set applicants(value) {
       // this.coApplicantIndexing = 1;
        //console.log('this.coApplicantIndexing  ==>',this.coApplicantIndexing );
        let tempApplicantsData = value;
        console.log('tempApplicantsData===>'+JSON.stringify(tempApplicantsData));
        let i = 1;
        this.applicantData = tempApplicantsData.map(currentItem => {
            let tempContact = { ...currentItem };
            if (tempContact.Phone) {
                tempContact.Phone = formatPhoneNumber(tempContact.Phone);
            }if(tempContact.selected){
                tempContact.coApplicantIndex = i;
                i++;
            }
            return tempContact;
        });
        console.log('applicantData===>'+JSON.stringify(this.applicantData));
        if(this.picklistValues){
            let dummyApplicantData = this.prepareApplicant();
            this.applicantData = dummyApplicantData;
        }
    }

    get applicants() {
        return this.applicantData;
    }

     get showCoApplicantDetails() {
        let filteredData = this.applicantData.filter(item => item.selected);
        return filteredData.length > 0;
    }

    picklistValues;
    @wire(getObjectInfo, { objectApiName: CONTACT_OBJECT })
    objectInfo;

    @wire(getPicklistValuesByRecordType, { objectApiName: CONTACT_OBJECT, recordTypeId: '$objectInfo.data.defaultRecordTypeId' })
    picklistValuesHandler({ error, data }) {
        if (data) {
            this.picklistValues = data.picklistFieldValues;
            if(this.contactData != {} && this.contactData){
                let tempContactData = this.prepareContact();
                this.contactData = tempContactData;
            } 
            if(this.applicantData != {} && this.applicantData){
                let tempApplicants = this.prepareApplicant();
                this.applicantData  = tempApplicants;
            }
        } else if (error) {
            console.log('getPicklistValuesByRecordType error===>', JSON.stringify(error));
            this.error = error;
        }
    }

    prepareContact(){
        let obj = this.contactData;
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
        if(this.applicantData){
            let processedApplicants = this.applicantData.map(applicant =>{
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
}