/*
* @description    Trigger to create Log for exception.
*/

trigger EventLogTrigger on EventLog__e(after insert) {
  List<Log__c> logs = new List<Log__c>();
  for (EventLog__e el : Trigger.new) {
    Log__c l = new Log__c();
    l.RelatedToRecord__c = el.RelatedToRecord__c;
    l.RecordLink__c = string.IsNotBlank(el.RelatedToRecord__c) ? '/'+el.RelatedToRecord__c : '';
    l.GovtLimitinExecutingCode__c = el.GovtLimitinExecutingCode__c;
    l.ExceptionMessage__c = el.ExceptionMessage__c;
    l.ExceptionType__c = el.ExceptionType__c;
    l.LineNumber__c = el.LineNumber__c;
    l.StackTrace__c = el.StackTrace__c;
    l.MethodName__c = el.MethodName__c;
    l.ClassName__c = el.ClassName__c;
    logs.add(l);
  }
  Database.insert(logs);
}