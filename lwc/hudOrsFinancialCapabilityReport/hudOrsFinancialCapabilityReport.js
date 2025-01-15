import { LightningElement, api, track } from "lwc";
import getOrsFinancialUniqueList from "@salesforce/apex/HudOrsFinancialCapabilityReportCtrl.fetchORSFinancialRecords";
import fetchNWQRFCAggregateValidation from "@salesforce/apex/HudOrsFinancialCapabilityReportCtrl.fetchNWQRFCAggregateValidation";
import { loadStyle, loadScript } from "lightning/platformResourceLoader";
import workbook from "@salesforce/resourceUrl/ConvertToExcel";
import cssFile from '@salesforce/resourceUrl/sldsBoxCssFile';
import { ShowToastEvent } from "lightning/platformShowToastEvent";
var activetab='';

export default class HudOrsFinancialCapabilityReport extends LightningElement {
    tabContent = '';
    clientAggregateReportFC;
    clientValidationReportFC;
    showAggregateReportFC = false;
    handleActive(event) {
        activetab = event.target.label;   
        console.log('tab=='+activetab);
    }

  librariesLoaded = false;
  btndisable = true;
  @track isLoading = false;
  @track qtrStartdate;
  @track qtrEnddate;
  
    //FC
    @track columnsAggregateReportFC = [
    
    {
        label: "Item",
        fieldName: "description",
        type: "text",
        sortable: false,
        hideDefaultActions: true,
        initialWidth: 900,
        wrapText: true
    },
    {
        label: "Count",
        fieldName: "count",
        type: "number",
        sortable: false,
        hideDefaultActions: true,
        initialWidth: 70
    }
    ];
    @track columnsValidationReportFC = [
        {
            label: "Client",
            fieldName: "clientName",
            type: "text",
            sortable: false,
            hideDefaultActions: true,
            initialWidth: 270
        },
        {
            label: "Client ID",
            fieldName: "clientId",
            type: "text",
            sortable: false,
            hideDefaultActions: true,
            initialWidth: 270
        },
        {
            label: "FC Coaching Date",
            fieldName: "fcCoachingDate",
            type: "date-local",
            sortable: false,
            hideDefaultActions: true,
            initialWidth: 270
        },
        {
            label: "FC Edu Date",
            fieldName: "fcEduDate",
            type: "date-local",
            sortable: false,
            hideDefaultActions: true,
            initialWidth: 270
        }
    ];
  @track schemaObj1 = [
    {
        column: "Household ID",
        type: String,
        value: (ors) => ors.Household_ID
    },
    {
        column: "First Name",
        type: String,
        value: (ors) => ors.First_Name
    },
    {
        column: "Last Name",
        type: String,
        value: (ors) => ors.Last_Name
    },
    {
        column: "Date Opened",
        type: Date,
        format: "mm/dd/yyyy",
        value: (ors) => ors.Date_Opened
    },
    {
        column: "Age",
        type: String,
        value: (ors) => ors.Age
    },  
    {
        column: "Goal Improve Credit",
        type: String,
        value: (ors) => ors.Goal_Improve_Credit
    },
    {
        column: "Goal Increase Credit Access",
        type: String,
        value: (ors) => ors.Goal_Increase_Credit_Access
    },
    {
        column: "Goal Establish Credit",
        type: String,
        value: (ors) => ors.Goal_Establish_Credit
    },
    {
        column: "Goal Fewer Collections",
        type: String,
        value: (ors) => ors.Goal_Fewer_Collections
    },
    {
        column: "Goal Fewer Past Due",
        type: String,
        value: (ors) => ors.Goal_Fewer_Past_Due
    },
    {
        column: "Goal Reduce Debt",
        type: String,
        value: (ors) => ors.Goal_Reduce_Debt
    },
    {
        column: "Goal Increase Savings",
        type: String,
        value: (ors) => ors.Goal_Increase_Savings
    },
    {
        column: "Goal Increase Worth",
        type: String,
        value: (ors) => ors.Goal_Increase_Worth
    },
    {
        column: "Goal Spend Less on Financial Services",
        type: String,
        value: (ors) => ors.Goal_Spend_Less_on_Financial_Services
    },
    {
        column: "Goal New Financial Products",
        type: String,
        value: (ors) => ors.Goal_New_Financial_Products
    },
    {
        column: "Goal Increase Insurance Coverage",
        type: String,
        value: (ors) => ors.Goal_Increase_Insurance_Coverage
    },
    {
        column: "Goal Manage Fluctuations in Income",
        type: String,
        value: (ors) => ors.Goal_Manage_Fluctuations_in_Income
    },
    {
        column: "Goal Three Months Savings",
        type: String,
        value: (ors) => ors.Goal_Three_Months_Savings
    },
    {
        column: "Goal Savings Goal",
        type: String,
        value: (ors) => ors.Goal_Savings_Goal
    },
    {
        column: "Goal Decrease Tax Filing Cost",
        type: String,
        value: (ors) => ors.Goal_Decrease_Tax_Filing_Cost
    },
    {
        column: "Goal Increase Tax Benefit",
        type: String,
        value: (ors) => ors.Goal_Increase_Tax_Benefit
    },
    {
        column: "Goal Optimize Public Benefits",
        type: String,
        value: (ors) => ors.Goal_Optimize_Public_Benefits
    },
    {
        column: "Goal Optimize Public Benefits",
        type: String,
        value: (ors) => ors.Goal_of_Stabilize_housing
    },
    {
        column: "Gender",
        type: String,
        value: (ors) => ors.Gender
    },
    {
        column: "Race",
        type: String,
        value: (ors) => ors.Race
    },
    {
        column: "Ethnicity",
        type: String,
        value: (ors) => ors.Ethnicity
    },
    {
        column: "Number of Household Members",
        type: String,
        value: (ors) => ors.Number_of_Household_Members
    },
    {
        column: "Annual HH Income at Start of Service",
        type: Number,
        format: "#,##0.00",
        value: (ors) => ors.Annual_HH_Income_at_Start_of_Service
    },
    {
      column: "Annual HH Income at End of Service",
      type: Number,
      format: "#,##0.00",
      value: (ors) => ors.Annual_HH_Income_at_End_of_Service
    },
    {
        column: "AMI at Start of Service",
        type: String,
        value: (ors) => ors.AMI_at_Start_of_Service
    },
    {
        column: "AMI at End of Service",
        type: String,
        value: (ors) => ors.AMI_at_End_of_Service
    },
    {
        column: "Savings at Start of Service",
        type: Number,
        format: "#,##0.00",
        value: (ors) => ors.Savings_at_Start_of_Service
    },
    {
      column: "Savings at End of Service",
      type: Number,
      format: "#,##0.00",
      value: (ors) => ors.Savings_at_End_of_Service
    },
    {
        column: "Credit Score at Start of Service",
        type: String,
        value: (ors) => ors.Credit_Score_at_Start_of_Service
    },
    {
        column: "Credit Score at End of Service",
        type: String,
        value: (ors) => ors.Credit_Score_at_End_of_Service
    },
    {
        column: "Debt at Start of Service",
        type: Number,
        format: "#,##0.00",
        value: (ors) => ors.Debt_at_Start_of_Service
    },
    {
      column: "Debt at End of Service",
      type: Number,
      format: "#,##0.00",
      value: (ors) => ors.Debt_at_End_of_Service
    },
    {
        column: "Residence Type at Start of Service",
        type: String,
        value: (ors) => ors.Residence_Type_at_Start_of_Service
    },
    {
        column: "Residence Type at End of Service",
        type: String,
        value: (ors) => ors.Residence_Type_at_End_of_Service
    },
    {
        column: "Address",
        type: String,
        value: (ors) => ors.Address
    },
    {
        column: "Street Name",
        type: String,
        value: (ors) => ors.Street_Name
    },
    {
        column: "Apt",
        type: String,
        value: (ors) => ors.Apt
    },
    {
        column: "Primary_City",
        type: String,
        value: (ors) => ors.Primary_City
    },
    {
        column: "Primary State",
        type: String,
        value: (ors) => ors.Primary_State
    },
    {
        column: "Primary Zip",
        type: String,
        value: (ors) => ors.Primary_Zip
    },
    {
        column: "Total Counseling Hours",
        type: String,
        value: (ors) => ors.Total_Counseling_Hours
    },
    {
        column: "Total Hours of FC Education",
        type: String,
        value: (ors) => ors.Total_Hours_of_FC_Education
    },
    {
        column: "Financial Capability Completion Date",
        type: Date,
        format: "mm/dd/yyyy",
        value: (ors) => ors.Financial_Capability_Completion_Date
    },
    {
        column: "Outcome Improve Credit",
        type: String,
        value: (ors) => ors.Outcome_Improve_Credit
    },
    {
        column: "Outcome Increase Credit Access",
        type: String,
        value: (ors) => ors.Outcome_Increase_Credit_Access
    },
    {
        column: "Outcome Establish Credit",
        type: String,
        value: (ors) => ors.Outcome_Establish_Credit
    },
    {
        column: "Outcome Fewer Collections",
        type: String,
        value: (ors) => ors.Outcome_Fewer_Collections
    },
    {
        column: "Outcome Fewer Past Due",
        type: String,
        value: (ors) => ors.Outcome_Fewer_Past_Due
    },
    {
        column: "Outcome Reduce Debt",
        type: String,
        value: (ors) => ors.Outcome_Reduce_Debt
    },
    {
        column: "Outcome Increase Savings",
        type: String,
        value: (ors) => ors.Outcome_Increase_Savings
    },
    {
        column: "Outcome Increase Worth",
        type: String,
        value: (ors) => ors.Outcome_Increase_Worth
    },
    {
        column: "Outcome Spend Less on Financial Services",
        type: String,
        value: (ors) => ors.Outcome_Spend_Less_on_Financial_Services
    },
    {
        column: "Outcome(s) achieved by end of coaching (check all that apply)_Engaged in new financial products (e.g. savings/checking aSorted by Outcome(s) achieved by end of coaching (check all that apply)_Engaged in new financial products (e.g. savings/checking a, A-to-Z",
        type: String,
        value: (ors) => ors.Outcome_achieved
    },

    {
        column: "Outcome Increase Insurance Coverage",
        type: String,
        value: (ors) => ors.Outcome_Increase_Insurance_Coverage
    },
    {
        column: "Outcome Manage Fluctuations in Income",
        type: String,
        value: (ors) => ors.Outcome_Manage_Fluctuations_in_Income
    },
    {
        column: "Outcome Three Months Savings",
        type: String,
        value: (ors) => ors.Outcome_Three_Months_Savings
    },
    {
        column: "Outcome Savings Goal",
        type: String,
        value: (ors) => ors.Outcome_Savings_Goal
    },
    {
        column: "Outcome Decrease Tax Filing Cost",
        type: String,
        value: (ors) => ors.Outcome_Decrease_Tax_Filing_Cost
    },
    {
        column: "Outcome Increase Tax Benefit",
        type: String,
        value: (ors) => ors.Outcome_Increase_Tax_Benefit
    },
    {
        column: "Outcome Optimize Public Benefits",
        type: String,
        value: (ors) => ors.Outcome_Optimize_Public_Benefits
    },
    {
        column: "Outcome of Stabilize housing",
        type: String,
        value: (ors) => ors.Outcome_of_Stabilize_housing
    }

  ];

