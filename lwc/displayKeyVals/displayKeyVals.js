import { LightningElement, api } from "lwc";

export default class DisplayKeyVals extends LightningElement {
  @api keyValuePairs = [];
  @api styleClass = "h-3";
}