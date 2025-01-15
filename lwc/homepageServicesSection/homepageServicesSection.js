import { LightningElement, api } from "lwc";

export default class HomepageServicesSection extends LightningElement {
  @api tileHeight;
  @api labelHyperlink;
  @api labelClassStarts;

  @api labelLastUpdated;

  @api labelStatusNew;
  @api labelStatusOnHold;
  @api labelStatusConverted;
  @api labelStatusClosedIncomplete;

  // Buttons
  @api btnLabels;
  @api btnTypes; // primary or secondary
  @api redirectToPage;
  @api queryParams;
  @api horizontalAlign; // Left, Right, Center
}