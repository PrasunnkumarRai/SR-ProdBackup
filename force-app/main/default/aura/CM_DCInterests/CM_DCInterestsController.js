({
	scriptsLoaded : function(component, event, helper) {
        var recId = component.get("v.recordId");
        helper.fetchCategoriesHelper(component);
		helper.prepareData(component, event, helper);
    },
    
    addNewRow: function(component, event, helper) {
        helper.createObjectData(component, event, helper);
    },
    
    saveJS: function(component, event, helper) {
        helper.saveDataHelper(component, event, helper);
    },
    
    removeRow: function(component, event, helper) {
        var index = event.currentTarget.id;
        helper.removeRowHelper(component, event, helper, index);
    },
    
    fetchSubCategoriesJS : function(component, event, helper) {
        var index = event.getSource().get("v.class");
        helper.fetchSubCategoriesHelper(component, event, helper,index);
    },
    
    fetchInterestsJS : function(component, event, helper) {
        var index = event.getSource().get("v.class");
        helper.fetchInterestsHelper(component, event, helper,index);
    },
})