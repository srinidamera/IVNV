import { LightningElement, api, track } from "lwc";
import getOrsClientsUniqueList from "@salesforce/apex/NWQRClientsReportController.getOrsClientsUniqueList";
import { loadStyle, loadScript } from "lightning/platformResourceLoader";
import workbook from "@salesforce/resourceUrl/ConvertToExcel";
import cssFile from '@salesforce/resourceUrl/sldsBoxCssFile';
import { ShowToastEvent } from "lightning/platformShowToastEvent";
var activetab='Clients Validation';

export default class NwqrClientsReport extends LightningElement {
    tabContent = '';
    
    handleActive(event) {
        activetab = event.target.label;   
        console.log('tab=='+activetab);
    }

  librariesLoaded = false;
  btndisable = true;
  @track isLoading = false;
  @track qtrStartdate;
  @track qtrEnddate;

  @track schemaObj = [
    {
        column: "Client ID",
        type: String,
        value: (ors) => ors.Client_ID
    },
    {
        column: "Privacy Notice Opt Out",
        type: String,
        value: (ors) => ors.Privacy_Notice_Opt_Out
    },
    {
        column: "NWO Role",
        type: String,
        value: (ors) => ors.NWO_Role
    },
    {
        column: "Services Provided to Existing Home Owner",
        type: String,
        value: (ors) => ors.Services_Provided_to_Existing_Home_Owner
    },
    {
        column: "NWO Provided Lending Services",
        type: String,
        value: (ors) => ors.NWO_Provided_Lending_Services
    },
    {
        column: "NWO Provided Counseling Education",
        type: String,
        value: (ors) => ors.NWO_Provided_Counseling_Education
    },
    {
        column: "Formal Partnering Org Provided Service",
        type: String,
        value: (ors) => ors.Formal_Partnering_Org_Provided_Service
    },
    {
        column: "Service Provided by Formal Partner Org",
        type: String,
        value: (ors) => ors.Service_Provided_by_Formal_Partner_Org
    },
    {
        column: "PCode of Partner Org",
        type: String,
        value: (ors) => ors.PCode_of_Partner_Org
    },
    {
        column: "Provide Real Estate Agent Services",
        type: String,
        value: (ors) => ors.Provide_Real_Estate_Agent_Services
    },
    {
        column: "Homeowner Svcs - Disaster/Health Crisis?",
        type: String,
        value: (ors) => ors.RehaborReplacementNat
    },
    {
        column: "Last Name ",
        type: String,
        value: (ors) => ors.Last_Name
    },
    {
        column: "First Name ",
        type: String,
        value: (ors) => ors.First_Name
    },
    {
        column: "Middle Name ",
        type: String,
        value: (ors) => ors.Middle_Name
    },
    {
        column: "Age ",
        type: String,
        value: (ors) => ors.Age
    },
    {
        column: "Gender ",
        type: String,
        value: (ors) => ors.Gender
    },
    {
        column: "Race ",
        type: String,
        value: (ors) => ors.Race
    },
    {
        column: "Ethnicity Latino ",
        type: String,
        value: (ors) => ors.Ethnicity_Latino
    },
    {
        column: "1st Time Buyer ",
        type: String,
        value: (ors) => ors.X1st_Time_Buyer
    },
    {
        column: "Veteran ",
        type: String,
        value: (ors) => ors.Veteran
    },
    {
        column: "Active Military ",
        type: String,
        value: (ors) => ors.Active_Military
    },
    {
        column: "Household Family Size ",
        type: String,
        value: (ors) => ors.Household_Family_Size
    },
    {
        column: "Household Annual Family Income ",
        type: Number,
        format: "#,##0.00",
        value: (ors) => ors.Household_Annual_Family_Income
    },
    {
        column: "Household Income Band ",
        type: String,
        value: (ors) => ors.Household_Income_Band
    },
    {
        column: "Intake Date ",
        type: Date,
        format: "mm/dd/yyyy",
        value: (ors) => ors.Intake_Date
    },
    {
        column: "HBE Provided by Other ",
        type: String,
        value: (ors) => ors.HBE_Provided_by_Other_Agency
    },
    {
        column: "Individual Counseling Hours by Org ",
        type: String,
        value: (ors) => ors.Individual_Counseling_Hours_by_Org
    },
    {
        column: "Group Ed total Hours In Person ",
        type: String,
        value: (ors) => ors.Group_Ed_total_Hours_In_Person
    },
    {
        column: "Group Ed Total Hours Online ",
        type: String,
        value: (ors) => ors.Group_Ed_Total_Hours_Online
    },
    {
        column: "Other Org Group Counseling Hours ",
        type: String,
        value: (ors) => ors.Other_Org_Group_Counseling_Hours
    },
    {
        column: "First Credit Score ",
        type: String,
        value: (ors) => ors.First_Credit_Score
    },
    {
        column: "Address ",
        type: String,
        value: (ors) => ors.Address
    },
    {
        column: "Street Name ",
        type: String,
        value: (ors) => ors.Street_Name
    },
    {
        column: "Unit ",
        type: String,
        value: (ors) => ors.Unit
    },
    {
        column: "City ",
        type: String,
        value: (ors) => ors.City
    },
    {
        column: "State ",
        type: String,
        value: (ors) => ors.State
    },
    {
        column: "Zip ",
        type: String,
        value: (ors) => ors.Zip
    },
    {
        column: "# of_Units ",
        type: String,
        value: (ors) => ors.of_Units
    },
    {
        column: "Foreclosure Counseling Outcome ",
        type: String,
        value: (ors) => ors.Foreclosure_Counseling_Outcome
    },    
  
    {
        column: "Primary Cost",
        type: Number,
        format: "#,##0.00",
        value: (ors) => ors.Primary_Cost
    },    
    {
        column: "Rehab Cost",
        type: Number,
        format: "#,##0.00",
        value: (ors) => ors.Rehab_Cost
    },
    {
        column: "Closing cost",
        type: Number,
        format: "#,##0.00",
        value: (ors) => ors.Closing_cost
    },
    {
        column: "Other Cost",
        type: Number,
        format: "#,##0.00",
        value: (ors) => ors.Other_Cost
    },
    {
        column: "Mortgage Insurance Type ",
        type: String,
        value: (ors) => ors.Mortgage_Insurance_Type
    }, 

    {
        column: "Monthly mortgage insurance amount",
        type: Number,
        format: "#,##0.00",
        value: (ors) => ors.Monthly_mortgage_insurance_amount
    },
    {
        column: "Total Monthly Payment",
        type: Number,
        format: "#,##0.00",
        value: (ors) => ors.Total_Monthly_Payment
    },
    {
        column: "Settlement Date",
        type: String,
        value: (ors) => ors.Settlement_Date
    }
  ];

