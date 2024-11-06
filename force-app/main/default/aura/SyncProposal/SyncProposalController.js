({
    doInit: function(component, event, helper) {
	   var action = component.get("c.syncProposal");
       action.setParams({
           "propsalId": component.get("v.recordId")
       });
       action.setCallback(this, function(response){
           var state = response.getState();
           if (state == "SUCCESS") {
               
               component.set("v.message" , response.getReturnValue().message);
               component.set("v.messageType", response.getReturnValue().messageType);
               console.log('result:::'+response.getReturnValue().message);
               console.log('result:::'+response.getReturnValue().messageType);
               
               var timeForRefresh = $A.get("$Label.c.Sync_Proposal_Time_in_Millie_Seconds");
               
               var interval  = setInterval($A.getCallback(function(){
                    window.location.reload();
                   }) ,timeForRefresh);
              
           }
           else if (state == "ERROR") {
               component.set("v.message" , "Request Failed!");
               component.set("v.messageType", 'error' );
           }
       });
       $A.enqueueAction(action);                
    }
})