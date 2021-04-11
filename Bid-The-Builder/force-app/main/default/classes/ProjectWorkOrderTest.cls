@isTest
private class ProjectWorkOrderTest {
    
   	@isTest
   	static void InvoiceIsNullShouldReturnTrue(){
        Project_Work_Order__c newOrder = new Project_Work_Order__c();
        system.assertEquals(true, ProjectWorkOrderTriggerHandler.invoiceIsNull(newOrder));
    }
    @isTest
   	static void InvoiceIsNullShouldReturnFalse(){
        Project__c newProject = new Project__c(name='TestHouse', work_type__c = 'Concrete', address__c = '123 Boulevard Lane');
        insert newProject;
        Project_Work_Order__c newOrder = new Project_Work_Order__c(Project__c = newProject.id, Invoice_Type__c = 'By Work Order');
        Invoice__c newInvoice = new Invoice__c(recordTypeId='0125Y000001mOuEQAU', Project__C = newOrder.Project__c, Total__c = 0.0);
        insert newInvoice;
        newOrder.invoice__c = newInvoice.id;
        system.assertEquals(false, ProjectWorkOrderTriggerHandler.invoiceIsNull(newOrder));
    }
    
    @isTest
    static void isInvoiceNotDeliveredShouldReturnTrue(){
        Invoice__c newInvoice = new Invoice__c(Delivered__c = true);
        ProjectWorkOrderTriggerHandler.isInvoiceNotDelivered(newInvoice);
    }
    
    @isTest
    static void isInvoiceNotDeliveredShouldReturnFalse(){
        Invoice__c newInvoice = new Invoice__c(Delivered__c = false);
        ProjectWorkOrderTriggerHandler.isInvoiceNotDelivered(newInvoice);
    }
    
    @isTest
    static void CheckUndeliveredInvoiceShouldReturnUndeliveredInvoice(){
        List<Invoice__c> projectInvoices = new List<Invoice__C>();
        for(Integer i = 0;  i<50; i++){
            Invoice__c newInvoice = new Invoice__c();
            if(i == 25){
                newInvoice.Delivered__c = false;
            }else{
                newInvoice.Delivered__c = true;
            }
            projectInvoices.add(newInvoice);
        }
        system.assertEquals(false, ProjectWorkOrderTriggerHandler.checkUndeliveredInvoice(projectInvoices).Delivered__c);
    }
    
    @testSetup
    static void createOrder(){
        Project__c newProject = new Project__c(name='TestHouse', work_type__c = 'Concrete', address__c = '123 Boulevard Lane');
        insert newProject;
        Project_Work_Order__c newOrder = new Project_Work_Order__c(Project__c = newProject.Id, Invoice_Type__c = 'By Work Order');
        insert newOrder;
    }
}