import { LightningElement, api, wire } from 'lwc';
import { getContent } from 'experience/cmsDeliveryApi';
import siteId from '@salesforce/site/Id';
import basePath from '@salesforce/community/basePath';
import FORM_FACTOR from '@salesforce/client/formFactor';
import getMultiLangNavigationMenuItems from '@salesforce/apex/NavigationMenuItemsController.getMultiLangNavigationMenuItems';
import getAgencyProfileDetails from '@salesforce/apex/FooterController.getAgencyProfileDetails';
import isGuestUser from '@salesforce/user/isGuest';
import { CurrentPageReference } from 'lightning/navigation';
import { showToastMsg } from "c/lwrUtils";
import LANG from "@salesforce/i18n/lang";

import mobileTemplate from "./footerMobile.html";
import desktopTemplate from "./footerDesktop.html";


export default class EnhancedFooter extends LightningElement {
    @api footerMenuName;
    @api contentKeyNW;
    @api contentKeyAgency;
    @api contentKeyMessagingUser;
    @api nwLogoWidth;
    @api nwLogoHeight;
    @api agencyLogoWidth;
    @api agencyLogoHeight;

    @api contentKeyFacebook;
    @api contentKeyInstagram;
    @api contentKeyTwitter;
    @api contentKeyLinkedin;
    @api contentKeyYoutube;

    NW_LOGO;
    AGENCY_LOGO;
    MESSAGING_USER_LOGO;
    FACEBOOK_LOGO;
    INSTAGRAM_LOGO;
    TWITTER_LOGO;
    LINKEDIN_LOGO;
    YOUTUBE_LOGO;
    

    menuItems = [];
    publishedState;
    error;

    /* @description: LWC lifehook method to render mobile or desktop template based on device*/
    render() {
        return this.deviceType === 'mobile' ? mobileTemplate : desktopTemplate;
    }

    agencyProfileDetails;

    /* @description: Wire method for getting Agency Information for footer*/
    @wire(getAgencyProfileDetails)
    onGetAgencyProfileDetails(result) {
        if (result.data) {
            this.agencyProfileDetails = result.data;
        } else if(result.error){
            console.log('code error str : ', JSON.stringify(result.error));
        } 
    }

    /* @description: Wire method for getting CMS Workspace content detail of NW Logo using content key as image url*/
    @wire(getContent, {channelOrSiteId: siteId, contentKeyOrId: '$contentKeyNW'})
    onGetContentNW(result) {
        if (result.data) {
            this.NW_LOGO = basePath + '/sfsites/c' + result.data.contentBody["sfdc_cms:media"].url;
        } else if(result.error){
            console.log('code error str : ', JSON.stringify(result.error));
        } 
    }

    /* @description: Wire method for getting CMS Workspace content detail of Agency Logo using content key as image url*/
    @wire(getContent, {channelOrSiteId: siteId, contentKeyOrId: '$contentKeyAgency'})
    onGetContentAgency(result) {
        if (result.data) {
            this.AGENCY_LOGO = basePath + '/sfsites/c' + result.data.contentBody["sfdc_cms:media"].url;
        } else if(result.error){
            console.log('code error str : ', JSON.stringify(result.error));
        }
    }

    /* @description: Wire method for getting CMS Workspace content detail of Messaging user Logo using content key as image url*/
    @wire(getContent, {channelOrSiteId: siteId, contentKeyOrId: '$contentKeyMessagingUser'})
    onGetMessagingUser(result) {
        if (result.data) {
            this.MESSAGING_USER_LOGO = basePath + '/sfsites/c' + result.data.contentBody["sfdc_cms:media"].url;
        } else if(result.error){
            console.log('code error str : ', JSON.stringify(result.error));
        }
    }

    /* @description: Wire method for getting CMS Workspace content detail of Facebook Logo using content key as image url*/
    @wire(getContent, {channelOrSiteId: siteId, contentKeyOrId: '$contentKeyFacebook'})
    onGetFacebookIcon(result) {
        if (result.data) {
            this.FACEBOOK_LOGO = basePath + '/sfsites/c' + result.data.contentBody["sfdc_cms:media"].url;
        } else if(result.error){
            console.log('code error str : ', JSON.stringify(result.error));
        }
    }

