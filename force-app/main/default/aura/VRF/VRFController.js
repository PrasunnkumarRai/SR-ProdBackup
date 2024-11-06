({
  doInit: function(component, event, helper) {

    var id = component.get("v.recordId");
    console.log("Record id is " + id);

    helper.getVRFComponents(component);
    helper.getDigitalCreativeRecord(component);

    setTimeout(function(){
      $A.get("e.force:refreshView").fire(); }
      , 2000);
  
  },
  closeModal: function(component, event, helper) {

    $A.get("e.force:refreshView").fire();
    $A.get("e.force:closeQuickAction").fire();

  },
  createVRF: function(component, event, helper) {

    var recordId = component.get("v.recordId");
    var SpotId    = component.find("spotId").get("v.value");

    console.log(
      "This will send the payload on the VRF Middleware " +
        "Creative Id is " +
        recordId +
        " Spot id " +
        SpotId
    );

    helper.createVRF(component);
 
  },
  checkIfNotNumber : function(component, event, helper) {

      var spotComponent  = component.find("spotId");
      var spotId         = spotComponent.get("v.value");
      var validationMsg  = component.find("validationMsg");
      var vastTag = component.get("v.vastTag");

      if (helper.validateClientId(spotId) || vastTag){
          component.set("v.disableButton",false); 
          component.set("v.hide","hide");           
      }else{
          component.set("v.disableButton",true);
          component.set("v.hide","");       
      }             
  }
});