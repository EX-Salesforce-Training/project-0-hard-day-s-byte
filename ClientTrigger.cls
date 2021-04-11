trigger ClientTrigger on Client__c ( after update) {
    switch on trigger.OperationType{
        when AFTER_UPDATE{
            ClientTriggerHandler.paidFull(trigger.new);
        }
    }

}