    /* @description: Wire method for getting CMS Workspace content detail of Instagram Logo using content key as image url*/
    @wire(getContent, {channelOrSiteId: siteId, contentKeyOrId: '$contentKeyInstagram'})
    onGetInstagramIcon(result) {
        if (result.data) {
            this.INSTAGRAM_LOGO = basePath + '/sfsites/c' + result.data.contentBody["sfdc_cms:media"].url;
        } else if(result.error){
            console.log('code error str : ', JSON.stringify(result.error));
        }
    }

    /* @description: Wire method for getting CMS Workspace content detail of Twitter Logo using content key as image url*/
    @wire(getContent, {channelOrSiteId: siteId, contentKeyOrId: '$contentKeyTwitter'})
    onGetTwitterIcon(result) {
        if (result.data) {
            this.TWITTER_LOGO = basePath + '/sfsites/c' + result.data.contentBody["sfdc_cms:media"].url;
        } else if(result.error){
            console.log('code error str : ', JSON.stringify(result.error));
        }
    }

    /* @description: Wire method for getting CMS Workspace content detail of LinkedIn Logo using content key as image url*/
    @wire(getContent, {channelOrSiteId: siteId, contentKeyOrId: '$contentKeyLinkedin'})
    onGetLinkinIcon(result) {
        if (result.data) {
            this.LINKEDIN_LOGO = basePath + '/sfsites/c' + result.data.contentBody["sfdc_cms:media"].url;
        } else if(result.error){
            console.log('code error str : ', JSON.stringify(result.error));
        }
    }
    
    /* @description: Wire method for getting CMS Workspace content detail of Youtube Logo using content key as image url*/
    @wire(getContent, {channelOrSiteId: siteId, contentKeyOrId: '$contentKeyYoutube'})
    onGetYoutubeIcon(result) {
        if (result.data) {
            this.YOUTUBE_LOGO = basePath + '/sfsites/c' + result.data.contentBody["sfdc_cms:media"].url;
        } else if(result.error){
            console.log('code error str : ', JSON.stringify(result.error));
        }
    }

    /* @description: Wire method for getting Navigation menu its for selected footer navigation option in builder for footer*/
    @wire(getMultiLangNavigationMenuItems, {
        menuName: '$footerMenuName',
        publishedState: '$publishedState',
        language: LANG
    })
    wiredMenuItems({ error, data }) {
        if (data) {
            console.log('data wire->'+JSON.parse(JSON.stringify(data)));
            this.menuItems = data
                .map((item, index) => {
                    return {
                        target: item.Target,
                        id: index,
                        label: item.Label,
                        defaultListViewId: item.DefaultListViewId,
                        type: item.Type,
                        accessRestriction: item.AccessRestriction
                    };
                })
                .filter((item) => {
                    // Only show "Public" items if guest user
                    return (
                        item.accessRestriction === 'None' ||
                        (item.accessRestriction === 'LoginRequired' &&
                            !isGuestUser)
                    );
                });
            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.menuItems = [];
            let message = `Navigation menu error: ${JSON.stringify(
                this.error
            )}`;
            showToastMsg(
                this,
                "Error",
                message,
                "error"
            );
        }
    }

    /* @description: Wire method for getting CurrentPageReference*/
    @wire(CurrentPageReference)
    setCurrentPageReference(currentPageReference) {
        const app =
            currentPageReference &&
            currentPageReference.state &&
            currentPageReference.state.app;
        if (app === 'commeditor') {
            this.publishedState = 'Draft';
        } else {
            this.publishedState = 'Live';
        }
    }

    /* @description: getter for check device type*/
    get deviceType (){
        switch(FORM_FACTOR) {
            case 'Large':
                return 'desktop';
            case 'Medium':
                return 'tablet';
            case 'Small':
                return 'mobile';
            default:
        }
    }

