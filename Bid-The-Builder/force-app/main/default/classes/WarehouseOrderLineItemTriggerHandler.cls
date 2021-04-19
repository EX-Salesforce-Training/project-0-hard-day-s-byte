///////////////////////////////////////////////////////////////
//
// Name: ProjectWorkOrderTriggerHandler
// Author: Josh Miccolo
// Created: 04/18/2021
// Updated: 04/19/2021
// Description: Handler to for Warehouse Order Line Item Trigger. Finds
// undelivered invoices for Projects and adds them to the Work Order or makes
// new invoices for the Projects 
//
///////////////////////////////////////////////////////////////
public class WarehouseOrderLineItemTriggerHandler {
    public static void updateWarehouseOrderTotal(List<Warehouse_Order_Line_Item__c> lineItems){
        Set<Id> warehouseOrderIds = getWarehouseOrders(lineItems);
        List<Warehouse_Order__c> warehouseOrders = [SELECT id, (SELECT id, Quantity__c, Price_Per_Unit1__c FROM Warehouse_Order_Line_Items__r) FROM Warehouse_Order__c WHERE id IN :warehouseOrderIds];
        updateOrderTotals(warehouseOrders);
        update warehouseOrders;
      }
    
    private static Set<Id> getWarehouseOrders(List<Warehouse_Order_Line_Item__c> lineItems){
        Set<Id>WarehouseOrderIds = new Set<Id>();
        for(Warehouse_Order_Line_Item__c item:lineItems){
            WarehouseOrderIds.add(item.Warehouse_Order__c);
        }
        return WarehouseOrderIds;
    }
    
    private static void updateOrderTotals(List<Warehouse_Order__C> warehouseOrders){
        for(Warehouse_Order__c order:warehouseOrders){
            order.Subtotal__c = 0;
            for(Warehouse_Order_Line_Item__c lineItem:order.Warehouse_Order_Line_Items__r){
                order.Subtotal__c += (lineItem.Quantity__C * lineItem.Price_Per_Unit1__c);
            }
        }
    }
}