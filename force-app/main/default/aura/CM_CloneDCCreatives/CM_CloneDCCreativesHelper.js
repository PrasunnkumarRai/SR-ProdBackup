({
    /*
   	  Description	 : Helper to navigate to record detail page
    */
    gotoURL : function (component, event ,torecId) {
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": "/"+torecId
        });
        setTimeout(function() {
            urlEvent.fire();
        }, 2000);
    },
    /*
   	  Description	 : Helper to get the Digital creatives
    */
    getDCCreativesHelper : function(component, event,fromDCObjt , toDCId) {
        var toDcStatusVal = component.get("v.toDcStatus");
        
        var cmpTarget = component.find('showContacts');
        var noCons = component.find('noContacts');
        /*if(toDcStatusVal == '39 Cancelled' || 
           toDcStatusVal == '99 Campaign Completed' || 
           toDcStatusVal == '98 Cancellation Complete' || 
           toDcStatusVal == '00 Rejected' ) {
            var noCons = component.find('noDCs');
            $A.util.removeClass(noCons, 'slds-hide');
        }
        else*/
        {
            var action = component.get("c.getDigitalCreatives");
            action.setParams({
                "FromDCObj": fromDCObjt,
                "toDCId" : toDCId
            });
            action.setCallback(this, function(response) {
                //var data = response.getReturnValue();
                var state = response.getState();
                // Set the component attributes using values returned by the API call
                if (state === "SUCCESS")
                {
                    var conWrap = response.getReturnValue();
                    component.set("v.ChildContacts", conWrap);
                    //(conWrap.length);
                    if(conWrap.length > 0) {
                        component.set("v.showDcs", true);
                    }
                    else {
                        var noCons = component.find('noDCs');
                        $A.util.removeClass(noCons, 'slds-hide');
                    }
                }
                else
                    alert("Unexpected Error Occured");
                //component.set("v.brTag", "1122<br/>");
                //alert(component.get("v.brTag"));
            });
            $A.enqueueAction(action);
        }
    },
    /*
   	  Description	 : Helper to Check all the checkboxes when selected on header
    */
    checkAllHelper : function(component, event , IsChecked) { 
        var contactsLst = component.get("v.ChildContacts");
        //console.log('contactsLst',contactsLst);
        var getAllId = component.find("boxPack");
        if (IsChecked)
        {
            for (var i = 0; i < contactsLst.length; i++) {
               
            contactsLst[i].isCheck = true;
        	}
        }
        else
        {
            for (var i = 0; i < contactsLst.length; i++) {
            contactsLst[i].isCheck = false;
        	}
        }
        
        component.set("v.ChildContacts",contactsLst);
        //component.set("v.brTag", "1122<br/>");
        //alert(component.get("v.brTag"));
        //console.log('contactsLstNew',component.get("v.ChildContacts"));
    },
    /*
   	  Description	 : Helper to enable the clone button
    */
    enableCloneHelper : function(component, event) {
        var conLst = component.get("v.ChildContacts");
        var disable = true;
        for (var i = 0; i < conLst.length; i++) {
            if(conLst[i].isCheck)
             disable = false;
        }
        component.set("v.disableClone",disable);
    }
})