({
	init : function(component, event, helper) {
		//var pageReference = component.get("v.pageReference");
		var navigateEvent = $A.get("e.force:navigateToComponent");
        var objectName = component.get("v.sObjectName")
        console.log('Object Name (In Aura Component) ====> ',objectName);
        navigateEvent.setParams({
            componentDef: "c:accountMergeLWC",
            componentAttributes: {
                parentRecordId: component.get("v.recordId"),
                objectName: component.get("v.sObjectName")
                            }
                        });
        
        navigateEvent.fire();
	}
})