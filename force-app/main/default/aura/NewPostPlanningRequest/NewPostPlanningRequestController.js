({
    doInit: function(component, event, helper) {
        component.set("v.showModal", true);
        var recordId = component.get("v.recordId");
        var action = component.get("c.createPostPlanningSupportRequest");
        action.setParams({
            "suppReq" : recordId
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
    
    /*hideModel: function(component, event, helper) {
       var navigateEvent = $A.get("e.force:navigateToSObject");
       navigateEvent.setParams({
               recordId: component.get("v.recordId")
       });
       navigateEvent.fire();
   },*/
    
    hideModel : function(cmp, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    },
    
    onRecordSubmit: function(component, event, helper) {
        component.set("v.statusVal","Submitted to Planning");
        component.set('v.loaded', component.get('v.loaded'));
        //START: SRSF-4643 :"Required fields" validation
        helper.validateform(component);
        //END: SRSF-4643 
        
        
    },
    
    submitApproval :  function(component, event, helper) {
        component.set('v.loaded', component.get('v.loaded'));
        /* if(helper.validateform(component)){
           component.find("editform").submit();
       }*/
        //START: SRSF-4643 :"Required fields" validation
        helper.validateform(component);
        //END: SRSF-4643 
    },
    
    handleSuccess : function(component, event, helper) {
        component.set('v.loaded', !component.get('v.loaded'));
        var payload = event.getParams().response;
        console.log("payload", payload);
        if(payload.id){
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "Success!",
                "type": "success",
                "message": "The record has been saved successfully."
            });
            toastEvent.fire();
            var navService = component.find("navService");
            var pageReference = {
                type: 'standard__recordPage',
                attributes: {
                    "recordId": payload.id,
                    "objectApiName": "Support_Request__c",
                    "actionName": "view"
                }
            }
            event.preventDefault();
            navService.navigate(pageReference);  
        }  
    },
    
    handleError: function(component, event) {
        var errors = event.getParams();
        console.log("response", JSON.stringify(errors));
    }
})