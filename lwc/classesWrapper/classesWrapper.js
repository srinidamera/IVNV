import { LightningElement, api, wire } from "lwc";
import { NavigationMixin } from "lightning/navigation";
import getClassesForLoggedInUser from "@salesforce/apex/ClassesController.getClassesForLoggedInUser";
import getAllParentClasses from "@salesforce/apex/ClassesController.getAllParentClasses";
import getOptedClasses from "@salesforce/apex/ClassesController.getOptedClasses";
import isguest from "@salesforce/user/isGuest";
import {
  getMonthNameAndYearFromUtcDate,
  sortByMonthAndYear,
  formatDate,
  isEmpty
} from "c/lwrUtils";
import LANG from "@salesforce/i18n/lang";
import { CurrentPageReference } from "lightning/navigation";

export default class ClassesWrapper extends NavigationMixin(LightningElement) {
  @api allClassesLabel;
  @api myClassesLabel;
  @api cardHeight;
  @api hyperlinkTitle;
  @api cardBtnLabel;
  @api cardSecondaryBtnLabel;
  @api backBtnLabel;

  @api deliveryMethodText;
  @api startDateText;
  @api endDateText;
  @api availableSeatsText;
  @api costText;
  @api locationText;
  @api virtualText;
  @api inPersonText;
  @api textOnline;
  @api freeSponsoredText;
  @api unlimitedText;
  @api noClassesEnrolledMsg;

  @api statusEnrolled;
  @api statusCanceled;
  @api statusNoShow;
  @api statusAttendedComplete;
  @api statusAttendedInComplete;
  @api statusCourseComplete;
  @api statusCourseInComplete;
  defTab;

  monthWiseClasses = [];
  currentTab = "AllClasses";
  filterBtnStyleClass =
    " slds-col slds-size_4-of-8 slds-small-size_4-of-8 slds-medium-size_4-of-8 slds-large-size_2-of-8 ";
  isLoading = false;

  statusToBadgeStyle = Object.freeze({
    BOOKED: "slds-badge_inverse badge-width font-weight-700",
    CANCELED: "slds-theme_error badge-width font-weight-700",
    "No Show": "slds-theme_error badge-width font-weight-700",
    "Attended - Complete": "slds-theme_success badge-width font-weight-700",
    "Attended - Incomplete": "slds-theme_error badge-width font-weight-700",
    "Course Complete": "slds-theme_success badge-width font-weight-700",
    "Course Incomplete": "slds-theme_error badge-width font-weight-700"
  });

  tabIdToName = {
    1: "AllClasses",
    2: "MyClasses"
  };

  connectedCallback() {
    this.getClassData();
  }

  getClassData() {
    if (isguest) {
      this.getAllClasses();
    } else {
      if (this.currentTab === "AllClasses") {
        this.getClassesForLoggedInUser();
      } else {
        this.getMyClasses();
      }
    }
  }

  getAllClasses() {
    this.showLoader();
    getAllParentClasses({ language: LANG })
      .then((result) => {
        this.monthWiseClasses = this.prepareData(result);
      })
      .catch((error) => {
        this.monthWiseClasses = [];
        console.log("error::", JSON.stringify(error));
      })
      .finally(() => {
        this.hideLoader();
      });
  }

  getClassesForLoggedInUser() {
    this.showLoader();
    getClassesForLoggedInUser({ language: LANG })
      .then((result) => {
        this.monthWiseClasses = this.prepareData(result);
      })
      .catch((error) => {
        console.log("error::", JSON.stringify(error));
      })
      .finally(() => {
        this.hideLoader();
      });
  }

  getMyClasses() {
    this.showLoader();
    getOptedClasses({ language: LANG })
      .then((result) => {
        this.monthWiseClasses = this.prepareData(result);
      })
      .catch((error) => {
        this.monthWiseClasses = [];
        console.log("error::", JSON.stringify(error));
      })
      .finally(() => {
        this.hideLoader();
      });
  }

  anchorClickHandler(event) {
    const recordId = event.detail.value;
    this[NavigationMixin.Navigate]({
      type: "standard__webPage",
      attributes: {
        url: "/class-detail?recId=" + recordId
      },
      state: {
        recId: recordId
      }
    });
  }

