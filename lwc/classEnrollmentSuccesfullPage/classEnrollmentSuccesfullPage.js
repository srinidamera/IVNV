import { LightningElement, api, wire } from 'lwc';
import siteId from "@salesforce/site/Id";
import { getContent } from "experience/cmsDeliveryApi";
import { replaceStrings } from "c/lwrUtils";
export default class ClassEnrollmentSuccesfullPage extends LightningElement {
    formattedContent;
    @api contact;
    @api course;
    @api labels;
    @api finalPageContentId;
    @wire(getContent, {
        channelOrSiteId: siteId,
        contentKeyOrId: "$finalPageContentId"
    })
    getSectionDescription(result) {
        if (result?.data?.contentBody?.Value) {
            this.formattedContent = result.data.contentBody.Value;
            if (this.formattedContent) {
                const replacements = {
                    "{username}": this.contact.Name,
                    "{classname}": this.course.Name,
                    "{classdatetime}": this.course.StartDate
                };
                this.formattedContent = replaceStrings(this.formattedContent, replacements);
            }
        }
    }

}