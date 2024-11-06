({
	 selectContact : function(component, event, helper){      
    // get the selected Contact from list  
      var getSelectContact = component.get("v.oContact");
      console.log('-------->> getSelectContact = ' + JSON.stringify(getSelectContact));
    // call the event   
      var compEvent = component.getEvent("oSelectedContactEvent");
    // set the Selected Contact to the event attribute.  
         compEvent.setParams({"contactByEvent" : getSelectContact });  
    // fire the event  
         compEvent.fire();
    },
})