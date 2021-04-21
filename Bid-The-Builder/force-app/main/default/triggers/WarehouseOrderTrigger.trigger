///////////////////////////////////////////////////////////////
//
// Name: ProjectWorkOrderTriggerHandler
// Author: Josh Miccolo
// Created: 04/6/2021
// Updated: 04/12/2021
// Description: Warehouse Order Trigger. Calls Warehouse Order Trigger Handler for functionality.
// 
//
///////////////////////////////////////////////////////////////

trigger WarehouseOrderTrigger on Warehouse_Order__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    switch on trigger.operationType{
        when BEFORE_INSERT{
            WarehouseOrderTriggerHandler.confirmNotShipped(trigger.new);
        }
        when AFTER_INSERT{
            
        }
        when BEFORE_UPDATE {
         	   
        }
        when AFTER_UPDATE{
            WarehouseOrderTriggerHandler.adjustInventoryOnReceipt(trigger.new);
        }
        when BEFORE_DELETE{
            WarehouseOrderTriggerHandler.confirmNotShipped(trigger.old);
        }
    }
}