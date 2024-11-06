({
    doInit : function(component, event, helper) {
        component.set("v.showModal", true);
        helper.openNewResearchRequest( component, event, helper );
    },
    hideModal : function(cmp, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    },
    onRecordSubmit: function(component, event, helper) {
/* var comscore=component.get('v.recordData.defaultFieldValues.ComScore__c');
var Nielsen=component.get('v.recordData.defaultFieldValues.Nielsen_Demographics__c');
  var selectedValue = component.get('v.recordData.defaultFieldValues.Ratings_Service__c');
       if(selectedValue == 'Comscore' && comscore ==null){
              helper.showerrorComscore(component);
        }
        if(selectedValue == 'Nielsen' && Nielsen ==null){
              helper.showerrorNielsen(component);
        }*/
       console.log('inside RecordSubmit>>>'); 
       component.set("v.statusVal","Submitted to Research");
       component.set('v.loaded', component.get('v.loaded'));
       if(helper.validateform(component)){
            component.find("editform").submit();
       }
       else{
         helper.showerrorToast(component); 
        }
   },    
    onSave :  function(component, event, helper) {
 /* var comscore=component.get('v.recordData.defaultFieldValues.ComScore__c');
var Nielsen=component.get('v.recordData.defaultFieldValues.Nielsen_Demographics__c');
  var selectedValue = component.get('v.recordData.defaultFieldValues.Ratings_Service__c');
       if(selectedValue == 'Comscore' && comscore ==null){
              //helper.showerrorComscore(component);
          component.set('v.ValComScore',false);
        }else{
            component.set('v.ValComScore',true);
        }
        if(selectedValue == 'Nielsen' && Nielsen ==null){
             // helper.showerrorNielsen(component);
            component.set('v.ValNielsen',false);
        }else{
           component.set('v.ValNielsen',true);
        }*/


       component.set('v.loaded', component.get('v.loaded'));
       if(helper.validateform(component)){
           component.find("editform").submit();
       }
      else {
           helper.showerrorToast(component); 
        }   },
    
    onRatingServiceChange: function(component, event,helper){
        console.log('Inside rating service change');
        var selectedValue = component.get('v.recordData.defaultFieldValues.Ratings_Service__c');
        if(selectedValue == 'Comscore'){
            component.set('v.isNielsenDemographics',true);//disabledNielsenDemographics
            component.set('v.isComScore',false);
        }
        if(selectedValue == 'Nielsen'){
        component.set('v.isComScore',true); //disabledComScore
        component.set('v.isNielsenDemographics',false);
}
    },
    
    handleSuccess : function(component, event, helper) {
        component.set('v.loaded', !component.get('v.loaded'));
        var payload = event.getParams().response;
        console.log("payload", payload);
        if(payload.id){
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "Success!",
                "type": "success",
                "message": "The record has been saved successfully."
            });
            toastEvent.fire();
            var navService = component.find("navService");
            var pageReference = {
                type: 'standard__recordPage',
                attributes: {
                    "recordId": payload.id,
                    "objectApiName": "Support_Request__c",
                    "actionName": "view"
                }
            }
            event.preventDefault();
            navService.navigate(pageReference);  
        }  
    },    
    handleError: function(component, event) {
        var errors = event.getParams();
        console.log("response", JSON.stringify(errors));
        //helper.showerrorToast(component); //Added newly
        if(errors){
           var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "Error!",
                "type": "error",
                "message": errors.detail
            });
                toastEvent.fire(); 
        }
    }
})