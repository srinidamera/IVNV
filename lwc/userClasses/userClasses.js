import { LightningElement, api, wire } from "lwc";
import { NavigationMixin } from "lightning/navigation";
import { formatDate } from "c/lwrUtils";
import getUserClasses from "@salesforce/apex/UserClassesController.getUserClasses";

export default class UserClasses extends NavigationMixin(LightningElement) {
  @api tileHeight;
  @api labelHyperlink;
  @api labelClassStarts;

  @api statusEnrolled;
  @api statusNoShow;
  @api statusAttendedComplete;
  @api statusAttendedInComplete;
  @api statusCourseComplete;
  @api statusCourseInComplete;

  classProps;

  statusToBadgeStyle = Object.freeze({
    BOOKED: "slds-badge_inverse badge-width font-weight-700",
    "No Show": "slds-theme_error badge-width font-weight-700",
    "Attended - Complete": "bg-green badge-width font-weight-700 font-white",
    "Attended - Incomplete": "bg-yellow badge-width font-weight-700 font-black",
    "Course Complete": "bg-green badge-width font-weight-700 font-white",
    "Course Incomplete": "bg-yellow badge-width font-weight-700  font-black"
  });

  @wire(getUserClasses)
  wiredGetClasses({ data, error }) {
    if (data) {
      this.classProps = this.buildClassProps(data);
    } else {
      console.log("Error in getUserClasses:", error);
    }
  }

  buildClassProps(data) {
    const statusToLabel = {
      BOOKED: this.statusEnrolled,
      "No Show": this.statusNoShow,
      "Attended - Complete": this.statusAttendedComplete,
      "Attended - Incomplete": this.statusAttendedInComplete,
      "Course Complete": this.statusCourseComplete,
      "Course Incomplete": this.statusCourseInComplete
    };

    const props = [];
    data.forEach((elem) => {
      props.push({
        id: elem.sumoapp__SumoEvent__r?.Id,
        title: elem.sumoapp__SumoEvent__r?.sumoapp__EventName__c,
        keyValPairs: [
          {
            key: this.labelClassStarts,
            value: elem?.sumoapp__SumoEvent__r?.sumoapp__StartDatetime__c
              ? formatDate(
                  elem?.sumoapp__SumoEvent__r?.sumoapp__StartDatetime__c
                )
              : ""
          }
        ],
        showBadge: true,
        badgeLabel: statusToLabel[elem.sumoapp__Status__c],
        badgeStyle: this.statusToBadgeStyle[elem.sumoapp__Status__c],
        showHyperlink: true,
        cardStyle: this.cardStyle,
        hyperlinkTitle: this.labelHyperlink
      });
    });
    return props;
  }

  /* Click Handlers */
  handleClick(event) {
    const recordId = event?.detail?.value;
    this[NavigationMixin.Navigate]({
      type: "comm__namedPage",
      attributes: {
        name: "ClassDetail__c"
      },
      state: {
        recId: recordId
      }
    });
  }

  /*Calculates and returns the style string for setting the height of service tiles based on the nwServiceColumnHeight property. */
  get cardStyle() {
    let style = "";
    if (this.tileHeight && parseInt(this.tileHeight) !== 0) {
      style = "height:" + this.tileHeight + "px;";
    } else {
      style = "height:88px;";
    }
    return style;
  }
}