({
	loadDCRecordTypes : function( component, event, helper ) {
        console.log('----> inside loadDCRecordTypes');
        var action = component.get("c.getDigitalCampaignRecordTypes");
        action.setParams({
            "recordId" : component.get("v.recordId")
        });
        action.setCallback(this, function( response ){
            console.log('----> response.getState(): '+response.getState());
            if(response.getState()=="SUCCESS"){
                var respObj = response.getReturnValue();
                console.log('----> respObj: '+JSON.stringify(respObj));
                if( !respObj.userPresentInOpptyTeamMember ){
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        type : "error",
                        title: "Error!",
                        duration : 10000,
                        message: "You are not allowed to create Digital Campaign for this proposal as you are not present in Opportunity's Team Member list."
                    });
                    toastEvent.fire();
                    helper.dismissQuickAction( component, event, helper );
                }else{
                    if( respObj.lstRecordTypes != null && respObj.lstRecordTypes.length > 0 ){
                        component.set("v.showRTOptions", true );
                        var firstRT = respObj.lstRecordTypes[0];
                        component.set("v.selectedRT", firstRT.Id );
                        component.set( "v.rtOptions", respObj.lstRecordTypes );
                    }else{
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            type : "error",
                            title: "Error!",
                            duration : 10000,
                            message: "You are not allowed to create Digital Campaign for this proposal. Please contact your System Administrator"
                        });
                        toastEvent.fire();
                        helper.dismissQuickAction( component, event, helper );
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
    createNewCampaign : function( component, event, helper ) {
        var proposalId = component.get("v.recordId");
        var selectedRT = component.get("v.selectedRT");
        var action = component.get("c.getProposalRecord");
        action.setParams({
            "recordId" : proposalId,
            "selectedDCRT" : selectedRT
        });
        action.setCallback(this, function( response ){
            var state = response.getState();
            if( state === "SUCCESS"){
                var data = response.getReturnValue();  
                //console.log('----> data: '+JSON.stringify(data));
                var createRecordEvent = $A.get("e.force:createRecord");
                createRecordEvent.setParams({
                    "entityApiName": "Digital_Campaign__c",
                    "recordTypeId" : selectedRT,
                    "defaultFieldValues": data
                });
                createRecordEvent.fire();
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