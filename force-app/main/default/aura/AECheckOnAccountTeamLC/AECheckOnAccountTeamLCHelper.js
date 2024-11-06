({
    checkForAE: function(component, event, helper) {
        //alert(component.get("v.recordId"));
        var action = component.get("c.checkAccExeInAccTeam");
        action.setParams({
            "aeId": component.get("v.recordId")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state == "SUCCESS") {
                var resObj = response.getReturnValue();
                component.set("v.isAEExists", resObj.isAEOnAccTeam);
                component.set("v.SalesOffice", resObj.strSO);
            } else if (state == "ERROR") {
                var errors = response.getError();
                console.log('----> Error : ' + JSON.stringify(errors[0]));
            }
        });
        $A.enqueueAction(action);
    },
})