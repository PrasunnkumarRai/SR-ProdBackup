({
  doInit: function (component, event, helper) {
    component.set("v.showModal", true);
    helper.openNewAudienceRequest(component, event, helper);
  },
  hideModal: function (cmp, event, helper) {
    $A.get("e.force:closeQuickAction").fire();
  },  
  onSave: function (component, event, helper) {
    console.log("inside Record Save>>>");
    component.set('v.SaveAndNew', false);
    component.set("v.loaded", component.get("v.loaded")); 
    component.find("editform").submit();
  },
  onSaveNew: function (component, event, helper) {
    console.log("inside Save & New>>>");
    component.set('v.SaveAndNew', true);
    component.set("v.loaded", component.get("v.loaded"));  
    component.find("editform").submit();
  },  
  handleSuccess: function (component, event, helper) {    
    component.set("v.loaded", !component.get("v.loaded"));
    var payload = event.getParams().response;
    console.log("payload>>>>>", payload);
    if (payload.id) {
      var toastEvent = $A.get("e.force:showToast");
      toastEvent.setParams({
        title: "Success!",
        type: "success",
        message: "The record has been saved successfully.",
      });
      toastEvent.fire();
      if (component.get('v.SaveAndNew')) {
          helper.clear(component, helper);
      } else{
        var navService = component.find("navService");
        var pageReference = {
          type: "standard__recordPage",
          attributes: {
            recordId: payload.id,
            objectApiName: "Support_Request__c",
            actionName: "view",
          }
        }
        navService.navigate(pageReference);
      }  
      event.preventDefault();
    }
  },
  handleError: function (component, event) {
    var errors = event.getParams();
    console.log("Error Response>>>>", JSON.stringify(errors));    
    if (errors) {
      var toastEvent = $A.get("e.force:showToast");
      toastEvent.setParams({
        title: "Error!",
        type: "error",
        message: errors.detail,
      });
      toastEvent.fire();
    }
  },
  //SRSF-3993(Digital)
  handleStatusChange: function (component, event) {
    console.log("handleStatusChange:: ", event);
    if (event.getParams().value == "Approved Pending Creative Review") {
      component.set("v.creativeRequiresReviewVal", true);
    } else {
      component.set("v.creativeRequiresReviewVal", false);
    }
  },
});