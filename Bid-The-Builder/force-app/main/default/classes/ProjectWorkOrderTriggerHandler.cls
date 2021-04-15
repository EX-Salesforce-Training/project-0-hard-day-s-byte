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
public with sharing class ProjectWorkOrderTriggerHandler {
	
    //save record type for use
    private static Id WorkOrderInvoiceId = Schema.SObjectType.Invoice__c.getRecordTypeInfosByName().get('Work Order Invoice').getRecordTypeId();
    
    //check for Invoice in list of triggered Project Work Orders and assign Invoice for Work Order Types. 
    public static void handleWorkOrderInvoiceTypes(List<Project_Work_Order__c> orders){   
        
        //Find all unassigned Project Work Orders
        List<Project_Work_Order__c> nullInvoiceWorkOrders = checkForNull(orders);
        
        //Find all Project Work Orders by Invoice Type 'Work Order'
        List<Project_Work_Order__c> WorkOrderTypeOrders = checkInvoiceType(nullInvoiceWorkOrders);
        
        //Map Project Ids to Project Work Order Lists
        Map<Id, List<Project_Work_Order__c>> ProjectsMappedToOrders = MapProjectToOrders(WorkOrderTypeOrders);
        
        //Will return list of orders without Invoices Assigned to them by Project Id
        Map<Id, List<Project_Work_Order__C>> ProjectsToCreateInvoice = MapWorkOrdersToUndeliveredInvoice(ProjectsMappedToOrders);
        
        //Returns New Invoices for Projects without a current Work ORder Invoice
        List<Invoice__c> InvoicesToInsert = createNewInvoices(ProjectsToCreateInvoice);
        
        // Insert into database new Invoices
        insert InvoicesToInsert;
        
        //Add new Invoices to Project Work Orders
        updateNewInvoices(ProjectsToCreateInvoice, InvoicesToInsert);
    }
    
    //check for Null Invoices in list of Project Work Orders, returns new list of unassigned Project Work Orders
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
    
    //Checks the Invoice Type of the Project Work Order and returns only those with 'By Work Order' type
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
    
    //Maps each Work Order to its assigned Project 
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
    
    //Checks Projects for their undelivered Invoices by 'Work Order Invoice' type and returns new map
    @TestVisible
    private static Map<Id, List<Project_Work_Order__c>> MapWorkOrdersToUndeliveredInvoice(Map<Id, list<Project_Work_Order__c>> ordersByProject){
        
        List<Invoice__C> undeliveredInvoices = [SELECT id, name, Project__c FROM Invoice__c Where Project__c IN :ordersByProject.keySet() AND Delivered__c = false AND RecordTypeId=:WorkOrderInvoiceId];
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
    
    //return invoices for insertion
    @TestVisible
   	private static List<Invoice__c> createNewInvoices(Map<Id, List<Project_Work_Order__c>> projectOrderMap){
        List<Invoice__c> newInvoices = new List<Invoice__c>();
        
        for(Id project:ProjectOrderMap.keySet()){
            newInvoices.add(new Invoice__c(recordTypeId=workOrderInvoiceId, Project__c = project, Total__c = 0.00));
        }
        return newInvoices;
    }
    
    //update Project Work Order Lists with new Invoices
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