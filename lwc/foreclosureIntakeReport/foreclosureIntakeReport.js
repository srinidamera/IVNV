import { LightningElement, track, api } from 'lwc';
import fetchAllTableData from "@salesforce/apex/ForeclosureIntakeReportController.fetchAllTableData";
import fetchTable1Data from "@salesforce/apex/ForeclosureIntakeReportController.fetchTable1Data";
import fetchTable2Data from "@salesforce/apex/ForeclosureIntakeReportController.fetchTable2Data";
import fetchTable3Data from "@salesforce/apex/ForeclosureIntakeReportController.fetchTable3Data";
import fetchTable4Data from "@salesforce/apex/ForeclosureIntakeReportController.fetchTable4Data";
import fetchTable5Data from "@salesforce/apex/ForeclosureIntakeReportController.fetchTable5Data";
import fetchReport from "@salesforce/apex/ForeclosureIntakeReportController.fetchReport";
import { loadScript } from "lightning/platformResourceLoader";
import workbook from "@salesforce/resourceUrl/ConvertToExcel"; 


export default class ForeclosureIntakeReport extends LightningElement {
    librariesLoaded = false;
    btndisable = true;
    @track isLoading = false;
    @track qtrStartdate;
    @track qtrEnddate;
    @track columnsDetailReportWithCost = [
        {
            label: "Client ID",
            fieldName: "clientNumber",
            type: "text",
            sortable: false,
            hideDefaultActions: true,
            initialWidth: 240
        },
        {
            label: "Client Case #",
            fieldName: "caseNumber",
            type: "text",
            sortable: false,
            hideDefaultActions: true,
            initialWidth: 240
        },
        {
            label: "Client Name",
            fieldName: "clientName",
            type: "text",
            sortable: false,
            hideDefaultActions: true,
            initialWidth: 250
        },
        {
            label: "Resolution Date",
            fieldName: "resolutionDate",
            type: "text",
            sortable: false,
            hideDefaultActions: true,
            initialWidth: 160
        },
        {
            label: "Intake Date",
            fieldName: "intakeDate",
            type: "text",
            sortable: false,
            hideDefaultActions: true,
            initialWidth: 100
        },
        {
            label: "Units",
            fieldName: "units",
            type: "text",
            sortable: false,
            hideDefaultActions: true,
            initialWidth: 100
        },
        {
            label: "Sum Of Repair Financing",
            fieldName: "costs",
            type: "text",
            sortable: false,
            hideDefaultActions: true,
            initialWidth: 150
        }
    ]
    @track columnsDetailReport = [
        {
            label: "Client ID",
            fieldName: "clientNumber",
            type: "text",
            sortable: false,
            hideDefaultActions: true,
            initialWidth: 240
        },
        {
            label: "Client Case #",
            fieldName: "caseNumber",
            type: "text",
            sortable: false,
            hideDefaultActions: true,
            initialWidth: 240
        },
        {
            label: "Client Name",
            fieldName: "clientName",
            type: "text",
            sortable: false,
            hideDefaultActions: true,
            initialWidth: 250
        },
        {
            label: "Resolution Date",
            fieldName: "resolutionDate",
            type: "text",
            sortable: false,
            hideDefaultActions: true,
            initialWidth: 170
        },
        {
            label: "Intake Date",
            fieldName: "intakeDate",
            type: "text",
            sortable: false,
            hideDefaultActions: true,
            initialWidth: 170
        },
        {
            label: "Units",
            fieldName: "units",
            type: "text",
            sortable: false,
            hideDefaultActions: true,
            initialWidth: 170
        }
    ];

    @track schemaObj = [
        {
            column: "Total Owner-Occupied Units Repaired",
            type: Number,
            value: (ors) => ors.table1Units
        },
        {
            column: "Total Cost of Repairs to Owner-Occupied Units",
            type: Number,
            value: (ors) => ors.table1Costs
        },
        {
            column: "Out of your total Owner-Occupied Units Repaired, how many have seniors as the head of household",
            type: Number,
            value: (ors) => ors.table2Units
        },
        {
            column: "Out of your total Owner-Occupied Units Repaired, how many were repaired in direct response to a public health crisis or a natural disaster, or to increase or improve climate resilience?",
            type: Number,
            value: (ors) => ors.table3Units
        },
        {
            column: "Out of your total Owner-Occupied Units Repaired, how many were repaired to increase or improve climate resilience?",
            type: Number,
            value: (ors) => ors.table4Units
        },
        {
            column: "Foreclosure Intake (Households)",
            type: Number,
            value: (ors) => ors.table5Units
        }
    ];

    renderedCallback() {
        if (!this.btndisable) return;
        this.btndisable = true;

        if (this.librariesLoaded) return;
        this.librariesLoaded = true;
        loadScript(this, workbook).then(async (data) => {
            console.log("success------>>>", data);
        }).catch((error) => {
            console.log("failure-------->>>>", error);
        });
    }

    @track table1Data
    @track totalTable1Records
    @track showTable1Pagination = false
    fetchTable1Data(event){
        var pageNumber = event.detail.pageNumber - 1;
        fetchTable1Data({qtrStartDate: this.qtrStartdate, qtrEndDate: this.qtrEnddate, pageNumber : pageNumber}).then((result) => {
            console.log('result of fetchTable1Data: ' +JSON.stringify(result));
            this.table1Data = result;
        }).catch((error) => {
            console.log('error: ' +JSON.stringify(error));
            this.isLoading = false;
            const event = new ShowToastEvent({
                title: "Error",
                message: error,
                variant: "error"
            });
            this.dispatchEvent(event);
        });
    }

