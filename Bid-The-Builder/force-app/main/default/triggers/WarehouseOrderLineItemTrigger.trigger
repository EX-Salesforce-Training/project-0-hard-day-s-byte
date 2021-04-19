///////////////////////////////////////////////////////////////
//
// Name: ProjectWorkOrderTriggerHandler
// Author: Josh Miccolo
// Created: 04/18/2021
// Updated: 04/19/2021
// Description: Trigger for Warehouse Order Line Items to update warehouse Order Totals
//
///////////////////////////////////////////////////////////////


trigger WarehouseOrderLineItemTrigger on Warehouse_Order_Line_Item__c (after insert, after update, after delete) {
	
    switch on trigger.OperationType{
        when AFTER_INSERT{
            WarehouseOrderLineItemTriggerHandler.updateWarehouseOrderTotal(trigger.new);
        }
        when AFTER_UPDATE{
            WarehouseOrderLineItemTriggerHandler.updateWarehouseOrderTotal(trigger.new);
        }
        when AFTER_DELETE{
            WarehouseOrderLineItemTriggerHandler.updateWarehouseOrderTotal(trigger.old);
        }
    }
}