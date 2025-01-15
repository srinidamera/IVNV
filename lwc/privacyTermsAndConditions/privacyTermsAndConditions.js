import { LightningElement, api, wire} from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { getContent } from 'experience/cmsDeliveryApi';
import basePath from "@salesforce/community/basePath";
import siteId from '@salesforce/site/Id';

export default class PrivacyTermsAndConditions extends NavigationMixin(LightningElement) {
    @api privacyTermsImageKey;

    securityContent;
    privacyTermsImageURL;

    /* @description: Wire method for getting CMS Workspace content detail of Backgroud image for Privacy Terms page using content key as image url*/
    @wire(getContent, {channelOrSiteId: siteId, contentKeyOrId: '$privacyTermsImageKey'})
    getPrivacyTermImage(result) {
        if (result.data) {
            this.privacyTermsImageURL = basePath + "/sfsites/c" + result.data.contentBody["sfdc_cms:media"].url;
        } else if(result.error){
            console.log('code error str : ', JSON.stringify(result.error));
        } 
    }

    /* @description: Handler method to navigate to home page*/
    navigateToHomePage() {
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url: basePath + '/'
            },
        });
    }


}