import { LightningElement,api,wire,track } from 'lwc';
import { RefreshEvent } from 'lightning/refresh';
import { getRecord } from 'lightning/uiRecordApi';
import getJobDetails from '@salesforce/apex/HudGenerateAndSubmitController.getJobDetails';
import executeBatch from '@salesforce/apex/HudGenerateAndSubmitController.executeBatch';
import executeSubmissionBatch from '@salesforce/apex/HudGenerateAndSubmitController.executeSubmissionBatch';
import update9902Status from '@salesforce/apex/HudGenerateAndSubmitController.update9902Status';

const FIELDS = ["X9902__c.AgencyGenerationStatus__c", 
"X9902__c.ClientGenerationStatus__c", "X9902__c.CounselorGenerationStatus__c", 
"X9902__c.Summary9902GenerationStatus__c", "X9902__c.AgencySubmissionID__c",
"X9902__c.ClientSubmissionID__c","X9902__c.CounselorSubmissionID__c",
"X9902__c.Summary9902SubmissionID__c","X9902__c.Summary9902SubmissionStatus__c",
"X9902__c.CounselorSubmissionStatus__c","X9902__c.ClientSubmissionStatus__c",
"X9902__c.AgencySubmissionStatus__c", "X9902__c.AgencyProfile__c", "X9902__c.Summary9902__c", 
"X9902__c.CounselorProfile__c", "X9902__c.ClientSummary__c"
];
const GENERATION_STATUS_FIELDS = {Agency: "AgencyGenerationStatus__c",Client: "ClientGenerationStatus__c", 
Counselor: "CounselorGenerationStatus__c",Summary: "Summary9902GenerationStatus__c"};
const SUBMISSION_STATUS_FIELDS = {Agency: "AgencySubmissionStatus__c", Client: "ClientSubmissionStatus__c",
Counselor: "CounselorSubmissionStatus__c",Summary: "Summary9902SubmissionStatus__c"};

export default class HudGenerateAndSubmit extends LightningElement {
    @api recordId;
    @api objectApiName;
    summaryGenVariant = 'base';
    summarySubVariant = 'base';
    x9902;
    value = [];
    stopWireExecution = false;
    executedIndicatorSubmission = 0;//To remove
    executedSubmissionPercentage = 0;//To remove
    isSubmissionBatchCompleted = false;
    executedBatch;//TO remove
    totalBatch;// to remove
    isBatchCompleted = false;
    @track disabledButton = {Generate: false, Submit: false};
    isClientSubmissionInProgress = false;
    @track checkBoxes = {Agency: true, Counselor: true, Client: true, Summary: true};
    @track generationBatchIds = {Agency: '', Counselor: '', Client: '', Summary: ''};
    @track submissionBatchIds = {Agency: '', Counselor: '', Client: '', Summary: ''};
    @track generationExecutedPercentage = {Agency: 0, Counselor: 0, Client: 0, Summary: 0};
    @track submissionExecutedPercentage = {Agency: 0, Counselor: 0, Client: 0, Summary: 0};
    @track generationExecutedIndicator = {Agency: 0, Counselor: 0, Client: 0, Summary: 0};
    @track submissionExecutedIndicator = {Agency: 0, Counselor: 0, Client: 0, Summary: 0};
    @track generationIsBatchCompleted = {Agency: false, Counselor: false, Client: false, Summary: false};//TO remove
    @track submissionIsBatchCompleted = {Agency: false, Counselor: false, Client: false, Summary: false};//TO remove
    @track batchesStatusGeneration = {Agency: 'Not Started',Counselor: 'Not Started', Client: 'Not Started', Summary: 'Not Started'};
    @track batchesExtendedStatusGeneration = {Agency: '',Counselor: '', Client: '', Summary: ''};
    @track batchesExtendedStatusSubmission = {Agency: '',Counselor: '', Client: '', Summary: ''};
    @track generationStatusToUpdate = {Agency: '',Counselor: '', Client: '', Summary: ''};
    @track submissionStatusToUpdate = {Agency: '',Counselor: '', Client: '', Summary: ''};
    @track batchesStatusSubmission = {Agency: 'Not Started', Counselor: 'Not Started', Client: 'Not Started', Summary: 'Not Started'};
    @track progressRingVariantGeneration = {Agency: 'base', Counselor: 'base', Client: 'base', Summary: 'base'};
    @track progressRingVariantSubmission = {Agency: 'base', Counselor: 'base', Client: 'base', Summary: 'base'};
    @track badgeClassGeneration = {
        Agency: 'badge-width slds-badge_lightest', Counselor: 'badge-width slds-badge_lightest', 
        Client: 'badge-width slds-badge_lightest', Summary: 'badge-width slds-badge_lightest'
    };
    @track badgeClassSubmission = {
        Agency: 'badge-width slds-badge_lightest', Counselor: 'badge-width slds-badge_lightest', 
        Client: 'badge-width slds-badge_lightest', Summary: 'badge-width slds-badge_lightest'
    };

    

