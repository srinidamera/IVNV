public class AccountTriggerHandler {
	public static List<Account> populateUniqueClientId(List<Account> accList){
        Set<String> uniqueValuesSet = new Set<String>();
        String uniqueId;
        Boolean isUnique = false;
        while(!isUnique){
            while(uniqueValuesSet.size() < accList.size()){
                uniqueValuesSet.add(Utility.getNewUniqueId());
            }
            List<Account> accListDump = checkDuplicacy(uniqueValuesSet); 
            if(accListDump.size() > 0){
                uniqueValuesSet = new Set<String>();
            } else {
                isUnique = true;
            }
        }
        Integer index = 0;
        List<String> uniqueValuesList = new List<String>(uniqueValuesSet);
        for(Account acc : accList){
            acc.ClientNumber__c = uniqueValuesList[index];
            index++;
        }
        if(!Trigger.isExecuting){
            Database.update(accList,false);
        }
        return accList;
    }
    
    private static List<Account> checkDuplicacy(Set<String> uniqueValuesSet){
        return new List<Account>([Select id from Account where ClientNumber__c in: uniqueValuesSet limit 1]);
    }
	
	
}