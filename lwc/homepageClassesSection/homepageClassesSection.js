import { LightningElement, api } from "lwc";

export default class HomepageClassesSection extends LightningElement {
  @api tileHeight;
  @api labelHyperlink;
  @api labelClassStarts;

  @api statusEnrolled;
  @api statusNoShow;
  @api statusAttendedComplete;
  @api statusAttendedInComplete;
  @api statusCourseComplete;
  @api statusCourseInComplete;

  // Buttons
  @api btnLabels;
  @api btnTypes; // primary or secondary
  @api redirectToPage;
  @api queryParams; //
  @api horizontalAlign; // Left, Right, Center
}