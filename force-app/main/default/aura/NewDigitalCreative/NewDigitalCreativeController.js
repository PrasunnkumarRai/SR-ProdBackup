({
	doInit : function(component, event, helper) {
        helper.getDigitalCreativeRecordTypes( component, event, helper );
	},
    createNewDCreative : function(component, event, helper) {
        helper.createNewDCreative( component, event, helper );
    },
    dismissQuickAction : function(component, event, helper){
        helper.dismissQuickAction( component, event, helper );
    }
})