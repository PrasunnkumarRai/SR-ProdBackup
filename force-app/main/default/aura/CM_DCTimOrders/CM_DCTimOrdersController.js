({
	scriptsLoaded : function(component, event, helper) {
        //var recId = component.get("v.recordId");
        helper.fetchTIMOrderData(component, event, helper);
    },
    
    Save: function(component, event, helper) {
        var recId = component.get("v.recordId");
        //var recId = "a084100000A63PtAAJ";
        helper.saveTIMData(component, recId);
    },
    
    addNewRow: function(component, event, helper) {
        helper.createObjectData(component, event);
    },
    
    removeRow: function(component, event, helper) {
        //var index = event.getParam("indexVar");
        var index = event.currentTarget.id;
        var AllRowsList = component.get("v.timArray");
        AllRowsList.splice(index, 1);
        component.set("v.timArray", AllRowsList);
    }
    
})