import { LightningElement, api, track, wire } from "lwc";
import { CurrentPageReference, NavigationMixin } from "lightning/navigation";
import getClassDetails from "@salesforce/apex/ClassesController.getClassDetails";
import LANG from "@salesforce/i18n/lang";
import isguest from "@salesforce/user/isGuest";
import { formatDate, isEmpty } from "c/lwrUtils";

export default class ClassDetails extends NavigationMixin(LightningElement) {
  @api title2;

  @api classText;
  @api classesText;
  @api aboutText;
  @api learnMoreText;
  @api cardPrimaryBtnLabel;
  @api cardSecondaryBtnLabel;
  @api backBtnLabel;
  @api cardHeight;

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

  @api statusEnrolled;
  @api statusNoShow;
  @api statusAttendedComplete;
  @api statusAttendedInComplete;
  @api statusCourseComplete;
  @api statusCourseInComplete;
  classPageDefTab;

  @track content = {
    title1: "Title1",
    description1: "Description1",
    title2: "Title2",
    description2: "Description2",
    path: "Test"
  };
  parentClassRecId;

  statusToBadgeStyle = Object.freeze({
    BOOKED: "slds-badge_inverse badge-width font-weight-700",
    "No Show": "slds-theme_error badge-width font-weight-700",
    "Attended - Complete": "slds-theme_success badge-width font-weight-700",
    "Attended - Incomplete": "slds-theme_error badge-width font-weight-700",
    "Course Complete": "slds-theme_success badge-width font-weight-700",
    "Course Incomplete": "slds-theme_error badge-width font-weight-700"
    // "Withdrawn": "back-yellow badge-width font-black font-weight-700",
  });

  @wire(CurrentPageReference)
  getStateParameters(currentPageReference) {
    if (currentPageReference) {
      this.parentClassRecId = currentPageReference.state?.recId;
      this.classPageDefTab = currentPageReference.state?.defTab;
    }
  }

  @wire(getClassDetails, { language: LANG, recordId: "$parentClassRecId" })
  wiredData({ error, data }) {
    if (data) {
      this.content = this.processData(data);
    } else {
      console.log("error::", JSON.stringify(error));
    }
  }

  processData(data) {
    const statusToLabel = {
      BOOKED: this.statusEnrolled,
      "No Show": this.statusNoShow,
      "Attended - Complete": this.statusAttendedComplete,
      "Attended - Incomplete": this.statusAttendedInComplete,
      "Course Complete": this.statusCourseComplete,
      "Course Incomplete": this.statusCourseInComplete
    };
    const content = {
      breadCrumbPath: this.getCurrentPathLabel(data.eventName),
      breadCrumbRedirectPage: this.getbreadCrumbRedirectPage(),
      title1: this.getTitle1(data.eventName),
      description1: data.description,
      title2: this.title2,
      description2: data.frequentlyAskedQuestions,
      classProp: {
        id: this.parentClassRecId,
        name: data.eventName,
        description: data.shortDescription,
        richTextContent: data.highlights,
        keyValPairs: this.buildKeyValuePairs(
          data.keyValPairs,
          data.isVirtualEvent
        ),
        childClasses: this.processChilds(data.childClasses),
        btnLabel: data.status || data.seatsNotAvailable || data.courseExpire
          ? this.cardSecondaryBtnLabel
          : this.cardPrimaryBtnLabel, // If status then show Request Support button, otherwise show Enroll button
        isPrimary:  data.status || data.seatsNotAvailable || data.courseExpire ? false : true, //!data.status, // If no status then show primary(Enroll) button
        showBadge: this.isLoggedInUser && data.status, // show badge when status and logged in user
        badgeLabel:
          data.status === ("BOOKED" || "CANCELLED")
            ? statusToLabel[data.status]
            : statusToLabel[data.attendeeStatus],
        badgeStyle:
          data.status === ("BOOKED" || "CANCELLED")
            ? this.statusToBadgeStyle[data.status]
            : this.statusToBadgeStyle[data.attendeeStatus],
        cardStyle: this.cardStyle
      }
    };
    return content;
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

  processChilds(childRecords) {
    const childRecs = [];
    let index = 1;
    childRecords.forEach((data) => {
      const child = {
        title: `${this.classText} ${index++}`,
        shortDescription: data.eventName,
        keyValPairs: [
          { key: this.startDateText, value: formatDate(data.startDate) },
          { key: this.endDateText, value: formatDate(data.endDate) }
        ]
      };
      childRecs.push(child);
    });
    return childRecs;
  }

  handleGoBack() {
    window.history.back();
  }

  getCurrentPathLabel(label) {
    return `${this.classesText}, ${this.learnMoreText} ${this.aboutText} ${label}`;
  }

  getbreadCrumbRedirectPage() {
    return "Classes__c";
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

  getTitle1(eventName) {
    return `${this.aboutText} ${eventName}`;
  }

  get isLoggedInUser() {
    return !isguest;
  }

  /*Calculates and returns the style string for setting the height of service tiles based on the nwServiceColumnHeight property. */
  get cardStyle() {
    let style = "";
    if (this.cardHeight && parseInt(this.cardHeight) !== 0) {
      style = "min-height:" + this.cardHeight + "px;";
    } else {
      style = "min-height:360px;";
    }
    return style;
  }
}