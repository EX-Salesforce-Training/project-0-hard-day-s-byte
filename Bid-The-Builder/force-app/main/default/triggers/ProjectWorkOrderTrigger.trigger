///////////////////////////////////////////////////////////////
//
// Name: ProjectWorkOrderTriggerHandler
// Author: Josh Miccolo
// Created: 04/6/2021
// Updated: 04/12/2021
// Description: Trigger for Project Work Order
//
///////////////////////////////////////////////////////////////
trigger ProjectWorkOrderTrigger on Project_Work_Order__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    switch on trigger.operationType{
        when BEFORE_INSERT{
            ProjectWorkOrderTriggerHandler.handleWorkOrderInvoiceTypes(trigger.new);
        }
    }
}