  @track schemaObjNew = [
    {
        column: "Client ID",
        type: String,
        value: (ors) => ors.Client_ID
    },
    {
        column: "Privacy Notice Opt Out",
        type: String,
        value: (ors) => ors.Privacy_Notice_Opt_Out
    },
    {
        column: "NWO Role",
        type: String,
        value: (ors) => ors.NWO_Role
    },
    {
        column: "Services Provided to Existing Home Owner",
        type: String,
        value: (ors) => ors.Services_Provided_to_Existing_Home_Owner
    },
    {
        column: "NWO Provided Lending Services (Underwriting, Origination, Brokering or Packaging)",
        type: String,
        value: (ors) => ors.NWO_Provided_Lending_Services
    },
    {
        column: "NWO Provided Counseling/Education",
        type: String,
        value: (ors) => ors.NWO_Provided_Counseling_Education
    },
    {
        column: "Did a formal partnering organization provide counseling/education and/or lending services?",
        type: String,
        value: (ors) => ors.Formal_Partnering_Org_Provided_Service
    },
    {
        column: "Type of service provided by a formal partnering organization",
        type: String,
        value: (ors) => ors.Service_Provided_by_Formal_Partner_Org
    },
    {
        column: "PCODE of the Other NeighborWorks Network Organization (NWO) or Approved Partner that assisted this client (see help text for the list of PCODEs). ",
        type: String,
        value: (ors) => ors.PCode_of_Partner_Org
    },
    {
        column: "Did your organization provide Real Estate Agent Services (listing agent and/or buyer's agent)?",
        type: String,
        value: (ors) => ors.Provide_Real_Estate_Agent_Services
    },
    {
        column: "Was this service provided in direct response to a public health crisis or a natural disaster, or to increase or improve climate resilience? ",
        type: String,
        value: (ors) => ors.RehaborReplacementNat
    },
    {
        column: "Client Last ",
        type: String,
        value: (ors) => ors.Last_Name
    },
    {
        column: "Client First ",
        type: String,
        value: (ors) => ors.First_Name
    },
    {
        column: "Client Middle ",
        type: String,
        value: (ors) => ors.Middle_Name
    },
    {
        column: "Age ",
        type: String,
        value: (ors) => ors.Age
    },
    {
        column: "Gender ",
        type: String,
        value: (ors) => ors.Gender
    },
    {
        column: "Race ",
        type: String,
        value: (ors) => ors.Race
    },
    {
        column: "Ethnicity:Latino ",
        type: String,
        value: (ors) => ors.Ethnicity_Latino
    },
    {
        column: "1st-Time Buyer ",
        type: String,
        value: (ors) => ors.X1st_Time_Buyer
    },
    {
        column: "Veteran ",
        type: String,
        value: (ors) => ors.Veteran
    },
    {
        column: "Active Military ",
        type: String,
        value: (ors) => ors.Active_Military
    },
    {
        column: "Head of Household Type ",
        type: String,
        value: (ors) => ors.Head_Of_Household_Type
    },
    {
        column: "Household Family Size ",
        type: String,
        value: (ors) => ors.Household_Family_Size
    },
    {
        column: "Household Annual Family Income ",
        type: Number,
        format: "#,##0.00",
        value: (ors) => ors.Household_Annual_Family_Income
    },
    {
        column: "Household Income Band ",
        type: String,
        value: (ors) => ors.Household_Income_Band
    },
    {
        column: "Intake Date ",
        type: Date,
        format: "mm/dd/yyyy",
        value: (ors) => ors.Intake_Date
    },
    {
        column: "If the client received a Homebuyer Education certificate of completion from another organization prior to engaging in pre-purchase services with your organization, please enter the certification date. ",
        //type: String,
        //format: "mm/dd/yyyy",
        type: Date,
        format: "mm/dd/yyyy",
        value: (ors) => ors.HBE_Provided_by_Other_Agency_Date
    },
    {
        column: "Individual Counseling Hours Provided by your Organization ",
        type: String,
        value: (ors) => ors.Individual_Counseling_Hours_by_Org
    },
    {
        column: "Group Education Hours Provided Online by your Organization ",
        type: String,
        value: (ors) => ors.Group_Ed_total_Hours_In_Person
    },
    {
        column: "Group Education Hours Provided by your Organization in person via a classroom setting ",
        type: String,
        value: (ors) => ors.Group_Ed_Total_Hours_Online
    },
    {
        column: "Total number of Individual Counseling Hours and Group Education Hours (combined) provided by the Other Organization ",
        type: String,
        value: (ors) => ors.Other_Org_Group_Counseling_Hours
    },
    {
        column: "First Credit Score ",
        type: String,
        value: (ors) => ors.First_Credit_Score
    },
    {
        column: "Address # ",
        type: String,
        value: (ors) => ors.Address
    },
    {
        column: "Street Name ",
        type: String,
        value: (ors) => ors.Street_Name
    },
    {
        column: "Apt # ",
        type: String,
        value: (ors) => ors.Unit
    },
    {
        column: "City ",
        type: String,
        value: (ors) => ors.City
    },
    {
        column: "State ",
        type: String,
        value: (ors) => ors.State
    },
    {
        column: "Zip ",
        type: String,
        value: (ors) => ors.Zip
    },
    {
        column: "# Units ",
        type: String,
        value: (ors) => ors.of_Units
    },
    {
        column: "Foreclosure Counseling Outcome/Resolution ",
        type: String,
        value: (ors) => ors.Foreclosure_Counseling_Outcome
    },    
  
    {
        column: "Primary Cost",
        type: Number,
        format: "#,##0.00",
        value: (ors) => ors.Primary_Cost
    },    
    {
        column: "Rehab Cost",
        type: Number,
        format: "#,##0.00",
        value: (ors) => ors.Rehab_Cost
    },
    {
        column: "Closing cost",
        type: Number,
        format: "#,##0.00",
        value: (ors) => ors.Closing_cost
    },
    {
        column: "Other Cost",
        type: Number,
        format: "#,##0.00",
        value: (ors) => ors.Other_Cost
    },
    {
        column: "Mortgage Insurance Type ",
        type: String,
        value: (ors) => ors.Mortgage_Insurance_Type
    }, 

    {
        column: "Monthly mortgage insurance amount",
        type: Number,
        format: "#,##0.00",
        value: (ors) => ors.Monthly_mortgage_insurance_amount
    },
    {
        column: "Total Monthly Payment",
        type: Number,
        format: "#,##0.00",
        value: (ors) => ors.Total_Monthly_Payment
    },
    {
        column: "Settlement Date",
        type: String,
        value: (ors) => ors.Settlement_Date
    }
  ];

