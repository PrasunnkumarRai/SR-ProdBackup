({
    openNewAudienceRequest : function( component, event, helper ) {
        console.log ('inside openNewAudienceRequest>>>>>');
        var recordId = component.get("v.recordId");
        var action = component.get("c.createSupportRequest");
        action.setParams({
            "opptyId" : recordId,
            "selectedRequest" : "audienceRequest"
        }); 
        action.setCallback(this, function( response ){
            var state = response.getState();
            if( state == "SUCCESS" ){
                var data = response.getReturnValue();
                
                if(data == "" || data == null){
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Error!",
                        "type" : "error",
                        "mode" : "dismissible",
                        "duration" : 5000,
                        "message": "You are not allowed to create a Audience Request as you are not present in the Opportunity Team Member list."
                    });
                    toastEvent.fire();
                    var navEvt = $A.get("e.force:navigateToSObject");
                    navEvt.setParams({
                      "recordId": recordId,
                    });
                    navEvt.fire();
                }
                else{
                    component.set("v.recordData", data);
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
    clear : function (component, helper) {
        console.log ('inside clear >>>>');
        component.set('v.loaded', !component.get('v.loaded'));
        component.find("audReqField").forEach(function(f) {
            f.reset();
        })     
    }
})