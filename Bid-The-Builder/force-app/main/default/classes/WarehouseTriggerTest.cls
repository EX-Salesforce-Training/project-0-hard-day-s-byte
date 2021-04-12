@isTest
public class WarehouseTriggerTest {
	@testSetup
    static void CreateOrders(){
    }
    
    @isTest
    static void newOrderNotShipped(){
        Warehouse_Order__c newOrder = new Warehouse_Order__c(Status__c = 'Shipped');
        try{
        	insert newOrder;
        }catch(Exception e){
            system.assertEquals('Insert failed. First exception on row 0; first error: FIELD_CUSTOM_VALIDATION_EXCEPTION, Order cannot be Shipped upon creation: []', e.getMessage());
        }
    }
}