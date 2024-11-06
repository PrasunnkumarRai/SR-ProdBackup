({
	doInit : function(component, event, helper) {
        
        var recordId = component.get("v.recordId");
        console.log('----> RecordId : '+recordId);
        if( recordId != null ){
            console.log('----> inside if.');
            $A.get("e.force:navigateToSObject").setParams({
                "recordId": recordId,
            }).fire();
        }else{
            console.log('----> inside else.');
            $A.get("e.force:navigateToObjectHome").setParams({
                "scope": "Account"
            }).fire();
        }
        
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            type: 'warning',
            duration : 10000,
            message: 'The Account Request must be created from an Account.'
        });
        toastEvent.fire();
    }
})