import { LightningElement, api } from "lwc";
import { NavigationMixin } from "lightning/navigation";

export default class BreadCrumb extends NavigationMixin(LightningElement) {
  @api displayLabels;
  @api redirectToPage;

  get properties() {
    const regex = /\s*,{1,}\s*/;
    const displayLabelsList = this.displayLabels?.split(regex);
    const redirectToPageList = this.redirectToPage?.split(regex);
    const props = [];
    displayLabelsList.forEach((elem, idx) => {
      if (elem.trim()) {
        const prop = {
          label: elem,
          redirectToPage: redirectToPageList?.at(idx),
          style: idx < displayLabelsList.length - 1 ? "hyper-link" : "",
          isHyperlink: idx < displayLabelsList?.length - 1
        };
        props.push(prop);
      }
    });
    return props;
  }

  /* method to call on anchor click */
  goToPage(event) {
    const redirectToPage = event?.currentTarget?.dataset?.item;
    this.navigateTo(redirectToPage);
  }

  /* method to redirect to other pages */
  navigateTo(pageName) {
    this[NavigationMixin.Navigate]({
      type: "comm__namedPage",
      attributes: {
        name: pageName
      }
    });
  }
}