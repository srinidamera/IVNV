public class HUD9902SummaryReportController {
    public X9902Summary__c summaryRec{get;set;}
    public X9902Agency__c x9902AgencyRec{get;set;}
    public String reportDateYear{get;set;}
    public Integer section8And9Sum{get;set;}
    public Integer hudSection8And9Sum{get;set;}
    public String currentTimeStamp{get;set;}
    public String fromDt{get;set;}
    public String toDt{get;set;}
    public Integer agencyid{get;set;}
    
    public HUD9902SummaryReportController(){
        Id hud9902Id = ApexPages.currentPage().getParameters().get('recId');
                
        reportDateYear = String.valueOf(System.today().Year());
        currentTimeStamp = System.now().format('MM/dd/yyyy hh:mm:ss');
        
        IntegrationSettings__c mc   = IntegrationSettings__c.getValues('HUD Settings');
        agencyid   = integer.valueOf(mc.AgencyID__c);
        
        x9902AgencyRec = [Select Id, AgencyName__c, AgencyPhysicalAddressCity__c from X9902Agency__c where X9902__c =:hud9902Id AND ElementType__c = 'Profile' limit 1];
        
        if(String.isNotBlank(hud9902Id)){
            List<X9902Summary__c> sumaryRecs = [SELECT Id, X9902__c, X9902__r.PeriodStartDate__c, X9902__r.PeriodEndDate__c,
                                                Hispanic__c, NotHispanic__c, ChoseNottoRespond__c, Section3TOTAL__c,
                                                AmericanIndianAlaskanNative__c, Asian__c, BlackorAfricanAmerican__c, NativeHawaiian__c, White__c, MoreThanoneRace__c, MultiRaceChosenottorespond__c, Section4TOTAL__c,
                                                X30ofAreaMedianIncomeAMI__c, X3049ofAMI__c, X5079ofAMI__c, X80100ofAMI__c, X100AMI__c, AMIChosenottorespond__c, Section5TOTAL__c,
                                                Householdlivesinaruralarea__c, Householddoesnotliveinaruralarea__c, RuralChosenottorespond__c, Section6TOTAL__c,
                                                HouseholdisLimitedEnglishProficient__c, NotLimitedEnglishProficient__c, LimitedEnglishProficienChoseNotToRespond__c, Section7TOTAL__c,
                                                Completedfinancialliteracyworkshop__c, Completedpredatorylending__c, Completedfairhousingworkshop__c, HomelessnessPreventionWorkshop__c, Completedrentalworkshop__c, 
                                                Prepurchasehomebuyereducationworkshop__c, NonDelinquencyPostPurchaseWorkshop__c, MortgageDelinquencyWorkshop__c, CompletedDisasterPreparednessWorkshop__c, DisasterRecoveryWorkshop__c, Section_8_TOTAL__c,
                                                HomelessAssistance__c, RentalTopics__c, PrepurchaseHomebuying__c, HomeMaintenance__c, ReverseMortgage__c, ForwardMortgageDelinquencyorDefault__c, ReverseMortgageDelinquencyorDefault__c, DisasterPreparednessAssistance__c, DisasterRecoveryAssistance__c, Section9TOTAL__c,
                                                OneononeCounseling__c, ReceivedInformationonFairHousing__c, SustainableHouseholdBudget__c, HouseholdsImprovedFinancialCapacity__c, HouseholdsGainedAccesstoResources__c, GainedAccesstoNonHousingResources__c, 
                                                HomelessobtainedHousing__c, DisasterRecoveryNonhousingResources__c, DisasterRecoveryHousingResources__c, EmergencyPreparednessPlan__c, HouseholdsReceivedRentalCounselling__c, 
                                                HouseholdsImprovedLivingConditions__c, PrepurchaseHomebuyingCounseling__c, HouseholdsReceivedReverseMortgage__c, NonDelinquencyPostPurchaseCounseling__c, PreventedForwardMortgageDefault__c, 
                                                PreventedReverseMortgageDefault__c, ForwardMortgageModImprovedFinancials__c, ForwardModImprovedFinancialCapacity__c, Section10TOTAL__c,
                                                
                                                HUDHispanic__c, HUDNotHispanic__c, HUDChoseNottoRespond__c, HUDSection3TOTAL__c,
                                                HUDAmericanIndianAlaskanNative__c, HUDAsian__c, HUDBlackorAfricanAmerican__c, HUDNativeHawaiian__c, HUDWhite__c, HUDMoreThanoneRace__c, HUDMultiRaceChosenottorespond__c, HUDSection4TOTAL__c,
                                                HUDX30ofAreaMedianIncomeAMI__c, HUDX3049ofAMI__c, HUDX5079ofAMI__c, HUDX80100ofAMI__c, HUDX100AMI__c, HUDAMIChosenottorespond__c, HUDSection5TOTAL__c,
                                                HUDHouseholdlivesinaruralarea__c, HUDHouseholddoesnotliveinarural__c, HUDRuralChosenottorespond__c, HUDSection6TOTAL__c,
                                                HUDHouseholdisLimitedEnglish__c, HUDNotLimitedEnglishProficient__c, HUDLimitedEnglishProficienChoseNotTo__c, HUDSection7TOTAL__c,
                                                HUDCompletedfinancialliteracy__c, HUDCompletedpredatorylending__c, HUDCompletedfairhousingworkshop__c, HUDHomelessnessPreventionWorkshop__c, HUDCompletedrentalworkshop__c, 
                                                HUDPrepurchasehomebuyereducation__c, HUDNonDelinquencyPostPurchaseWork__c, HUDMortgageDelinquencyWorkshop__c, HUDCompletedDisasterPreparedness__c, HUDDisasterRecoveryWorkshop__c, HUDSection8TOTAL__c,
                                                HUDHomelessAssistance__c, HUDRentalTopics__c, HUDPrepurchaseHomebuying__c, HUDHomeMaintenance__c, HUDReverseMortgage__c, HUDForwardMortgageDelinquencyor__c, HUDReverseMortgageDelinquencyor__c, HUDDisasterPreparednessAssistance__c, HUDDisasterRecoveryAssistance__c, HUDSection9TOTAL__c,
                                                HUDOneononeCounseling__c, HUDReceivedInformationonFair__c, HUDSustainableHouseholdBudget__c, HUDHouseholdsImprovedFinancial__c, HUDHouseholdsGainedAccessto__c, HUDGainedAccesstoNonHousing__c, 
                                                HUDHomelessobtainedHousing__c, HUDDisasterRecoveryNonhousing__c, HUDDisasterRecoveryHousingResources__c, HUDEmergencyPreparednessPlan__c, HUDHouseholdsReceivedRental__c, 
                                                HUDHouseholdsImprovedLiving__c, HUDPrepurchaseHomebuyingCounseling__c, HUDHouseholdsReceivedReverseMortgage__c, HUDNonDelinquencyPostPurchaseCoun__c, HUDPreventedForwardMortgageDefault__c, 
                                                HUDPreventedReverseMortgageDefault__c, HUDForwardMortgageModImproved__c, HUDForwardModImprovedFinancial__c, HUDSection10TOTAL__c
                                                from X9902Summary__c where X9902__c =:hud9902Id AND ElementType__c = '9902' limit 1];
            
            if(sumaryRecs.size() > 0){
                summaryRec = sumaryRecs[0];
                
                if(sumaryRecs[0].X9902__c != NULL && sumaryRecs[0].X9902__r.PeriodStartDate__c != NULL){
                    fromDt = formatDate(sumaryRecs[0].X9902__r.PeriodStartDate__c);
                }
                
                if(sumaryRecs[0].X9902__c != NULL && sumaryRecs[0].X9902__r.PeriodEndDate__c != NULL){
                    toDt = formatDate(sumaryRecs[0].X9902__r.PeriodEndDate__c);
                }
                
                
                section8And9Sum = Integer.valueOf(summaryRec.Section_8_TOTAL__c + summaryRec.Section9TOTAL__c);
                hudSection8And9Sum = Integer.valueOf(summaryRec.HUDSection8TOTAL__c + summaryRec.HUDSection9TOTAL__c);
                
            }
        }
            
    }
    
    private static String formatDate(Date dt){
        String dtString = '';
        String day = String.valueOf(dt.day()).length() == 1 ? ('0' + String.valueOf(dt.day())) : String.valueOf(dt.day());
        String month = String.valueOf(dt.month()).length() == 1 ? ('0' + String.valueOf(dt.month())) : String.valueOf(dt.month());
        
        dtString = month + '/' + day + '/' + String.valueOf(dt.year());
        
        return dtString;
    }

}