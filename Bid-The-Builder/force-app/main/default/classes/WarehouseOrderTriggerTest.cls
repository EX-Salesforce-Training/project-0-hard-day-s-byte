@isTest
public class WarehouseOrderTriggerTest {
    
    @isTest
    static void newOrderNotShipped(){
       	Warehouse__c newWarehouse = new Warehouse__c(name='TestHouse', address__c ='Test');
        insert newWarehouse;
        
        Warehouse_Order__c newOrder = new Warehouse_Order__c(Status__c = 'Shipped', warehouse__C = newWarehouse.id);
       	
       
        try{
            Test.startTest();
        	Database.SaveResult sr = database.insert(newOrder);  
        	Test.stopTest();
        }
        catch (DMLException e){
            system.assert(e.getMessage().contains('Order cannot be Shipped'));
        }
    }
    
    @isTest
    static void ShippednotDeleted(){
        
        Warehouse__c newWarehouse = new Warehouse__c(name='TestHouse', address__c ='Test');
        insert newWarehouse;
        
        Warehouse_Order__c newDeletedOrder = new Warehouse_Order__c(Status__c = 'Not Ordered', Warehouse__C = newWarehouse.id);
        insert newDeletedOrder;
        
        Warehouse_Order__C OrderToUpdate = [SELECT id, Status__c FROM Warehouse_Order__c LIMIT 1];
        OrderToUpdate.Status__c = 'Shipped';
       	update OrderToUpdate;
        
        Test.startTest();
        try{
            Warehouse_Order__C OrderToDelete = [SELECT id, Status__c FROM Warehouse_Order__c LIMIT 1];
        	Database.DeleteResult deleted = database.delete(OrderToDelete);
        }
        catch(DMLException e){
             system.assert(e.getMessage().contains('Order cannot be Shipped'));
        }
        Test.stopTest();
    }
    
    @isTest
    static void getRecievedOrdersShouldReturnOnlyRecievedOrders(){
        Warehouse__c testWarehouse = new Warehouse__c(name='testWarehouse', Address__c='Test');
        insert testWarehouse;
        List<Warehouse_Order__c> testOrders = new List<Warehouse_Order__c>();
        for(Integer i = 0; i < 50; i++){
            if(Math.mod(i, 2) == 0){
                Warehouse_Order__c newOrder = new Warehouse_Order__c(status__c = 'Recieved', warehouse__c = testWarehouse.id);
                testOrders.add(newOrder);
            }else{
                Warehouse_Order__c newOrder = new Warehouse_Order__c(status__c = 'Ordered', warehouse__c = testWarehouse.id);
            	testOrders.add(newOrder);
            }
        }

        List<Warehouse_Order__c> recievedOrders = WarehouseOrderTriggerHandler.getRecievedOrders(testOrders);
  
        system.assert(recievedOrders.size() == 25);
        
        for(Warehouse_Order__c order:recievedOrders){
            system.assertEquals('Recieved', order.status__c);
        }
    }
   	@testSetup
    static void createInventoryAndOrders(){
        Warehouse__c testWarehouse = new Warehouse__c(name='testWarehouse', Address__c='Test');
        insert testWarehouse;
        
        List <Raw_Material__c> testMaterials = new List<Raw_Material__c>();
        for(Integer i = 0; i < 200; i++){
            Raw_Material__c newMaterial = new Raw_Material__c(Name='Material'+i, Work_Type__c = 'Concrete', Cost_Per_Unit__C = 1, Unit_of_Measure__c = 'square feet');
        	testMaterials.add(newMaterial);
        }
        insert testMaterials;
        
       	List<Material_Inventory__c> testInventory = new List<Material_Inventory__c>();
        for(Raw_Material__c inventoryMaterial:testMaterials){
            Material_Inventory__C newInventory = new Material_Inventory__c(Raw_Material__c = inventoryMaterial.id, Warehouse__c = testWarehouse.id, Quantity__c = 2);
        	testInventory.add(newInventory);
        }
		insert testInventory;
        
        Warehouse_Order__c newOrder1 = new Warehouse_Order__c(Status__c = 'Not Ordered', Warehouse__c = testWarehouse.id);
        insert newOrder1;
        
        List<Warehouse_Order_Line_Item__c> newLineItems = new List<Warehouse_Order_Line_Item__c>();
        for(Integer i = 0; i < 150; i++){
         	Warehouse_Order_Line_Item__c newOrderLine = new Warehouse_Order_Line_Item__c(Warehouse_Order__c = newOrder1.id, Raw_Material__c = testMaterials[i].id, Quantity__c = 5);
        	newLineItems.add(newOrderLine);
        }
        insert newLineItems;
    }
    
    @isTest
    static void updateOneOrderToManyInventory(){
        Warehouse_Order__c testOrder = [SELECT id, Status__C, Warehouse__c, (SELECT Raw_Material__c, Quantity__C FROM Warehouse_Order_Line_Items__r) FROM Warehouse_Order__c LIMIT 1];
        system.assert(testOrder.Status__c == 'Not Ordered');
        system.assert(testOrder.Warehouse_Order_Line_Items__R.size() == 150);
        
        testOrder.Status__C = 'Recieved';
        
        Test.startTest();
        Database.SaveResult sr = Database.update(testOrder);
        Test.stopTest();
        
        system.assert(sr.isSuccess());
        
        List<Id> rawMaterials = new List<Id>();
        for(Warehouse_Order_Line_Item__c lineItem:testOrder.warehouse_Order_Line_Items__r){
            rawMaterials.add(lineItem.Raw_Material__c);
        }
        List<Material_Inventory__c> testInventory = [SELECT Raw_Material__c, Quantity__c FROM Material_Inventory__c WHERE Warehouse__c = :testOrder.Warehouse__c AND Raw_Material__c IN :rawMaterials];
        for(Material_Inventory__c inventory:testInventory){
            
        }
    }
}