    @wire(getRecord, { recordId: "$recordId", fields: FIELDS })
    wired9902({ error, data }) {
        if (error) {
            console.log('Error: ' + error);
        } else if (data) {
            this.x9902 = data;
            this.isClientSubmissionInProgress = data?.fields?.ClientSubmissionStatus__c?.value === 'In Progress';
            if (this.isClientSubmissionInProgress) {
                this.setClientSubmissionStatus('Client');
            }
            if(!this.stopWireExecution){
                Object.keys(GENERATION_STATUS_FIELDS).forEach((key,index) => {
                    let genStatusVal = this.x9902.fields[GENERATION_STATUS_FIELDS[key]].value;
                    this.batchesStatusGeneration[key] = genStatusVal;
                    if(genStatusVal === 'Ready' || (genStatusVal && genStatusVal !== 'Ready')){
                        this.generationExecutedPercentage[key] = 100;
                        this.generationExecutedIndicator[key] = 100;
                    }
                });
                Object.keys(SUBMISSION_STATUS_FIELDS).forEach((key,index) => {
                    let subStatusVal = this.x9902.fields[SUBMISSION_STATUS_FIELDS[key]].value;
                    this.batchesStatusSubmission[key] = subStatusVal;
                    if(subStatusVal === 'Completed' || (subStatusVal && subStatusVal !== 'Completed')){
                        this.submissionExecutedPercentage[key] = 100;
                        this.submissionExecutedIndicator[key] = 100;
                    }
                });    
                this.updateBadgeStatus();
                this.updateSubmissionBadgeStatus();

                /*
                Object.keys(GENERATION_STATUS_FIELDS).forEach((key,index) => {
                    let genStatusVal = this.x9902.fields[GENERATION_STATUS_FIELDS[key]].value;
                    if(genStatusVal === 'Ready' || (genStatusVal && genStatusVal != 'Ready')){
                        this.generationExecutedPercentage[key] = 100
                        this.generationExecutedIndicator[key] = 100
                    }
                });
                Object.keys(SUBMISSION_STATUS_FIELDS).forEach((key,index) => {
                    if(this.x9902.fields[SUBMISSION_STATUS_FIELDS[key]].value === 'Completed'){
                        this.submissionExecutedPercentage[key] = 100
                        this.submissionExecutedIndicator[key] = 100
                    }
                });
                */
                this.stopWireExecution = true;
            }
        }
    }

    checkboxChange(e) {
        var inp = this.template.querySelectorAll("lightning-input");
        inp.forEach(function(element){
            if(element.name=="Agency"){
                this.checkBoxes.Agency = element.checked;
            }else if(element.name=="Counselor"){
                this.checkBoxes.Counselor = element.checked;
            }else if(element.name=="Client"){
                this.checkBoxes.Client = element.checked;
            }else if(element.name=="Summary"){
                this.checkBoxes.Summary = element.checked;
            }
        },this);
    }

