({
    doInit : function(component, event, helper)
    {        
        var recId = component.get('v.recordId');
        console.log('recId>>>>>>'+recId);
        var action = component.get("c.sendReqToCreateAOSDeal");
        action.setParams({
            "proposalId" : recId                     
        }); 
        action.setCallback(this, function(response)
        {
            var state = response.getState();
            if(state == "SUCCESS")
            {
                var data = response.getReturnValue();
                console.log('data>>>>>'+data);
                if(data != "" || data != null)
                {
                    if(data.includes('Error') || data.includes('Exception'))
                    {
                        helper.showToastMsg(component, "Error!","error", data);
                    } 
                    else
                    {
                        window.open(data);
                    }                   
                }
            }
            else if(state == "ERROR")
            {
                var errors = response.getError();
                if(errors)
                {
                    if(errors[0] && errors[0].message)
                    {
                        helper.showToastMsg(component, "Error!","error", errors[0].message);
                        console.log("Error message: " + errors[0].message);
                    }
                } 
                else
                {
                    helper.showToastMsg(component, "Error!","error", "Unknown error");
                    console.log("Unknown error");
                }
            }            
            $A.get("e.force:closeQuickAction").fire();
        });
        $A.enqueueAction(action);                  
    },
    /*showSpinner : function (component, event, helper) {        
        var spinnerMain =  component.find("spinner");
        $A.util.removeClass(spinnerMain, "slds-hide");            
    },
    hideSpinner : function (component, event, helper) {
        var spinnerMain =  component.find("spinner");
        $A.util.addClass(spinnerMain, "slds-hide");            
    }*/ 
})