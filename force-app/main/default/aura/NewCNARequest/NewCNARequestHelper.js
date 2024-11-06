({
	createCNARequest : function( component, event, helper ) {
		var action = component.get("c.createCNARequest");
        action.setParams({
            "opptyId" : component.get("v.recordId"),
        });
        action.setCallback(this,function( response ){
            var state = response.getState();
            if( state == "SUCCESS" ){
                if(response.getReturnValue() !=null){
                var data = response.getReturnValue();
                var createRecordEvent = $A.get("e.force:createRecord");
                createRecordEvent.setParams( data );
                createRecordEvent.fire();
                helper.dismissQuickAction( component, event, helper );
                }else{
                    var toastEvent = $A.get("e.force:showToast");
                     toastEvent.setParams({
                       mode: "sticky",
                       type:"error",
                       message: "You must be on the Opportunity Team in order to create a CNA on this Opportunity.",              
                     });
                     $A.get("e.force:closeQuickAction").fire();
                     toastEvent.fire();
                     $A.get("e.force:refreshView").fire();
                }
            }else if( state == "ERROR" ){
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
        // Close the action panel
        var dismissActionPanel = $A.get("e.force:closeQuickAction");
        dismissActionPanel.fire();
    }
})