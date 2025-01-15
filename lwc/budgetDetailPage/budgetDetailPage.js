/**
 * @description  : Detail Page for budget
 **/
import { LightningElement, api,  track, wire } from 'lwc';
import { refreshApex } from '@salesforce/apex';
import getBudgetId from '@salesforce/apex/BudgetDetailPageController.getBudgetId';
import isIntakeStaffUser from "@salesforce/apex/ClientCaseGuidanceController.isIntakeStaffUser";


import { getObjectInfo, getPicklistValues } from "lightning/uiObjectInfoApi";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';



export default class BudgetDetailPage extends LightningElement {
    @api recordId;
    isShowModal = false;
    budgetId;
    actionLabel = 'New';
    wiredBudgetResult;
    modalLabel = 'New Budget';
    activeSections = ['Housing'];
    toggleIconName = 'utility:collapse_all';
    toggleButtonLabel = 'Expand All';


    @track actionPlans = [];
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

    @track showPrintActionModal = false;
    //To be used for modal box
    hideModalBox() {
        this.isShowModal = false;
    }
    //To be used for modal box
    showModalBox() {
        this.isShowModal = true;
    }

    //Refresh Page on close of Modal box
    closeModalRefresh() {
        refreshApex(this.wiredBudgetResult);
        this.isShowModal = false;
    }

    connectedCallback() {
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

    //To Expand all accordian
    expandAll() {
        if (this.toggleIconName === 'utility:collapse_all') {
            this.toggleIconName = 'utility:expand_all';
            this.toggleButtonLabel = 'Collapse All';
            this.activeSections = [
                'Housing',
                'Transportation',
                'Food',
                'Pets',
                'PersonalCare',
                'Entertainment',
                'Loans',
                'Taxes',
                'SavingsInvestments',
                'GiftsDonations',
                'Legal'
            ];
        } else {
            this.toggleIconName = 'utility:collapse_all';
            this.toggleButtonLabel = 'Expand All';
            this.activeSections = ['Housing'];
        }
    }

    //To get budget Id based on client case
    @wire(getBudgetId, { clientCaseId: '$recordId' })
    wireGetBudgetId(result) {
        this.wiredBudgetResult = result;
        if (result.error) {
            console.log('error==', result.error);
        } else {
            console.log('data1==', result.data);
            this.budgetId = result.data;
            this.actionLabel = this.budgetId ? 'Edit' : 'New Budget';
            this.modalLabel = this.budgetId ? 'Edit Budget' : 'New Budget';
        }
    }
    /* @description: handler method for showing print  popup*/
    showPrintActionPlanModal() {
        this.showPrintActionModal = true;
    }
    /* @description: handler method for hiding print goal popup*/
    closePrintActionPlanModal() {
        this.showPrintActionModal = false;
    }
    //Check New/existing record
    get isNew() {
        if (this.budgetId) return false;
        else return true;
    }
    get actionPlanPrintUrl(){
        return '/apex/BudgetPDF?Id='+ this.recordId;

    }
    @track height = '900px';
    @track referrerPolicy = 'no-referrer';
    @track sandbox = '';
    @track width = '100%';
}