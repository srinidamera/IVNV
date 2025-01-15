import { LightningElement, wire, api, track } from 'lwc';
import getEmailRecords from '@salesforce/apex/EmailController.getEmailRecords';
import { NavigationMixin } from 'lightning/navigation';
import hasShowButtonPermission from '@salesforce/apex/TaskListClass.hasShowButtonPermission'

export default class CustomEmailList extends NavigationMixin(LightningElement) {
    sortedEmails = [];
    @track emaildata = [];
    @track isOpen = ''
    @track tabBoolean = false;
    @track prevIndex = 0;
    @track newIndex = 0;
    error;
    @api recordId;
    @track totalCount = 0;
    @track toRedirect = false;

    async checkPermission() {
        try {
            const result = await hasShowButtonPermission();
            this.toRedirect = result;
            
        } catch (error) {
            console.error('Error checking permission', error);
        }
    }
    connectedCallback() {
        this.fetchData();
        this.checkPermission();
    }
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
    visibility = {
        timeline01: true,
        timeline02: true,
        timeline03: true,
        timeline04: true,
        timeline05: true,
        timeline06: true,
        timeline07: true,
        timeline08: true,
        timeline09: true
    }
    showAppointmentModal = false;
    handleActivityDisplay(event) {
        let locator = event.target.dataset.locator;
        console.log('Locator : ', locator);
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
    fetchData() {
        this.showSpinner = true;
        getEmailRecords({ recId: this.recordId })
            .then((result) => {
                this.totalCount = result.length;
                const processedEmails = result.map((email) => {
                    try {
                        email.TextBody = JSON.parse(email.TextBody);
                    } catch (error) {
                        console.error('Error parsing TextBody:', error);
                    }
                    return email;
                });
                this.emaildata = processedEmails;
            })
            .catch((error) => {
                this.error = error;
            })
            .finally(() => {
                this.showSpinner = false;
            });
    }
    @wire(getEmailRecords, { RelatedToID: '$recordId' })
    wiredEmailRecords({ error, data }) {
        if (data) {
            const sortedEmails = [...data];
            sortedEmails.sort((a, b) => {
                if (a.Subject < b.Subject) {
                    return -1;
                }
                if (a.Subject > b.Subject) {
                    return 1;
                }
                return 0;
            });
            this.sortedEmails = sortedEmails.map((email) => ({
                ...email,
                formattedDate: this.formatDate(email.MessageDate),
                formattedTime: this.formatTime(email.MessageDate),
                url: this.getEmailRecordUrl(email.ld)
            }));
            this.error = undefined;
        } else if (error) {
            this.error = 'Error retrieving email records';
            this.sortedEmails = undefined;
        }
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