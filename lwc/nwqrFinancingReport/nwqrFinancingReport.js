import { LightningElement, track } from "lwc";
import getNWQRFinancingList from "@salesforce/apex/NwqrFinancingReportController.fetchNWQRFinancingReports";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
// import { loadScript } from "lightning/platformResourceLoader";
import workbook from "@salesforce/resourceUrl/ConvertToExcel";
import { loadStyle, loadScript } from "lightning/platformResourceLoader";
import cssFile from '@salesforce/resourceUrl/sldsBoxCssFile';
export default class NwqrFinancingReport extends LightningElement {

    librariesLoaded = false;
    btndisable = true;
    @track isLoading = false;
    @track qtrStartdate;
    @track qtrEnddate;
    @track loanList;
    missingCSS = 'slds-box';

    @track sortDirection;
    @track sortBy;

    //columns for excel reports
    @track schemaObj = [
        {
            column: "Client_ID ",
            type: String,
            value: (ors) => ors.Client_ID
        },
        {
            column: "Funding Type ",
            type: String,
            value: (ors) => ors.Funding_Type
        },
        {
            column: "Funding_Source ",
            type: String,
            value: (ors) => ors.Funding_Source
        },
        {
            column: "Financing_Type ",
            type: String,
            value: (ors) => ors.Financing_Type
        },

        {
            column: "Amount ",
            type: Number,
            format: "#,##0.00",
            value: (ors) => ors.Amount
        },
        {
            column: "NWO_role_as_mortgage_underwriter ",
            type: String,
            value: (ors) => ors.NWO_role_as_mortgage_underwriter
        },
        {
            column: "NWO_role_as_mortgage_originator ",
            type: String,
            value: (ors) => ors.NWO_role_as_mortgage_originator
        },
        {
            column: "Rate ",
            type: Number,
            value: (ors) => ors.RateNumeric
        },
        {
            column: "Term ",
            type: String,
            value: (ors) => ors.Term
        },
        {
            column: "Deferred_Term ",
            type: String,
            value: (ors) => ors.Deferred_Term
        },
        {
            column: "Forgivable ",
            type: String,
            value: (ors) => ors.Forgivable
        },

    ];

    //columns for data table
    @track validationColumns = [
        {
            label: "In Download?",
            fieldName: "In_Download",
            type: "text",
            sortable: true,
            hideDefaultActions: true,
            initialWidth: 100
        },
        {
            label: "Missing Loan Details",
            fieldName: "Missing_Loan_Details",
            cellAttributes: {
                class: {
                    fieldName: 'formatMLD'
                }
            },
            type: "text",
            sortable: false,
            hideDefaultActions: true,
            initialWidth: 200
        },
        {
            label: "Equity and Out of Pocket Info",
            fieldName: "Equity_and_Out_of_Pocket_Info",
            cellAttributes: {
                class: {
                    fieldName: 'fortmatEOP'
                }
            },
            type: "text",
            sortable: false,
            hideDefaultActions: true,
            initialWidth: 200
        },
        {
            label: "RLF Info",
            fieldName: "RLF_Info",
            cellAttributes: {
                class: {
                    fieldName: 'fortmatRLF'
                }
            },
            type: "text",
            sortable: false,
            hideDefaultActions: true,
            initialWidth: 200
        },
        {
            label: "Loan Record Number",
            fieldName: "recordid",
            type: "url",
            typeAttributes: { label: { fieldName: 'Loan_Record_Number' }, target: '_blank' },
            sortable: false,
            hideDefaultActions: true,
            initialWidth: 200
        },
        {
            label: "Client ID",
            fieldName: "Client_ID",
            type: "text",
            sortable: true,
            hideDefaultActions: true,
            cellAttributes: {
                class: {
                    fieldName: 'Client_IDformat'
                }
            },
            initialWidth: 100
        },
        {
            label: "Funding Type",
            fieldName: "Funding_Type",
            type: "text",
            sortable: false,
            hideDefaultActions: true,
            cellAttributes: {
                class: {
                    fieldName: 'Funding_Typeformat'
                }
            },
            initialWidth: 200
        },
        {
            label: "Funding Source",
            fieldName: "Funding_Source",
            type: "text",
            sortable: false,
            hideDefaultActions: true,
            cellAttributes: {
                class: {
                    fieldName: 'Funding_Sourceformat'
                }
            },
            initialWidth: 200
        },
        {
            label: "Financing Type",
            fieldName: "Financing_Type",
            type: "text",
            sortable: false,
            hideDefaultActions: true,
            cellAttributes: {
                class: {
                    fieldName: 'Financing_Typeformat'
                }
            },
            initialWidth: 200
        },
        {
            label: "Amount",
            fieldName: "Amount",
            type: "currency",
            typeAttributes: {
                currencyCode: { fieldName: "CurrencyIsoCode" },
                currencyDisplayAs: "symbol"
            },
            cellAttributes: {
                class: {
                    fieldName: 'Amountformat'
                }
            },
            initialWidth: 200
        },
        {
            label: "NWO role as mortgage underwriter",
            fieldName: "NWO_role_as_mortgage_underwriter",
            type: "text",
            sortable: false,
            hideDefaultActions: true,
            cellAttributes: {
                class: {
                    fieldName: 'NWO_role_as_mortgage_underwriterformat'
                }
            },
            initialWidth: 200
        },
        {
            label: "NWO role as mortgage originator",
            fieldName: "NWO_role_as_mortgage_originator",
            type: "text",
            sortable: false,
            hideDefaultActions: true,
            cellAttributes: {
                class: {
                    fieldName: 'NWO_role_as_mortgage_originatorformat'
                }
            },
            initialWidth: 200
        },
        {
            label: "Rate",
            fieldName: "Rate",
            type: "text",
            sortable: false,
            hideDefaultActions: true,
            cellAttributes: {
                class: {
                    fieldName: 'Rateformat'
                }
            },
            initialWidth: 200
        },
        {
            label: "Term",
            fieldName: "Term",
            type: "text",
            sortable: false,
            hideDefaultActions: true,
            initialWidth: 200
        },
        {
            label: "Deferred Term",
            fieldName: "Deferred_Term",
            type: "text",
            sortable: false,
            hideDefaultActions: true,
            cellAttributes: {
                class: {
                    fieldName: 'DeferredTermformat'
                }
            },
            initialWidth: 200
        },
        {
            label: "Forgivable",
            fieldName: "Forgivable",
            type: "text",
            sortable: false,
            hideDefaultActions: true,
            cellAttributes: {
                class: {
                    fieldName: 'Forgivableformat'
                }
            },
            initialWidth: 200
        }

    ];

