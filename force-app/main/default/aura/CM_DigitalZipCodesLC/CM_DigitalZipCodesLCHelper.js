({
    //Fetch Picklist Data in the Pageload
	fetchPickListVal: function(component, recId) {
        var action = component.get("c.PrepareData");
        action.setParams({
             dcRecordId: recId
        });
        var opts = [];
        action.setCallback(this, function(response) {
            if (response.getState() === "SUCCESS") {
                var objWrap = response.getReturnValue();
                component.set("v.objDCampaign", objWrap.objDCampaign);
                var showDMA = objWrap.showDMA;
                var showSRZ = objWrap.showSRZ;
                //var showCD = objWrap.showCD;
                component.set("v.showDMA", objWrap.showDMA);
                component.set("v.showSRZ", objWrap.showSRZ);
             //   component.set("v.showCD", objWrap.showCD);
                component.set("v.strLblDM", objWrap.strLblDMA);
                component.set("v.strLblSRZ", objWrap.strLblSRZone);
              //  component.set("v.strLblCD", objWrap.strLblCongDist);
                //console.log('----> lockRecord 1: '+ objWrap.lockRecord );
                component.set("v.lockRecord", objWrap.lockRecord);
                //console.log('----> objWrap.lstDMA : '+JSON.stringify( objWrap.lstDMA ) );
                // Create DMA Picklist
                //console.log('----> showDMA 1: '+ showDMA );
                if( showDMA ){
                    var DMANames = objWrap.objDCampaign.DMAs__c;
                    var lstOpt = [];
                    if(DMANames!=null && DMANames!='' && DMANames!=undefined)
                        lstOpt = DMANames.split('; ');
                    //console.log('----> showDMA : '+JSON.stringify( document.getElementById('picklist2') ) );
                    this.prepareDynamicPicklist("#picklist2", objWrap.lstDMA,lstOpt);
                    //console.log('----> showDMA 2: ');
                }
                // Create SR Zone Picklist
                if( showSRZ ){
                    var SRNames = objWrap.objDCampaign.Spectrum_Reach_Zones__c;
                    lstOpt = [];
                    if(SRNames!=null && SRNames!='' && SRNames!=undefined)
                        lstOpt = SRNames.split('; ');
                    this.prepareDynamicPicklist("#picklist3", objWrap.lstZone,lstOpt);
                }
                
                // Create CR Zone Picklist
              /*  if( showCD ){
                    var CRNames = objWrap.objDCampaign.Congressional_Districts__c;
                    lstOpt = [];
                    if(CRNames!=null && CRNames!='' && CRNames!=undefined)
                        lstOpt = CRNames.split('; ');
                    this.prepareDynamicPicklist("#picklist1", objWrap.lstCongr,lstOpt);
                }*/
            }
        });
        $A.enqueueAction(action);
    },
    
    //Updating Geographies data
    updateZipcodeCH : function(component, recId, zipData){
        var lstCngJS = decodeURI ($("#picklist1").val()).replace(/,/gi, "; ");
        var lstDMAJS = decodeURI ($("#picklist2").val()).replace(/,/gi, "; ");
        var lstZoneJS = decodeURI ($("#picklist3").val()).replace(/,/gi, "; ");
        var action = component.get("c.insertZipCodes");
        
        var showDMA = component.get("v.showDMA");            
        var lstDMA = lstDMAJS.split("; ");
        if( showDMA && lstDMA.length>1 && lstDMA.indexOf("None") >= 0){
            alert("Please select only one DMA option when you select None");
            return;
        }
        var lstZone = lstZoneJS.split("; ");
        if(lstZone.length>1 && lstZone.indexOf("None") >= 0){
            alert("Please select only one Spectrum Reach Zone option when you select None");
            return;
        }
        var lstCng = lstCngJS.split("; ");
        if(lstCng.length>1 && lstCng.indexOf("None") >= 0){
            alert("Please select only one Congressional District option when you select None");
            return;
        }
        
        var isClearDMA = false;
        if( showDMA && lstDMA.length==1 && lstDMA.indexOf("None") >= 0){
            isClearDMA = confirm("Do you want to remove existing DMA data?");
            if(isClearDMA)
                lstDMAJS = "None";
            else
                return;
        }
        var isClearZone = false;
        if(lstZone.length==1 && lstZone.indexOf("None") >= 0){
            isClearZone = confirm("Do you want to remove existing Spectrum Reach Zone data?");
            if(isClearZone)
                lstZoneJS = "None";
            else
                return;
        }
        var isClearCng = false;
        if(lstCng.length==1 && lstCng.indexOf("None") >= 0){
            isClearCng = confirm("Do you want to remove existing Congressional District data?");
            if(isClearCng)
                lstCngJS = "None";
            else
                return;
        }
        lstDMAJS = showDMA ? lstDMAJS : '';
        action.setParams({
            dcRecordId: recId,
            lstCng: lstCngJS,
            lstDMA: lstDMAJS,
            lstZone: lstZoneJS,
            strZipData: zipData 
        });
        action.setCallback(this, function(response) {
            if (response.getState() === "SUCCESS") {
                var resultData = response.getReturnValue();
                //console.log('----> resultData: '+JSON.stringify( resultData ) );
                if( resultData.strMsg.indexOf('Error') == -1 ){
	                component.set("v.objDCampaign", resultData.objDCampaign);
                    this.showToast( "success", "Success!", resultData.strMsg );
                }else{
                    this.showToast( "error", "Error!", resultData.strMsg );
                }
                //alert(resultData.strMsg);
            }
        });
        $A.enqueueAction(action);
    },
    
    //Prepares Picklist data for reusable purpose
    prepareDynamicPicklist : function(picklistId, allValues,lstOpt){
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
        $(picklistId).html(options);
    },
    
    //display message after DML
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