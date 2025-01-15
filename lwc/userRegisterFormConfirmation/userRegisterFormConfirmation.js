import { LightningElement, api } from "lwc";
import { NavigationMixin } from "lightning/navigation";
import { replaceStrings } from "c/lwrUtils";

export default class UserRegisterFormConfirmation extends NavigationMixin(
  LightningElement
) {
  @api title;
  @api description;
  @api btnLabel;
  @api userFirstName;
  @api userEmail;
  @api userAgencyName;

  /* method to redirect to home page */
  handleDone() {
    this[NavigationMixin.Navigate]({
      type: "comm__namedPage",
      attributes: {
        name: "Home"
      }
    });
  }

  get formattedDesc() {
    if (this.description) {
      const replacements = {
        "{User_First_Name}": this.userFirstName,
        "{User_Email_Address}": this.userEmail,
        "{Agency_Name}": this.userAgencyName
      };
      return replaceStrings(this.description, replacements);
    }
    return this.description;
  }
}