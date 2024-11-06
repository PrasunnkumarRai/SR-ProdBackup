({
	scriptsLoaded : function(component, event, helper) {
        var recId = component.get("v.recordId");
		helper.fetchFlightDate(component, recId);
    },
    
    Save: function(component, event, helper) {
        var recId = component.get("v.recordId");
        helper.saveFlightDate(component, recId);
    },
    
    addNewRow: function(component, event, helper) {
        helper.createObjectData(component, event, helper);
    },
    
    removeRow: function(component, event, helper) {
        //var index = event.getParam("indexVar");
        var objWrap = component.get("v.resultWrap");
        var maxcampaignstartdate = (objWrap.objDCampaign.Campaign_Start_Date__c!=undefined)? objWrap.objDCampaign.Campaign_End_Date__c : new Date();
        var maxcampaignenddate = (objWrap.objDCampaign.Campaign_End_Date__c!=undefined)? objWrap.objDCampaign.Campaign_End_Date__c : new Date();
        
        var index = event.currentTarget.id;
        var RowItemList = component.get("v.datesArray");
        RowItemList.splice(index, 1);
        if(RowItemList.length > 0){
            /*if(RowItemList.length == 1){
                RowItemList[0].maxst = maxcampaignstartdate;
                RowItemList[0].maxend = maxcampaignenddate;
            }else*/{
                RowItemList[RowItemList.length-1].maxst = RowItemList[RowItemList.length-1].startDate;
                RowItemList[RowItemList.length-1].maxend = maxcampaignenddate;
            }
            for(var i=0;i<RowItemList.length;i++){
                if(i == (RowItemList.length-1))
                    RowItemList[i].disable = false;
                else
                    RowItemList[i].disable = true;
            }
        }
        component.set("v.datesArray", RowItemList);
        helper.checkForErrorMessage(component, event, helper);
    },
    
    checkForErrorMsg: function(component, event, helper) {
        /*var index = event.currentTarget.step;
        alert(index);
        var stdt = RowItemList[index].startDate;
        var enddt = RowItemList[index].endDate;
        if(stdt>enddt){
            component.set("v.showErrorMsg1", true);
        }else{
            component.set("v.showErrorMsg1", false);
        }*/
    	helper.checkForErrorMessage(component, event, helper);
    }
    
})