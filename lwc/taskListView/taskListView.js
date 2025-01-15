import { LightningElement, api, track } from 'lwc';
import getOpenTasks from '@salesforce/apex/TaskListClass.getOpenTasks';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import completeTask from '@salesforce/apex/TaskListClass.completeTask';
import createTask from '@salesforce/apex/TaskListClass.createTask';
import { NavigationMixin } from 'lightning/navigation';
import hasShowButtonPermission from '@salesforce/apex/TaskListClass.hasShowButtonPermission'

export default class TaskListView extends NavigationMixin(LightningElement) {
    @api recordId;
    @track showDataModal = false;
    @track data = [];
    @track showSpinner = false;
    @track totalCount = 0;
    @track selectedDurationValue;
    @track isOverdue = false;
    @track assignedTo = "";
    @track currentTask = {};
    @track showButton = false; 

    connectedCallback() {
        this.fetchData();
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

    get statusOptions() {
        return [
            { label: 'Completed', value: 'Completed' },
            { label: 'In Progress', value: 'In Progress' },
            { label: 'Not Started', value: 'Not Started' }
        ];
    }

    get priorityOptions() {
        return [
            { label: 'High', value: 'High' },
            { label: 'Medium', value: 'Medium' },
            { label: 'Low', value: 'Low' }
        ]
    }

    handleFieldChange(event) {
        const field = event.target.name;
        if (field === 'Select Subject') {
            this.subject = event.target.value;
            this.currentTask.Subject = event.target.value;
        } else if (field === 'Description') {
            this.description = event.target.value;
            this.currentTask.Description = event.target.value;
        } else if (field === 'Status') {
            this.currentTask.Status = event.target.value;
        } else if (field == 'ActivityDate') {
            this.currentTask.ActivityDate = event.target.value;
        } else if (field === 'Priority') {
            this.currentTask.Priority = event.target.value;
        } else if (field == 'Name') {
            this.currentTask.Who.Name = event.target.value; editTask
        }
    }

    handleScroll(event) {
        if (event.target.scrollTop + event.target.clientHeight >= event.target.scrollHeight) {
            this.fetchData();
        }
    }


    handleEditClick(event) {
        const taskId = event.target.dataset.id;
        this.editTask(taskId);
    }

    handleClearFields() {
        this.subject = '';
        this.description = '';
        this.isReminderSet = false;
    }

    async editTask(taskId) {
        this.showSpinner = true;
        try {
            const task = await this.fetchTask(taskId);
            this.currentTask = {
                ...task.task,
                AssignedTo: task.ownerName
            };
            this.modalTitle = 'Edit Task';
            this.showDataModal = true;
        } catch (error) {
            console.error('Error fetching task', error);
        } finally {
            this.showSpinner = false;
        }
    }

    async fetchTask(taskId) {
        return this.data.find(task => task.task.Id === taskId);
    }

    handleCompleteClick(event) {
        let id = event.currentTarget.dataset.id;
        completeTask({ recId: id })
            .then(result => {
                this.showSpinner = false;
                this.showToast('Success', 'Task Completed successfully', 'success');
                this.fetchData();
            })
            .catch(error => {
                this.showSpinner = false;
                console.error('Error:', error);
            });
    }

    handleReassignClick(event) {
        const taskId = event.target.dataset.id;


        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: taskId,
                objectApiName: 'Task',
                actionName: 'view'
            },
        });

    }

    handleSave() {
        this.showSpinner = true;
        const now = new Date();
        const task = {
            Id: (this.currentTask.Id) ? this.currentTask.Id : null,
            Subject: this.currentTask.Subject,
            Description: this.currentTask.Description,
            Status: this.currentTask.Status,
            ActivityDate: this.currentTask.ActivityDate,
            Priority: this.currentTask.Priority,
        };
        createTask({ task })
            .then(result => {
                this.showSpinner = false;
                this.handleCancel();
                this.handleClearFields();
                if (!this.isSnooze) {
                    this.showToast('Success', 'Task Updated successfully', 'success');
                } else {
                    this.showToast('Success', 'Task Updated successfully', 'success');
                }
                this.fetchData();
            })
            .catch(error => {
                this.showSpinner = false;
                this.handleCancel();
                console.log('error ===>', JSON.stringify(error));
                this.showToast('Error', 'Error creating task', 'error');
            });
    }

    fetchData() {
        this.showSpinner = true;
        const now = new Date();
        const options = { day: '2-digit', month: '2-digit', year: 'numeric' };
        getOpenTasks({ recId: this.recordId })
            .then((result) => {
                this.totalCount = result.length;
                let objs = JSON.parse(JSON.stringify(result));
                objs.forEach(function (d) {
                    d.iconName = 'utility:chevronright';
                    d.divCss = 'slds-hide';
                    d.isOverdue = new Date(d.task.ActivityDate) < now;
                    let date = new Date(d.task.ActivityDate);
                    d.task.ActivityDate = date.toLocaleDateString('en-US', options);
                });
                this.data = objs;
            })
            .catch((error) => {
                this.error = error;
            })
            .finally(() => { this.showSpinner = false; });
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


    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
        });
        this.dispatchEvent(event);
    }

    handleCancel() {
        this.showDataModal = false;
        this.handleClearFields();
    }

    handleChange(event) {
        this.value = event.detail.value;
    }

    handleClick(event) {
        let selectedId = event.currentTarget.dataset.id;
        let objIndx = this.data.findIndex((item => item.task.Id == selectedId));
        if (this.data[objIndx].iconName == 'utility:chevrondown') {
            this.data[objIndx].iconName = 'utility:chevronright';
            this.data[objIndx].divCss = 'slds-hide';
        } else if (this.data[objIndx].iconName == 'utility:chevronright') {
            this.data[objIndx].iconName = 'utility:chevrondown';
            this.data[objIndx].divCss = 'slds-show';
        }
    }

    handleRefresh(event) {
        this.showSpinner = true;
        this.data = []
        this.page = 1
        this.fetchData(this.page, this.dateRange);
    }

}