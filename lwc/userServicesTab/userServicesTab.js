import { LightningElement, api, wire } from "lwc";
import FORM_FACTOR from "@salesforce/client/formFactor";
import getDesiredServices from "@salesforce/apex/UserServicesController.getDesiredServices";
import getEnrolledServicesRecord from "@salesforce/apex/UserServicesController.getEnrolledServicesRecord";
import LANG from "@salesforce/i18n/lang";
import { NavigationMixin } from "lightning/navigation";
import isguest from "@salesforce/user/isGuest";
import { encodeDefaultFieldValues } from "lightning/pageReferenceUtils";
import { CurrentPageReference } from "lightning/navigation";

export default class UserServicesTab extends NavigationMixin(LightningElement) {
  @api signUpLabel;
  @api contactUsLabel;
  @api allServicesLabel;
  @api myServicesLabel;
  @api nwServiceColumnHeight;
  @api learnMoreLinkTitle;
  @api viewDetailsLinkTitle;
  @api labelOpen;
  @api labelCompleted;
  @api labelIncomplete;
  @api labelOnHold;
  @api noServicesSignedUpdMsg;
  allServicesData;
  enrolledServiceDetails;
  showBadge = true;
  desiredServices;
  myServicesData;
  currentTab = "AllServices";
  filterBtnStyleClass =
    " slds-col slds-size_4-of-8 slds-small-size_4-of-8 slds-medium-size_4-of-8 slds-large-size_2-of-8 ";
  allServicesTab = true;

  statusToBadgeStyle = Object.freeze({
    Open: "slds-badge_inverse badge-width font-weight-700",
    "On Hold": "slds-theme_warning  badge-width font-weight-700",
    Completed: "slds-theme_success badge-width font-weight-700",
    Incomplete: "back-yellow badge-width font-weight-700"
  });

  /* @description: getter for check device type*/
  get deviceType() {
    switch (FORM_FACTOR) {
      case "Large":
        return "desktop";
      case "Medium":
        return "tablet";
      case "Small":
        return "mobile";
      default:
    }
  }


  get allServicesStyle() {
    return ( this.currentTab === "AllServices"
        ? "brand"
        : "brand-outline"
    );
  }

  get myServicesStyle() {
    return (this.currentTab === "MyServices"
        ? "brand"
        : "brand-outline"
    );
  }
  /*
  get allServicesStyle() {
    return (
      (this.currentTab === "AllServices"
        ? "tab-btn btn-primary border-left "
        : "tab-btn btn-secondary border-left ") + this.filterBtnStyleClass
    );
  }

  get myServicesStyle() {
    return (
      (this.currentTab === "MyServices"
        ? "btn btn-primary border-right "
        : "btn btn-secondary border-right ") + this.filterBtnStyleClass
    );
  }
    */

  get showNoSignedUpdMsg() {
    return this.currentTab === "MyServices" && !this.myServicesData?.length;
  }

  /*This method fetches desired services data from the CaseType__c Object */
  @wire(getDesiredServices)
  wiredData({ error, data }) {
    if (data) {
      this.dataMapping = data.mapping;
      this.desiredServices = data.records; //this.prepareServices(data.records, data.mapping);
    } else if (error) {
      console.error("getDesiredServices Error:", error);
    }
  }

  /*This method fetches registered services data from the CaseType__c Object */
  @wire(getEnrolledServicesRecord)
  wiredData2({ error, data }) {
    if (data) {
      this.dataMapping = data.mapping;
      this.enrolledServiceDetails = data.enrolledServiceDetails;
      this.myServicesData = this.prepareServices(data.records, data.mapping);
      let tempMyservicesRawData = data.records;
      this.myServicesRawData = tempMyservicesRawData;// data.records;
    } else if (error) {
      console.error("getEnrolledServicesRecord Error:", error);
    }
  }

  get allService(){
    const myServices = Array.isArray(this.myServicesRawData) ? this.myServicesRawData : [];
    const desiredServices = Array.isArray(this.desiredServices) ? this.desiredServices : [];
    let tempServices = [...myServices, ...desiredServices];
    this.allServicesData =  this.prepareServices(tempServices, this.dataMapping);
    return this.allServicesData;
  }

