trigger LeadTrigger on Lead (before insert) {
    switch on trigger.operationType{
        when BEFORE_INSERT{
            LeadTriggerHandler.addAccountIfConverted(trigger.new);
        }
        when BEFORE_UPDATE{
             LeadTriggerHandler.addAccountIfConverted(trigger.new);
        }
    }
}