    handleHUDSubmission(){
        this.disabledButton.Submit = true;
        Object.keys(SUBMISSION_STATUS_FIELDS).forEach((key,index) => {
            this.batchesStatusGeneration[key] === 'Not Started';
        });
        executeSubmissionBatch({
            reportId: this.recordId,
            batchChecks: this.checkBoxes
        }).then(res => {
            console.log('response => ', res);
            if (res) {
                this.submissionBatchIds.Agency = res.Agency;
                this.submissionBatchIds.Client = res.Client;
                this.submissionBatchIds.Counselor = res.Counselor;
                this.submissionBatchIds.Summary = res.Summary;
                this.getSubmissionBatchStatus(this.submissionBatchIds);
                Object.keys(SUBMISSION_STATUS_FIELDS).forEach((key,index) => {
                    this.batchesStatusGeneration[key] === 'In Progress';
                });
                this.updateSubmissionBadgeStatus();
            }
        }).catch(err => {
            console.log('err ', err);
            this.disabledButton.Submit = false;
        })
    }
    handleExecuteBatch() {
        this.disabledButton.Generate = true;
        Object.keys(GENERATION_STATUS_FIELDS).forEach((key,index) => {
            this.batchesStatusGeneration[key] === 'Not Started';
        });
        executeBatch({
            reportId: this.recordId,
            batchChecks: this.checkBoxes
        }).then(res => {
            console.log('response => ', res);
            if (res) {
                this.generationBatchIds.Agency = res.Agency;
                this.generationBatchIds.Client = res.Client;
                this.generationBatchIds.Counselor = res.Counselor;
                this.generationBatchIds.Summary = res.Summary;
                this.getBatchStatus(this.generationBatchIds);
                Object.keys(GENERATION_STATUS_FIELDS).forEach((key,index) => {
                    this.batchesStatusGeneration[key] === 'In Progress';
                });
                this.updateBadgeStatus();
            }
        }).catch(err => {
            console.log('err ', err);
            this.disabledButton.Generate = false;
        })
    }
    
