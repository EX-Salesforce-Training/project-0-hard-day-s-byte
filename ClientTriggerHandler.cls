public class ClientTriggerHandler {
    public static void paidFull(List <Client__c> clients){
        //Query for clients in update w/ Paid in Full Checked
        List<Client__c> updateClients = [SELECT id, name FROM Client__c WHERE (iD IN :clients AND Paid_in_Full__c = true )];
        List<Charge__c> updateCharges = new List<Charge__c> ();
        for (Client__c client: updateClients){
            //Find which Paid in Full Clients had charges marked unpaid
            for(Charge__c charge : [SELECT id, client__c FROM Charge__c 
                                    WHERE (client__c =:client.Id AND paid__c = false)]) {
                    charge.paid__c = true;
                	updateCharges.add(charge);
             }
        }
        try{
        database.update(updateCharges, false);
        }
        finally{
            system.debug('Update charges: ' + updateCharges);
        }
    }
   
}