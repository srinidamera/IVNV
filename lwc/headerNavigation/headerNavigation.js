import { LightningElement, api, wire } from "lwc";
import getMultiLangNavigationMenuItems from "@salesforce/apex/NavigationMenuItemsController.getMultiLangNavigationMenuItems";
import getUserLoginDetails from "@salesforce/apex/CommunityUserController.getUserLoginDetails";
import { CurrentPageReference, NavigationMixin } from "lightning/navigation";
import siteId from "@salesforce/site/Id";
import basepath from "@salesforce/community/basePath";
import { getContent } from "experience/cmsDeliveryApi";
import LANG from "@salesforce/i18n/lang";
import activeLanguages from "@salesforce/site/activeLanguages";
import isGuestUser from "@salesforce/user/isGuest";
import FORM_FACTOR from "@salesforce/client/formFactor";
import mobileTemplate from "./headerMobile.html";
import desktopTemplate from "./headerNavigation.html";
import { getUTCDifferenceInSeconds } from "c/lwrUtils";

export default class HeaderNavigation extends NavigationMixin(
  LightningElement
) {
  @api leftMenuName;
  @api rightMenuName;
  @api contentKey;
  @api nwLogoWidth;
  @api nwLogoHeight;
  @api toastTitleKey;
  @api toastMessageKey;
  @api welcomeMsg;

  toastTitle;
  toastMessage;

  error;
  leftMenuData;
  rightMenuData;
  leftMenuItems = [];
  rightMenuItems = [];
  publishedState;
  logoImageUrl;
  languages = [];
  selectedLanguage;
  isLanguageSectionOpen = false;

  @wire(getContent, {
    channelOrSiteId: siteId,
    contentKeyOrId: "$toastTitleKey"
  })
  getToastTitle(result) {
    if (result?.data?.contentBody?.Value) {
      this.toastTitle = result.data.contentBody.Value;
      this.showToastOnFirstTimeLogin();
    }
  }

  @wire(getContent, {
    channelOrSiteId: siteId,
    contentKeyOrId: "$toastMessageKey"
  })
  getToastMessage(result) {
    if (result?.data?.contentBody?.Value) {
      this.toastMessage = result.data.contentBody.Value;
      this.showToastOnFirstTimeLogin();
    }
  }

  /*This method sets the chosen language based on the user's preference from the URL or 
        defaults to a predefined language. */
  prepareLanguages() {
    let userCurrentLanguage = this.getLanguageCodeFromURL();
    let tempLanguages = activeLanguages;
    let languageFound = false;
    for (let i = 0; i < tempLanguages.length; i++) {
      if (userCurrentLanguage == tempLanguages[i].code) {
        this.selectedLanguage = tempLanguages[i];
        tempLanguages[i].isActive = true;
        languageFound = true;
        break;
      }
    }
    if (!languageFound) {
      for (let i = 0; i < tempLanguages.length; i++) {
        if (tempLanguages[i].default) {
          this.selectedLanguage = tempLanguages[i];
          tempLanguages[i].isActive = true;
        } else {
          tempLanguages[i].isActive = false;
        }
      }
    }
    this.languages = tempLanguages;
  }

  /*This method extracts the language code from the current page URL using a regular expression and returns it. 
    If no language code is found, it returns null. */
  getLanguageCodeFromURL() {
    // Get the current page URL
    var url = window.location.href;
    // Regular expression to match language code pattern (e.g., /es/)
    var languageCodeRegex = /\/([a-z]{2})\//;
    // Match the language code pattern in the URL
    var match = url.match(languageCodeRegex);
    // If a match is found, return the language code, otherwise return null
    if (match && match.length > 1) {
      return match[1]; // The language code is captured in the first group of the regex
    } else {
      return null; // Return null if no language code is found
    }
  }

  /* @description: getter for check device type*/
  get deviceType() {
    switch (FORM_FACTOR) {
      case "Large":
        return "desktop";
      case "Medium":
        return "tablet";
      case "Small":
        return "mobile";
      default:
    }
  }

  /* @description: LWC lifehook method to render mobile or desktop template based on device*/
  render() {
    return this.deviceType === "mobile" ? mobileTemplate : desktopTemplate;
  }

  /* @description: It will fetch the left side of the menus*/
  @wire(getMultiLangNavigationMenuItems, {
    menuName: "$leftMenuName",
    publishedState: "$publishedState",
    language: LANG
  })
  leftMenus({ error, data }) {
    if (data) {
      this.leftMenuData = data;
      this.buildLeftNavMenu(data);
      this.error = undefined;
    } else if (error) {
      this.error = error;
      this.leftMenuItems = [];
    }
  }

  buildLeftNavMenu(data) {
    if (data) {
      this.leftMenuItems = data
        .map((item, index) => {
          return {
            target: item.Target,
            id: index,
            activeClass:
              this.currentActivePage === item.Target ? `active-tab` : ``,
            label: item.Label,
            defaultListViewId: item.DefaultListViewId,
            type: item.Type,
            accessRestriction: item.AccessRestriction,
            menuSide: "left"
          };
        })
        .filter((item) => {
          // Only show "Public" items if guest user
          return (
            item.accessRestriction === "None" ||
            (item.accessRestriction === "LoginRequired" && !isGuestUser)
          );
        });
    }
  }

  /* @description: It will fetch the right side of the menus*/
  @wire(getMultiLangNavigationMenuItems, {
    menuName: "$rightMenuName",
    publishedState: "$publishedState",
    language: LANG
  })
  rightMenus({ error, data }) {
    if (data) {
      this.rightMenuData = data;
      this.buildRightNavMenu(data);
      this.error = undefined;
    } else if (error) {
      this.error = error;
      this.rightMenuItems = [];
    }
  }

  buildRightNavMenu(data) {
    if (data) {
      this.rightMenuItems = data
        .map((item, index) => {
          return {
            target: item.Target,
            id: index,
            activeClass:
              this.currentActivePage === item.Target ? "active-tab" : "",
            label: item.Label,
            defaultListViewId: item.DefaultListViewId,
            type: item.Type,
            accessRestriction: item.AccessRestriction,
            menuSide: "right",
            isLanguage: false
          };
        })
        .filter((item) => {
          // Only show "Public" items if guest user
          return (
            (item.accessRestriction === "None" &&
              (item.label !== "Login" && item.label !== "Iniciar sesión" || isGuestUser)) ||
            
            (item.accessRestriction === "LoginRequired" && !isGuestUser) 
          );
        });
      this.rightMenuItems[this.rightMenuItems.length - 1].isLanguage = true;
    }
  }

  /*This wire method sets the published state based on the current app state: "Draft" if the app is "commeditor", otherwise "Live". */
  @wire(CurrentPageReference)
  setCurrentPageReference(currentPageReference) {
    const app =
      currentPageReference &&
      currentPageReference.state &&
      currentPageReference.state.app;
    if (app === "commeditor") {
      this.publishedState = "Draft";
    } else {
      this.publishedState = "Live";
    }
    this.buildLeftNavMenu(this.leftMenuData);
    this.buildRightNavMenu(this.rightMenuData);
  }

  /* @description: this method is used to fetch the logo from CMS*/
  @wire(getContent, { channelOrSiteId: siteId, contentKeyOrId: "$contentKey" })
  onGetContent(result) {
    if (result.data) {
      this.logoImageUrl =
        basepath + "/sfsites/c" + result.data.contentBody["sfdc_cms:media"].url;
    }
  }

  /* @description: This method will dynamically make the header menus active and inactive*/
  handleMenuChange(item) {
    let menuSide = item.menuSide;
    let index = item.id;
    this.leftMenuItems = JSON.parse(
      JSON.stringify(this.makeTheMenuInactive(this.leftMenuItems, "left"))
    );
    this.rightMenuItems = JSON.parse(
      JSON.stringify(this.makeTheMenuInactive(this.rightMenuItems, "right"))
    );
    this.rightMenuItems[this.rightMenuItems.length - 1].isLanguage = true;
    if (menuSide == "left") {
      this.leftMenuItems[index].activeClass = `active-tab`;
    } else if (menuSide == "right") {
      this.rightMenuItems[index].activeClass =
        `slds-context-bar__item_divider active-tab`;
    }
  }

  makeTheMenuInactive(menus, menuSide) {
    return menus.map((item, index) => {
      return {
        target: item.target,
        id: item.id,
        activeClass: menuSide == "left" ? `` : `slds-context-bar__item_divider`,
        label: item.label,
        defaultListViewId: item.defaultListViewId,
        type: item.type,
        accessRestriction: item.accessRestriction,
        menuSide: menuSide
      };
    });
  }

  /* @description: this method will change the language of the page*/
  handleLanguageMenuSelect(evt) {
    //console.log('handleLanguageMenuSelect : ',evt.detail.value);
    //event.currentTarget.dataset.langcode
    const selectedLanguageCode = evt.detail.value;
    // locale is in base path and needs to be replaced with new locale
    const newBasePath = this.updateLocaleInBasePath(
      basepath,
      LANG,
      selectedLanguageCode
    );

    const currentUrl = window.location.pathname;
    const queryUrl = window.location.search;
    if (currentUrl) {
      const restOfUrl = currentUrl.substring(basepath.length);
      //window.location.href = window.location.origin + newBasePath + restOfUrl;

      let url = window.location.origin + newBasePath + restOfUrl;
      url += queryUrl && queryUrl != "" ? queryUrl : "";
      window.location.href = url;
    } else {
      // WARNING: this is a current limitation of Lightning Locker in LWR sites
      // Locker must be disabled to reference the global window object
      console.warn(
        "Lightning Locker must be disabled for this language picker component to redirect"
      );
    }
  }
  /* @description: this method is helper method of handleMenuSelect*/
  updateLocaleInBasePath(path, oldLocale, newLocale) {
    if (path.endsWith("/" + oldLocale)) {
      // replace with new locale
      return path.replace(new RegExp("/" + oldLocale + "$"), "/" + newLocale);
    } else {
      // since the default locale is not present in the base path,
      // append the new locale
      return path + "/" + newLocale;
    }
  }

  handleNavigation(event) {
    setTimeout(() => {
      this.handleMenuChange(event.detail);
    }, 0);
  }
  handleLanguageChangeOnDesktop() {
    this.template.querySelector("lightning-button-menu").click();
  }

  /*This method dynamically generates a style string for the NW logo based on provided height and width values, 
    defaulting to preset dimensions if none are given. */
  get nwLogoStyle() {
    let style = "";
    if (this.nwLogoHeight && parseInt(this.nwLogoHeight) !== 0) {
      style = "height:" + this.nwLogoHeight + "px;";
    } else {
      style = "height:20px;";
    }

    if (this.nwLogoWidth && parseInt(this.nwLogoWidth) !== 0) {
      style = style + "width:" + this.nwLogoWidth + "px;";
    } else {
      style = style + "width:41px;";
    }

    return style;
  }

  get isUserLogin() {
    let style = "";
    if (!isGuestUser) {
      style =
        "--slds-c-icon-color-foreground-default: var(--dxp-g-brand) !important";
    }
    return style;
  }

  openLanguagesSection() {
    event.stopPropagation();
    this.isLanguageSectionOpen = !this.isLanguageSectionOpen;
  }

  /*This method handles language selection based on the clicked language code, 
    updating the selected language and toggling its active state. 
    Then, it triggers a language menu selection event. */
  handleLanguageSelection(event) {
    for (let i = 0; i < this.languages.length; i++) {
      if (this.languages[i].code == event.currentTarget.dataset.langcode) {
        this.selectedLanguage = this.languages[i];
        this.languages[i].isActive = true;
      } else {
        this.languages[i].isActive = false;
      }
    }
    const detail = {
      detail: {
        value: event.currentTarget.dataset.langcode
      }
    };
    this.handleLanguageMenuSelect(detail);
  }

  /*Start Handle Mobile Menu */
  _handler;
  handleOnClick(event) {
    event.stopPropagation();
    this.template
      .querySelector('[data-id="combobox-drop-down-id-137-custom"]')
      ?.classList?.toggle("slds-is-open");
  }

  connectedCallback() {
    this.prepareLanguages();
    document.addEventListener(
      "click",
      (this._handler = this.handleCloseMobileMenu.bind(this))
    );
    this.showToastOnFirstTimeLogin();
  }

  renderedCallback() {}

  handleCloseMobileMenu() {
    this.isLanguageSectionOpen = false;
    this.template
      .querySelector('[data-id="combobox-drop-down-id-137-custom"]')
      ?.classList?.remove("slds-is-open");
  }

  disconnectedCallback() {
    document.removeEventListener("click", this._handler);
  }
  /*End Handle Mobile Menu */

  /* toast message methods */
  showToastOnFirstTimeLogin() {
    if (
      this.currentActivePage === "/" &&
      this.toastTitle &&
      this.toastMessage
    ) {
      getUserLoginDetails()
        .then((result) => {
          const lastLoginTimeDifference = getUTCDifferenceInSeconds(
            result.lastLoginTime,
            new Date().toISOString()
          );
          if (result.isLoggingFirstTime) {
            this.showFirstTimeLoginToast(result.userFirstName);
          } else {
            if (lastLoginTimeDifference < 20) {
              this.showWelcomeToastMsg(result.userFirstName);
            }
          }
        })
        .catch((error) => {
          console.log("error-::", JSON.stringify(error));
        });
    }
  }

  showFirstTimeLoginToast(clientName) {
    const toast = this.refs.toast;
    toast.showToastMessage({
      title: this.toastTitle,
      message: this.toastMessage,
      toastVariant: "theme",
      // iconName: "action:check",
      iconName: "standard:task2",
      autoClose: false,
      autoCloseTime: 3000,
      mergeFields: { "{Client_Name}": clientName }
    });
  }

  showWelcomeToastMsg(clientName) {
    const toast = this.refs.toast;
    toast.showToastMessage({
      title: this.welcomeMsg,
      message: "",
      toastVariant: "theme",
      // iconName: "action:check",
      iconName: "standard:task2",
      autoClose: false,
      autoCloseTime: 3000,
      mergeFields: { "{Client_Name}": clientName }
    });
  }

  get currentActivePage() {
    const relativeUrl = window.location.pathname;
    return relativeUrl.substring(relativeUrl.lastIndexOf("/"));
  }

  navigateToProfile() {
    console.log("in navigate");
    this[NavigationMixin.Navigate]({
      type: "standard__webPage",
      attributes: {
        url: "/profile"
      }
    });
  }
}