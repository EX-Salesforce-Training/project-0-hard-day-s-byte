///////////////////////////////////////////////////////////////
//
// Name: ProjectWorkOrderTriggerHandler
// Author: Josh Miccolo
// Created: 04/6/2021
// Updated: 04/12/2021
// Description: Tests for Project Work Order
//
///////////////////////////////////////////////////////////////
@isTest
private with sharing class ProjectWorkOrderTriggerTest {
  
    //Single Tests
    @isTest
    static void ProjectWorkOrderTriggerShouldCreateInvoice(){
                
        Project__c newProject = new Project__c(name='TestHouse', work_type__c = 'Concrete', address__c = '123 Boulevard Lane');
    	insert newProject;
            
        Project_Work_Order__c newOrder = new Project_Work_Order__c(Project__c = newProject.id, Invoice_Type__c = 'By Work Order');
        
        Test.startTest();
		Database.SaveResult result = Database.insert(newOrder);
        Test.stopTest();
        
        Id recordTypeId =  Schema.SObjectType.Invoice__c.getRecordTypeInfosByName().get('Work Order Invoice').getRecordTypeId();
        
        system.assert(result.isSuccess());
        system.assert(result.getErrors().size() == 0);
        Project_Work_Order__c orderResult = [SELECT Invoice__c, Invoice__r.recordTypeId FROM Project_Work_Order__c WHERE id = :result.getId()];
        system.assert(orderResult.Invoice__c != null);
        system.assertEquals(orderResult.Invoice__r.recordTypeId, recordTypeId);
    
    }
    
    @isTest
    static void ProjectWorkOrderTriggerShouldAddCorrectInvoice(){
       
            
        Project__c newProject2 = new Project__c(name='TestHouse2', work_type__c = 'Concrete', address__c = '123 Boulevard Lane');
        insert newProject2;
        
        Invoice__c newInvoice = new Invoice__c(recordTypeId=Schema.SObjectType.Invoice__c.getRecordTypeInfosByName().get('Work Order Invoice').getRecordTypeId(), Project__c = newProject2.id, Customer_Account__c = newProject2.Account__c, Total__c = 0.0);
        insert newInvoice;
        
        Project_Work_Order__c newOrder2 = new Project_Work_Order__c(Project__c = newProject2.id, Invoice_Type__c = 'By Work Order');
    	
        Test.startTest();
		Database.SaveResult result = Database.insert(newOrder2);
        Test.stopTest();
        
       	Id recordTypeId =  Schema.SObjectType.Invoice__c.getRecordTypeInfosByName().get('Work Order Invoice').getRecordTypeId();
        
        system.assert(result.isSuccess());
        system.assert(result.getErrors().size() == 0);
        Project_Work_Order__c orderResult = [SELECT Invoice__c, Invoice__r.recordTypeId FROM Project_Work_Order__c WHERE id = :result.getId()];
        system.assertEquals(newInvoice.id, orderResult.Invoice__c);
        system.assertEquals(recordTypeId, orderResult.Invoice__r.recordTypeId);
    }
    
    //Bulk Tests
    @isTest
    static void ProjectWorkOrderTriggerShouldhandleBulk(){
        
        List<Project__c> projectList = new List<Project__c>();
        List<Invoice__c> invoiceList = new List<Invoice__c>();
        List<Project_Work_Order__c> orderList = new List<Project_Work_Order__c>();
        
        for(Integer i = 0; i < 150; i++){
            Project__c newProject3 = new Project__c(name='BulkTestHouse' + i, work_type__c = 'Concrete', address__c = '123 Boulevard Lane');
            projectList.add(newProject3);
        }
        
        insert projectList;
        
        for(Integer i = 0; i < 150; i++){
            List<id> invoiceTypes = new List<id>{Schema.SObjectType.Invoice__c.getRecordTypeInfosByName().get('Work Order Invoice').getRecordTypeId(), Schema.SObjectType.Invoice__c.getRecordTypeInfosByName().get('Installment Invoice').getRecordTypeId()};
            Project__c invoiceProject = projectList[Math.round(Math.random()*149)];
            Invoice__c newBulkInvoice = new Invoice__c(recordTypeId=invoiceTypes[Math.round(Math.random())], Project__c = invoiceProject.id, Customer_Account__c = invoiceProject.Account__c, Total__c = 0.0);
        	invoiceList.add(newBulkInvoice);
        }
        
        insert invoiceList;
        
        for(Integer i = 0; i < 150; i++){
            List<String> invoiceTypes = new List<String>{'By Work Order', 'Installation'};
            Project__c orderProject = projectList[Math.round(Math.random()*149)];
            Project_Work_Order__c newBulkOrder = new Project_Work_Order__c(Invoice_Type__c=invoiceTypes[Math.round(Math.random())], Project__c = orderProject.id);
        	orderList.add(newBulkOrder);
        }
        
        Test.startTest();
        Database.SaveResult[] resultList = Database.insert(orderList, false);
        Test.stopTest();
		
        List<Id> resultIds = new List<Id>();
        
        for(Database.SaveResult result:resultList){
            system.assert(result.isSuccess());
            system.assert(result.getErrors().size() == 0);
            resultIds.add(result.getId());
        }        
        
        List<Project_Work_Order__C> workOrders = [SELECT Invoice__c, Invoice__r.recordTypeId, Invoice_Type__c FROM Project_Work_Order__c WHERE id IN :resultIds];
        
        for(Project_Work_Order__c workOrder:workOrders){
            if(workOrder.Invoice_Type__c == 'By Work Order'){
                system.assert(workOrder.Invoice__c != null);
                Id recordTypeId =  Schema.SObjectType.Invoice__c.getRecordTypeInfosByName().get('Work Order Invoice').getRecordTypeId();
                system.assert(workOrder.Invoice__r.recordTypeId == recordTypeId);
            }
        }
    }
    
    @isTest
    static void projectWorkOrderTriggerShouldAllowUse(){
        Profile projectManager = [SELECT id FROM Profile WHERE Name='Project-Management'];
        String uniqueUsername = 'testUser' + DateTime.now().getTime() + '@testorg.com'; 
        User rightUser = new User(Alias = 'rightU', 
                                  Email='rightUser@testorg.com', 
                                  EmailEncodingKey='UTF-8', 
                                  LastName='Test', 
                                  LanguageLocaleKey='en_US', 
                                  LocaleSidKey='en_US',
                                  ProfileId=projectManager.id,
                                  TimeZoneSidKey='America/Los_Angeles',
                                  UserName=uniqueUsername
                                 );
        	insert rightuser;
            System.runAs(rightUser){
                Project__c newProject = new Project__c(name='TestHouse', work_type__c = 'Concrete', address__c = '123 Boulevard Lane');
    			insert newProject;
            
        		Project_Work_Order__c newOrder = new Project_Work_Order__c(Project__c = newProject.id, Invoice_Type__c = 'By Work Order');
        
       			Test.startTest();
				Database.SaveResult result = Database.insert(newOrder);
        		Test.stopTest();
        
        		Id recordTypeId =  Schema.SObjectType.Invoice__c.getRecordTypeInfosByName().get('Work Order Invoice').getRecordTypeId();
        
       			system.assert(result.isSuccess());
        		system.assert(result.getErrors().size() == 0);
            }
    }
    
     @isTest
    static void projectWorkOrderTriggerShouldDenyUse(){
        Profile warehouse = [SELECT id FROM Profile WHERE Name='Warehouse'];
        String uniqueUsername = 'testUser' + DateTime.now().getTime() + '@testorg.com'; 
        User wrongUser = new User(Alias = 'wrongU', 
                                  Email='wrongUser@testorg.com', 
                                  EmailEncodingKey='UTF-8', 
                                  LastName='Test', 
                                  LanguageLocaleKey='en_US', 
                                  LocaleSidKey='en_US',
                                  ProfileId=warehouse.id,
                                  TimeZoneSidKey='America/Los_Angeles',
                                  UserName=uniqueUsername
                                 );
        	insert wrongUser;
            System.runAs(wrongUser){
                Project__c newProject = new Project__c(name='TestHouse', work_type__c = 'Concrete', address__c = '123 Boulevard Lane');
    			insert newProject;
            
        		Project_Work_Order__c newOrder = new Project_Work_Order__c(Project__c = newProject.id, Invoice_Type__c = 'By Work Order');
        
       			Test.startTest();
				Database.SaveResult result = Database.insert(newOrder);
        		Test.stopTest();
        
        		Id recordTypeId =  Schema.SObjectType.Invoice__c.getRecordTypeInfosByName().get('Work Order Invoice').getRecordTypeId();
        	
       			system.assertEquals(result.isSuccess(), false, 'Database was able to insert');
        		system.assertEquals(result.getErrors().size(), 0);
            }
    }
    
    
   
}