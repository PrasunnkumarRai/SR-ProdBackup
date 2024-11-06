({
	scriptsLoaded : function(component, event, helper) {
		// active/call select2 plugin function after load jQuery and select2 plugin successfully    
        var recId = component.get("v.recordId");
        helper.fetchPickListVal(component, recId);
    },
    
    doInit: function(component, event, helper) {
       /*On the component load call the fetchPickListVal helper method
         pass the Picklist[multi-select] API name in parameter  
       */
        //var recId = component.get("v.recordId");
        //helper.fetchPickListVal(component, recId);
    },
    
    updateData : function(component, event, helper){
        var lockRecord = component.get("v.lockRecord");
        if( lockRecord ){
            return false;
        }
        var recId = component.get("v.recordId");
        var selectedSkills = '';
        if(document.getElementById("picklist")!=null)
        	selectedSkills = $('#picklist').select2("val");
        selectedSkills = selectedSkills != null ? selectedSkills : '';
        //console.log('----> selectedSkills: '+selectedSkills);
        if( selectedSkills.length>1 && selectedSkills.indexOf("None") >= 0){
            alert("Please select only one Audience Interests from Available Audience Interests when you select \"None\"");
            return;
        }
        
        var isAI = false;
        if(selectedSkills.length==1 && selectedSkills.indexOf("None") >= 0){
            isAI = confirm("You have selected \"None\" for Audience Interests,  this will replace all selected Audience Interests. Are you sure you want to do this?");
            if(isAI){
                selectedSkills = [];
                selectedSkills.push("None");
            }
            else{
                return;
            }
        }
        
        var selectedDigAs = $('#DigApicklist').select2("val");
        selectedDigAs = selectedDigAs != null ? selectedDigAs : '';
        //console.log('----> selectedDigAs: '+selectedDigAs);
        if(selectedDigAs.length>1 && selectedDigAs.indexOf("None") >= 0){
            alert("Please select only one Audience Interests from Available DigA when you select \"None\"");
            return;
        }
        
        if(selectedDigAs.length==1 && selectedDigAs.indexOf("None") >= 0){
            var flag = confirm("You have selected \"None\" for Audience Interests,  this will replace all selected DigA values. Are you sure you want to do this?");
            if(flag){
                selectedDigAs = [];
                selectedDigAs.push("None");
            }
            else{
                return;
            }
        }
        
        if(selectedSkills!=null && selectedSkills!=undefined){
        	selectedSkills = unescape(selectedSkills.toString());
        }else
            selectedSkills = "";
        
        if(selectedDigAs!=null && selectedDigAs!=undefined){
        	selectedDigAs = unescape(selectedDigAs.toString());
        }else
            selectedDigAs = "";
        
        helper.updateDataCH(component,recId,selectedSkills, selectedDigAs);
    }
})