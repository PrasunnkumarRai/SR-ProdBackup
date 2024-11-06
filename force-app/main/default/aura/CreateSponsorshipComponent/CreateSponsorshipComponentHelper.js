({
	navigateToSponsorship : function( component, event, helper ) {
        var recordId = component.get("v.recordId");
        var userId = $A.get("$SObjectType.CurrentUser.Id");
        var initialUrl = window.location.origin;
		var action = component.get("c.checkTeamMember");
        action.setParams({
            "oppId" : recordId,
            "currentUser" : userId
        }); 
        action.setCallback(this, function( response ){
            var state = response.getState();
            if( state == "SUCCESS" ){
                var data = response.getReturnValue();
                if(data == false){
                    let toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Error!",
                        "type" : "error",
                        "mode" : "dismissible",
                        "duration" : 5000,
                        "message": "You are not allowed to create a Sponsorship as you are not present in the Opportunity Team Member list."
                    });
                    toastEvent.fire();
                    let navEvt = $A.get("e.force:navigateToSObject");
                    navEvt.setParams({
                      "recordId": recordId,
                    });
                    navEvt.fire();
                }
                else{ 
                    var urlEvent = $A.get("e.force:navigateToURL");
    				urlEvent.setParams({
      					"url": initialUrl+"/lightning/n/Sponsorship_Inventory_Graph?OpportunityId__c="+recordId
    				});
    				urlEvent.fire();
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
    /*dismissQuickAction : function( component, event, helper ){
        // Close the action panel
        var dismissActionPanel = $A.get("e.force:closeQuickAction");
        dismissActionPanel.fire();
    }*/
})