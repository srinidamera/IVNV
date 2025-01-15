/*
  @author         Munna Jaiswal
  @description    Test class for LoggerClass
  @date           2024-01-23
  @group          File Upload List
*/
@IsTest
public class LoggerClassTest {
    @IsTest
    private static void LogTest(){
        List<Log__c> logList;
        try {
          Integer i = 12 / 0;
        }catch (Exception e) {
          LoggerClass.log(e,'');
        }
    }
}