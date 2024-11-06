({
	loadProductionServiceRTs : function( component, event ) {
        console.log('-----> loadProductionServiceRTs.');
		var action = component.get("c.getProductionServiceRecordTypes");
        action.setParams({
            "recordId" : component.get("v.recordId")
        });
        action.setCallback( this, function( response ){
            var state = response.getState();
            console.log('-----> state: '+state);
            if( state == "SUCCESS"){
                var data = response.getReturnValue();
                console.log('---> data: '+JSON.stringify(data));
                if( data.recordTypes != null && data.recordTypes.length > 0 ){
                    component.set("v.selectedRT", data.currentRTId );
                    component.set("v.lstRecordTypes", data.recordTypes );
                    component.set("v.showRTSelection", true );
                }else{
                    this.createProductionService( component, component.get("v.recordId"), data.currentRTId );
                }
            }else if( state == "ERROR"){
                var errors = response.getError();
                console.log('---> Exception: '+JSON.stringify(errors));
            }
        });
        $A.enqueueAction( action );
	},
    cloneThisProductionService : function ( component, event ){
        this.createProductionService( component, component.get("v.recordId"), component.get("v.selectedRT") );
    },
    closeQuickAction : function( component, event ){
        $A.get("e.force:closeQuickAction").fire();
    },
    createProductionService : function( component, currentPSId, recordTypeId ){
    	var action = component.get("c.cloneThisProductionService");
        action.setParams({
            "recordId" : currentPSId,
            "recordTypeId" : recordTypeId
        });
        action.setCallback( this, function( response ){
            var state = response.getState();
            if( state == "SUCCESS"){
                var newPService = response.getReturnValue();
                $A.get("e.force:navigateToSObject").setParams({
                    "recordId": newPService.Id
                }).fire();
                $A.get("e.force:closeQuickAction").fire();
                $A.get("e.force:showToast").setParams({
                    type : "success",
                    message : "Production Service \""+newPService.Name+"\" was created."
                }).fire();
            }else if( state == "ERROR"){
                var errors = response.getError();
                console.log('---> Exception1: '+JSON.stringify(errors));
                console.log('---> Exception2: '+JSON.stringify(errors[0]));
                $A.get("e.force:closeQuickAction").fire();
                try{
                    console.log('---> Exception3: '+errors[0].pageErrors[0].message);
                    $A.get("e.force:showToast").setParams({
                        type : "error",
                        message : errors[0].pageErrors[0].message
                    }).fire();
                }catch(err){
                	 console.log('---> catch Error: '+JSON.stringify(err));  
                }
            }
        });
        $A.enqueueAction( action );
	}
    
})