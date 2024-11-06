({
	doInit: function(component, event, helper) {
		//this.search(component, event, helper);
	},
    /**
     * Search an SObject for a match
     */
	search : function(cmp, event, helper) {
		  
        var cmpTarget = cmp.find('lookup-pill');
         var lookUpList = cmp.find('lookuplist');
         $A.util.addClass(lookUpList, 'slds-lookup__menu slds-show');
        $A.util.removeClass(lookUpList, 'slds-lookup__menu slds-hide');
        helper.doSearch(cmp);
    },
    /**
     * Select an SObject from a list
     */
    select: function(cmp, event, helper) {
    	helper.handleSelection(cmp, event);
        var cmpTarget = cmp.find('lookup-pill');
         var lookUpList = cmp.find('lookuplist');
         $A.util.addClass(lookUpList, 'slds-lookup__menu slds-hide');
        $A.util.removeClass(lookUpList, 'slds-lookup__menu slds-show');
    },
    
    /**
     * Clear the currently selected SObject
     */
    clear: function(cmp, event, helper) {
    	event.preventDefault();
    	helper.clearSelection(cmp);    
    },
    clearlookUp: function(cmp, event, helper) {
    	//event.preventDefault();
    	//console.log('clear lookup after assign in controller');
    	helper.clearCompletelookup(cmp);
    
    },
    clearData:function(cmp,event,helper){
    	
        //helper.displayToast('Error', 'Unknown error.'); // commented temporarily by suresh on 06/09/2017
        event.preventDefault();
        // Create the ClearLookupId event
        var clearEvent = cmp.getEvent("clearLookupIdEvent");

        // Get the Instance Id of the Component
        var instanceId = cmp.get('v.instanceId');

        // Populate the event with the Instance Id
        clearEvent.setParams({
            "instanceId" : instanceId
        });
        
        // Fire the event
        clearEvent.fire();

        // Clear the Searchstring
        cmp.set("v.searchString", '');

        // Hide the Lookup pill
        var lookupPill = cmp.find("lookup-pill");
        $A.util.addClass(lookupPill, 'slds-hide');
        
        // Hide the lookuplist
        var lookuplist = cmp.find("lookuplist");
                 $A.util.removeClass(lookuplist, 'slds-show');
        $A.util.addClass(lookuplist, 'slds-hide');

        // Show the Input Element
        var inputElement = cmp.find('lookup');
        $A.util.removeClass(inputElement, 'slds-hide');
        
        // Show the Input Element
        var inputElement = cmp.find('lookup');
        $A.util.removeClass(inputElement, 'slds-hide');
    },
    
})