/*
@description    Controller class for LWC clientActionPlans containing methods for fetching existing goal for a client case and 
saving new or updated details for a goal
*/
public class ClientActionPlansController {
    
    private static Set<String> goalOptionsList = new Set<String>();
    private static Set<String> obstacleOptionsList = new Set<String>();
    private static Set<String> solutionOptionsList = new Set<String>();
    
    
    
    
    /*
* Function to check custom permission access to remove obstacle 
*/
    @AuraEnabled(cacheable=true)
    public static Boolean hasRemoveObstaclePermission() {
        return FeatureManagement.checkPermission('Delete');
    }
    
    /*
* Function to  remove obstacle  from backend when hit remove obstacle button
*/
    
    @AuraEnabled
    public static void deleteObstaclesAndSolutionsForGoal(String goalId) {
        
        if (String.isNotBlank(goalId)) {
            
            // Check if the user has delete access to Obstacle__c and Solution__c
            if (Schema.sObjectType.Obstacle__c.isDeletable() && Schema.sObjectType.Solution__c.isDeletable()) {
                // Retrieve all Obstacles for the given Goal
                List<Obstacle__c> obstacleList = [
                    SELECT Id FROM Obstacle__c WHERE Goal__c = :goalId WITH SECURITY_ENFORCED
                ];
                
                
                if (!obstacleList.isEmpty()) {
                    // Retrieve all Solutions for the retrieved Obstacles
                    List<Solution__c> solutionList = [
                        SELECT Id FROM Solution__c WHERE Obstacle__c IN :obstacleList WITH SECURITY_ENFORCED
                    ];
                    
                    
                    // Delete the Solutions first
                    if (!solutionList.isEmpty()) {
                        try {
                            delete solutionList;
                            
                        } catch (DmlException dmlEx) {
                            
                            throw new AuraHandledException('Error deleting Solutions: ' + dmlEx.getMessage());
                        }
                    }
                    
                    // Delete the Obstacles
                    delete obstacleList;
                    
                    
                } 
            } 
        } 
    }
    
    /* method to remove solution of the obstacle */
    
