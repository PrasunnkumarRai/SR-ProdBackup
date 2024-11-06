({  
    getProductionService : function (component, event, helper){  
        var recId = component.get("v.recordId");
        console.log('recId>>>>'+recId);
        var action = component.get("c.getProductionService");
        action.setParams({
            "recordId" : recId,
        });
        action.setCallback(this, function( response ){
            var state = response.getState();    
            if( state == "SUCCESS"){
                var data = response.getReturnValue();
                console.log(data);
                console.log('Submit SR>>>>'+data.Submit_Support_Request__c);
                console.log ('SR Status >>>>'+data.Support_Request__r.Status__c);                               
                if(data.Submit_Support_Request__c && data.Support_Request__r.Status__c=='Pending'){
                    helper.handleConfirmDialog(component, event, helper);  
                }                 
            }            
        });        
        $A.enqueueAction(action);
    },
    handleConfirmDialog : function(component, event, helper) {
        component.set('v.showConfirmDialog', true);
    },
})