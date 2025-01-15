import { LightningElement, track, api } from 'lwc';
import getOrsCounselingUniqueList from "@salesforce/apex/NWQRCounselingReportController.fetchOrsCounselingRecords";
import { loadStyle, loadScript } from "lightning/platformResourceLoader";
import workbook from "@salesforce/resourceUrl/ConvertToExcel";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import cssFile from '@salesforce/resourceUrl/sldsBoxCssFile';
export default class HudOrsCounselingReport extends LightningElement {

    librariesLoaded = false;
    btndisable = true;
    @track error;
    @track clientCaseList;
    @track exportList = [];
    @track isLoading = false;
    @track dtStartdateClosed;
    @track dtEnddateClosed;
    missingCSS = 'slds-box';
    @track columns = [
        {
            label: "Client ID",
            fieldName: "Household_Number",
            type: "text",
            sortable: false,
            hideDefaultActions: true,
            initialWidth: 150
        },
        {
            label: "Intake Date",
            fieldName: "Date_Opened",
            type: "text",
            sortable: false,
            hideDefaultActions: true,
            initialWidth: 100
        },
        {
            label: "Age",
            fieldName: "Current_Age",
            type: "number",
            sortable: false,
            hideDefaultActions: true,
            initialWidth: 50
        },
        {
            label: "Gender",
            fieldName: "Head_of_Household_Gender",
            type: "text",
            sortable: false,
            hideDefaultActions: true,
            initialWidth: 50
        },
        {
            label: "Race",
            fieldName: "Head_of_Household_Race",
            type: "text",
            sortable: false,
            hideDefaultActions: true,
            initialWidth: 150
        },
        {
            label: "Ethnicity",
            fieldName: "Head_of_Household_Ethnicity",
            type: "text",
            sortable: false,
            hideDefaultActions: true,
            initialWidth: 150
        },
        {
            label: "Disabled",
            fieldName: "Disabled",
            type: "text",
            sortable: false,
            hideDefaultActions: true,
            initialWidth: 100
        },
        {
            label: "Head of Household Type",
            fieldName: "Household_Type",
            type: "text",
            sortable: false,
            hideDefaultActions: true,
            initialWidth: 250
        },
        {
            label: "Household Family Size",
            fieldName: "Total_Household_Members",
            type: "text",
            sortable: false,
            hideDefaultActions: true,
            initialWidth: 150
        },
        {
            label: "Household Gross Monthly Income",
            fieldName: "Household_Gross_Monthly_Income",
            type: "number",
            sortable: false,
            hideDefaultActions: true,
            initialWidth: 200
        },
        {
            label: "Household Income Band",
            fieldName: "Household_AMI",
            type: "text",
            sortable: false,
            hideDefaultActions: true,
            initialWidth: 150
        },
        {
            label: "Primary Language Spoken",
            fieldName: "Preferred_Language",
            type: "text",
            sortable: false,
            hideDefaultActions: true,
            initialWidth: 150
        },
        {
            label: "House Number and Street Name",
            fieldName: "BillingStreet",
            type: "text",
            sortable: false,
            hideDefaultActions: true,
            cellAttributes: {
                class: {
                    fieldName: 'Street_Typeformat'
                }
            },
            initialWidth: 200
        },
        {
            label: "Apartment or Unit Number",
            fieldName: "Apt",
            type: "text",
            sortable: false,
            hideDefaultActions: true,
            initialWidth: 150
        },
        {
            label: "City",
            fieldName: "BillingCity",
            type: "text",
            sortable: false,
            hideDefaultActions: true,
            cellAttributes: {
                class: {
                    fieldName: 'City_Typeformat'
                }
            },
            initialWidth: 100
        },
        {
            label: "State",
            fieldName: "BillingState",
            type: "text",
            sortable: false,
            hideDefaultActions: true,
            cellAttributes: {
                class: {
                    fieldName: 'State_Typeformat'
                }
            },
            initialWidth: 50
        },
        {
            label: "Zip Code",
            fieldName: "BillingPostalCode",
            type: "text",
            sortable: false,
            hideDefaultActions: true,
            cellAttributes: {
                class: {
                    fieldName: 'Zip_Typeformat'
                }
            },
            initialWidth: 50
        },
        {
            label: "Rural Area Status",
            fieldName: "ORS_Rural_Area_Status",
            type: "text",
            sortable: false,
            hideDefaultActions: true,
            initialWidth: 100
        },
        {
            label: "One-on-One Counseling Completed_Homeless Assistance",
            fieldName: "One_on_One_Homeless_Assistance",
            type: "text",
            sortable: false,
            hideDefaultActions: true,
            initialWidth: 350
        },
        {
            label: "One-on-One Counseling Completed_Rental Topics",
            fieldName: "One_on_One_Rental_Topics",
            type: "text",
            sortable: false,
            hideDefaultActions: true,
            initialWidth: 300
        },
        {
            label: "One-on-One Counseling Completed_Pre-purchase/Homebuying",
            fieldName: "One_on_One_Pre_purchase_Homebuying",
            type: "text",
            sortable: false,
            hideDefaultActions: true,
            initialWidth: 350
        },
        {
            label: "One-on-One Counseling Completed_Non-Delinquency Post-Purchase",
            fieldName: "One_on_One_Non_Delinquency_Post_Purchase",
            type: "text",
            sortable: false,
            hideDefaultActions: true,
            initialWidth: 400
        },
        {
            label: "One-on-One Counseling Completed_Reverse Mortgage",
            fieldName: "One_on_One_Reverse_Mortgage",
            type: "text",
            sortable: false,
            hideDefaultActions: true,
            initialWidth: 300
        },
        {
            label: "One-on-One Counseling Completed_Resolving or Preventing Forward Mortgage Delinquency or Default",
            fieldName: "One_on_One_Forward_Mortgage_Delinquency",
            type: "text",
            sortable: false,
            hideDefaultActions: true,
            initialWidth: 600
        },
        {
            label: "One-on-One Counseling Completed_Resolving or Preventing Reverse Mortgage Delinquency or Default",
            fieldName: "One_on_One_Reverse_Mortgage_Delinquency",
            type: "text",
            sortable: false,
            hideDefaultActions: true,
            initialWidth: 600
        },
        {
            label: "One-on-One Counseling Completed_Disaster Preparedness Assistance",
            fieldName: "One_on_One_Disaster_Preparedness_Assista",
            type: "text",
            sortable: false,
            hideDefaultActions: true,
            initialWidth: 400
        },
        {
            label: "One-on-One Counseling Completed_Disaster Recovery Assistance",
            fieldName: "One_on_One_Disaster_Recovery_Assistance",
            type: "text",
            sortable: false,
            hideDefaultActions: true,
            initialWidth: 400
        },
        {
            label: "Service Completion Date",
            fieldName: "Date_Closed",
            type: "text",
            sortable: false,
            hideDefaultActions: true,
            initialWidth: 400
        }
    ];

