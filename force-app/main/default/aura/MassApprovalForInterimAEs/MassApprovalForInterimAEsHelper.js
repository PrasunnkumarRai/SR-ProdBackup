({
    fetchInterimAEAccountsList : function(component, event, helper) {
    	var action = component.get('c.getInterimAEAccountsList');

        action.setCallback(this,function(response){
        	var state = response.getState(); 
        	if( state === "SUCCESS" ){
        		//alert('response>>>>>>'+response.getReturnValue());                
                if(response.getReturnValue() !=null && response.getReturnValue() !=''){
                	component.set('v.interimAEAccountsList', response.getReturnValue());
                } else {
                	component.find('notifLib').showToast({
                        "variant": "warning",
                        "title": "",
                        "mode" : "dismissable",
                        'message': $A.get("$Label.c.No_records_found_for_Approval")
                    });
                }
            }else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + 
                                 errors[0].message);                    
                        component.find('notifLib').showToast({
	                        "variant": "error",
	                        "title": "Error!",
	                        "mode" : "dismissable",
	                        'message': errors[0].message
	                    });
                    }
                } else {
                    console.log("Unknown error");
                }
            }

        	/*try{
        		console.log('>>>>>'+response.getReturnValue());
        		component.set('v.interimAEAccountsList', response.getReturnValue());
        		console.log('interim AE Accounts>>>'+component.get('v.interimAEAccountsList'));
        	}catch(e){}*/
        });

        $A.enqueueAction(action);
    }
})