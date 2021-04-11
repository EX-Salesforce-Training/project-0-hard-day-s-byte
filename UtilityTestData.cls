@isTest
public class UtilityTestData {
    @testVisible
    public static List<Lesson__c> createLessons(integer numLessons){
        List <Lesson__c> newLessons= new List <Lesson__c>();
        for(integer i =0; i<numLessons; i++){
            Lesson__c newLesson = new Lesson__c();
            newLesson.name = 'Lesson ' +i;
            newLesson.Subject__c = 'Python';
            newLesson.Status__c = 'Pending';
            newLessons.add(newLesson);  
        }
        insert newLessons;
        return newLessons;
    }
    
    
    @testVisible
    public static Client__c createClient(){
        Client__c client = new Client__c(name = 'Christine', Client_Email__c = 'christine@ida.com',Paid_in_Full__c = false);
        insert client;
        return client;
    }
  @testVisible
    public static void createClientBulk(integer num){
        List <Client__c> newClients = new List <Client__c>();
        for ( integer i = 0; i< num; i++){
            Client__c client = new Client__c();
            client.name = 'Test '+i;
            client.Paid_in_Full__c = false;
            newClients.add(client);
        }
        database.insert(newClients,false);

    }
    @testVisible
    public static List<Client__c> createClientBulk(integer num, String returnList){
        List <Client__c> newClients = new List <Client__c>();
        for ( integer i = 0; i< num; i++){
            Client__c client = new Client__c();
            client.name = 'Test '+i;
            newClients.add(client);
        }
        database.insert(newClients,false);
        return newClients;
        
    }

    @testVisible
    public static void createCharge(){
        Client__c c = [SELECT id FROM Client__c LIMIT 1];
        Charge__c charge = new Charge__c();
        charge.Name = 'Kiaran Python -5';
        charge.Client__c = c.id;
        charge.Number_Courses__c = 1;
        insert charge;
        
    }
    @testVisible
    public static Charge__c createCharge(Client__c c){
        Charge__c charge = new Charge__c();
        charge.Name = 'Kiaran Python -5';
        charge.Client__c = c.id;
        charge.Number_Courses__c = 1;
        insert charge;
        return charge;
        
    }
    @testVisible
     public static void createChargeBulk(integer num){
        List <Charge__c> newCharges = new List <Charge__c>();
        List <Client__c> clients = createClientBulk(num, 'returnList');
         integer i = 0;
        for ( Client__c client: clients){
            if(i<num){
            Charge__c charge = new Charge__c();
            charge.name = 'Test '+ i;
            charge.Client__c = client.id;
            charge.Number_Courses__c = 1;
            newCharges.add(charge);
            i++;
            }
            else{
                break;
            }
        }
         //return newCharges;
        database.insert(newCharges,false); 
    }
    @testVisible
     public static List<Charge__c> createChargeBulk(integer num, String returnList){
       List <Charge__c> newCharges = new List <Charge__c>();
        List <Client__c> clients = createClientBulk(num, 'returnList');
         integer i = 0;
        for ( Client__c client: clients){
            if (i<num){
            Charge__c charge = new Charge__c();
            charge.name = 'Test '+ i;
            charge.Client__c = client.id;
            charge.Number_Courses__c = 1;
            newCharges.add(charge);
            i++;
            }
            else{
                break;
            }
        }
         return newCharges;
    }
}