({
	doInit : function(component, event, helper) {
		helper.loadProductionServiceRTs(component, event );
	},
    cloneProductionService : function(component, event, helper) {
		helper.cloneThisProductionService( component, event );
	},
    dismissQuickAction : function(component, event, helper) {
		helper.closeQuickAction( component, event ); 
	}
})