    //loading static resourses
    renderedCallback() {
        if (!this.btndisable) return;
        this.btndisable = true;

        Promise.all([
            loadStyle(this, cssFile),
        ]).then(() => { })

        if (this.librariesLoaded) return;
        this.librariesLoaded = true;
        loadScript(this, workbook)
            .then(async (data) => {
                console.log("success------>>>", data);
            })
            .catch((error) => {
                console.log("failure-------->>>>", error);
            });
    }

    doSorting(event) {
        this.sortBy = event.detail.fieldName;
        this.sortDirection = event.detail.sortDirection;
        console.log('this.sortDirection : '+this.sortDirection);
        this.sortData(this.sortBy, this.sortDirection);
    }

    sortData(fieldname, direction) {
        let parseData = JSON.parse(JSON.stringify(this.loanList));
        // Return the value stored in the field
        let keyValue = (a) => {
            return a[fieldname];
        };
        // cheking reverse direction
        let isReverse = direction === 'asc' ? 1: -1;
        // sorting data
        parseData.sort((x, y) => {
            x = keyValue(x) ? keyValue(x) : ''; // handling null values
            y = keyValue(y) ? keyValue(y) : '';
            // sorting values based on direction
            return isReverse * ((x > y) - (y > x));
        });
        this.loanList = parseData;
    }    

    //handle start date changes
    handledqtrStartDate(event) {
        this.qtrStartdate = event.target.value;
        if (event.target.value) {
            if (this.qtrStartdate && this.qtrEnddate) {
                this.btndisable = false;
            }
        } else {
            this.loanList = null;
            this.btndisable = true;
        }
    }

    //handle end date changes
    handledqtrEndDate(event) {
        this.qtrEnddate = event.target.value;
        if (event.target.value) {
            if (this.qtrStartdate && this.qtrEnddate) {
                this.btndisable = false;
            }
        } else {
            this.loanList = null;
            this.btndisable = true;
        }
    }

