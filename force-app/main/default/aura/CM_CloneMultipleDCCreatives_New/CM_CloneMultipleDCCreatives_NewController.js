({
    /*
   	  Description	 : Controller to get the detials of from Digital Campaign record
    */
    doInit : function(component, event, helper) 
    {  
        var getProfileaction = component.get("c.getProfileInfo");
        getProfileaction.setCallback(this, function(response) {
            // Set the component attributes using values returned by the API call
            if (response.getState() === "SUCCESS")
            {
                var profileName = response.getReturnValue();
                var profilesFromCustomlabel = $A.get("$Label.c.DC_MultipleCloningProfiles");
                var profielsArr = profilesFromCustomlabel.split(",");
                var isProfileFound = false;
                for(var i=0;i<profielsArr.length;i++){
                    if(profielsArr[i] == profileName){
                        isProfileFound = true;
                        break;
                    }
                }
                if( !isProfileFound ){
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        type : "error",
                        title: "Error!",
                        duration : 20000,
                        message: "Error : You are not allowed to use this functionality. Only users with '"+profilesFromCustomlabel+"' profile can access this functionality.\n"
                    });
                    toastEvent.fire();
                    helper.dismissQuickAction( component, event, helper );
                }
             }
        });
        $A.enqueueAction(getProfileaction);
        
        var tooltip = $A.get("$Label.c.CM_Clone_Creative_Tooltip");
        var res = tooltip.replace(/\n/g, "<br/>");
        //component.set("v.tooltipInfo", res);
        var getDCaction = component.get("c.getDigitalCampaign");
        getDCaction.setParams({
            "campaignID": component.get("v.recordId")
        });
        getDCaction.setCallback(this, function(response) {
            // Set the component attributes using values returned by the API call
            if (response.getState() === "SUCCESS")
            {
        console.log('response.getReturnValue',response.getReturnValue().Migrated_Creative__c);
                if(response.getReturnValue().Migrated_Creative__c ==true){
                component.set("v.MigratedCreative",false);     
                }                component.set("v.FromDC", response.getReturnValue());
                //component.set("v.brTag", "<br/>");
             }
        });
        $A.enqueueAction(getDCaction);
    },
    /*
   	  Description	 : Controller to get the list of Digital creatives
    */
    getDCCreatives : function(component, event , helper) {
        var noCons = component.find('noDCs');
        $A.util.addClass(noCons, 'slds-hide');
        component.set("v.showDcs", false);
        var cmpTarget = component.find('showContacts');
        var noCons = component.find('noContacts');
        $A.util.removeClass(cmpTarget, 'slds-hide');
        $A.util.addClass(noCons, 'slds-hide');
        
        helper.getDCCreativesHelper(component, event);
    },
    /*
   	  Description	 : Controller to clone the selected Digital creatives
    */
    CloneHandle : function(component, event , helper) 
    {
        var cmpTarget1 = component.find('showAlertValidation');
        $A.util.removeClass(cmpTarget1, 'slds-show');
        $A.util.addClass(cmpTarget1, 'slds-hide');
        
        var torecId = [];
        var selectedLookUpRecords = component.get("v.selectedLookUpRecords");
        for(var i=0;i<selectedLookUpRecords.length;i++)
            torecId.push(selectedLookUpRecords[i].Id);
        var CloneAction = component.get("c.CreateCloneDigitalCreative");
        CloneAction.setParams({
            "selWrap": JSON.stringify(component.get("v.DigitalCreativeRecords")),
            "cloneToDCId": torecId,
            "fromStrDCId" : component.get("v.recordId")
        });
        CloneAction.setCallback(this, function(response) {
            if (response.getState() === "SUCCESS") {
                var status = response.getReturnValue();
                //alert(status);
                if(status == 'successful') {
                    var cmpTarget = component.find('showAlert');
                    $A.util.removeClass(cmpTarget, 'slds-hide');
                    $A.util.addClass(cmpTarget, 'slds-show');
                    
                    helper.gotoURL(component, event , torecId[0]);
                }else if(status == 'tooltip info') {
                    var tooltip = $A.get("$Label.c.CM_Clone_Creative_Tooltip");
        			var res = tooltip.replace(/\n/g, "<br/>");
                    res = "Error : "+res;
                    component.set('v.Errormessage',res);
                    var cmpTarget1 = component.find('showAlertValidation');
                    $A.util.removeClass(cmpTarget1, 'slds-hide');
                    $A.util.addClass(cmpTarget1, 'slds-show');
                }else {
                    component.set('v.Errormessage',status);
                    var cmpTarget1 = component.find('showAlertValidation');
                    $A.util.removeClass(cmpTarget1, 'slds-hide');
                    $A.util.addClass(cmpTarget1, 'slds-show');
                }
            }
        });
        $A.enqueueAction(CloneAction);
        
    },
    /*
   	  Description	 : Controller to check all the digital creatives
    */
    checkAll : function(component, event, helper) {
        var selectedHeaderCheck = component.find("box3").get("v.value");
        var contactsLst = component.get("v.DigitalCreativeRecords");
        helper.checkAllHelper(component, event , selectedHeaderCheck);
        helper.enableCloneHelper(component, event);
    },
    /*
   	  Description	 : Controller to enable the clone button
    */
    enableClone : function(component, event, helper) {
        //var selectedHeaderCheck = component.find("boxPack").get("v.value");
         
         //var isBusExist1 = event.currentTarget.getAttribute("v.text");
        // var isBusExist = event.currentTarget.getAttribute("text");
        var selectedRec = event.getSource().get("v.text");
         var selectedRec1 = event.getSource().get("v.value");
        //console.log('selectedRec1',selectedRec1);
        //console.log('selectedRec',selectedRec);
      
        helper.enableCloneHelper(component, event);
    },
        
})