    @AuraEnabled
    public static void deleteSolution(String solutionId) {
        if ( Schema.sObjectType.Solution__c.isDeletable()) {
            List<Solution__c> solutionList  = [SELECT Id from Solution__c WHERE   Id =: solutionId WITH SECURITY_ENFORCED];
            
            if (!solutionList.isEmpty()) {
                delete solutionList;
            }
        }
    }
    
    
    /*
@description    this method is used to return existing goals for a client case
*/
    @AuraEnabled
    public static ClientActionPlansController.ClientActionPlanWrapper getGoalsForClientCase(String clientCaseId){
        ClientActionPlansController.ClientActionPlanWrapper resultWrap = new ClientActionPlansController.ClientActionPlanWrapper();
        List<Utility.PicklistOption> goalPicklistOpt = new List<Utility.PicklistOption>();
        List<Utility.PicklistOption> obsPicklistOpt = new List<Utility.PicklistOption>();
        List<Utility.PicklistOption> solutionPicklistOpt = new List<Utility.PicklistOption>();
        
        if(//ClientCase__c Access Check
            Schema.sObjectType.ClientCase__c.isAccessible() && Schema.sObjectType.ClientCase__c.fields.PrimaryClient__c.isAccessible() &&
            //Goal__c Access Check
            Schema.sObjectType.Goal__c.isAccessible() && Schema.sObjectType.Goal__c.fields.GoalSubject__c.isAccessible() &&
            Schema.sObjectType.Goal__c.fields.ClientCase__c.isAccessible() && Schema.sObjectType.Goal__c.fields.GoalDetails__c.isAccessible() &&
            Schema.sObjectType.Goal__c.fields.GoalType__c.isAccessible() && Schema.sObjectType.Goal__c.fields.Status__c.isAccessible() &&
            Schema.sObjectType.Goal__c.fields.DueDate__c.isAccessible() && Schema.sObjectType.Goal__c.fields.CompletionDate__c.isAccessible() &&
            //Obstacle__c Access Check
            Schema.sObjectType.Obstacle__c.isAccessible() && Schema.sObjectType.Obstacle__c.fields.ObstacleSubject__c.isAccessible() &&
            Schema.sObjectType.Obstacle__c.fields.ClientCase__c.isAccessible() && Schema.sObjectType.Obstacle__c.fields.ClientActionPlan__c.isAccessible() &&
            Schema.sObjectType.Obstacle__c.fields.Goal__c.isAccessible() && Schema.sObjectType.Obstacle__c.fields.ObstacleDetails__c.isAccessible() &&
            Schema.sObjectType.Obstacle__c.fields.DueDate__c.isAccessible() && Schema.sObjectType.Obstacle__c.fields.CompletionDate__c.isAccessible() &&
            //Solution__c Access Check
            Schema.sObjectType.Solution__c.isAccessible() && Schema.sObjectType.Solution__c.fields.SolutionSubject__c.isAccessible() &&
            Schema.sObjectType.Solution__c.fields.ClientCase__c.isAccessible() && Schema.sObjectType.Solution__c.fields.Status__c.isAccessible() &&
            Schema.sObjectType.Solution__c.fields.SolutionDetails__c.isAccessible() && Schema.sObjectType.Solution__c.fields.ClientActionPlan__c.isAccessible() &&
            Schema.sObjectType.Solution__c.fields.Goal__c.isAccessible() && Schema.sObjectType.Solution__c.fields.Obstacle__c.isAccessible() &&
            //Task Access Check
            Schema.sObjectType.Task.isAccessible() && Schema.sObjectType.Task.fields.Status.isAccessible() &&
            Schema.sObjectType.Task.fields.Status.isAccessible() && Schema.sObjectType.Task.fields.CompletedDateTime.isAccessible() &&
            Schema.sObjectType.Task.fields.Subject.isAccessible() && Schema.sObjectType.Task.fields.ActionType__c.isAccessible() &&
            Schema.sObjectType.Task.fields.Description.isAccessible() && Schema.sObjectType.Task.fields.ActivityDate.isAccessible())
        {
            try{
                
                List<ClientCase__c> clientCaseRec = [Select Id, Name, PrimaryClient__r.Name, PrimaryClient__r.CorrespondingPortalUser__c, ClientCaseName__c, Purpose__c, OwnerId, 
                                                     Owner.Type, Owner.Name, Owner.Email, Owner.Phone, (Select Id from ClientActionPlans__r), 
                                                     (Select Id, Name, Contact__c, Contact__r.Name from Co_Applicants__r), 
                                                     (Select Id, ReferralNotes__c, ReferralOutcome__c, ReferredtoAgency__c, ReferredtoAgency__r.Name, ReferredtoContact__c, ReferredtoContact__r.Name, ClientName__c, ClientName__r.Name from Referrals__r) 
                                                     from ClientCase__c where Id =:clientCaseId];

                
                
                if(clientCaseRec.size() > 0){
                    

                    resultWrap.clientCaseId = clientCaseRec[0].Id;
                    resultWrap.clientCaseNumber = clientCaseRec[0].Name;
                    resultWrap.reasonForCounseling = clientCaseRec[0].Purpose__c;
                    resultWrap.referrals = clientCaseRec[0].Referrals__r;
                    
                    if(clientCaseRec[0].OwnerId != NULL && clientCaseRec[0].Owner.Type == 'User'){
                        resultWrap.counselorName = clientCaseRec[0].Owner.Name;
                        resultWrap.counselorEmail = clientCaseRec[0].Owner.Email;
                        resultWrap.counselorPhone = clientCaseRec[0].Owner.Phone;
                    }
                    
                    if(clientCaseRec[0].PrimaryClient__c != NULL){
                        resultWrap.clientName = clientCaseRec[0].PrimaryClient__r.Name;

                        List<User> lUsers = [SELECT Id,Contact.Id,Name,Email FROM User WHERE ContactId  =: clientCaseRec[0].PrimaryClient__c];
                        if (lUsers.size() > 1) {
                            if(clientCaseRec[0].PrimaryClient__r.CorrespondingPortalUser__c != NULL) {
                                resultWrap.portalUserId = clientCaseRec[0].PrimaryClient__r.CorrespondingPortalUser__c;
                            } 
                        } else if(lUsers.size() == 1){
                            resultWrap.portalUserId = lUsers[0].Id;
                        }
                    }
                    
                    if(clientCaseRec[0].ClientCaseName__c != NULL){
                        resultWrap.clientCaseName = clientCaseRec[0].ClientCaseName__c;
                    }
                    
                    if(clientCaseRec[0].ClientActionPlans__r.size() > 0){
                        resultWrap.actionPlanId = clientCaseRec[0].ClientActionPlans__r[0].Id;
                    }
                    String coAppName = '';
                    for(CoApplicant__c coApp : clientCaseRec[0].Co_Applicants__r){
                        coAppName = String.isNotBlank(coAppName) ? coAppName + ', ' + coApp.Contact__r.Name : coApp.Contact__r.Name;
                    }
                    
                    resultWrap.coAppNames = coAppName;
                }
                
                
                List<GoalWrapper> goalWrapperList = new List<GoalWrapper>();
                if(resultWrap.actionPlanId != NULL){
                    List<Goal__c> goalList = [Select Id, Name, GoalSubject__c, ClientActionPlan__c, ClientCase__c, GoalDetails__c, GoalType__c, Status__c, DueDate__c, CompletionDate__c
                                              from Goal__c where ClientActionPlan__c =:resultWrap.actionPlanId WITH SECURITY_ENFORCED ];
                    
                    List<Obstacle__c> obstacleList = [Select Id, Name, ObstacleSubject__c, ClientCase__c, ClientActionPlan__c, Goal__c, ObstacleDetails__c, DueDate__c, CompletionDate__c from Obstacle__c 
                                                      where Goal__c IN :goalList WITH SECURITY_ENFORCED];
                    
                    /*List<Solution__c> solutionList = [Select Id, Name, SolutionSubject__c, Status__c, SolutionDetails__c, ClientCase__c, ClientActionPlan__c, Goal__c, Obstacle__c, Obstacle__r.Goal__c,
(Select Id, Status, Subject, ActionType__c, Description, ActivityDate, CompletedDateTime from Activities__r  order by ActivityDate DESC, LastModifiedDate DESC limit 500)
from Solution__c where Obstacle__c IN :obstacleList WITH SECURITY_ENFORCED];*/
                    
                    List<Solution__c> solutionList = [Select Id, Name, SolutionSubject__c, Status__c, SolutionDetails__c, ClientCase__c, ClientActionPlan__c, Goal__c, Obstacle__c, Obstacle__r.Goal__c
                                                      from Solution__c where Obstacle__c IN :obstacleList WITH SECURITY_ENFORCED];
                    
                    List<Task> taskList = [Select Id, Status, Subject, ActionType__c, Description, ActivityDate, CompletedDateTime, Solution__c from Task where Solution__c IN : solutionList];
                    
                    Map<Id, List<Task>> taskBySolution = new Map<Id, List<Task>>();
                    
                    for(Task tsk : taskList){
                        if(!taskBySolution.containsKey(tsk.Solution__c)){
                            taskBySolution.put(tsk.Solution__c, new List<Task>());
                        }
                        taskBySolution.get(tsk.Solution__c).add(tsk);
                    }
                    
                    Map<Id, List<SolutionWrapper>> soultionByObstacle = new Map<Id, List<SolutionWrapper>>();
                    
                    for(Solution__c sol : solutionList){
                        SolutionWrapper solWrap = new SolutionWrapper();
                        
                        if(taskBySolution.containsKey(sol.Id)){
                            
                            //for(LookedUpFromActivity tsk : sol.Activities__r){
                            for(Task tsk : taskBySolution.get(sol.Id)){
                                
                                if(tsk.ActionType__c == 'Client Action'){
                                    solWrap.clientActionId = tsk.Id;
                                    solWrap.clientAction = tsk.Subject;
                                    solWrap.clientActionDetail = tsk.Description;
                                    solWrap.clientActionDueDate = tsk.ActivityDate;
                                    solWrap.clientActionDueDateStr = tsk.ActivityDate != NULL ? tsk.ActivityDate.format() : '';
                                    solWrap.clientActionStatus = String.isBlank(tsk.Status) ? 'Not Started' : tsk.Status;
                                    solWrap.isClientActionCompleted = (String.isNotBlank(tsk.Status) && tsk.Status == 'Completed') ? true : false;
                                    solWrap.clientActionCompletionDate = Date.valueOf(tsk.CompletedDateTime);
                                    solWrap.clientActionCompletionDateStr = tsk.CompletedDateTime != NULL ? Date.valueOf(tsk.CompletedDateTime).format() : '';
                                }
                                
                                if(tsk.ActionType__c == 'Counselor Action'){
                                    solWrap.counselorActionId = tsk.Id;
                                    solWrap.counselorAction = tsk.Subject;
                                    solWrap.counselorActionDetail = tsk.Description;
                                    solWrap.counselorActionDueDate = tsk.ActivityDate;
                                    solWrap.counselorActionDueDateStr = tsk.ActivityDate != NULL ? tsk.ActivityDate.format() : '';
                                    solWrap.counselorActionStatus = String.isBlank(tsk.Status) ? 'Not Started' : tsk.Status;
                                    solWrap.isCounselorActionCompleted = (String.isNotBlank(tsk.Status) && tsk.Status == 'Completed') ? true : false;
                                    solWrap.counselorActionCompletionDate = Date.valueOf(tsk.CompletedDateTime);
                                    solWrap.counselorActionCompletionDateStr = tsk.CompletedDateTime != NULL ? Date.valueOf(tsk.CompletedDateTime).format() : '';
                                }
                            }
                        }
                        
                        solWrap.solutionId = sol.Id;
                        
                        if(solutionOptionsList.contains(sol.SolutionSubject__c)){
                            solWrap.solutionName = sol.SolutionSubject__c;
                            solWrap.solutionOtherName = '';
                            solWrap.showSolutionOtherName = false;
                        } else{
                            solWrap.solutionName = 'Other';
                            solWrap.solutionOtherName = sol.SolutionSubject__c;
                            solWrap.showSolutionOtherName = true;
                        }
                        
                        solWrap.solutionDetail = sol.SolutionDetails__c;
                        solWrap.solutionStatus = String.isBlank(sol.Status__c) ? 'Not Started' : sol.Status__c;
                        solWrap.solExternalId = String.valueOf(Integer.valueof((Math.random() * 1000000)));
                        solWrap.viewModeCollapsed = false;
                        
                        if(!soultionByObstacle.containsKey(sol.Obstacle__c)){
                            soultionByObstacle.put(sol.Obstacle__c, new List<SolutionWrapper>());
                        }
                        soultionByObstacle.get(sol.Obstacle__c).add(solWrap);
                        
                    }
                    
                    Map<Id, List<ObstacleWrapper>> obstacleByGoal = new Map<Id, List<ObstacleWrapper>>();
                    
                    for(Obstacle__c obs : obstacleList){
                        ObstacleWrapper obsWrap = new ObstacleWrapper();
                        obsWrap.obstacleId = obs.Id;
                        
                        if(obstacleOptionsList.contains(obs.ObstacleSubject__c)){
                            obsWrap.obstacleName = obs.ObstacleSubject__c;
                            obsWrap.obstacleOtherName = '';
                            obsWrap.showObstacleOtherName = false;
                        } else{
                            obsWrap.obstacleName = 'Other';
                            obsWrap.obstacleOtherName = obs.ObstacleSubject__c;
                            obsWrap.showObstacleOtherName = true;
                        }
                        
                        
                        obsWrap.obstacleDetail = obs.ObstacleDetails__c;
                        obsWrap.obstacleDueDate = obs.DueDate__c;
                        if(soultionByObstacle.containsKey(obs.Id)){
                            obsWrap.solutionList = soultionByObstacle.get(obs.Id);
                        }else{
                            obsWrap.solutionList = new List<SolutionWrapper>();
                        }
                        obsWrap.viewModeCollapsed = false;
                        obsWrap.showAddSolutionAction = true;
                        obsWrap.obsExternalId = String.valueOf(Integer.valueof((Math.random() * 1000000)));
                        
                        if(!obstacleByGoal.containsKey(obs.Goal__c)){
                            obstacleByGoal.put(obs.Goal__c, new List<ObstacleWrapper>());
                        }
                        
                        obstacleByGoal.get(obs.Goal__c).add(obsWrap);
                    }
                    
                    for(Goal__c goal : goalList){
                        GoalWrapper goalWrap = new GoalWrapper();
                        goalWrap.goalId = goal.Id;
                        
                        goalWrap.clientCaseId = goal.ClientCase__c;
                        goalWrap.actionPlanId = goal.ClientActionPlan__c;
                        
                        if(goalOptionsList.contains(goal.GoalSubject__c)){
                            goalWrap.goalName = goal.GoalSubject__c;
                            goalWrap.goalOtherName = '';
                            goalWrap.showGoalOtherName = false;
                        } else{
                            goalWrap.goalName = 'Other';
                            goalWrap.goalOtherName = goal.GoalSubject__c;
                            goalWrap.showGoalOtherName = true;
                        }
                        
                        goalWrap.goalCompletionDate = goal.CompletionDate__c;
                        goalWrap.goalCompletionDateStr = goal.CompletionDate__c != NULL ? goal.CompletionDate__c.format() : '';
                        goalWrap.goalDetail = goal.GoalDetails__c;
                        goalWrap.goalType = goal.GoalType__c;
                        goalWrap.goalStatus = String.isBlank(goal.Status__c) ? 'Not Started' : goal.Status__c;
                        goalWrap.goalDueDate = goal.DueDate__c;
                        goalWrap.goalDueDateStr = goal.DueDate__c != NULL ? goal.DueDate__c.format() : '';
                        if(obstacleByGoal.containsKey(goal.Id)){
                            goalWrap.obstacleList = obstacleByGoal.get(goal.Id);
                        }else{
                            goalWrap.obstacleList = new List<ObstacleWrapper>();
                        }
                        goalWrap.viewModeCollapsed = true;
                        
                        if(goal.Status__c == 'Not Started'){
                            goalWrap.statusClass = 'slds-badge slds-badge_lightest';
                        } else if(goal.Status__c == 'In Progress'){
                            goalWrap.statusClass = 'slds-badge slds-theme_info';
                        } else if(goal.Status__c == 'Completed'){
                            goalWrap.statusClass = 'slds-badge slds-theme_success';
                            goalWrap.isGoalCompleted = true;
                        }
                        
                        
                        goalWrapperList.add(goalWrap);
                        
                    }
                }
                
                resultWrap.actionPlans = goalWrapperList;
                
            } catch(Exception exe){
                throw new AuraHandledException(exe.getMessage());
            }
        }
        return resultWrap;
    }
    
