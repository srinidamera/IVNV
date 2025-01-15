import { LightningElement, api, track, wire } from "lwc";
import siteId from "@salesforce/site/Id";
import { getContent } from "experience/cmsDeliveryApi";

export default class TitleAndContentSection extends LightningElement {
  @api title;
  @api sectionDescKey;
  @track content = {};

  @wire(getContent, {
    channelOrSiteId: siteId,
    contentKeyOrId: "$sectionDescKey"
  })
  getSectionDescription(result) {
    if (result?.data?.contentBody?.Value) {
      this.content.description = result.data.contentBody.Value;
    }
  }
}