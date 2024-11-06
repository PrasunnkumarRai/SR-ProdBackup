({
	loadAddress : function(component,recId) {
		var action = component.get("c.PrepareData");
        action.setParams({
            dcRecordId:recId
        });
        
        action.setCallback(this,function(response){
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                var resData = response.getReturnValue();
                //component.set("v.addList",response.getReturnValue());
                //console.log('----> response '+JSON.stringify(resData));
                component.set("v.addList",resData.lstAddress);
                component.set("v.lockRecord",resData.lockRecord);
            }
        });
        $A.enqueueAction(action);
	},
    
    updateAddressCH : function(component,recId,street,city,state,zip,type,radius,isnone){
        var action = component.get("c.insertAddress");
        action.setParams({
            dcRecordId:recId,
            street:street,
            city:city,
            state:state,
            zip:zip,
            type:type,
            radius:radius,
            isNone:isnone
        });
        
        action.setCallback(this,function(response){
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                var resData = response.getReturnValue();
                if(resData.strMsg=="Success"){
                    //alert("The address has been added.");
                    this.showToast("success", "Success!", "The address has been added.");
                	component.set("v.addList",resData.lstAddress);
                }else{
                    //alert(resData.strMsg);
                    this.showToast("error", "Error!", resData.strMsg);
                }
            }else{
                this.showToast("error", "Error!", JSON.stringify(response.error));
            }
        });
        $A.enqueueAction(action);
    },
    
    deleteAddressCH : function(component,recId,indx){
        var action = component.get("c.deleteAddressCC");
        action.setParams({
            dcRecordId:recId,
            rowInd:indx
        });
        action.setCallback(this,function(response){
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                var resData = response.getReturnValue();
                if(resData.strMsg=="Success"){
                    //alert("The address has been removed.");
                	component.set("v.addList",resData.lstAddress);
                    this.showToast("success", "Success!", "The address has been removed.");
                }else{ 
                    //alert(resData.strMsg);
                    this.showToast("error", "Error!", resData.strMsg);
                }
            }else{
                this.showToast("error", "Error!", JSON.stringify(response.error));
            }
        });
        $A.enqueueAction(action);
    },
    showToast : function( type, title, msg ){
    	var toastEvent = $A.get("e.force:showToast");
    	toastEvent.setParams({
    		"type": type,
            "title": title,
            "message": msg
        });
        toastEvent.fire();
    }
})