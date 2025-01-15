import { LightningElement, track, api, wire } from 'lwc';
import { getObjectInfo, getPicklistValues } from "lightning/uiObjectInfoApi";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import RemoveObstacle from '@salesforce/customPermission/AgencyAdmin';
import hasRemoveObstaclePermission from '@salesforce/apex/ClientActionPlansController.hasRemoveObstaclePermission';

import GOAL_OBJECT from "@salesforce/schema/Goal__c";
import GOALTYPE_FIELD from '@salesforce/schema/Goal__c.GoalType__c';
import GOAL_DEFAULT_VALLUES_FIELD from '@salesforce/schema/Goal__c.GoalDefaultValues__c';
import GOALSTATUS_FIELD from '@salesforce/schema/Goal__c.Status__c';
import SOLUTION_OBJECT from "@salesforce/schema/Solution__c";
import SOLUTIONSTATUS_FIELD from '@salesforce/schema/Solution__c.Status__c';
import SOLUTION_DEFAULT_VALUES_FIELD from '@salesforce/schema/Solution__c.SolutionDefaultValues__c';
import OBSTACLE_OBJECT from "@salesforce/schema/Obstacle__c";
import OBSTACLE_DEFAULT_VALUES_FIELD from '@salesforce/schema/Obstacle__c.ObstaclesDefaultValues__c';
import CLIENTCASE_OBJECT from '@salesforce/schema/ClientCase__c';

import getGoalsForClientCase from '@salesforce/apex/ClientActionPlansController.getGoalsForClientCase';
import saveGoalsForClientCase from '@salesforce/apex/ClientActionPlansController.saveGoalsForClientCase';
import deleteObstaclesAndSolutionsForGoal from '@salesforce/apex/ClientActionPlansController.deleteObstaclesAndSolutionsForGoal'
import deleteSolution from '@salesforce/apex/ClientActionPlansController.deleteSolution'
import getClientCase from '@salesforce/apex/ClientActionPlansController.getClientCase'
import isIntakeStaffUser from "@salesforce/apex/ClientCaseGuidanceController.isIntakeStaffUser";


const FIELDS = ["Name", "Action_Plan_Created_Date__c"];
export default class ClientActionPlans extends LightningElement {
    @api recordId;
    @api obs; 
    @track actionPlans = [];
    @track showRemoveObstacle = false;
    showSpinner = false;
    showSpinnerPopup = false;
    @track actionPlanWrapper;
    showNewOrEditModal = false;
    @track selectedRecord;
    @track goalTypePicklistOptions = [];
    @track goalStatusPicklistOptions = [];
    @track goalDefaultValuesPicklistOptions = [];
    @track showPrintActionModal = false;
    @track solutionStatusPicklistOptions = [];
    @track solutionDefaultValuesPicklistOptions = [];
    @track obstacleDefaultValuesPicklistOptions = [];
    @track taskStatusPicklistOptions = [
        {label: 'Not Started', value: 'Not Started'},
        {label: 'In Progress', value: 'In Progress'},
        {label: 'Completed', value: 'Completed'}
    ];
    @track showButton = false;
    @track clientCase = {};
    @wire (getClientCase, {recordId: "$recordId"}) wiredclientCase({data,error}){
        if(data){
            this.clientCase = data;
        }else{
          console.log(error);
        }
     }

    /* @description: Wire method for getting Object Info for Goal__c Object*/
    @wire(getObjectInfo, { objectApiName: GOAL_OBJECT })
    goalObjectInfo;

    /* @description: Wire method for getting picklist values for Goal__c.GoalType__c field*/
    @wire(getPicklistValues, {
        recordTypeId: "$goalObjectInfo.data.defaultRecordTypeId",
        fieldApiName: GOALTYPE_FIELD
    })
    goalTypePicklistValues({error, data}){
        if(data){
            this.goalTypePicklistOptions = data.values;
        }
        if(error){
            console.log(JSON.stringify(error))
        }
    }
    
    /* @description: Wire method for getting picklist values for Goal__c.Status__c field*/
    @wire(getPicklistValues, {
        recordTypeId: "$goalObjectInfo.data.defaultRecordTypeId",
        fieldApiName: GOALSTATUS_FIELD
    })
    goalStatusPicklistValues({error, data}){
        if(data){
            this.goalStatusPicklistOptions = data.values;
        }
        if(error){
            console.log(JSON.stringify(error))
        }
    }

    /* @description: Wire method for getting picklist values for Goal__c.GoalDefaultValues__c field*/
    @wire(getPicklistValues, {
        recordTypeId: "$goalObjectInfo.data.defaultRecordTypeId",
        fieldApiName: GOAL_DEFAULT_VALLUES_FIELD
    })
    goalDefaultTypePicklistValues({error, data}){
        if(data){
            this.goalDefaultValuesPicklistOptions = data.values;
        }
        if(error){
            console.log(JSON.stringify(error))
        }
    }

