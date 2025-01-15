import { LightningElement, track } from 'lwc';
import getOrsEducationUniqueList from "@salesforce/apex/NWQREducationReportController.fetchOrsEducationRecords";
import { loadScript } from "lightning/platformResourceLoader";
import workbook from "@salesforce/resourceUrl/ConvertToExcel";
import { ShowToastEvent } from "lightning/platformShowToastEvent";

export default class HudOrsEducationReport extends LightningElement {
  librariesLoaded = false;
  @track btndisable = true;
  @track isLoading = false;
  @track qtrStartdate;
  @track qtrEnddate;
  @track error;
  @track attendeeList;
  @track exportList = [];
  @track columns = [
    {
      label: "Client ID",
      fieldName: "Client_ID",
      type: "text",
      sortable: false,
      hideDefaultActions: true,
      initialWidth: 100
    },
    {
      label: "Age",
      fieldName: "Age",
      type: "number",
      sortable: false,
      hideDefaultActions: true,
      initialWidth: 20
    },
    {
      label: "Gender",
      fieldName: "Gender",
      type: "text",
      sortable: false,
      hideDefaultActions: true,
      initialWidth: 60
    },
    {
      label: "Race",
      fieldName: "Race",
      type: "text",
      sortable: false,
      hideDefaultActions: true,
      initialWidth: 250
    },
    {
      label: "Ethnicity",
      fieldName: "Ethnicity",
      type: "text",
      sortable: false,
      hideDefaultActions: true,
      initialWidth: 250
    },
    {
      label: "Disabled",
      fieldName: "Disability",
      type: "text",
      sortable: false,
      hideDefaultActions: true,
      initialWidth: 30
    },
    {
      label: "Household Type",
      fieldName: "Household_Type",
      type: "text",
      sortable: false,
      hideDefaultActions: true,
      initialWidth: 250
    },
    {
      label: "Household Size",
      fieldName: "Household_Size",
      type: "number",
      sortable: false,
      hideDefaultActions: true,
      initialWidth: 20
    },
    {
      label: "Household Monthly Income",
      fieldName: "Monthly_Household_Income",
      type: "currency",
      typeAttributes: {
        currencyCode: { fieldName: "CurrencyIsoCode" },
        currencyDisplayAs: "code"
      },
      sortable: false,
      hideDefaultActions: true,
      initialWidth: 100
    },
    {
      label: "Household Income Band",
      fieldName: "Household_Income_Band",
      type: "text",
      sortable: false,
      hideDefaultActions: true,
      initialWidth: 70
    },
    {
      label: "Preferred Language",
      fieldName: "Primary_Language_Spoken",
      type: "text",
      sortable: false,
      hideDefaultActions: true,
      initialWidth: 100
    },
    {
      label: "Street Address",
      fieldName: "House_Number_and_Street_Name",
      type: "text",
      sortable: false,
      hideDefaultActions: true,
      initialWidth: 70
    },
    {
      label: "Address Line 2",
      fieldName: "Apartment_or_Unit_Number",
      type: "text",
      sortable: false,
      hideDefaultActions: true,
      initialWidth: 50
    },
    {
      label: "City",
      fieldName: "City",
      type: "text",
      sortable: false,
      hideDefaultActions: true,
      initialWidth: 70
    },
    {
      label: "Province/State",
      fieldName: "State",
      type: "text",
      sortable: false,
      hideDefaultActions: true,
      initialWidth: 70
    },
    {
      label: "Zip/Postal Code",
      fieldName: "Zip_Code",
      type: "text",
      sortable: false,
      hideDefaultActions: true,
      initialWidth: 50
    },
    {
      label: "Rural Area Status",
      fieldName: "Rural_Area_Status",
      type: "text",
      sortable: false,
      hideDefaultActions: true,
      initialWidth: 100
    },
    {
      label: "Group Education Completed",
      fieldName: "Group_Education_Service_Completed",
      type: "text",
      sortable: false,
      hideDefaultActions: true,
      initialWidth: 300
    },
    {
      label: "Course Completion Date",
      fieldName: "Series_End_date",
      type: "text",
      sortable: false,
      hideDefaultActions: true,
      initialWidth: 300
    }
  ];
  @track schemaObj = [
    {
      column: "Client ID",
      type: String,
      value: (ors) => ors.Client_ID
    },
    {
      column: "Age",
      type: Number,
      value: (ors) => ors.Age
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
      column: "Disabled",
      type: String,
      value: (ors) => ors.Disability
    },
    {
      column: "Household Type",
      type: String,
      value: (ors) => ors.Household_Type
    },
    {
      column: "Household Size",
      type: Number,
      value: (ors) => ors.Household_Size
    },
    {
      column: "Household Monthly Income",
      type: Number,
      format: "#,##0.00",
      value: (ors) => ors.Monthly_Household_Income
    },
    {
      column: "Household Income Band",
      type: String,
      value: (ors) => ors.Household_Income_Band
    },
    {
      column: "Preferred Language",
      type: String,
      value: (ors) => ors.Primary_Language_Spoken
    },
    {
      column: "Street Address",
      type: String,
      value: (ors) => ors.House_Number_and_Street_Name
    },
    {
      column: "Address Line 2",
      type: String,
      value: (ors) => ors.Apartment_or_Unit_Number
    },
    {
      column: "City",
      type: String,
      value: (ors) => ors.City
    },
    {
      column: "Province/State",
      type: String,
      value: (ors) => ors.State
    },
    {
      column: "Zip/Postal Code",
      type: String,
      value: (ors) => ors.Zip_Code
    },
    {
      column: "Rural Area Status",
      type: String,
      value: (ors) => ors.Rural_Area_Status
    },
    {
      column: "Group Education Completed",
      type: String,
      value: (ors) => ors.Group_Education_Service_Completed
    },
    {
      column: "Course Completion Date",
      type: String,
      //format: "mm/dd/yyyy",
      value: (ors) => ors.Series_End_date
    }
  ];

  renderedCallback() {
    if (!this.btndisable) return;
    this.btndisable = true;

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

  handledqtrStartDate(event) {
    this.qtrStartdate = event.target.value;
    if (this.qtrStartdate) {
      if (this.qtrStartdate && this.qtrEnddate) {
        this.btndisable = false;
      }
    } else {
      this.attendeeList = null;
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
      this.attendeeList = null;
      this.btndisable = true;
    }
  }

  refreshData(event) {
    this.isLoading = true;
    getOrsEducationUniqueList({qtrStartDate: this.qtrStartdate, qtrEndDate: this.qtrEnddate}).then((result) => {
      this.attendeeList = result;
      this.isLoading = false;
    }).catch((error) => {
      this.isLoading = false;
      const event = new ShowToastEvent({
        title: "Error",
        message: JSON.stringify(error),
        variant: "error"
      });
      this.dispatchEvent(event);
    });
  }

  async exporttoExcel() {
    let _self = this;
    getOrsEducationUniqueList({qtrStartDate: this.qtrStartdate, qtrEndDate: this.qtrEnddate}).then((result) => {
      writeXlsxFile(result, {
        schema: _self.schemaObj,
        fileName: "NWQR Education.xlsx"
      });
    }).catch((error) => {
      console.log('error = '+error);
      const event = new ShowToastEvent({
        title: "Error",
        message: "Please Contact System Admin",
        variant: "error"
      });
      this.dispatchEvent(event);
    });
  }

}