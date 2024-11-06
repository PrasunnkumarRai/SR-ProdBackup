({
	doInit : function(component, event, helper) {
        helper.loadDCRecordTypes( component, event, helper );
	},
    createNewCampaign : function(component, event, helper) {
        helper.createNewCampaign( component, event, helper );
    },
    dismissQuickAction : function(component, event, helper){
        helper.dismissQuickAction( component, event, helper );
    }
})