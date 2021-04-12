@isTest
public class LeadTriggerTest {
    @testSetup
    static void createLeads(){
        Lead updateLead = new Lead(FirstName = 'Test', LastName = 'Test', Company = 'Test Company', Status = 'Open - Not Contacted');
        insert updateLead;
        updateLead.Status = 'Closed - Converted';
        update updateLead;
        
        List<Lead> newLeads = new List<Lead>();
        for(integer i = 1; i <= 100; i++){
            String first = 'lead'+ i;
            String last = 'lead' + i;
            Lead newLead = new Lead(FirstName = first, LastName = last, Company = 'Lead Company', Status = 'Closed - Converted');
            newLeads.add(newLead);
        }
        insert newLeads;
    }
    
    @isTest
    static void addAccountIfConvertedShouldReturnAccountWithSameNAme(){
        Lead newLead = [SELECT name, account__r.name from Lead WHERE status = 'Closed - Converted' LIMIT 1];
        system.assertEquals(newlead.name, newlead.account__r.name);
    }
    
    @isTest
    static void AccountedAddedOnUpdate(){
        Lead afterUpdate = [SELECT name, account__r.name FROM LEAD WHERE name = 'Test Test' LIMIT 1];
        system.assertEquals(afterUpdate.name, afterUpdate.account__r.name );
    }
}