    @track schemaObj = [
        {
            column: "Client ID",
            type: String,
            value: (ors) => ors.Household_Number
        },
        {
            column: "Intake Date",
            type: String,
            value: (ors) => ors.Date_Opened
        },
        {
            column: "Age",
            type: Number,
            value: (ors) => ors.Current_Age
        },
        {
            column: "Gender",
            type: String,
            value: (ors) => ors.Head_of_Household_Gender
        },
        {
            column: "Race",
            type: String,
            value: (ors) => ors.Head_of_Household_Race
        },
        {
            column: "Ethnicity",
            type: String,
            value: (ors) => ors.Head_of_Household_Ethnicity
        },
        {
            column: "Disabled",
            type: String,
            value: (ors) => ors.Disabled
        },
        {
            column: "Head of Household Type",
            type: String,
            value: (ors) => ors.Household_Type
        },
        {
            column: "Household Family Size",
            type: Number,
            value: (ors) => ors.Total_Household_Members
        },
        {
            column: "Household Gross Monthly Income",
            type: Number,
            format: "#,##0.00",
            value: (ors) => ors.Household_Gross_Monthly_Income
        },
        {
            column: "Household Income Band",
            type: String,
            value: (ors) => ors.Household_AMI
        },
        {
            column: "Primary Language Spoken",
            type: String,
            value: (ors) => ors.Preferred_Language
        },
        {
            column: "House Number and Street Name",
            type: String,
            value: (ors) => ors.BillingStreet
        },
        {
            column: "Apartment or Unit Number",
            type: String,
            value: (ors) => ors.Apt
        },
        {
            column: "City",
            type: String,
            value: (ors) => ors.BillingCity
        },
        {
            column: "State",
            type: String,
            value: (ors) => ors.BillingState
        },
        {
            column: "Zip Code",
            type: String,
            value: (ors) => ors.BillingPostalCode
        },
        {
            column: "Rural Area Status",
            type: String,
            value: (ors) => ors.ORS_Rural_Area_Status
        },
        {
            column: "One-on-One Counseling Completed_Homeless Assistance",
            type: String,
            value: (ors) => ors.One_on_One_Homeless_Assistance
        },     
        {
            column: "One-on-One Counseling Completed_Rental Topics",
            type: String,
            value: (ors) => ors.One_on_One_Rental_Topics
        },
        {
            column: "One-on-One Counseling Completed_Pre-purchase/Homebuying",
            type: String,
            value: (ors) => ors.One_on_One_Pre_purchase_Homebuying
        },
        {
            column: "One-on-One Counseling Completed_Non-Delinquency Post-Purchase",
            type: String,
            value: (ors) => ors.One_on_One_Non_Delinquency_Post_Purchase
        },
        {
            column: "One-on-One Counseling Completed_Reverse Mortgage",
            type: String,
            value: (ors) => ors.One_on_One_Reverse_Mortgage
        },
        {
            column: "One-on-One Counseling Completed_Resolving or Preventing Forward Mortgage Delinquency or Default",
            type: String,
            value: (ors) => ors.One_on_One_Forward_Mortgage_Delinquency
        },
        {
            column: "One-on-One Counseling Completed_Resolving or Preventing Reverse Mortgage Delinquency or Default",
            type: String,
            value: (ors) => ors.One_on_One_Reverse_Mortgage_Delinquency
        },
        {
            column: "One-on-One Counseling Completed_Disaster Preparedness Assistance",
            type: String,
            value: (ors) => ors.One_on_One_Disaster_Preparedness_Assista
        },
        {
            column: "One-on-One Counseling Completed_Disaster Recovery Assistance",
            type: String,
            value: (ors) => ors.One_on_One_Disaster_Recovery_Assistance
        },
        {
            column: "Service Completion Date",
            type: String,
            value: (ors) => ors.Date_Closed
        }
    ];

