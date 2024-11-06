({
	cloneDigitalCampaign : function( component, event, helper ) {
		var action = component.get("c.cloneThisDigitalCampaign");
        action.setParams({
            "recordId" : component.get("v.recordId")
        });
        action.setCallback(this, function( response ){
            console.log('---->getState: '+response.getState());
            var state = response.getState();
            if( state == "SUCCESS" ){
                $A.get("e.force:closeQuickAction").fire();
                var newDC = response.getReturnValue();
                $A.get("e.force:navigateToSObject").setParams({
                    "recordId" : newDC.Id
                }).fire();
                $A.get("e.force:showToast").setParams({
                    "type" : "success",
                    "message" : 'Digital Campaign '+newDC.Name+" was created."
                }).fire();
            }else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + 
                                 errors[0].message);
                        this.showToast("error", "Error!",errors[0].message);
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
    //Message to display on Lightning Component after DML
    showToast : function( type, title, msg ){
        var durationval = (type=='error')? 10000 : 5000;
    	var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
    		"type": type,
            "title": title,
            "message": msg,
            "duration": durationval
        });
        toastEvent.fire();
    }
})