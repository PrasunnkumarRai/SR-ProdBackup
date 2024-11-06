({

      doMapInit : function(component, event, helper) {
          //if (component.get("v.showActionLin") == true) {
              var toggleMap = component.get("v.callTogglerMap");
          //    toggleMap[component.get("v.opptyId")] = component.get("v.callToggler");
          //    console.log('toggleMap:');
          //    console.log(toggleMap);
         // }
      },

      display : function(component, event, helper) {
     //   console.log('in display');
        //var doHide = component.get("v.callToggler");
//        if(doHide == false) {
            component.set("v.callToggler", true);
          helper.toggleHelper(component, event);
  //      }
      },

      displayOut : function(component, event, helper) {
     //   console.log('in displayOut');
/*            component.set("v.callToggler", true);

            window.setTimeout(
              $A.getCallback(function() {
  */              //  var doHide = component.getCallTogglerValue();
                  var doHide = component.get("v.callToggler");
                  console.log('----->> in displayOut, doHide = ' + doHide);
                  if (doHide == true) {
                    helper.toggleHelper(component, event);
                    console.log('HIDING...');
                  }
                  else
                    component.set("v.callToggler", true);
    /*              else {
                    component.callDisplayOut();
                  }
              }), 500
            );
      */ 
      },
     
      popoverDisplay : function(component, event, helper) {
     //   console.log('in display');
        component.set("v.callToggler", false);
      },

      popoverDisplayOut : function(component, event, helper) {
        component.set("v.callToggler", true);
        component.callDisplayOut();
       
      },
/*     
     displayPO : function(component, event, helper) {
      	console.log('in displayPO');
        helper.showPopover(component, event);
         window.setTimeout(
            $A.getCallback(function() {
                if (component.isValid()) {
                    component.find("popover").getElement().focus();
                }
            }), 300
        );

      },

      displayOutPO : function(component, event, helper) {
        console.log('in displayOutPO');
        helper.hidePopover(component, event);
      },  
*/ 
    createTask : function(component, event, helper) {
        helper.createTask(component, event);
    },

    createEvent : function(component, event, helper) {
        helper.createEvent(component, event);
    },
    getCallTogglerValue : function(component, event, helper) {
        console.log('OK: ' + component.get("v.callToggler"));
        return component.get("v.callToggler");
    },

})