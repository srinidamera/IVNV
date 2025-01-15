import { LightningElement, api, wire } from "lwc";
import { NavigationMixin } from "lightning/navigation";
import { formatDate } from "c/lwrUtils";
import getUserServices from "@salesforce/apex/UserServicesControllerHomepage.getUserServices";

export default class UserServices extends NavigationMixin(LightningElement) {
  @api tileHeight;
  @api labelHyperlink;

  @api labelLastUpdated;
  @api labelStatusNew;
  @api labelStatusOnHold;
  @api labelStatusConverted;
  @api labelStatusClosedIncomplete;

  servicesProps;

  statusToBadgeStyle = Object.freeze({
    Open: "slds-badge_inverse badge-width font-weight-700",
    "On Hold": "slds-theme_warning  badge-width font-weight-700",
    Completed: "slds-theme_success badge-width font-weight-700",
    Incomplete: "bg-yellow badge-width font-weight-700"
  });

  @wire(getUserServices)
  wiredGetClasses({ data, error }) {
    if (data) {
      this.servicesProps = this.buildServicesProps(data);
    } else {
      console.log("Error in getUserServices:", error);
    }
  }

  buildServicesProps(data) {
    
    const statusToLabel = {
        'Open': this.labelStatusNew,
        'Completed': this.labelStatusConverted,
        'Incomplete': this.labelStatusClosedIncomplete,
        'On Hold': this.labelStatusOnHold
      };
    const props = [];
    data.forEach((elem) => {
      console.log('Status ==>',elem.status);
      let statusLabel = "";
        if (
          elem.status ===
            "Open Intake" ||
            elem.status ===
            "Open Case" ||
            elem.status ===
            "In Progress"
        ) {
          statusLabel = "Open";
        } else if (
          elem.status ===
            "Closed - Complete"
        ) {
          statusLabel = "Completed";
        } else if (
          elem.status ===
            "Closed - Incomplete" 
        ) {
          statusLabel = "Incomplete";
        } else if (
          elem.status === "On Hold"
        ) {
          statusLabel = "On Hold";
        } else {
          statusLabel = "";
        }
      props.push({
        id: elem.Id,
        title: elem.intakeRequestName,
        keyValPairs: [
          {
            key: this.labelLastUpdated,
            value: formatDate(elem.lastModifiedDate)
          }
        ],
        showBadge: statusLabel != "" ? true : false,
        badgeLabel: statusToLabel[statusLabel],
        badgeStyle: this.statusToBadgeStyle[statusLabel],
        showHyperlink: true,
        tileStyle: this.cardStyle,
        hyperlinkTitle: this.labelHyperlink
      });
      
    });
    return props;
  }

  /* Click Handlers */
  handleClick(event) {
    const state = {
      iId: event?.detail?.value
    };
    this[NavigationMixin.Navigate]({
      type: "comm__namedPage",
      attributes: {
        name: "Intake__c"
      },
      state: {
        ...state
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