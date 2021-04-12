@isTest
public class LessonTriggerTest {
    //Test Singular
    @isTest static void testUpdatePSR(){
    List <Lesson__c> lesson = UtilityTestData.createLessons(1);
    for (Lesson__c c: lesson){
        c.Post_Session_Report__c = 'Populating Post Session Report Field';
        Database.SaveResult sr = Database.update(c, false);
        system.debug('save result '+ sr);
        system.debug('lesson ' + c);
        if (sr.isSuccess()){
          Lesson__c updatedLesson = [SELECT id,Post_Session_Report__c,Status__c FROM Lesson__c WHERE id = :c.id ];
            system.debug(updatedLesson);
          system.assertEquals('Completed', updatedLesson.Status__c, 'PSR was not updated');
        }  
    }     
        
    }
    //Test Bulk 
    @isTest static void testUpdatePSRBulk(){
    List <Lesson__c> lesson = UtilityTestData.createLessons(100);
    for (Lesson__c c: lesson){
        c.Post_Session_Report__c = 'Populating Post Session Report Field';
        Database.SaveResult sr = Database.update(c, false);
        system.debug('save result '+ sr);
        system.debug('lesson ' + c);
        if (sr.isSuccess()){
          Lesson__c updatedLesson = [SELECT id,Post_Session_Report__c,Status__c FROM Lesson__c WHERE id = :c.id ];
            system.debug(updatedLesson);
          system.assertEquals('Completed', updatedLesson.Status__c, 'PSR was not updated');
        } 
    } 
    }
     @isTest 
    static void noPSR(){
        Lesson__c newLesson = new Lesson__c();
        newLesson.status__c = 'Pending';
        newLesson.name = 'Python Lesson';
        Database.SaveResult res = Database.insert(newLesson, false);
        Id acctId = res.getId();
        newLesson.status__c = 'Scheduled';
        Database.SaveResult sr = Database.update(newLesson);
        if( sr.isSuccess()){
        system.assertEquals(NULL,newLesson.Post_Session_Report__c );
            }
        
        
      
          
        
    }
    

}
