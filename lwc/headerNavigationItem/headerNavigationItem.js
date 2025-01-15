import { LightningElement, api, track } from "lwc";
import { NavigationMixin } from "lightning/navigation";
import basepath from "@salesforce/community/basePath";
export default class HeaderNavigationItem extends NavigationMixin(
  LightningElement
) {
  @api menuItem;
  @api isMobile;
  @api isDesktop;

  @track href = "#";
  /**
   * the PageReference object used by lightning/navigation
   */
  pageReference;

  /*This LWC method constructs a URL for navigation based on the type of menu item provided, 
        using Salesforce's NavigationMixin.*/
  connectedCallback() {
    const { type, target, defaultListViewId } = this.menuItem;
    // get the correct PageReference object for the menu item type
    if (type === "SalesforceObject") {
      // aka "Salesforce Object" menu item
      this.pageReference = {
        type: "standard__objectPage",
        attributes: {
          objectApiName: target
        },
        state: {
          filterName: defaultListViewId
        }
      };
    } else if (type === "InternalLink") {
      // WARNING: Normally you shouldn't use 'standard__webPage' for internal relative targets, but
      // we don't have a way of identifying the Page Reference type of an InternalLink URL
      this.pageReference = {
        type: "standard__webPage",
        attributes: {
          url: basepath + target
        }
      };
    } else if (type === "ExternalLink") {
      // aka "External URL" menu item
      this.pageReference = {
        type: "standard__webPage",
        attributes: {
          url: target
        }
      };
    } else if (type === "Event" && target === "Logout") {
      /* Logout logic in handleClick */
    }
    // use the NavigationMixin from lightning/navigation to generate the URL for navigation.
    if (this.pageReference) {
      this[NavigationMixin.GenerateUrl](this.pageReference, true).then(
        (url) => {
          this.href = url;
          // console.log("this.href--> ", this.href);
        }
      );
    }
  }

  /*This LWC method dispatches a custom 'navigation' event, passing the current menu item as the event detail. */
  handleNavigation() {
    const selectEvent = new CustomEvent("navigation", {
      detail: this.menuItem
    });
    this.dispatchEvent(selectEvent);
  }

  /*This LWC method handles click events by navigating to a page reference if it exists; otherwise, it logs a warning. */
  handleClick(event) {
    event.stopPropagation();
    event.preventDefault();
    if (this.menuItem.target === "Logout") {
      const logoutUrl = `https://${location.host}/compassportalvforcesite/secur/logout.jsp`;
      window.location.href = logoutUrl;
    } else if (this.pageReference) {
      this[NavigationMixin.Navigate](this.pageReference);
      this.handleNavigation();
    } else {
      console.log(
        `Navigation menu type "${
          this.menuItem.type
        }" not implemented for item ${JSON.stringify(this.menuItem)}`
      );
    }
  }
}