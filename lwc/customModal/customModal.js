import { LightningElement, api } from "lwc";

export default class CustomModal extends LightningElement {
  @api modalHeader;
  @api modalSubHeader;

  closeModal() {
    const closeEvt = new CustomEvent("close", {});
    this.dispatchEvent(closeEvt);
  }
}