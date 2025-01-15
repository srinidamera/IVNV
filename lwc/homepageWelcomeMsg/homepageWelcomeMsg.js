import { LightningElement, api, wire } from "lwc";
import { replaceStrings, capitalizeWords } from "c/lwrUtils";
import Id from "@salesforce/user/Id";
import USER_FULL_NAME from "@salesforce/schema/User.Name";
import { getRecord } from "lightning/uiRecordApi";

export default class HomepageWelcomeMsg extends LightningElement {
  @api welcomeMsg;
  currentUserFullName;

  @wire(getRecord, {
    recordId: Id,
    fields: [USER_FULL_NAME]
  })
  currentUserInfo({ error, data }) {
    if (data) {
      this.currentUserFullName = data.fields.Name.value;
      this.error = error;
    }
  }

  get formattedWelcomeMessage() {
    const mergeFields = {
      "{client_full_name}": capitalizeWords(this.currentUserFullName)
    };
    return replaceStrings(this.welcomeMsg, mergeFields);
  }
}