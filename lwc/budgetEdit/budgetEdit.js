/**
 * @description  : Budget Edit LWC
 **/
import { LightningElement, api, track, wire } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { RefreshEvent } from 'lightning/refresh';

import NAME_FIELD from '@salesforce/schema/ClientCase__c.Name';
import PRIMARY_CLIENT from '@salesforce/schema/ClientCase__c.PrimaryClient__c';

export default class BudgetEdit extends NavigationMixin(LightningElement) {
    @api recordId;
    @api budgetId;
    @api objectApiName;
    @track clienCase;
    @track budget = {};

    //Get Client Case
    @wire(getRecord, {
        recordId: '$recordId',
        fields: [NAME_FIELD, PRIMARY_CLIENT]
    })
    wireClientCase({ error, data }) {
        if (error) {
            console.log('error==', error);
        } else {
            console.log('data11==', data);
            this.clienCase = data;
        }
    }

    //Get Budget Record
    @wire(getRecord, {
        recordId: '$budgetId',
        fields: [
            'Budget__c.ProjectedTotalMonthlyIncome__c',
            'Budget__c.ActualTotalMonthlyIncome__c',
            'Budget__c.ProjectedMortgageOrRent__c',
            'Budget__c.ActualMortgageOrRent__c',
            'Budget__c.MortgageOrRentDifference__c',
            'Budget__c.ProjectedPhone__c',
            'Budget__c.ProjectedElectricity__c',
            'Budget__c.ProjectedGas__c',
            'Budget__c.ProjectedWaterAndSewer__c',
            'Budget__c.ProjectedCable__c',
            'Budget__c.ProjectedWasteRemoval__c',
            'Budget__c.ProjectedMaintenanceOrRepair__c',
            'Budget__c.ProjectedSupplies__c',
            'Budget__c.HousingProjectedOther__c',
            'Budget__c.ActualPhone__c',
            'Budget__c.ActualElectricity__c',
            'Budget__c.ActualWaterAndSewer__c',
            'Budget__c.ActualCable__c',
            'Budget__c.ActualWasteRemova__c',
            'Budget__c.ActualMaintenanceOrRepair__c',
            'Budget__c.ActualSupplies__c',
            'Budget__c.HousingActualOther__c',
            'Budget__c.ActualGas__c',
            'Budget__c.HousingProjectedCost__c',
            'Budget__c.HousingActualCost__c',
            'Budget__c.ProjectedVehiclePayment__c',
            'Budget__c.ProjectedInsurance__c',
            'Budget__c.ProjectedLicensing__c',
            'Budget__c.ProjectedFuel__c',
            'Budget__c.ProjectedMaintenance__c',
            'Budget__c.TransportationProjectedOther__c',
            'Budget__c.ActualVehiclePayment__c',
            'Budget__c.ActualInsurance__c',
            'Budget__c.ActualLicensing__c',
            'Budget__c.ActualFuel__c',
            'Budget__c.ActualMaintenance__c',
            'Budget__c.TransportationActualOther__c',
            'Budget__c.TransportationProjectedCost__c',
            'Budget__c.TransportationActualCost__c',
            'Budget__c.ProjectedGroceries__c',
            'Budget__c.ActualGroceries__c',
            'Budget__c.ProjectedDiningout__c',
            'Budget__c.ActualDiningout__c',
            'Budget__c.FoodProjectedOther__c',
            'Budget__c.FoodActualOther__c',
            'Budget__c.FoodProjectedCost__c',
            'Budget__c.FoodActualCost__c',
            'Budget__c.FoodDifference__c',
            'Budget__c.ProjectedFood__c',
            'Budget__c.ActualFood__c',
            'Budget__c.PetsProjectedMedical__c',
            'Budget__c.PetsActualMedical__c',
            'Budget__c.ProjectedGrooming__c',
            'Budget__c.ActualGrooming__c',
            'Budget__c.ProjectedToys__c',
            'Budget__c.ActualToys__c',
            'Budget__c.PetsProjectedOther__c',
            'Budget__c.PetsActualOther__c',
            'Budget__c.ProjectedHairNails__c',
            'Budget__c.ActualHairNails__c',
            'Budget__c.ProjectedClothing__c',
            'Budget__c.ActualClothing__c',
            'Budget__c.ProjectedDrycleaning__c',
            'Budget__c.ActualDrycleaning__c',
            'Budget__c.ProjectedHealthclub__c',
            'Budget__c.ActualHealthclub__c',
            'Budget__c.ProjectedOrganizationduesorfees__c',
            'Budget__c.ActualOrganizationduesorfees__c',
            'Budget__c.PersonalCareProjectedOther__c',
            'Budget__c.PersonalCareActualOther__c',
            'Budget__c.ProjectedNightout__c',
            'Budget__c.ActualNightout__c',
            'Budget__c.ProjectedMusicplatforms__c',
            'Budget__c.ActualMusicplatforms__c',
            'Budget__c.ProjectedMovies__c',
            'Budget__c.ActualMovies__c',
            'Budget__c.ProjectedConcerts__c',
            'Budget__c.ActualConcerts__c',
            'Budget__c.ProjectedSportingevents__c',
            'Budget__c.ActualSportingevents__c',
            'Budget__c.ProjectedLivetheater__c',
            'Budget__c.ActualLivetheater__c',
            'Budget__c.EntertainmentProjectedOther__c',
            'Budget__c.EntertainmentActualOther__c',
            'Budget__c.ProjectedPersonal__c',
            'Budget__c.ActualPersonal__c',
            'Budget__c.ProjectedStudent__c',
            'Budget__c.ActualStudent__c',
            'Budget__c.LoansProjectedOther__c',
            'Budget__c.LoansActualOther__c',
            'Budget__c.ProjectedFederal__c',
            'Budget__c.ActualFederal__c',
            'Budget__c.ProjectedState__c',
            'Budget__c.ActualState__c',
            'Budget__c.ProjectedLocal__c',
            'Budget__c.ActualLocal__c',
            'Budget__c.TaxesProjectedOther__c',
            'Budget__c.TaxesActualOther__c',
            'Budget__c.ProjectedRetirementaccount__c',
            'Budget__c.ActualRetirementaccount__c',
            'Budget__c.ProjectedInvestmentaccount__c',
            'Budget__c.ActualInvestmentaccount__c',
            'Budget__c.SavingsorInvestmentsProjectedOther__c',
            'Budget__c.SavingsorInvestmentsActualOther__c',
            'Budget__c.ProjectedCharity1__c',
            'Budget__c.ActualCharity1__c',
            'Budget__c.ProjectedCharity2__c',
            'Budget__c.ActualCharity2__c',
            'Budget__c.ProjectedCharity3__c',
            'Budget__c.ActualCharity3__c',
            'Budget__c.ProjectedAttorney__c',
            'Budget__c.ActualAttorney__c',
            'Budget__c.LegalProjectedAlimony__c',
            'Budget__c.LegalActualAlimony__c',
            'Budget__c.ProjectedPaymentsonlienorjudgment__c',
            'Budget__c.ActualPaymentsonlienorjudgment__c',
            'Budget__c.LegalProjectedOther__c',
            'Budget__c.LegalActualOther__c',
            'Budget__c.ProjectedCreditcard1__c',
            'Budget__c.ActualCreditcard1__c',
            'Budget__c.ProjectedCreditcard2__c',
            'Budget__c.ActualCreditcard2__c',
            'Budget__c.ProjectedCreditcard3__c',
            'Budget__c.ActualCreditcard3__c',
            'Budget__c.PersonalCareProjectedMedical__c',
            'Budget__c.PersonalCareActualMedical__c',
            'Budget__c.PetsProjectedCost__c',
            'Budget__c.PetsActualCost__c',
            'Budget__c.PersonalCareProjectedCost__c',
            'Budget__c.PersonalCareActualCost__c',
            'Budget__c.EntertainmentProjectedCost__c',
            'Budget__c.EntertainmentActualCost__c',
            'Budget__c.LoansProjectedCost__c',
            'Budget__c.LoansActualCost__c',
            'Budget__c.TaxesProjectedCost__c',
            'Budget__c.TaxesActualCost__c',
            'Budget__c.TaxesDifference__c',
            'Budget__c.SavingsorInvestmentsProjectedCost__c',
            'Budget__c.SavingsorInvestmentsActualCost__c',
            'Budget__c.GiftsandDonationsProjectedCost__c',
            'Budget__c.GiftsandDonationsActualCost__c',
            'Budget__c.LegalProjectedCost__c',
            'Budget__c.LegalActualCost__c',
            'Budget__c.LegalDifference__c',
            'Budget__c.ProjectedBalance__c',
            'Budget__c.ActualBalance__c',
            'Budget__c.Difference__c',
            'Budget__c.ProjectedEmployment__c',
            'Budget__c.ProjectedOvertime__c',
            'Budget__c.ProjectedInterestDividen__c',
            'Budget__c.ProjectedNetRentalIncome__c',
            'Budget__c.ProjectedBonuses__c',
            'Budget__c.ProjectedComissions__c',
            'Budget__c.ProjectedSSI__c',
            'Budget__c.ProjectedChildSupport__c',
            'Budget__c.ProjectedAFDC__c',
            'Budget__c.ProjectedUnemployment__c',
            'Budget__c.ProjectedOther__c',
            'Budget__c.ProjectedWithholding__c',
            'Budget__c.ActualEmployment__c',
            'Budget__c.ActualOvertime__c',
            'Budget__c.ActualInterestDividen__c',
            'Budget__c.ActualNetRentalIncome__c',
            'Budget__c.ActualBonuses__c',
            'Budget__c.ActualComissions__c',
            'Budget__c.ActualSSI__c',
            'Budget__c.ActualChildSupport__c',
            'Budget__c.ActualAFDC__c',
            'Budget__c.ActualUnemployment__c',
            'Budget__c.ActualOther__c',
            'Budget__c.ActualWithholding__c',
            'Budget__c.ProjectedHomeOwnerAssoc__c',
            'Budget__c.ActualHomeOwnerAssoc__c',
            'Budget__c.ProjectedHomeEquityLine__c',
            'Budget__c.ActualHomeEquityLine__c',
            'Budget__c.ProjectedHomeownerRentersInsurance__c',
            'Budget__c.ActualHomeownerRentersInsurance__c',
            'Budget__c.ProjectedEducation__c',
            'Budget__c.ActualEducation__c',
            'Budget__c.ProjectedCreditCollections__c',
            'Budget__c.ActualCreditCollections__c',
            'Budget__c.ProjectedMonthlyIncomeAlimony__c',
            'Budget__c.ActualMonthlyIncomeAlimony__c'
        ]
    })
    wireBudget({ error, data }) {
        if (error) {
            console.log('errorBudget=', error);
        } else {
            //console.log('data111==', data);
            if (data) {
                this.budget = this.transformFields(data);
            }
        }
    }

