///////////////////////////////////////////////////////////////
//
// Name: ProjectWorkOrderTriggerHandler
// Author: Josh Miccolo
// Created: 04/6/2021
// Updated: 04/12/2021
// Description: Warehouse Order Trigger Handler. Confirms not shipped items
// and adjusts inventory when recieved. 
//
///////////////////////////////////////////////////////////////
public class WarehouseOrderTriggerHandler {

    //Before Insert or Delete make sure order hasn't shipped
    public static void confirmNotShipped(List<Warehouse_Order__c> orders){
        for(Warehouse_Order__c order:orders){
            if(order.Status__c == 'Shipped' || order.Status__c == 'Recieved'){
                order.addError('Order cannot be Shipped');
            }
        }
    }
    
    //adjust inventory by Warehouse Order upon Status changed to 'Recieved'
    public static void adjustInventoryOnReceipt(List<Warehouse_Order__c> orders){
        
        //list recieved orders
        List<Warehouse_Order__c> recievedOrders = getRecievedOrders(orders);
		
        //List orderLine Items
        Map<Id, Map<Id, Decimal>> mappedLineItems = mapLineItemsToRawMaterials(recievedOrders);
        
       	//Set of Raw Material Ids in order
        Set<Id> RawMaterialsInOrders = listMaterials(mappedLineItems);

        //Mapped Warehouses to Raw Materials and associated Material Inventories
        Map<Id, Map<Id, Material_Inventory__c>> inventoryToUpdate = getMaterialInventoriesByWarehouses(mappedLineItems, RawMaterialsInOrders);
        
        //update Inventory by Warehouse and Line Item
        List<Material_Inventory__C> updatedInventory = updateInventory(mappedLineItems, inventoryToUpdate);
        
        // Insert necessary inventory and update rest
        upsert updatedInventory;
    }
    
    
    //return list of only recieved orders.
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
	
    //Find Line Items by warehouse and map the raw material to their decimal quantity
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
    
    //Return Set of Raw Materials to check against Material Inventories
    @TestVisible
    private static Set<Id> ListMaterials(Map<Id, Map<id, Decimal>> mappedLineItems){
        Set<Id> Materials = new Set<Id>();
        for(Id warehouseId:mappedLineItems.keySet()){
            Materials.addAll(mappedLineItems.get(warehouseId).keySet());
        }
        return Materials;
    }
    
    //Get Material Inventories by Warehouse and possible Raw Material in Warehouse
    @TestVisible
    private static Map<Id, Map<Id, Material_Inventory__c>> getMaterialInventoriesByWarehouses(Map<Id, Map<Id, Decimal>> LineItems, Set<Id> Materials){
       	
        Set<Id> warehouses = lineItems.keySet();
        
        
        //Query for all Material Inventories by warehouses in orders and raw Materials in Line Items
        List<Material_Inventory__c> inventories = [SELECT Name, Raw_Material__c, Warehouse__c, Quantity__c FROM Material_Inventory__c WHERE (Warehouse__c IN :warehouses AND Raw_Material__c IN :Materials)];
    
        //Map to save Material inventories by their Warehouse and Raw_Material
        Map<Id, Map<Id, Material_Inventory__C>> mappedInventories = new Map<Id, Map<Id, Material_Inventory__c>>();
        
        
        for(Material_Inventory__c inventory:inventories){
            system.debug(inventory.Name);
            if(mappedInventories.containsKey(inventory.Warehouse__c)){
                mappedInventories.get(inventory.Warehouse__c).put(Inventory.Raw_Material__c, inventory);
            }else{
                Map<Id, Material_Inventory__c> newInventory = new Map<Id, Material_Inventory__c>{inventory.Raw_Material__c => inventory};
                mappedInventories.put(inventory.Warehouse__c, newInventory);
            }
        }
        return mappedInventories;
    }
    
    //update inventory by looping through lineItems and incrementing existing inventory, or adding new inventory
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
                        inventoryToUpdate.Quantity__C += warehouseLineItems.get(rawMaterial);
                        updatedInventory.add(inventoryToUpdate);
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