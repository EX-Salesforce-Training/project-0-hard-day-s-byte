public class ProjectWorkOrderTriggerHandler {
    
    public static void ValidateInvoiceType(List<Project_Work_Order__c> orders){
        for(Project_Work_Order__c order:orders){
            updateByInvoiceType(order);
        }
    }
    
    @TestVisible
    private static void updateByInvoiceType(Project_Work_Order__c order){
        switch on order.Invoice_Type__c {
            when 'By Work Order'{
                List<Invoice__c> newInvoices = new List<Invoice__c>();
                List<Project_Work_Order__c> NewInvoiceOrders = new List<Project_Work_Order__c>();

                if(invoiceIsNull(order)){
                    List <Invoice__c> projectInvoices = getProjectInvoices(order);
                   	Invoice__c undeliveredInvoice = checkUndeliveredInvoice(projectInvoices);
                    if(undeliveredInvoice == null){
                        NewInvoiceOrders.add(order);
                        newInvoices.add(createNewInvoice(order));
                    }
                    else{
                        order.Invoice__c = undeliveredInvoice.id;
                    }
                }
                insert newInvoices;
                for(Integer i = 0; i < newInvoices.size(); i++){
                    newInvoiceOrders[i].Invoice__c = newInvoices[i].Id;
                }
            }
            when 'Installation'{
                
            }
        }
	}
    
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
    private static List<Invoice__c> getProjectInvoices(Project_Work_Order__c order){
       List<Invoice__c> invoiceList = [SELECT recordTypeId, delivered__c 
                    	                            FROM Invoice__c 
                        	                        WHERE Project__c=:order.Project__c 
                            	                    AND recordTypeId='0125Y000001mOuEQAU'];
       return invoiceList;
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
   	private static Invoice__c createNewInvoice(Project_Work_Order__C order){
        Project__c project = [SELECT Account__c FROM Project__C WHERE id=:order.Project__c];  
        Invoice__c newInvoice = new Invoice__c(recordTypeId='0125Y000001mOuEQAU', Project__C = order.Project__c, Customer_Account__C = project.Account__c, Total__c = 0.0);
        return newInvoice;
    }
}