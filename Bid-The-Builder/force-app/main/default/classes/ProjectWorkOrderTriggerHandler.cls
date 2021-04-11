public class ProjectWorkOrderTriggerHandler {

    private static List<Invoice__c> invoicesToInsert = new List<Invoice__c>();
    private static List<Project_Work_Order__c> ordersToAssignInvoice = new List<Project_Work_Order__c>();

    public static void handleInvoiceTypesByOrder(List<Project_Work_Order__c> orders){
        for(Project_Work_Order__c order:orders){
            if(order.Invoice__c == null){
                assignInvoiceByInvoiceType(order);
            }
        }
        clearLists();
    }
    
    @TestVisible
    private static void assignInvoiceByInvoiceType(Project_Work_Order__c order){
        switch on order.Invoice_Type__c {
            when 'By Work Order'{
                    attachCorrectInvoice(order);
                    insertNewInvoices();
                    assignInsertedInvoices();
            }
        }
	}
    
    @TestVisible
    private static void attachCorrectInvoice(Project_Work_Order__c order) {
        Invoice__c undeliveredProjectInvoice = getUndeliveredProjectInvoice(order);
        if(undeliveredProjectInvoice != null){
            order.Invoice__c = undeliveredProjectInvoice.id;
        }else{
            invoicesToInsert.add(createNewInvoice(order));
            ordersToAssignInvoice.add(order);
        }
    }
    
    @TestVisible
    private static Invoice__c getUndeliveredProjectInvoice(Project_Work_Order__c order){
        try{
       		Invoice__c undeliveredInvoice = [SELECT delivered__c 
                    	            FROM Invoice__c 
                        	        WHERE Project__c = :order.Project__c 
                            	    AND recordTypeId = '0125Y000001mOuEQAU' AND delivered__c = false LIMIT 1];
            return undeliveredInvoice;
        }catch(QueryException e){
            Invoice__c nullInvoice = null;
            return nullInvoice;
        }
       
    }
    
    @TestVisible
   	private static Invoice__c createNewInvoice(Project_Work_Order__c order){
        Project__c project = [SELECT Account__c FROM Project__c WHERE id=:order.Project__c];  
        Invoice__c newInvoice = new Invoice__c(recordTypeId='0125Y000001mOuEQAU', Project__c = order.Project__c, Customer_Account__c = project.Account__c, Total__c = 0.0);
        return newInvoice;
    }

    @TestVisible
    private static void insertNewInvoices(){
        insert invoicesToInsert;
    }

    @TestVisible
    private static void assignInsertedInvoices(){
         for(Integer i = 0; i < invoicesToInsert.size(); i++){
                    ordersToAssignInvoice[i].Invoice__c = invoicesToInsert[i].Id;
        }
    }

    @TestVisible
    private static void clearLists(){
        invoicesToInsert.clear();
        ordersToAssignInvoice.clear();
    }
}