  btnClickHandler(event) {
    const type = "standard__webPage";
    let uri = "/";

    if (isguest) {
      uri = "/SelfRegister?previous=classes";
    } else {
      const recordId = event.detail.value;
      const btnType = event.detail.btnType;
      if (btnType === "primary") {
        uri = "/class-enrollment?Id=" + recordId;
      } else {
        uri = "/contact";
      }
    }
    this.navigateTo(type, uri);
  }

  navigateTo(type, uri) {
    this[NavigationMixin.Navigate]({
      type: type,
      attributes: {
        url: uri
      }
    });
  }

  handleGoBack() {
    window.history.back();
  }

  prepareData(data) {
    const statusToLabel = {
      BOOKED: this.statusEnrolled,
      CANCELED: this.statusCanceled,
      "No Show": this.statusNoShow,
      "Attended - Complete": this.statusAttendedComplete,
      "Attended - Incomplete": this.statusAttendedInComplete,
      "Course Complete": this.statusCourseComplete,
      "Course Incomplete": this.statusCourseInComplete
    };
    const props = [];
    data?.forEach((elem) => {
      const startDate = this.getStartDateFromKeyVal(elem.keyValPairs);
      console.log('elem status ===>',elem.status);
      console.log('elem.attendeeStatus ===>',elem.attendeeStatus);
      let badgeLabel = '';
      if((elem.status === 'BOOKED' || elem.status === 'CANCELED') && 
        (elem.attendeeStatus === '' || elem.attendeeStatus === undefined)){
        badgeLabel = elem.status;
      } else{
        badgeLabel = elem.attendeeStatus;
      }
      const prop = {
        id: elem.id,
        name: elem.eventName,
        startDate: formatDate(startDate),
        startMonthNum: new Date(startDate).getMonth(),
        startYear: new Date(startDate).getFullYear(),
        startMonthAndYear: getMonthNameAndYearFromUtcDate(startDate),
        description: elem.shortDescription,
        richTextContent: this.adjustBulletPointsCss(elem.highlights),
        keyValPairs: this.buildKeyValuePairs(
          elem.keyValPairs,
          elem.isVirtualEvent
        ),
        cardStyle: this.cardStyle,
        showHyperlink: true,
        hyperlinkTitle: this.hyperlinkTitle,
        btnLabel: elem.status || elem.seatsNotAvailable || elem.courseExpire ? this.cardSecondaryBtnLabel : this.cardBtnLabel, //elem.status ? this.cardSecondaryBtnLabel : this.cardBtnLabel, // If status then show Request Support button, otherwise show Enroll button
        isPrimary: elem.status || elem.seatsNotAvailable || elem.courseExpire ? false : true, // If no status then show primary(Enroll) button
        showBadge: this.isLoggedInUser && elem.status, // show badge when status and logged in user
        badgeLabel: statusToLabel[badgeLabel],
        badgeStyle: this.statusToBadgeStyle[badgeLabel],
        class:
          "slds-col slds-max-small-size_12-of-12 slds-small-size_12-of-12 slds-medium-size_6-of-12 slds-large-size_3-of-12"
      };
      props.push(prop);
    });
    // group by month and year
    const monthlyGrouped = Object.groupBy(
      props,
      (elem) => elem.startMonthAndYear
    );
    let groupedClasses = [];
    Object.keys(monthlyGrouped).forEach((startMonthAndYear) => {
      const classDetails = {
        startMonthNum: monthlyGrouped[startMonthAndYear][0].startMonthNum,
        startYear: monthlyGrouped[startMonthAndYear][0].startYear,
        startMonthAndYear: startMonthAndYear,
        classes: monthlyGrouped[startMonthAndYear]
      };
      groupedClasses.push(classDetails);
    });
    // sort monthly grouped classes
    groupedClasses = sortByMonthAndYear(
      groupedClasses,
      "startMonthNum",
      "startYear"
    );
    console.log("groupedClasses::", JSON.stringify(groupedClasses));
    return groupedClasses;
  }


