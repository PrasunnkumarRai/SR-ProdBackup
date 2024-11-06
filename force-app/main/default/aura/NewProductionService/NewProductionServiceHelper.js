({  
	loadPSRecordTypes : function( component, event, helper ) {
        const action1 = component.get("c.getSupportRequestData");
        action1.setParams({
            "recordId" : component.get("v.recordId"),
        });
        action1.setCallback(this, function( response ){
            if(response.getState()=="SUCCESS"){
                const returnValue = response.getReturnValue();
                const action = component.get("c.getProductionServiceRecordTypes");
                action.setCallback(this, function( response ){
                    if(response.getState()=="SUCCESS"){
                        const lstRTs = response.getReturnValue();       
                        if( lstRTs.length ){
                            if (returnValue[0].Sponsorship_Type__c =='News' || returnValue[0].Sponsorship_Type__c == 'Weather'){              
                                const newsWeatherRTs = lstRTs.filter(e => /^News/.test(e.Name));
                                component.set( "v.rtOptions", newsWeatherRTs );
                            }
                            else{
                                component.set("v.selectedRT", lstRTs[0].Id );
                                component.set( "v.rtOptions", lstRTs );
                            }  
                        }
                    }
                    
                });
                $A.enqueueAction( action );  
            }
        });
        $A.enqueueAction( action1 );
	}, 
    createNewPService : function( component, event, helper ) {
        /*var sRequestId = component.get("v.recordId");
        var selectedRT = component.get("v.selectedRT");
        var createRecordEvent = $A.get("e.force:createRecord");
        createRecordEvent.setParams({
            "entityApiName": "Production_Service__c",
            "recordTypeId" : selectedRT,
            "defaultFieldValues": {
                "Support_Request__c" : sRequestId
            }
        });
        createRecordEvent.fire();
        helper.dismissQuickAction( component, event, helper );*/
        
        var action = component.get("c.getSupportRequestRecord");
        action.setParams({
            "recordId" : component.get("v.recordId"),
        });
        action.setCallback(this, function( response ){
            var state = response.getState(); 	
            if( state == "SUCCESS"){
                var data = response.getReturnValue();
                console.log(data);
                if( !data.hasOwnProperty('Support_Request__c') ){
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        type : "error",
                        title: "Error!",
                        duration : 10000,
                        message: "You are not allowed to create New Production Services for this Support Request."
                    });
                    toastEvent.fire();
                    helper.dismissQuickAction( component, event, helper );
                }else{
                    $A.get("e.force:createRecord").setParams({
                        "entityApiName": "Production_Service__c",
                        "recordTypeId" : component.get("v.selectedRT"),
                        "defaultFieldValues": data
                    }).fire();
                    helper.dismissQuickAction( component, event, helper );
                }
            }
        });
        $A.enqueueAction(action);
    },
    dismissQuickAction : function( component, event, helper ){
        var dismissActionPanel = $A.get("e.force:closeQuickAction");
        dismissActionPanel.fire();
    }
})