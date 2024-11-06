({
	scriptsLoaded : function(component, event, helper) {
		// active/call select2 plugin function after load jQuery and select2 plugin successfully    
       $(".select2Class").select2({
           placeholder: "Select Multiple values"
       });
       var recId = component.get("v.recordId");
        helper.fetchPickListVal(component, recId);
	},
    
    doInit : function(component, event, helper) {
       /*On the component load call the fetchPickListVal helper method
         pass the Picklist[multi-select] API name in parameter  
       */
     //   var recId = component.get("v.recordId");
      //  helper.fetchPickListVal(component, recId);
    },
    
    updateZipcode : function(component, event, helper){
        var lockRecord = component.get("v.lockRecord");
        if( lockRecord ) 
            return false;
        
        var recId = component.get("v.recordId");
        var zipData = component.get("v.Zipcode");
        //var selectedSkills = $('[id$=picklist]').select2("val");
        if(zipData!=undefined)
        	zipData = zipData.replace(/ /g, '');
        else
            zipData = null;
        helper.updateZipcodeCH(component,recId,zipData);
        //$("#picklist").val(["One"]).select2();
    }
})