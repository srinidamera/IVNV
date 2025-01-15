import { LightningElement, api, wire } from 'lwc';
import siteId from "@salesforce/site/Id";
import { getContent } from "experience/cmsDeliveryApi";
import { replaceStrings } from "c/lwrUtils";
import basePath from '@salesforce/community/basePath';

export default class ServiceEnrollmentSuccesfullPage extends LightningElement {
    formattedContent;
    @api contact;
    @api service;
    @api labels;
    @api finalPageContentId;
    @api intakeId;
    communityIntakeUrl;

    connectedCallback() {
        this.communityIntakeUrl = `https://${location.host}${basePath}/intake?iId=${this.intakeId}`;
    }

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
                    "{serviceName}": this.service.Name,
                    "https://intakedetailpage.com": this.communityIntakeUrl,    
                };
                this.formattedContent = replaceStrings(this.formattedContent, replacements);
            }
        }
    }
}