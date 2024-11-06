({
	getTraffic : function(component, event) {
		console.log('-------><><> in helper:getTraffic');
		var acctId = component.get("v.recordId");
		var action = component.get("c.getEclipseTraffic");
		action.setParams({'acctId' : acctId});
		action.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                var retVal = response.getReturnValue();
                console.log('%%%%%%%%$$$$$$$--->> retVal = ' + retVal);
                console.log(retVal);
                component.set("v.trafficList", retVal);
                var numRecs = 0;
                if (retVal) {
                	numRecs = retVal.length;
                }
                component.set("v.numRecords", numRecs);
                
            }
		});
		$A.enqueueAction(action);
	},

})