    /*
@description    this method is used to saving new or updated details for a goal
*/
    @AuraEnabled
    public static void saveGoalsForClientCase(ClientActionPlansController.GoalWrapper inputWrapper){
        if(inputWrapper != NULL){
            try{
                if(//ClientCase__c Access Check
                    Schema.sObjectType.ClientCase__c.isCreateable() && Schema.sObjectType.ClientCase__c.fields.PrimaryClient__c.isCreateable() &&
                    //Goal__c Access Check
                    Schema.sObjectType.Goal__c.isCreateable() && Schema.sObjectType.Goal__c.fields.GoalSubject__c.isCreateable() &&
                    Schema.sObjectType.Goal__c.fields.ClientCase__c.isCreateable() && Schema.sObjectType.Goal__c.fields.GoalDetails__c.isCreateable() &&
                    Schema.sObjectType.Goal__c.fields.GoalType__c.isCreateable() && Schema.sObjectType.Goal__c.fields.Status__c.isCreateable() &&
                    Schema.sObjectType.Goal__c.fields.DueDate__c.isCreateable() && Schema.sObjectType.Goal__c.fields.CompletionDate__c.isCreateable() &&
                    //Obstacle__c Access Check
                    Schema.sObjectType.Obstacle__c.isCreateable() && Schema.sObjectType.Obstacle__c.fields.ObstacleSubject__c.isCreateable() &&
                    Schema.sObjectType.Obstacle__c.fields.ClientCase__c.isCreateable() && Schema.sObjectType.Obstacle__c.fields.ClientActionPlan__c.isCreateable() &&
                    Schema.sObjectType.Obstacle__c.fields.Goal__c.isCreateable() && Schema.sObjectType.Obstacle__c.fields.ObstacleDetails__c.isCreateable() &&
                    Schema.sObjectType.Obstacle__c.fields.DueDate__c.isCreateable() && Schema.sObjectType.Obstacle__c.fields.CompletionDate__c.isCreateable() &&
                    //Solution__c Access Check
                    Schema.sObjectType.Solution__c.isCreateable() && Schema.sObjectType.Solution__c.fields.SolutionSubject__c.isCreateable() &&
                    Schema.sObjectType.Solution__c.fields.ClientCase__c.isCreateable() && Schema.sObjectType.Solution__c.fields.Status__c.isCreateable() &&
                    Schema.sObjectType.Solution__c.fields.SolutionDetails__c.isCreateable() && Schema.sObjectType.Solution__c.fields.ClientActionPlan__c.isCreateable() &&
                    Schema.sObjectType.Solution__c.fields.Goal__c.isCreateable() && Schema.sObjectType.Solution__c.fields.Obstacle__c.isCreateable() &&
                    //Task Access Check
                    Schema.sObjectType.Task.isCreateable() && Schema.sObjectType.Task.fields.Status.isCreateable() &&
                    Schema.sObjectType.Task.fields.Status.isCreateable() &&
                    Schema.sObjectType.Task.fields.Subject.isCreateable() && Schema.sObjectType.Task.fields.ActionType__c.isCreateable() &&
                    Schema.sObjectType.Task.fields.Description.isCreateable() && Schema.sObjectType.Task.fields.ActivityDate.isCreateable())
                {
                    if(String.isBlank(inputWrapper.actionPlanId)){
                        ClientActionPlan__c  cap = new ClientActionPlan__c ();
                        cap.ClientCase__c = inputWrapper.clientCaseId;
                        insert cap;
                        inputWrapper.actionPlanId = cap.Id;
                        
                        ClientCase__c cc = [select id, Action_Plan_Created_Date__c from ClientCase__c where id =: inputWrapper.clientCaseId];
                        cc.Action_Plan_Created_Date__c = Date.today();
                        update cc;
                    }
                    Goal__c goal;
                    
                    if(String.isNotBlank(inputWrapper.goalId)){
                        goal = new Goal__c(Id=inputWrapper.goalId);
                    } else{
                        goal = new Goal__c();
                    }
                    goal.ClientCase__c = inputWrapper.clientCaseId;
                    goal.ClientActionPlan__c = inputWrapper.actionPlanId;
                    goal.GoalType__c = inputWrapper.goalType;
                    goal.Status__c = inputWrapper.goalStatus;
                    goal.GoalDetails__c = inputWrapper.goalDetail;
                    goal.DueDate__c = inputWrapper.goalDueDate;
                    if(inputWrapper.goalName == 'Other'){
                        goal.GoalSubject__c = inputWrapper.goalOtherName;
                    } else{
                        goal.GoalSubject__c = inputWrapper.goalName;
                    }
                    goal.GoalDefaultValues__c = inputWrapper.goalName;
                    
                    upsert goal;
                    
                    inputWrapper.goalId = goal.Id;
                    
                    if(inputWrapper.obstacleList != NULL && inputWrapper.obstacleList.size() > 0){
                        Map<String, Obstacle__c> obstacleByExternalId = new Map<String, Obstacle__c>();
                        
                        Map<String, Solution__c> solutionByExternalId = new Map<String, Solution__c>();
                        
                        List<Task> taskList = new List<Task>();
                        
                        for(ObstacleWrapper wrap : inputWrapper.obstacleList){
                            Obstacle__c obs;
                            
                            if(String.isNotBlank(wrap.obstacleId)){
                                obs = new Obstacle__c(Id=wrap.obstacleId);
                            } else{
                                obs = new Obstacle__c();
                            }
                            
                            obs.Goal__c = goal.Id;
                            obs.ClientCase__c = inputWrapper.clientCaseId;
                            obs.ClientActionPlan__c = inputWrapper.actionPlanId;
                            obs.DueDate__c = wrap.obstacleDueDate;
                            obs.ObstacleDetails__c = wrap.obstacleDetail;
                            if(wrap.obstacleName == 'Other'){
                                obs.ObstacleSubject__c = wrap.obstacleOtherName;
                            } else{
                                obs.ObstacleSubject__c = wrap.obstacleName;
                            }
                            obs.ObstaclesDefaultValues__c = wrap.obstacleName;
                            obstacleByExternalId.put(wrap.obsExternalId, obs);
                        }
                        
                        if(obstacleByExternalId.size() > 0){
                            upsert obstacleByExternalId.values();
                        }
                        
                        if(inputWrapper.obstacleList != NULL && inputWrapper.obstacleList.size() > 0){
                            
                            for(ObstacleWrapper wrap : inputWrapper.obstacleList){
                                if(wrap.solutionList != NULL && wrap.solutionList.size() > 0){
                                    for(SolutionWrapper solWrap : wrap.solutionList){
                                        Solution__c sol;
                                        
                                        if(String.isNotBlank(solWrap.solutionId)){
                                            sol = new Solution__c(Id=solWrap.solutionId);
                                        } else{
                                            sol = new Solution__c();
                                        }
                                        
                                        sol.Obstacle__c = obstacleByExternalId.get(wrap.obsExternalId).Id;
                                        sol.Goal__c = inputWrapper.goalId;
                                        sol.ClientCase__c = inputWrapper.clientCaseId;
                                        sol.ClientActionPlan__c = inputWrapper.actionPlanId;
                                        sol.SolutionDetails__c = solWrap.solutionDetail;
                                        sol.Status__c = solWrap.solutionStatus;
                                        if(solWrap.solutionName == 'Other'){
                                            sol.SolutionSubject__c = solWrap.solutionOtherName;
                                        } else{
                                            sol.SolutionSubject__c = solWrap.solutionName;
                                        }
                                        sol.SolutionDefaultValues__c = solWrap.solutionName;
                                        
                                        solutionByExternalId.put(solWrap.solExternalId, sol);
                                    }
                                }
                                
                            }
                        }
                        
                        if(solutionByExternalId.size() > 0){
                            upsert solutionByExternalId.values();
                        }
                        
                        if(inputWrapper.obstacleList != NULL && inputWrapper.obstacleList.size() > 0){
                            Id taskRecTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('Task').getRecordTypeId();
                            for(ObstacleWrapper wrap : inputWrapper.obstacleList){
                                if(wrap.solutionList != NULL && wrap.solutionList.size() > 0){
                                    for(SolutionWrapper solWrap : wrap.solutionList){
                                        System.debug('solWrap->'+solWrap);
                                        Task clientTsk;
                                        if(String.isNotBlank(solWrap.clientActionId)){
                                            clientTsk = new Task(Id = solWrap.clientActionId);
                                        } else{
                                            clientTsk = new Task();
                                        }
                                        System.debug('solWrap.portalUserId !@ 479 '+solWrap.portalUserId);
                                        clientTsk.Solution__c  = solutionByExternalId.get(solWrap.solExternalId).Id;
                                        clientTsk.WhatId = inputWrapper.clientCaseId; 
                                        clientTsk.Subject = solWrap.clientAction;
                                        clientTsk.Description = solWrap.clientActionDetail;
                                        clientTsk.ActivityDate = solWrap.clientActionDueDate;
                                        clientTsk.ActionType__c = 'Client Action';
                                        clientTsk.Status = solWrap.clientActionStatus;
                                        if (solWrap.portalUserId != null) {
                                            clientTsk.OwnerId = solWrap.portalUserId;
                                        }
                                        clientTsk.RecordTypeId = taskRecTypeId != null ? taskRecTypeId : null;
                                        
                                        taskList.add(clientTsk);
                                        
                                        Task counselorTsk;
                                        if(String.isNotBlank(solWrap.counselorActionId)){
                                            counselorTsk = new Task(Id = solWrap.counselorActionId);
                                        } else{
                                            counselorTsk = new Task();
                                        }
                                        counselorTsk.Solution__c  = solutionByExternalId.get(solWrap.solExternalId).Id;
                                        counselorTsk.WhatId = inputWrapper.clientCaseId;
                                        counselorTsk.Subject = solWrap.counselorAction;
                                        counselorTsk.Description = solWrap.counselorActionDetail;
                                        counselorTsk.ActivityDate = solWrap.counselorActionDueDate;
                                        counselorTsk.ActionType__c = 'Counselor Action';
                                        counselorTsk.Status = solWrap.counselorActionStatus;
                                        counselorTsk.RecordTypeId = taskRecTypeId != null ? taskRecTypeId : null;
                                        
                                        taskList.add(counselorTsk);
                                    }
                                }
                                
                            }
                        }
                        System.debug('taskList->'+taskList);
                        if(taskList.size() > 0){
                            upsert taskList;
                        }
                    }
                }
            } catch(Exception exe){
                throw new AuraHandledException(exe.getMessage());
            }
        }
    }
    
