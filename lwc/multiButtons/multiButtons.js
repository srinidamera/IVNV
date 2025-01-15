import { LightningElement, api } from "lwc";
import { NavigationMixin } from "lightning/navigation";
import basepath from "@salesforce/community/basePath";
import { queryStringToJSON, isEmpty } from "c/lwrUtils";

export default class MultiButtons extends NavigationMixin(LightningElement) {
  @api btnLabels;
  @api btnTypes; // primary or secondary
  @api redirectToPage;
  @api queryParams; // page=1&size=2, page=3&size=4
  @api horizontalAlign; // Left, Right, Center

  btnTypeToStyleMap = {
    Primary: "btn btn-primary",
    Secondary: "btn btn-secondary"
  };

  btnTypeToVariantMap = {
    Primary: "brand",
    Secondary: "brand-outline"
  };

  alignmentStyle = {
    Left: "slds-grid_align-start",
    Right: "slds-grid_align-end",
    Center: "slds-grid_align-center"
  };

  get btnProps() {
    const props = [];
    const regex = /\s*,{1,}\s*/;
    const btnTypesList = this.btnTypes?.split(regex);
    const btnLabelsList = this.btnLabels?.split(regex);
    const redirectToPageList = this.redirectToPage?.split(regex);
    const queryParamsList = this.queryParams?.split(regex);

    btnLabelsList.forEach((elem, idx) => {
      if (elem.trim()) {
        const prop = {
          btnLabel: elem,
          redirectToPage: redirectToPageList?.at(idx),
          queryParams: queryParamsList?.at(idx),
          btnStyle: this.btnTypeToStyleMap[btnTypesList?.at(idx)],
          show_m_bottom: true,
          btnVariant: this.btnTypeToVariantMap[btnTypesList?.at(idx)]
        };
        props.push(prop);
      }
    });
    const propsSize = props.length;
    if (propsSize) {
      props[propsSize - 1].show_m_bottom = false;
    }
    return props;
  }

  /* method to naviagate to other pages */
  gotoPage(event) {
    console.log('go to');
    const pageName = event.target.value;
    const params = event?.currentTarget?.dataset?.queryParams;
    this.navigateTo(pageName, params);
  }

  /* method to naviagate to other pages */
  navigateTo(pageName, params) {
    if (pageName === "GO_BACK") {
      window.history.back();
    } else if (pageName === "LOG_OUT") {
      this.logout();
    } else {
      this[NavigationMixin.Navigate]({
        type: "comm__namedPage",
        attributes: {
          name: pageName
        },
        state:
          isEmpty(params) || params === "null" ? {} : queryStringToJSON(params)
      });
    }
  }

  logout() {
    const logoutUrl = `https://${location.host}/compassportalvforcesite/secur/logout.jsp`;
    window.location.href = logoutUrl;
  }

  get gridStyle() {
    return (
      "slds-grid slds-gutters slds-wrap " +
      this.alignmentStyle[this.horizontalAlign]
    );
  }

}