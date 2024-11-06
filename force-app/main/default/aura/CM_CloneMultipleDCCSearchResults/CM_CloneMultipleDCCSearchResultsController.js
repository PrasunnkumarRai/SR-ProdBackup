({
    //Check selected Digital Campaign is valid to clone based on DCC_Clone_Matrix__mdt.
    selectRecord : function(component, event, helper){
        
        //console.log(component.get("v.fromDC").Name);
        //console.log(component.get("v.toDC").Name);
        
         var action = component.get("c.checkForValidDC");
        // set param to method  
        action.setParams({
            'fromDCObj': component.get("v.fromDC"),
            'toDCObj' : component.get("v.toDC")
        });
        // set a callBack    
        action.setCallback(this, function(response) {
            $A.util.removeClass(component.find("mySpinner"), "slds-show");
            var state = response.getState();
            if (state === "SUCCESS") {
                var isValid = response.getReturnValue();
                //alert("isValid::"+isValid);
                if (isValid) {
                    var getSelectRecord = component.get("v.toDC");
                    var compEvent = component.getEvent("oSelectedRecordEvent");
                    compEvent.setParams({"recordByEvent" : getSelectRecord, "fromDCRecord" : component.get("v.fromDC"), "toDCRecord" : component.get("v.toDC")});  
                    compEvent.fire();
                } else {
                    alert(component.get("v.toDC").Name+" is not a Valid DC..");
                }
            }
        }); 
        $A.enqueueAction(action);
    },
})