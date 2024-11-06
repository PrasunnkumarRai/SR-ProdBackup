({
    /*
   	  Description	 : Controller to get the detials of from Digital Campaign record
    */
    doInit : function(component, event, helper) 
    {
        //component.set("v.brTag", "1122<br/>");
        //alert(component.get("v.brTag"));
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
                }

    
                component.set("v.FromDC", response.getReturnValue());
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
        var fromDCObjt = component.get("v.FromDC");
        var toDCId = component.get("v.ToAccId");
        if(toDCId != '' && toDCId != null )
            helper.getDCCreativesHelper(component, event ,fromDCObjt , toDCId);
    },
    /*
   	  Description	 : Controller to clone the selected Digital creatives
    */
    CloneHandle : function(component, event , helper) 
    {
        var cmpTarget1 = component.find('showAlertValidation');
        $A.util.removeClass(cmpTarget1, 'slds-show');
        $A.util.addClass(cmpTarget1, 'slds-hide');
        var torecId = component.get("v.ToAccId");
        var CloneAction = component.get("c.CreateCloneDigitalCreative");
        CloneAction.setParams({
            "selWrap": JSON.stringify(component.get("v.ChildContacts")),
            "strDCId": torecId,
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
                    
                    helper.gotoURL(component, event , torecId);
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
        var contactsLst = component.get("v.ChildContacts");
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
    
    /*
   	  Description	 : Controller to update the selected to digital campaign
    */
    handleAccountIdUpdate : function(cmp, event, helper) {
        // Get the Id from the Event
        var accountId = event.getParam("sObjectId");
        // Get the Instance Id from the Event
        var instanceId = event.getParam("instanceId");
        var status = event.getParam("strCampaignStatus");
        // Determine the instance Id of the component that fired the event
        if(accountId != '' && instanceId === 'ToAccount') {
            cmp.set('v.toDcStatus',status);
            cmp.set('v.ToAccId', accountId);
        }
        else
        {
            console.log('Unknown instance id: ' + instanceId);
        }
    },
    /*
   	  Description	 : Controller to clear the selected to digital campaign
    */
    handleAccountIdClear : function(cmp, event, helper) {
        cmp.set('v.ToAccId', '');
    }
})