@isTest
public class ClientTriggerTest {
    @isTest 
    static void SingleTest(){
        Client__c client = UtilityTestData.createClient();
        UtilityTestData.createCharge(client);
        client.Paid_in_Full__c = true;
        Database.SaveResult sr = Database.update(client, false);
        if(sr.isSuccess()){
            Charge__c charge = [SELECT paid__c FROM Charge__c WHERE client__c = :client.id];
            system.debug('charge ' + charge);
            system.debug('paid '+ charge.Paid__c);
            system.assertEquals(true, charge.Paid__c);
        }
        
    }

}