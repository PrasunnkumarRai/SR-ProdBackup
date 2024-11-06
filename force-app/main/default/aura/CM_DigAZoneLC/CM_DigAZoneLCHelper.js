({
    //Loading the DigA_Zone__c
	fetchPickListVal: function(component, recId) {
        //alert("Calling..");
        var action = component.get("c.PrepareData");
        action.setParams({
             dcRecordId: recId
        });
        var opts = [];
        action.setCallback(this, function(response) {
            if (response.getState() === "SUCCESS") {
                var objWrap = response.getReturnValue();
                //alert(objWrap);
                //component.set("v.picklistDigAZoneOptsList", objWrap.lstDigAZone);
                component.set("v.Zipcode", objWrap.strZipcode);
                component.set("v.lockRecord", objWrap.lockRecord );
                component.set( "v.DigAZoneTooltip", objWrap.strDigAZoneHelpText);
                var lstDigAOpt = [];
                var selectedDigA = objWrap.strZipcode;
                if(selectedDigA!=null && selectedDigA!='' && selectedDigA!=undefined)
                    lstDigAOpt = selectedDigA.split('; ');
                this.prepareDynamicPicklist("#picklist4",objWrap.lstDigAZone,lstDigAOpt);
            }
        });
        $A.enqueueAction(action);
    },
    
    //Updating Userinput into SFDatabase
    updateZipcodeCH : function(component, recId, zipData){
        var lstDZone = decodeURI ($("#picklist4").val()).replace(/,/gi, "; ");
        var lstDZoneArr = lstDZone.split("; ");
        if(lstDZoneArr.length>1 && lstDZoneArr.indexOf("None") >= 0){
            alert("Please select only one DigA Zone from Available Diga Zones when you select None");
            return;
        }
        var isClearDAZ = false;
        if(lstDZoneArr.length==1 && lstDZoneArr.indexOf("None") >= 0){
            isClearDAZ = confirm("You have selected \"None\" for DigA Zone,  this will replace all selected Diga Zones. Are you sure you want to do this?");
            if(isClearDAZ){
                lstDZone = "None";
            }
            else{
                return;
            }
        }
        var action = component.get("c.insertZipCodes");
        action.setParams({
            dcRecordId: recId,
            lstDZone: lstDZone
        });
        action.setCallback(this, function(response) {
            if (response.getState() === "SUCCESS") {
                var resultData = response.getReturnValue();
                //console.log('-----> Response: '+JSON.stringify( response ) );
                //alert(resultData.strMsg);
                if( resultData.strMsg.indexOf('Error') == -1 ){
                    this.showToast("success", "Success!", resultData.strMsg);
	                component.set("v.Zipcode", resultData.strZipcode);
                }else{
                    this.showToast("error", "Error!", resultData.strMsg);
                }
            }else{
                this.showToast("error", "Error!", JSON.stringify(response.error));
            }
        });
        $A.enqueueAction(action);
    },
    
    //Prepares Picklist data for reusable purpose
    prepareDynamicPicklist : function(selectId, allValues,lstOpt){
        var options='';
        for(var indx in allValues){
            if(indx && allValues.hasOwnProperty(indx) && allValues[indx]!=null){
                if(lstOpt.indexOf(allValues[indx]) >= 0)
                    options+='<option selected = true value='+escape(allValues[indx])+'>'+allValues[indx]+'</option>';   
                else
                    options+='<option value='+escape(allValues[indx])+'>'+allValues[indx]+'</option>';
            }
        }
        //sets dynamic values for details emp function
        $(selectId).html(options);
        //$("#picklist").selectpicker('refresh');
    },
    
    //Displaying message after DML
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