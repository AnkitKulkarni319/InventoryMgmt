sap.ui.define([
    "sap/fe/test/JourneyRunner",
	"stockanalysis/test/integration/pages/MovementKPIsList",
	"stockanalysis/test/integration/pages/MovementKPIsObjectPage"
], function (JourneyRunner, MovementKPIsList, MovementKPIsObjectPage) {
    'use strict';

    var runner = new JourneyRunner({
        launchUrl: sap.ui.require.toUrl('stockanalysis') + '/test/flp.html#app-preview',
        pages: {
			onTheMovementKPIsList: MovementKPIsList,
			onTheMovementKPIsObjectPage: MovementKPIsObjectPage
        },
        async: true
    });

    return runner;
});

