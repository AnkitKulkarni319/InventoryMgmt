using MovementService as service from '../../srv/service';

annotate service.StockMovements with {
    Product       @Common.Text: Product.Name       @Common.TextArrangement: #TextFirst;
    FromWarehouse @Common.Text: FromWarehouse.Name @Common.TextArrangement: #TextFirst;
    ToWarehouse   @Common.Text: ToWarehouse.Name   @Common.TextArrangement: #TextFirst;

    MovementType @UI.Hidden: {
        $edmJson: {
            $If: [
                { $Eq: [ { $Path: 'IsActiveEntity' }, false ] },
                true,
                false
            ]
        }
    };
};

annotate service.StockMovements with {

    ActionRequested @Common.ValueListWithFixedValues: true;

    Product @Common.ValueList: {
        $Type         : 'Common.ValueListType',
        CollectionPath: 'Products',
        Parameters    : [
            {
                $Type: 'Common.ValueListParameterInOut',
                LocalDataProperty: Product_ID,
                ValueListProperty: 'ID'
            },
            {
                $Type: 'Common.ValueListParameterDisplayOnly',
                ValueListProperty: 'Name'
            }
        ]
    };

    FromWarehouse @Common.ValueList: {
        $Type         : 'Common.ValueListType',
        CollectionPath: 'Warehouses',
        Parameters    : [
            {
                $Type: 'Common.ValueListParameterInOut',
                LocalDataProperty: FromWarehouse_ID,
                ValueListProperty: 'ID'
            },
            {
                $Type: 'Common.ValueListParameterDisplayOnly',
                ValueListProperty: 'Name'
            }
        ]
    };

    ToWarehouse @Common.ValueList: {
        $Type         : 'Common.ValueListType',
        CollectionPath: 'Warehouses',
        Parameters    : [
            {
                $Type: 'Common.ValueListParameterInOut',
                LocalDataProperty: ToWarehouse_ID,
                ValueListProperty: 'ID'
            },
            {
                $Type: 'Common.ValueListParameterDisplayOnly',
                ValueListProperty: 'Name'
            }
        ]
    };

    FromWarehouse @Common.FieldControl: {
        $edmJson: {
            $If: [
                { $Eq: [ { $Path: 'ActionRequested' }, 'GoodsIssue' ] },
                3,
                {
                    $If: [
                        { $Eq: [ { $Path: 'ActionRequested' }, 'Transfer' ] },
                        3,
                        1
                    ]
                }
            ]
        }
    };

    ToWarehouse @Common.FieldControl: {
        $edmJson: {
            $If: [
                { $Eq: [ { $Path: 'ActionRequested' }, 'GoodsReceipt' ] },
                3,
                {
                    $If: [
                        { $Eq: [ { $Path: 'ActionRequested' }, 'Transfer' ] },
                        3,
                        1
                    ]
                }
            ]
        }
    };
};

annotate service.StockMovements with @(
    UI.SelectionFields: [
        ActionRequested,
        Product_ID,
        MovementDate
    ],

    UI.LineItem: [
        {
            $Type: 'UI.DataField',
            Value: ActionRequested,
            Label: 'Action Requested'
        },
        {
            $Type: 'UI.DataField',
            Value: Product_ID,
            Label: 'Product'
        },
        {
            $Type: 'UI.DataField',
            Value: Quantity,
            Label: 'Quantity'
        },
        {
            $Type: 'UI.DataField',
            Value: FromWarehouse_ID,
            Label: 'From Warehouse'
        },
        {
            $Type: 'UI.DataField',
            Value: ToWarehouse_ID,
            Label: 'To Warehouse'
        },
        {
            $Type: 'UI.DataField',
            Value: MovementType,
            Label: 'Processed Type'
        },

        {
            $Type  : 'UI.DataFieldForAction',
            Action : 'MovementService.goodsReceipt',
            Label  : 'Goods Receipt',

            ![@Core.OperationAvailable]: {
                $edmJson: {
                    $And: [
                        { $Eq: [ { $Path: 'IsActiveEntity' }, true ] },
                        { $Eq: [ { $Path: 'ActionRequested' }, 'GoodsReceipt' ] },
                        { $Eq: [ { $Path: 'MovementType' }, null ] }
                    ]
                }
            }
        },

        {
            $Type  : 'UI.DataFieldForAction',
            Action : 'MovementService.goodsIssue',
            Label  : 'Goods Issue',

            ![@Core.OperationAvailable]: {
                $edmJson: {
                    $And: [
                        { $Eq: [ { $Path: 'IsActiveEntity' }, true ] },
                        { $Eq: [ { $Path: 'ActionRequested' }, 'GoodsIssue' ] },
                        { $Eq: [ { $Path: 'MovementType' }, null ] }
                    ]
                }
            }
        },

        {
            $Type  : 'UI.DataFieldForAction',
            Action : 'MovementService.stockTransfer',
            Label  : 'Stock Transfer',

            ![@Core.OperationAvailable]: {
                $edmJson: {
                    $And: [
                        { $Eq: [ { $Path: 'IsActiveEntity' }, true ] },
                        { $Eq: [ { $Path: 'ActionRequested' }, 'Transfer' ] },
                        { $Eq: [ { $Path: 'MovementType' }, null ] }
                    ]
                }
            }
        }
    ]
);

annotate service.StockMovements with @(
    UI.HeaderInfo: {
        TypeName       : 'Stock Movement',
        TypeNamePlural : 'Stock Movements',
        Title          : { Value: Product.Name },
        Description    : { Value: MovementType }
    },

    UI.Facets: [
        {
            $Type  : 'UI.ReferenceFacet',
            Label  : 'General Information',
            Target : '@UI.FieldGroup#General'
        },
        {
            $Type  : 'UI.ReferenceFacet',
            Label  : 'Warehouse Details',
            Target : '@UI.FieldGroup#Warehouse'
        },
        {
            $Type  : 'UI.ReferenceFacet',
            Label  : 'Administrative Info',
            Target : '@UI.FieldGroup#Admin'
        }
    ],

    UI.FieldGroup #General: {
        Data: [
            { Value: ActionRequested },
            { Value: Product_ID },
            { Value: Quantity },
            { Value: MovementDate }
        ]
    },

    UI.FieldGroup #Warehouse: {
        Data: [
            { Value: FromWarehouse_ID },
            { Value: ToWarehouse_ID }
        ]
    },

    UI.FieldGroup #Admin: {
        Data: [
            { Value: MovedBy },
            { Value: createdAt },
            { Value: createdBy },
            { Value: modifiedAt },
            { Value: modifiedBy }
        ]
    }
);

annotate service.Products with {
    ID @Common.Text: Name
       @Common.TextArrangement: #TextFirst
};

annotate service.Warehouses with {
    ID @Common.Text: Name
       @Common.TextArrangement: #TextFirst
};

  