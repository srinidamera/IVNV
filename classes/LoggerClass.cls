/* 
* @description    Utility Class providing methods to Log for exception.
*/
global with sharing class LoggerClass {
  global static void log(Exception e,string relatedToId) {
    String stackTrace = e.getStackTraceString().substringBefore('\n');
    String className = stackTrace.substringAfter('.').substringBefore('.'); 
    String methodName = stackTrace.substringBefore(':').substringAfter(className).substringAfter('.');
      
    //Governer Limit of executingQuery 
    String QueryLimit = '1. SOQL Queries used / SOQL Queries allowed: ' + Limits.getQueries() + '/' + Limits.getLimitQueries();
    String DMLimit = '2. Number of records queried so far /  Number allowed: ' + Limits.getDmlRows() + '/' + Limits.getLimitDmlRows();
    String DMLStat = '3. Number of DML statements used so far / Number allowed: ' +  Limits.getDmlStatements() + '/' + Limits.getLimitDmlStatements();   
    String CPUT = '4. Amount of CPU time (in ms) used so far / CPU usage time (in ms) allowed: ' + Limits.getCpuTime() + '/' + Limits.getLimitCpuTime();
    EventLog__e l = new EventLog__e();
    l.RelatedToRecord__c = string.IsNotBlank(relatedToId) ? relatedToId :'';
    l.GovtLimitinExecutingCode__c = String.format('{0}\n{1}\n{2}\n{3}',new List<string>{QueryLimit, DMLimit,DMLStat,CPUT});
    l.ExceptionMessage__c = e.getMessage();
    l.ExceptionType__c = e.getTypeName();
    l.LineNumber__c = e.getLineNumber();
    l.StackTrace__c = e.getStackTraceString();
    l.MethodName__c= string.IsNotBlank(methodName) ? methodName :'';
    l.ClassName__c= string.IsNotBlank(className) ? className :'';
    
    EventBus.publish(l);
  }
}