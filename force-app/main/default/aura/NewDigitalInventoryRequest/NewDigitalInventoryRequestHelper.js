({
	openNewDigitalInventoryRequest : function(component, event, helper) {
        var recordId = component.get("v.recordId");
		var action = component.get("c.createSupportRequest");
        action.setParams({
            "opptyId" : recordId,
            "selectedRequest" : "digitalInventoryRequest"
        }); 
        action.setCallback(this, function( response ){
            var state = response.getState();
            if( state == "SUCCESS" ){
                var data = response.getReturnValue();

                //console.log('****DEBUG LOG(openNewDigitalInventoryRequest)****' + data + "_");
                //console.log('typeof data = ' + typeof data);
       //         if(data == null && data == "") {
       // SRSF-437 (bab) above check wasn't working, because whoever coded it used && instead of ||. so I changed to if (!data) as a simpler solution
                if (!data) {
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Error!",
                        "type" : "error",
                        "mode" : "dismissible",
                        "duration" : 5000,
                        "message": "You are not allowed to create a Digital Inventory Request as you are not present in the Opportunity Team Member list."
                    });
                    toastEvent.fire();
                    var navEvt = $A.get("e.force:navigateToSObject");
                    navEvt.setParams({
                      "recordId": recordId,
                    });
                    navEvt.fire();
                }
                else{ 
                    //console.log('------->> creating Digital Inventory Record!!!');               
                    var createRecordEvent = $A.get("e.force:createRecord");
                    createRecordEvent.setParams( data );
                    createRecordEvent.fire();
                    helper.dismissQuickAction( component, event, helper );
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
    },
})