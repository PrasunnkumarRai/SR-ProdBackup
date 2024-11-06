({
    //prepares data in page load
    fetchPickListVal: function(component, recId) {
        //console.log('----> inside load .');
        var action = component.get("c.PrepareData");
        //action.setStorable();
        action.setParams({
             dcRecordId: recId
        });
        action.setCallback(this, function(response) {
            if (response.getState() === "SUCCESS") {
                //alert(resultData.isDisplay);
               // console.log('----> resultData.isDisplay : '+resultData.isDisplay );
                var resultData = response.getReturnValue();
             //   console.log(resultData);
                component.set("v.lockRecord", resultData.lockRecord );
                component.set("v.isDisplayStd", resultData.isDisplay );
              //  console.log('----> result : '+JSON.stringify( resultData ) );
                var allValues = resultData.lstOptions;
                var selData = resultData.strSelOption;
                var selectedDigA = resultData.selectedDigA;
                var allDigAs = resultData.lstDigAAudianceInterests;
                
                component.set("v.selectedAudience", selData);
                component.set("v.selectedDigA", selectedDigA );
                component.set("v.strLblAI", resultData.strLblAudInt);
                component.set("v.strLblDigAAI", resultData.strLblDigAAudInt);
                //component.set("v.SelOpt", selData);
                component.set("v.lockRecord", resultData.lockRecord);
                
                var lstOpt = [];
                if(selData!=null && selData!='' && selData!=undefined)
                    lstOpt = selData.split(';');
                this.prepareDynamicPicklist("#picklist", allValues,lstOpt);
                
                var lstDigAOpt = [];
                if(selectedDigA!=null && selectedDigA!='' && selectedDigA!=undefined)
                    lstDigAOpt = selectedDigA.split(';');
                this.prepareDynamicPicklist("#DigApicklist",allDigAs,lstDigAOpt);
                
                $(".select2Class").select2({
                   placeholder: "Select Multiple values"
                });
            }
        });
        $A.enqueueAction(action);
    },
    
    //Updates AUDIENCE INTERESTS INFORMATION on Digital Campaign object
    updateDataCH : function(component, recId, selOpts, selectedDigAs){
        var action = component.get("c.updateAudData");
        var opts = [];
        action.setParams({
             dcRecordId: recId,
             strSelOpts: selOpts,
             selectedDigA : selectedDigAs
        });
        action.setCallback(this, function(response) {
            if (response.getState() === "SUCCESS") {
                var resultData = response.getReturnValue();
                var strStatus = resultData.strMsg;
                if(strStatus=="Success"){
                    //alert("The Audience Interests have been added.");
                    this.showToast( "success", "Success!", "The Audience Interests have been added.");
                    
                    //var allValues = resultData.lstOptions;
                    var selData = resultData.strSelOption;
                    var selectedDigA = resultData.selectedDigA;
                    var allDigAs = resultData.lstDigAAudianceInterests;
                    
                    component.set("v.selectedAudience", selData);
                    component.set("v.selectedDigA", selectedDigA );
                    //component.set("v.SelOpt", selData);
                    
                    /*var lstOpt = [];
                        if(selData!=null && selData!='' && selData!=undefined)
                            lstOpt = selData.split(';');
                        this.prepareDynamicPicklist("#picklist", allValues,lstOpt);
                        
                        var lstDigAOpt = [];
                        if(selectedDigA!=null && selectedDigA!='' && selectedDigA!=undefined)
                            lstDigAOpt = selectedDigA.split(';');
                        this.prepareDynamicPicklist("#DigApicklist",allDigAs,lstDigAOpt);*/
                    
                }else{
                    this.showToast( "error", "Error!", resultData.strMsg);
                }
            }else{
                //alert("Error : "+strStatus);
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
    
    //display the message after DML
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