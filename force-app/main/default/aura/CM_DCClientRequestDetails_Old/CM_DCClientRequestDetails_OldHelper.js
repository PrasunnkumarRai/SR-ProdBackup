({
    //Adding one more row with Plan Detail Lineitem 
    createObjectData: function(component, event, helper) {
        
        var RowItemList = component.get("v.datesArray");
        //alert(RowItemList.length);
        if(RowItemList.length == 4){
            component.set("v.ErrorMsg", "You cannot select more than 4 rows.");
            component.set("v.showErrorMsg2", true);
            return;
        }
        var lstInvSrc = this.getInventoryResource();
        var lstType = this.getSFDCDCType();
        var lstAudience = this.getAudience();
        var lstGeoTargetType = this.getGeoTargetType();
        var inventorysource="";
        var selectivetype="";
        var disable = false;
        if(RowItemList.length == 0){
            inventorysource = "Freewheel – O&O/Affiliate/Direct";
            selectivetype = "Ads Everywhere";
            disable = false;
        }
        var objWrap = component.get("v.resultWrap");
        console.log(objWrap);
        var maxcampaignstartdate = (objWrap.objDCampaign.Campaign_Start_Date__c!=undefined)? objWrap.objDCampaign.Campaign_Start_Date__c : new Date();
        var maxcampaignenddate = (objWrap.objDCampaign.Campaign_End_Date__c!=undefined)? objWrap.objDCampaign.Campaign_End_Date__c : new Date();
        RowItemList.push({"startDate": maxcampaignstartdate,"endDate": maxcampaignenddate,
                          "lstIS":lstInvSrc,"selIS": inventorysource,
                          "lstDCType":lstType,"selType": selectivetype,
                          "lstAudience":lstAudience,"selAud":"", 
                          "lstGeoTargetType":lstGeoTargetType,"selGeoType":"",
                          "Notes": "","Impressions":"",
                          "CPM":"","Cost":"","disable":disable});  
        component.set("v.datesArray", RowItemList);
    },
    
    formatDate: function(date) {
        var d = new Date(date),
            month = '' + (d.getMonth() + 1),
            day = '' + d.getDate(),
            year = d.getFullYear();
    
        if (month.length < 2) 
            month = '0' + month;
        if (day.length < 2) 
            day = '0' + day;
    
        return [year, month, day].join('-');
    },
    
    onlyNumber :function(component, event, helper) {
        var RowItemList = component.get("v.datesArray");
        var index = event.getSource().get("v.requiredIndicatorClass");
        var RowItemList = component.get("v.datesArray");
        if(RowItemList[index].Impressions){
            var impressions = RowItemList[index].Impressions+"";
            impressions = impressions.replace(/\D/g, '');
            RowItemList[index].Impressions = impressions;
            component.set("v.datesArray", RowItemList);
        }
    },
    
    //Fetching all the PlanDetails in the PageLoad
	fetchPlanDetails : function(component, recId) {
        //alert(recId);
        var RowItemList = component.get("v.datesArray");
        RowItemList = [];
        component.set("v.datesArray",RowItemList);
        var action = component.get("c.PrepareData");
        action.setParams({
             dcRecordId: recId
        });
        action.setCallback(this, function(response) {
            if (response.getState() === "SUCCESS") {
                var objWrap = response.getReturnValue();
                component.set("v.resultWrap", objWrap);
                console.log(objWrap.objDCampaign);
                var RowItemList = component.get("v.datesArray");
                
                var lstInvSrc = this.getInventoryResource();
                var lstType = this.getSFDCDCType();
                var lstAudience = this.getAudience();
                var lstGeoTargetType = this.getGeoTargetType();
                
                var disable = false;
                for(var obj in objWrap.lstPlanRecords){
                    var objWrapRec = objWrap.lstPlanRecords[obj];
                    console.log(objWrapRec);
                    var maxcampaignstartdate = (objWrap.objDCampaign.Campaign_Start_Date__c!=undefined)? objWrap.objDCampaign.Campaign_Start_Date__c : new Date();
                    var maxcampaignenddate = (objWrap.objDCampaign.Campaign_End_Date__c!=undefined)? objWrap.objDCampaign.Campaign_End_Date__c : new Date();
                    /*if(RowItemList.length == 1){
                    	disable = true;
                    }*/
                    RowItemList.push({"startDate": maxcampaignstartdate,"endDate": maxcampaignenddate,
                                      "lstIS":lstInvSrc,"selIS": objWrapRec.selIS,
                                      "lstDCType":lstType,"selType": objWrapRec.selType,
                                      "lstAudience":lstAudience,"selAud":objWrapRec.selAud, 
                                      "lstGeoTargetType":lstGeoTargetType,"selGeoType":objWrapRec.selGeoType,
                                      "Notes": objWrapRec.Notes,"Impressions":objWrapRec.Impressions,
                                      "CPM":objWrapRec.CPM,"Cost":objWrapRec.Cost,
                                      "isPrimary":objWrapRec.isPrimary,"disable":disable});
                    }
            	}
            	component.set("v.datesArray", RowItemList);
        });
        //Tooltip for PlanDetails
        var tooltip = $A.get("$Label.c.CM_ClientRequestPlanDetails");
        var res = tooltip.replace(/\n/g, "<br/>");
        component.set("v.planDetailFormTooltip", res);
        $A.enqueueAction(action);
	},
    
    checkValidations : function(component, event, helper) {
        var lstInvSrc = this.getInventoryResource();
        var RowItemList = component.get("v.datesArray");
        //alert((RowItemList[1].selIS == ""));
        for(var i=0;i<lstInvSrc.length;i++){
            var count = 0;
            for(var riIndex in RowItemList){
                if(RowItemList[riIndex].selIS == undefined || RowItemList[riIndex].selIS == ""){
                    component.set("v.ErrorMsg", "INVENTORY SOURCE should be selected.");
                    component.set("v.showErrorMsg1", true);
                    return;
                }
                if(RowItemList[riIndex].selIS == lstInvSrc[i]){
                	count++;
                    if(count > 1){
                        component.set("v.showErrorMsg", true);
                        return;
                    }
                }
            }
        }
        component.set("v.ErrorMsg", "");
        component.set("v.showErrorMsg", false);
        component.set("v.showErrorMsg1", false);
        component.set("v.showErrorMsg2", false);
    },
    
    getInventoryResource : function(component){
        var lstInvSrc = [];
        lstInvSrc.push("Freewheel – O&O/Affiliate/Direct");
        lstInvSrc.push("Freewheel - FF OTT");
        lstInvSrc.push("Freewheel – FF TVE");
        lstInvSrc.push("TTD - CTV");
        return lstInvSrc;
    },
    
    getSFDCDCType : function(component){
        var lstType = [];
        lstType.push("Ads Everywhere");
        lstType.push("Pre Roll Custom");
        return lstType;
	},
    
    getAudience : function(component){
        var lstAudience = [];
        lstAudience.push("Streaming TV");
        lstAudience.push("Custom Nets");
        lstAudience.push("Audience Segments");
        return lstAudience;
    },
    
    getGeoTargetType : function(component){
        var lstGeoTargetType = [];
        lstGeoTargetType.push("State");
        lstGeoTargetType.push("DMA");
        lstGeoTargetType.push("Zone");
        lstGeoTargetType.push("Zip");
        return lstGeoTargetType;
    },
    
    //Upserting PlanDetails information
    savePlanDetails : function(component, event, helper, recId) {
        this.checkValidations(component, event, helper);
        var isError1 = component.get("v.showErrorMsg");
        var isError2 = component.get("v.showErrorMsg1");
        if(isError1 || isError2){
            this.showToast("error", "Error!", "Error on Client Request Form Plan Details.");
            return false;
        }
        var updatedData = '';
        var RowItemList = component.get("v.datesArray");
        var notes = '';
        var primaryInventorySource = '';
        var isOTTPrimary = false;
        for(var obj in RowItemList){
            var invsrc = RowItemList[obj].selIS;
            var selType = RowItemList[obj].selType;
            var selAud = RowItemList[obj].selAud;
            var selGeoType = RowItemList[obj].selGeoType;
            var impressions = RowItemList[obj].Impressions;
            if(!impressions)
                impressions = "";
            var CPM = RowItemList[obj].CPM;
            if(!CPM)
                CPM = "";
            var cost = RowItemList[obj].Cost;
            if(!cost)
                cost = "";
            var isPrimary = RowItemList[obj].isPrimary;
            if(!isPrimary)
                isPrimary = false;
            if(isPrimary)
                primaryInventorySource = invsrc;
            if(invsrc=="Freewheel - FF OTT")
                isOTTPrimary = isPrimary;
            var notesdata = RowItemList[obj].Notes;
            if(notesdata!=undefined)
                notesdata = notesdata.split(";").join(",");
            notes+= invsrc+':'+notesdata+';';
            updatedData+=invsrc+':'+selType+':'+selAud+':'+selGeoType+':'+impressions+':'+CPM+':'+cost+':'+isPrimary+';';
        }
        //alert(updatedData);
        //alert(notes);
        //alert(primaryInventorySource);
        //console.log(updatedData);
        var action = component.get("c.UpdateData");
        action.setParams({
            dcRecordId: recId,
            strData: updatedData,
            notes: notes,
            primaryInventorySource : primaryInventorySource,
            isOTTPrimaryVal: isOTTPrimary
        });
        action.setCallback(this, function(response) {
            if (response.getState() === "SUCCESS") {
                var objWrap = response.getReturnValue();
                component.set("v.resultWrap", objWrap);
                if( objWrap.isVRError == false ){
                    this.showToast("success", "Success!", objWrap.strMsg);
                    //publishing Is_Freewheel_FF_OTT_Primary__c information to the networkLWC
                    var isOTT = component.get("v.resultWrap.dcRecord.Is_Freewheel_FF_OTT_Primary__c");
                    this.publishMC(component, event, helper,isOTT);
                }else{
                    this.showToast("error", "Error!", objWrap.strMsg);
                }
                
            }else{
                this.showToast("error", "Error!", JSON.stringify(response.error));
            }
        });
        $A.enqueueAction(action);
        //$A.get("e.force:refreshView").fire();
	},
    
    publishMC: function(cmp, event, helper, isOTTPrimaryVal) {
        var message = {
            isOTTPrimary: isOTTPrimaryVal
        };
        cmp.find("dcMessageChannel").publish(message);
    },
    
    //Message to display on Lightning Component after DML
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