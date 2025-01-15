import { LightningElement, api } from "lwc";

export default class CustomAccordionSection extends LightningElement {
  @api label;
  @api uniqueId;
  @api collapseIcon = "utility:collapse_all";
  @api expandIcon = "utility:expand_all";
  @api showMenu = false;
  @api disableMenu = false;
  @api menuItems;
  _isExpanded = false;
  _selectedMenuItem;

  accordionClick() {
    this._isExpanded = !this._isExpanded;
  }

  handleOnselect(event) {
    if (this._selectedMenuItem !== event.detail.value) {
      this._selectedMenuItem = event.detail.value;
      this.dispatchEvent(
        new CustomEvent("menuselect", {
          detail: { uniqueId: this.uniqueId, status: event.detail.value }
        })
      );
    }
  }

  @api set selectedMenuItem(value) {
    this._selectedMenuItem = value;
  }

  get selectedMenuItem() {
    return this._selectedMenuItem;
  }

  get accordionIcon() {
    return this.isExpanded ? this.collapseIcon : this.expandIcon;
  }

  get isExpanded() {
    return this._isExpanded;
  }

  get sectionClass() {
    return this.isExpanded
      ? "slds-accordion__section slds-is-open"
      : "slds-accordion__section";
  }
}