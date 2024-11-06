({
    //Fetch Picklist Data in the Pageload
	scriptsLoaded : function(component, event, helper) {
		// active/call select2 plugin function after load jQuery and select2 plugin successfully    
        var recId = component.get("v.recordId");
        //helper.fetchPickListVal(component, recId);
        helper.fetchPickListVal(component, recId);
        console.log('---> binding doInit select2.');
        $("#picklist1, #picklist2, #picklist3").select2({
            placeholder: "Select Multiple values"
        });
    },
    
    //Not Using
    doInit : function(component, event, helper) {
       /*On the component load call the fetchPickListVal helper method
         pass the Picklist[multi-select] API name in parameter  
       */
       //var recId = component.get("v.recordId");
    },
    
    //Updating Geographies data
    updateZipcode : function(component, event, helper){
        
        var lockRecord = component.set("v.lockRecord");
        if( lockRecord )
            return false;
        
        var recId = component.get("v.recordId");
        var zipData = component.get("v.objDCampaign.Zip_Codes__c");
        //var selectedSkills = $('[id$=picklist]').select2("val");
        if(zipData!=undefined)
        	zipData = zipData.replace(/ /g, '');
        else
            zipData = null;
        helper.updateZipcodeCH(component,recId,zipData);
        //$("#picklist").val(["One"]).select2();
    }
})