    /*
@description    this method is used to saving new or updated details for a goal
*/
    @AuraEnabled(cacheable=true)
    public static ClientCase__c getClientCase(Id recordId){
        try{
            return [select id,Action_Plan_Created_Date__c from ClientCase__c where id = : recordId];
        }catch(Exception e){
            return null;
        }
    }
    
    /*
@description    wrapper class to return result for Gaol
*/
    public class ClientActionPlanWrapper{
        @AuraEnabled
        public String clientCaseName{get;set;}
        @AuraEnabled
        public String clientName{get;set;}
        @AuraEnabled
        public String portalUserId{get;set;}
        @AuraEnabled
        public String clientCaseNumber{get;set;}
        @AuraEnabled
        public String coAppNames{get;set;}
        @AuraEnabled
        public String actionPlanId{get;set;}
        @AuraEnabled
        public String clientCaseId{get;set;}
        @AuraEnabled
        public String reasonForCounseling {get;set;}
        @AuraEnabled
        public String counselorName  {get;set;}
        @AuraEnabled
        public String counselorEmail {get;set;}
        @AuraEnabled
        public String counselorPhone {get;set;}
        @AuraEnabled
        public List<Referral__c> referrals {get;set;}
        @AuraEnabled
        public List<Utility.PicklistOption> goalOptions{get;set;}
        @AuraEnabled
        public List<Utility.PicklistOption> obstacleOptions{get;set;}
        @AuraEnabled
        public List<Utility.PicklistOption> solutionOptions{get;set;}
        @AuraEnabled
        public List<GoalWrapper> actionPlans{get;set;}
    }
    
