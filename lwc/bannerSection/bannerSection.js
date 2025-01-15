import { LightningElement, api, wire } from "lwc";
import siteId from "@salesforce/site/Id";
import { getContent } from "experience/cmsDeliveryApi";
import basePath from "@salesforce/community/basePath";
import { NavigationMixin } from "lightning/navigation";
import LANG from "@salesforce/i18n/lang";
import { replaceStrings, capitalizeWords } from "c/lwrUtils";
import Id from "@salesforce/user/Id";
import USER_FULL_NAME from "@salesforce/schema/User.Name";
import { getRecord } from "lightning/uiRecordApi";
import isguest from "@salesforce/user/isGuest";

export default class BannerSection extends NavigationMixin(LightningElement) {
  @api bannerImgSrcKey;
  @api title;
  @api description;
  @api useHyperlinkTitle;
  @api redirectToPage;
  @api showWelcomeMsg;
  @api welcomeMsg;
  currentUserFullName;
  bannerImgSrc;

  @wire(getContent, {
    channelOrSiteId: siteId,
    contentKeyOrId: "$bannerImgSrcKey"
  })
  getAboutUsImage(result) {
    console.log(`LANG:: ${LANG}`);
    if (result.data) {
      this.bannerImgSrc =
        basePath + "/sfsites/c" + result.data.contentBody["sfdc_cms:media"].url;
    }
  }

  @wire(getRecord, {
    recordId: Id,
    fields: [USER_FULL_NAME]
  })
  currentUserInfo({ error, data }) {
    if (data) {
      this.currentUserFullName = data.fields.Name.value;
      this.error = error;
    }
  }

  onTitleClick() {
    this.navigateTo(this.redirectToPage);
  }

  navigateTo(pageName) {
    this[NavigationMixin.Navigate]({
      type: "comm__namedPage",
      attributes: {
        name: pageName
      }
    });
  }

  get formattedWelcomeMessage() {
    const mergeFields = {
      "{client_full_name}": capitalizeWords(this.currentUserFullName)
    };
    return replaceStrings(this.welcomeMsg, mergeFields);
  }

  get isHyperlinkTitle() {
    return this.useHyperlinkTitle === "Yes";
  }

  get displayWelcomeMsg() {
    return (
      this.showWelcomeMsg &&
      isguest === false &&
      this.currentUserFullName &&
      this.formattedWelcomeMessage
    );
  }
}