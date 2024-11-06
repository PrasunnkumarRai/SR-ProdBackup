({
    openNewResearchRequest : function( component, event, helper ) {
        var recordId = component.get("v.recordId");
        var action = component.get("c.createSupportRequest");
        console.log('oppID>>>>>'+recordId);
        action.setParams({
            "opptyId" : recordId,
            "selectedRequest" : "researchRequest"
        }); 
        action.setCallback(this, function( response ){
            var state = response.getState();
            if( state == "SUCCESS" ){
                var data = response.getReturnValue();                
                if(data == "" || data == null){
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Error!",
                        "type" : "error",
                        "mode" : "dismissible",
                        "duration" : 7000,
                        "message": "You are not allowed to create a Research Request as you are Either 'Not present in the Opportunity Team Member list' or 'Not a Valid Tier Mapping record for the AE'."
                    });
                    toastEvent.fire();
                    var navEvt = $A.get("e.force:navigateToSObject");
                    navEvt.setParams({
                      "recordId": recordId,
                    });
                    navEvt.fire();
                }               
                else{
                    console.log("data--->"+data);
                    console.log('isPreferred-->'+data.hasOwnProperty('isPreferred'));
                    console.log('isOnOpptyTeam-->'+data.hasOwnProperty('isOnOpptyTeam'));                    
                    /*if(data.hasOwnProperty('isPreferred')){                        
                        component.set("v.recordData", data);                    
                        helper.dismissQuickAction( component, event, helper );
                    }
                    else{ */                       
                        if(data.hasOwnProperty('isPreferred') || !data.hasOwnProperty('isOnOpptyTeam')){
                            component.set("v.recordData", data);                         
                        }
                        if(data.hasOwnProperty('isOnOpptyTeam')){
                            var conf  = confirm("There is not a Valid Tier Mapping record for the Opportunity Owner. Do you want to continue?");
                            if(conf){
                                component.set("v.recordData", data); 
                            }                            
                        }
                    //}
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
    validateform: function(component) {

          var comscore=component.get('v.recordData.defaultFieldValues.ComScore__c');
          var Nielsen=component.get('v.recordData.defaultFieldValues.Nielsen_Demographics__c');
          var selectedValue = component.get('v.recordData.defaultFieldValues.Ratings_Service__c');
          if(selectedValue == 'Comscore' && comscore ==null){
             this.showerrorComscore(component);
             return false; 
            // component.set('v.ValComScore',false);
            }else{
            component.set('v.ValComScore',true);
           }
          if(selectedValue == 'Nielsen' && Nielsen ==null){
            this.showerrorNielsen(component);
            //component.set('v.ValNielsen',false);
             return false; 
            }else{
            component.set('v.ValNielsen',true);
           }
        
        var reqfelds = [].concat(component.find('requiredField'));
        for(var i=0;i<reqfelds.length;i++){
            if($A.util.isEmpty(reqfelds[i].get("v.value"))){
                return false;
//this.showerrorToast(component);
               }            
        }
        return true;
    },
    showerrorToast : function(component) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": "Required Field Error!",
            "type": "error",
            "message": "Please fill the required fields and then try to save again."
        });
        toastEvent.fire(); 
    },
    showerrorComscore: function(component){
    var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": "RatingScore is Comscore",
            "type": "error",
            "message": "Please select the comscore value"
        });
        toastEvent.fire(); 
},
 showerrorNielsen: function(component){
    var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": "RatingScore is Nilesen",
            "type": "error",
            "message": "Please select the Nielsen Demographics value"
        });
        toastEvent.fire(); 
},

})