sap.ui.define([
    "sap/fe/test/JourneyRunner",
	"movementconsole/test/integration/pages/StockMovementsList",
	"movementconsole/test/integration/pages/StockMovementsObjectPage"
], function (JourneyRunner, StockMovementsList, StockMovementsObjectPage) {
    'use strict';

    var runner = new JourneyRunner({
        launchUrl: sap.ui.require.toUrl('movementconsole') + '/test/flp.html#app-preview',
        pages: {
			onTheStockMovementsList: StockMovementsList,
			onTheStockMovementsObjectPage: StockMovementsObjectPage
        },
        async: true
    });

    return runner;
});