    /*
@description    wrapper class to Store details for Goal
*/
    public Class GoalWrapper{
        @AuraEnabled
        public String goalId{get;set;}
        @AuraEnabled
        public String clientCaseId{get;set;}
        @AuraEnabled
        public String actionPlanId{get;set;}
        @AuraEnabled
        public String goalName{get;set;}
        @AuraEnabled
        public String goalOtherName{get;set;}
        @AuraEnabled
        public Boolean showGoalOtherName{get;set;}
        @AuraEnabled
        public String goalDetail{get;set;}
        @AuraEnabled
        public String goalType{get;set;}
        @AuraEnabled
        public String goalStatus{get;set;}
        @AuraEnabled
        public Date goalDueDate{get;set;}
        @AuraEnabled
        public String goalDueDateStr{get;set;}
        @AuraEnabled
        public List<ObstacleWrapper> obstacleList{get;set;}
        @AuraEnabled
        public Boolean viewModeCollapsed{get;set;}
        @AuraEnabled
        public String statusClass{get;set;}
        @AuraEnabled
        public Boolean isGoalCompleted{get;set;}
        @AuraEnabled
        public Date goalCompletionDate{get;set;}
        @AuraEnabled
        public String goalCompletionDateStr{get;set;}
    }
    
    /*
@description    wrapper class to Store details for Obstacle
*/
    public Class ObstacleWrapper{
        @AuraEnabled
        public String obstacleId{get;set;}
        @AuraEnabled
        public String obstacleName{get;set;}
        @AuraEnabled
        public String obstacleOtherName{get;set;}
        @AuraEnabled
        public Boolean showObstacleOtherName{get;set;}
        @AuraEnabled
        public String obstacleDetail{get;set;}
        @AuraEnabled
        public Date obstacleDueDate{get;set;}
        @AuraEnabled
        public List<SolutionWrapper> solutionList{get;set;}
        @AuraEnabled
        public Boolean viewModeCollapsed{get;set;}
        @AuraEnabled
        public Boolean showAddSolutionAction{get;set;}
        @AuraEnabled
        public String obsExternalId{get;set;}
    }
    
