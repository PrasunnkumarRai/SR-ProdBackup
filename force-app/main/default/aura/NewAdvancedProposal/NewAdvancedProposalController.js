({
    doInit : function(component, event, helper)
    {       
        helper.fetchProposalData(component, event, helper);        
    },
    hideModal: function (component, event, helper)
    {
        $A.get("e.force:closeQuickAction").fire();
    },
    onSave: function (component, event, helper)
    {
        console.log("inside Record Save>>>");       
        component.set("v.loaded", component.get("v.loaded"));
        helper.createAdvancedProposal (component, event, helper);                
    },
    handleOrderTypeChange: function (component, event, helper)
    {
        var selectedValues = component.find("orderType").get("v.value");
        component.set("v.orderTypeSelected",component.find("orderType").get("v.value"));
        console.log('selectedValues--->'+selectedValues);
        helper.getPicklistValues(component, 'Product_Type__c',component.get("v.orderTypeSelected"));                
    },
    handleProductTypeMultiChange: function (component, event, helper)
    {
        var selectedProdValues = event.getParam("value");        
        console.log('selectedValues--->'+selectedProdValues);
        component.set("v.productType", selectedProdValues);           
    },
    handleProductTypeChange: function (component, event, helper)
    {        
        var selectedProdValues = component.find("prodTypePicklist").get("v.value");
        console.log('selectedValues--->'+selectedProdValues);
        component.set("v.productType", selectedProdValues);           
    }
})