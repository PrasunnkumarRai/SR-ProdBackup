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
    getDCCreativesHelper : function(component, event) {
        var cmpTarget = component.find('showContacts');
        var noCons = component.find('noContacts');
        var action = component.get("c.getDigitalCreatives");
        if( event.getParam("eventFromDC")!=null && event.getParam("eventToDC")!=null ){
            action.setParams({
                "fromDCObj": event.getParam("eventFromDC"),
                "toDCObj" : event.getParam("eventToDC")
            });
            action.setCallback(this, function(response) {
                //var data = response.getReturnValue();
                var state = response.getState();
                // Set the component attributes using values returned by the API call
                if (state === "SUCCESS")
                {
                    var conWrap = response.getReturnValue();
                    component.set("v.DigitalCreativeRecords", conWrap);
                    //alert(conWrap);
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
            });
            $A.enqueueAction(action);
        }else{
            component.set("v.DigitalCreativeRecords", null);
        }
    },
    /*
   	  Description	 : Helper to Check all the checkboxes when selected on header
    */
    checkAllHelper : function(component, event , IsChecked) { 
        var contactsLst = component.get("v.DigitalCreativeRecords");
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
        component.set("v.DigitalCreativeRecords",contactsLst);
    },
    /*
   	  Description	 : Helper to enable the clone button
    */
    enableCloneHelper : function(component, event) {
        var conLst = component.get("v.DigitalCreativeRecords");
        var disable = true;
        for (var i = 0; i < conLst.length; i++) {
            if(conLst[i].isCheck)
             disable = false;
        }
        component.set("v.disableClone",disable);
    },
    
    dismissQuickAction : function( component, event, helper ){
        var dismissActionPanel = $A.get("e.force:closeQuickAction");
        dismissActionPanel.fire();
    },
})