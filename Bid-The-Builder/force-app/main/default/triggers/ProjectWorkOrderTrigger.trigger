trigger ProjectWorkOrderTrigger on Project_Work_Order__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    switch on trigger.operationType{
        when BEFORE_INSERT{
            ProjectWorkOrderTriggerHandler.handleInvoiceTypesByOrder(trigger.new);
        }
    }
}