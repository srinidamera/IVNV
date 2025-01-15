import { LightningElement, api, wire } from "lwc";
import { NavigationMixin } from "lightning/navigation";
import getUserTasks from "@salesforce/apex/UserTasksController.getUserTasks";
import getTasksMetrics from "@salesforce/apex/UserTasksController.getTasksMetrics";
import { formatDate, isEmpty } from "c/lwrUtils";

export default class UserTasks extends NavigationMixin(LightningElement) {
  @api tileHeight;

  @api labelMyTasks;
  @api labelLastUpdated;
  @api labelDueDate;
  @api labelTaskDescription;
  @api noTasksMsg;
  @api labelViewDetails;
  @api labelNotStarted;
  @api labelInProgress;
  @api labelCompleted;
  @api showBackBtn;
  @api backBtnLabel;
  @api showHeaderDetailsHyperlink;
  @api useGrid;
  @api showTaskProgressBar;
  @api pageType;

  headerProps;
  taskProps;
  get isProgressBarVsible(){
    console.log('showTaskProgressBar==>',this.showTaskProgressBar);
    if(this.showTaskProgressBar === 'Yes'){
      return true;
    }
    return false;
  }
  statusToBadgeStyle = Object.freeze({
    "Not Started": "bg-orange badge-width font-weight-700 font-white",
    "In Progress": "slds-badge_inverse badge-width font-weight-700 font-white",
    Completed: "bg-green badge-width font-weight-700 font-white"
  });

  @wire(getTasksMetrics)
  wiredGetTaskMetrics({ data, error }) {
    if (data) {
      this.headerProps = this.buildTaskHeaderProps(data);
    } else {
      console.log("Error in getTasksMetrics:", error);
    }
  }

  buildTaskHeaderProps(data) {
    return {
      title: this.labelMyTasks,
      keyVal: {
        key: this.labelLastUpdated,
        value: ""
      },
      metricTitle1: this.labelNotStarted,
      metric1: data["Not Started"] || 0,
      metricTitle2: this.labelInProgress,
      metric2: data["In progress"] || 0,
      metricTitle3: this.labelCompleted,
      metric3: data.Completed || 0,
      showHyperlink: true && this.showHeaderDetailsHyperlink,
      hyperlinkTitle: this.labelViewDetails
    };
  }

  @wire(getUserTasks, {pageType: "$pageType"})
  wiredGetTask({ data, error }) {
    if (data) {
      this.taskProps = this.buildTaskProps(data);
    } else {
      console.log("Error in getUserTasks:", error);
    }
  }

  buildTaskProps(data) {
    const statusToLabel = {
      "In Progress": this.labelInProgress,
      "Not Started": this.labelNotStarted,
      Completed: this.labelCompleted
    };

    const props = [];
    data.forEach((elem) => {
      props.push({
        // id: elem.Id,
        id: elem.WhatId, // Client Case Id / Intake Id
        title: elem.Subject,
        keyValPairs: this.buildKeyValuePairs(elem),
        showBadge: true,
        badgeLabel: statusToLabel[elem.Status],
        badgeStyle: this.statusToBadgeStyle[elem.Status],
        tileStyle: this.tileStyle,
        showHyperlink: true,
        hyperlinkTitle: this.labelViewDetails
      });
    });
    return props;
  }

  buildKeyValuePairs(elem) {
    const fieldsToDisplay = {};
    fieldsToDisplay[this.labelLastUpdated] = formatDate(elem.LastModifiedDate);
    fieldsToDisplay[this.labelDueDate] = elem.ActivityDate
      ? formatDate(elem.ActivityDate)?.split(" ")[0]
      : "";
    fieldsToDisplay[this.labelTaskDescription] = elem.Description;
    const keyValPairs = [];
    Object.keys(fieldsToDisplay).forEach((field) => {
      if (!isEmpty(field)) {
        keyValPairs.push({
          key: field,
          value: fieldsToDisplay[field]
        });
      }
    });
    return keyValPairs;
  }

  /* Click Handlers */
  redirectToTasks() {
    const pageState = {
      defTab: 2
    };
    this.redirectToPage("Profile__c", pageState);
  }

  goToTaskDetails(event) {
    const recordId = event.detail.value; // Client Case Id
    const state = {
      iId: recordId
    };

    this.redirectToPage("Intake__c", state);
  }

  redirectToPage(pageApiName, pgState = {}) {
    this[NavigationMixin.Navigate]({
      type: "comm__namedPage",
      attributes: {
        name: pageApiName
      },
      state: pgState
    });
  }

  handleGoBack() {
    window.history.back();
  }

  /*Calculates and returns the style string for setting the height of service tiles based on the nwServiceColumnHeight property. */
  get tileStyle() {
    let style = "";
    if (this.tileHeight && parseInt(this.tileHeight) !== 0) {
      style = "height:" + this.tileHeight + "px;";
    } else {
      style = "height:88px;";
    }
    return style;
  }

  get headerStyles() {
    const defaultClasses = "tile slds-p-around_x-small slds-card slds-wrap ";
    return this.useGrid
      ? defaultClasses
      : defaultClasses + "slds-m-bottom_xxx-small"; // for Profile page
  }

  get tileClasses() {
    return this.useGrid
      ? "slds-col slds-size_8-of-8 slds-small-size_8-of-8 slds-medium-size_8-of-8 slds-large-size_2-of-8"
      : "slds-col slds-size_8-of-8 slds-m-bottom_xxx-small"; // for Profile page
  }

  get noTasksExist() {
    return !this.taskProps?.length;
  }
}