import { LightningElement, wire, api, track } from "lwc";
import { NavigationMixin } from "lightning/navigation";
//import getDesiredServices from "@salesforce/apex/CommunityUserController.getDesiredServices";
import getDesiredServicesOptions from "@salesforce/apex/CommunityUserController.getDesiredServicesOptions";
import insertCommunityContact from "@salesforce/apex/CommunityUserController.insertCommunityContact";
import getAgencyName from "@salesforce/apex/CommunityUserController.getAgencyName";
import { getPicklistValues } from "lightning/uiObjectInfoApi";
import { getObjectInfo } from "lightning/uiObjectInfoApi";
import CONTACT_OBJINFO from "@salesforce/schema/Contact";
import HDYHAUField_FIELD from "@salesforce/schema/Contact.ReferralSource__c";
import { CurrentPageReference } from "lightning/navigation";
import basePath from "@salesforce/community/basePath";
import LANG from "@salesforce/i18n/lang";
import lwrModal from "c/lwrModal";
import siteId from "@salesforce/site/Id";
import { getContent } from "experience/cmsDeliveryApi";
import { replaceStrings, isValidValue, formatPhoneNumber, isValidPhoneNumber, isValidEmail, getSuffixOptions } from "c/lwrUtils";
import getAgencyProfileDetails from '@salesforce/apex/FooterController.getAgencyProfileDetails';
import BESTTIMETOCALL_FIELD from '@salesforce/schema/Contact.Besttimetocontact__c';
import PREFLANG_FIELD from '@salesforce/schema/Contact.PreferredLanguage__c';
import CompassSuffix from "@salesforce/label/c.CompassSuffix";
 
