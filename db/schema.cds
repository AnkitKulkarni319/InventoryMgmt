    namespace Inventory;

    using {
        cuid,
        managed
    } from '@sap/cds/common';

    @assert.unique.u1: [ProductCode]
    entity Products : cuid, managed {

    ProductCode   : String not null
        @mandatory
        @Common.Label: 'Product Code';

    Name          : String not null
        @mandatory
        @Common.Label: 'Product Name';

    Description   : String
        @Common.Label: 'Description';

    UnitOfMeasure : String not null
        @mandatory
        @Common.Label: 'Unit of Measure';

    MinStockLevel : Integer not null
        @mandatory
        @assert.range: [(0),_]
        @Common.Label: 'Min Stock Level';

    MaxStockLevel : Integer not null
        @mandatory
        @assert.range: [(1),_]
        @Common.Label: 'Max Stock Level';

    Category      : Association to Categories not null
        @mandatory
        @Common.Label: 'Category';

    StockLevels   : Composition  of many StockLevels
        on StockLevels.Product = $self;
}

    @assert.unique.u1: [CategoryCode]
    entity Categories : cuid, managed {
        CategoryCode : String not null  @mandatory  @Common.Label: 'Category Code';
        CategoryName : String not null  @mandatory  @Common.Label: 'Category Name';
        Products     : Composition of many Products
                        on Products.Category = $self;
    }

  @assert.unique.u1: [WarehouseCode]
entity Warehouses : cuid, managed {

    WarehouseCode : String not null
        @mandatory
        @Common.Label: 'Warehouse Code';

    Name : String not null
        @mandatory
        @Common.Label: 'Warehouse Name';

    Location : String not null
        @mandatory
        @Common.Label: 'Location';

    Capacity : Decimal(10,2) not null
        @mandatory
        @Common.Label: 'Capacity';

           Latitude      : Double;  
    Longitude     : Double;  
     MapUrl        : String;
}
    @assert.unique.u1: [
        Product,
        Warehouse
    ]
   entity StockLevels : cuid, managed {

    Product : Association to Products not null
        @mandatory
        @Common.Label: 'Product';

    Warehouse : Association to Warehouses not null
        @mandatory
        @Common.Label: 'Warehouse';

    CurrentStock : Integer not null default 0
        @mandatory
        @assert.range: [(0),_]
        @Common.Label: 'Current Stock';

    ReservedStock : Integer default 0
        @assert.range: [(0),_]
        @Common.Label: 'Reserved Stock';

    AvailableStock : Integer
        @Core.Computed
        @Common.Label: 'Available Stock';
}

    entity StockMovements : cuid, managed {
        ActionRequested : ActionType   @Common.Label: 'Action Requested';
        MovementType  : MovementType   @Common.Label: 'Movement Type';
        Product       : Association to Products not null  @mandatory  @Common.Label: 'Product';
        FromWarehouse : Association to Warehouses @Common.Label: 'From Warehouse';
        ToWarehouse   : Association to Warehouses     @Common.Label: 'To Warehouse';
        Quantity      : Integer not null   @mandatory  @Common.Label: 'Quantity';
        MovedBy       : String not null        @mandatory  @Common.Label: 'Moved By';
        MovementDate  : Date not null  @mandatory  @Common.Label: 'Movement Date';
    }

    // entity actionRequestedView as select from StockMovements {
    //     key ActionRequested
    // }group by ActionRequested;

    type MovementType : String @assert.range enum {
        GoodsReceipt = 'GoodsReceipt';
        GoodsIssue = 'GoodsIssue';
        Transfer = 'Transfer';
    };

type ActionType : String @assert.range enum {
    GoodsReceipt = 'GoodsReceipt';
    GoodsIssue   = 'GoodsIssue';
    Transfer     = 'Transfer';
};


     @cds.autoexpose
    view MovementKPIs as
        select from StockMovements {
            key ID,
                MovementType,
                MovementDate,
                Quantity,
                1 as movementCount : Integer
        };