    //get the generation batch status
    getBatchStatus(batchJobIdsMap) {
        this.isBatchCompleted = false;
        getJobDetails({ 
            batchJobtoIdsMap: batchJobIdsMap,
            batchChecks: this.checkBoxes })
        .then(res => {
            let executedNumber;
            let readyCount = 0;
            console.log('response => ', res);
            Object.keys(res).forEach((key,index) => {
                //console.log(key + ' -- ' + JSON.stringify(res[key]));
                if(res && res[key] && (res[key].Status === 'Queued' || res[key].Status ==='Holding')){
                    this.generationExecutedPercentage[key] = 0;
                    this.generationExecutedIndicator[key] = 0;
                    //this.generationIsBatchCompleted[key] = false;
                    this.disabledButton.Generate = true;
                    this.batchesStatusGeneration[key] = 'Not Started';
                }else if (res && res[key] && res[key].TotalJobItems !== 0 
                    && res[key].TotalJobItems === res[key].JobItemsProcessed) {
                    //this.generationIsBatchCompleted[key] = true;
                    this.disabledButton.Generate = false;
                    this.batchesStatusGeneration[key] = 'Ready';
                    if(!res[key].ExtendedStatus){
                        this.generationStatusToUpdate[key] = 'Ready';
                    }else{
                        this.generationStatusToUpdate[key] = res[key].ExtendedStatus;
                    }
                    this.generationExecutedPercentage[key] = ((res[key].JobItemsProcessed / res[key].TotalJobItems) * 100).toFixed(2);
                    executedNumber = Number(this.generationExecutedPercentage[key]);
                    this.generationExecutedIndicator[key] = Math.floor(executedNumber);
                    readyCount++;
                }else{
                    //this.generationIsBatchCompleted[key] = false;
                    this.batchesStatusGeneration[key] = 'In Progress';
                    this.disabledButton.Generate = true;
                    this.generationExecutedPercentage[key] = ((res[key].JobItemsProcessed / res[key].TotalJobItems) * 100).toFixed(2);
                    executedNumber = Number(this.generationExecutedPercentage[key]);
                    this.generationExecutedIndicator[key] = Math.floor(executedNumber);
                }
                this.batchesExtendedStatusGeneration[key] = res[key].ExtendedStatus;
            });
            if(readyCount === Object.keys(res).length){
                this.update9902Status(this.generationStatusToUpdate);
                this.dispatchEvent(new RefreshEvent());
                this.isBatchCompleted = true;
            }
            this.updateBadgeStatus();
            this.refreshBatchOnInterval(batchJobIdsMap);

        }).catch(err => {
            console.log('err ', err);
        })
    }
    getSubmissionBatchStatus(batchJobIdsMap){
        getJobDetails({ 
            batchJobtoIdsMap: batchJobIdsMap,
            batchChecks: this.checkBoxes 
        }).then(res => {
            this.isSubmissionBatchCompleted = false;
            let executedNumberSubmission;
            let readyCount = 0;
            Object.keys(res).forEach((key,index) => {
                if (key === 'Client' && this.isClientSubmissionInProgress) {
                    this.setClientSubmissionStatus(key);
                } else {
                    if(res && res[key] && (res[key].Status === 'Queued' || res[key].Status ==='Holding')){
                        this.submissionExecutedPercentage[key] = 0;
                        this.submissionExecutedIndicator[key] = 0;
                        this.disabledButton.Submit = true;
                        this.batchesStatusSubmission[key] = 'Not Started';
                    }else if (res && res[key] && res[key].TotalJobItems !== 0 
                        && res[key].TotalJobItems === res[key].JobItemsProcessed) {
    
                        this.disabledButton.Submit = false;
                        this.batchesStatusSubmission[key] = 'Completed'
                        if(!res[key].ExtendedStatus){
                            this.submissionStatusToUpdate[key] = 'Completed';
                        }else{
                            this.submissionStatusToUpdate[key] = res[key].ExtendedStatus;
                        }
                        this.submissionExecutedPercentage[key] = ((res[key].JobItemsProcessed / res[key].TotalJobItems) * 100).toFixed(2);
                        executedNumberSubmission = Number(this.submissionExecutedPercentage[key]);
                        this.submissionExecutedIndicator[key] = Math.floor(executedNumberSubmission);
                        readyCount++;
                    }else{
                        this.batchesStatusSubmission[key] = 'In Progress';
                        this.disabledButton.Submit = true;
                        this.submissionExecutedPercentage[key] = ((res[key].JobItemsProcessed / res[key].TotalJobItems) * 100).toFixed(2);
                        executedNumberSubmission = Number(this.submissionExecutedPercentage[key]);
                        this.submissionExecutedIndicator[key] = Math.floor(executedNumberSubmission);
                    }
                }
                this.batchesExtendedStatusSubmission[key] = res[key].ExtendedStatus;
            });
            if(readyCount === Object.keys(res).length){
                this.dispatchEvent(new RefreshEvent());
                this.isSubmissionBatchCompleted = true;
            }
            this.updateSubmissionBadgeStatus();
            this.refreshSubmissionBatchOnInterval(batchJobIdsMap);
        }).catch(err => {
            console.log('err ', err);
        })
    }
    refreshBatchOnInterval(batchJobIdsMap) {
        this._interval = setInterval(() => {
            if (this.isBatchCompleted) {
                clearInterval(this._interval);
                //this.dispatchEvent(new RefreshEvent());
            } else {
                this.getBatchStatus(batchJobIdsMap);
            }
        }, 2000); //refersh view every time
    }
    refreshSubmissionBatchOnInterval(batchJobIdsMap) {
        this._interval = setInterval(() => {
            if (this.isSubmissionBatchCompleted) {
                clearInterval(this._interval);
                //this.dispatchEvent(new RefreshEvent());
            } else {
                this.getSubmissionBatchStatus(batchJobIdsMap);
            }
        }, 2000); //refersh view every time
    }

