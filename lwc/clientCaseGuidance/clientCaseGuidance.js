import { LightningElement, api, wire, track } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import getClientCaseTasks from "@salesforce/apex/ClientCaseGuidanceController.getClientCaseTasks";
import getStatusPicklist from "@salesforce/apex/ClientCaseGuidanceController.getStatusPicklist";
import updateClientCaseTask from "@salesforce/apex/ClientCaseGuidanceController.updateClientCaseTask";
import isIntakeStaffUser from "@salesforce/apex/ClientCaseGuidanceController.isIntakeStaffUser";

export default class ClientCaseGuidance extends LightningElement {
  @api recordId;
  @api objectApiName;
  statusPicklistLabelVal;
  @track clientCaseTasks;
  @track disableMenu;

  statusToBadgeStyle = Object.freeze({
    "Not Started": "slds-badge_lightest badge-width",
    "In Progress": "slds-badge_inverse badge-width",
    Skipped: "slds-theme_warning badge-width font-white",
    Done: "slds-theme_success badge-width"
  });

  @wire(getStatusPicklist)
  wiredStatusPicklist({ data }) {
    if (data) {
      this.statusPicklistLabelVal = data;
    } else {
      this.showToastMsg(
        "Something Went Wrong!",
        "We're unable to fetch some data at this moment.",
        "error"
      );
    }
  }

  @wire(getClientCaseTasks, { clientCaseId: "$recordId" })
  wiredCaseTasks({ data }) {
    if (data) {
      this.clientCaseTasks = this.buildCaseGuidance(data);
    } else {
      this.showToastMsg(
        "Something Went Wrong!",
        "We're unable to fetch the Case Guidance at this moment.",
        "error"
      );
    }
  }

  connectedCallback() {
    this.isIntakeStaffUser();
  }

  isIntakeStaffUser() {
    isIntakeStaffUser().then((result) => {
      this.disableMenu = result;
    }).catch((error) => {
      console.log('ERROR !!!'+JSON.stringify(error))
    });
  }

  get checkDisableMenu(){
    return (this.disableMenu && this.objectApiName == 'ClientCase__c');
  }

  buildCaseGuidance(tasks) {
    const caseGuidanceTasks = [];
    tasks?.forEach((task) => {
      caseGuidanceTasks.push({
        Id: task.Id,
        label: task.StepName__c,
        status: task.Status__c,
        description: task.StepDetails__c,
        comment: task.Comments__c,
        badgeStyle: this.statusToBadgeStyle[task.Status__c]
      });
    });
    return caseGuidanceTasks;
  }

  handleOnSelect(event) {
    updateClientCaseTask({
      recordId: event.detail.uniqueId,
      status: event.detail.status,
      comments: null
    })
      .then(() => {
        this.clientCaseTasks.forEach((task) => {
          if (task.Id === event.detail.uniqueId) {
            task.status = event.detail.status;
            task.badgeStyle = this.statusToBadgeStyle[event.detail.status];
          }
        });
        this.showToastMsg(
          "Record Updated!",
          "You have successfully updated the Case Guidance Status.",
          "success"
        );
      })
      .catch(() => {
        this.showToastMsg(
          "Something Went Wrong!",
          "We're unable to update the Case Guidance Status at this moment.",
          "error"
        );
      });
  }


  showToastMsg(title, msg, variant) {
    const evt = new ShowToastEvent({
      title: title,
      message: msg,
      variant: variant
    });
    this.dispatchEvent(evt);
  }

  get isLoaded() {
    return this.statusPicklistLabelVal && this.clientCaseTasks;
  }

  get noRecords() {
    return !this.clientCaseTasks?.length;
  }
}