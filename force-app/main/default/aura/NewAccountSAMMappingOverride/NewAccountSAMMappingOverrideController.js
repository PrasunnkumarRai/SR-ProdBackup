({
    doInit: function (component, event, helper) {
        helper.openNewSAMMapping(component, event, helper);
    },
    hideModel: function (component, event, helper) {
        helper.dismissQuickAction(component, event, helper);
    },
    onRecordSave: function (component, event, helper) {
        component.set('v.loaded', component.get('v.loaded'));         
        if (helper.validateform(component)) {            
            component.find("editform").submit();
            //window.location.reload(); // SRSF-4428 : Commented to show error message
        }
        else {
            helper.showerrorToast(component);
        }
    },
    handleSuccess: function (component, event, helper) {
        helper.onSuccess(component, event, helper);
    }   
})