    /*
@description    wrapper class to Store details for Solution
*/
    public Class SolutionWrapper{
        @AuraEnabled
        public String solutionId{get;set;}
        @AuraEnabled
        public String solutionName{get;set;}
        @AuraEnabled
        public String solutionOtherName{get;set;}
        @AuraEnabled
        public Boolean showSolutionOtherName{get;set;}
        @AuraEnabled
        public String solutionDetail{get;set;}
        @AuraEnabled
        public String solutionStatus{get;set;}
        @AuraEnabled
        public String solExternalId{get;set;}
        @AuraEnabled
        public Boolean viewModeCollapsed{get;set;}
        @AuraEnabled
        public String clientActionId{get;set;}
        @AuraEnabled
        public String clientAction{get;set;}
        @AuraEnabled
        public String portalUserId{get;set;}
        @AuraEnabled
        public String clientActionDetail{get;set;}
        @AuraEnabled
        public Date clientActionDueDate{get;set;}
        @AuraEnabled
        public String clientActionDueDateStr{get;set;}
        @AuraEnabled
        public String clientActionStatus{get;set;}
        @AuraEnabled
        public Boolean isClientActionCompleted{get;set;}
        @AuraEnabled
        public Date clientActionCompletionDate{get;set;}
        @AuraEnabled
        public String clientActionCompletionDateStr{get;set;}
        @AuraEnabled
        public String counselorActionId{get;set;}
        @AuraEnabled
        public String counselorAction{get;set;}
        @AuraEnabled
        public String counselorActionDetail{get;set;}
        @AuraEnabled
        public Date counselorActionDueDate{get;set;}
        @AuraEnabled
        public String counselorActionDueDateStr{get;set;}
        @AuraEnabled
        public String counselorActionStatus{get;set;}
        @AuraEnabled
        public Boolean isCounselorActionCompleted{get;set;}
        @AuraEnabled
        public Date counselorActionCompletionDate{get;set;}
        @AuraEnabled
        public String counselorActionCompletionDateStr{get;set;}
    }
     /*
@description    wrapper class to Store details for Financial Snapshot
*/
    public class FinancialSnapshotWrapper {
        
