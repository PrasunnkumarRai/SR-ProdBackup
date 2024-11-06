({
   toggleHelper : function(component,event) {
    var toggleText = component.find("tooltip");
       $A.util.toggleClass(toggleText, "toggle");    
   },

   showPopover : function(component,event) {
      console.log('==========>> in showPopover!!!');
      var po = component.find('popover');
      if (typeof po !== 'undefined') {
          $A.util.removeClass(po, "slds-hide");
          $A.util.addClass(po, "slds-show");
        //  document.getElementById("popoverDiv").focus();
      }

   },

   hidePopover : function(component,event) {
      console.log('==========>> in hidePopover!!!');
      var po = component.find('popover');
      $a.util.toggleClass(po, "slds-hide");
  //    $A.util.removeClass(po, "slds-show");
    //  $A.util.addClass(po, "slds-hide");
   },

   createTask : function(component, event) {
      var createRecordEvent = $A.get("e.force:createRecord");
      var opptyId = component.get("v.opptyId");
      createRecordEvent.setParams({
          "entityApiName": "Task",
          'defaultFieldValues': {
          "WhatId" : opptyId
            }                      
        });

      createRecordEvent.fire();                   
   },

   createEvent : function(component, event) {
      var createRecordEvent = $A.get("e.force:createRecord");
      var opptyId = component.get("v.opptyId");
      createRecordEvent.setParams({
          "entityApiName": "Event",
          'defaultFieldValues': {
          "WhatId" : opptyId
            }                      
        });

      createRecordEvent.fire();                   
   },

})