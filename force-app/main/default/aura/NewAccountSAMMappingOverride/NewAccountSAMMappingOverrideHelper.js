({
    openNewSAMMapping : function( component, event, helper) {  
        var action = component.get("c.createAccountSAMMapping");
        action.setParams({
            "accountValue" : component.get("v.recordId")
        }); 
        action.setCallback(this, function( response ){
            var state = response.getState();
            if( state == "SUCCESS" ){
                var data = response.getReturnValue();
                console.log("data" , data);
                component.set("v.recordData", data);
            }
             else {
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
    
    validateform: function(component) {
        var reqfelds = [].concat(component.find('requiredField'));
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
    },
    
    onSuccess : function( component, event, helper ){
        component.set('v.loaded', !component.get('v.loaded'));
        var payload = event.getParams().response;
        console.log("payload", JSON.parse(JSON.stringify(payload)));
        if(payload.id){
            //Commented regarding Tier Designation change SRSF-4944
            /*if(payload.fields.SAM_Designation__c.value != null && (payload.fields.SAM_Designation__c.value == 'Extra' || payload.fields.SAM_Designation__c.value == 'Target') ){
                console.log('Inside' , payload.fields.SAM_Designation__c.value);
                console.log('Inside' , payload.fields.User__c.value);
                component.set("v.samDesignationValue",payload.fields.SAM_Designation__c.value);
                component.set("v.userValue",payload.fields.User__c.value);
                this.checkCountForExtraAndTarget(component,component.get("v.samDesignationValue"),component.get("v.userValue"));
            }*/
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "Success!",
                "type": "success",
                "message": "The record has been saved successfully."
            });
            toastEvent.fire();
            this.dismissQuickAction(component, event, helper);
            event.preventDefault();
        }  
    },
    
    //Commented regarding Tier Designation change SRSF-4944
    /*checkCountForExtraAndTarget : function(component,sam,user){
        var action = component.get("c.checkCountForTargetAndExtra");
        action.setParams({
            "samDesignation" : sam,
            "user" : user
        }); 
         action.setCallback(this, function( response ){
            var state = response.getState();
            if( state == "SUCCESS" ){
                var response = response.getReturnValue();
                console.log("response" , response);
                if(response){
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                     "mode": "sticky",
                    "title": "Warning!",
                    "type": "warning",
                    "message": response
                    });
                    toastEvent.fire();
                } 
            }
             else {
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
        
    },*/

    dismissQuickAction : function( component, event, helper ){
        $A.get("e.force:closeQuickAction").fire();
    }
})