    get hrefNW(){
        return this.agencyProfileDetails && this.agencyProfileDetails.AgencyWebsite__c ? this.agencyProfileDetails.AgencyWebsite__c : '';
    }
    
    /* @description: getter for check if navigation links to show in same row or in second row for mibile*/
    get showNavigationLinkInSameRow(){
        return this.menuItems && this.menuItems.length === 1 && !this.AGENCY_LOGO;
    }

    /* @description: getter for agency email*/
    get email(){
        return this.agencyProfileDetails && this.agencyProfileDetails.AgencyEmailAddress__c ? this.agencyProfileDetails.AgencyEmailAddress__c : '';
    }

    /* @description: getter for agency phone*/
    get phone(){
        return this.agencyProfileDetails && this.agencyProfileDetails.AgencyPhoneNumber__c ? this.agencyProfileDetails.AgencyPhoneNumber__c : '';
    }

    /* @description: getter for agency address street*/
    get street(){
        return this.agencyProfileDetails && this.agencyProfileDetails.AgencyAddress__c && this.agencyProfileDetails.AgencyAddress__c.street ? this.agencyProfileDetails.AgencyAddress__c.street : '';
    }

    /* @description: getter for agency address city*/
    get city(){
        return this.agencyProfileDetails && this.agencyProfileDetails.AgencyAddress__c && this.agencyProfileDetails.AgencyAddress__c.city ? this.agencyProfileDetails.AgencyAddress__c.city : '';
    }

    /* @description: getter for agency address state*/
    get state(){
        return this.agencyProfileDetails && this.agencyProfileDetails.AgencyAddress__c && this.agencyProfileDetails.AgencyAddress__c.state ? this.agencyProfileDetails.AgencyAddress__c.state : '';
    }

    /* @description: getter for agency address postal code*/
    get postalCode(){
        return this.agencyProfileDetails && this.agencyProfileDetails.AgencyAddress__c && this.agencyProfileDetails.AgencyAddress__c.postalCode ? this.agencyProfileDetails.AgencyAddress__c.postalCode : '';
    }

    /* @description: getter for agency address country*/
    get country(){
        return this.agencyProfileDetails && this.agencyProfileDetails.AgencyAddress__c && this.agencyProfileDetails.AgencyAddress__c.country ? this.agencyProfileDetails.AgencyAddress__c.country : '';
    }

    /* @description: getter for generating agency address line 2 for footer to show city, state, country and zip code*/
    get addressLine2(){
        let line2 = '';
        if(this.city){
            line2 = this.city;
        }

        if(this.state){
            line2 = line2 != '' ?  (line2 + ', ' + this.state) : this.state;
        }

        if(this.country){
            line2 = line2 != '' ?  (line2 + ', ' + this.country) : this.country;
        }

        if(this.postalCode){
            line2 = line2 != '' ?  (line2 + ', ' + this.postalCode) : this.postalCode;
        }

        return line2;
    }

    /* @description: getter for NW logo style using input provided from builder*/
    get nwLogoStyle(){
        let style = '';
        
        if(this.nwLogoHeight && parseInt(this.nwLogoHeight) !== 0){
            style = 'height:'+ this.nwLogoHeight + 'px;';
        } else {
            style = 'height:37px;'
        }

        if(this.nwLogoWidth && parseInt(this.nwLogoWidth) !== 0){
            style = style +  'width:'+ this.nwLogoWidth + 'px;';
        } else{
            style = style +  'width:64px;';
        }

        return style;
    }

    /* @description: getter for agency logo style using input provided from builder*/
    get agencyLogoStyle(){
        let style = '';
        
        if(this.agencyLogoHeight && parseInt(this.agencyLogoHeight) !== 0){
            style = 'height:'+ this.agencyLogoHeight + 'px;';
        } else {
            style = 'height:37px;'
        }

        if(this.agencyLogoWidth && parseInt(this.agencyLogoWidth) !== 0){
            style = style +  'width:'+ this.agencyLogoWidth + 'px;';
        } else{
            style = style +  'width:64px;';
        }

        return style;
    }

}