({
	cloneSupportRequest : function( component, event, helper ) {
		var action = component.get("c.cloneThisSupportRequest");
        action.setParams({
            "recordId" : component.get("v.recordId")
        });
        action.setCallback(this, function( response ){
            console.log('---->getState: '+response.getState());
            var state = response.getState();
            if( state == "SUCCESS" ){
                if(response.getReturnValue() !=null){
                    $A.get("e.force:closeQuickAction").fire();
                var newSR = response.getReturnValue();
                component.set("v.recordId", newSR.Id);                               
                $A.get("e.force:navigateToSObject").setParams({
                    "recordId" : newSR.Id
                }).fire();
                
                $A.get("e.force:showToast").setParams({
                    "type" : "success",
                    "message" : 'Support Request '+newSR.Name+" was created."
                }).fire();
                }else{
                    var toastEvent = $A.get("e.force:showToast");
                     toastEvent.setParams({
                       mode: "sticky",
                       type:"error",
                       message: "You are not eligible to clone this Support Request as you are not on the Opportunity Team related to this request.",              
                     });
                     $A.get("e.force:closeQuickAction").fire();
                     toastEvent.fire();
                     $A.get("e.force:refreshView").fire();
                }
                
                
            }else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + 
                                 errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            } else {
                console.log('Unknown problem, state: ' + response.getState() + ', error: ' + response.getError());
            }
        });
        $A.enqueueAction( action );
	},

})