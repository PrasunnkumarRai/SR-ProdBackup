({  
    
    doInit: function(component, event, helper) {
        component.set("v.showModal", true);
    },
    
    hideModel: function(component, event, helper) {
        var navigateEvent = $A.get("e.force:navigateToSObject");
        navigateEvent.setParams({
            recordId: component.get("v.recordId")
        });
        navigateEvent.fire();
    },
    
    handleError: function(component, event) {
        var errors = event.getParams();
        console.log("response", JSON.stringify(errors));
        if(errors){
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "Error!",
                "type": "error",
                "message": errors.detail
            });
            toastEvent.fire(); 
        }
    },
    
    onRecordSubmit: function(component, event, helper) {
        component.set('v.loaded', component.get('v.loaded'));
        component.set("v.statusVal","Submitted to Planning");
        var CNALinkId = component.get("v.selectedLookUpRecord").Id;
        component.set("v.CNALinkValue",CNALinkId );
        //START:SRSF-4643 "Required fields" validation   
        helper.validateform(component);
        //END :SRSF-4643   
        
        
        
    },
    
    submitApproval :  function(component, event, helper) {
        component.set('v.loaded', component.get('v.loaded'));
        var CNALinkId = component.get("v.selectedLookUpRecord").Id;
        console.log('CNALinkId', CNALinkId);
        component.set("v.CNALinkValue",CNALinkId );
        console.log('CNALinkValue', component.get("v.CNALinkValue"));
        //START:SRSF-4643 "Required fields" validation  
        helper.validateform(component);
        //END :SRSF-4643    
    },
    handleSuccess : function(component, event, helper) {
        var errors = event.getParams();
        console.log("response@@", JSON.stringify(errors));
        component.set('v.loaded', !component.get('v.loaded'));
        var payload = event.getParams().response;
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
    }
})