public class LeadTriggerHandler {
    
    private static List<Account> accountsToBeInserted = new List<Account>(); 
    private static List<Lead> leadsToAddAccounts = new List<Lead>();
    
    public static void addAccountIfConverted(List<Lead> leads){
        for(Lead lead:leads){
            if(lead.status == 'Closed - Converted'){
                createProjectClientAccount(lead);
                leadsToAddAccounts.add(lead);
            }
        }
        insert accountsToBeInserted;
        matchAccountsToLeads();
        clearLists();
    }
    
    @TestVisible
    private static void createProjectClientAccount(Lead convertedLead){
        Account newAccount = new Account(recordTypeId ='0125Y000001mOBNQA2', 
                                         name = convertedLead.FirstName + ' ' + convertedLead.LastName, 
                                         AnnualRevenue=convertedLead.AnnualRevenue,
                                         Active__c='Yes', 
                                         Description = convertedLead.Description,
                                         NumberOfEmployees = convertedLead.NumberOfEmployees,
                                         Fax = convertedLead.Fax, 
                                         Industry = convertedLead.Industry, 
                                         NumberofLocations__c = convertedLead.NumberofLocations__c, 
                                         Phone = convertedLead.Phone, 
                                         Type = 'Project Client- Potential', 
                                         Website = convertedLead.Website);
        accountsToBeInserted.add(newAccount);
        
    }
    
    @TestVisible
    private static void matchAccountsToLeads(){
        for(Integer i = 0; i < accountsToBeInserted.size(); i++){
            leadsToAddAccounts[i].Account__c = accountsToBeInserted[i].id;
        }
    }
    
    @TestVisible
    private static void clearLists(){
        leadsToAddAccounts.clear();
        accountsToBeInserted.clear();
    }
}