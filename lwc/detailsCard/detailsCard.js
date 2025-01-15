import { LightningElement, api } from "lwc";

export default class DetailsCard extends LightningElement {
  @api props;

  /* Click Handlers */
  hyperlinkClickHandler(event) {
    const recordId = event?.currentTarget?.dataset?.id;
    this.dispatchEvent(
      new CustomEvent("anchorclick", {
        detail: {
          value: recordId
        }
      })
    );
  }

  btnClickHandler(event) {
    const recordId = event?.currentTarget?.dataset?.id;
    const btnType = event?.currentTarget?.dataset?.btnType;
    this.dispatchEvent(
      new CustomEvent("btnclick", {
        detail: {
          btnType: btnType,
          value: recordId
        }
      })
    );
  }
}