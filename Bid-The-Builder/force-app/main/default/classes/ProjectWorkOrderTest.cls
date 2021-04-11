@isTest
private class ProjectWorkOrderTest {
    @testSetup
    static void createOrder(){
        Project__c newProject = new Project__c(name='TestHouse', work_type__c = 'Concrete', address__c = '123 Boulevard Lane');
        insert newProject;
        Project_Work_Order__c newOrder = new Project_Work_Order__c(Project__c = newProject.Id, Invoice_Type__c = 'By Work Order');
        insert newOrder;
    }
    
    @isTest
    static void handleInvoiceTypesByOrderShouldUpdateSingleOrder(){
        Project_Work_Order__c newOrder = [SELECT Invoice__c FROM Project_Work_Order__c LIMIT 1];
        system.assert(newOrder.Invoice__c != null);
    }
    
    @isTest
    static void newInvoiceShouldBeRightRecordType(){
        Invoice__c newInvoice = [SELECT recordTypeId FROM Invoice__c LIMIT 1];
        system.assert(newInvoice.recordTypeId == '0125Y000001mOuEQAU');
    }
}