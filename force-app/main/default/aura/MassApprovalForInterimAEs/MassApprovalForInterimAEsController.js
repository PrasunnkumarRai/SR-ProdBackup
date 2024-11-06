({
    doInit : function(component, event, helper) 
    {
        helper.fetchInterimAEAccountsList(component,helper);               
    },
    
    SelectAllCheck:function(component,event,helper)
    {
        var checkvalue = component.find("selectAll").get("v.value");              
        var checkInterimAE = component.find("checkInterimAE"); 
        var len = checkInterimAE.length;

        for (var i = 0; i<len; i++){
          checkInterimAE[i].set("v.value",checkvalue);
        }
    },
    validateSelectAllCheck : function(component,event,helper) 
    {       
        var checkInterimAE = component.find("checkInterimAE");
        var len = checkInterimAE.length;
        var count = len;
        for (var i = 0; i<len; i++){        
        if(!checkInterimAE[i].get("v.value")){
          count --; 
            break;
        }
    }
    if(count == len){
      component.find("selectAll").set("v.value", true); 
    }
    else{
      component.find("selectAll").set("v.value", false);
    }

    },

    ApproveReject:function(component,event,helper)
    {
       $A.util.removeClass(component.find("mySpinner"),"slds-hide");
       
       var clickedBtn = event.getSource().getLocalId(); 

       var approverComments = component.find("comments");
       var checkInterimAE = component.find("checkInterimAE");
       //SRSF-4170: Added below Array check conditions 
       if (!Array.isArray(checkInterimAE)) {
        checkInterimAE = [checkInterimAE];        
       }      
       if (!Array.isArray(approverComments)) {
        approverComments = [approverComments];        
       }      
       var len = checkInterimAE.length;       
       
       var theMap = component.get("v.interimAEMap");  

       var isApproved = false;
       if (clickedBtn == 'approve'){
            isApproved = true;
       } 
       var count = 0;
       for(var i=0;i<len;i++)
       {
          if(checkInterimAE[i].get("v.value") == true)  
          {                         
            count++;
            theMap[checkInterimAE[i].get("v.text")] = approverComments[i].get("v.value");
          }  
       } 
       var myMap= component.get("v.interimAEMap");
       
        if(count == 0) {

            $A.util.addClass(component.find("mySpinner"), "slds-hide");

            component.find('notifLib').showToast({
                "variant": "error",
                "title": "Error!",
                "mode" : "dismissable",
                'message': $A.get("$Label.c.Select_atleast_one_record_for_Approve_Reject")
            });
        } 
        else {
           var action = component.get('c.processApprovalRequest');       
           action.setParams({
              "interimRecs": theMap,
              "isApproved": isApproved
           });
           action.setCallback(this, function(response) {
                var state = response.getState();
                if( state === "SUCCESS" ){  
                    $A.get('e.force:refreshView').fire(); // To reload UI
                    component.find('notifLib').showToast({
                        "variant": "success",
                        "title": "Success!",
                        "mode" : "dismissable",
                        'message': $A.get("$Label.c.Request_Processed")
                    });
                }else if (state === "ERROR") {
                    var errors = response.getError();                  
                    if (errors) {                     
                        if (errors[0] && errors[0].message) {
                            console.log("Error message: " + errors[0].message);                    
                            component.find('notifLib').showToast({
                                "variant": "error",
                                "title": "Error!",
                                "mode" : "dismissable",
                                'message': errors[0].message
                            });
                        }
                    } 
                }
                $A.util.addClass(component.find("mySpinner"), "slds-hide");
           });

           $A.enqueueAction(action); 
        }   
    },
    /*showText : function(component,event,helper)
    {       
       var approverComments = component.find("comments");
       var checkInterimAE = component.find("checkInterimAE");      
       var len = checkInterimAE.length;
       for(var i=0;i<len;i++)
       {
          if(checkInterimAE[i].get("v.value") == true)  
          {
            var comments = approverComments[i].get("v.value");
            alert('approverComments>>>'+comments);
          }  
       }
    }*/ 
})