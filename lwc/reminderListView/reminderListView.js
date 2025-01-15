import { LightningElement, api, track, wire } from 'lwc';
import getTaskList from "@salesforce/apex/TaskListClass.getTaskList";
import createReminder from '@salesforce/apex/TaskListClass.createReminder';
import completeTask from '@salesforce/apex/TaskListClass.completeTask';
import getUserTimeZone from '@salesforce/apex/TaskListClass.getUserTimeZone';
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import hasShowButtonPermission from '@salesforce/apex/TaskListClass.hasShowButtonPermission'

export default class ReminderListView extends LightningElement {
    @api recordId;
    @track selectedDurationValue;
    @track showDataModal = null;
    @track subject = '';
    @track description = '';
    @track isReminderSet = false;
    @track subjectOptions;
    @track reminderdate;
    @track data = [];
    @track totalCount = 0;
    @track showSpinner = false;
    @track error = null;
    @track page = 1;
    @track pageSize = 11;
    @track dataId = '';
    @track lastRem = false;
    @track isReminder = false;
    @track dateRange = "Today";
    @track timezone;
    @track showButton = false;
    tasks = [];
    currentTask = {};
    value = 'Today';
    rendertrue = true;
    modalTitle = 'Create Reminder';
    isSnooze = false;
    

    connectedCallback() {
        this.fetchData(this.page);
        this.checkPermission();
    }

    async checkPermission() {
        try {
            const result = await hasShowButtonPermission();
            this.showButton = result;
            
        } catch (error) {
            console.error('Error checking permission', error);
        }
    }

