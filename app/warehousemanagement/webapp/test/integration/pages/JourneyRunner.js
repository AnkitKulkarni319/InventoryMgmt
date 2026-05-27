sap.ui.define([
    "sap/fe/test/JourneyRunner",
	"warehousemanagement/test/integration/pages/WarehousesList",
	"warehousemanagement/test/integration/pages/WarehousesObjectPage"
], function (JourneyRunner, WarehousesList, WarehousesObjectPage) {
    'use strict';

    var runner = new JourneyRunner({
        launchUrl: sap.ui.require.toUrl('warehousemanagement') + '/test/flp.html#app-preview',
        pages: {
			onTheWarehousesList: WarehousesList,
			onTheWarehousesObjectPage: WarehousesObjectPage
        },
        async: true
    });

    return runner;
});

