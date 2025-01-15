/**
 * @description       :
 * @author            : The Developer
 * @group             :
 * @last modified on  : 02-02-2024
 * @last modified by  : The Developer
 **/
import { LightningElement, api } from "lwc";

export default class CustomAccordion extends LightningElement {
  @api showNoRecMsg = false;
  @api noRecordsMsg = "No records exist";
}