    setClientSubmissionStatus(key) {
        this.batchesStatusSubmission[key] = 'In Progress';
        this.disabledButton.Submit = true;
        this.submissionExecutedPercentage[key] = "";
        this.submissionExecutedIndicator[key] = "";
    }
    updateBadgeStatus(){
        console.log('updateBadgeStatus------------ ');
        Object.keys(GENERATION_STATUS_FIELDS).forEach((key,index) => {
            if(this.batchesStatusGeneration[key] === 'In Progress' && !this.batchesExtendedStatusGeneration[key]){
                this.badgeClassGeneration[key] = 'slds-badge slds-badge_inverse';
                this.progressRingVariantGeneration[key] = 'base';
            }else if(this.batchesStatusGeneration[key] === 'Ready' && !this.batchesExtendedStatusGeneration[key]){
                this.generationExecutedPercentage[key] = 100;
                this.generationExecutedIndicator[key] = 100;
                this.badgeClassGeneration[key]= 'slds-badge badge-width slds-theme_success';
                this.progressRingVariantGeneration[key] = 'base';
            }else if(this.batchesStatusGeneration[key] === 'Not Started' || this.batchesStatusGeneration[key] === '' || 
                    this.batchesStatusGeneration[key] === null || this.batchesStatusGeneration[key] === undefined){
                this.generationExecutedPercentage[key] = 0;
                this.generationExecutedIndicator[key] = 0;
                this.batchesStatusGeneration[key] = 'Not Started';
                this.progressRingVariantGeneration[key] = 'base';
                this.badgeClassGeneration[key] = 'slds-badge badge-width slds-badge_lightest';
            }else{
                this.batchesStatusGeneration[key] = 'Error';
                this.progressRingVariantGeneration[key] = 'expired';
                this.badgeClassGeneration[key] = 'slds-badge badge-width slds-theme_error';
            }
        });
        /**/
    }

    updateSubmissionBadgeStatus(){
        console.log('updateSubmissionBadgeStatus------------ ');
        Object.keys(SUBMISSION_STATUS_FIELDS).forEach((key,index) => {
            if( this.batchesStatusSubmission[key] === 'In Progress' && !this.batchesExtendedStatusSubmission[key]){
                this.badgeClassSubmission[key] = 'slds-badge slds-badge_inverse';
                this.progressRingVariantSubmission[key] = 'base';
            }else if((this.batchesStatusSubmission[key] === 'Completed' || this.batchesStatusSubmission[key] === 'DONE') && 
                    !this.batchesExtendedStatusSubmission[key]){
                this.submissionExecutedPercentage[key] = 100;
                this.submissionExecutedIndicator[key] = 100;
                this.badgeClassSubmission[key]= 'slds-badge badge-width slds-theme_success';
                this.progressRingVariantSubmission[key] = 'base';
            }else if(this.batchesStatusSubmission[key] === 'Not Started' || !this.batchesStatusSubmission[key]){
                this.batchesStatusSubmission[key] = 'Not Started';
                this.submissionExecutedPercentage[key] = 0;
                this.submissionExecutedIndicator[key] = 0;
                this.badgeClassSubmission[key] = 'slds-badge badge-width slds-badge_lightest';
                this.progressRingVariantSubmission[key] = 'base';
            }else{
                this.batchesStatusSubmission[key] = 'Error';
                this.submissionExecutedPercentage[key] = 100;
                this.submissionExecutedIndicator[key] = 100;
                this.progressRingVariantSubmission[key] = 'expired';
                this.badgeClassSubmission[key] = 'slds-badge badge-width slds-theme_error';
            }
        });
    }

    update9902Status(status){
        update9902Status({
            batchJobStatusMap: status,
            batchChecks: this.checkBoxes,
            reportId: this.recordId
        }).then(res => {
            console.log('response => ', res);
        }).catch(err => {
            console.log('err: ', err);
        })
    }
}