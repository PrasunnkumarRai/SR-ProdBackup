({
    doInit : function(component, event, helper) {
        console.log ('inside doinit>>>>>');
        var recId = component.get("v.recordId");
        console.log ('recId in doinit >>>'+recId);
        if (recId!= null){
            helper.getProductionService(component, event, helper);
        }                                  
    },
         
    handleConfirmDialogYes : function(component, event, helper) {
        console.log('Yes');         
        var recId = component.get("v.recordId");       
        console.log('Yes Confirmed>>>>'+recId);
        if(recId!= null){
            component.set('v.showConfirmDialog', false);
            var action = component.get("c.updateSupportRequest");
            action.setParams({
                "recordId" : recId,
            });
            action.setCallback(this, function( response ){
                var state = response.getState();    
                if( state == "SUCCESS"){                    
                    console.log('response>>>>'+response.getReturnValue());
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        type : "success",
                        title: "Success!",
                        duration : 10000,
                        message: $A.get("$Label.c.Submit_Support_Request_SuccessMsg")
                    });
                    toastEvent.fire();                     
                }
            });
            $A.enqueueAction(action);
            $A.get('e.force:refreshView').fire();
        } 
    },
     
    handleConfirmDialogNo : function(component, event, helper) {
        console.log('No');          
        var recId = component.get("v.recordId"); 
        if (recId!= null){
            component.set('v.showConfirmDialog', false);     
            var action = component.get("c.updateProductionService");
            action.setParams({
                "recordId" : recId,
            });
            action.setCallback(this, function( response ){
                var state = response.getState();    
                if( state == "SUCCESS"){                    
                    console.log('response>>>>'+response.getReturnValue());                                   
                }
            });
            $A.enqueueAction(action);
            $A.get('e.force:refreshView').fire();
        }            
    },        
})