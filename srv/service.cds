using { Inventory as db } from '../db/schema';

@requires: ['Operator', 'WarehouseManager', 'Administrator']
service InventoryService {

  @restrict: [
    { grant: 'READ',              to: ['Operator', 'WarehouseManager', 'Administrator'] },
    { grant: ['CREATE','UPDATE','DELETE'], to: ['Administrator'] }
  ]
  @odata.draft.enabled
  entity Products as projection on db.Products;

  @restrict: [
    { grant: 'READ', to: ['Operator', 'WarehouseManager'] },
    { grant: '*',    to: ['Administrator'] }
  ]

  entity Categories as projection on db.Categories;

  @restrict: [
    { grant: 'READ',              to: ['Operator', 'WarehouseManager', 'Administrator'] },
    { grant: ['CREATE','UPDATE','DELETE'], to: ['Administrator'] },
     { grant: 'checkLocation',             to: ['Operator', 'WarehouseManager', 'Administrator'] }

  ]
  @odata.draft.enabled
    entity Warehouses as projection on db.Warehouses
    actions {

      @requires: ['Operator', 'WarehouseManager', 'Administrator']
        action checkLocation() returns {
            lat    : Double;
      lng    : Double;
      mapUrl : String;
        };
    };

  @restrict: [
    { grant: 'READ', to: ['Operator', 'WarehouseManager', 'Administrator'] }
  ]
  entity StockLevels as projection on db.StockLevels;

  @requires: ['Operator', 'WarehouseManager', 'Administrator']
  function getAvailableStock(productID: String, warehouseID: String) returns Integer;

  @requires: ['Operator', 'WarehouseManager', 'Administrator']
  function getLowStockAlerts() returns many StockLevels;
}

@requires: ['Operator', 'WarehouseManager', 'Administrator']
service MovementService {

  @restrict: [
    { grant: 'READ',   to: ['Operator', 'WarehouseManager', 'Administrator'] },
    { grant: 'CREATE', to: ['Operator'] },
    { grant: '*', to: ['Operator'], where: 'createdBy = $user' },
    { grant: '*', to: ['WarehouseManager', 'Administrator'] },
    { grant: 'DELETE', to: ['Administrator'] }
  ]
  @odata.draft.enabled
  entity StockMovements as projection on db.StockMovements actions {

   
    @requires: ['WarehouseManager', 'Administrator']
  
    action goodsReceipt() returns String;

     @requires: ['WarehouseManager', 'Administrator']
   
    action goodsIssue() returns String;

     @requires: ['WarehouseManager', 'Administrator']
    
    action stockTransfer() returns String;
  };

  @readonly
 @restrict: [{ grant: 'READ', to: ['Operator', 'WarehouseManager', 'Administrator'] }]
  entity Products as projection on db.Products;

  @readonly
@restrict: [{ grant: 'READ', to: ['Operator', 'WarehouseManager', 'Administrator'] }]
  entity Warehouses as projection on db.Warehouses;


    @readonly
    @Analytics.query: true
    @Aggregation.ApplySupported: {
        Transformations      : ['aggregate', 'groupby', 'filter', 'orderby', 'top', 'skip', 'search'],
        Rollup               : #None,
        PropertyRestrictions : true,
        GroupableProperties  : [MovementType, MovementDate],
        AggregatableProperties: [
            { Property: Quantity      },
            { Property: movementCount }
        ]
    }
    @Analytics.AggregatedProperty #totalQty: {
        Name                : 'totalQty',
        AggregationMethod   : 'sum',
        AggregatableProperty: 'Quantity',
        ![@Common.Label]    : 'Total Quantity Moved'
    }
    @Analytics.AggregatedProperty #totalMovements: {
        Name                : 'totalMovements',
        AggregationMethod   : 'sum',
        AggregatableProperty: 'movementCount',
        ![@Common.Label]    : 'Total Movements'
    }
    entity MovementKPIs as projection on db.MovementKPIs;
    action checkPendingStockMovements() returns String;
    //entity actionRequestedView as projection on db.actionRequestedView;


    
  
}