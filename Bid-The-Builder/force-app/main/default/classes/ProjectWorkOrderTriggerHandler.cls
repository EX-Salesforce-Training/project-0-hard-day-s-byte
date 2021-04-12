public class ProjectWorkOrderTriggerHandler {
	
    // Create static lists to reference throughout for Insert Queries.
    private static List<Invoice__c> invoicesToInsert = new List<Invoice__c>();
    private static List<Project_Work_Order__c> ordersToAssignInvoice = new List<Project_Work_Order__c>();

    //check for Invoice in list of triggered Project Work Orders. 
    public static void handleInvoiceTypesByOrder(List<Project_Work_Order__c> orders){
        for(Project_Work_Order__c order:orders){
            if(order.Invoice__c == null){
                assignInvoiceByInvoiceType(order);
            }
        }
        //clear static lists
        clearLists();
    }
    
    //Switch to add later functionality to other Invoice Types if necessary
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
    
    //Check for any undelivered Invoices in Project and assign to Project Work Order or create a new Invoice.
    @TestVisible
    private static void attachCorrectInvoice(Project_Work_Order__c order) {
        Invoice__c undeliveredProjectInvoice = getUndeliveredProjectInvoice(order);
        if(undeliveredProjectInvoice != null){
            order.Invoice__c = undeliveredProjectInvoice.id;
        }else{
            //add newly created Invoices to static list for insertion.
            invoicesToInsert.add(createNewInvoice(order));
            //add order to list for reference after invoices are inserted.
            ordersToAssignInvoice.add(order);
        }
    }
    
    //Return a single invoice if undelivered, else return null on QueryException and addError on DMLException
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
        }catch(DMLException e){
            order.addError('Object couldn\'t be added at this time');
            Invoice__c errorInvoice = new Invoice__c();
            return errorInvoice;
        } 
    }
    
    //return invoice for insertion
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