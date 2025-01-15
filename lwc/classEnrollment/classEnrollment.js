import { LightningElement, track, wire, api } from 'lwc';
import { CurrentPageReference, NavigationMixin } from 'lightning/navigation';
import LANG from "@salesforce/i18n/lang";
import getCourseName from "@salesforce/apex/EnrollmentFormController.getCourseName";
import updateRecords from "@salesforce/apex/EnrollmentFormController.updateRecords";
import { formatDate } from "c/lwrUtils";
export default class ClassEnrollment extends NavigationMixin (LightningElement) {
    finalPageContentStore
    @api builderClassesLabel;
    @api builderEnrollmentLabel;
    @api builderClassEnrollmentLabel;
    @api builderEnterYourInformationLabel;
    @api builderStagesLabel;
    @api builderIndicatesRequiredFieldLabel;
    @api builderCreateNewCoApplicantLabel;
    @api builderCancelLabel;
    @api builderSaveLabel;
    @api builderGoBackLabel;
    @api builderNextLabel;
    @api builderSubmitLabel;
    @api builderDoneLabel;
    @api builderContactInformationLabel;
    @api builderFullNameLabel;
    @api builderEmailAddressLabel;
    @api builderPhoneNumberLabel;
    @api builderPhoneLabel;
    @api builderBestimeToCallLabel;
    @api builderPreferredCommunicationLanguageLabel;
    @api builderRelationshipToClientLabel;
    @api builderPhoneNumberValidationLabel;
    @api builderBirthdateValidationLabel;
    @api builderAddressLabel;
    @api builderStreetLabel;
    @api builderAddressLine2Label;
    @api builderCityLabel;
    @api builderStateProvinceLabel;
    @api builderZipPostalCodeLabel;
    @api builderDemographicsLabel;
    @api builderBirthdateLabel;
    @api builderGenderLabel;
    @api builderEthnicityLabel;
    @api builderRaceLabel;
    @api builderCommunityLabel;
    @api builderVeteranStatusLabel;
    @api buildChoseNottoProvideIncomeLabel;
    @api builderCommunityHelpTextLabel;
    @api builderFluencyInEnglishLabel;
    @api builder1stTimeHomebuyerLabel;
    @api builderHouseholdSizeLabel;
    @api builderHouseholdTypeLabel;
    @api builderMaritalStatusLabel;
    @api builderEducationLabel;
    @api builderActiveMilitaryLabel;
    @api builderLegallyDisabledLabel;
    @api builderFinancesLabel;
    @api builderCurrentHouseHoldGrossMonthlyIncomeLabel;
    @api builderSelectExistingCoApplicantsLabel;
    @api builderOptionsSelectedLabel;
    @api builderViewDetailsLabel;
    @api builderCoApplicantsSelectedLabel;
    @api builderCoApplicantsSelectedOptionCountLabel;
    @api builderEnterCoApplicantInformationLabel;
    @api builderCoApplicantInformationLabel;
    @api builderFirstNameLabel;
    @api builderMiddleNameLabel;
    @api builderLastNameLabel;
    @api builderSuffixLabel;
    @api builderHouseHoldMonthlyIncomeLabel;
    @api builderTotalMonthlyIncomeLabel;
    @api builderHouseholdIncomeLabel;
    @api builderNumberOfDependentsLabel;
    @api builderEmploymentStatusLabel;
    @api builderCreditScoreLabel;
    @api builderSameAsPrimaryContactLabel;
    @api builderYesLabel;
    @api builderNoLabel;
    @api builderRemoveCoApplicantLabel;
    @api builderContactSavedToMyProfileLabel;
    @api builderCoApplicantRemovedLabel;
    @api builderRemoveCoApplicantConfirmationLabel;
    @api builderReviewDetailsLabel;
    @api builderClassDetailsLabel;
    @api builderClassNameLabel;
    @api builderShortDescriptionLabel;
    @api builderStartDateLabel;
    @api builderLocationLabel;
    @api builderPrimaryContactDetailsLabel;
    @api builderNameLabel;
    @api builderCoApplicantDetailsLabel;
    @api builderEnrollmentSuccessfulLabel;
    @api builderDeleteUnsavedChangesLabel;
    @api builderDeleteUpdatesLabel;
    @api finalPageContent;
    @api enterOnly5DigitNumbersLabel;

