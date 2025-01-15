public with sharing class GrantTriggerHandler {
    public static void recomputeGrantFinancing(List<Grant__c> grantList, Boolean fromTrigger){
        
        Set<Id> clientCaseIdSet = new Set<Id>();
        Map<Id,List<Grant__c>> ccToNewGrantMap = new Map<Id,List<Grant__c>>();
        List<Grant__c> grantsToUpdate = new List<Grant__c>();
        
        for(Grant__c grant : grantList){
            clientCaseIdSet.add(grant.ClientCase__c);
            if(ccToNewGrantMap.containskey(grant.ClientCase__c)){
                ccToNewGrantMap.get(grant.ClientCase__c).add(grant);
            } else {
                ccToNewGrantMap.put(grant.ClientCase__c,new List<Grant__c>{grant});
            }
        }
        for(ClientCase__c cc : [Select id, (Select id, FundingAmount__c FROM Grants__r order by FundingAmount__c desc limit 1) from ClientCase__c where id in :clientCaseIdSet]){
            Grant__c highestGrant;
            if(cc.Grants__r != null && cc.Grants__r.size() > 0 && cc.Grants__r[0] != null && cc.Grants__r[0].Id != null){
                highestGrant = cc.Grants__r[0];
            }
            if(highestGrant == null){
                Decimal highestAmt = 0;
                Boolean flag = false;
                for(Grant__c grant : ccToNewGrantMap.get(cc.Id)){
                    if(grant.FundingAmount__c > highestAmt){
                        highestAmt = grant.FundingAmount__c;
                    }
                }
                for(Grant__c grant : ccToNewGrantMap.get(cc.Id)){
                    if((!flag) && grant.FundingAmount__c == highestAmt){
                        grant.FinancingType__c = 'First grant';
                        flag = true;
                    } else {
                        grant.FinancingType__c = 'All other grants';
                    }
                    if(!fromTrigger){
                        grantsToUpdate.add(grant);
                    }
                }
            } else {
                Decimal highestAmt = 0;
                Boolean flag = false;
                for(Grant__c grant : ccToNewGrantMap.get(cc.Id)){
                    if(grant.FundingAmount__c > highestAmt){
                        highestAmt = grant.FundingAmount__c;
                    }
                }
                if(highestAmt > highestGrant.FundingAmount__c){
                    highestGrant.FinancingType__c = 'All other grants';
                    grantsToUpdate.add(highestGrant);
                    for(Grant__c grant : ccToNewGrantMap.get(cc.Id)){
                        if((!flag) && grant.FundingAmount__c == highestAmt){
                            grant.FinancingType__c = 'First grant';
                            flag = true;
                        } else {
                            grant.FinancingType__c = 'All other grants';
                        }
                        if(!fromTrigger){
                            grantsToUpdate.add(grant);
                        }
                    }
                } else {
                    for(Grant__c grant : ccToNewGrantMap.get(cc.Id)){
                        grant.FinancingType__c = 'All other grants';
                        if(!fromTrigger){
                            grantsToUpdate.add(grant);
                        }
                    }
                }
            }
        }
        if(grantsToUpdate.size() > 0){
            Database.update(grantsToUpdate, false);
        }
    }
}