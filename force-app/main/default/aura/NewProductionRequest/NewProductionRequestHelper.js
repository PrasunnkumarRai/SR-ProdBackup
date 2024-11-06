({
	openNewProductionRequest : function( component, event, helper ) {
        console.log ('inside openNewProductionRequest>>>>>>');
        var recordId = component.get("v.recordId");
		var action = component.get("c.createSupportRequest");
        action.setParams({
            "opptyId" : recordId,
            "selectedRequest" : "production"
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
                        "message": "You are not allowed to create a Production Request as you are not present in the Opportunity Team Member list."
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
        component.set('v.loaded', !component.get('v.loaded'));
        component.find("prodReqField").forEach(function(f) {
            f.reset();
        })     
    },
    validateform: function(component) {        
        var reqfelds = [].concat(component.find('prodReqField'));
        for(var i=0;i<reqfelds.length;i++){
            if($A.util.isEmpty(reqfelds[i].get("v.value")))
                return false;        
        }     
        return true; 
    },
    showerrorToast : function(component) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": "Required Field Error!",
            "type": "error",
            "message": "Please fill the required fields and then try to save again."
        });
        toastEvent.fire(); 
    }
})