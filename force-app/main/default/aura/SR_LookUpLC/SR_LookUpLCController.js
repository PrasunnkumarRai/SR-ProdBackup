({
    /**Method Name:search
     * Description:Search an SObject for a match
     */
	search : function(cmp, event, helper) {
		helper.doSearch(cmp);  
        var cmpTarget = cmp.find('lookup-pill');
         var lookUpList = cmp.find('lookuplist');
         $A.util.addClass(lookUpList, 'slds-lookup__menu slds-show');
        $A.util.removeClass(lookUpList, 'slds-lookup__menu slds-hide');
    },
    /**Method Name:select
     * Description:Select an SObject from a list
     */
    select: function(cmp, event, helper) {
    	helper.handleSelection(cmp, event);
        var cmpTarget = cmp.find('lookup-pill');
         var lookUpList = cmp.find('lookuplist');
         $A.util.addClass(lookUpList, 'slds-lookup__menu slds-hide');
        $A.util.removeClass(lookUpList, 'slds-lookup__menu slds-show');
    },
    
    /**Method Name:clear
     * Description:Clear the currently selected SObject
     */
    clear: function(cmp, event, helper) {
    	helper.clearSelection(cmp);    
    },
    
    /**Method Name:clear
     * Description:Clear the currently selected SObject
     */
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
    },
    
})