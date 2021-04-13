public class WarehouseOrderTriggerHandler {

    public static void confirmNotShipped(List<Warehouse_Order__c> orders){
        for(Warehouse_Order__c order:orders){
            if(order.Status__c == 'Shipped'){
                order.addError('Order cannot be Shipped upon creation');
            }
        }
    }
    
    public static void adjustInventoryOnReceipt(List<Warehouse_Order__c> orders){
        
    }

    
    @TestVisible
    private static List<Id> getRecievedOrderIds(List<Warehouse_Order__c> orders){
        List<Id> recievedOrders = new List<Id>();
        for(Warehouse_Order__c order:orders){
            if(order.Status__c == 'Recieved'){
                recievedOrders.add(order.id);
            }
        }
        return recievedOrders;
    }
    
    @TestVisible
    private static List<Warehouse_Order_Line_Item__c> getAllLineItems(List<Id> orderIds){
        return [SELECT Raw_Material__c, Quantity__c, Warehouse_Order__r.Warehouse__c FROM Warehouse_Order_Line_Item__c WHERE Warehouse_Order__c IN :orderIds];
    }
    
    @TestVisible
    private static void getInventoriesByLineItems(List<WareHouse_Order_Line_Item__c> lineItems){
        List<Id> RawMaterialIds = new List<Id>();
        List<Id> Warehouses = new List<Id>();
    }
    
    @TestVisible
    private static void updateInventory(Warehouse_Order__c order, List<Material_Inventory__c> updatedInventories){
        List<Warehouse_Order_Line_Item__c> lineItems = [SELECT Raw_Material__c, Quantity__c FROM Warehouse_Order_Line_Item__c WHERE Warehouse_Order__c = :order.id];
        
        List<Id> rawMaterials = new List<Id>();
        for(Warehouse_Order_Line_Item__c lineItem:lineItems){
            rawMaterials.add(lineItem.Raw_Material__c);
        }
        List<Material_Inventory__C> inventory = [SELECT Raw_Material__c, Quantity__c FROM Material_Inventory__c WHERE Warehouse__c = :order.Warehouse__c AND Raw_Material__r.id IN :rawMaterials];
    }
}