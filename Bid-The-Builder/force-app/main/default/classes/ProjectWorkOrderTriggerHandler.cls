///////////////////////////////////////////////////////////////
//
// Name: ProjectWorkOrderTriggerHandler
// Author: Josh Miccolo
// Created: 04/6/2021
// Updated: 04/12/2021
// Description: Handler to for Project Work Order Trigger. Finds
// undelivered invoices for Projects and adds them to the Work Order or makes
// new invoices for the Projects 
//
///////////////////////////////////////////////////////////////
public class ProjectWorkOrderTriggerHandler {

    //check for Invoice in list of triggered Project Work Orders. 
    public static void handleInvoiceTypesByOrder(List<Project_Work_Order__c> orders){
        
        //find orders with null Invoices
        //find 'By Work Order" Invoice Type orders
        //find undelivered invoices in projects through orders
        //assign orders to undelivered invoices
        //create new invoices for projects without undelivered invoices
        //insert list of invoices
        //update invoices in orders       
        
        List<Project_Work_Order__c> nullInvoiceWorkOrders = checkForNull(orders);
        List<Project_Work_Order__c> WorkOrderTypeOrders = checkInvoiceType(nullInvoiceWorkOrders);
        Map<Id, List<Project_Work_Order__c>> ProjectsMappedToOrders = MapProjectToOrders(WorkOrderTypeOrders);
        Map<Id, List<Project_Work_Order__C>> ProjectsToCreateInvoice = MapWorkOrdersToUndeliveredInvoice(ProjectsMappedToOrders);
        List<Invoice__c> InvoicesToInsert = createNewInvoices(ProjectsToCreateInvoice);
        insert InvoicesToInsert;
        updateNewInvoices(ProjectsToCreateInvoice, InvoicesToInsert);
    }
    
    @TestVisible
    private static List<Project_Work_Order__c> checkForNull(List<Project_Work_Order__c> orders){
        
        List<Project_Work_Order__c> nullInvoices = new List<Project_Work_Order__C>();
        
        for(Project_Work_Order__c order:orders){
            if(order.Invoice__c == null){
                nullInvoices.add(order);
            }
        }
        
        return nullInvoices;
    }
    
    @TestVisible
    private static List<Project_Work_Order__c> checkInvoiceType(List<Project_Work_Order__c> orders){
       	List<Project_Work_Order__c> orderByInvoiceTypes = new List<Project_Work_Order__c>();
        for(Project_Work_Order__c order:orders){
            if(order.Invoice_Type__c == 'By Work Order'){
                orderByInvoiceTypes.add(order);
            }
        }
        return orderByInvoiceTypes;
    }
    
    @TestVisible
    private static Map<Id, List<Project_Work_Order__c>> MapProjectToOrders(List<Project_Work_Order__c> orders){
        Map<Id, List<Project_Work_Order__c>> mappedOrders = new Map<Id, List<Project_Work_Order__c>>();
        for(Project_Work_Order__c order:orders){
            if(mappedOrders.containsKey(order.Project__c)){
                List<Project_Work_Order__c> ProjectMappedOrders = mappedOrders.get(order.Project__c);
                ProjectMappedOrders.add(order);
            }else{
                mappedOrders.put(order.Project__c, new List<Project_Work_Order__c>{order});
            }
        }	
        return mappedOrders;
    }
    
    @TestVisible
    private static Map<Id, List<Project_Work_Order__c>> MapWorkOrdersToUndeliveredInvoice(Map<Id, list<Project_Work_Order__c>> ordersByProject){
        List<Invoice__C> undeliveredInvoices = [SELECT id, name, Project__c FROM Invoice__c Where Project__c IN :ordersByProject.keySet() AND Delivered__c = false AND RecordTypeId='0125Y000001mOuEQAU'];
        for(Invoice__c invoice:undeliveredInvoices){
            if(ordersByProject.containsKey(invoice.Project__c)){
                List<Project_Work_Order__c> ordersToSet = ordersByProject.get(invoice.Project__c);
                for(Project_Work_Order__c order:ordersToSet){
                    order.Invoice__c = invoice.id;
                }
                ordersByProject.remove(invoice.Project__c);
            }
        }
        return ordersByProject;
    }
    
    //return invoice for insertion
    @TestVisible
   	private static List<Invoice__c> createNewInvoices(Map<Id, List<Project_Work_Order__c>> projectOrderMap){
        List<Invoice__c> newInvoices = new List<Invoice__c>();
        for(Id project:ProjectOrderMap.keySet()){
            newInvoices.add(new Invoice__c(recordTypeId='0125Y000001mOuEQAU', Project__c = project, Total__c = 0.00));
        }
        return newInvoices;
    }
    
    @TestVisible
    private Static void updateNewInvoices(Map<Id, List<Project_Work_Order__c>> ordersByProject, List<Invoice__c> insertedInvoices){
        for(Invoice__c invoice:insertedInvoices){
            if(ordersByProject.containsKey(invoice.Project__c)){
                List<Project_Work_Order__c> ordersToSet = ordersByProject.get(invoice.Project__c);
                for(Project_Work_Order__c order:ordersToSet){
                    order.Invoice__c = invoice.id;
                }
            }
        }
    }
}