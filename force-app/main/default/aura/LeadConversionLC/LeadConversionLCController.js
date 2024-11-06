({
    doInit: function(component,event,helper) {
        helper.getDetails(component,event,helper);
    },
    
    onAccountChange : function(component,event,helper) {
        helper.changeOppName(component,event,helper);
    },
    
    getLookedUpAcc: function(component,event,helper) {
        helper.getLookedUpAcc(component,event,helper);
    },
    
    convertingLead : function(component,event,helper) {
        console.log('======>> in convertingLead, calling LeadConversion');
        helper.LeadConversion(component,event,helper);
    },

    cancelConversion : function(component, event, helper) {
        if (typeof sforce !== 'undefined' && typeof sforce.one !== 'undefined') {
            sforce.one.back(true);
        }
    },
    
    /**Method Name:handleAccountIdUpdate
     * Description:Handler for receiving the updateLookupIdEvent event
     */
    handleAccountIdUpdate : function(component,event,helper) {
        // Get the Id from the Event
        var accountId = event.getParam("sObjectId");
        
        console.log("accountId-----"+accountId);
        
        // Get the Instance Id from the Event
        var instanceId = event.getParam("instanceId");
        // Determine the instance Id of the component that fired the event
        if (instanceId == "myAccount")
        {
            // Set the Id bound to the View
            component.set('v.selAccount', accountId);
        }
        else if (instanceId == "myUser")
        {
            // Set the Id bound to the View
            component.set('v.selUser', accountId);
            helper.updateAECheck(component, event, helper, accountId);

        }
        else
        {
            console.log('Unknown instance id: ' + instanceId);
        }
    },

    /**Method Name:handleAccountIdClear
     * Description:Handler for receiving the clearLookupIdEvent event
    */
	handleAccountIdClear : function(component,event,helper) {
        // Get the Instance Id from the Event
        var instanceId = event.getParam("instanceId");

        // Determine the instance Id of the component that fired the event
        if (instanceId == "myAccount")
        {
            // Clear the Id bound to the View
            component.set('v.selAccount', null);
        }
        else if (instanceId == "myUser")
        {
            // Set the Id bound to the View
            component.set('v.selUser', null);
        }
        else
        {
            console.log('Unknown instance id: ' + instanceId);
        }
	}
})