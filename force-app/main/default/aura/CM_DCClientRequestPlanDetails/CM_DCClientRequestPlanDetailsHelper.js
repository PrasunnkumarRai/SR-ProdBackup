({
    
    formatDate: function(date) {
        var d = new Date(date),
            month = '' + (d.getMonth() + 1),
            day = '' + d.getDate(),
            year = d.getFullYear();
    
        if (month.length < 2) 
            month = '0' + month;
        if (day.length < 2) 
            day = '0' + day;
    	console.log('');
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
        this.calculateTotalImpressions(component, event, helper);
    },
    
    calculateTotalImpressions :function(component, event, helper) {
        var RowItemList = component.get("v.datesArray");
        var index = event.getSource().get("v.requiredIndicatorClass");
        var RowItemList = component.get("v.datesArray");
        var profilename = component.get("v.resultWrap").profileName;
        if(RowItemList[index].CPM==0 && RowItemList[index].Cost==0){
            //alert(profilename);
            if(profilename == 'Master - Yield and Inventory' || 
               profilename == 'Master - Enterprise Digital' || 
               profilename == 'Master - Optimization Manager' || 
               profilename == 'System Administrator'){
            	RowItemList[index].isImpressionsDisable = false;
            }
        }else if(RowItemList[index].CPM && RowItemList[index].Cost){
            var CPM = RowItemList[index].CPM;
            var cost = RowItemList[index].Cost;
            var num = (cost/CPM)*1000;
			var n = parseInt(num);
            RowItemList[index].Impressions = n;
            RowItemList[index].isImpressionsDisable = true;
        }else{
            RowItemList[index].Impressions = null;
            RowItemList[index].isImpressionsDisable = true;
        }
        component.set("v.datesArray", RowItemList);
        this.calculateTotals(component, event, helper);
    },
    
    calculateTotals :function(component, event, helper) {
        var totImpressions = 0;
        var totCPM = 0.00;
        var totCOST = 0.00;
        var RowItemList = component.get("v.datesArray");
        for(var index in RowItemList){
            /*if(RowItemList[index].CPM){
                totCPM+= RowItemList[index].CPM;
            }*/
            if(RowItemList[index].Impressions!="" && RowItemList[index].Impressions!=undefined && RowItemList[index].Impressions){
                totImpressions+= parseInt(RowItemList[index].Impressions);
            }
            if(RowItemList[index].Cost){
                totCOST+= RowItemList[index].Cost;
            }
        }
        //totCOST = totCOST.toFixed(2);
        if(totImpressions==0 || totCOST==0)
            totCPM = 0.00;
        else
        	totCPM = (totCOST/totImpressions)*1000;
        //alert( Math.floor(totCPM * 100) / 100 );
        totCPM = totCPM.toFixed(2);
        var resultrap = component.get("v.resultWrap");
        resultrap.totImpressions = totImpressions;
        resultrap.totCPM = totCPM;
        resultrap.totCOST = totCOST;
        component.set("v.resultWrap", resultrap);
        this.checkTotalcostWithDesiredBudget(component, event, helper);
    },
    
    checkTotalcostWithDesiredBudget :function(component, event, helper) {
        var resultrap = component.get("v.resultWrap");
        var totCost   = resultrap.totCOST;
        var desiredBudget = resultrap.desiredBudget;
        component.set("v.showDBWarningMsg", false);
        if(totCost!=undefined && desiredBudget!=null && desiredBudget!=undefined){
            var colorcode = '';
            if(totCost > desiredBudget){
                colorcode = 'background-color:red;';
                component.set("v.DesiredBudgetWarningMsg", "The Total Cost (Gross) exceeds the Desired Budget.");
                component.set("v.showDBWarningMsg", true);
            }else if(totCost < desiredBudget){
                colorcode = 'background-color:yellow;';
                component.set("v.DesiredBudgetWarningMsg", "The Total Cost (Gross) is less than the Desired Budget.");
                component.set("v.showDBWarningMsg", true);
            }else{
                component.set("v.showDBWarningMsg", false);
            }
            component.set("v.totalcostWarningMsg", colorcode);
        }
    },
    
    //Fetching all the PlanDetails in the PageLoad
	fetchPlanDetails : function(component, event, helper, recId) {
        var action = component.get("c.PrepareData");
        action.setParams({
             dcRecordId: recId
        });
        action.setCallback(this, function(response) {
            if (response.getState() === "SUCCESS") {
                var objWrap = response.getReturnValue();
                component.set("v.resultWrap", objWrap);
                var isCPM_CostLock = (objWrap.profileName == 'Master - Digital Operations');
                component.set("v.isCPMCostLock", isCPM_CostLock);
                this.checkTotalcostWithDesiredBudget(component, event, helper);
                //console.log(objWrap.objDCampaign);
                var RowItemList = component.get("v.datesArray");
                RowItemList = [];
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
                    var isDisable = (objWrapRec.CPM == 0 && objWrapRec.Cost==0)? false : true;
                    RowItemList.push({"startDate": maxcampaignstartdate,"endDate": maxcampaignenddate,
                                      "lstIS":lstInvSrc,"selIS": objWrapRec.selIS,
                                      "lstDCType":lstType,"selType": objWrapRec.selType,
                                      "lstAudience":lstAudience,"selAud":objWrapRec.selAud, 
                                      "lstGeoTargetType":lstGeoTargetType,"selGeoType":objWrapRec.selGeoType,
                                      "Notes": objWrapRec.Notes,"Impressions":objWrapRec.Impressions,
                                      "CPM":objWrapRec.CPM,"Cost":objWrapRec.Cost,
                                      "Industry":objWrapRec.Industry,"LineItemId":objWrapRec.LineItemId,
                                      "RecordId":objWrapRec.RecordId,"objIS":objWrapRec.objIS,
                                      "isEditStDate":objWrapRec.isEditStDate,
                                      "isImpressionsDisable":isDisable
                                     });
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
        lstInvSrc.push("Freewheel-O&O/Affiliate/Direct");
        lstInvSrc.push("Freewheel-FF OTT");
        lstInvSrc.push("Freewheel-FF TVE");
        lstInvSrc.push("TTD-CTV");
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
        var resultrap = component.get("v.resultWrap");
        var totImp    = resultrap.totImpressions;
        var totCPM    = resultrap.totCPM;
        var totcost1   = resultrap.totCOST;
        var action    = component.get("c.UpdateData");
        action.setParams({
            dcRecordId: recId,
            wrapInvSrcData : JSON.stringify(component.get("v.datesArray")),
            totImpressions : totImp,
            totCPM : totCPM,
            totCOST : totcost1
        });
        action.setCallback(this, function(response) {
            if (response.getState() === "SUCCESS") {
                var objWrap = response.getReturnValue();
                //alert(objWrap.strMsg);
                component.set("v.resultWrap", objWrap);
                component.set("v.isDMLError", false);
                this.showToast("success", "Success!", "Details have been added successfully.");
            }else if (response.getState() === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        component.set("v.isDMLError", true);
                        this.showToast("error", "Error!", errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
        $A.enqueueAction(action);
	},
    
    //Message to display on Lightning Component after DML
    showToast : function( type, title, msg ){
        var durationval = (type=='error')? 10000 : 5000;
    	var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
    		"type": type,
            "title": title,
            "message": msg,
            "duration": durationval
        });
        toastEvent.fire();
    }
    
})