    renderedCallback() {
        if (!this.btndisable) return;
        this.btndisable = true;

        Promise.all([
            loadStyle(this, cssFile),
        ]).then(() => { })
        
        if (this.librariesLoaded) return;
        this.librariesLoaded = true;
        loadScript(this, workbook).then(async (data) => {
            console.log("success------>>>", data);
        }).catch((error) => {
            console.log("failure-------->>>>", error);
        });
    }

    handleddtStartdateClosed(event) {
        this.dtStartdateClosed = event.target.value;
        if(event.target.value){
            if(this.dtStartdateClosed && this.dtEnddateClosed){
                this.btndisable= false;
            }
        }else{
            this.clientCaseList = null;
            this.btndisable = true;
        }
      }

    handleddtEnddateClosed(event) {
        this.dtEnddateClosed = event.target.value;
        if(event.target.value){
            if(this.dtStartdateClosed && this.dtEnddateClosed){
                this.btndisable= false;
            }
        }else{
            this.clientCaseList = null;
            this.btndisable = true;
        }
    }

    refreshData(event) {
        this.isLoading = true;
        getOrsCounselingUniqueList({ dtStartdateClosed: this.dtStartdateClosed, dtEnddateClosed: this.dtEnddateClosed}).then((result) => {
            result.forEach((record) => {
                if (record.BillingStreet == undefined || record.BillingStreet.toString().length == 0) {
                    record.Street_Typeformat = this.missingCSS;
                }
                if (record.BillingCity == undefined || record.BillingCity.toString().length == 0) {
                    record.City_Typeformat = this.missingCSS;
                }
                if (record.BillingState == undefined || record.BillingState.toString().length == 0) {
                    record.State_Typeformat = this.missingCSS;
                }
                if (record.BillingPostalCode == undefined || record.BillingPostalCode.toString().length == 0) {
                    record.Zip_Typeformat = this.missingCSS;
                }
            })
            this.clientCaseList = result;
            this.isLoading = false;
        }).catch((error) => {
            console.log("Error == ", JSON.stringify(error));
            this.isLoading = false;
            const event = new ShowToastEvent({
            title: "Error",
            message: "Issue in loading data ,Please Contact System Admin",
            variant: "error"
            });
            this.dispatchEvent(event);
        });
    }

    async exporttoExcel() {
        let _self = this;
        getOrsCounselingUniqueList({dtStartdateClosed: this.dtStartdateClosed, dtEnddateClosed: this.dtEnddateClosed}).then((result) => {
            writeXlsxFile(result, {
                schema: _self.schemaObj,
                fileName: "NWQR Counseling.xlsx"
            });
        }).catch((error) => {
            console.log('Error = '+error)
            const event = new ShowToastEvent({
            title: "Error",
            message: "Please Contact System Admin",
            variant: "error"
            });
            this.dispatchEvent(event);
        });
    }
}