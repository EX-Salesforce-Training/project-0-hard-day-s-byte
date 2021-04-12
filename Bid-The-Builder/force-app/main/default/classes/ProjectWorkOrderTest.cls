@isTest
private class ProjectWorkOrderTest {
    
    //Set up two different types of orders and 
    @testSetup
    static void createOrder(){
        List<Project__c> projectList = new List<Project__c>();
        List<Invoice__c> invoiceList = new List<Invoice__c>();
        List<Project_Work_Order__c> orderList = new List<Project_Work_Order__c>();
        
        Project__c newProject = new Project__c(name='TestHouse', work_type__c = 'Concrete', address__c = '123 Boulevard Lane');
        projectList.add(newProject);
        
 		Project__c newProject2 = new Project__c(name='TestHouse2', work_type__c = 'Concrete', address__c = '123 Boulevard Lane');
        projectList.add(newProject2);
    	
        insert projectList;
        
        Invoice__c newInvoice = new Invoice__c(recordTypeId='0125Y000001mOuEQAU', Project__c = newProject2.id, Customer_Account__c = newProject2.Account__c, Total__c = 0.0);
    	invoiceList.add(newInvoice);
        
        insert invoiceList;
        
        Project_Work_Order__c newOrder2 = new Project_Work_Order__c(Project__c = newProject2.id, Invoice_Type__c = 'By Work Order');
    	orderList.add(newOrder2);
        
        Project_Work_Order__c newOrder = new Project_Work_Order__c(Project__c = newProject.id, Invoice_Type__c = 'By Work Order');
        orderList.add(newOrder);
        
        insert orderList;
    }
    
    @isTest
    static void handleInvoiceTypesByOrderShouldUpdateSingleOrder(){
        Project_Work_Order__c newOrder = [SELECT Invoice__c FROM Project_Work_Order__c WHERE Project__r.name = 'TestHouse' LIMIT 1];
        system.assert(newOrder.Invoice__c != null);
    }
    
    @isTest
    static void newInvoiceShouldBeRightRecordType(){
        Invoice__c newInvoice = [SELECT recordTypeId FROM Invoice__c WHERE Project__r.name = 'TestHouse' LIMIT 1];
        system.assert(newInvoice.recordTypeId == '0125Y000001mOuEQAU');
    }
    
    @isTest
    static void oldInvoiceShouldBeAddedIfPresent(){
        Project_Work_Order__c newOrder = [SELECT Invoice__c FROM Project_Work_Order__c WHERE Project__r.name = 'TestHouse2' LIMIT 1];
    }
}