  @track columns = [
    {
        label: "Financial Capability Data Complete",
        fieldName: "Financial_Capability_Data_Complete",
        cellAttributes: {
            class: {
                fieldName: 'format1'
            }
        },
        type: "text",
        sortable: false,
        hideDefaultActions: true,
        initialWidth: 100
    },
    {
      label: "Client Case Name",
      fieldName: "Service_Name",
      type: "url",
      typeAttributes: { label: { fieldName: 'ServiceName' }, target: '_blank'},
      sortable: false,
      hideDefaultActions: true,
      initialWidth: 150     
    },
    {
        label: "First Name",
        fieldName: "First_Name",
        type: "text",
        cellAttributes: {
            class: {
                fieldName: 'firstnameformat'
            }
        },
        sortable: false,
        hideDefaultActions: true,
        initialWidth: 100
    },
    {
        label: "Last Name",
        fieldName: "Last_Name",
        type: "text",
        cellAttributes: {
            class: {
                fieldName: 'lastnameformat'
            }
        },
        sortable: false,
        hideDefaultActions: true,
        initialWidth: 100
    },
    {
        label: "Date Opened",
        fieldName: "Date_Opened",
        type: "date",
        typeAttributes: {month: "2-digit",day: "2-digit",year: "numeric"},
        sortable: false,
        hideDefaultActions: true,
        initialWidth: 100
    },
    {
        label: "Birthdate",
        fieldName: "Birthdate",
        type: "date",
        typeAttributes: {month: "2-digit",day: "2-digit",year: "numeric"},
        cellAttributes: {
            class: {
                fieldName: 'birthdateformat'
            }
        },
        sortable: false,
        hideDefaultActions: true,
        initialWidth: 100
    },
    {
        label: "Gender",
        fieldName: "Gender",
        type: "text",
        cellAttributes: {
            class: {
                fieldName: 'genderformat'
            }
        },
        sortable: false,
        hideDefaultActions: true,
        initialWidth: 100
    },
    {
        label: "Race",
        fieldName: "Race",
        type: "text",
        sortable: false,
        cellAttributes: {
            class: {
                fieldName: 'raceformat'
            }
        },
        hideDefaultActions: true,
        initialWidth: 100
    },
    {
        label: "Ethnicity",
        fieldName: "Ethnicity",
        type: "text",
        sortable: false,
        cellAttributes: {
            class: {
                fieldName: 'ethnicityformat'
            }
        },
        hideDefaultActions: true,
        initialWidth: 100
    },
    {
        label: "Number of Household Members",
        fieldName: "Number_of_Household_Members",
        type: "text",
        cellAttributes: {
            class: {
                fieldName: 'householdsizeformat'
            }
        },
        sortable: false,
        hideDefaultActions: true,
        initialWidth: 100
    },
    {
        label: "Annual HH Income at Start of Service",
        fieldName: "Annual_HH_Income_at_Start_of_Service",
        type: "currency",
        typeAttributes: {
          currencyCode: { fieldName: "CurrencyIsoCode" },
          currencyDisplayAs: "symbol"
        },
        cellAttributes: {
            class: {
                fieldName: 'preincomeformat'
            }
        },
        sortable: false,
        hideDefaultActions: true,
        initialWidth: 100
    },
    {
        label: "Annual HH Income at End of Service",
        fieldName: "Annual_HH_Income_at_End_of_Service",
        type: "currency",
        typeAttributes: {
          currencyCode: { fieldName: "CurrencyIsoCode" },
          currencyDisplayAs: "symbol"
        },
        cellAttributes: {
            class: {
                fieldName: 'postincomeformat'
            }
        },
        sortable: false,
        hideDefaultActions: true,
        initialWidth: 100
    }, 
    {
        label: "AMI at Start of Service",
        fieldName: "AMI_at_Start_of_Service",
        type: "text",
        sortable: false,
        cellAttributes: {
            class: {
                fieldName: 'preamiformat'
            }
        },
        hideDefaultActions: true,
        initialWidth: 100
    },
    {
        label: "AMI at End of Service",
        fieldName: "AMI_at_End_of_Service",
        type: "text",
        sortable: false,
        cellAttributes: {
            class: {
                fieldName: 'postamiformat'
            }
        },
        hideDefaultActions: true,
        initialWidth: 100
    },
    {
        label: "Savings at Start of Service",
        fieldName: "Savings_at_Start_of_Service",
        type: "currency",
        typeAttributes: {
          currencyCode: { fieldName: "CurrencyIsoCode" },
          currencyDisplayAs: "symbol"
        },
        cellAttributes: {
            class: {
                fieldName: 'presavingformat'
            }
        },
        sortable: false,
        hideDefaultActions: true,
        initialWidth: 100
    },
    {
        label: "Savings at End of Service",
        fieldName: "Savings_at_End_of_Service",
        type: "currency",
        cellAttributes: {
            class: {
                fieldName: 'postsavingformat'
            }
        },
        typeAttributes: {
          currencyCode: { fieldName: "CurrencyIsoCode" },
          currencyDisplayAs: "symbol"
        },
        sortable: false,
        hideDefaultActions: true,
        initialWidth: 100
    }, 
    {
        label: "Credit Score at Start of Service",
        fieldName: "Credit_Score_at_Start_of_Service",
        type: "text",
        sortable: false,
        cellAttributes: {
            class: {
                fieldName: 'precreditformat'
            }
        },
        hideDefaultActions: true,
        initialWidth: 100
    },
    {
        label: "Credit Score at End of Service",
        fieldName: "Credit_Score_at_End_of_Service",
        type: "text",
        sortable: false,
        cellAttributes: {
            class: {
                fieldName: 'postcreditformat'
            }
        },
        hideDefaultActions: true,
        initialWidth: 100
    },
    {
        label: "Debt at Start of Service",
        fieldName: "Debt_at_Start_of_Service",
        type: "currency",
        typeAttributes: {
          currencyCode: { fieldName: "CurrencyIsoCode" },
          currencyDisplayAs: "symbol"
        },
        cellAttributes: {
            class: {
                fieldName: 'predebtformat'
            }
        },
        sortable: false,
        hideDefaultActions: true,
        initialWidth: 100
    },
    {
        label: "Debt at End of Service",
        fieldName: "Debt_at_End_of_Service",
        type: "currency",
        typeAttributes: {
          currencyCode: { fieldName: "CurrencyIsoCode" },
          currencyDisplayAs: "symbol"
        },
        cellAttributes: {
            class: {
                fieldName: 'postdebtformat'
            }
        },
        sortable: false,
        hideDefaultActions: true,
        initialWidth: 100
    }, 
    {
        label: "Residence Type at Start of Service",
        fieldName: "Residence_Type_at_Start_of_Service",
        type: "text",
        sortable: false,
        cellAttributes: {
            class: {
                fieldName: 'preresidenceformat'
            }
        },
        hideDefaultActions: true,
        initialWidth: 100
    },
    {
        label: "Residence Type at End of Service",
        fieldName: "Residence_Type_at_End_of_Service",
        type: "text",
        sortable: false,
        cellAttributes: {
            class: {
                fieldName: 'postresidenceformat'
            }
        },
        hideDefaultActions: true,
        initialWidth: 100
    },
    {
        label: "Address",
        fieldName: "Address",
        type: "text",
        sortable: false,
        hideDefaultActions: true,
        initialWidth: 100
    },
    {
        label: "Street Name",
        fieldName: "Street_Name",
        type: "text",
        cellAttributes: {
            class: {
                fieldName: 'streetformat'
            }
        },
        sortable: false,
        hideDefaultActions: true,
        initialWidth: 100
    },
    {
        label: "Apt",
        fieldName: "Apt",
        type: "text",
        sortable: false,
        hideDefaultActions: true,
        initialWidth: 100
    },
    {
        label: "Primary City",
        fieldName: "Primary_City",
        type: "text",
        sortable: false,
        hideDefaultActions: true,
        initialWidth: 100
    },
    {
        label: "Primary State",
        fieldName: "Primary_State",
        type: "text",
        sortable: false,
        hideDefaultActions: true,
        initialWidth: 100
    },
    {
        label: "Primary Zip",
        fieldName: "Primary_Zip",
        type: "text",
        sortable: false,
        hideDefaultActions: true,
        initialWidth: 100
    },
    {
        label: "Total Counseling Hours",
        fieldName: "Total_Counseling_Hours",
        type: "text",
        sortable: false,
        hideDefaultActions: true,
        initialWidth: 100
    },
    {
        label: "Total Hours of FC Education",
        fieldName: "Total_Hours_of_FC_Education",
        type: "String",
        sortable: false,
        hideDefaultActions: true,
        initialWidth: 100
    },
    {
        label: "Financial Capability Completion Date",
        fieldName: "Financial_Capability_Completion_Date",
        type: "date",
        cellAttributes: {
            class: {
                fieldName: 'fccompletionformat'
            }
        },
        typeAttributes: {month: "2-digit",day: "2-digit",year: "numeric"},
        sortable: false,
        hideDefaultActions: true,
        initialWidth: 100
    }
  ];

