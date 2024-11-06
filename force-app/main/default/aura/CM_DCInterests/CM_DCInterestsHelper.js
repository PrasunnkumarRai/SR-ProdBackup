({
	//Adding one more row with Category, SubCategory and Interest 
    createObjectData: function(component, event, helper) {
        var arrcat = component.get("v.categoryArray");
        var RowItemList = component.get("v.interestArray");
        var objWrap = component.get("v.resultWrap");
        RowItemList.push({"category": "","subCategory": "","interest":"","disable":false,"lstCategory":arrcat,"lstSC":null,lstInt:null});              
        component.set("v.interestArray", RowItemList);
    },
    
    //Fetching all the SubCategories related to the Category
	prepareData : function(component, event, helper, index) {
        var action = component.get("c.PrepareData");
        action.setParams({
             dcRecordId: component.get("v.recordId")
        });
        action.setCallback(this, function(response) {
            if (response.getState() === "SUCCESS") {
                var objWrap = response.getReturnValue();
                component.set("v.resultWrap", objWrap);
                component.set("v.interestArray", objWrap.lstInterest);
            }else if (response.getState() === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        this.showToast("error", "Error!", errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
        $A.enqueueAction(action);
        var tooltip = $A.get("$Label.c.CM_DCInterests");
        var res = tooltip.replace(/\n/g, "<br/>");
        component.set("v.interestTooltip", res);
	},
    
    checkForRequiredFields: function(component, event, helper) {
        var industryitems = component.get("v.interestArray");
        var lstRec = [];
        var isRequiredMissing = false;
        for(var indx in industryitems){
            var categoryjs = industryitems[indx].category;
            var subcategoryjs = industryitems[indx].subCategory;
            var interestjs = industryitems[indx].interest;
            if(categoryjs==null || categoryjs=="" || 
               subcategoryjs==null || subcategoryjs=="" || 
               interestjs==null || interestjs==""){
                isRequiredMissing = true;
                break;
            }
        }
        return isRequiredMissing;
    },
    
    checkForDuplicates: function(component, event, helper) {
        var industryitems = component.get("v.interestArray");
        var lstRec = [];
        for(var indx in industryitems){
            var categoryjs = industryitems[indx].category;
            var subcategoryjs = industryitems[indx].subCategory;
            var interestjs = industryitems[indx].interest;
            lstRec.push(categoryjs+';'+subcategoryjs+';'+interestjs);
        }
        let dupRecs = lstRec.filter((c, index) => {
            return lstRec.indexOf(c) !== index;
        });
        console.log(dupRecs);
        console.log(dupRecs.length);
        return dupRecs.length;
    },
    
    saveDataHelper: function(component, event, helper) {
        var isRequiredFieldsMissing = this.checkForRequiredFields(component,event,helper);
        if(isRequiredFieldsMissing==true){
            component.set("v.showErrorMsg", true);
            component.set("v.ErrorMsg", "Category, Sub-Category, and Interest are required for each line.");
            return false;
        }
        var duplicates = this.checkForDuplicates(component,event,helper);
        if( duplicates>0 ){
        	component.set("v.showErrorMsg", true);
            component.set("v.ErrorMsg", "Category, Sub-Category, and Interest must be unique.");
            return false;
        }else{
            component.set("v.showErrorMsg", false);
            component.set("v.ErrorMsg", "");
        }
        var categoryjs='';
        var subcategoryjs='';
        var interestjs='';
        var industryitems = component.get("v.interestArray");
        for(var indx in industryitems){
            categoryjs+=industryitems[indx].category+",";
            subcategoryjs+=industryitems[indx].subCategory+",";
            interestjs+=industryitems[indx].interest+",";
        }
        if(categoryjs!=''){
            categoryjs = categoryjs.substring(0,categoryjs.length-1);
            subcategoryjs = subcategoryjs.substring(0,subcategoryjs.length-1);
            interestjs = interestjs.substring(0,interestjs.length-1);
        }
        //alert(subcategoryjs);
        var action = component.get("c.saveData");
        action.setParams({
             dcRecordId: component.get("v.recordId"),
             category: categoryjs,
             subcategory: subcategoryjs,
             interest: interestjs
        });
        action.setCallback(this, function(response) {
            if (response.getState() === "SUCCESS") {
                this.showToast("success", "Success!", "Interests have been added successfully.");
                this.prepareData(component, event, helper);
            }else if (response.getState() === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        this.showToast("error", "Error!", errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
        $A.enqueueAction(action);
        
    },
    
    removeRowHelper: function(component, event, helper, index) {
        var RowItemList = component.get("v.interestArray");
        RowItemList.splice(index, 1);
        component.set("v.interestArray", RowItemList);
    },
    
    //Fetching all the Categories
	fetchCategoriesHelper : function(component) {
        var action = component.get("c.fetchCategories");
        action.setCallback(this, function(response) {
            if (response.getState() === "SUCCESS") {
                var objWrap = response.getReturnValue();
                component.set("v.categoryArray", objWrap);
            }else if (response.getState() === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        this.showToast("error", "Error!", errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
        $A.enqueueAction(action);
	},
    
    //Fetching all the SubCategories related to the Category
	fetchSubCategoriesHelper : function(component, event, helper, index) {
        var industryitems = component.get("v.interestArray");
        var categoryname = industryitems[index].category;
        var action = component.get("c.fetchSubCategories");
        action.setParams({
             strCategory: categoryname
        });
        action.setCallback(this, function(response) {
            if (response.getState() === "SUCCESS") {
                var objWrap = response.getReturnValue();
                industryitems[index].lstSC = objWrap;
                component.set("v.interestArray", industryitems);
            }else if (response.getState() === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        this.showToast("error", "Error!", errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
        $A.enqueueAction(action);
	},
    
    //Fetching all the Interests related to the Category and Subcategory
	fetchInterestsHelper : function(component, event, helper, index) {
        var industryitems = component.get("v.interestArray");
        var categoryname = industryitems[index].category;
        var subcategoryname = industryitems[index].subCategory;
        var action = component.get("c.fetchInterests");
        action.setParams({
             strCategory: categoryname,
            strSubCategory: subcategoryname
        });
        action.setCallback(this, function(response) {
            if (response.getState() === "SUCCESS") {
                var objWrap = response.getReturnValue();
                industryitems[index].lstInt = objWrap;
                component.set("v.interestArray", industryitems);
            }else if (response.getState() === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        this.showToast("error", "Error!", errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
        $A.enqueueAction(action);
	},
    
    //Message to display on Lightning Component after DML
    showToast : function( type, title, msg ){
    	var toastEvent = $A.get("e.force:showToast");
    	toastEvent.setParams({
    		"type": type,
            "title": title,
            "message": msg
        });
        toastEvent.fire();
    }
})