    get labels() {
        return {
            builderClassesLabel: this.builderClassesLabel,
            builderEnrollmentLabel: this.builderEnrollmentLabel,
            builderClassEnrollmentLabel: this.builderClassEnrollmentLabel,
            builderEnterYourInformationLabel: this.builderEnterYourInformationLabel,
            builderIndicatesRequiredFieldLabel: this.builderIndicatesRequiredFieldLabel,
            builderCreateNewCoApplicantLabel: this.builderCreateNewCoApplicantLabel,
            builderCancelLabel: this.builderCancelLabel,
            builderSaveLabel: this.builderSaveLabel,
            builderGoBackLabel: this.builderGoBackLabel,
            builderNextLabel: this.builderNextLabel,
            builderSubmitLabel: this.builderSubmitLabel,
            builderDoneLabel: this.builderDoneLabel,
            builderContactInformationLabel: this.builderContactInformationLabel,
            builderFullNameLabel: this.builderFullNameLabel,
            builderEmailAddressLabel: this.builderEmailAddressLabel,
            builderPhoneNumberLabel: this.builderPhoneNumberLabel,
            builderPhoneLabel: this.builderPhoneLabel,
            builderBestimeToCallLabel: this.builderBestimeToCallLabel,
            builderPreferredCommunicationLanguageLabel: this.builderPreferredCommunicationLanguageLabel,
            builderRelationshipToClientLabel: this.builderRelationshipToClientLabel,
            builderPhoneNumberValidationLabel: this.builderPhoneNumberValidationLabel,
            builderBirthdateValidationLabel: this.builderBirthdateValidationLabel,
            builderAddressLabel: this.builderAddressLabel,
            builderStreetLabel: this.builderStreetLabel,
            builderAddressLine2Label: this.builderAddressLine2Label,
            builderCityLabel: this.builderCityLabel,
            builderStateProvinceLabel: this.builderStateProvinceLabel,
            builderZipPostalCodeLabel: this.builderZipPostalCodeLabel,
            builderDemographicsLabel: this.builderDemographicsLabel,
            builderBirthdateLabel: this.builderBirthdateLabel,
            builderGenderLabel: this.builderGenderLabel,
            builderEthnicityLabel: this.builderEthnicityLabel,
            builderRaceLabel: this.builderRaceLabel,
            builderCommunityLabel: this.builderCommunityLabel,
            builderVeteranStatusLabel: this.builderVeteranStatusLabel,
            buildChoseNottoProvideIncomeLabel: this.buildChoseNottoProvideIncomeLabel,
            builderCommunityHelpTextLabel: this.builderCommunityHelpTextLabel,
            builderFluencyInEnglishLabel: this.builderFluencyInEnglishLabel,
            builder1stTimeHomebuyerLabel: this.builder1stTimeHomebuyerLabel,
            builderHouseholdSizeLabel: this.builderHouseholdSizeLabel,
            builderHouseholdTypeLabel: this.builderHouseholdTypeLabel,
            builderMaritalStatusLabel: this.builderMaritalStatusLabel,
            builderEducationLabel: this.builderEducationLabel,
            builderActiveMilitaryLabel: this.builderActiveMilitaryLabel,
            builderLegallyDisabledLabel: this.builderLegallyDisabledLabel,
            builderFinancesLabel: this.builderFinancesLabel,
            builderCurrentHouseHoldGrossMonthlyIncomeLabel: this.builderCurrentHouseHoldGrossMonthlyIncomeLabel,
            builderSelectExistingCoApplicantsLabel: this.builderSelectExistingCoApplicantsLabel,
            builderOptionsSelectedLabel: this.builderOptionsSelectedLabel,
            builderViewDetailsLabel: this.builderViewDetailsLabel,
            builderCoApplicantsSelectedLabel: this.builderCoApplicantsSelectedLabel,
            builderCoApplicantsSelectedOptionCountLabel: this.builderCoApplicantsSelectedOptionCountLabel,
            builderEnterCoApplicantInformationLabel: this.builderEnterCoApplicantInformationLabel,
            builderCoApplicantInformationLabel: this.builderCoApplicantInformationLabel,
            builderFirstNameLabel: this.builderFirstNameLabel,
            builderMiddleNameLabel: this.builderMiddleNameLabel,
            builderLastNameLabel: this.builderLastNameLabel,
            builderSuffixLabel: this.builderSuffixLabel,
            builderHouseHoldMonthlyIncomeLabel: this.builderHouseHoldMonthlyIncomeLabel,
            builderTotalMonthlyIncomeLabel: this.builderTotalMonthlyIncomeLabel,
            builderHouseholdIncomeLabel: this.builderHouseholdIncomeLabel,
            builderNumberOfDependentsLabel: this.builderNumberOfDependentsLabel,
            builderEmploymentStatusLabel: this.builderEmploymentStatusLabel,
            builderCreditScoreLabel: this.builderCreditScoreLabel,
            builderSameAsPrimaryContactLabel: this.builderSameAsPrimaryContactLabel,
            builderYesLabel: this.builderYesLabel,
            builderNoLabel: this.builderNoLabel,
            builderRemoveCoApplicantLabel: this.builderRemoveCoApplicantLabel,
            builderContactSavedToMyProfileLabel: this.builderContactSavedToMyProfileLabel,
            builderCoApplicantRemovedLabel: this.builderCoApplicantRemovedLabel,
            builderRemoveCoApplicantConfirmationLabel: this.builderRemoveCoApplicantConfirmationLabel,
            builderReviewDetailsLabel: this.builderReviewDetailsLabel,
            builderClassDetailsLabel: this.builderClassDetailsLabel,
            builderClassNameLabel: this.builderClassNameLabel,
            builderShortDescriptionLabel: this.builderShortDescriptionLabel,
            builderStartDateLabel: this.builderStartDateLabel,
            builderLocationLabel: this.builderLocationLabel,
            builderPrimaryContactDetailsLabel: this.builderPrimaryContactDetailsLabel,
            builderNameLabel: this.builderNameLabel,
            builderCoApplicantDetailsLabel: this.builderCoApplicantDetailsLabel,
            builderEnrollmentSuccessfulLabel: this.builderEnrollmentSuccessfulLabel,
            builderDeleteUnsavedChangesLabel: this.builderDeleteUnsavedChangesLabel,
            builderDeleteUpdatesLabel: this.builderDeleteUpdatesLabel,
            enterOnly5DigitNumbersLabel: this.enterOnly5DigitNumbersLabel,
        };
    }
    @track stages;

