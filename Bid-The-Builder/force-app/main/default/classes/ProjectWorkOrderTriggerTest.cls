@isTest
private class ProjectWorkOrderTriggerTest {
    
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
    	
        for(Integer i = 0; i < 150; i++){
            Project__c newProject3 = new Project__c(name='BulkTestHouse' + i, work_type__c = 'Concrete', address__c = '123 Boulevard Lane');
            projectList.add(newProject3);
        }
        
        insert projectList;
        
        Invoice__c newInvoice = new Invoice__c(recordTypeId='0125Y000001mOuEQAU', Project__c = newProject2.id, Customer_Account__c = newProject2.Account__c, Total__c = 0.0);
    	invoiceList.add(newInvoice);
        
        for(Integer i = 0; i < 150; i++){
            List<id> invoiceTypes = new List<id>{Schema.SObjectType.Invoice__c.getRecordTypeInfosByName().get('Work Order Invoice').getRecordTypeId(), Schema.SObjectType.Invoice__c.getRecordTypeInfosByName().get('Installment Invoice').getRecordTypeId()};
            Project__c invoiceProject = projectList[Math.round(Math.random()*149)];
            Invoice__c newBulkInvoice = new Invoice__c(recordTypeId=invoiceTypes[Math.round(Math.random())], Project__c = invoiceProject.id, Customer_Account__c = invoiceProject.Account__c, Total__c = 0.0);
        	invoiceList.add(newBulkInvoice);
        }
        
        insert invoiceList;
        
        Project_Work_Order__c newOrder2 = new Project_Work_Order__c(Project__c = newProject2.id, Invoice_Type__c = 'By Work Order');
    	orderList.add(newOrder2);
        
        Project_Work_Order__c newOrder = new Project_Work_Order__c(Project__c = newProject.id, Invoice_Type__c = 'By Work Order');
        orderList.add(newOrder);
        
        for(Integer i = 0; i < 150; i++){
            List<String> invoiceTypes = new List<String>{'By Work Order', 'Installation'};
            Project__c orderProject = projectList[Math.round(Math.random()*150)];
            Project_Work_Order__c newBulkOrder = new Project_Work_Order__c(Invoice_Type__c=invoiceTypes[Math.round(Math.random())], Project__c = orderProject.id);
        	orderList.add(newBulkOrder);
        }
        
        insert orderList;
    }
    
    //Single Tests
    @isTest
    static void handleInvoiceTypesByOrderShouldCreateInvoice(){
        Project_Work_Order__c noInvoiceOrder = [SELECT id, Invoice__c FROM Project_Work_Order__c Where Project__r.Name = 'TestHouse' LIMIT 1];
        Invoice__c addedInvoice = [SELECT id, recordTypeId FROM Invoice__c Where Project__r.Name = 'TestHouse'];
        Id recordTypeId =  Schema.SObjectType.Invoice__c.getRecordTypeInfosByName().get('Work Order Invoice').getRecordTypeId();
        system.assert(noInvoiceOrder.Invoice__c != null);
        system.assertEquals(addedInvoice.recordTypeId, recordTypeId);
    }
    
    @isTest
    static void handleInvoiceTypesByOrderShouldAddCorrectInvoice(){
        Project_Work_Order__c addedInvoiceOrder = [SELECT id, Invoice__c FROM Project_Work_Order__c Where Project__r.Name = 'TestHouse2' LIMIT 1];
        Invoice__c addedInvoice = [SELECT id, recordTypeId FROM Invoice__c Where Project__r.Name = 'TestHouse2'];
        Id recordTypeId =  Schema.SObjectType.Invoice__c.getRecordTypeInfosByName().get('Work Order Invoice').getRecordTypeId();
        system.assert(addedInvoiceOrder.Invoice__c == addedInvoice.id);
        system.assertEquals(addedInvoice.recordTypeId, recordTypeId);
    }
    
    //Bulk Tests
    @isTest
    static void handleInvoiceTypesByOrderShouldhandleBulk(){
        List<Project_Work_Order__c> BulkOrders = [SELECT Invoice__c, Project__c, Invoice_Type__c FROM Project_Work_Order__c WHERE Project__r.Name Like 'BulkTestHouse%'];
        system.assertEquals(150, BulkOrders.size());
    }
   
}