  handledqtrStartDate(event) {

    console.log('handledqtrStartDate',event.target.value);
    console.log('handledqtrStartDate before',this.btndisable);
    this.qtrStartdate = event.target.value;
    if(event.target.value){
        
        if(this.qtrStartdate && this.qtrEnddate){
            this.btndisable= false;
        }

        console.log('handledqtrStartDate',event.target.value);
        console.log('handledqtrStartDate after',this.btndisable);
    }else{
        
        this.bookingList = null;
        this.bookingList1 = null;
        this.btndisable = true;
       

    }
  }

  handledqtrEndDate(event) {
      console.log('event.target.value'+event.target.value);
      this.qtrEnddate = event.target.value;
    if(event.target.value){
        

        if(this.qtrStartdate && this.qtrEnddate){
            this.btndisable= false;
        }
     }else{
       
        this.bookingList = null;
        this.bookingList1 = null;
        this.btndisable = true;
    }
  }

  @track error;
  @track bookingList;
  @track bookingList1;
  @track exportList = [];
  simpleMap = [];
  missingCSS = 'slds-box';

refreshData(event) {
    console.log(this.qtrStartdate);
    console.log(this.qtrEnddate);
    this.isLoading = true;
    getOrsFinancialUniqueList({
      qtrStartDate: this.qtrStartdate,
      qtrEndDate: this.qtrEnddate
    })
    .then((result) => {
        console.log("result", result);
        if(result['Validation']){
            for(let key in result) {
                if(key=='Validation'){
                    var listrecords=[];
                    var listrecords1=[];
                    listrecords=result[key];
                    this.isLoading = false;
                    listrecords.forEach( ( record ) => {
                        let tempRec = Object.assign( {}, record );
                        record.Service_Name='/' +record.recordid;     

                        var string1 = record.Financial_Capability_Data_Complete; 
                        
                        if(string1.includes('passed')) {               
                            record.format1=  'slds-text-color_success';                        
                        }                    
                        else {
                            record.format1 =  'slds-text-color_error'; 
                        }
                        if(!(record.First_Name && record.First_Name.length && record.First_Name.length > 0)){
                            record.firstnameformat = this.missingCSS;
                        }
                        if(!(record.Last_Name && record.Last_Name.length && record.Last_Name.length > 0)){
                            record.lastnameformat = this.missingCSS;
                        }
                        if(!(record.Birthdate && record.Birthdate.toString().length && record.Birthdate.toString().length > 0)){
                            record.birthdateformat = this.missingCSS;
                        }
                        if(!(record.Gender && record.Gender.length && record.Gender.length > 0)){
                            record.genderformat = this.missingCSS;
                        }
                        if(!(record.Race && record.Race.length && record.Race.length > 0)){
                            record.raceformat = this.missingCSS;
                        }
                        if(!(record.Ethnicity && record.Ethnicity.length && record.Ethnicity.length > 0)){
                            record.ethnicityformat = this.missingCSS;
                        }
                        if(!(record.Number_of_Household_Members && record.Number_of_Household_Members.length && record.Number_of_Household_Members.length > 0)){
                            record.householdsizeformat = this.missingCSS;
                        }
                        if(!(record.Annual_HH_Income_at_Start_of_Service && record.Annual_HH_Income_at_Start_of_Service.toString().length && record.Annual_HH_Income_at_Start_of_Service.toString().length > 0)){
                            record.preincomeformat = this.missingCSS;
                        }
                        if(!(record.Annual_HH_Income_at_End_of_Service && record.Annual_HH_Income_at_End_of_Service.toString().length && record.Annual_HH_Income_at_End_of_Service.toString().length > 0)){
                            record.postincomeformat = this.missingCSS;
                        }
                        if(!(record.AMI_at_Start_of_Service && record.AMI_at_Start_of_Service.length && record.AMI_at_Start_of_Service.length > 0)){
                            record.preamiformat = this.missingCSS;
                        }
                        if(!(record.AMI_at_End_of_Service && record.AMI_at_End_of_Service.length && record.AMI_at_End_of_Service.length > 0)){
                            record.postamiformat = this.missingCSS;
                        }
                        if(!(record.Savings_at_Start_of_Service && record.Savings_at_Start_of_Service.toString().length && record.Savings_at_Start_of_Service.toString().length > 0)){
                            record.presavingformat = this.missingCSS;
                        }
                        if(!(record.Savings_at_End_of_Service && record.Savings_at_End_of_Service.toString().length && record.Savings_at_End_of_Service.toString().length > 0)){
                            record.postsavingformat = this.missingCSS;
                        }
                        if(!(record.Credit_Score_at_Start_of_Service && record.Credit_Score_at_Start_of_Service.length && record.Credit_Score_at_Start_of_Service.length > 0)){
                            record.precreditformat = this.missingCSS;
                        }
                        if(!(record.Credit_Score_at_End_of_Service && record.Credit_Score_at_End_of_Service.length && record.Credit_Score_at_End_of_Service.length > 0)){
                            record.postcreditformat = this.missingCSS;
                        }
                        if(!(record.Debt_at_Start_of_Service && record.Debt_at_Start_of_Service.toString().length && record.Debt_at_Start_of_Service.toString().length > 0)){
                            record.predebtformat = this.missingCSS;
                        }
                        if(!(record.Debt_at_End_of_Service && record.Debt_at_End_of_Service.toString().length && record.Debt_at_End_of_Service.toString().length > 0)){
                            record.postdebtformat = this.missingCSS;
                        }
                        if(!(record.Residence_Type_at_Start_of_Service && record.Residence_Type_at_Start_of_Service.length && record.Residence_Type_at_Start_of_Service.length > 0)){
                            record.preresidenceformat = this.missingCSS;
                        }
                        if(!(record.Residence_Type_at_End_of_Service && record.Residence_Type_at_End_of_Service.length && record.Residence_Type_at_End_of_Service.length > 0)){
                            record.postresidenceformat = this.missingCSS;
                        }
                        if(!(record.Street_Name && record.Street_Name.length && record.Street_Name.length > 0)){
                            record.streetformat = this.missingCSS;
                        }
                        if(!(record.Financial_Capability_Completion_Date && record.Financial_Capability_Completion_Date.toString().length && record.Financial_Capability_Completion_Date.toString().length > 0)){
                            record.fccompletionformat = this.missingCSS;
                        }
                        listrecords1.push( record );
                    });
                    this.bookingList = listrecords1;
                }
            }
        } else {
            const event = new ShowToastEvent({
            title: "Error",
            message: "No valid records found, Please re-validate date range",
            variant: "error"
            });
            this.dispatchEvent(event);
        }
        this.isLoading = false;     
    })
    .catch((error) => {
        this.isLoading = false;
        console.log(error);
        const event = new ShowToastEvent({
          title: "Error",
          message: "Issue in loading data ,Please Contact System Admin",
          variant: "error"
        });
        this.dispatchEvent(event);
    });
}

renderedCallback() {
    console.log("renderedCallback xlsx");
    if(!this.btndisable) return;
    this.btndisable = true;

    Promise.all([
        loadStyle(this, cssFile),
    ]).then(() => {})

    if (this.librariesLoaded) return;
    this.librariesLoaded = true;
    loadScript(this, workbook + "/WriteExcel/js/write-excel-file.min.js")
      .then(async (data) => {
        console.log("success------>>>", data);
    })
      .catch((error) => {
        console.log("failure-------->>>>", error);
    });
}

async exporttoExcel() {
    
    let _self = this;
    // When passing `objects` and `schema`.
      
    getOrsFinancialUniqueList({
        qtrStartDate: this.qtrStartdate,
        qtrEndDate: this.qtrEnddate
    })
        .then((result) => {
            for(let key in result) {
                //if(activetab=="Financial Capability Export"){
                    if(key=='Export'){
                        console.log("export", result);
                        var listrecords=[];
                        listrecords=result[key];
                        this.isLoading = false;
                        console.log("this.bookingList==", listrecords);
                        listrecords.forEach(function (rec) {
                            console.log("export1", rec);
                            rec.Date_Opened = new Date(rec.Date_Opened);
                            rec.Date_Opened.setDate(rec.Date_Opened.getDate());
                            rec.Birthdate = new Date(rec.Birthdate);
                            rec.Birthdate.setDate(rec.Birthdate.getDate());
                            rec.Financial_Capability_Completion_Date= new Date(rec.Financial_Capability_Completion_Date);
                            rec.Financial_Capability_Completion_Date.setDate(rec.Financial_Capability_Completion_Date.getDate());
                        });
                    
                        writeXlsxFile(listrecords, {
                            schema: _self.schemaObj1,
                            fileName: "NWQR Financial Capability Export.xlsx"
                        });
                    }
                //}
            }
        })       
        .catch((error) => {
            const event = new ShowToastEvent({
            title: "Error",
            message: "Please Contact System Admin",
            variant: "error"
            });
            this.dispatchEvent(event);
        });
    }   
refreshFCAggregateValidation(event){
    console.log('refreshFCAggregateValidation: ' );
    
    fetchNWQRFCAggregateValidation({
        qtrStartDate: this.qtrStartdate,
        qtrEndDate: this.qtrEnddate
    })
    .then((result) => {
        console.log('result: ' +JSON.stringify(result));
        this.clientAggregateReportFC = result.aggrigateWrapList;
        this.clientValidationReportFC = result.detailWrapList;
    })
    .catch((error) => {
        console.log('error: ' +error);
        this.isLoading = false;
        const event = new ShowToastEvent({
            title: "Error",
            message: "Issue in loading data ,Please Contact System Admin",
            variant: "error"
        });
        this.dispatchEvent(event);
    });
    this.showAggregateReportFC = true;
}
}