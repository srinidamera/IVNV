import { LightningElement, api } from "lwc";
import { NavigationMixin } from "lightning/navigation";

export default class HomePage extends NavigationMixin(LightningElement) {
  /* Content Keys */
  @api aboutUsImageKey;
  @api servicesImageKey;
  @api classesImageKey;

  /* public properties */
  // Section-1
  @api sectionOneTitle;
  @api sectionOneDesc;
  @api sectionOneBtnOneLabel;
  @api sectionOneBtnTwoLabel;

  // Section-2
  @api sectionTwoTitle;
  @api sectionTwoDesc;
  @api sectionTwoBtnOneLabel;

  // Section-3
  @api sectionThreeTitle;
  @api sectionThreeDesc;
  @api sectionThreeBtnOneLabel;

  /* wire calls to get data from CMS' contents object */
  /* method to redirect to About us page */
  goToAboutUs() {
    this.navigateTo("AboutUs__c");
  }

  /* method to redirect to Services page */
  goToServices() {
    this.navigateTo("Service__c");
  }

  /* method to redirect to clases page */
  goToClasses() {
    this.navigateTo("Classes__c");
  }

  /* method to redirect to login page */
  goToLogin() {
    this.navigateTo("Login");
  }

  /* method to redirect to Signup/Registration page */
  goToSignUp() {
    this.navigateTo("Register");
  }

  /* method to naviagate to other pages */
  navigateTo(pageName) {
    this[NavigationMixin.Navigate]({
      type: "comm__namedPage",
      attributes: {
        name: pageName
      }
    });
  }
}