    prepareStage() {
        return this.builderStagesLabel.split(',').map((item, index) => ({
            currentStepName: item,
            currentStepApiName: item,
            isCompleted: false,
            isCurrent: index == 0,
            isDue: index != 0,
        }));
    }

    connectedCallback() {
        this.stages = this.prepareStage();
    }

    @track currentStepIndex = 0;
    @track courseId;
    @track courseRecord;
    @track showSpinner;
    @track formData = {};

    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        if (currentPageReference) {
            this.courseId = currentPageReference.state?.Id;
        }
    }

    @wire(getCourseName, { recordId: "$courseId" })
    wiredData({ error, data }) {
        if (data && data.record) {
            let userLanguageMapping = (LANG === 'en-US') ? data?.mapping?.English : data?.mapping?.Spanish;
            this.courseRecord = { Name: data?.record[userLanguageMapping?.Name] };
            this.courseRecord = { ...this.courseRecord, Description: data?.record[userLanguageMapping?.Description] };
            this.courseRecord = { ...this.courseRecord, StartDate: formatDate(data?.record[userLanguageMapping?.StartDate]) };
            this.courseRecord = { ...this.courseRecord, Location: data?.record?.sumoapp__Location__r?.[userLanguageMapping?.Location] };
        } else if (error) {
            console.error("getCourseName Error:", error);
        }
    }
    
    handlePrevious() {
        if (this.stages[this.currentStepIndex].currentStepApiName === this.stages[0].currentStepApiName) { // Profile
            this.currentStepIndex--;
            this.transformSteps();
        }
        else if (this.stages[this.currentStepIndex].currentStepApiName === this.stages[1].currentStepApiName) {// Co-Applicant
            let response = this.template.querySelector('c-class-enrollment-co-applicant-form').handlePrevious();
            this.formData = { ...this.formData, 'applicants': response.applicants }
            this.currentStepIndex--;
            this.transformSteps();
        }
        else if (this.stages[this.currentStepIndex].currentStepApiName === this.stages[2].currentStepApiName) { //'Review
            this.currentStepIndex--;
            this.transformSteps();
        }
        else {
            this.currentStepIndex--;
            this.transformSteps();
        }
    }

    handleNext() {
        
        if (this.stages[this.currentStepIndex].currentStepApiName === this.stages[0].currentStepApiName) {
            let response = this.template.querySelector('c-class-enrollment-profile-form').handleNext();
            if (response?.allValid) {
                this.currentStepIndex++;
                this.transformSteps();
                this.formData = { ...this.formData, 'contact': response.contact }
                const toast = this.refs.toast;
                toast.showToastMessage({
                    title: this.builderContactSavedToMyProfileLabel,
                    message: '',    
                    toastVariant: 'theme',
                    iconName: 'standard:task2',
                    autoClose: true,
                    autoCloseTime: 2000,
                    mergeFields: {}
                });
            }
        }
        else if (this.stages[this.currentStepIndex].currentStepApiName === this.stages[1].currentStepApiName) {
            let response = this.template.querySelector('c-class-enrollment-co-applicant-form').handleNext();
            this.formData = { ...this.formData, 'applicants': response.applicants }
            this.currentStepIndex++;
            this.transformSteps();
        }
        else if (this.stages[this.currentStepIndex].currentStepApiName === this.stages[3].currentStepApiName) {
            this.currentStepIndex++;
            this.transformSteps();
        }
        else {
            this.currentStepIndex++;
            this.transformSteps();
        }
    }

    handleSave() {
        this.showSpinner = true;
        let tempPrimaryContact = { ...this.formData.contact };
        if (tempPrimaryContact.Phone) {
            tempPrimaryContact.Phone = tempPrimaryContact.Phone.replace(/[^\d]/g, ''); // Retain only digits
        }
        delete tempPrimaryContact.Name;
        updateRecords({ primaryContact: tempPrimaryContact, applicants: this.removeNonSalesforceMembers(this.formData.applicants), courseId: this.courseId })
            .then((result) => {
                this.showSpinner = false;
                this.currentStepIndex++;
            }).catch((err) => {
                this.showSpinner = false;
                const toast = this.refs.toast;
                toast.showToastMessage({
                    title: err.body.message,
                    message: '',    
                    toastVariant: 'error',
                    iconName: 'utility:error',
                    autoClose: true,
                    autoCloseTime: 2000,
                    mergeFields: {}
                });
            });
    }


    removeNonSalesforceMembers(applicants) {
        return applicants
            .filter(obj => obj.selected)
            .map(obj => {
                const { Name, uniqueId, selected, ...newObj } = obj;
                return newObj;
            });
    }


    transformSteps() {
        let currIndex = this.currentStepIndex;
        let newStages = [];
        for (let i = 0; i < this.stages.length; i++) {
            if (i === currIndex) {
                newStages.push({ ...this.stages[i], isCurrent: true, isCompleted: false, isDue: false })
            }

            else if (i > currIndex) {
                newStages.push({ ...this.stages[i], isCurrent: false, isCompleted: false, isDue: true })
            }
            else {
                newStages.push({ ...this.stages[i], isCurrent: false, isCompleted: true, isDue: false })
            }
        }

        this.stages = newStages;
    }


    get showProfilePage() {
        return this.stages[this.currentStepIndex]?.currentStepApiName === this.stages[0]?.currentStepApiName;
    }

    get showCancelButton() {
        return this.stages[this.currentStepIndex]?.currentStepApiName === this.stages[0]?.currentStepApiName; //|| this.currentStepIndex === 2;
    }

    get isFinalPage() {//showDoneButton
        return this.currentStepIndex === 3;
    }

    get showCoApplicantsPage() {
        return this.stages[this.currentStepIndex]?.currentStepApiName === this.stages[1]?.currentStepApiName;
    }
    get showReviewPage() {
        return this.stages[this.currentStepIndex]?.currentStepApiName === this.stages[2]?.currentStepApiName;
    }

    get showReuiredFieldDes(){
        if(this.currentStepIndex === 2){
            return false;
        }
        return true;
    }

    showToast(event) {
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

    openNewApplicantModal() {
        this.template.querySelector("c-class-enrollment-co-applicant-form").handleNewApplicant();
    }

    handleDone(){
        this[NavigationMixin.Navigate]({
        type: "standard__webPage",
        attributes: {
          url: "/classes?isActive=" + true
        }
      });
    }

    navigateToClasses(){
        this[NavigationMixin.Navigate]({
            type: "standard__webPage",
            attributes: {
              url: "/classes"
            }
          });
    }
}