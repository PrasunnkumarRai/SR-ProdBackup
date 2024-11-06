({
   selectRecordChild : function(component, event, helper){            
    // get the selected record from list                  
      var getSelectRecord = component.get("v.oRecord");  
      //alert(getSelectRecord.Id);
              
    // call the event   
      var compEvent = component.getEvent("oSelectedRecordEventChild");
    // set the Selected sObject Record to the event attribute.  
        compEvent.setParams({"recordByEventChild" : getSelectRecord });  
    // fire the event  
         compEvent.fire();
    }
})