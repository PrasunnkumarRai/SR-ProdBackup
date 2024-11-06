({
    /*
   	  Description	 : Controller to get the detials Tooltip Information
    */
    doInit : function(component, event, helper) 
    {
        var tooltip = $A.get("$Label.c.CM_Clone_Creative_Tooltip");
        var res = tooltip.replace(/\n/g, "<br/>");
        component.set("v.tooltipInfo", res);
        /*var getTooltipData = component.get("c.getTooltipInfo");
        getTooltipData.setCallback(this, function(response) {
            // Set the component attributes using values returned by the API call
            if (response.getState() === "SUCCESS")
            {
                component.set("v.tooltipInfo", response.getReturnValue());
             }
        });
        $A.enqueueAction(getTooltipData);*/
    },
    
    /**
     * Search an SObject for a match
     */
	search : function(cmp, event, helper) {
		helper.doSearch(cmp);  
        var cmpTarget = cmp.find('lookup-pill');
         var lookUpList = cmp.find('lookuplist');
         $A.util.addClass(lookUpList, 'slds-lookup__menu slds-show');
        $A.util.removeClass(lookUpList, 'slds-lookup__menu slds-hide');
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
        //To Digital Campaign Information unhiding
         var inputElement = cmp.find('toDigCamInfo');
        $A.util.removeClass(inputElement, 'slds-hide');
    },
    
    /**
     * Clear the currently selected SObject
     */
    clear: function(cmp, event, helper) {
    	helper.clearSelection(cmp);    
    },
    clearData:function(cmp,event,helper){
        helper.displayToast('Error', 'Unknown error.');
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
    }
    
})