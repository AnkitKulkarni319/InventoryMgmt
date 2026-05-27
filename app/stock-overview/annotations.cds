using InventoryService as service from '../../srv/service';

annotate service.Products with @(

    Capabilities.InsertRestrictions : { Insertable : true },
    Capabilities.UpdateRestrictions : { Updatable : true },
    Capabilities.DeleteRestrictions : { Deletable : true },

    UI.HeaderInfo : {
        TypeName       : 'Product',
        TypeNamePlural : 'Products',

        Title : {
            $Type : 'UI.DataField',
            Value : Name
        },

        Description : {
            $Type : 'UI.DataField',
            Value : ProductCode
        }
    },

    UI.LineItem : [

        { $Type : 'UI.DataField', Label : 'Product Code', Value : ProductCode },
        { $Type : 'UI.DataField', Label : 'Name', Value : Name },
        { $Type : 'UI.DataField', Label : 'Description', Value : Description },
        { $Type : 'UI.DataField', Label : 'Unit Of Measure', Value : UnitOfMeasure },

        {
            $Type : 'UI.DataField',
            Label : 'Min Stock Level',
            Value : MinStockLevel,
            Criticality : #Negative
        }
    ],

    UI.SelectionFields : [
        ProductCode,
        Name,
        MinStockLevel
    ],

    UI.FieldGroup #GeneralInfo : {
        $Type : 'UI.FieldGroupType',
        Data : [
            { $Type : 'UI.DataField', Label : 'Product Code', Value : ProductCode },
            { $Type : 'UI.DataField', Label : 'Name', Value : Name },
            { $Type : 'UI.DataField', Label : 'Description', Value : Description },
            { $Type : 'UI.DataField', Label : 'Unit Of Measure', Value : UnitOfMeasure },
            { $Type : 'UI.DataField', Label : 'Min Stock Level', Value : MinStockLevel,
            //Criticality : (MinStockLevel<11?1:3) 
            },
            { $Type : 'UI.DataField', Label : 'Max Stock Level', Value : MaxStockLevel },
            { $Type : 'UI.DataField', Label : 'Category', Value : Category_ID }
        ]
    },

    UI.Facets : [
        {
            $Type  : 'UI.ReferenceFacet',
            ID     : 'GeneralFacet',
            Label  : 'General Information',
            Target : '@UI.FieldGroup#GeneralInfo'
        },
        {
            $Type  : 'UI.ReferenceFacet',
            ID     : 'StockFacet',
            Label  : 'Stock by Warehouse',
            Target : 'StockLevels/@UI.LineItem#StockLevels'
        }
    ]
);

annotate service.Products with {

    Category @(
        Common.Text : Category.CategoryName,
        Common.TextArrangement : #TextOnly,

        Common.ValueList : {
            $Type          : 'Common.ValueListType',
            CollectionPath : 'Categories',
            Parameters     : [
                {
                    $Type             : 'Common.ValueListParameterInOut',
                    LocalDataProperty : Category_ID,
                    ValueListProperty : 'ID'
                },
                {
                    $Type             : 'Common.ValueListParameterDisplayOnly',
                    ValueListProperty : 'CategoryCode'
                },
                {
                    $Type             : 'Common.ValueListParameterDisplayOnly',
                    ValueListProperty : 'CategoryName'
                }
            ]
        }
    );
};

annotate service.StockLevels with @(

    Capabilities.InsertRestrictions : { Insertable : true },
    Capabilities.UpdateRestrictions : { Updatable  : true },
    Capabilities.DeleteRestrictions : { Deletable  : true },

    UI.HeaderInfo : {
        TypeName       : 'Stock Level',
        TypeNamePlural : 'Stock Levels',

        Title : {
            $Type : 'UI.DataField',
            Value : Product.Name
        },

        Description : {
            $Type : 'UI.DataField',
            Value : Warehouse.Name
        }
    },

    UI.LineItem #StockLevels : [

        {
            $Type : 'UI.DataField',
            Label : 'Warehouse',
            Value : Warehouse_ID
        },
      
        {
            $Type : 'UI.DataField',
            Label : 'Current Stock',
            Value : CurrentStock
        },
        {
            $Type : 'UI.DataField',
            Label : 'Reserved Stock',
            Value : ReservedStock
        },
        {
            $Type : 'UI.DataField',
            Label : 'Available Stock',
            Value : AvailableStock
        }
    ],

    UI.FieldGroup #StockCreate : {
        $Type : 'UI.FieldGroupType',
        Data  : [
            {
                $Type : 'UI.DataField',
                Label : 'Warehouse',
                Value : Warehouse_ID
            },
        
            {
                $Type : 'UI.DataField',
                Label : 'Current Stock',
                Value : CurrentStock
            },
            {
                $Type : 'UI.DataField',
                Label : 'Reserved Stock',
                Value : ReservedStock
            },
            {
                $Type : 'UI.DataField',
                Label : 'Available Stock',
                Value : AvailableStock
            }
        ]
    }
);

annotate service.StockLevels with {

    Warehouse @(
        Common.Text : Warehouse.Name,
        Common.TextArrangement : #TextFirst,

        Common.ValueList : {
            $Type          : 'Common.ValueListType',
            CollectionPath : 'Warehouses',
            Parameters     : [
                {
                    $Type             : 'Common.ValueListParameterInOut',
                    LocalDataProperty : Warehouse_ID,
                    ValueListProperty : 'ID'
                },
                {
                    $Type             : 'Common.ValueListParameterDisplayOnly',
                    ValueListProperty : 'WarehouseCode'
                },
                {
                    $Type             : 'Common.ValueListParameterDisplayOnly',
                    ValueListProperty : 'Name'
                },
                {
                    $Type             : 'Common.ValueListParameterDisplayOnly',
                    ValueListProperty : 'Location'
                }
            ]
        }
    );

    Product @(
        Common.Text : Product.Name,
        Common.TextArrangement : #TextFirst
    );

    AvailableStock @(
        Core.Computed   : true,
        UI.HiddenFilter : true
    );

    ID         @UI.Hidden : true;
    Product    @UI.Hidden : true;

    createdBy  @UI.Hidden : true;
    createdAt  @UI.Hidden : true;
    modifiedBy @UI.Hidden : true;
    modifiedAt @UI.Hidden : true;
};