({
    getDigitalCreativeRecordTypes : function( component, event, helper ){
        console.log('---> inside getDigitalCreativeRecordTypes.');
        var action = component.get('c.getDigitalCreativeRecordTypes');
        action.setParams({
            "recordId" : component.get("v.recordId")
        });
        action.setCallback(this, function( response ){
            var state = response.getState();
            console.log('---> state: '+state);
            if( state == "SUCCESS" ){
                
                var respObj = response.getReturnValue();
                console.log('----> respObj: '+JSON.stringify(respObj));
                if( !respObj.userPresentInOpptyTeamMember ){
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        type : "error",
                        title: "Error!",
                        duration : 10000,
                        message: "You are not allowed to create Digital Creative for this Digital Campaign as you are not present in Opportunity's Team Member list."
                    });
                    toastEvent.fire();
                    helper.dismissQuickAction( component, event, helper );
                }else{
                    var lstRTs = respObj.lstRecordTypes;
                    console.log('---> lstRTs: '+JSON.stringify(lstRTs));
                    if( lstRTs != null && lstRTs.length > 0 ){
                        component.set("v.rtOptions", lstRTs );
                        component.set("v.selectedRT", lstRTs[0].Id);
    
                        if( lstRTs.length == 1 ){
                            this.createNewDCreative( component, event, helper );
                        }else{
                            component.set("v.hasRecordTypes", true);
                        }
                    }else{
                        this.createNewDCreative( component, event, helper );
                    }
                }
            }else if( state == "ERROR" ){
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + 
                                 errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
        $A.enqueueAction( action );
    },
	createNewDCreative : function( component, event, helper ) {
        var action = component.get("c.getDigitalCampaignRecord");
        action.setParams({
            "recordId" : component.get("v.recordId"),
        });
        action.setCallback(this, function( response ){
            var state = response.getState(); 	
            if( state == "SUCCESS"){
                var data = response.getReturnValue();
                var selectedRT = component.get("v.selectedRT");
                if( typeof selectedRT !== "undefined" && selectedRT != null & selectedRT != '' ){
		            $A.get("e.force:createRecord").setParams({
		                "entityApiName": "Digital_Creative__c",
		                "recordTypeId" : selectedRT,
		                "defaultFieldValues": data
		            }).fire();
                }else{
	            	$A.get("e.force:createRecord").setParams({
    	                "entityApiName": "Digital_Creative__c",
        	            "defaultFieldValues": data
            	    }).fire();
                }
                helper.dismissQuickAction( component, event, helper );
            }
        });
        $A.enqueueAction(action);
    },
    dismissQuickAction : function( component, event, helper ){
        var dismissActionPanel = $A.get("e.force:closeQuickAction");
        dismissActionPanel.fire();
    }
})