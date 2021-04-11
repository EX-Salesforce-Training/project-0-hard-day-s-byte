public class ChargeTriggerHandler {
  
    public static void createLessonFromCharge(List <Charge__c> charges){
        system.debug('Charges: '+ charges);
        List <Lesson__c> addLesson = new List<Lesson__c>();
        for(Charge__c charge: charges){
            
            for(integer i=0; i<charge.Number_Courses__c;i++){
            Lesson__c newLesson = GenerateLesson(charge);
            system.debug('Generated Lesson: ' + newLesson);
            addLesson.add(newLesson);
            }
            
        }
        try{
        system.debug(addLesson);
        database.insert(addLesson);
		//updateClientPay(charges);
        }
        finally{
            
        }
       /** catch(Exception e){
            system.debug(e.getMessage() + ' '+ e.getCause());
            
        }**/
    }
  
    public static void updateClientPay (List <Charge__c> charges){
        List<Client__c> updateClients = new List <Client__c>();
        for(Charge__c charge: charges){
             if(charge.paid__c ==false){
                Client__c client = [SELECT id, Paid_in_Full__c FROM Client__c WHERE id = :charge.client__c LIMIT 1];
                client.Paid_in_Full__c = false;
                updateClients.add(client);
            }
        }
       database.update(updateClients); 
    }
    
    private static Lesson__c GenerateLesson(Charge__c charge){
        Lesson__c newLesson = new Lesson__c();
            newLesson.name = charge.name;
            newLesson.student__c= charge.student__c;
            newLesson.status__c = 'Pending';
            newLesson.subject__c = 'Unassigned';
        return newLesson;
        
    }
    

}