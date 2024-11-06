({
	openNewPlanningRequest : function( component, event, helper ) {
        var recordId = component.get("v.recordId");
		var action = component.get("c.createSupportRequest");
        action.setParams({
            "opptyId" : recordId,
            "selectedRequest" : "planningRequest"
        }); 
        action.setCallback(this, function( response ){
            var state = response.getState();
            if( state == "SUCCESS" ){
                var data = response.getReturnValue();
                console.log("data" , data);
                component.set("v.recordData", data);
                if(data == "" || data == null){
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Error!",
                        "type" : "error",
                        "mode" : "dismissible",
                        "duration" : 5000,
                        "message": "You are not allowed to create a Planning Request as you are not present in the Opportunity Team Member list."
                    });
                    toastEvent.fire();
                    var navEvt = $A.get("e.force:navigateToSObject");
                    navEvt.setParams({
                      "recordId": recordId,
                    });
                    navEvt.fire();
                }
                else if(data.errorMessage){
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Error!",
                        "type" : "error",
                        "mode" : "dismissible",
                        "duration" : 5000,
                        "message": "You cannot create a Planning Request if the Opportunity is 'Closed as Lost'."
                    });
                    toastEvent.fire();
                    helper.dismissQuickAction( component, event, helper );
                }
                else{
                    //Navigate to the new lightning component with data value because we need to autopopulate data in new lightning component
                    var navigateEvent = $A.get("e.force:navigateToComponent");
                    navigateEvent.setParams({
                            componentDef: "c:NewPlanningRequest",
                            componentAttributes: {
                                recordId: component.get("v.recordId"),
                                recordData: component.get("v.recordData"),
                                showModal: component.get("v.showModal")
                            }
                        });
                    navigateEvent.fire();
                    
                    
                    //alert(JSON.stringify(data));
	              /*  var createRecordEvent = $A.get("e.force:createRecord");
	                createRecordEvent.setParams( data );
	                createRecordEvent.fire();
	                helper.dismissQuickAction( component, event, helper );*/
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