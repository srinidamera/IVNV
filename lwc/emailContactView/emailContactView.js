import { LightningElement, wire, api, track } from 'lwc';
import getContactEmailRecords from '@salesforce/apex/EmailContactController.getContactEmailRecords';
import { NavigationMixin } from 'lightning/navigation';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import CONTACT_EMAIL from '@salesforce/schema/Contact.Email';
export default class emailContactView  extends NavigationMixin(LightningElement) {

    sortedEmails = [];
    @track emaildata = [];
    @track isOpen = ''
    @track tabBoolean = false;
    @track prevIndex = 0;
    @track newIndex = 0;
    @track showSpinner;
    error;
    @api recordId;
    @track totalCount = 0;

    connectedCallback() {
        if(this.contactEmail){
            
        }
    }

    //Fetching Contact Email Address here
    @wire(getRecord, { recordId: '$recordId', fields: [CONTACT_EMAIL] }) contactRecord;
    get contactEmail() {
        return this.contactRecord.data ? getFieldValue(this.contactRecord.data, CONTACT_EMAIL):"";
    }
    //Fetching Contact Email 
    @wire(getContactEmailRecords, { RelatedToID: '$recordId' ,contactEmail:'$contactEmail' })
    wiredContactEmailRecords({ error, data }) {
        if (data) {
            this.totalCount = data.length;
                const processedEmails = data.map((email) => {
                    try {
                        email.TextBody = JSON.parse(email.TextBody);
                        email.Subject = (!email.Subject)?"":email.Subject;

                    } catch (error) {
                    }
                    return email;
                });
                this.emaildata = processedEmails;
        } else if (error) {
            this.error = 'Error retrieving email records';
        }
    }
    //Email Collapse and Expand Handler 
    handleExpandCollapse(event) {
        this.newIndex = parseInt(event.currentTarget.dataset.index);
        let emailTemplate = this.template.querySelector(`[data-is-desired-index="${this.newIndex}"]`);

        if (emailTemplate.style.display === 'block') {
            emailTemplate.style.display = 'none';
        } else {
            emailTemplate.style.display = 'block';
        }

        event.target.iconName = emailTemplate.style.display === 'block' ? 'utility:chevrondown' : 'utility:chevronright';

    }


    isSectionOpen(emailId) {
        return this.openSections.has(emailId);
    }

    viewRecord(event) {
        const emailId = event.currentTarget.dataset.id;
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: emailId,
                objectApiName: 'EmailMessage',
                actionName: 'view'
            },
        });

    }

    showAppointmentModal = false;

    handleActivityDisplay(event) {
        let locator = event.target.dataset.locator;
        let mainDiv = this.template.querySelector(`[data-id="${locator}"]`);

        let classList = mainDiv.classList;
        classList.toggle('slds-is-open');
        let iconName = event.target.iconName;
        if (iconName === 'utility:chevrondown') {
            event.target.iconName = 'utility:chevronright';
        } else {
            event.target.iconName = 'utility:chevrondown';
        }
    }

    openAppointmentModal() {
        this.selectedRecord = this.appointmentRecord;
        this.showAppointmentModal = true;
    }


    handleEmailClick(event) {
        const emailld = event.target.dataset.emailld;
        this.navigateToRecordPage(emailld);
    }
    navigateToRecordPage(recordId) {
        this[NavigationMixin.Navigate]({
            type: 'standard record Page',
            attributes: {
                recordId: recordid,
                actionName: 'view'
            }
        });
    }
    getEmailRecordUrl(recordId) {
        return '/lightning/r/EmailMessage/${recordId}/view';
    }

    formatDate(dateTimeString) {
        const options = { day: '2-digit', month: '2-digit', year: 'numeric' };
        const date = new Date(dateTimeString);
        return date.toLocaleDateString('en-US', options);
    }

    formatTime(dateTimeString) {
        const options = { hour: 'numeric', minute: 'numeric', hour12: true };
        const date = new Date(dateTimeString);
        return date.toLocaleTimeString('en-US', options);
    }
}