  /*Prepares the service data for rendering based on the device type, adjusting CSS 
        classes and formatting for responsive display. */
  prepareServices(services, fieldMappings) {
    if (!services) {
      return;
    }
    
    let desiredServices = [];
    let parentThis = this;
    let userLanguageMapping =
      LANG === "en-US" ? fieldMappings?.English : fieldMappings?.Spanish;
      const statusToLabel = {
        'Open': this.labelOpen,
        'Completed': this.labelCompleted,
        'Incomplete': this.labelIncomplete,
        'On Hold': this.labelOnHold
      };
    services.forEach(function (currentItem, index) {
      let dynamicClass;
      let classWithPadding =
        "slds-col slds-max-small-size_12-of-12 slds-small-size_12-of-12 slds-medium-size_6-of-12 slds-large-size_3-of-12 slds-p-left_medium";
      let classWithoutPadding =
        "slds-col slds-max-small-size_12-of-12 slds-small-size_12-of-12 slds-medium-size_6-of-12 slds-large-size_3-of-12 slds-p-bottom_medium";
      
      
      if (parentThis.deviceType === "desktop") {
        if (
          (index + 1) % 4 === 2 ||
          (index + 1) % 4 === 3 ||
          (index + 1) % 4 === 0 
        ) {
          dynamicClass = classWithPadding;
        } else {
          dynamicClass = classWithoutPadding;
        }
      } else if (parentThis.deviceType === "tablet") {
        if (index % 2 !== 0) {
          dynamicClass = classWithPadding;
        } else {
          dynamicClass = classWithoutPadding;
        }
      } else if (parentThis.deviceType === "mobile") {
        dynamicClass = classWithoutPadding;
      }
  
      let statusLabel = "";
      let caseClientId = "";
      let intakeId = "";
      let isEnrolled = false;
      if (
        parentThis.enrolledServiceDetails &&  
        parentThis.enrolledServiceDetails[currentItem.Id]
      ) {
        if (
          parentThis.enrolledServiceDetails[currentItem.Id].status ===
            "Open Intake" ||
          parentThis.enrolledServiceDetails[currentItem.Id].status ===
            "Open Case" ||
          parentThis.enrolledServiceDetails[currentItem.Id].status ===
            "In Progress"
        ) {
          statusLabel = "Open";
        } else if (
          parentThis.enrolledServiceDetails[currentItem.Id].status ===
            "Closed - Complete"
        ) {
          statusLabel = "Completed";
        } else if (
          parentThis.enrolledServiceDetails[currentItem.Id].status ===
            "Closed - Incomplete" 
        ) {
          statusLabel = "Incomplete";
        } else if (
          parentThis.enrolledServiceDetails[currentItem.Id].status === "On Hold"
        ) {
          statusLabel = "On Hold";
        } else {
          statusLabel = "";
        }

        if (parentThis.enrolledServiceDetails[currentItem.Id].intakeId) {
          intakeId = parentThis.enrolledServiceDetails[currentItem.Id].intakeId;
        }
        if (parentThis.enrolledServiceDetails[currentItem.Id].caseClientId) {
          caseClientId =
            parentThis.enrolledServiceDetails[currentItem.Id].caseClientId;
        }
        if(parentThis.enrolledServiceDetails[currentItem.Id].isEnrolled){
            isEnrolled = true;
        }
      }
      
      let service = {
        Id: currentItem.Id,
        Name: currentItem[userLanguageMapping?.Name],
        Description: currentItem[userLanguageMapping?.ShortDescription],
        class: dynamicClass,
        Highlights: parentThis.adjustBulletPointsCss(
          currentItem[userLanguageMapping?.Highlights]
        ),
        badgeLabel: statusLabel ? statusToLabel[statusLabel] : '', //statusLabel,
        badgeStyle: parentThis.statusToBadgeStyle[statusLabel],
        badgeVisible: statusLabel != "" ? true : false,
        caseClientId: caseClientId,
        intakeId: intakeId,
        isEnrolled: isEnrolled
      };
      desiredServices.push(service);
    });
    return desiredServices;
  }

  /*Adjusts the CSS styling of bullet points within the HTML*/
  adjustBulletPointsCss(stringHtml) {
    if (stringHtml) {
      var newStyle =
        'style="font-size: 12px; font-weight: 600;font-family: Segoe UI;"';
      stringHtml = stringHtml.replace(/<strong[^>]*>(.*?)<\/strong>/g, "$1");
      stringHtml = stringHtml.replace(/font-size:[^;]+;/g, newStyle);
      return stringHtml.replace(/<li([^>]*)>/g, "<li " + newStyle + ">");
    }
    return "";
  }

  /*Calculates and returns the style string for setting the height of service tiles based on the nwServiceColumnHeight property. */
  get nwServiceTileStyle() {
    let style = "";
    if (
      this.nwServiceColumnHeight &&
      parseInt(this.nwServiceColumnHeight) !== 0
    ) {
      style = "height:" + this.nwServiceColumnHeight + "px;";
    } else {
      style = "height:360px;";
    }
    return style;
  }

  /* Event handler method to handle the click event on the "Learn More" button for a service tile. */
  handleLearnMore(event) {
    let recordId = this.allServicesData[event.currentTarget.dataset.index].Id;
    let stateParams = {};
    stateParams.sId = recordId;

    this[NavigationMixin.Navigate]({
      type: "comm__namedPage",
      attributes: {
        name: "ServiceDetail__c"
      },
      state: {
        ...stateParams
      }
    });
  }

  /* this method is navigate to upload document section on click of 'Lean more' */
  myServiceLearnMore(event) { 
    let intakeId =
      this.allServicesData[event.currentTarget.dataset.index]?.intakeId; 
    let stateParams = {};
    if (intakeId) {
      stateParams.iId = intakeId;
    }  
    this[NavigationMixin.Navigate]({
      type: "comm__namedPage",
      attributes: {
        name: "Intake__c"
      },
      state: {
        ...stateParams
      }
    });
    
  }

  /*Navigates to the registration page when triggered, directing users to a self-registration page with a previous parameter indicating the source. */
  redirectToRegister(e) {
    const dataId = e.target.dataset.id;
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
          url: "/service-enrollment?Id=" + dataId
        }
      });
    }
  }

  @wire(CurrentPageReference)
  pageReference({ state }) {
    const tabNameToId = {
      1: "AllServices",
      2: "MyServices"
    };
    if (state && state.defTab) {
      this.currentTab = tabNameToId[state.defTab];
    }
  }

  get isLoggedInUser() {
    return !isguest;
  }

  get showAllServices() {
    if (this.currentTab === "AllServices") {
      return true;
    }
    return false;
  }

  handleTabClick(event) {
    this.currentTab = event.target.name;
    //this.allServicesTab = !this.allServicesTab;
  }

  // navigate to Contact Us page
  handleNavigateToContact() {
    this[NavigationMixin.Navigate]({
      type: "standard__webPage",
      attributes: {
        url: "/contact"
      }
    });
  }
}