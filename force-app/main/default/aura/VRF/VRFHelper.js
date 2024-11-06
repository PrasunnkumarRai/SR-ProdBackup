({
    getVRFComponents : function(component) {

        var toastEvent = $A.get("e.force:showToast");
        var creativeId = component.get("v.recordId");
        var action     = component.get("c.getVRFComponents");

        action.setParams({
            "creativeId" : creativeId
        });

        action.setCallback(this, function(response){

            var state = response.getState();
        
            if (state == "SUCCESS"){
            
                var vrfClass = JSON.parse(response.getReturnValue());

                component.set("v.vrfClass", vrfClass); 
                component.find("clientId").set("v.value", vrfClass.VrfClientId);
   
                var spotId;

                if (vrfClass.SpotId == null){
                    spotId = "";
                }else{
                    spotId = vrfClass.SpotId.trim();
                }

               
                component.find("spotId").set("v.value", spotId);  
                            
                if (this.validateClientId(spotId)){
                    component.set("v.disableButton",false); 
                    component.set("v.hide",'hide'); 
    
                }else{
                    component.set("v.disableButton",true);   
                    component.set("v.hide",'');        
                }   
                
                if (vrfClass.isVrfVisible == false){
                    var cmpTarget = component.find('messageDiv');
                    $A.util.removeClass(cmpTarget, 'hide');
                }
               
            }else{
                console.log("Error: " + error[0].message);  

                toastEvent.setParams({
                    "type" : "error",
                    "title": "Error",
                    "message": "An Error has occur. Please contact your system administrator."
                });
                
                toastEvent.fire();
            }
        });

        $A.enqueueAction(action);
    },
    getDigitalCreativeRecord: function(component) {
        var creativeId = component.get("v.recordId");
        var action     = component.get("c.getDigitalCreativeRecord");

        action.setParams({
            "recordId" : creativeId
        });

        action.setCallback(this, function(response){
            var state = response.getState();
        
            if (state == "SUCCESS"){
                var result = response.getReturnValue();
                component.set("v.vastTag", result.Vast_Tag_Enabled__c);


                if ( result.Vast_Tag_Enabled__c){
                    component.set("v.hide","hide");    
                }
                 
            }
        });
        $A.enqueueAction(action);
    },
    validateClientId: function(spotId){

        if (!(spotId.length === 9 || spotId.length === 8)){
            return false;
        }

        var regExp = /^[a-zA-Z0-9]+$/;
	    return regExp.test(spotId);

    },
    createVRF : function(component){

        var toastEvent  = $A.get("e.force:showToast");
        var vrfClientId = component.find("clientId").get("v.value");
        var vrfSpotId   = component.find("spotId").get("v.value");
        var vastTag     = component.get("v.vastTag");

        component.set("v.disableButton",true);

        if (vrfClientId == '' ||  vrfClientId == null){

            toastEvent.setParams({
                "type" : "error",
                "title": "Validation Error",
                "message": "Please select a  VRF Client ID"
              });
        
              toastEvent.fire();
              return;
        }

        vrfSpotId = (vrfSpotId == null) ? "" : vrfSpotId;


        if (vastTag){
        
            if (vrfSpotId.length < 0){
                toastEvent.setParams({
                    "type" : "error",
                    "title": "Validation Error",
                    "message": "Vast Tag is checked. Cannot Entered any value on the Spot ID Text Box"
                  });
            
                  toastEvent.fire();
                  return;
            }

        }
        else{


            if ((vrfSpotId.length < 9 && vrfSpotId.length < 8)){
                toastEvent.setParams({
                    "type" : "error",
                    "title": "Validation Error",
                    "message": "VRF Spot Id must be 8 or 9 characters"
                });
            
                toastEvent.fire();
                return;
            }
          
        }

        var creativeId  = component.get("v.recordId"); 
        var action      = component.get("c.saveVRFData");

        component.set("v.isSpinnerVisible", true);

        action.setParams({
            "creativeId" : creativeId,
            "vrfClientId": vrfClientId,
            "spotId" : vrfSpotId
        });

        action.setCallback(this, function(response){

            var state = response.getState();
            var error = response.getError();

            if (state == "SUCCESS"){
        
                var result = JSON.parse(response.getReturnValue());

                if (result.isSuccessfull){

                    if (result.StatusCode == 200){

                        toastEvent.setParams({
                            "type" : "success",
                            "title": "Success!",
                            "message": "The record has been updated successfully."
                        });
        
                        toastEvent.fire();
            
                        var cmpTarget = component.find('messageDiv');
                        $A.util.removeClass(cmpTarget, 'hide');
    
                        component.set("v.vrfClass.isVrfVisible", false);
                        component.set("v.vrfClass.isSubmitValid", false);        
                        component.set("v.vrfClass.isVRFMessageVisble", true);
                        component.set("v.submitMsg", "VRF Submitted Successfully");
    
                        this.updateStatus(component, creativeId);

                    }

                    // Warning Message from MW
                    if (result.StatusCode == 409){

                        toastEvent.setParams({
                            "mode":"dismissible",
                            "duration": "15000",
                            "type" : "warning",
                            "title": "Warning!",
                            "message": result.Message
                        });
        
                        toastEvent.fire();

                    }

                }
                else {
                    component.set("v.disableButton",false);
                    this.middleWareError(component, result.Message,vrfSpotId, vrfClientId);
                }
         
            }else {
                this.middleWareError(component, error[0].message, vrfSpotId, vrfClientId);
            }

            component.set("v.isSpinnerVisible", false);
            $A.get("e.force:refreshView").fire();
        });

        $A.enqueueAction(action);

    },
    updateStatus: function(component, creativeId){

        var action  = component.get("c.UpdateStatus");

        action.setParams({
            "creativeId" : creativeId,
        });

        action.setCallback(this, function(response){

            var state = response.getState();
            var error = response.getError();

            if (state == "SUCCESS"){
                console.log("Update Status Successfully");
            }else{
                console.log("Update Status Successfailed " + error[0].message);
            }

            setTimeout(function(){
                $A.get("e.force:refreshView").fire(); }
                , 2000);          
        });

        $A.enqueueAction(action);
        
    },
    middleWareError: function(component, message, vrfSpotId, vrfClientId){
        console.log("Error: " + message);

        var toastEvent  = $A.get("e.force:showToast");

        toastEvent.setParams({
            "type" : "error",
            "title": "Error",
            "message": `DCC not submitted. Please contact your sales admin.  ${message}`
        });
        
        toastEvent.fire();

        this.sendEmail(component, message, vrfSpotId, vrfClientId);
    },
    sendEmail : function(component, message, spotId, vrfClientId){

        var action      = component.get("c.SendErrorMessage");
        var creativeId  = component.get("v.recordId"); 

        action.setParams({
            "creativeId" : creativeId,
            "message": message.substring(0, 50),
            "spotId" : spotId,
            "vrfClientId" : vrfClientId
        });

        action.setCallback(this, function(response){

            var state = response.getState();

            if (state == "SUCCESS"){
                console.log("Email send");
            }else{
                console.log("Email not send");
            }

        });

        $A.enqueueAction(action);

    }


})