    @track table2Data
    @track totalTable2Records
    @track showTable2Pagination = false
    fetchTable2Data(event){
        var pageNumber = event.detail.pageNumber - 1;
        fetchTable2Data({qtrStartDate: this.qtrStartdate, qtrEndDate: this.qtrEnddate, pageNumber : pageNumber}).then((result) => {
            console.log('result of fetchTable1Data: ' +JSON.stringify(result));
            this.table2Data = result;
        }).catch((error) => {
            console.log('error: ' +JSON.stringify(error));
            this.isLoading = false;
            const event = new ShowToastEvent({
                title: "Error",
                message: error,
                variant: "error"
            });
            this.dispatchEvent(event);
        });
    }

    @track table3Data
    @track totalTable3Records
    @track showTable3Pagination = false
    fetchTable3Data(event){
        var pageNumber = event.detail.pageNumber - 1;
        fetchTable3Data({qtrStartDate: this.qtrStartdate, qtrEndDate: this.qtrEnddate, pageNumber : pageNumber}).then((result) => {
            console.log('result of fetchTable1Data: ' +JSON.stringify(result));
            this.table3Data = result;
        }).catch((error) => {
            console.log('error: ' +JSON.stringify(error));
            this.isLoading = false;
            const event = new ShowToastEvent({
                title: "Error",
                message: error,
                variant: "error"
            });
            this.dispatchEvent(event);
        });
    }

    @track table4Data
    @track totalTable4Records
    @track showTable4Pagination = false
    fetchTable4Data(event){
        var pageNumber = event.detail.pageNumber - 1;
        fetchTable4Data({qtrStartDate: this.qtrStartdate, qtrEndDate: this.qtrEnddate, pageNumber : pageNumber}).then((result) => {
            console.log('result of fetchTable1Data: ' +JSON.stringify(result));
            this.table4Data = result;
        }).catch((error) => {
            console.log('error: ' +JSON.stringify(error));
            this.isLoading = false;
            const event = new ShowToastEvent({
                title: "Error",
                message: error,
                variant: "error"
            });
            this.dispatchEvent(event);
        });
    }

    @track table5Data
    @track totalTable5Records
    @track showTable5Pagination = false
    fetchTable5Data(event){
        var pageNumber = event.detail.pageNumber - 1;
        fetchTable5Data({qtrStartDate: this.qtrStartdate, qtrEndDate: this.qtrEnddate, pageNumber : pageNumber}).then((result) => {
            console.log('result of fetchTable1Data: ' +JSON.stringify(result));
            this.table5Data = result;
        }).catch((error) => {
            console.log('error: ' +JSON.stringify(error));
            this.isLoading = false;
            const event = new ShowToastEvent({
                title: "Error",
                message: error,
                variant: "error"
            });
            this.dispatchEvent(event);
        });
    }

    fetchAllTableData(){
        fetchAllTableData({qtrStartDate: this.qtrStartdate, qtrEndDate: this.qtrEnddate}).then((result) => {
            console.log('result of fetchAllTableData: ' +JSON.stringify(result));
            this.table1Data = result.table1Data.tableData;
            this.totalTable1Records = result.table1Data.totalRecords;
            if(this.totalTable1Records > 10){
                this.showTable1Pagination = true;
            }

            this.table2Data = result.table2Data.tableData;
            this.totalTable2Records = result.table2Data.totalRecords;
            if(this.totalTable2Records > 10){
                this.showTable2Pagination = true;
            }

            this.table3Data = result.table3Data.tableData;
            this.totalTable3Records = result.table3Data.totalRecords;
            if(this.totalTable3Records > 10){
                this.showTable3Pagination = true;
            }

            this.table4Data = result.table4Data.tableData;
            this.totalTable4Records = result.table4Data.totalRecords;
            if(this.totalTable4Records > 10){
                this.showTable4Pagination = true;
            }

            this.table5Data = result.table5Data.tableData;
            this.totalTable5Records = result.table5Data.totalRecords;
            if(this.totalTable5Records > 10){
                this.showTable5Pagination = true;
            }
        }).catch((error) => {
            console.log('error: ' +JSON.stringify(error));
            this.isLoading = false;
            const event = new ShowToastEvent({
                title: "Error",
                message: error,
                variant: "error"
            });
            this.dispatchEvent(event);
        });
    }

    handledqtrStartDate(event) {
        this.qtrStartdate = event.target.value;
        if (this.qtrStartdate) {
            if (this.qtrStartdate && this.qtrEnddate) {
                this.btndisable = false;
            }
        } else {
        this.appointmentAggregateReport = null;
        this.btndisable = true;
        }
    }

    handledqtrEndDate(event) {
        this.qtrEnddate = event.target.value;
        if (this.qtrEnddate) {
            if (this.qtrStartdate && this.qtrEnddate) {
                this.btndisable = false;
            }
        } else {
        this.appointmentAggregateReport = null;
        this.btndisable = true;
        }
    }

    async exporttoExcel() {
        let _self = this;
        fetchReport({qtrStartDate: this.qtrStartdate, qtrEndDate: this.qtrEnddate}).then((result) => {
            console.log('result = '+JSON.stringify(result));
            writeXlsxFile(result, {
                schema: _self.schemaObj,
                fileName: "NWQR Summary.xlsx"
            });
        }).catch((error) => {
            console.log('Error = '+JSON.stringify(error))
            const event = new ShowToastEvent({
            title: "Error",
            message: "Please Contact System Admin",
            variant: "error"
            });
            this.dispatchEvent(event);
        });
    }
}