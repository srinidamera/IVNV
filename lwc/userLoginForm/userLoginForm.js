import { LightningElement, track,wire, api } from 'lwc';
import doLogin from '@salesforce/apex/CommunityAuthController.doLogin';
import { NavigationMixin } from 'lightning/navigation';
import basePath from '@salesforce/community/basePath';
import { CurrentPageReference } from "lightning/navigation";
export default class UserLoginForm extends NavigationMixin(LightningElement) {

    @api loginTitle;
    @api description;
    @api emailAddressLabel;
    @api passwordLabel;
    @api invalidEmailFormat;
    @api loginButtonTitle;
    @api createNewAccountButtonTitle;
    @api goBackButtonTitle;
    @api forgotPasswordButtonTitle;
    @api builderPasswordErrorMessage;
    username;
    password;
    previousPage;
    @track errorCheck;
    @track errorMessage;

    @track isPasswordVisible = false;

    get inputType() {
        return this.isPasswordVisible ? 'text' : 'password';
    }

    get iconName() {
        return this.isPasswordVisible ? 'utility:hide' : 'utility:preview';
    }

    togglePasswordVisibility() {
        this.isPasswordVisible = !this.isPasswordVisible;
    }

    handleUserNameChange(event) {
        this.username = event.target.value;
    }
    handlePasswordChange(event) {
        this.password = event.target.value;
    }

    connectedCallback() {
        console.log('OUTPUT basePath', basePath);
        const communityUrl = `https://${location.host}${basePath}/`;
        console.log('connectedCallback communityUrl : ', communityUrl);
        this.template.addEventListener('keydown', this.handleKeyDown.bind(this));
    }

    handleKeyDown(event) {
        // Check if the pressed key is Enter
        if (event.key === 'Enter') {
            this.handleEnterKeyPress();
        }
    }

    handleEnterKeyPress() {
        if (this.username && this.password) {
            this.loginHandler();
        }
    }

    /*@description: This method send the username password to server and get the user logged in*/
    handleLogin(event) {
        if (this.username && this.password) {
            event.preventDefault();
            this.loginHandler();
        }
    }


    redirectToForgetPassword(e) {
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url: '/ForgotPassword?previous=login'
            }
        });
    }

    loginHandler(){
        doLogin({ username: this.username, password: this.password })
                .then((result) => {
                    window.location.href = result;
                })
                .catch((error) => {
                    this.error = error;
                    this.errorCheck = true;
                    this.errorMessage = error.body.message;
                    console.log('OUTPUT : error.body.message', error.body.message);
                    if(
                        error?.body?.message?.includes("Make sure the username and password are correct") || 
                        error?.body?.message?.includes("Asegúrese de que el nombre de usuario y la contraseña son correctos")
                    ){
                        let inputIcon = this.template.querySelector('.input-icon');
                        inputIcon.classList.add('icon-align');
                        let passwordField = this.template.querySelector(".password-field");
                        passwordField.setCustomValidity(this.builderPasswordErrorMessage);
                        passwordField.reportValidity();
                    }
                });
    }
    redirectToRegister(e) {
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url: '/SelfRegister?previous=login'
            }
        });
    }
    goBackPreviousPage() {
        if(this.previousPage == 'SelfRegister'){
            this.redirectToRegister();
        }else if(this.previousPage == 'ForgotPassword'){
            this.redirectToForgetPassword();
        }else if(this.previousPage == 'Home'){
            window.location.href = `https://${location.host}${basePath}/`;
        }else{
            window.location.href = `https://${location.host}${basePath}/`;
        }
        
    }

    @wire(CurrentPageReference)
    pageReference({ state }) {
        if (state && state.previous) {
            this.previousPage = state.previous;
            console.log('state.previous : ', state.previous);
        }
    }
}