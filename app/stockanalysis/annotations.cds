using MovementService as service from '../../srv/service';


annotate service.MovementKPIs with {
    MovementType  @Analytics.Dimension : true  @Common.Label: 'Movement Type';
    MovementDate  @Analytics.Dimension : true  @Common.Label: 'Movement Date';
    Quantity      @Analytics.Measure   : true  @Common.Label: 'Quantity';
    movementCount @Analytics.Measure   : true  @Common.Label: 'Movement Count';
};


annotate service.MovementKPIs with @(

    UI.SelectionFields: [MovementType, MovementDate],

    UI.KPITag #totalMovementsToday: {
        $Type    : 'UI.KPITagType',
        DataPoint: '@UI.DataPoint#totalMovements',
        Label    : 'Total Movements Today'
    },
    UI.KPITag #goodsReceiptsToday: {
        $Type    : 'UI.KPITagType',
        DataPoint: '@UI.DataPoint#goodsReceipts',
        Label    : 'Goods Receipts Today'
    },
    UI.KPITag #goodsIssuesToday: {
        $Type    : 'UI.KPITagType',
        DataPoint: '@UI.DataPoint#goodsIssues',
        Label    : 'Goods Issues Today'
    },

    UI.DataPoint #totalMovements: {
        Value      : movementCount,
        Title      : 'Total Movements',
        Description: 'All stock movements today',
        Criticality: #Positive
    },
    UI.DataPoint #goodsReceipts: {
        Value      : movementCount,
        Title      : 'Goods Receipts',
        Description: 'Inbound movements today',
        Criticality: #Positive
    },
    UI.DataPoint #goodsIssues: {
        Value      : movementCount,
        Title      : 'Goods Issues',
        Description: 'Outbound movements today',
        Criticality: #Critical
    },

    UI.Chart: {
        $Type          : 'UI.ChartDefinitionType',
        Title          : 'Stock Movements Today',
        ChartType      : #Column,
        Dimensions     : [MovementType],
        DimensionAttributes: [{
            $Type    : 'UI.ChartDimensionAttributeType',
            Dimension: MovementType,
            Role     : #Category
        }],
        DynamicMeasures: ['@Analytics.AggregatedProperty#totalMovements'],
        MeasureAttributes: [{
            $Type         : 'UI.ChartMeasureAttributeType',
            DynamicMeasure: '@Analytics.AggregatedProperty#totalMovements',
            Role          : #Axis1
        }]
    },

    UI.LineItem: [
        { $Type: 'UI.DataField', Value: MovementType,  Label: 'Type'     },
        { $Type: 'UI.DataField', Value: MovementDate,  Label: 'Date'     },
     
    ],

    UI.PresentationVariant: {
        $Type         : 'UI.PresentationVariantType',
        Visualizations: ['@UI.Chart', '@UI.LineItem'],
        SortOrder     : [{
            Property  : MovementDate,
            Descending: true
        }]
    },

   
    UI.HeaderInfo: {
        TypeName      : 'Stock Movement',
        TypeNamePlural: 'Stock Movements',
        
        Title: {
            $Type: 'UI.DataField',
            Value: MovementType
        },
  
        Description: {
            $Type: 'UI.DataField',
            Value: MovementDate
        }
    },


    UI.Facets: [{
        $Type : 'UI.CollectionFacet',
        ID    : 'InfoSection',
        Label : 'Information',
        Facets: [{
            $Type : 'UI.ReferenceFacet',
            ID    : 'InfoFacet',
            Label : 'Note',
            Target: '@UI.FieldGroup#ReadOnlyNote'
        }]
    }],

    UI.FieldGroup #ReadOnlyNote: {
        $Type: 'UI.FieldGroupType',
        Label: 'Analytics View',
        Data : [
            {
                $Type: 'UI.DataField',
                Value: MovementType,
                Label: 'Movement Type'
            },
            {
                $Type: 'UI.DataField',
                Value: MovementDate,
                Label: 'Movement Date'
            },
            {
                $Type: 'UI.DataField',
                Value: Quantity,
                Label: 'Quantity'
            },
            {
                $Type      : 'UI.DataField',
                Value      : movementCount,
                Label      : 'Count'
            }
        ]
    }
);


annotate service.MovementKPIs with @(
    Capabilities.UpdateRestrictions: { Updatable: false },
    Capabilities.DeleteRestrictions: { Deletable: false },
    Capabilities.InsertRestrictions: { Insertable: false }
);