     @wire(getUserTimeZone)
    wiredTimeZone({ error, data }) {
        if (data) {
            console.log(data);
             this.timezone = data;
            // this.convertTime();
        } else if (error) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error loading time zone',
                    message: error.body.message,
                    variant: 'error',
                }),
            );
        }
    }
    
    

    fetchData(pageData, dateRange) {
        this.showSpinner = true;
        const allTasks = [];
        let range = (!this.caseRecId && !dateRange)?this.dateRange:dateRange;
        const fetchAllPages = async () => {
            for (let currentPage = 1; currentPage <= pageData; currentPage++) {
                try {
                    const result = await getTaskList({ caseRecId: this.recordId, page: currentPage, pageSize: this.pageSize, dateRange: range });
                    this.isReminder = (this.recordId )?true:false;
                    if (result && result.length > 0) {
                        this.lastRem = false;
                        const objs = JSON.parse(JSON.stringify(result));
                        objs.forEach((d) => {
                            d.iconName = 'utility:chevronright';
                            d.divCss = 'slds-hide';
                            if (d.RecordType && d.RecordType.DeveloperName === 'Reminder') {
                                this.isReminder = true;
                            }
                        });
                        allTasks.push(...objs);
                        
                    }
                    else {
                        this.lastRem = true;
                        if (this.page > 1) {
                            this.page--;
                        }
                    }
                } catch (error) {
                    this.error = error;
                    console.error(`Error fetching data for page ${currentPage}:`, error);
                }
            }
            this.totalCount = allTasks.length;
            this.data = allTasks;
            this.showSpinner = false;
        };
        fetchAllPages();
    }

    handleOnselect(event) {
        this.dateRange = event.detail.value;
        this.page = 1
        this.fetchData(this.page, this.dateRange);
    }

    handleScroll(event) {
        if ((event.target.scrollTop + event.target.clientHeight + 1 >= event.target.scrollHeight) && !this.lastRem) {
            this.page++;
            this.fetchData(this.page, this.dateRange);
        }
        else if (event.target.scrollTop == 0) {
            this.lastRem = false;
        }
    }


    handleComboboxChange(event) {
        this.selectedValue = event.detail.value;
        this.fetchDuration();
    }

    fetchDuration() {
        this.showSpinner = true;
        getDurationList({ filterValue: this.selectedValue })
            .then((result) => {
                this.totalCount = result.length;
                let objs = JSON.parse(JSON.stringify(result));
                objs.forEach(function (d) {
                    d.iconName = 'utility:chevronright';
                    d.divCss = 'slds-hide';

                });
                this.data = objs;
            })
            .catch((error) => {
                this.error = error;
            })
            .finally(() => { this.showSpinner = false; });
    }

    addNewReminder() {
        this.isSnooze = false;
        this.modalTitle = 'Create Reminder';
        this.showDataModal = true;
        this.currentTask = {};
    }

    handleSave(event) {
        this.showSpinner = true;
        const task = {
            Id: (this.currentTask.Id) ? this.currentTask.Id : null,
            Subject: this.currentTask.Subject,
            Description: this.currentTask.Description,
            IsReminderSet: this.currentTask.IsReminderSet,
            ReminderDateTime: this.currentTask.ReminderDateTime
        };

        createReminder({ task })
            .then(result => {

                this.showSpinner = false;
                this.handleCancel();
                this.handleClearFields();
                if (!this.isSnooze) {
                    this.showToast('Success', 'Reminder Created successfully', 'success');
                } else {
                    this.showToast('Success', 'Reminder Updated successfully', 'success');
                }
                this.fetchData(this.page,this.dateRange);
            })
            .catch(error => {
                this.showSpinner = false;
                this.handleCancel();
                console.log('error ===>', JSON.stringify(error));
                this.showToast('Error', 'Error creating task', 'error');
            });
    }

    handleCancel() {
        this.showDataModal = false;
        this.handleClearFields();
        this.dataId = "";
    }

    handleClearFields() {
        this.subject = '';
        this.description = '';
        this.isReminderSet = false;
    }

    handleSnooze(event) {
        this.isSnooze = true;
        this.showDataModal = true;
        this.modalTitle = 'Snooze Reminder';
    }
    handleEdit(event) {
        this.dataId = event.currentTarget.dataset.id;
        this.modalTitle = 'Edit Reminder';
        this.showDataModal = true;
        this.isSnooze = false;
        this.fetchData(this.page, this.dateRange)
    }
    handleRow(event) {
        this.currentTask.Id = event.currentTarget.dataset.id;
        this.currentTask.Description = event.currentTarget.dataset.des;
        this.currentTask.Subject = event.currentTarget.dataset.sub;
        this.currentTask.IsReminderSet = event.currentTarget.dataset.reminder;
        this.currentTask.ReminderDateTime = event.currentTarget.dataset.time;
    }

    handleFieldChange(event) {
        const field = event.target.name;
        if (field === 'Select Subject') {
            this.subject = event.target.value;
            this.currentTask.Subject = event.target.value;
        } else if (field === 'Description') {
            this.description = event.target.value;
            this.currentTask.Description = event.target.value;
        } else if (field === 'IsReminderSet') {
            this.isReminderSet = event.target.checked;
            this.currentTask.IsReminderSet = event.target.value;
        } else if (field == 'date') {
            this.reminderdate = event.target.value;
            this.currentTask.ReminderDateTime = event.target.value;
            
        }
        }
    
    handleClick(event) {
        this.openRem = true;
        let selectedId = event.currentTarget.dataset.id;
        let objIndx = this.data.findIndex((item => item.Id == selectedId));
        if (this.data[objIndx].iconName == 'utility:chevrondown') {
            this.data[objIndx].iconName = 'utility:chevronright';
            this.data[objIndx].divCss = 'slds-hide';
        } else if (this.data[objIndx].iconName == 'utility:chevronright') {
            this.data[objIndx].iconName = 'utility:chevrondown';
            this.data[objIndx].divCss = 'slds-show';
        }
    }

    handleRefresh() {
        this.showSpinner = true;
        this.data = []
        this.page = 1
        this.fetchData(this.page, this.dateRange);
    }


    handleDismissClick(event) {
        let selectedId = event.currentTarget.dataset.id;
        this.completeTsk(selectedId)

            .catch((error) => {
                this.error = error;
            })
            .finally(() => {
                this.showSpinner = false;
                this.fetchData(this.page, this.dateRange);
            });
    }

    completeTsk(id) {
        this.showSpinner = true;
        completeTask({ recId: id })
            .then(result => {
                this.showSpinner = false;
                this.showToast('Success', 'Reminder dismissed successfully', 'success');
                this.page = 1
                this.fetchData(this.page, this.dateRange);
            })
            .catch(error => {
                this.showSpinner = false;
                console.error('Error:', error);
            });
    }

    showToast(title, message, variant) {
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(evt);
    }

}