    //fetching loan records
    refreshData() {
        console.log('refreshData called');
        this.isLoading = true;
        getNWQRFinancingList({ qtrStartDate: this.qtrStartdate, qtrEndDate: this.qtrEnddate }).then((result) => {
            console.log("result = ", result);
            var listrecords = [];
            result.forEach((record) => {
                console.log('record.recordTypeName = '+record.recordTypeName);
                record.recordid = '/' + record.recordid;
                if(record.Obj_Name == 'Loan'){
                    if (record.Equity_and_Out_of_Pocket_Info != 'Passed') {
                        record.fortmatEOP = 'slds-text-color_error';
                        record.Equity_and_Out_of_Pocket_Info = 'failed ' + record.Equity_and_Out_of_Pocket_Info;
                    } else {
                        record.fortmatEOP = 'slds-text-color_success';
                        record.Equity_and_Out_of_Pocket_Info = 'Passed';
                    }

                    if (record.RLF_Info != 'Passed') {
                        record.fortmatRLF = 'color-text-warning'; // 'slds-text-color_inverse-weak';      
                        record.RLF_Info = 'warning ' + record.RLF_Info;
                    } else {
                        record.fortmatRLF = 'slds-text-color_success';
                        record.RLF_Info = 'Passed';
                    }
                    if (record.Missing_Loan_Details.includes('missing')) {
                        record.formatMLD = 'slds-text-color_error';
                        record.Missing_Loan_Details = 'failed ' + record.Missing_Loan_Details;
                    } else {
                        record.formatMLD = 'slds-text-color_success';
                        record.Missing_Loan_Details = 'Passed';
                    }
                    if(record.recordTypeName != 'OutOfPocket'){
                        if (!(record.NWO_role_as_mortgage_underwriter && record.NWO_role_as_mortgage_underwriter.toString().length && record.NWO_role_as_mortgage_underwriter.toString().length > 0)) {
                            record.NWO_role_as_mortgage_underwriterformat = this.missingCSS;
                        }

                        if (!(record.NWO_role_as_mortgage_originator && record.NWO_role_as_mortgage_originator.toString().length && record.NWO_role_as_mortgage_originator.toString().length > 0)) {
                            record.NWO_role_as_mortgage_originatorformat = this.missingCSS;
                        }

                        if (!(record.Deferred_Term && record.Deferred_Term.toString().length && record.Deferred_Term.toString().length > 0)) {
                            record.DeferredTermformat = this.missingCSS;
                        }

                        if (record.RateNumeric == null) {
                            record.Rateformat = this.missingCSS;
                        }
                    }
                    
                } else if(record.Obj_Name == 'Grant'){
                    if (record.Missing_Loan_Details == 'failed') {
                        record.formatMLD = 'slds-text-color_error';
                    } else {
                        record.formatMLD = 'slds-text-color_success';
                    }
                }

                if (!(record.Client_ID && record.Client_ID.toString().length && record.Client_ID.toString().length > 0)) {
                    record.Client_IDformat = this.missingCSS;
                }

                if (!(record.Funding_Type && record.Funding_Type.toString().length && record.Funding_Type.toString().length > 0)) {
                    record.Funding_Typeformat = this.missingCSS;
                }

                if (!(record.Funding_Source && record.Funding_Source.toString().length && record.Funding_Source.toString().length > 0)) {
                    record.Funding_Sourceformat = this.missingCSS;
                }

                if (!(record.Financing_Type && record.Financing_Type.toString().length && record.Financing_Type.toString().length > 0)) {
                    record.Financing_Typeformat = this.missingCSS;
                }

                if (!(record.Amount && record.Amount.toString().length && record.Amount.toString().length > 0)) {
                    record.Amountformat = this.missingCSS;
                }

                listrecords.push(record);
            });
            //this.loanList = this.reOrder(listrecords);
            this.loanList = listrecords;
            console.log('true');
            this.isLoading = false;
        }).catch((error) => {
            this.isLoading = false;
            const event = new ShowToastEvent({
                title: "Error",
                message: error,
                variant: "error"
            });
            this.dispatchEvent(event);
        });
    }

    //reOrder Records
    reOrder(records) {
        records.forEach((record, i) => {
            if (record.Missing_Loan_Details == 'Passed' && record.Equity_and_Out_of_Pocket_Info == 'Passed' && record.RLF_Info == 'Passed') {
                if ((record.Client_ID && record.Client_ID.toString().length && record.Client_ID.toString().length > 0) && (record.Funding_Type && record.Funding_Type.toString().length && record.Funding_Type.toString().length > 0) && (record.Funding_Source && record.Funding_Source.toString().length && record.Funding_Source.toString().length > 0) && (record.Financing_Type && record.Financing_Type.toString().length && record.Financing_Type.toString().length > 0) && (record.Amount && record.Amount.toString().length && record.Amount.toString().length > 0)) {
                    if ((record.NWO_role_as_mortgage_underwriter && record.NWO_role_as_mortgage_underwriter.toString().length && record.NWO_role_as_mortgage_underwriter.toString().length > 0) && (record.NWO_role_as_mortgage_originator && record.NWO_role_as_mortgage_originator.toString().length && record.NWO_role_as_mortgage_originator.toString().length > 0) && (record.Forgivable && record.Forgivable.toString().length && record.Forgivable.toString().length > 0)) {
                        records.splice(i, 1);
                        records.unshift(record);
                    }
                }
            }
        });
        return records;
    }

    //exporting excel
    async exporttoExcel() {
        let _self = this;
        getNWQRFinancingList({ qtrStartDate: this.qtrStartdate, qtrEndDate: this.qtrEnddate }).then((result) => {
            var listrecords = [];
            result.forEach((record) => {
                if (record.Missing_Loan_Details == 'Passed' && record.In_Download == 'Yes') {
                    if(!(record.ClientCaseRecordType == 'HomeownerCounseling' && record.ClientCaseSubType == 'NW Client Other Based Services')){
                        listrecords.push(record);
                    }
                }
            });

            writeXlsxFile(listrecords, {
                schema: _self.schemaObj,
                fileName: "NWQR Financing.xlsx"
            });
        }).catch((error) => {
            console.log('error = ' + error);
            const event = new ShowToastEvent({
                title: "Error",
                message: error,
                variant: "error"
            });
            this.dispatchEvent(event);
        });
    }

}