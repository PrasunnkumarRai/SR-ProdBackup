({
	openPostPlanningRequest : function( component, event, helper ) {
        var recordId = component.get("v.recordId");
		var action = component.get("c.createPostPlanningSupportRequest");
        action.setParams({
            "suppReq" : recordId
        }); 
        action.setCallback(this, function( response ){
            var state = response.getState();
            if( state == "SUCCESS" ){
                var data = response.getReturnValue();
                var createRecordEvent = $A.get("e.force:createRecord");
                createRecordEvent.setParams( data );
                createRecordEvent.fire();
                helper.dismissQuickAction( component, event, helper );
            }
             else {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + 
                                 errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
        $A.enqueueAction( action );
	},
    dismissQuickAction : function( component, event, helper ){
        var dismissActionPanel = $A.get("e.force:closeQuickAction");
        dismissActionPanel.fire();
    }
})