  @track columns2 = [  
    {
        label: "In Download?",
        fieldName: "In_Download",
        type: "text",
        sortable: false,
        hideDefaultActions: true,
        initialWidth: 100
    },
    {
        label: "Client Case Name",
        fieldName: "ORS_Clients_Financing",
        type: "url",
        typeAttributes: { label: { fieldName: 'ORS_Name' }, target: '_blank'},
        sortable: false,
        hideDefaultActions: true,
        initialWidth: 200
    },
    {
        label: "Total Costs Match",
        fieldName: "Total_Costs_Match",
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
        label: "Age Check",
        fieldName: "Age_Check",
        cellAttributes: {
            class: {
                fieldName: 'format2'
            }
        },
        hideDefaultActions: true,
        initialWidth: 200
    },
    {
        label: "Household Income Band Missing",
        fieldName: "Household_Income_Band_Missing",
        cellAttributes: {
            class: {
                fieldName: 'format3'
            }
        },
        type: "text",
        sortable: false,
        hideDefaultActions: true,
        initialWidth: 200
    },
    {
        label: "Property Check",
        fieldName: "Property_Check",
        cellAttributes: {
            class: {
                fieldName: 'format4'
            }
        },
        type: "text",
        sortable: false,
        hideDefaultActions: true,
        initialWidth: 200
    },
    {
        label: "New Homeowner Counseling Provided",
        fieldName: "New_Homeowner_Counseling_Provided",
        cellAttributes: {
            class: {
                fieldName: 'format5'
            }
        },
        type: "text",
        sortable: false,
        hideDefaultActions: true,
        initialWidth: 200
    },
    {
        label: "Date HBE Provided Check",
        fieldName: "Date_HBE_Provided_Check",
        cellAttributes: {
            class: {
                fieldName: 'format6'
            }
        },
        type: "text",
        sortable: false,
        hideDefaultActions: true,
        initialWidth: 200
    },    
    {
        label: "Date HBE Provided by Other",
        fieldName: "HBE_Provided_by_Other_Agency_Date",   
        type: "date",
        typeAttributes: {month: "2-digit",day: "2-digit",year: "numeric"},
        sortable: false,
        hideDefaultActions: true,
        initialWidth: 200
    },
    {
        label: "Client ID",
        fieldName: "ClientID",
        type: "url",
        typeAttributes: { label: { fieldName: 'Client_ID' }, target: '_blank'},
        sortable: false,
        hideDefaultActions: true,
        cellAttributes: {
            class: {
                fieldName: 'ClientIDformat'
            }
        },
        initialWidth: 100
    },
    {
        label: "Privacy Notice Opt Out",
        fieldName: "Privacy_Notice_Opt_Out",
        type: "text",
        sortable: false,
        hideDefaultActions: true,
        cellAttributes: {
            class: {
                fieldName: 'Privacy_Notice_Opt_Outformat'
            }
        },
        initialWidth: 100
    }, 
    {
        label: "NWO Role",
        fieldName: "NWO_Role",
        type: "text",
        sortable: false,
        hideDefaultActions: true,
        cellAttributes: {
            class: {
                fieldName: 'NWO_Roleformat'
            }
        },
        initialWidth: 200
    },
    {
        label: "Services Provided to Existing Home Owner",
        fieldName: "Services_Provided_to_Existing_Home_Owner",
        type: "text",
        sortable: false,
        cellAttributes: {
            class: {
                fieldName: 'Services_Provided_to_Existing_Home_Ownerformat'
            }
        },
        hideDefaultActions: true,
        initialWidth: 200
    },
    {
        label: "NWO Provided Lending Services (Underwriting, Origination, Brokering or Packaging)",
        fieldName: "NWO_Provided_Lending_Services",
        type: "text",
        sortable: false,
        cellAttributes: {
            class: {
                fieldName: 'NWO_Provided_Lending_Servicesformat'
            }
        },
        hideDefaultActions: true,
        initialWidth: 200
    },
    {
        label: "NWO Provided Counseling/Education",
        fieldName: "NWO_Provided_Counseling_Education",
        type: "text",
        sortable: false,
        cellAttributes: {
            class: {
                fieldName: 'NWO_Provided_Counseling_Educationformat'
            }
        },
        hideDefaultActions: true,
        initialWidth: 200
    },
    {
        label: "Did a formal partnering organization provide counseling/education and/or lending services?",
        fieldName: "Formal_Partnering_Org_Provided_Service",
        type: "text",
        sortable: false,
        cellAttributes: {
            class: {
                fieldName: 'Formal_Partnering_Org_Provided_Serviceformat'
            }
        },
        hideDefaultActions: true,
        initialWidth: 200
    },
    {
        label: "Type of service provided by a formal partnering organization",
        fieldName: "Service_Provided_by_Formal_Partner_Org",
        type: "text",
        sortable: false,
        hideDefaultActions: true,
        initialWidth: 200
    },
    {
        label: "PCODE of the Other NeighborWorks Network Organization (NWO) or Approved Partner that assisted this client (see help text for the list of PCODEs). ",
        fieldName: "PCode_of_Partner_Org",
        type: "text",
        sortable: false,
        hideDefaultActions: true,
        initialWidth: 200
    },
    {
        label: "Did your organization provide Real Estate Agent Services (listing agent and/or buyer's agent)?",
        fieldName: "Provide_Real_Estate_Agent_Services",
        type: "text",
        sortable: false,
        cellAttributes: {
            class: {
                fieldName: 'Provide_Real_Estate_Agent_Servicesformat'
            }
        },
        hideDefaultActions: true,
        initialWidth: 200
    },
    {
        label: "Was this service provided in direct response to a public health crisis or a natural disaster, or to increase or improve climate resilience? ",
        fieldName: "RehaborReplacementNat",
        cellAttributes: {
            class: {
                fieldName: 'format8'
            }
        },
        type: "text",
        sortable: false,
        hideDefaultActions: true,
        initialWidth: 200
    },
    {
        label: "Client Last",
        fieldName: "Last_Name",
        type: "text",
        sortable: false,
        cellAttributes: {
            class: {
                fieldName: 'Last_Nameformat'
            }
        },
        hideDefaultActions: true,
        initialWidth: 200
    },
    {
        label: "Client First",
        fieldName: "First_Name",
        type: "text",
        sortable: false,
        cellAttributes: {
            class: {
                fieldName: 'First_Nameformat'
            }
        },
        hideDefaultActions: true,
        initialWidth: 200
    },
    {
        label: "Client Middle",
        fieldName: "Middle_Name",
        type: "text",
        sortable: false,
        hideDefaultActions: true,
        initialWidth: 200
    },
    {
        label: "Age",
        fieldName: "Age",
        type: "text",
        sortable: false,
        cellAttributes: {
            class: {
                fieldName: 'Ageformat'
            }
        },
        hideDefaultActions: true,
        initialWidth: 200
    },
    {
        label: "Gender",
        fieldName: "Gender",
        type: "text",
        sortable: false,
        cellAttributes: {
            class: {
                fieldName: 'Genderformat'
            }
        },
        hideDefaultActions: true,
        initialWidth: 200
    },
    {
        label: "Race",
        fieldName: "Race",
        type: "text",
        sortable: false,
        cellAttributes: {
            class: {
                fieldName: 'Raceformat'
            }
        },
        hideDefaultActions: true,
        initialWidth: 200
    },
    {
        label: "Ethnicity:Latino",
        fieldName: "Ethnicity_Latino",
        type: "text",
        sortable: false,
        cellAttributes: {
            class: {
                fieldName: 'Ethnicity_Latinoformat'
            }
        },
        hideDefaultActions: true,
        initialWidth: 200
    },
    {
        label: "1st-Time Buyer",
        fieldName: "X1st_Time_Buyer",
        type: "text",
        sortable: false,
        cellAttributes: {
            class: {
                fieldName: 'X1st_Time_Buyerformat'
            }
        },
        hideDefaultActions: true,
        initialWidth: 200
    },
    {
        label: "Veteran",
        fieldName: "Veteran",
        type: "text",
        sortable: false,
        cellAttributes: {
            class: {
                fieldName: 'Veteranformat'
            }
        },
        hideDefaultActions: true,
        initialWidth: 200
    },
    {
        label: "Active Military",
        fieldName: "Active_Military",
        type: "text",
        sortable: false,
        cellAttributes: {
            class: {
                fieldName: 'Active_Militaryformat'
            }
        },
        hideDefaultActions: true,
        initialWidth: 200
    },
	{
        label: "Head of Household Type",
        fieldName: "Head_Of_Household_Type",
        cellAttributes: {
            class: {
                fieldName: 'format7'
            }
        },
        type: "text",
        sortable: false,
        hideDefaultActions: true,
        initialWidth: 200
    },
    {
        label: "Household Family Size",
        fieldName: "Household_Family_Size",
        type: "text",
        sortable: false,
        cellAttributes: {
            class: {
                fieldName: 'Household_Family_Sizeformat'
            }
        },
        hideDefaultActions: true,
        initialWidth: 200
    },
    {
        label: "Household Annual Family Income",
        fieldName: "Household_Annual_Family_Income",
        type: "currency",
        typeAttributes: {
            currencyCode: { fieldName: "CurrencyIsoCode" },
            currencyDisplayAs: "symbol"
        },
        cellAttributes: {
            class: {
                fieldName: 'Household_Annual_Family_Incomeformat'
            }
        },
        sortable: false,
        hideDefaultActions: true,
        initialWidth: 200
    },
    {
        label: "Household Income Band",
        fieldName: "Household_Income_Band",
        type: "text",
        sortable: false,
        cellAttributes: {
            class: {
                fieldName: 'Household_Income_Bandformat'
            }
        },
        hideDefaultActions: true,
        initialWidth: 200
    },
    {
        label: "Intake Date",
        fieldName: "Intake_Date",
        type: "date",
        cellAttributes: {
            class: {
                fieldName: 'Intake_Dateformat'
            }
        },
        typeAttributes: {month: "2-digit",day: "2-digit",year: "numeric"},
        sortable: false,
        hideDefaultActions: true,
        initialWidth: 200
    },
    {
        label: "If the client received a Homebuyer Education certificate of completion from another organization prior to engaging in pre-purchase services with your organization, please enter the certification date. ",
        fieldName: "HBE_Provided_by_Other_Agency_Date",
        type: "date",
        typeAttributes: {month: "2-digit",day: "2-digit",year: "numeric"},
        sortable: false,
        hideDefaultActions: true,
        initialWidth: 200
    },
    {
        label: "Individual Counseling Hours Provided by your Organization",
        fieldName: "Individual_Counseling_Hours_by_Org",
        type: "text",
        sortable: false,
        cellAttributes: {
            class: {
                fieldName: 'Individual_Counseling_Hours_by_Orgformat'
            }
        },
        hideDefaultActions: true,
        initialWidth: 200
    },
    {
        label: "Group Education Hours Provided Online by your Organization",
        fieldName: "Group_Ed_total_Hours_In_Person",
        type: "text",
        sortable: false,
        hideDefaultActions: true,
        cellAttributes: {
            class: {
                fieldName: 'Group_Ed_total_Hours_In_Personformat'
            }
        },
        initialWidth: 200
    },
    {
        label: "Group Education Hours Provided by your Organization in person via a classroom setting",
        fieldName: "Group_Ed_Total_Hours_Online",
        type: "text",
        sortable: false,
        cellAttributes: {
            class: {
                fieldName: 'Group_Ed_Total_Hours_Onlineformat'
            }
        },
        hideDefaultActions: true,
        initialWidth: 200
    },
    {
        label: "Total number of Individual Counseling Hours and Group Education Hours (combined) provided by the Other Organization",
        fieldName: "Other_Org_Group_Counseling_Hours",
        type: "text",
        sortable: false,
        hideDefaultActions: true,
        initialWidth: 200
    },
    {
        label: "First Credit Score",
        fieldName: "First_Credit_Score",
        type: "text",
        sortable: false,
        cellAttributes: {
            class: {
                fieldName: 'First_Credit_Scoreformat'
            }
        },
        hideDefaultActions: true,
        initialWidth: 200
    },
    {
        label: "Address #",
        fieldName: "Address",
        type: "text",
        sortable: false,
        cellAttributes: {
            class: {
                fieldName: 'Addressformat'
            }
        },
        hideDefaultActions: true,
        initialWidth: 200
    },
    {
        label: "Street Name",
        fieldName: "Street_Name",
        type: "text",
        sortable: false,
        cellAttributes: {
            class: {
                fieldName: 'Street_Nameformat'
            }
        },
        hideDefaultActions: true,
        initialWidth: 200
    },
    {
        label: "Apt #",
        fieldName: "Unit",
        type: "text",
        sortable: false,
        hideDefaultActions: true,
        initialWidth: 200
    },
    {
        label: "City",
        fieldName: "City",
        type: "text",
        sortable: false,
        cellAttributes: {
            class: {
                fieldName: 'Cityformat'
            }
        },
        hideDefaultActions: true,
        initialWidth: 200
    },
    {
        label: "State",
        fieldName: "State",
        type: "text",
        sortable: false,
        cellAttributes: {
            class: {
                fieldName: 'Stateformat'
            }
        },
        hideDefaultActions: true,
        initialWidth: 200
    },
    {
        label: "Zip",
        fieldName: "Zip",
        type: "text",
        sortable: false,
        cellAttributes: {
            class: {
                fieldName: 'Zipformat'
            }
        },
        hideDefaultActions: true,
        initialWidth: 200
    },
    {
        label: "# Units",
        fieldName: "of_Units",
        type: "text",
        sortable: false,
        cellAttributes: {
            class: {
                fieldName: 'of_Unitsformat'
            }
        },
        hideDefaultActions: true,
        initialWidth: 200
    },
    {
        label: "Foreclosure Counseling Outcome/Resolution",
        fieldName: "Foreclosure_Counseling_Outcome",
        type: "text",
        sortable: false,
        hideDefaultActions: true,
        initialWidth: 200
    },
   
    {
        label: "Primary Cost",
        fieldName: "Primary_Cost",
        type: "currency",
        cellAttributes: {
            class: {
                fieldName: 'primaryCost'
            }
        },
        typeAttributes: {
            currencyCode: { fieldName: "CurrencyIsoCode" },
            currencyDisplayAs: "symbol"
        }    
    },
    {
        label: "Rehab Cost",
        fieldName: "Rehab_Cost",
        type: "currency",
        cellAttributes: {
            class: {
                fieldName: 'rehabCost'
            }
        },
        typeAttributes: {
            currencyCode: { fieldName: "CurrencyIsoCode" },
            currencyDisplayAs: "symbol"
        }
    },    
    {
        label: "Closing cost",
        fieldName: "Closing_cost",
        type: "currency",
        cellAttributes: {
            class: {
                fieldName: 'closingCost'
            }
        },
        typeAttributes: {
          currencyCode: { fieldName: "CurrencyIsoCode" },
          currencyDisplayAs: "symbol"
        }  
    },
    {
        label: "Other Cost",
        fieldName: "Other_Cost",
        type: "currency",
        cellAttributes: {
            class: {
                fieldName: 'otherCost'
            }
        },
        typeAttributes: {
          currencyCode: { fieldName: "CurrencyIsoCode" },
          currencyDisplayAs: "symbol"
        }  
    },
    {
        label: "Mortgage Insurance Type",
        fieldName: "Mortgage_Insurance_Type",
        type: "text",
        cellAttributes: {
            class: {
                fieldName: 'mortgageInsuranceType'
            }
        },
        sortable: false,
        hideDefaultActions: true,
        initialWidth: 200
    },

    {
        label: "Monthly mortgage insurance amount",
        fieldName: "Monthly_mortgage_insurance_amount",
        type: "currency",
        cellAttributes: {
            class: {
                fieldName: 'Monthly_mortgage_insurance_amount_format'
            }
        },
        typeAttributes: {
          currencyCode: { fieldName: "CurrencyIsoCode" },
          currencyDisplayAs: "symbol"
        }  
    },
    {
        label: "Total Monthly Payment ",
        fieldName: "Total_Monthly_Payment",
        type: "currency",
        cellAttributes: {
            class: {
                fieldName: 'Total_Monthly_Payment_format'
            }
        },
        typeAttributes: {
          currencyCode: { fieldName: "CurrencyIsoCode" },
          currencyDisplayAs: "symbol"
        }  
    },
    {
        label: "Settlement Date",
        fieldName: "Settlement_Date",
        type: "text",
        sortable: false,
        hideDefaultActions: true,
        initialWidth: 200  
    }
  ];

