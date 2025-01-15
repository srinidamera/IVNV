import { LightningElement, api } from "lwc";
import { replaceStrings, addClassToAllAnchorTags } from "c/lwrUtils";

export default class ToastNotification extends LightningElement {
  title;
  message;
  iconName = "action:check";
  autoClose = false;
  autoCloseTime = 4000;
  showToast = false;
  toastVariant = "theme";
  mergeFields = {};
  variant = "success";

  toastVariantToClass = {
    theme: "toast-theme",
    success: "toast-success",
    info: "toast-grey",
    error: "toast-error"
  };

  connectedCallback() {
    const customEvent = new CustomEvent("load");
    this.dispatchEvent(customEvent);
  }

  @api
  showToastMessage({
    title,
    message,
    iconName,
    toastVariant,
    autoClose,
    autoCloseTime,
    mergeFields
  }) {
    this.title = title;
    this.message = message;
    this.iconName = iconName;
    this.toastVariant = toastVariant;
    this.autoClose = autoClose;
    this.autoCloseTime = autoCloseTime;
    this.showToast = true;
    this.mergeFields = mergeFields;
    if (autoClose) {
      setTimeout(this.closeToast.bind(this), this.autoCloseTime);
    }
  }

  @api
  closeToast() {
    this.showToast = false;
  }

  get toastStyle() {
    return (
      this.toastVariantToClass[this.toastVariant] +
      " toast-body slds-notify slds-notify_toast slds-col slds-grid slds-small-size_12-of-12 slds-medium-size_6-of-12 slds-large-size_2-of-8"
    );
  }

  get formattedToastMsg() {
    const formattedMsg = replaceStrings(this.message, this.mergeFields);
    return addClassToAllAnchorTags(
      formattedMsg,
      'style="color: white !important"'
    );
  }

  get fromattedTitle() {
    return replaceStrings(this.title, this.mergeFields);
  }
}