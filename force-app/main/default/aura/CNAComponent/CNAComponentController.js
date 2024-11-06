({
    submitDetails: function(component, event, helper) {
       console.log(component.get("v.value"));
       var navigateEvent = $A.get("e.force:navigateToComponent");
       navigateEvent.setParams({
           componentDef: "c:CNAOverhaul",
           componentAttributes: {
               recordId: component.get("v.recordId"),
               recordTypeName: component.get("v.value")             
           }
       });
       navigateEvent.fire();
   }
})