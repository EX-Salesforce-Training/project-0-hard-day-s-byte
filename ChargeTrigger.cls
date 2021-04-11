trigger ChargeTrigger on Charge__c (after insert, before insert) {
    switch on trigger.operationType{
        when BEFORE_INSERT{
            ChargeTriggerHandler.updateClientPay(trigger.new);
        }
        when AFTER_INSERT{
            ChargeTriggerHandler.createLessonFromCharge(trigger.new);
        }
        
        
    }

}