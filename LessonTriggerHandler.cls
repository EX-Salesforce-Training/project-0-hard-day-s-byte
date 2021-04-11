public class LessonTriggerHandler {

    /**public static void createdChargeOnLesson(List<Lesson__c>lessons){
        List <Charge__c> addCharges = new List <Charge__c>();
        for(Lesson__c lesson: lessons){
        student__c student = [SELECT id, client__c,name FROM Student__c WHERE id = :lesson.student__c LIMIT 1];
        //Create Charge
        system.debug(student);
        system.debug(lesson);
          Charge__c newCharge = new Charge__c();
            newCharge.Name = lesson.Name;
            newCharge.client__c = student.client__c;
       		newCharge.Number_Courses__c =1;
        	newCharge.Student__c = student.id;
           addCharges.add(newCharge);
        }
       // system.debug(newCharge);
       // system.debug(lesson.student__r.client__c);
        try{
        database.insert(addCharges);
        }
        catch(DMLException e){ System.debug(e.getMessage( ) + ' '+ e.getCause());}
    
    }
    **/
    public static void updateLessonComplete(List<Lesson__c>lessons){
        for (Lesson__c lesson : lessons){
            if(String.isBlank(lesson.post_session_report__c) == false){
                lesson.status__c = 'Completed';
            }
        }   
    }
    
    
}