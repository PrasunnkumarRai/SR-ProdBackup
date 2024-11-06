({
	fetchLinks : function(component, event, helper) {
		var action = component.get("c.getLinks");
        action.setParams({
            "strVisible": component.get("v.visibleTo")
        });
        action.setCallback(this,function(response){
            if(response.getState()==='SUCCESS'){
                component.set("v.urlArray",response.getReturnValue());
            }
        });$A.enqueueAction(action);
	}
})