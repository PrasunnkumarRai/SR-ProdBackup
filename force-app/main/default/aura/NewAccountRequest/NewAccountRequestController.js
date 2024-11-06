({
	doInit : function(component, event, helper) {
		helper.loadARRecordTypes( component, event, helper );
    },
    onRecordTypeChange : function(component, event, helper) {
        helper.recordTypeChanged( component, event, helper );
    },
    createNewAccountRequest : function( component, event, helper ){
        helper.createNewAccountRequestHelper( component, event, helper );
    },
    checkForAEInAccTeamJS : function( component, event, helper ){
        //event.preventDefault();
        helper.checkForAEInAccTeamHelper( component, event, helper );
    },
    SaveData : function( component, event, helper ){
        helper.SaveDataHelper( component, event, helper );
    },
    dismissQuickAction : function( component, event, helper ){
        helper.dismissQuickActionHelper( component, event, helper );
    },
    showSpinner: function(component, event, helper) {
    	component.set("v.Spinner", true); 
    },
    hideSpinner : function(component,event,helper){
        component.set("v.Spinner", false);
    },
})