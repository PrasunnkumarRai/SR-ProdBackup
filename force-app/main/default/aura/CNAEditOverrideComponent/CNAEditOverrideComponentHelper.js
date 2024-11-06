({
	verifyAccountTeamMember : function( component, event, helper ) {
		var recordId = component.get("v.recordId");
        console.log('----> RecordId : '+recordId); 
        var action = component.get("c.checkAccountTeamMember");
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
                  var  editURL = "/"+recordId+"/e?nooverride=1&retURL=%2F"+recordId+"&saveURL=%2F"+recordId;
                   var urlEvent = $A.get("e.force:navigateToURL");
                    urlEvent.setParams({
                        "isredirect" : true,
                      "url": editURL
                    });                        
                    urlEvent.fire(); 
                  /*  var editRecordEvent = $A.get("e.force:editRecord");
                    editRecordEvent.setParams({
                         "recordId": component.get("v.recordId")
                    });
                    editRecordEvent.fire();
                    var urlclose = $A.get("e.force:closeQuickAction").fire(); */
                }else if (data == "oppfalse") {
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Error!",
                        "type" : "error",
                        "mode" : "dismissible",
                        "duration" : 5000,
                        "message": "You are not allowed to edit this CNA as You are not present in Opportunity Team Member list."
                    });
                    toastEvent.fire();
                    var navEvt = $A.get("e.force:navigateToSObject");
                    navEvt.setParams({
                      "recordId": recordId,
                    });
                    navEvt.fire();
                }else if (data == "accfalse") {
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Error!",
                        "type" : "error",
                        "mode" : "dismissible",
                        "duration" : 5000,
                        "message": "You are not allowed to edit this CNA as You are not present in Account Team Member list."
                    });
                    toastEvent.fire();
                    var navEvt = $A.get("e.force:navigateToSObject");
                    navEvt.setParams({
                      "recordId": recordId,
                    });
                    navEvt.fire();

            } else {    // CNA is in the session cache, so just go back (prevents endless editing loop)
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