import { LightningElement } from 'lwc';
export default class UserProfile extends LightningElement {
    currentTab = "Profile";

    handleActive(event) {
        this.currentTab = event.target.value;
    }
}