    /* @description: Wire method for getting Object Info for Solution__c Object*/
    @wire(getObjectInfo, { objectApiName: SOLUTION_OBJECT })
    solutionObjectInfo;

    /* @description: Wire method for getting picklist values for Solution__c.Status__c field*/
    @wire(getPicklistValues, {
        recordTypeId: "$solutionObjectInfo.data.defaultRecordTypeId",
        fieldApiName: SOLUTIONSTATUS_FIELD
    })
    solutionStatusPicklistValues({error, data}){
        if(data){
            this.solutionStatusPicklistOptions = data.values;
        }
        if(error){
            console.log(JSON.stringify(error))
        }
    }
    
    /* @description: Wire method for getting picklist values for Solution__c.SolutionDefaultValues__c field*/
    @wire(getPicklistValues, {
        recordTypeId: "$solutionObjectInfo.data.defaultRecordTypeId",
        fieldApiName: SOLUTION_DEFAULT_VALUES_FIELD
    })
    solutionDefaultValuesPicklistValues({error, data}){
        if(data){
            this.solutionDefaultValuesPicklistOptions = data.values;
        }
        if(error){
            console.log(JSON.stringify(error))
        }
    }

    /* @description: Wire method for getting Object Info for Obstacle__c Object*/
    @wire(getObjectInfo, { objectApiName: OBSTACLE_OBJECT })
    obstacleObjectInfo;

    /* @description: Wire method for getting picklist values for Solution__c.SolutionDefaultValues__c field*/
    @wire(getPicklistValues, {
        recordTypeId: "$obstacleObjectInfo.data.defaultRecordTypeId",
        fieldApiName: OBSTACLE_DEFAULT_VALUES_FIELD
    })
    obstacleDefaultValuesPicklistValues({error, data}){
        if(data){
            this.obstacleDefaultValuesPicklistOptions = data.values;
        }
        if(error){
            console.log(JSON.stringify(error))
        }
    }

    connectedCallback() {
        this.getGoalsForClientCase();
        this.checkPermission();
        this.isIntakeStaffUser();
    }

    @track isIntakeUser = false;
    isIntakeStaffUser() {
        isIntakeStaffUser().then((result) => {
        this.isIntakeUser = result;
        }).catch((error) => {
        console.log('ERROR !!!'+JSON.stringify(error))
        });
    }

    async checkPermission() {
        try {
            const result = await hasRemoveObstaclePermission();
            this.showButton = result;
        } catch (error) {
            console.error('Error checking permission', error);
        }
    }

    /* @description: Wire method for getting all existing goals for the client case*/
    async getGoalsForClientCase(){
        this.showSpinner = true;
        try{
            const result = await getGoalsForClientCase({clientCaseId: this.recordId});
            if(result && result.actionPlans){
                console.log('result 185 ',result);
                
                let temp = result.actionPlans;
                if(this.selectedRecord){
                    
                    temp.forEach(record=>{
                        if(record.goalId == this.selectedRecord.goalId){
                            record.viewModeCollapsed = this.selectedRecord.viewModeCollapsed;
                        }
                    })
                }
                this.actionPlans = JSON.parse(JSON.stringify(temp));
            }
            this.selectedRecord = undefined;
            this.actionPlanWrapper = result;

            this.showSpinner = false;
        } catch (error) {
            console.log(JSON.stringify(error));
            this.selectedRecord = undefined;
            this.showSpinner = false;
            this.showToast('Error', error.body.message, 'error', 'sticky');
        }
    }
    
    /* @description: getter for Client Name*/
    get clientName(){
        return this.actionPlanWrapper && this.actionPlanWrapper.clientName ? this.actionPlanWrapper.clientName : '';
    }

    /* @description: handler method for editing a goal*/
    handleGoalEdit(event) {
        let rowIndex = event.target.dataset.index;
        this.selectedRecord = JSON.parse(JSON.stringify(this.actionPlans[rowIndex]));
        this.showNewOrEditModal = true;
    }

    /* @description: handler method for closing New or Edit popup*/
    handleCancel() {
        this.selectedRecord = undefined;
        this.showNewOrEditModal = false;
    }

