/**
 *Desc: An apex class controller for budgetPDF data retrieving 
 */
public class BudgetPDFController {
    public Budget__c budget { get; set; }
    public Id budgetId { get; set; }
    
    /**
 *Desc: An apex class constructor for the data retrieving functionality
 */
    public BudgetPDFController() {
        Id CaseId = ApexPages.currentPage().getParameters().get('id');
        if(CaseId != NULL){
            List<Budget__c> BudgetList = [SELECT id FROM Budget__c WHERE ClientCase__c =:CaseId ];
            if(!BudgetList.isEmpty()){
                budgetId = BudgetList[0].id;
            }
        }
        
        if (budgetId != null) {
            budget = [SELECT Id, IsDeleted, Name, CreatedDate, CreatedById, ClientCase__c, ActualAFDC__c, ActualAttorney__c, ActualBonuses__c, ActualCharity1__c, ActualCable__c, ActualCharity2__c, ActualCharity3__c, ActualClothing__c, 
                      ActualCreditCollections__c, ActualChildSupport__c, ActualComissions__c, ActualConcerts__c, ActualCreditcard1__c, ActualCreditcard2__c, ActualCreditcard3__c, ActualDiningout__c, ActualDrycleaning__c, ActualEducation__c, 
                      ActualElectricity__c, ActualEmployment__c, ActualFood__c, ActualHairNails__c, ActualHomeOwnerAssoc__c, ActualInsurance__c, ActualHomeEquityLine__c, ActualHealthclub__c, ActualGrooming__c, ActualGroceries__c, ActualGas__c, 
                      ActualFuel__c, ActualFederal__c, ActualHomeownerRentersInsurance__c, ActualInterestDividen__c, ActualLocal__c, ActualMortgageOrRent__c, ActualOvertime__c, ActualRetirementaccount__c, ActualStudent__c, ActualToys__c, 
                      ActualWasteRemova__c, ActualWithholding__c, EntertainmentProjectedOther__c, HousingActualOther__c, ActualInvestmentaccount__c, ActualLicensing__c, ActualLivetheater__c, ActualMaintenance__c, ActualMaintenanceOrRepair__c, 
                      ActualMonthlyIncomeAlimony__c, ActualMovies__c, ActualMusicplatforms__c, ActualNetRentalIncome__c, ActualNightout__c, ActualOrganizationduesorfees__c, ActualOther__c, ActualPaymentsonlienorjudgment__c, ActualPersonal__c, 
                      ActualPhone__c, ActualSSI__c, ActualSportingevents__c, ActualState__c, ActualSupplies__c, ActualUnemployment__c, ActualVehiclePayment__c, ActualWaterAndSewer__c, EntertainmentActualOther__c, FoodActualOther__c, 
                      FoodProjectedOther__c, HousingProjectedOther__c, LegalActualAlimony__c, LegalActualOther__c, LegalProjectedAlimony__c, LegalProjectedOther__c, PersonalCareProjectedOther__c, PetsProjectedMedical__c, ProjectedBonuses__c, 
                      ProjectedDiningout__c, ProjectedFood__c, ProjectedGrooming__c, ProjectedHomeOwnerAssoc__c, ProjectedInsurance__c, ProjectedInvestmentaccount__c, ProjectedLicensing__c, ProjectedInterestDividen__c, Total_Monthly_Income_Difference__c,
                      ProjectedHomeownerRentersInsurance__c, ProjectedHomeEquityLine__c, ProjectedHealthclub__c, ProjectedHairNails__c, ProjectedGroceries__c, ProjectedGas__c, ProjectedFuel__c, ProjectedFederal__c, ProjectedEmployment__c, 
                      ProjectedElectricity__c, ProjectedDrycleaning__c, ProjectedEducation__c, ProjectedComissions__c, ProjectedCreditcard1__c, ProjectedCreditCollections__c, ProjectedConcerts__c, ProjectedClothing__c, ProjectedCreditcard2__c, 
                      ProjectedCreditcard3__c, ProjectedCharity2__c, ProjectedCharity1__c, ProjectedCable__c, ProjectedCharity3__c, ProjectedChildSupport__c, ProjectedAttorney__c, ProjectedAFDC__c, PrimaryClient__c, PetsProjectedOther__c, 
                      PetsActualOther__c, PetsActualMedical__c, LoansActualOther__c, PersonalCareActualMedical__c, LoansProjectedOther__c, PersonalCareActualOther__c, PersonalCareProjectedMedical__c, ProjectedLivetheater__c, Employment_Difference__c,
                      ProjectedMonthlyIncomeAlimony__c, ProjectedOther__c, ProjectedRetirementaccount__c, ProjectedToys__c, ProjectedWaterAndSewer__c, SavingsorInvestmentsProjectedOther__c, TransportationProjectedOther__c, CableDiffrence__c, 
                      ProjectedLocal__c, ProjectedMaintenanceOrRepair__c, ProjectedMaintenance__c, ProjectedMortgageOrRent__c, ProjectedMusicplatforms__c, ProjectedNetRentalIncome__c, ProjectedMovies__c, ProjectedNightout__c, Interest_Dividend_Difference__c,
                      ProjectedOrganizationduesorfees__c, ProjectedOvertime__c, ProjectedPaymentsonlienorjudgment__c, ProjectedPersonal__c, ProjectedPhone__c, ProjectedSSI__c, ProjectedSportingevents__c, ProjectedState__c, ProjectedStudent__c, Net_Rental_Income_Difference__c,
                      ProjectedSupplies__c, Charity2Difference__c, Charity1Difference__c, Charity3Difference__c, ClothingDifference__c, ConcertsDifference__c, CreditCollectionsDifference__c, Creditcard1Difference__c, Creditcard2Difference__c, 
                      Difference__c, Creditcard3Difference__c, DiningoutDifference__c, ProjectedUnemployment__c, ProjectedWasteRemoval__c, ProjectedVehiclePayment__c, ProjectedWithholding__c, SavingsorInvestmentsActualOther__c, TaxesActualOther__c, Overtime_Difference__c,
                      TransportationActualOther__c, TaxesProjectedOther__c, ActualBalance__c, ActualTotalMonthlyIncome__c, AttorneyDifference__c, DrycleaningDifference__c, EducationDifference__c, EntertainmentActualCost__c, ElectricityDiffrence__c,
                      EntertainmentDifference__c, EntertainmentOtherDifference__c, EntertainmentProjectedCost__c, FederalDifference__c, FoodActualCost__c, FoodDifference__c, FoodOtherDifference__c, FoodProjectedCost__c, FuelDiffrence__c, Bonuses_Difference__c,
                      GasDiffrence__c, GiftsandDonationsActualCost__c, GiftsandDonationsDifference__c, GiftsandDonationsProjectedCost__c, GroceriesDifference__c, GroomingDifference__c, HairNailsDifference__c, HealthclubDifference__c, Withholding_Difference__c,
                      HomeEquityLineDifference__c, HomeOwnerAssocDifference__c, HomeownerRentersInsuranceDifference__c, HousingActualCost__c, HousingDiffrence__c, HousingOtherDiffrence__c, HousingProjectedCost__c, InsuranceDiffrence__c, Child_Support_Difference__c,
                      InvestmentaccountDifference__c, LegalActualCost__c, LegalAlimonyDifference__c, LegalOtherDifference__c, LegalDifference__c, LegalProjectedCost__c, LivetheaterDifference__c, LoansActualCost__c, LocalDifference__c, SSI_Difference__c,
                      MortgageOrRentDifference__c, NightoutDifference__c, PersonalCareDifference__c, PersonalCareMedicalDifference__c, PersonalDifference__c, PetsActualCost__c, PetsFoodDifference__c, PetsProjectedCost__c, Monthly_Income_Other_Difference__c,
                      ProjectedTotalMonthlyIncome__c, RetirementaccountDifference__c, SavingsorInvestmentsDifference__c, SportingeventsDifference__c, StudentDifference__c, TaxesActualCost__c, TaxesDifference__c, TaxesProjectedCost__c, Unemployment_Difference__c,
                      TotalActualCost__c, LicensingDiffrence__c, LoansDifference__c, LoansOtherDifference__c, LoansProjectedCost__c, MaintenanceDiffrence__c, MaintainanceOrRepairDiffrence__c, MoviesDifference__c, MusicplatformsDifference__c, 
                      PaymentsonlienorjudgmentDifference__c, PersonalCareActualCost__c, OrganizationduesorfeesDifference__c, PersonalCareOtherDifference__c, PersonalCareProjectedCost__c, WaterAndSewerDiffrence__c, WasteRemovalDiffrence__c, Alimony_Difference__c,
                      VehiclePaymentDiffrence__c, TransportationProjectedCost__c, TransportationOtherDiffrence__c, TransportationDiffrence__c, TransportationActualCost__c, ToysDifference__c, TotalProjectedCost__c, TotalDifference__c, Commissions_Difference__c, 
                      TaxesOtherDifference__c, SuppliesDiffrence__c, StateDifference__c, SavingsorInvestmentsProjectedCost__c, SavingsorInvestmentsOtherDifference__c, SavingsorInvestmentsActualCost__c, ProjectedBalance__c, PhoneDifference__c, 
                      PetsOtherDifference__c, PetsMedicalDifference__c, PetsDifference__c FROM Budget__c WHERE id =:budgetId];
        }
    }

}