  handleTabClick(event) {
    const tabNameToId = {
      AllClasses: 1,
      MyClasses: 2
    };
    this.currentTab = event.target.name;
    this.defTab = tabNameToId[event.target.name];
    this.getClassData();
    // Tab history
    const regex = /defTab=[0-9]/i;
    const currUrl = window.location.href;
    if (window.location.href?.match(regex)) {
      window.history.replaceState(
        { previousURL: currUrl },
        "",
        currUrl.replace(regex, "defTab=" + this.defTab)
      );
    } else {
      window.history.replaceState(
        { previousURL: window.location.href },
        "",
        currUrl + "?defTab=" + this.defTab
      );
    }
  }

  showLoader() {
    this.isLoading = true;
  }

  hideLoader() {
    this.isLoading = false;
  }

  buildKeyValuePairs(keyValPairs, isVirtualEvent) {
    if (!keyValPairs) return;
    const dateFields = ["startDate", "endDate"];
    const keyToDisplayText = {
      type: this.deliveryMethodText,
      startDate: this.startDateText,
      endDate: this.endDateText,
      availableSeats: this.availableSeatsText,
      cost: this.costText,
      location: this.locationText
    };
    const displayKeyVal = [];
    keyValPairs.forEach((keyVal) => {
      let formattedVal = "";
      switch (keyVal.key) {
        case "type":
          formattedVal = isVirtualEvent ? this.virtualText : this.inPersonText;
          break;
        case "location":
          formattedVal = isVirtualEvent ? this.textOnline : keyVal.value;
          break;
        case "cost":
          formattedVal =
            keyVal.value > 0 ? keyVal.value : this.freeSponsoredText;
          break;
        case "availableSeats":
          formattedVal = keyVal.value === 'Unlimited' ? this.unlimitedText : keyVal.value;
          break;
        default:
          if (dateFields.includes(keyVal.key) && !isEmpty(keyVal.value)) {
            formattedVal = formatDate(keyVal.value);
          } else if (!isEmpty(keyVal.value)) {
            formattedVal = keyVal.value;
          }
      }
      displayKeyVal.push({
        key: keyToDisplayText[keyVal.key],
        value: formattedVal
      });
    });
    return displayKeyVal;
  }

  adjustBulletPointsCss(stringHtml) {
    if (stringHtml) {
      let newStyle =
        'style="font-size: 12px; font-weight: 600;font-family: Segoe UI;"';
      stringHtml = stringHtml.replace(/<strong[^>]*>(.*?)<\/strong>/g, "$1");
      stringHtml = stringHtml.replace(/font-size:[^;]+;/g, newStyle);
      return stringHtml.replace(/<li([^>]*)>/g, "<li " + newStyle + ">");
    }
    return "";
  }

  getStartDateFromKeyVal(keyValPairs) {
    const startDateKeyVal = keyValPairs.find(
      (keyVal) => keyVal.key === "startDate"
    );
    return startDateKeyVal?.value;
  }

  @wire(CurrentPageReference)
  pageReference({ state }) {
    if (state && state.defTab) {
      this.defTab = state.defTab;
      this.currentTab = this.tabIdToName[state.defTab];
    } else if (this.defTab) {
      this.currentTab = this.tabIdToName[this.defTab];
    } else {
      this.defTab = 1;
    }
  }

  /*Calculates and returns the style string for setting the height of service tiles based on the nwServiceColumnHeight property. */
  get cardStyle() {
    let style = "";
    if (this.cardHeight && parseInt(this.cardHeight) !== 0) {
      style = "height:" + this.cardHeight + "px;";
    } else {
      style = "height:360px;";
    }
    return style;
  }
 
  get allClassesVariant(){
    console.log('all classes ==>',this.currentTab);
    return this.currentTab === "AllClasses"
        ? "brand"
        : "brand-outline";
  }

  get myClassesVariant(){
    console.log('My classes ==>',this.currentTab);
    return this.currentTab === "MyClasses"
        ? "brand"
        : "brand-outline";
  }

  get isLoggedInUser() {
    return !isguest;
  }

  get showNoClassEnrolledMsg() {
    return this.currentTab === "MyClasses" && !this.monthWiseClasses?.length;
  }
}