export default class UserRegisterForm extends NavigationMixin(
  LightningElement
) {
  @api signUpTitle;
  @api learnMoreLinkTitle; //no use
  @api description;
  @api firstNameLabel;
  @api preferredLanguage;
  @api middleNameLabel;
  @api suffixLabel;
  @api bestTimeToCallLabel;
  @api lastNameLabel;
  @api emailAddressLabel;
  @api confirmEmailAddressLabel;
  @api phoneNumberLabel;
  @api desiredServiceLabel;
  @api howDidYouHearLabel;
  @api pleaseSpecifylabel;
  @api reviewElectronicLabel;
  @api createNewAccountLabel;
  @api goBackLabel;
  @api loginwithExistingAccountLabel;
  @api invalidEmailFormat;
  @api emailAddressNotMatchWarning;
  @api phoneNumberDigitWarning;
  @api userExistErrorMessage;
  @api electronicConsentDeclineButtonTitle;
  @api electronicConsentAcceptButtonTitle;
  @api disclousureConsentError;
  @api reviewElectronicConsentText;
  @api electronicContentDisclosure;
  @api electronicContentDisclosureHeader;
  /* Buttons */

  /* Field labels */

  /* Error/Warning Messages */

  /* Initial Toast */
  @api initialToastPopupLabel;
  @api initialToastPopupDescription;

  /* Confirmation Screen */
  @api confirmationTitle;
  @api confirmationDescriptionKey;
  @api confirmationScrBtnLabel;
  confirmationDescription;
  disclosureContent = "";
  formattedPhoneNumber = "";
  selectedDesiredServices;
  selectedHearAboutUs;
  isCreateButtonDisabled = true;
  disclosureCheck = false;
  otherSpecifySection = false;
  desiredServices = [];
  howDidYouHearOptions = [];
  bestTimeToCallOptions = [];
  preferredLanguageOptions = [];
  pleaseVerifyText;
  contactRecord = { sobjectType: "Contact" };
  signUpFinished = false;
  previousPage;
  preferrdLangVal = 'English';
  suffixVal = '';
  bestTimeToCallVal = '';
  reviewDisclousuresAccepted = true;
  agencyProfileDetails;
  @wire(getAgencyName)
  userAgencyName;

  @wire(getContent, {
    channelOrSiteId: siteId,
    contentKeyOrId: "$confirmationDescriptionKey"
  })
  getConfirmationDescription(result) {
    if (result?.data?.contentBody?.Value) {
      this.confirmationDescription = result.data.contentBody.Value;
    }
  }

  /* This method will the  */
  showIntialToast() {
    const toast = this.refs.toast;
    toast.showToastMessage({
      title: this.initialToastPopupLabel,
      message: this.initialToastPopupDescription,
      toastVariant: "info",
      // iconName: "action:check",
      iconName: "standard:task2",
      autoClose: false,
      autoCloseTime: 3000,
      mergeFields: {}
    });
  }

  /*This method fetches desired services data from the CaseType__c Object and maps it to 
        label-value pairs for storage in the component's state variable. */
  @wire(getDesiredServicesOptions, { language :  LANG})
  wiredData({ error, data }) {
    if (data) {
      this.desiredServices = data.map((desire) => {
        return { label: desire.label, value: desire.label };
      });
    } else if (error) {
      console.error("getDesiredServicesOptions Error:", error);
    }
  }

  /*These methods wire data from Salesforce for contact information and picklist values for the "How Did You Hear" field, 
    populating respective variables in the component */
  @wire(getObjectInfo, {
    objectApiName: CONTACT_OBJINFO
  })
  contactInfo;
  @wire(getPicklistValues, {
    recordTypeId: "$contactInfo.data.defaultRecordTypeId",
    fieldApiName: HDYHAUField_FIELD
  })
  hdyhauPicklistValues({ error, data }) {
    if (data) {
      //console.log('hdyhauPicklistValues data.values', JSON.stringify(data.values));
      this.howDidYouHearOptions = data.values.map((option) => {
        return { label: option.label, value: option.value };
      });
    } else if (error) {
    }
  }

  /*This method handles changes in the phone number input field. It formats the input value, validates it, 
    sets custom validity if it's not valid, updates the formatted value in the input field, and reports validity.*/
  handlePhoneNumberChange(event) {
    let inputValue = event.target.value.replace(/\D/g, ""); // Remove non-numeric characters
    let formattedValue = formatPhoneNumber(inputValue);
    let phonefield = this.template.querySelector(".phone-field");
    if (!isValidValue(inputValue)) {
      phonefield.setCustomValidity("");
    } else if (!isValidPhoneNumber(inputValue)) {
      phonefield.setCustomValidity(this.phoneNumberDigitWarning);
    } else {
      phonefield.setCustomValidity("");
    }
    this.formattedPhoneNumber = formattedValue; // Update the input field with the formatted value
    phonefield.value = formattedValue;
    phonefield.reportValidity();
    this.validateInputValues();
  }
 
  /*Redirects users to the community login page. */
  redirectToLoginPage() {
    this[NavigationMixin.Navigate]({
      type: "standard__webPage",
      attributes: {
        url: "/login?previous=SelfRegister" // Replace this with the actual URL of your community's Forget Password page
      }
    });
  }

  /*Redirects users to the community login page. */
  redirectToServicesPage() {
    this[NavigationMixin.Navigate]({
      type: "standard__webPage",
      attributes: {
        url: "/service?previous=SelfRegister" // Replace this with the actual URL of your community's Forget Password page
      }
    });
  }
  goBackPreviousPage() {
    if (this.previousPage == "login") {
      this.redirectToLoginPage();
    } else if (this.previousPage == "Home") {
      window.location.href = `https://${location.host}${basePath}/`;
    } else if (this.previousPage == "service") {
      this.redirectToServicesPage();
    } else {
      window.location.href = `https://${location.host}${basePath}/`;
    }
  }

  /* This method will call the server apex method to create a Contact record */
  handleCreateAccount() {
    //console.log("this.userExistErrorMessage", this.userExistErrorMessage);
    //console.log("this.emailAddressLabel ", this.emailAddressLabel);
    this.isCreateButtonDisabled = true;
    this.prepareContactRecord();
    insertCommunityContact({
      contactRecord: this.contactRecord,
      localLanguage: this.getCurrentLanguge()
    })
      .then((result) => {
        console.log("Result", result);
        this.signUpFinished = true;
      })
      .catch((error) => {
        console.error("Error:", error);
        if (
          error &&
          error.body &&
          error.body.message &&
          error.body.message.includes("User with this email already exists.")
        ) {
          let emailAddress = this.template.querySelector(".email-address");
          //console.log("this.userExistErrorMessage", this.userExistErrorMessage);
          emailAddress.setCustomValidity(this.userExistErrorMessage);
          emailAddress.reportValidity();
        }
        else if(error.body.message){
          this.isCreateButtonDisabled = false;
          const toast = this.refs.toast;
          toast.showToastMessage({
            title: 'Error',
            message: error.body.message,
            toastVariant: "error",
            // iconName: "action:check",
            iconName: "action:delete",
            autoClose: true,
            autoCloseTime: 2000,
            mergeFields: {}
          });
        }
      });
  }

  getCurrentLanguge() {
    return LANG == "en-US" ? "en_US" : LANG;
  }

  /*This method will prepare the contact payload to send in apex method */
  prepareContactRecord() {
    this.contactRecord.FirstName = this.refs.firstName.value;
    this.contactRecord.LastName = this.refs.lastName.value;
    this.contactRecord.Email = this.refs.emailField.value;
    this.contactRecord.Phone = isValidValue(this.refs.phonefield.value)
      ? this.refs.phonefield.value.replace(/\D/g, "")
      : "";
      
    this.contactRecord.DesiredService__c = this.selectedDesiredServices;
    this.contactRecord.ReferralSource__c = this.selectedHearAboutUs;
    this.contactRecord.PleaseSpecify__c = this.pleaseVerifyText;
    this.contactRecord.ReviewDisclosuresforElectronicConsent__c = this.disclosureCheck;

    this.contactRecord.MiddleName = this.refs.middleName.value;
    this.contactRecord.PreferredLanguage__c = this.preferrdLangVal;
    this.contactRecord.Suffix = this.suffixVal;
    this.contactRecord.Besttimetocontact__c = this.bestTimeToCallVal;
   
  }

  /*This method validates input values for a form and enables a button if all conditions are met; 
    otherwise, it disables the button. */
  validateInputValues() {
    if (
      isValidValue(this.refs.firstName.value) &&
      isValidValue(this.refs.lastName.value) &&
      isValidEmail(this.refs.emailField.value) &&
      (!isValidValue(this.refs.phonefield.value) ||
        isValidPhoneNumber(
          this.refs.phonefield.value.replace(/\D/g, "")
        )) &&
      //this.isValidPhoneNumber(this.refs.phonefield.value.replace(/\D/g, "")) &&
      isValidValue(this.selectedDesiredServices) &&
      isValidValue(this.selectedHearAboutUs) &&
      this.disclosureCheck &&
      this.refs.emailField.value == this.refs.confirmEmailField.value &&
      (!this.otherSpecifySection ||
        (this.otherSpecifySection &&
          isValidValue(this.pleaseVerifyText))) &&
      this.reviewDisclousuresAccepted
    ) {
      //&& this.isValidValue(this.refs.spesifyfield.value)
      this.isCreateButtonDisabled = false;
      return;
    }
    this.isCreateButtonDisabled = true;
  }

  handleDesiredSerChange(event) {
    this.selectedDesiredServices = event.detail.value;
    this.validateInputValues();
  }

  handleSuffixChange(event){
    this.suffixVal = event.detail.value;
    this.validateInputValues();
  }

  handlePreferredLanguageChange(event){
    this.preferrdLangVal = event.detail.value;
    this.validateInputValues();
  }

  handleBestTimeToCallChange(event){
    this.bestTimeToCallVal = event.detail.value;
    this.validateInputValues();
  }

  /*This method will check, if user select Others in How did you hear about us field, 
    then another field will be visible to put the other description */
  handleHearAboutUsChange(event) {
    this.selectedHearAboutUs = event.detail.value;
    if (event.detail.value == "Other") {
      this.otherSpecifySection = true;
    } else {
      this.pleaseVerifyText = "";
      this.otherSpecifySection = false;
    }
    this.validateInputValues();
  }
  handleDisclosureCheck(event) {
    this.disclosureCheck = event.target.checked;
    this.validateInputValues();
  }
  /*This method validates the format of an email address input field, 
    setting a custom validity message if the format is invalid, then triggers validation reporting. */
  handleEmailAddress() {
    let emailAddress = this.template.querySelector(".email-address");
    if (!isValidEmail(this.refs.emailField.value)) {
      emailAddress.setCustomValidity(this.invalidEmailFormat);
    } else {
      emailAddress.setCustomValidity("");
    }
    emailAddress.reportValidity();
    this.handleConfirmEmailChange();
  }

  /*This method compares the values of two email input fields, setting a custom validity message if they don't match, 
        then triggers input validation. */
  handleConfirmEmailChange() {
    let confirmEmailField = this.template.querySelector(".confirm-email");
    if (this.refs.emailField.value != this.refs.confirmEmailField.value) {
      confirmEmailField.setCustomValidity(this.emailAddressNotMatchWarning);
    } else {
      confirmEmailField.setCustomValidity("");
    }
    confirmEmailField.reportValidity();
    this.validateInputValues();
  }

  handlePleaseSpecifyText(event) {
    this.pleaseVerifyText = event.target.value;
    this.validateInputValues();
  }

  @wire(CurrentPageReference)
  pageReference({ state }) {
    if (state && state.previous) {
      this.previousPage = state.previous;
    }
  }

  /*
  This method asynchronously opens a dynamic modal using. It displays electronic consent disclosure and provides options for acceptance or decline. Upon user action, it updates relevant variables and triggers input validation.
   */
  async handleReviewEletronic() {
    this.result = await lwrModal.open({
      style: { "--slds-c-modal-heading-font-size": "20px" },
      size: "full", //full
      //description: 'Accessible description of modal\'s purpose',
      richContent: this.formattedDesc,
      //"<b>Introduction</b><br/><br/>Please read this disclosure carefully. You are creating an account with Agency Organization Name! (hereinafter referred to as a \"Suggestion\").<br/> Under the Electronic Signatures in Global and National Commerce Act (E-SIGN Act 15 U.S.C. §7001), Agency Organization Name! can provide you with some of the benefits of our services by conducting occasional communication and documentation delivery in connection with your Request via e-mail. Such documentation may include eligible required disclosures, notices, documents and other information that Agency Organization Name! is legally allowed to provide in electronic format.<br/><br/><b>Electronic Disclosure Consent</b><br/><br/>In order to deliver electronic communications and documentation to you, we need you to consent to allow us to communicate with you electronically and to provide some or all disclosures, notices, documents and other information to you via e-mail. This document informs you of your rights when receiving legally required disclosures, notices, documents and other information from Agency Organization Name! and any service providers we may use in connection with your Request. <u>You must authorize Agency Organization Name! to conduct electronic delivery of such disclosures, notices, documents and other information by selecting \"YES\" at the bottom of this screen.</u><br/><br/><b>Electronic Delivery, Valid E-mail and Creating an Account</b><br/><br/>Should you decide to consent to receive electronic disclosures, notices, documents and other information via e-mail, Agency Organization Name! will verify your ability to communicate via e-mail. After selecting the “Create Account” button at the bottom of this screen, you will receive a confirmation e-mail to the email address you entered during account creation. By clicking on the link that is in the email, you will be activating your account with Agency Organization Name! and verifying your ability and authorization to receive emails from us. Any such disclosures, notices, documents and other information related to your Request may then be provided to you electronically by Agency Organization Name!. It is important that you maintain a valid e-mail address so that you can receive electronic disclosures, notices, documents and other information via e-mail.<br/><br/><b>Requesting Paper Copies</b><br/><br/>If you wish to obtain a paper copy of any of the disclosures, notices, documents and other information you receive from Agency Organization Name! electronically, you may contact your Agency Organization Name! representative with the details of the disclosures, notices, documents and other information that you would like to receive via a paper copy. Paper copies will be provided to you at no charge.<br/><br/><b>Withdrawal of Your Consent</b><br/><br/>Should you decide not to consent to electronic delivery, any such disclosures, notices, documents and other information related to your Request will then be provided to you via standard United States Postal Service mail. You should know that declining electronic consent may delay the availability of the earliest Eligibility Determination Session appointments in order to allow time for you to receive and review any initial disclosures, notices, documents and other information sent via traditional USPS mail.<br/><br/><b>Hardware and Software Capabilities</b><br/><br/>Before you decide to conduct business related to this Request electronically via e-mail with Agency Organization Name!, you should consider whether you have the required hardware and software capabilities to do this as described below.<br/><br/><b>In order to access documents electronically:</b><br/><ul><li>You must provide us with a current, valid e-mail address. In the event you change your e-mail address, you must notify us. We may treat your provision of an invalid e‐mail address or the subsequent malfunction of a previously valid address as a withdrawal of your consent to receive electronic communications.</li><li>You must have a personal computer or other access device which is capable of accessing the designated e-mail account via Internet access through an Internet Service Provider (ISP) or other means of e-mail account access.</li><li>You must have access to Microsoft Internet Explorer version 9 or later, or Microsoft Edge, or the latest version of Firefox, or the latest version of Google Chrome.</li><li>Disclosures and other documents will be in Portable Document Format (.pdf) and you must have Adobe Acrobat Reader® software version XI or later which permits you to receive and access Portable Document Format files. A free version of the latest Adobe Acrobat Reader® program is available at <a>https://www.adobe.com/</a>, but all other software, hardware and systems must be provided at your cost.</li><li>To retain a copy of the electronic disclosures, notices, documents and other information we send, your system must have the ability to either download electronic documents to your hard disk drive or a peripheral device and/or have printing capabilities. To print, you must have a functioning printer connected to your personal computer or other access device which is able to print the disclosures, notices, documents and other information we send.</li></ul>If you are unable to view or access any electronic disclosures, notices, documents and other information you should notify your Agency Organization Name! representative immediately to request a paper copy, if applicable.<br/>If these software or hardware requirements change, we will provide you with prior written notice of the change and the opportunity to withdraw your consent to receive electronic disclosures, notices, documents and other information.<br/><br/><b>Consent Acknowledgement, Limitation and Withdrawal of Consent</b><br/><br/>You will be asked to acknowledge your acceptance of these terms by checking the box before you are able to continue with your application. In doing so, you are confirming that you meet the system requirements described above, that you have demonstrated your ability to receive, retain, and view electronic documents, and that you have an active and valid e-mail address.<br/>Your consent to receive electronic disclosures, notices, documents and other information only applies to this Request. You may withdraw your consent at any time by contacting the Agency Organization Name! representative you are working with at:<br/><br/><b>Organization Name: Agency Organization Name!<br/>Address:123 SAMPLE Street, Washington DC, 10001<br/>Telephone: (098)892-0987</b>",
      //content
      headerText: this.electronicContentDisclosureHeader,//"Electronic Disclosures Consent",
      cancelButtonTitle: this.electronicConsentDeclineButtonTitle,
      saveButtonTitle: this.electronicConsentAcceptButtonTitle
    });
    if (this.result == "save") {
      this.disclosureCheck = true;
      this.reviewDisclousuresAccepted = true;
    } else {
      this.disclosureCheck = false;
      this.reviewDisclousuresAccepted = false;
    }
    this.validateInputValues();
  }

  @wire(getContent, {
    channelOrSiteId: siteId,
    contentKeyOrId: "$electronicContentDisclosure"
  })
  getSectionDescription(result) {
    if (result?.data?.contentBody?.Value) {
      this.disclosureContent = result.data.contentBody.Value;
    }
  }

  get formattedDesc() {
    if (this.disclosureContent) {
      const replacements = {
        "{organization_name}": this.agencyProfileDetails.Name ? this.agencyProfileDetails.Name : '',
        "{organization_address}": this.agencyProfileDetails.AgencyAddress__c ? this.agencyProfileDetails.AgencyAddress__c.street + ' ' + this.agencyProfileDetails.AgencyAddress__c.city + ', ' + this.agencyProfileDetails.AgencyAddress__c.state + ' ' + this.agencyProfileDetails.AgencyAddress__c.postalCode + ' ' + this.agencyProfileDetails.AgencyAddress__c.country : '',
        "{organization_phone}": this.agencyProfileDetails.AgencyPhoneNumber__c ? this.agencyProfileDetails.AgencyPhoneNumber__c : ''
      };
      return replaceStrings(this.disclosureContent, replacements);
    }
    return this.disclosureContent;
  }

  @wire(getAgencyProfileDetails)
    onGetAgencyProfileDetails(result) {
        if (result.data) {
            this.agencyProfileDetails = result.data;
        } else if(result.error){
            console.log('code error str : ', JSON.stringify(result.error));
        } 
    }

    @wire(getPicklistValues, {
      recordTypeId: "$contactInfo.data.defaultRecordTypeId",
      fieldApiName: PREFLANG_FIELD
    })
    preferredLanguageValues({ error, data }) {
    if (data) {
      this.preferredLanguageOptions = data.values.map((option) => {
        return { label: option.label, value: option.value };
      });
    } else if (error) {
      console.error('error : '+error);
    }
  }

    get suffixOptions(){
      return getSuffixOptions();
    }

    @wire(getPicklistValues, {
      recordTypeId: "$contactInfo.data.defaultRecordTypeId",
      fieldApiName: BESTTIMETOCALL_FIELD
    })
    bestTimeToCallPicklistValues({ error, data }) {
    if (data) {
      this.bestTimeToCallOptions = data.values.map((option) => {
        return { label: option.label, value: option.value };
      });
    } else if (error) {
      console.error('error : '+error);
    }
  }
}