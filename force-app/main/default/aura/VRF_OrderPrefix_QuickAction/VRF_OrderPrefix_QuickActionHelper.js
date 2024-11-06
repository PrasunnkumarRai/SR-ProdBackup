({
    getUrl : function(component) {

        var action  = component.get("c.getOrderPrefixUrl");

        action.setCallback(this, function(response){

            var state = response.getState();
         
            if (state == "SUCCESS"){
            
                var url = response.getReturnValue();

                console.log(url);

                component.set("v.OrderPrefixUrl", url);
    
            }else{
                console.log("Error: ");  

                toastEvent.setParams({
                    "type" : "error",
                    "title": "Error",
                    "message": "An Error has occur. Please contact your system administrator."
                });
                
                toastEvent.fire();
            }

        });

        $A.enqueueAction(action);
    }
})