    //Tranform data to display in UI
    transformFields(data) {
        const transformed = {};
        for (const field in data.fields) {
            transformed[field] = data.fields[field].value;
        }
        return transformed;
    }

    get primaryClientId() {
        return getFieldValue(this.clienCase, PRIMARY_CLIENT);
    }

    //Handle Submit
    handleFormSubmit(event) {
        event.preventDefault();

        //Demo
        let result = [];
        this.template.querySelectorAll('.editSection').forEach((elt) => {
            result.push(elt.getFieldValues());
        });
        console.log('Field Values from ', JSON.parse(JSON.stringify(result)));

        const inputFields = event.detail.fields;

        let currentDate = new Date();
        let month = currentDate.getMonth() + 1;
        month = month <= 9 ? '0' + month : month;
        let date =
            currentDate.getDate() <= 9
                ? '0' + currentDate.getDate()
                : currentDate.getDate();

        result.forEach((elt) => {
            for (const [key, value] of Object.entries(elt)) {
                inputFields[`${key}`] = `${value}`;
            }
        });

        inputFields['Name'] =
            'Budget-' + month + '/' + date + '/' + currentDate.getFullYear();
        inputFields['ClientCase__c'] = this.recordId;
        this.template
            .querySelector('lightning-record-edit-form')
            .submit(inputFields);
        this.dispatchEvent(new RefreshEvent());
    }

    //Handle After Submit
    handleFormSuccess(event) {
        let message = {
            title: 'Success',
            message: 'Record was created successfully.',
            variant: 'success'
        };
        if (this.budgetId) {
            message.message = 'Record was updated successfully.';
        }
        const evt = new ShowToastEvent(message);
        this.dispatchEvent(evt);

        this.dispatchEvent(new CustomEvent('closemodal'));
    }
    //Handle Cancel
    handleCancelButton(event) {
        this.dispatchEvent(new CustomEvent('closemodal'));
    }
}