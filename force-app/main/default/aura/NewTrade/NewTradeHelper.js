({
	openNewTrade : function( component, event, helper ) {
        var recordId = component.get("v.recordId");
		var action = component.get("c.createTrade");
        action.setParams({
            "opptyId" : recordId
        }); 
        action.setCallback(this, function( response ){
            //console.log('response--->'+JSON.stringify(response.getReturnValue()));
            //alert(JSON.stringify(response.getReturnValue()));
           // if(typeof  response.getReturnValue() === undefined){
            var state = response.getState();
            if( state == "SUCCESS" ){
                //if(typeof  response.getReturnValue() === "undefined"){  
                if(response.getReturnValue() !=null){
                //console.log('response--->'+response);
                //alert('response');
                
                var data = response.getReturnValue();
                //console.log('****DEBUG LOG ****' + data + "_");
                var createRecordEvent = $A.get("e.force:createRecord");
                createRecordEvent.setParams( data );
                createRecordEvent.fire();
                helper.dismissQuickAction( component, event, helper );
                }else{    
                    //component.set("v.ErrorBoolean",false);
                    var toastEvent = $A.get("e.force:showToast");
                     toastEvent.setParams({
                       mode: "sticky",
                       type:"error",
                       message: "You are not eligible to create a Trade as you are not on the Opportunity Team.",              
                     });
                     $A.get("e.force:closeQuickAction").fire();
                     toastEvent.fire();
                     $A.get("e.force:refreshView").fire();
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