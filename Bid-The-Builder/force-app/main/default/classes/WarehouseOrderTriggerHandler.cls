public class WarehouseOrderTriggerHandler {

    public static void confirmNotShipped(List<Warehouse_Order__c> orders){
        for(Warehouse_Order__c order:orders){
            if(order.Status__c == 'Shipped' || order.Status__c == 'Recieved'){
                order.addError('Order cannot be Shipped');
            }
        }
    }
    
    public static void adjustInventoryOnReceipt(List<Warehouse_Order__c> orders){
        //list recieved orders
        List<Warehouse_Order__c> recievedOrders = getRecievedOrders(orders);
		//List orderLine Items
        Map<Id, Map<Id, Decimal>> mappedLineItems = mapLineItemsToRawMaterials(recievedOrders);
        Map<Id, Map<Id, Material_Inventory__c>> inventoryToUpdate = getMaterialInventoriesByWarehouses(mappedLineItems);
        List<Material_Inventory__C> updatedInventory = updateInventory(mappedLineItems, inventoryToUpdate);
        upsert updatedInventory;
    }
    
    @TestVisible
    private static List<Warehouse_Order__c> getRecievedOrders(List<Warehouse_Order__c> orders){
        List<Warehouse_Order__c> recievedOrders = new List<Warehouse_Order__c>();
        
        for(Warehouse_Order__c order:orders){
            if(order.Status__c == 'Recieved'){
                recievedOrders.add(order);
            }
        }
        
        return recievedOrders;
    }

    @TestVisible
    private static Map<Id, Map<Id, Decimal>> mapLineItemsToRawMaterials(List<Warehouse_Order__c> recievedOrders){
        List<Warehouse_Order_Line_Item__c> lineItems = [SELECT Raw_Material__c, 
                                                        Quantity__c, 
                                                        Warehouse_Order__c, 
                                                        Warehouse_Order__r.Warehouse__c 
                                                        FROM Warehouse_Order_Line_Item__c
                                                        WHERE Warehouse_Order__c IN :recievedOrders]; 
        
       	Map<Id, Map<Id, Decimal>> mappedLineItems = new Map<Id, Map<Id, Decimal>>();
        
        for(Warehouse_Order_Line_Item__c lineItem:lineItems){
            Map<Id, Decimal> mappedlineItem = new Map<Id, Decimal>{lineItem.Raw_Material__c => lineItem.Quantity__c};
            mappedLineItems.put(lineItem.Warehouse_Order__r.Warehouse__c, mappedlineItem);
        }
        
        return mappedLineItems;
    }
    
    @TestVisible
    private static Map<Id, Map<Id, Material_Inventory__c>> getMaterialInventoriesByWarehouses(Map<Id, Map<Id, Decimal>> LineItems){
       	List<Material_Inventory__c> inventories = [SELECT Raw_Material__c, Warehouse__c, Quantity__c FROM Material_Inventory__c WHERE Warehouse__c IN :lineItems.KeySet()];
    	Map<Id, Map<Id, Material_Inventory__C>> mappedInventories = new Map<Id, Map<Id, Material_Inventory__c>>();
        for(Material_Inventory__c inventory:inventories){
            if(mappedInventories.containsKey(inventory.Warehouse__c)){
                mappedInventories.get(inventory.Warehouse__c).put(Inventory.Raw_Material__c, inventory);
            }else{
                Map<Id, Material_Inventory__c> newInventory = new Map<Id, Material_Inventory__c>{inventory.Raw_Material__c => inventory};
                mappedInventories.put(inventory.Warehouse__c, newInventory);
            }
        }
        return mappedInventories;
    }
    
    @TestVisible
    private static List<Material_Inventory__C> updateInventory(Map<Id, Map<Id, Decimal>> mappedLineItems, Map<Id, Map<Id, Material_Inventory__c>> inventories){
		List<Material_Inventory__c> updatedInventory = new List<Material_Inventory__c>();
        
        for(Id warehouseID:mappedLineItems.keySet()){
            if(inventories.containsKey(warehouseId)){
                Map<Id, Decimal> warehouseLineItems = mappedLineItems.get(warehouseId);
                Map<Id, Material_Inventory__c> warehouseInventory = inventories.get(warehouseId);
                for(Id rawMaterial:warehouseLineItems.keySet()){
                    if(warehouseInventory.containsKey(rawMaterial)){
                        Material_Inventory__c inventoryToUpdate = warehouseInventory.get(rawMaterial);
                        system.debug(inventoryToUpdate);
                        inventoryToUpdate.Quantity__C = InventoryToUpdate.Quantity__C + warehouseLineItems.get(rawMaterial);
                        system.debug(inventoryToUpdate);
                        updatedInventory.add(warehouseInventory.get(rawMaterial));
                    }
                    else{
                        Material_Inventory__c newInventory = new Material_Inventory__C(warehouse__c = warehouseID, Raw_Material__c = rawMaterial, Quantity__c = warehouseLineItems.get(rawMaterial));
                        updatedInventory.add(newInventory);
                    }
                }
            }else{
                Map<Id, Decimal> warehouseLineItems = mappedLineItems.get(warehouseId);
                for(Id rawMaterial:warehouseLineItems.keySet()){
                	Material_Inventory__c newInventory = new Material_Inventory__c(warehouse__c = warehouseID, Raw_Material__c = rawMaterial, Quantity__c =  warehouseLineItems.get(rawMaterial));
           		 	updatedInventory.add(newInventory);
            	}
        	}
    	}
        return updatedInventory;
    }
}