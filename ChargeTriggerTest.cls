@isTest
public class ChargeTriggerTest {
    
    //Test Positive Insert Charge 
    @istest
    static void LessonInsert(){
        UtilityTestData.createClient();
        Client__c c = [SELECT id FROM Client__c LIMIT 1];
        Charge__c charge = new Charge__c();
        charge.Name = 'Kiaran Python- 5';
        charge.Client__c = c.id;
        charge.Number_Courses__c = 1;
        Database.SaveResult sr = Database.insert(charge, false);
        integer numLessons;
        if(sr.isSuccess()){
            List <Lesson__c> lesson = [SELECT id, name FROM Lesson__c WHERE name = :charge.name];
            numLessons = lesson.size();
        }
        system.assertEquals(charge.Number_Courses__c, (Decimal)numLessons);
    }
 
    


     /**
     @istest
    static void LessonInsertBulk(){
        List <Charge__c> charges = UtilityTestData.createChargeBulk(100, 'returnList');
        //Charge__c charges = [SELECT id FROM Charge__c];
        //system.debug(charges);
        Database.SaveResult sr = Database.insert(charges, false);
        integer numLessons;
           List <Lesson__c> lesson = [SELECT id, name FROM Lesson__c WHERE name LIKE 'Test%'];
            numLessons = lesson.size();
             system.debug('CHARGE TRIGGER list of lessons ' + lesson);
        
       system.debug(numLessons);
        
        system.assertEquals(100, numLessons);
    }**/
   
    }