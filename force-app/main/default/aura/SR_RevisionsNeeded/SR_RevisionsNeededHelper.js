({
    isUserAuthenticated : function(component, event, helper) {
        
        var recordId = component.get("v.recordId");
        console.log('--->'+recordId);
        var action = component.get("c.updateToRevNeeded");
        action.setParams({
            "SupportReqId" : recordId
        });
        
        action.setCallback(this, function( response ){
            
            var data = response.getReturnValue();
            console.log('===========>> return value:');
            console.log(data);
            
            var state = response.getState();
            if( state == "SUCCESS" ){
                
                if( data == "true" ) {
                    ($A.get("e.force:closeQuickAction")).fire();
                    
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "success",
                        "type" : "success",
                        "mode" : "dismissible",
                        "duration" : 5000,
                        "message": "Record Updated!"
                    });
                    toastEvent.fire();
                    $A.get('e.force:refreshView').fire();
                    
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
                    $A.get("e.force:closeQuickAction").fire();
                }else if (data == 'No Opportunity') {      // this else block is for SRSF-814
                    var toastEvent1 = $A.get("e.force:showToast");
                    toastEvent1.setParams({
                        "title": "Error!",
                        "type" : "error",
                        "mode" : "sticky",
                        "message": "Error: This Support Request cannot be edited because it's not associated with an Opportunity."
                    });
                    toastEvent1.fire();
                    $A.get("e.force:closeQuickAction").fire();
                } else if(data == 'DMLException') {      
                    
                    var toastEvent2 = $A.get("e.force:showToast");
                    toastEvent2.setParams({
                        "title": "Error!",
                        "type" : "error",
                        "mode" : "sticky",
                        "message": "Error: This Support Request cannot be edited because it's locked."
                    });
                    toastEvent2.fire();
                    $A.get("e.force:closeQuickAction").fire();
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
})