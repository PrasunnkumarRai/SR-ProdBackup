({
	verifyOpportunityTeamMember : function( component, event, helper ) {
		var recordId = component.get("v.recordId");
        console.log('----> RecordId : '+recordId); 
        var action = component.get("c.editSupportRequest");
        action.setParams({
            "recordId": component.get("v.recordId") 
        });
        action.setCallback(this, function( response ){
			var data = response.getReturnValue();
            console.log('===========>> return value:');
            console.log(data);
            var state = response.getState();
            if(response.getState()==='SUCCESS'){
                console.log('============')
                if( data == "true" ) {
                ($A.get("e.force:closeQuickAction")).fire();
                   var  editURL = "/"+recordId+"/e?nooverride=1&retURL=%2F"+recordId+"&saveURL=%2F"+recordId;
                   var urlEvent = $A.get("e.force:navigateToURL");
                    urlEvent.setParams({
                        "isredirect" : true,
                      "url": editURL
                    });                        
                    urlEvent.fire();
                }else if (data == 'false') {
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Error!",
                        "type" : "error",
                        "mode" : "dismissible",
                        "duration" : 5000,
                        "message": "You are not allowed to Edit this Request as You are not present in Opportunity Team Member list."
                    });
                    toastEvent.fire();
                    var navEvt = $A.get("e.force:navigateToSObject");
                    navEvt.setParams({
                      "recordId": recordId,
                    });
                    navEvt.fire();
                } else if (data == 'No Opportunity') {      // this else block is for SRSF-814
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Error!",
                        "type" : "error",
                        "mode" : "sticky",
                        "message": "Error: This Support Request cannot be edited because it's not associated with an Opportunity."
                    });
                    toastEvent.fire();
                    $A.get("e.force:closeQuickAction").fire();
                } else if (data == 'DMLException') {      // this else block is for SRSF-814
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Error!",
                        "type" : "error",
                        "mode" : "sticky",
                        "message": "Error: This Support Request cannot be edited because it's locked."
                    });
                    toastEvent.fire();
                    $A.get("e.force:closeQuickAction").fire();
                } else {    // SR is in the session cache, so just go back (prevents endless editing loop)
                    window.history.go(-1);
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
            }
        });
        $A.enqueueAction( action );
	},

})