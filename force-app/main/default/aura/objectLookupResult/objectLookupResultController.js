({
	 selectObject : function(component, event, helper){  
	 	console.log('======================>>> in selectObject!!!');    
    // get the selected Obect from list  
      var getSelectObject = component.get("v.oObject");
      console.log('-------->> getSelectObject = ' + JSON.stringify(getSelectObject));
    // call the event   
      var compEvent = component.getEvent("oSelectedObjectEvent");
    // set the Selected Contact to the event attribute. 
         var sObjectRec = getSelectObject.sObjectRec;
         compEvent.setParams({"objectByEvent" : sObjectRec });  
      console.log('compEvent: ' + compEvent);
    // fire the event  
         compEvent.fire();
    },


})