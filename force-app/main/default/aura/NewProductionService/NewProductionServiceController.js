({
	doInit : function(component, event, helper) {
        helper.loadPSRecordTypes( component, event, helper );
	},
    createNewPService : function(component, event, helper) {
        helper.createNewPService( component, event, helper );
    },
    dismissQuickAction : function(component, event, helper){
        helper.dismissQuickAction( component, event, helper );
    }
})