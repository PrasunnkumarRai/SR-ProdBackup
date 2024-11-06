({
	scriptsLoaded : function(component, event, helper) {
        var recId = component.get("v.recordId");
		helper.fetchPlanDetails(component, recId);
    },
    
    Save: function(component, event, helper) {
        var recId = component.get("v.recordId");
        helper.savePlanDetails(component, event, helper, recId);
    },
    
    addNewRow: function(component, event, helper) {
        helper.createObjectData(component, event, helper);
    },
    
    onlyNum: function(component, event, helper) {
        helper.onlyNumber(component, event, helper);
    },
    
    onChangeInentorySource: function(component, event, helper) {
        var RowItemList = component.get("v.datesArray");
        var index = event.getSource().get("v.class");
        if(RowItemList[index].selIS == "TTD - CTV"){
            RowItemList[index].selType = "Pre Roll Custom";
        }else{
            RowItemList[index].selType = "Ads Everywhere";
        }
        component.set("v.showErrorMsg", false);
        component.set("v.datesArray", RowItemList);
        helper.checkValidations(component, event, helper);
    },
    
    checkForPrimary: function(component, event, helper) {
        var RowItemList = component.get("v.datesArray");
        var index = event.getSource().get("v.class");
        //alert(index);
        var isChecked = RowItemList[index].isPrimary;
        if(isChecked){
            for(var indx in RowItemList){
            if(isChecked == true && indx!=index)
            	RowItemList[indx].isPrimary = false;
        	}
            component.set("v.datesArray", RowItemList);
        }
    },
    
    checkForPrimaryOld: function(component, event, helper) {
        var RowItemList = component.get("v.datesArray");
        var index = event.getSource().get("v.class");
        //alert(index);
        var isChecked = RowItemList[index].isPrimary;
        var adsEPlatform = component.get("v.resultWrap").objDCampaign.AdsE_Platform_s__c;
        if(isChecked && RowItemList[index].selIS == "Freewheel – FF TVE" && adsEPlatform!="3rd Party Apps"){
            RowItemList[index].isPrimary = false;
            component.set("v.datesArray", RowItemList);
            helper.showToast("error", "Error!", "Select Platform(s) should be '3rd Party Apps' when Freewheel – FF TVE is primary.");
        	return false;
        }
        //alert(isChecked);
        for(var indx in RowItemList){
            if(isChecked == true && indx!=index)
            	RowItemList[indx].isPrimary = false;
        }
        component.set("v.showErrorMsg", false);
        component.set("v.datesArray", RowItemList);
        helper.checkValidations(component, event, helper);
    },
    
    removeRow: function(component, event, helper) {
        var objWrap = component.get("v.resultWrap");
        var index = event.currentTarget.id;
        var RowItemList = component.get("v.datesArray");
        RowItemList.splice(index, 1);
        if(RowItemList.length == 1)
            RowItemList[0].disable = false;
        component.set("v.datesArray", RowItemList);
        helper.checkValidations(component, event, helper);
    },
    
    handleOnLoad: function (component, event, helper) {
        var recId = component.get("v.recordId");
        //alert(recId);
		helper.fetchPlanDetails(component, recId);
    },
    
})