    /* @description: handler method for capturing change in goal related input fields*/
    handleGoalChange(event) {
        this.selectedRecord[event.target.name] = event.detail.value;
        if(event.target.name == 'goalName' && (!this.selectedRecord.obstacleList || this.selectedRecord.obstacleList.length == 0)){
            this.selectedRecord.obstacleList.push({
                obstacleId:undefined,
                obstacleName: undefined,
                obstacleDetail: undefined,
                obstacleDueDate: undefined,
                obstacleOtherName:undefined,
                showObstacleOtherName: undefined,
                solutionList: [],
                viewModeCollapsed: false,
                showAddSolutionAction: false
            });
        }

        if(event.target.name == 'goalName'){
            if(event.detail.value == 'Other'){
                this.selectedRecord.showGoalOtherName = true;
            } else{
                this.selectedRecord.goalOtherName = '';
                this.selectedRecord.showGoalOtherName = false;
            }
        } 

    }

    /* @description: handler method for capturing change in obstacle related input fields*/
    handleObstacleChange(event) {
        let obsIndex = event.target.dataset.obsindex;
        this.selectedRecord.obstacleList[obsIndex][event.target.name] = event.target.value;

        if(this.selectedRecord.obstacleList[obsIndex].obstacleName){
            this.selectedRecord.obstacleList[obsIndex].showAddSolutionAction = true;
        }

        if(event.target.name == 'obstacleName'){
            if(event.detail.value == 'Other'){
                this.selectedRecord.obstacleList[obsIndex].showObstacleOtherName = true;
            } else{
                this.selectedRecord.obstacleList[obsIndex].obstacleOtherName = '';
                this.selectedRecord.obstacleList[obsIndex].showObstacleOtherName = false;
            }
        }
    }

    /* @description: handler method for capturing change in solution related input fields*/
    handleSolutionChange(event){
        let obsIndex = event.target.dataset.obsindex;
        let solIndex = event.target.dataset.solindex;
        
        this.selectedRecord.obstacleList[obsIndex].solutionList[solIndex][event.target.name] = event.target.value;

        if(event.target.name == 'solutionName'){
            if(event.detail.value == 'Other'){
                this.selectedRecord.obstacleList[obsIndex].solutionList[solIndex].showSolutionOtherName = true;
            } else{
                this.selectedRecord.obstacleList[obsIndex].solutionList[solIndex].solutionOtherName = '';
                this.selectedRecord.obstacleList[obsIndex].solutionList[solIndex].showSolutionOtherName = false;
            }
        }
    }

    /* @description: handler method for checking required and valid input entered in fields*/
    isInputValid(){
        let isValid = true;
        let inputFields = this.template.querySelectorAll('.requiredValidation');
        inputFields.forEach(inputField => {
            if(!inputField.checkValidity()) {
                inputField.reportValidity();
                isValid = false;
            }
        });
        return isValid;
    }

    /* @description: handler method for to save new or edited goal details*/
    handleSave(){
        if(!this.isInputValid()){
            return;
        }
        this.showSpinnerPopup = true;
        saveGoalsForClientCase({inputWrapper: this.selectedRecord})
        .then(result =>{
            this.showNewOrEditModal = false;
            this.showSpinnerPopup = false;
            if(this.selectedRecord && this.selectedRecord.goalId){
                this.showToast('Success', 'Goal updated successfully!!', 'success', 'dismissable');
            } else{
                this.showToast('Success', 'Goal created successfully!!', 'success', 'dismissable');
            }
            
            this.getGoalsForClientCase();
        })
        .catch(error=>{
            console.log(JSON.stringify(error))
            this.showSpinnerPopup = false;
            this.showToast('Error', error.body.message, 'error', 'sticky');
        })
    }

    /* @description: handler method for hiding or extedning view mode for a goal*/
    handleViewMode(event){
        let rowIndex = event.target.dataset.index;
        this.actionPlans[rowIndex].viewModeCollapsed = !this.actionPlans[rowIndex].viewModeCollapsed;
    }

    /* @description: handler method for hiding or extedning view mode for a obstacle*/
    handleObstacleHideShow(event){
        let obsIndex = event.target.dataset.obsindex;

        this.selectedRecord.obstacleList[obsIndex].viewModeCollapsed = !this.selectedRecord.obstacleList[obsIndex].viewModeCollapsed;
    }

    /* @description: handler method for hiding or extedning view mode for a solution*/
    handlerSolutionHideShow(event){
        let obsIndex = event.target.dataset.obsindex;
        let solIndex = event.target.dataset.solindex;

        this.selectedRecord.obstacleList[obsIndex].solutionList[solIndex].viewModeCollapsed = !this.selectedRecord.obstacleList[obsIndex].solutionList[solIndex].viewModeCollapsed;
    }

