import { LightningElement, api, wire } from "lwc";
import { CurrentPageReference } from "lightning/navigation";

/**
 * @slot Tab-1 This is the header slot
 * @slot Tab-2 This is the footer slot
 * @slot Tab-3 This is the default slot
 */
export default class CustomTabset extends LightningElement {
  @api tabLabel1;
  @api tabLabel2;
  @api tabLabel3;
  activeTab = "T1";

  @wire(CurrentPageReference)
  pageReference({ state }) {
    const tabNameToId = {
      1: "T1",
      2: "T2",
      3: "T3"
    };
    if (state && state.defTab) {
      this.activeTab = tabNameToId[state.defTab];
    }
  }
}