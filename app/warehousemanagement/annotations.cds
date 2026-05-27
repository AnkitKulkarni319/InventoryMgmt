using InventoryService as service from '../../srv/service';

annotate service.Warehouses with {
    Latitude  @readonly  @UI.Hidden;
    Longitude @readonly  @UI.Hidden;
    MapUrl    @readonly  @title: 'View on Map';
}

annotate service.Warehouses with @(

    UI.FieldGroup #GeneratedGroup : {
        $Type : 'UI.FieldGroupType',
        Data  : [
            {
                $Type : 'UI.DataField',
                Label : 'WarehouseCode',
                Value : WarehouseCode,
            },
            {
                $Type : 'UI.DataField',
                Label : 'Name',
                Value : Name,
            },
            {
                $Type : 'UI.DataField',
                Label : 'Location',
                Value : Location,
            },
            {
                $Type : 'UI.DataField',
                Label : 'Capacity',
                Value : Capacity,
            },
          
            {
                $Type          : 'UI.DataFieldWithUrl',
                Label          : 'View on Map',
                Value          : MapUrl,
                Url            : MapUrl,
                UrlContentType : #StandardLink,
            },
        ],
    },

    UI.LineItem : [
        {
            $Type : 'UI.DataField',
            Label : 'WarehouseCode',
            Value : WarehouseCode,
        },
        {
            $Type : 'UI.DataField',
            Label : 'Name',
            Value : Name,
        },
        {
            $Type : 'UI.DataField',
            Label : 'Location',
            Value : Location,
        },
        {
            $Type : 'UI.DataField',
            Label : 'Capacity',
            Value : Capacity,
        },

        {
            $Type          : 'UI.DataFieldWithUrl',
            Label          : 'Map',
            Value          : MapUrl,
            Url            : MapUrl,
            UrlContentType : #StandardLink,
        },
    ],

    UI.Facets : [
        {
            $Type  : 'UI.ReferenceFacet',
            ID     : 'GeneratedFacet1',
            Label  : 'General Information',
            Target : '@UI.FieldGroup#GeneratedGroup',
        },
    ],

    UI.Identification : [
        {
            $Type  : 'UI.DataFieldForAction',
            Action : 'InventoryService.checkLocation',
            Label  : 'Check Location',
        }
    ]
);