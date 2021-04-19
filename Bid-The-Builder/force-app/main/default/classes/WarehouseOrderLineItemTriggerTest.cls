///////////////////////////////////////////////////////////////
//
// Name: ProjectWorkOrderTriggerHandler
// Author: Josh Miccolo
// Created: 04/18/2021
// Updated: 04/19/2021
// Description:Trigger Test for Warehouse Order Line Items
//
///////////////////////////////////////////////////////////////
@isTest
public class WarehouseOrderLineItemTriggerTest {
	@isTest
    static void updatesWarehouseOrderOnInsert(){
        Warehouse__c newWarehouse = new Warehouse__c(name='Test', Address__c = 'Test');
        insert newWarehouse;
        Warehouse_Order__c newWarehouseOrder = new Warehouse_Order__c(Warehouse__c = newWarehouse.id);
        insert newWarehouseOrder;
        Id supplierRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Supplier').getRecordTypeId();
        Account supplier = new Account(name='testSupplier', recordTypeId = supplierRecordTypeId);
        Raw_Material__c newRawMaterial = new Raw_Material__c(name = 'Test', Supplier__c = supplier.id, Work_Type__C = 'General', cost_per_unit__c = 1, 	Unit_of_Measure__c = 'each');
        insert newRawMaterial;
        Warehouse_Order_Line_Item__c newLineItem = new Warehouse_Order_Line_Item__c(Warehouse_Order__C = newWarehouseOrder.id, Raw_Material__c = newRawMaterial.id, Quantity__c = 5);
    
    	Test.startTest();
        Database.SaveResult sr = database.insert(newLineItem);
        Test.stopTest();
        
        
       	system.assert(sr.isSuccess());
        Warehouse_Order_Line_Item__c lineItem = [SELECT id, Quantity__C, Raw_Material__r.cost_per_unit__c, Warehouse_Order__C, total_cost__c From Warehouse_Order_Line_Item__C LIMIT 1];
        system.debug(lineItem.Warehouse_Order__c);
        system.assert(lineItem != null);
        Warehouse_Order__c warehouseOrder = [SELECT id, Subtotal__C, total_Items__c From Warehouse_Order__c Where id = :lineItem.Warehouse_Order__c];
        system.assert(warehouseOrder.Total_Items__c == 1);
        system.debug(warehouseOrder.Subtotal__c);
        system.debug(lineItem.Raw_Material__r.cost_per_unit__c);
        system.debug(lineItem.Quantity__c);
        system.assertEquals(warehouseOrder.Subtotal__c, (lineItem.Raw_Material__r.cost_per_unit__c * lineItem.Quantity__c));
    	system.assertEquals(warehouseOrder.Subtotal__c, lineItem.Total_Cost__c);
    }
    
