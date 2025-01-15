public class PrintActionPlanVfController {
    public String clientCaseName {get;set;}
    public String currentDate {get;set;}
    public String clientName {get;set;}
    public String clientCaseNumber {get;set;}
    public String coAppNames {get;set;}
    public String reasonForCounseling {get;set;}
    public String counselorName  {get;set;}
    public String counselorEmail {get;set;}
    public String counselorPhone {get;set;}
    public String counselorPreferredContactMethod {get;set;}
    public String notesOnClientHousingGoalOrIssue {get;set;}
    public List<Referral__c> referrals {get;set;}
    public List<ClientActionPlansController.ClientActionPlanWrapper> wrapList{get;set;}
    public integer noOfClasses {get;set;}
    public String agencyName {get; set;}
    public String agencyContact {get; set;}
    public String refOutcome {get; set;}
    public String refNotes {get; set;}
    public ClientActionPlansController.FinancialSnapshotWrapper InitialfinancialSnapshotWrapper { get; set; }
    public ClientActionPlansController.FinancialSnapshotWrapper PostfinancialSnapshotWrapper { get; set; }
    
    
    public list<Integer> blankRowsExtraPage {get; set;}
    public map<string,list<Integer>> classtoBlankrowsMap {get; set;} 
    
    
    
    
    public PrintActionPlanVfController(){
        
        Id recId        = ApexPages.currentPage().getParameters().get('Id');
        
        if(recId == null){
            recId = 'a01W4000005HDyrIAG';
        }
        List<FinancialSnapshot__c> snapshots = [
            SELECT Id, CreditScore__c, CoAppCreditScore__c, Savings__c, GrossMonthlyIncome__c, NetMonthlyIncome__c, 
            CurrentMonthlyDebtObligation__c, HousingExpense__c, TotalDebt__c, TotalAssets__c, NetWorth__c, 
            PrimaryContact__c, ClientCase__c FROM FinancialSnapshot__c WHERE ClientCase__c = :recId WITH SECURITY_ENFORCED
            ORDER BY Name 
        ];

        if (!snapshots.isEmpty()) {
            InitialfinancialSnapshotWrapper = new ClientActionPlansController.FinancialSnapshotWrapper(snapshots[0]);
            if(snapshots.size() >1){
                PostfinancialSnapshotWrapper 	= new ClientActionPlansController.FinancialSnapshotWrapper(snapshots[snapshots.size() - 1]); 
            }
        }
        
        currentDate = System.today().format();
        
        blankRowsExtraPage = new list<Integer>{1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24};
            classtoBlankrowsMap = new map<string, list<integer>>();

        wrapList = new List<ClientActionPlansController.ClientActionPlanWrapper>();
        
        ClientActionPlansController.ClientActionPlanWrapper wrap = ClientActionPlansController.getGoalsForClientCase(recId);
        String clientCaseId =  String.isNotBlank(wrap.clientCaseId) ? wrap.clientCaseId : 'N/A';
        clientCaseName =  String.isNotBlank(wrap.clientCaseName) ? wrap.clientCaseName : 'N/A';
        clientName = String.isNotBlank(wrap.clientName) ? wrap.clientName : 'N/A';
        clientCaseNumber =  String.isNotBlank(wrap.clientCaseNumber) ? wrap.clientCaseNumber : 'N/A';
        coAppNames =  String.isNotBlank(wrap.coAppNames) ? wrap.coAppNames : 'N/A';
        reasonForCounseling =  String.isNotBlank(wrap.reasonForCounseling) ? wrap.reasonForCounseling : 'N/A';
        counselorName =  String.isNotBlank(wrap.counselorName) ? wrap.counselorName : 'N/A';
        counselorEmail =  String.isNotBlank(wrap.counselorEmail) ? wrap.counselorEmail : 'N/A';
        counselorPhone =  String.isNotBlank(wrap.counselorPhone) ? wrap.counselorPhone : 'N/A';
        referrals = wrap.referrals;
        
        counselorPreferredContactMethod = String.isNotBlank(counselorPreferredContactMethod) ? counselorPreferredContactMethod : 'N/A';
        notesOnClientHousingGoalOrIssue = String.isNotBlank(notesOnClientHousingGoalOrIssue) ? notesOnClientHousingGoalOrIssue : 'N/A';
        
        
        for(ClientActionPlansController.GoalWrapper goal : wrap.actionPlans){
            if(goal.showGoalOtherName == true){
                goal.goalName = goal.goalOtherName;
            }
            
            for (Referral__c ref : referrals){
                //System.debug(ref);
                agencyName = String.isNotBlank(ref.ReferredtoAgency__r.Name)?ref.ReferredtoAgency__r.Name:'N/A';
                agencyContact = String.isNotBlank(ref.ReferredtoContact__r.Name)?ref.ReferredtoContact__r.Name:'N/A';
                refOutcome = String.isNotBlank(ref.ReferralOutcome__c)?ref.ReferralOutcome__c:'N/A';
                refNotes = String.isNotBlank(ref.ReferralNotes__c)?ref.ReferralNotes__c:'N/A';
                System.debug(ref.ReferredtoAgency__r.Name);
            }
            
            for(ClientActionPlansController.ObstacleWrapper obstacle : goal.obstacleList){
                if(obstacle.showObstacleOtherName == true){
                    obstacle.obstacleName = obstacle.obstacleOtherName;
                    obstacle.obstacleDetail = String.isNotBlank(obstacle.obstacleDetail) ? obstacle.obstacleDetail : 'N/A';
                }
                
                for(ClientActionPlansController.SolutionWrapper solution : obstacle.solutionList){
                    if(solution.showSolutionOtherName == true){
                        solution.solutionName = solution.solutionOtherName;
                    }
                    
                    goal.goalDueDateStr = String.isNotBlank(goal.goalDueDateStr) ? goal.goalDueDateStr : 'N/A';
                    goal.goalCompletionDateStr = String.isNotBlank(goal.goalCompletionDateStr) ? goal.goalCompletionDateStr : 'N/A';
                    
                    solution.solutionDetail = String.isNotBlank(solution.solutionDetail) ? solution.solutionDetail : 'N/A';
                    
                    solution.clientAction = String.isNotBlank(solution.clientAction) ? solution.clientAction : 'N/A';
                    solution.clientActionDetail = String.isNotBlank(solution.clientActionDetail) ? solution.clientActionDetail : 'N/A';
                    solution.clientActionDueDateStr = String.isNotBlank(solution.clientActionDueDateStr) ? solution.clientActionDueDateStr : 'N/A';
                    solution.clientActionCompletionDateStr = String.isNotBlank(solution.clientActionCompletionDateStr) ? solution.clientActionCompletionDateStr : 'N/A';
                    
                    solution.counselorAction = String.isNotBlank(solution.counselorAction) ? solution.counselorAction : 'N/A';
                    solution.counselorActionDetail = String.isNotBlank(solution.counselorActionDetail) ? solution.counselorActionDetail : 'N/A';
                    solution.counselorActionDueDateStr = String.isNotBlank(solution.counselorActionDueDateStr) ? solution.counselorActionDueDateStr : 'N/A';
                    solution.counselorActionCompletionDateStr = String.isNotBlank(solution.counselorActionCompletionDateStr) ? solution.counselorActionCompletionDateStr : 'N/A';
                }
            }
        }
        
        wrapList.add(wrap);
        noOfClasses = 0;
    }
    
    
}