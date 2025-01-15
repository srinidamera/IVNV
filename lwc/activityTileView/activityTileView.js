import { LightningElement, api, track } from 'lwc';
import getParticipants from '@salesforce/apex/ActivityTimelineController.getParticipants';
import { NavigationMixin } from 'lightning/navigation';
import getEventWrapper from '@salesforce/apex/ActivityTimelineController.getEventWrapper';


export default class ActivityTileView extends NavigationMixin(LightningElement) {

    @api objectId;
    @api eventType;
    @api relatedId;
    @api clientCase;

    @track participants = [];
    @track durationInMin = '';
    @track notes = '';
    @track purpose;
    @track outcomes;
    @track appointmentStatus;

    //@description : To bring the list of co applicants if event type is Event.
    connectedCallback() {
        if (this.objectId && this.eventType && this.eventType === 'Event') {
            getEventWrapper({ eventId: this.objectId })
            .then(data => {
                console.log('Data for Participants : ', JSON.stringify(data));
                if(data){
                    this.durationInMin = data.durationInMin;
                    this.notes = data.notes;
                    this.participants = data.participants;
                    this.purpose = data.purpose;
                    this.outcomes = data.outcome;
                    this.appointmentStatus = data.appointmentStatus;
                }
            })
        }
    }

    //@Descripton : To check if activity is of type event
    get isEvent() {
        return this.eventType === 'Event';
    }

    //@descripton : To check if activity is of type note
    get isNote() {
        return this.eventType === 'Note';
    }

    //@description : To check if activity is of type course
    get isCourse() {
        return this.eventType === 'Course';
    }

    get clientCaseName() {
        return this.clientCase?.name;
    }

    navigateToClientCase() {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.clientCase?.recordId,
                objectApiName: 'ClientCase__c',
                actionName: 'view'
            },
        });
    }

    @api refreshNotes(){
        console.log('@@@ inside subscribe');
        if (this.objectId && this.eventType && this.eventType === 'Event') {
            getEventWrapper({ eventId: this.objectId })
            .then(data => {
                console.log('Data for Participants : ', JSON.stringify(data));
                if(data){
                    this.durationInMin = data.durationInMin;
                    this.notes = data.notes;
                    this.participants = data.participants;
                    this.purpose = data.purpose;
                    this.outcomes = data.outcome;
                    this.appointmentStatus = data.appointmentStatus;
                }
            })
        }
    }

}