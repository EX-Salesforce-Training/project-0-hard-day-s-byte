trigger LessonTrigger on Lesson__c ( before update) {
    //after insert
        switch on trigger.operationType{
            //when AFTER_INSERT{
              //	LessonTriggerHandler.createdChargeOnLesson(trigger.new);      
   // }
            when BEFORE_UPDATE{
                LessonTriggerHandler.updateLessonComplete(trigger.new);
                
            }
    }
    
}