    /* @description: handler method for adding a new goal on click on button New Goal*/
    addNewGoal() {
        this.selectedRecord = undefined;
        let newObj = {
            goalId:undefined,
            clientCaseId: this.recordId,
            actionPlanId: this.actionPlanWrapper && this.actionPlanWrapper.actionPlanId ? this.actionPlanWrapper.actionPlanId : undefined,
            goalName: undefined,
            goalDetail: undefined,
            goalType: undefined,
            goalStatus: 'Not Started',
            goalDueDate: undefined,
            obstacleList: [],
            viewModeCollapsed: false,
            statusClass: undefined,
            showGoalOtherName: undefined,
            goalOtherName: undefined
        }
        this.selectedRecord = newObj;
        this.showNewOrEditModal = true;
    }

    /* @description: handler method for adding a new Obstacle on click on button Add Obstacle*/
    addNewObstacle() {
        let newObj = {
            obstacleId:undefined,
            obstacleName: undefined,
            obstacleOtherName:undefined,
            showObstacleOtherName: undefined,
            obstacleDetail: undefined,
            obstacleDueDate: undefined,
            solutionList: [],
            viewModeCollapsed: false,
            showAddSolutionAction: false,
            obsExternalId: Math.floor(Math.random() * 1000000)
        }
        let obslist = [...this.selectedRecord.obstacleList];
        obslist.push(newObj);
        this.selectedRecord.obstacleList = obslist;
        
    }


    /* @description: handler method for adding a new Solution on click on button Add Solution*/
    addNewSolution(event) {
        console.log('this.actionPlanWrapper 396 ',this.actionPlanWrapper);

        let newObj = {
            solutionId:undefined,
            solutionName: undefined,
            solutionOtherName:undefined,
            showSolutionOtherName: undefined,
            solutionDetail: undefined,
            solutionStatus: 'Not Started',
            viewModeCollapsed: undefined,
            clientAction: undefined,
            portalUserId: this.actionPlanWrapper.portalUserId,
            clientActionDetail: undefined,
            clientActionDueDate: undefined,
            clientActionStatus: 'Not Started',
            counselorAction: undefined,
            counselorActionDetail: undefined,
            counselorActionDueDate: undefined,
            counselorActionStatus:'Not Started',
            solExternalId: Math.floor(Math.random() * 1000000)
        }
        this.showRemoveObstacle = true;
        let obsIndex = event.target.dataset.obsindex;
        let sollist = [...this.selectedRecord.obstacleList[obsIndex].solutionList];
        sollist.push(newObj);
        this.selectedRecord.obstacleList[obsIndex].solutionList = sollist;
    }
    //ankit's code
     /* @description: handler method for removing an obstacle from a goal*/
     removeObstacle(event){
        let obsIndex = event.target.dataset.obsindex;
        if(obsIndex > -1){
            this.selectedRecord.obstacleList.splice(obsIndex, 1);
           
                deleteObstaclesAndSolutionsForGoal({ goalId: this.selectedRecord.goalId})
                .then(result => {
                    // Handle success
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Success',
                            message: 'Obstacles and solutions deleted successfully.',
                            variant: 'success'
                        })
                    );
                })
                .catch(error => {
                    // Handle error
                    console.error('Error deleting obstacles and solutions:', error);
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error',
                            message: error.body.message,
                            variant: 'error'
                        })
                    );
                });
             }
        }

        removeSolution(event) {
            const solutionId = event.target.dataset.solutionId; // Get solution ID
            const obsIndex = event.target.dataset.obsindex; // Get obstacle index
            const solindex = event.target.dataset.solindex;

            if (obsIndex > -1) {
                    this.selectedRecord.obstacleList[obsIndex].solutionList.splice(solindex, 1);

                    deleteSolution({ solutionId: solutionId })
                        .then(result => {
                            // Handle success
                            this.dispatchEvent(
                                new ShowToastEvent({
                                    title: 'Success',
                                    message: 'Solutions deleted successfully.',
                                    variant: 'success'
                                })
                            );
                        })
                        .catch(error => {
                            // Handle error
                            console.error('Error deleting solution:', error);
                            this.dispatchEvent(
                                new ShowToastEvent({
                                    title: 'Error',
                                    message: error.body.message,
                                    variant: 'error'
                                })
                            );
                        });
                 
            } else {
                console.error('Invalid obstacle index');
            }
        }


    /* @description: handler method for showing print goal popup*/
    showPrintActionPlanModal() {
        this.showPrintActionModal = true;
    }

    /* @description: handler method for hiding print goal popup*/
    closePrintActionPlanModal() {
        this.showPrintActionModal = false;
    }

    /* @description: handler method for showing toast message*/
    showToast(title, message, variant, mode) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
            mode: mode
        });
        this.dispatchEvent(event);
    }

    @track height = '900px';
    @track referrerPolicy = 'no-referrer';
    @track sandbox = '';
    @track width = '100%';

    get actionPlanPrintUrl(){
        return '/apex/printActionPlanVf?Id='+ this.recordId;
    }
}