  get validationColumns(){
      return this.columns2;
  }

  get excelExportColumns(){
      return this.qtrEnddate < '2023-10-01' ? this.schemaObj : this.schemaObjNew;
  }

  get validationData(){
      return this.qtrEnddate < '2023-10-01' ? this.bookingListClientExport : this.bookingList
  }
  
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
  @track bookingListClientExport;
  @track exportList = [];
  simpleMap = [];
  missingCSS = 'slds-box';

refreshData(event) {
    console.log("==",this.qtrStartdate);
    console.log(this.qtrEnddate);
    this.isLoading = true;
    getOrsClientsUniqueList({
      qtrStartDate: this.qtrStartdate,
      qtrEndDate: this.qtrEnddate
    })
    .then((result) => {
        for(let key in result) {
            console.log("result", result);
            if(key=='Validation'){
                console.log("result", result);
                //this.bookingList = result[key];
                var listrecords=[];
                var listrecords1=[];
                var listrecordsClientExport=[];
                listrecords=result[key];
                this.isLoading = false;
                listrecords.forEach( ( record ) => {
                    let tempRec = Object.assign( {}, record );
                    record.ORS_Clients_Financing='/' +record.recordid;
                    record.ClientID='/' +record.recordid;
                    var string1 = record.Total_Costs_Match;
                    var string2 = record.Age_Check; 
                    var string3 = record.Household_Income_Band_Missing; 
                    var string4 = record.Property_Check; 
                    var string5 = record.New_Homeowner_Counseling_Provided; 
                    var string6 = record.Date_HBE_Provided_Check; 
                    var string7 = record.Head_Of_Household_Type;
                    var string8 = record.RehaborReplacementNat;
                    if(string1 != undefined && string1.includes('Passed')) {               
                        record.format1 =  'slds-text-color_success';                        
                    }                    
                    else {
                        record.format1=  'slds-text-color_error';  
                    }
                    
                    if(string2.includes('Passed')) {               
                        record.format2 =  'slds-text-color_success';                        
                    }                    
                    else {
                        record.format2=  'slds-text-color_error';  
                    }

                    if(string3.includes('Passed')) {               
                        record.format3 =  'slds-text-color_success';                        
                    }                    
                    else {
                        record.format3=  'slds-text-color_error';  
                    }
                    
                    if (string4.includes('Passed')) {               
                        record.format4 =  'slds-text-color_success';                        
                    }                    
                    else {
                        record.format4=  'slds-text-color_error';  
                    }
                    
                    if (string5.includes('Passed')) {               
                        record.format5 =  'slds-text-color_success';                        
                    }                    
                    else {
                        record.format5=  'slds-text-color_error';  
                    }
                    
                    if (string6.includes('Passed')) {               
                        record.format6 =  'slds-text-color_success';                        
                    }                    
                    else {
                        record.format6=  'slds-text-color_error';  
                    }

                    if (string7.includes('Head of Household Type missing')) {
                        record.format7 =  'slds-text-color_error';
                    }
                    else {
                        record.format7 =  'slds-text-color_success';
                    }

                    if (string8.includes('No Response')) {
                        record.format8 =  'slds-text-color_error';
                    }
                    else {
                        record.format8 =  'slds-text-color_success';
                    }

                    if (!(record.ClientID && record.ClientID.toString().length && record.ClientID.toString().length > 0)) {
                        record.ClientIDformat = this.missingCSS;
                    }
                    if (!(record.Privacy_Notice_Opt_Out && record.Privacy_Notice_Opt_Out.toString().length && record.Privacy_Notice_Opt_Out.toString().length > 0)) {
                        record.Privacy_Notice_Opt_Outformat = this.missingCSS;
                    }
                    if (!(record.NWO_Role && record.NWO_Role.toString().length && record.NWO_Role.toString().length > 0)) {
                        record.NWO_Roleformat = this.missingCSS;
                    }
                    if (!(record.Services_Provided_to_Existing_Home_Owner && record.Services_Provided_to_Existing_Home_Owner.toString().length && record.Services_Provided_to_Existing_Home_Owner.toString().length > 0)) {
                        record.Services_Provided_to_Existing_Home_Ownerformat = this.missingCSS;
                    }
                    if (!(record.NWO_Provided_Lending_Services && record.NWO_Provided_Lending_Services.toString().length && record.NWO_Provided_Lending_Services.toString().length > 0)) {
                        record.NWO_Provided_Lending_Servicesformat = this.missingCSS;
                    }
                    if (!(record.NWO_Provided_Counseling_Education && record.NWO_Provided_Counseling_Education.toString().length && record.NWO_Provided_Counseling_Education.toString().length > 0)) {
                        record.NWO_Provided_Counseling_Educationformat = this.missingCSS;
                    }
                    if (!(record.Formal_Partnering_Org_Provided_Service && record.Formal_Partnering_Org_Provided_Service.toString().length && record.Formal_Partnering_Org_Provided_Service.toString().length > 0)) {
                        record.Formal_Partnering_Org_Provided_Serviceformat = this.missingCSS;
                    }
                    if (!(record.Provide_Real_Estate_Agent_Services && record.Provide_Real_Estate_Agent_Services.toString().length && record.Provide_Real_Estate_Agent_Services.toString().length > 0)) {
                        if(record.NWO_Role != 'NWO Provides Services to an Existing Home Owner' && record.NWO_Role != 'Foreclosure Mitigation Counseling'){
                            record.Provide_Real_Estate_Agent_Servicesformat = this.missingCSS;
                        }
                    }
                    if (!(record.Last_Name && record.Last_Name.toString().length && record.Last_Name.toString().length > 0)) {
                        record.Last_Nameformat = this.missingCSS;
                    }
                    if (!(record.First_Name && record.First_Name.toString().length && record.First_Name.toString().length > 0)) {
                        record.First_Nameformat = this.missingCSS;
                    }
                    if (!(record.Age && record.Age.toString().length && record.Age.toString().length > 0)) {
                        record.Ageformat = this.missingCSS;
                    }
                    if (!(record.Gender && record.Gender.toString().length && record.Gender.toString().length > 0)) {
                        record.Genderformat = this.missingCSS;
                    }
                    if (!(record.Race && record.Race.toString().length && record.Race.toString().length > 0)) {
                        record.Raceformat = this.missingCSS;
                    }
                    if (!(record.Ethnicity_Latino && record.Ethnicity_Latino.toString().length && record.Ethnicity_Latino.toString().length > 0)) {
                        record.Ethnicity_Latinoformat = this.missingCSS;
                    }
                    if (!(record.X1st_Time_Buyer && record.X1st_Time_Buyer.toString().length && record.X1st_Time_Buyer.toString().length > 0)) {
                        record.X1st_Time_Buyerformat = this.missingCSS;
                    }
                    if (!(record.Veteran && record.Veteran.toString().length && record.Veteran.toString().length > 0)) {
                        record.Veteranformat = this.missingCSS;
                    }
                    if (!(record.Active_Military && record.Active_Military.toString().length && record.Active_Military.toString().length > 0)) {
                        record.Active_Militaryformat = this.missingCSS;
                    }
                    if (!(record.Household_Family_Size && record.Household_Family_Size.toString().length && record.Household_Family_Size.toString().length > 0)) {
                        record.Household_Family_Sizeformat = this.missingCSS;
                    }
                    if (!(record.Household_Income_Band && record.Household_Income_Band.toString().length && record.Household_Income_Band.toString().length > 0)) {
                        record.Household_Income_Bandformat = this.missingCSS;
                    }
                    if (!(record.Intake_Date && record.Intake_Date.toString().length && record.Intake_Date.toString().length > 0)) {
                        record.Intake_Dateformat = this.missingCSS;
                    }
                    if (!(record.Individual_Counseling_Hours_by_Org && record.Individual_Counseling_Hours_by_Org.toString().length && record.Individual_Counseling_Hours_by_Org.toString().length > 0)) {
                        record.Individual_Counseling_Hours_by_Orgformat = this.missingCSS;
                    }
                    if (!(record.Group_Ed_total_Hours_In_Person && record.Group_Ed_total_Hours_In_Person.toString().length && record.Group_Ed_total_Hours_In_Person.toString().length > 0)) {
                        record.Group_Ed_total_Hours_In_Personformat = this.missingCSS;
                    }
                    if (!(record.Group_Ed_Total_Hours_Online && record.Group_Ed_Total_Hours_Online.toString().length && record.Group_Ed_Total_Hours_Online.toString().length > 0)) {
                        record.Group_Ed_Total_Hours_Onlineformat = this.missingCSS;
                    }
                    if (!(record.Address && record.Address.toString().length && record.Address.toString().length > 0)) {
                        record.Addressformat = this.missingCSS;
                    }
                    if (!(record.Street_Name && record.Street_Name.toString().length && record.Street_Name.toString().length > 0)) {
                        record.Street_Nameformat = this.missingCSS;
                    }
                    if (!(record.City && record.City.toString().length && record.City.toString().length > 0)) {
                        record.Cityformat = this.missingCSS;
                    }
                    if (!(record.State && record.State.toString().length && record.State.toString().length > 0)) {
                        record.Stateformat = this.missingCSS;
                    }
                    if (!(record.Zip && record.Zip.toString().length && record.Zip.toString().length > 0)) {
                        record.Zipformat = this.missingCSS;
                    }
                    if (!(record.of_Units && record.of_Units.toString().length && record.of_Units.toString().length > 0)) {
                        record.of_Unitsformat = this.missingCSS;
                    }
                    if (record.RecordTypeName == 'HomeownerCounseling' && !(record.Primary_Cost && record.Primary_Cost.toString().length && record.Primary_Cost.toString().length > 0)) {
                        record.primaryCost = this.missingCSS;
                    }
                    if (record.RecordTypeName == 'HomeownerCounseling' && (record.CaseSubType != 'NW Rehab') && !(record.Rehab_Cost && record.Rehab_Cost.toString().length && record.Rehab_Cost.toString().length > 0)) {
                        if(!(record.Rehab_Cost != null && record.Rehab_Cost.toString() == 0)){
                            record.rehabCost = this.missingCSS;
                        }
                    }
                    if (record.RecordTypeName == 'HomeownerCounseling' && !(record.Closing_cost && record.Closing_cost.toString().length && record.Closing_cost.toString().length > 0)) {
                        if(!(record.Closing_cost != null && record.Closing_cost.toString() == 0)){
                            record.closingCost = this.missingCSS;
                        }
                    }
                    if (record.RecordTypeName == 'HomeownerCounseling' && !(record.Other_Cost && record.Other_Cost.toString().length && record.Other_Cost.toString().length > 0)) {
                        if(!(record.Other_Cost != null && record.Other_Cost.toString() == 0)){
                            record.otherCost = this.missingCSS;
                        }
                    }
                    if (record.RecordTypeName == 'HomeownerCounseling' && !(record.Mortgage_Insurance_Type && record.Mortgage_Insurance_Type.toString().length && record.Mortgage_Insurance_Type.toString().length > 0)) {
                        record.mortgageInsuranceType = this.missingCSS;
                    }
                    if (record.RecordTypeName == 'HomeownerCounseling' && !(record.Monthly_mortgage_insurance_amount && record.Monthly_mortgage_insurance_amount.toString().length && record.Monthly_mortgage_insurance_amount.toString().length > 0)) {
                        record.Monthly_mortgage_insurance_amount_format = this.missingCSS;
                    }
                    if (record.RecordTypeName == 'HomeownerCounseling' && !(record.Total_Monthly_Payment && record.Total_Monthly_Payment.toString().length && record.Total_Monthly_Payment.toString().length > 0)) {
                        record.Total_Monthly_Payment_format = this.missingCSS;
                    }                    

                    listrecords1.push( record );
                    tempRec = Object.assign({}, record);
                    if(tempRec.Head_Of_Household_Type == 'Head of Household Type missing'){
                        tempRec.Head_Of_Household_Type = '';
                    }
                    if(tempRec.RehaborReplacementNat == 'No Response' || tempRec.RehaborReplacementNat == 'N/A'){
                        tempRec.RehaborReplacementNat = '';
                    }
                    listrecordsClientExport.push(tempRec);
                });
                this.bookingList = listrecords1;
                this.bookingListClientExport = listrecordsClientExport;
            }
            if(key=='Export'){
                console.log("result", result);
                var listrecords=[];
                var listrecords1=[];
                listrecords=result[key];
                this.isLoading = false;
                listrecords.forEach( ( record ) => {
                    let tempRec = Object.assign( {}, record );
                    record.Household_ID='/' +record.recordid;     
                    listrecords1.push( record );
                });
                this.bookingList1 = listrecords1;
            }          
        }
        this.isLoading = false;
    })
    .catch((error) => {
        this.isLoading = false;
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
      
    getOrsClientsUniqueList({
        qtrStartDate: this.qtrStartdate,
        qtrEndDate: this.qtrEnddate
    })
        .then((result) => {
            for(let key in result) {
                console.log("export", result);
                if(key=='Valid'){
                    var elistrecords=[];
                    elistrecords=result[key];
                    this.isLoading = false;
                    console.log("this.bookingList==", elistrecords);
                    elistrecords.forEach(function (rec) {
                        console.log("export1", rec);
                        rec.Intake_Date = new Date(rec.Intake_Date);
                        rec.Intake_Date.setDate(rec.Intake_Date.getDate());
                        if(rec.HBE_Provided_by_Other_Agency_Date != null){
                            console.log('rec.HBE_Provided_by_Other_Agency_Date : '+rec.HBE_Provided_by_Other_Agency_Date);
                            rec.HBE_Provided_by_Other_Agency_Date = new Date(rec.HBE_Provided_by_Other_Agency_Date);
                        }
                        if(rec.Head_Of_Household_Type == 'Head of Household Type missing'){
                            rec.Head_Of_Household_Type = '';
                        }
                        if(rec.RehaborReplacementNat == 'No Response' || rec.RehaborReplacementNat == 'N/A'){
                            rec.RehaborReplacementNat = '';
                        }
                        console.log('3910');
                    });
                        
                    writeXlsxFile(elistrecords, {
                        schema: _self.excelExportColumns,
                        fileName: "NWQR Clients Export.xlsx"
                    });
                }
            }
        }) 
          
        .catch((error) => {
            console.error(error);
            const event = new ShowToastEvent({
            title: "Error",
            message: "Please Contact System Admin",
            variant: "error"
            });
            this.dispatchEvent(event);
        });
       
    }
}