    @isTest
    static void updatesWarehouseOrderOnUpdate(){
        Warehouse__c newWarehouse = new Warehouse__c(name='Test', Address__c = 'Test');
        insert newWarehouse;
        Warehouse_Order__c newWarehouseOrder = new Warehouse_Order__c(Warehouse__c = newWarehouse.id);
        insert newWarehouseOrder;
        Id supplierRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Supplier').getRecordTypeId();
        Account supplier = new Account(name='testSupplier', recordTypeId = supplierRecordTypeId);
        Raw_Material__c newRawMaterial = new Raw_Material__c(name = 'Test', Supplier__c = supplier.id, Work_Type__C = 'General', cost_per_unit__c = 1, 	Unit_of_Measure__c = 'each');
        insert newRawMaterial;
        Warehouse_Order_Line_Item__c newLineItem = new Warehouse_Order_Line_Item__c(Warehouse_Order__C = newWarehouseOrder.id, Raw_Material__c = newRawMaterial.id, Quantity__c = 5);
  		insert newLineItem;
       
        Warehouse_Order_Line_Item__c lineItem = [SELECT id, Quantity__C, Raw_Material__r.cost_per_unit__c, Warehouse_Order__C, total_cost__c From Warehouse_Order_Line_Item__C LIMIT 1];
        system.assert(lineItem != null);
        Warehouse_Order__c warehouseOrder = [SELECT id, Subtotal__C, total_Items__c From Warehouse_Order__c Where id = :lineItem.Warehouse_Order__c];
        system.assert(warehouseOrder.Total_Items__c == 1);
        system.assertEquals(warehouseOrder.Subtotal__c, (lineItem.Raw_Material__r.cost_per_unit__c * lineItem.Quantity__c));
    	system.assertEquals(warehouseOrder.Subtotal__c, lineItem.Total_Cost__c);
        
        lineItem.Quantity__c = 4;
        Test.startTest();
        Database.SaveResult sr = database.update(lineItem);
        Test.stopTest();
        
        system.assert(sr.isSuccess());
        Warehouse_Order_Line_Item__c updatedLineItem = [SELECT id, Quantity__C, Raw_Material__r.cost_per_unit__c, Warehouse_Order__C, total_cost__c From Warehouse_Order_Line_Item__C LIMIT 1];
        system.assert(updatedLineItem != null);
        Warehouse_Order__c updatedWarehouseOrder = [SELECT id, Subtotal__C, total_Items__c From Warehouse_Order__c Where id = :updatedLineItem.Warehouse_Order__c];
        system.assert(updatedWarehouseOrder.Total_Items__c == 1);
        system.assertEquals(updatedWarehouseOrder.Subtotal__c, (updatedLineItem.Raw_Material__r.cost_per_unit__c * updatedLineItem.Quantity__c));
    	system.assertEquals(updatedWarehouseOrder.Subtotal__c, updatedLineItem.Total_Cost__c);
    }
    
    @isTest
    static void updatesWarehouseOrderOnDelete(){
        Warehouse__c newWarehouse = new Warehouse__c(name='Test', Address__c = 'Test');
        insert newWarehouse;
        Warehouse_Order__c newWarehouseOrder = new Warehouse_Order__c(Warehouse__c = newWarehouse.id);
        insert newWarehouseOrder;
        Id supplierRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Supplier').getRecordTypeId();
        Account supplier = new Account(name='testSupplier', recordTypeId = supplierRecordTypeId);
        Raw_Material__c newRawMaterial = new Raw_Material__c(name = 'Test', Supplier__c = supplier.id, Work_Type__C = 'General', cost_per_unit__c = 1, 	Unit_of_Measure__c = 'each');
        insert newRawMaterial;
        Warehouse_Order_Line_Item__c newLineItem = new Warehouse_Order_Line_Item__c(Warehouse_Order__C = newWarehouseOrder.id, Raw_Material__c = newRawMaterial.id, Quantity__c = 5);
  		insert newLineItem;
       
        Warehouse_Order_Line_Item__c lineItem = [SELECT id, Quantity__C, Raw_Material__r.cost_per_unit__c, Warehouse_Order__C, total_cost__c From Warehouse_Order_Line_Item__C LIMIT 1];
        system.assert(lineItem != null);
        Warehouse_Order__c warehouseOrder = [SELECT id, Subtotal__C, total_Items__c From Warehouse_Order__c Where id = :lineItem.Warehouse_Order__c];
        system.assert(warehouseOrder.Total_Items__c == 1);
        system.assertEquals(warehouseOrder.Subtotal__c, (lineItem.Raw_Material__r.cost_per_unit__c * lineItem.Quantity__c));
    	system.assertEquals(warehouseOrder.Subtotal__c, lineItem.Total_Cost__c);
        
        Test.startTest();
        Database.DeleteResult dr = database.delete(lineItem);
        Test.stopTest();
        
        system.assert(dr.isSuccess());
        List<Warehouse_Order_Line_Item__c> allLineItems = [SELECT id, Quantity__C, Raw_Material__r.cost_per_unit__c, Warehouse_Order__C, total_cost__c From Warehouse_Order_Line_Item__C];
        system.assert(allLineItems.size() == 0);
        Warehouse_Order__c deletedWarehouseOrder = [SELECT id, Subtotal__C, total_Items__c From Warehouse_Order__c Where id = :lineItem.Warehouse_Order__c];
        system.assert(deletedWarehouseOrder.Total_Items__c == 0);
        system.assertEquals(0, deletedWarehouseOrder.Subtotal__c);
    }
}