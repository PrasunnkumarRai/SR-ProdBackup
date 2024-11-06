({
	init : function(component, event, helper) {
		var pageReference = component.get("v.pageReference");
		component.set("v.LeadId__c", pageReference.state.LeadId__c);
        component.set("v.IsOwnerActive__c", pageReference.state.IsOwnerActive__c);
        component.set("v.recordTypeId__c", pageReference.state.recordTypeId);
        helper.recordTypeHelper(component);
	},
    
    onPageReferenceChanged: function(component, event, helper) {
        var pageReference = component.get("v.pageReference");
		component.set("v.LeadId__c", pageReference.state.LeadId__c);
        component.set("v.IsOwnerActive__c", pageReference.state.IsOwnerActive__c);
        component.set("v.recordTypeId__c", pageReference.state.recordTypeId);
        helper.recordTypeHelper(component);
        $A.get('e.force:refreshView').fire();
    }
})