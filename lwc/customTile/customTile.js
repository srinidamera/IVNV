import { LightningElement, api } from "lwc";

export default class CustomTile extends LightningElement {
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
}