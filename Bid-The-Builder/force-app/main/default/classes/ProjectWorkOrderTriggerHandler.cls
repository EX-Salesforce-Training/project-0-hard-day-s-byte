public class ProjectWorkOrderTriggerHandler {

    private static List<Invoice__c> invoicesToInsert = new List<Invoice__c>();
    private static List<Project_Work_Order__c> ordersToAssignInvoice = new List<Project_Work_Order__c>();

    public static void handleInvoiceTypes(List<Project_Work_Order__c> orders){
        for(Project_Work_Order__c order:orders){
            if(order.Invoice__c == null){
                assignInvoiceByInvoiceType(order);
            }
        }
    }
    
    @TestVisible
    private static void assignInvoiceByInvoiceType(Project_Work_Order__c order){
        switch on order.Invoice_Type__c {
            when 'By Work Order'{
                    attachCorrectInvoice(order);
                    insertNewInvoices(newInvoices);
                    assignInsertedInvoices(ordersToAssignInvoice, newInvoices);
            }
        }
	}
    
    @TestVisible
    private static void attachCorrectInvoice(Project_Work_Order__c order) {
        Invoice__c undeliveredProjectInvoice = getUndeliveredProjectInvoice(order);
        if(undeliveredProjectInvoice != null){
            order.Invoice__c = undeliveredInvoice.id;
        }else{
            newInvoices.add(createNewInvoice(order));
        }
    }

    @TestVisible
    private static void AssignUndeliveredInvoice(Project_Work_Order__c order){
        if(undeliveredInvoice != null){
            order.invoice__c = undeliveredInvoice.id;
        }else{
            order.invoice__c =
        }
    };

    @TestVisible
    private static Invoice__c checkUndeliveredInvoice(List<Invoice__c> projectInvoices){
                for(Invoice__c invoice:projectInvoices){
                    if(isInvoiceNotDelivered(invoice)){
                        return invoice;
                    }
                }
        	return null;
    }
    
    @TestVisible
    private static Invoice__c getUndeliveredProjectInvoice(Project_Work_Order__c order){
       Invoice__c undeliveredInvoice = [SELECT delivered__c 
                    	            FROM Invoice__c 
                        	        WHERE Project__c = :order.Project__c 
                            	    AND recordTypeId = '0125Y000001mOuEQAU' AND delivered__c = false LIMIT 1];
       return undeliveredInvoice;
    }
    
    @TestVisible
    private static Boolean isInvoiceNotDelivered(Invoice__c invoice){
        return invoice.Delivered__c == false;
    }
    
    @TestVisible
	private static Boolean invoiceIsNull(Project_Work_Order__c order){
    	return order.Invoice__c == null;
	}
    
    @TestVisible
   	private static Invoice__c createNewInvoice(Project_Work_Order__c order){
        Project__c project = [SELECT Account__c FROM Project__c WHERE id=:order.Project__c];  
        Invoice__c newInvoice = new Invoice__c(recordTypeId='0125Y000001mOuEQAU', Project__c = order.Project__c, Customer_Account__c = project.Account__c, Total__c = 0.0);
        return newInvoice;
    }

    @TestVisible
    private static void insertNewInvoices(List<Invoice__c> newInvoices){
        insert newInvoices;
        newInvoices.clear();
    }

    @TestVisible
    private static void updateNewInvoices(List<Project_Work_Order__c> newInvoiceOrders, List<Invoice__c> newInvoices){
         for(Integer i = 0; i < newInvoices.size(); i++){
                    newInvoiceOrders[i].Invoice__c = newInvoices[i].Id;
        }
        newInvoiceOrders.clear();
    }
}