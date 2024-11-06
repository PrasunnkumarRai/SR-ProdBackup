({
	init : function(component, event, helper) {
		var pageReference = component.get("v.pageReference");
		component.set("v.accountid__c", pageReference.state.accountid__c);
        component.set("v.accountrequest__c", pageReference.state.accountrequest__c);
	},
    
    onPageReferenceChanged: function(component, event, helper) {
        var pageReference = component.get("v.pageReference");
		component.set("v.accountid__c", pageReference.state.accountid__c);
        component.set("v.accountrequest__c", pageReference.state.accountrequest__c);
        $A.get('e.force:refreshView').fire();
    }
})