        @AuraEnabled
        public String creditScore 					{ get; set; }
        @AuraEnabled
        public String coAppCreditScore 				{ get; set; }
        @AuraEnabled
        public String savings 						{ get; set; }
        @AuraEnabled
        public String grossMonthlyIncome 			{ get; set; }       
        @AuraEnabled
        public String housingExpense 				{ get; set; }
        @AuraEnabled
        public String totalDebt 					{ get; set; }
        @AuraEnabled
        public String totalAssets 					{ get; set; }
        @AuraEnabled
        public String conditionOfProperty			{ get; set; }
        @AuraEnabled
        public String CurrentAmountofJudgment		{ get; set; }
        
        public FinancialSnapshotWrapper(FinancialSnapshot__c snapshot) {
            this.creditScore 					= snapshot.CreditScore__c != null 					? String.valueOf(snapshot.CreditScore__c) 					: 'N/A';
            this.coAppCreditScore 				= snapshot.CurrentMonthlyDebtObligation__c != null 	? String.valueOf(snapshot.CurrentMonthlyDebtObligation__c) 	: 'N/A';
            this.savings 						= snapshot.Savings__c != null 						? String.valueOf(snapshot.Savings__c) 						: 'N/A';
            this.grossMonthlyIncome 			= snapshot.GrossMonthlyIncome__c != null 			? String.valueOf(snapshot.GrossMonthlyIncome__c) 			: 'N/A';
            this.housingExpense 				= snapshot.HousingExpense__c != null 				? String.valueOf(snapshot.HousingExpense__c) 				: 'N/A';
            this.totalDebt 						= snapshot.TotalDebt__c != null 					? String.valueOf(snapshot.TotalDebt__c) 					: 'N/A';
            this.totalAssets 					= snapshot.TotalAssets__c != null 					? String.valueOf(snapshot.TotalAssets__c) 					: 'N/A';
            this.conditionOfProperty 			= 'N/A';
            this.CurrentAmountofJudgment		= 'N/A';
        }
        
    }

    /**
* @description       : Method to check that current logged in user is IntakeStaff or not.
**/
    @AuraEnabled
    public static Boolean isIntakeStaffUser(){
        return FeatureManagement.checkPermission('IntakeStaff');
    }
    
}