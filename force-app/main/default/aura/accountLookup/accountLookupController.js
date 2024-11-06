({
	handleChangeAE : function(component, event, helper) {
        //alert('ae changed to:' + component.find("aePicklist").get("v.value"));
		    var spinnerDiv = component.find("spinnerDiv");
            $A.util.removeClass(spinnerDiv, "slds-hide");
            $A.util.addClass(spinnerDiv, "slds-show"); 

		var ae = component.find("aePicklist").get("v.value");        
        console.log('------------->> in handleChangeAE, ae = ' + ae);
        
        /* Code Added for SRSR-1672 Starts Here */
         var myEvent = $A.get("e.c:AEChangeEvent");
         myEvent.setParams({"AEId": ae});
         myEvent.fire();
        component.set("v.DMAChanges",true);
        /* Code Added for SRSR-1672 Ends Here */
        
		var aeList = component.get('v.accTeamMembers');
		for (var i = 0; i < aeList.length; i++) {
			console.log('=======>> aeList[' + i + ']:');
			console.log(aeList[i]);	
			console.log(aeList[i].User.Profile.Name);
			if (ae == aeList[i].User.Id) {
				console.log('found user!');
				component.set('v.curUserProfile', aeList[i].User.Profile.Name);
				break;
			}
		}  
	},
    hideSpinner: function(component, event, helper) {
        if(component.get("v.DMAChanges")){
            var spinnerDiv = component.find("spinnerDiv");
            $A.util.addClass(spinnerDiv, "slds-hide"); 
            $A.util.removeClass(spinnerDiv, "slds-show");
        }
        //Start : SRSF-3571
        if(component.get("v.displayModal")){
            var spinnerDiv = component.find("spinnerDiv");
            $A.util.addClass(spinnerDiv, "slds-hide"); 
            $A.util.removeClass(spinnerDiv, "slds-show");
        }
        //End : SRSF-3571
    },
	handleAccountSelection : function(component, event, helper) {
		var accType = event.getParam('accountType');
		var accId = event.getParam('accountId');
        console.log('%%%%%%%%%%%%  accType, accId = ' + accType + ', ' + accId);        
		if (accType == 'Agency Account') {
			component.set('v.selectedAgencyId', accId);
		} else if (accType == 'Rep Firm') {
			component.set('v.selectedRepFirmId', accId);
		} else if (accType == 'Hold Co') { //SRSF-4392: Added holding acc
			component.set('v.selectedHoldingAccId', accId);
		}
	},

	showHideRepFirm : function(component, event, helper) {
		var profile = component.get('v.curUserProfile');
		console.log('------>> profile = ' + profile);
		var repFirmDiv = component.find('repFirmDiv');
		/*if (profile) {
			if (profile.indexOf('National') !== -1 ||
				profile.indexOf('national') !== -1 ||
				profile.indexOf('Interconnect') !== -1 ||
				profile.indexOf('interconnect') !== -1 ) {
					console.log('$$$$$$$$$$$$  showing repFirmDiv');
					$A.util.removeClass(repFirmDiv,'slds-hide');
   		            $A.util.addClass(repFirmDiv,'slds-show');
			} else {
				console.log('$$$$$$$$$$$$  (not) hiding repFirmDiv');
				$A.util.removeClass(repFirmDiv,'slds-show');
   		        $A.util.addClass(repFirmDiv,'slds-hide');
			}
		}*/
	},
	closeModel: function(component, event, helper) {
      // Set displayModal attribute to false  
      component.set("v.displayModal", false);
       window.location.reload();
   	},
   	//SRSF-4392: Added 'handleDemandPlatformChange & handleSupplyPlatformChange' functions
   	handleDemandPlatformChange: function (component, event, helper) {
        var selectedValues = event.getParam("value");
        console.log('selectedValues--->'+selectedValues);
        component.set("v.demandSidePlatform", selectedValues);
           
    },
    handleSupplyPlatformChange: function (component, event, helper) {
    	var selectedValues = event.getParam("value"); 
        component.set("v.supplySidePlatform", selectedValues);       
    }
})