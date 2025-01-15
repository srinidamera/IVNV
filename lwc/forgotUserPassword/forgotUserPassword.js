/**
 * @description  : LWC for Compass Portal Site forgot password
 **/
import { LightningElement, api } from "lwc";
import { NavigationMixin } from "lightning/navigation";
import resetCommunityUserPassword from "@salesforce/apex/ForgotUserPasswordController.resetCommunityUserPassword";
import { showToastMsg, isValidEmail, isEmpty } from "c/lwrUtils";

export default class ForgotUserPassword extends NavigationMixin(
  LightningElement
) {

  @api headerText;
  @api headerDescription;
  @api fieldLabel;
  @api sendButtonLabel;
  @api backButtonLabel;
  @api resendButtonLabel;
  @api emailSuccessfullyTriggeredMsg;
  @api emailSentLabel;
  disableInput = false;
  disableSendBtn = false;
  disableReSendBtn = true;

  /* method to send recovery link to users email */
  sendRecoveryLink() {
    const emailField = this.refs.emailField;
    if (this.checkEmailValidity()) {
      this.disableSendBtn = true;
      this.disableInput = true;
      resetCommunityUserPassword({ email: emailField.value })
        .then(() => {
          this.disableReSendBtn = false;
          showToastMsg(
            this,
            this.emailSentLabel,
            this.emailSuccessfullyTriggeredMsg ? this.emailSuccessfullyTriggeredMsg : 'An email has been sent to you with a link to change your password.',
            "success"
          );
        })
        .catch(() => {
          showToastMsg(
            this,
            "Something Went Wrong!",
            "We're unable to reset your password at this moment.",
            "error"
          );
        });
    }
  }

  /* method to redirect to login page */
  goBack() {
    this[NavigationMixin.Navigate]({
      type: "comm__namedPage",
      attributes: {
        name: "Login"
      }
    });
  }

  /* method to validate email entered by user */
  checkEmailValidity() {
    const emailField = this.refs.emailField;
    let isValid = false;
    if (isEmpty(emailField.value)) {
      emailField.reportValidity();
      isValid = false;
    } else if (isValidEmail(emailField.value)) {
      emailField.setCustomValidity("");
      emailField.reportValidity();
      isValid = true;
    } else {
      emailField.reportValidity();
      isValid = false;
    }
    return isValid;
  }
}