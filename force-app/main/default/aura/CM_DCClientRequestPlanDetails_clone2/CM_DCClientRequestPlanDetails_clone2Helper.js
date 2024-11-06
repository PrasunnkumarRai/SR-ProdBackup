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
        //var yieldExVal = component.get("v.yieldEx");
        console.log("component.get: ",component.get("v.yieldEx"));
        component.set("v.datesArray", RowItemList);
        this.calculateTotals(component, event, helper);
        console.log("component.get:--",component.get("v.yieldEx"));
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
    
    //Loading the DigA_Zone__c
	fetchPickListVal: function(component) {
        //console.log("fetchPickListVal ")
        var action = component.get("c.getExclusionsPickListValues");
       action.setCallback(this, function(response) {
            if (response.getState() === "SUCCESS") {
                var result = response.getReturnValue();
                var plValues = [];
                for (var i = 0; i < result.length; i++) {
                    plValues.push({
                        value: result[i]
                    });
                }
                console.log('plValues',plValues)
                component.set("v.lstExlPicklist", plValues);
            }
        });
        $A.enqueueAction(action);
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
                console.log("objWrap===@@@@@@@",objWrap);

                component.set("v.resultWrap", objWrap);
                component.set("v.yisfVisible",objWrap.yisfVisible);
               component.set("v.yieldEx",objWrap.yieldExclude);
                var isCPM_CostLock = (objWrap.profileName == 'Master - Digital Operations' || objWrap.profileName == 'Master - Digital Traffic');
                component.set("v.isCPMCostLock", isCPM_CostLock);
                this.checkTotalcostWithDesiredBudget(component, event, helper);        

                var RowItemList = component.get("v.datesArray");
                RowItemList = [];
                var lstInvSrc = this.getInventoryResource();
                console.log("lstInvSrc@@@"+lstInvSrc);
                var lstType = this.getSFDCDCType();
                var lstAudience = this.getAudience();
                var lstGeoTargetType = this.getGeoTargetType();
                var lstExclision = component.get("v.lstExlPicklist");
                // var Exclusions = component.get("v.Exclusions");
                
                var disable = false;
                for(var obj in objWrap.lstPlanRecords){
                    var objWrapRec = objWrap.lstPlanRecords[obj];
                    console.log("objWrapRec====@@@",objWrapRec);
                    console.log(objWrapRec.objIS.Exclusions__c);
                    if(objWrapRec.objIS.Exclusions__c){
                        var exVal = objWrapRec.objIS.Exclusions__c;
                        console.log("exVal", exVal);
                        var exValArr = exVal.split(';');
                        console.log("exValArr", exValArr);
						component.set("v.exValArr", exValArr);
                    }
                    var maxcampaignstartdate = (objWrap.objDCampaign.Campaign_Start_Date__c!=undefined)? objWrap.objDCampaign.Campaign_Start_Date__c : new Date();
                    var maxcampaignenddate = (objWrap.objDCampaign.Campaign_End_Date__c!=undefined)? objWrap.objDCampaign.Campaign_End_Date__c : new Date();
                    var isDisable = (objWrapRec.CPM == 0 && objWrapRec.Cost==0)? false : true;
                    
                     
                    if(objWrap.objDCampaign.Full_Avail_Campaign__c && objWrapRec.objIS.Inventory_Resource_Type__c == "Freewheel-SA" ){
                        objWrapRec.Impressions = 1;
						objWrapRec.CPM = .00;
                        objWrapRec.Cost = .00;
                        isDisable = true;
                    }
                   
                    
                    
                    var isCPM_GrossLockedJS = false;
                   /* if(objWrapRec.isCPMGrrossLocked || isCPM_CostLock || (objWrapRec.objIS.Inventory_Resource_Type__c == "Freewheel-SA" && 
                       (objWrap.objDCampaign.X1x1_Pixel__c == true || objWrap.objDCampaign.VAST_Tag__c == 'Yes' ||objWrap.objDCampaign.Product_Type__c == 'Default Ads Everywhere Campaign') ) 
                       || objWrap.objDCampaign.Full_Avail_Campaign__c == true || 
                       (objWrapRec.objIS.Inventory_Resource_Type__c == "TTD-CTV" && (objWrap.objDCampaign.Product_Type__c == 'DMA Addressable' || objWrap.objDCampaign.Product_Type__c == 'National Addressable' )) 
                       || (objWrapRec.objIS.Inventory_Resource_Type__c == "Simpli.fi-CTV") || (objWrap.objDCampaign.RecordType.DeveloperName == "SSP_Programmatic" && objWrapRec.objIS.Inventory_Resource_Type__c != "Freewheel-O&O/Affiliate/Direct"))*/ //SRSF-4062(SSP Programmatic)
                    
                    //SRSF-3917 Start

                     let selectedNetwork;
                    let disableForCimplifi
                    if (objWrap.objDCampaign.AdsE_Genre_s__c && objWrap.objDCampaign.AdsE_Genre_s__c != null && objWrap.objDCampaign.AdsE_Genre_s__c != undefined && objWrap.objDCampaign.AdsE_Genre_s__c != '') {
                        selectedNetwork = objWrap.objDCampaign.AdsE_Genre_s__c.split(',');
                        console.log('selectedNetwork:::', selectedNetwork);
                        console.log('objWrap.objDCampaign.Product_Type__c:::', objWrap.objDCampaign.Product_Type__c);
                        console.log('objWrapRec.objIS.Inventory_Resource_Type__c:::', objWrapRec.objIS.Inventory_Resource_Type__c);
                        console.log('selectedNetwork.includes::', selectedNetwork.includes('All Networks'));
                        disableForCimplifi = (objWrapRec.objIS.Inventory_Resource_Type__c == "Simpli.fi-CTV" &&
                            (!(objWrap.objDCampaign.Product_Type__c == 'DMA Addressable' ||
                                objWrap.objDCampaign.Product_Type__c == 'National Addressable') ||
                                !selectedNetwork.includes('All Networks')))
                         //SRSF-3917 End
                         console.log('disableForCimplifi',disableForCimplifi);
                        //SRSF-4469:simpliFi visible when Networks is'Selected Networks'.
                        if ((objWrap.objDCampaign.RecordType.DeveloperName == "Inventory_Request_New_Ads_Everywhere"
                            || objWrap.objDCampaign.RecordType.DeveloperName == "Inventory_Request_Revision_New_Ads_Everywhere")
                            && selectedNetwork.includes('Selected Networks')
                            && ((objWrap.objDCampaign.Product_Type__c == 'DMA Addressable' ||
                                objWrap.objDCampaign.Product_Type__c == 'National Addressable'))) {
                            disableForCimplifi = false;
                        }
                        console.log('disableForCimplifi:::::', disableForCimplifi);
                    }
                   //SRSF-4469 End


                    
                    console.log('**objWrapRec.isCPMGrrossLocked::objWrapRec.isCPMGrrossLocked ');
                    console.log('**isCPM_CostLock::',isCPM_CostLock);
                    console.log('**third condition');
                    console.log('**objWrap.objDCampaign.Full_Avail_Campaign__c::',objWrap.objDCampaign.Full_Avail_Campaign__c);
                    console.log('**objWrapRec.objIS.Inventory_Resource_Type__c::',objWrapRec.objIS.Inventory_Resource_Type__c);
                    console.log('**objWrap.objDCampaign.Product_Type__c::',objWrap.objDCampaign.Product_Type__c);
                    console.log('**disableForCimplifi::',disableForCimplifi);
                    
                    
                    // Add disableForCimplifi condition
                    if(objWrapRec.isCPMGrrossLocked || isCPM_CostLock || (objWrapRec.objIS.Inventory_Resource_Type__c == "Freewheel-SA" && 
                                           (objWrap.objDCampaign.X1x1_Pixel__c == true || objWrap.objDCampaign.VAST_Tag__c == 'Yes' 
                                            ||objWrap.objDCampaign.Product_Type__c == 'Default Ads Everywhere Campaign') ) 
                                           || objWrap.objDCampaign.Full_Avail_Campaign__c == true || 
                                           (objWrapRec.objIS.Inventory_Resource_Type__c == "TTD-CTV" &&
                                            (objWrap.objDCampaign.Product_Type__c == 'DMA Addressable' || 
                                             objWrap.objDCampaign.Product_Type__c == 'National Addressable' )) 
                                           || disableForCimplifi){   
                        console.log('TTD-CTV - in if');
                        
                        isCPM_GrossLockedJS = true;                 
                    }
                    else{
                        console.log('TTD-CTV -in Else');
                         isCPM_GrossLockedJS = false; 
                    }
                    var isExclusionDisableJS = false;
                    
                 
                    if(objWrapRec.objIS.Inventory_Resource_Type__c == "Freewheel-O&O/Affiliate/Direct" ){
                        isExclusionDisableJS = false;  
                    }
                    else{
                        isExclusionDisableJS = true;
                    }

                    // SRSF-4158 start
                   // let colorcode = 'background-color:red;';
                    console.log('objWrapRec.isActiveCatalog:::::',objWrap.isActiveCatalog);
                       

                     if((!(objWrap.objDCampaign.Product_Type__c == 'DMA Addressable' || objWrap.objDCampaign.Product_Type__c == 'National Addressable' ) 

                          && objWrapRec.objIS.Inventory_Resource_Type__c == "Simpli.fi-CTV") ||

                       	( !objWrap.isActiveCatalog && objWrapRec.objIS.Inventory_Resource_Type__c == "Simpli.fi-CTV" && (objWrap.objDCampaign.Product_Type__c == 'DMA Addressable' 

                      || objWrap.objDCampaign.Product_Type__c == 'National Addressable' ))){



                        isExclusionDisableJS = true;

                        isCPM_GrossLockedJS = true;

                     }

                     if(((objWrap.objDCampaign.Product_Type__c == 'DMA Addressable' || objWrap.objDCampaign.Product_Type__c == 'National Addressable'||objWrap.objDCampaign.Product_Type__c == 'Default Ads Everywhere Campaign' ||objWrap.objDCampaign.Product_Type__c == 'Customer Data Match' ) 

                          && objWrapRec.objIS.Inventory_Resource_Type__c == "Simpli.fi-CTV")){

                         

                          // isExclusionDisableJS = false;

                        isCPM_GrossLockedJS = false;
                      //  component.set("v.totalcostWarningMsg", colorcode);
                    //    component.set('v.showInactiveCatalogWarning',true);
                    }
            /*        else{	
                        isExclusionDisableJS = true;
                        isCPM_GrossLockedJS = true;
					}*/
                 
                    // SRSF-4158 end
                    // SRSF-4328 start
                    if (objWrap.objDCampaign.Product_Type__c === 'Customer Data Match') {
                        if (objWrapRec.objIS.Inventory_Resource_Type__c == "TTD-CTV" || objWrapRec.objIS.Inventory_Resource_Type__c == 'Freewheel-O&O/Affiliate/Direct') {

                           
                 if(objWrapRec.objIS.Inventory_Resource_Type__c == "TTD-CTV"){

                                 isExclusionDisableJS = true; 

                            }else{

                                isExclusionDisableJS = false; 

                            }
                            // if (objWrapRec.objIS.Inventory_Resource_Type__c == "TTD-CTV" && ($A.util.isUndefinedOrNull(objWrapRec.CPM) || $A.util.isUndefinedOrNull(objWrapRec.Cost))) {
                            //     component.set("v.showErrorMsg3", true);
                            //     console.log('test::::: ...', objWrapRec.CPM, objWrapRec.Cost);
                            // } else {
                            //     component.set("v.showErrorMsg3", false);
                            //     console.log('test::::: ...false', objWrapRec.CPM, objWrapRec.Cost);
                            // }
                        }
                        else {
                            console.log('test::::: false...');
                            isExclusionDisableJS = true;
                            isCPM_GrossLockedJS = true;
                        }
                    }

                    // SRSF-4328 end  

                    RowItemList.push({"startDate": maxcampaignstartdate,"endDate": maxcampaignenddate,
                                      "lstIS":lstInvSrc,"selIS": objWrapRec.selIS,
                                      "lstDCType":lstType,"selType": objWrapRec.selType,
                                      "lstAudience":lstAudience,"selAud":objWrapRec.selAud, 
                                      "lstGeoTargetType":lstGeoTargetType,"selGeoType":objWrapRec.selGeoType,
                                      "lstExcl":lstExclision,
                                      "Notes": objWrapRec.Notes,"Impressions":objWrapRec.Impressions,
                                      "CPM":objWrapRec.CPM,"Cost":objWrapRec.Cost,
                                      "Industry":objWrapRec.Industry,"LineItemId":objWrapRec.LineItemId,
                                      "RecordId":objWrapRec.RecordId,"objIS":objWrapRec.objIS,
                                      "isEditStDate":objWrapRec.isEditStDate,
                                      "isImpressionsDisable":isDisable,
                                      "isCPM_GrossLocked":isCPM_GrossLockedJS,
                                      "isExclusionDisable":isExclusionDisableJS
                                     });
                    }
            	}
            	component.set("v.datesArray", RowItemList);
            	console.log("RowItemList@@@", RowItemList);
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
        console.log("RowItemList@@", RowItemList);
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
        lstInvSrc.push("Freewheel-SA");
        lstInvSrc.push("Freewheel-FF OTT");
        lstInvSrc.push("Freewheel-FF TVE");
        lstInvSrc.push("TTD-CTV");
        lstInvSrc.push("Simpli.fi-CTV");
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
        
        var exclusionValue;
        var excludeRangeFor18to25 = false;
        var resultrap = component.get("v.resultWrap");  
        
        var exVal = component.get("v.exValArr");
        var stringExcludeRangeFor18_25 = $A.get("$Label.c.ExcludeRangeFor18_25");
        var listExcludeRangeFor18_25 = stringExcludeRangeFor18_25.split(',');
        var exclusionValueFromPickList = component.get("v.lstExlPicklist");
        console.log("resultrap- ",resultrap);
        // SRSF-4328 start
       for (var obj in resultrap.lstPlanRecords) {
        var objWrapRec = resultrap.lstPlanRecords[obj];
        if (resultrap.objDCampaign.Product_Type__c === 'Customer Data Match') {
            console.log('errormsg working:::::')
            if (objWrapRec.objIS.Inventory_Resource_Type__c == "TTD-CTV" && ($A.util.isUndefinedOrNull(objWrapRec.CPM) || $A.util.isUndefinedOrNull(objWrapRec.Cost))) {
                //component.set("v.showErrorMsg3", true);
                
                console.log('errormsg working::::: test::::: ...', objWrapRec.CPM, objWrapRec.Cost);
            }

        }

      
    }  // SRSF-4328 end  
        if(resultrap.lstPlanRecords){
            if(resultrap.lstPlanRecords[0].objIS.Exclusions__c != 'None' && resultrap.lstPlanRecords[0].objIS.Exclusions__c){
                exclusionValue = resultrap.lstPlanRecords[0].objIS.Exclusions__c.split(';');
               // excludeRangeFor18to25 = true;
                if(listExcludeRangeFor18_25.every(item => exclusionValue.includes(item))){
                    excludeRangeFor18to25 = true;
                }
            }
            
            console.log('excludeRangeFor18to25::::',excludeRangeFor18to25);
            
            var RowItemList = component.get("v.datesArray"); 

            var isAllSelected = false;
            var isAllSelected = component.get("v.isAllSelected");
            if(isAllSelected == undefined && ((exVal.length + 2) == exclusionValueFromPickList.length)){
                isAllSelected = true;
            }   
            var yieldExVal = component.get("v.yieldEx");
            console.log("yieldExVal=====",yieldExVal);
            
            //console.log("allOptionsEx", allOptionsEx);
            //var alloptionsString = "AT&T/Xandr;Discovery Buyback;Dish/Sling;Fourfronts OTT;Fourfronts TVE;PlutoTV;Revvid;Verizon;Viacom Live Buyback;Viacom STB VOD Buyback";
            var totImp    = resultrap.totImpressions;
            var totCPM    = resultrap.totCPM;
            var totcost1   = resultrap.totCOST;  
            
            var isValid = true;
            var dcStatus = $A.get("$Label.c.CM_ClientRequestPlanDetails_Status");
            console.log("==dcStatus", dcStatus);
            var dcStatusList = '';
            var dcSource = resultrap.objDCampaign.Source__c;
            if(!dcStatus.includes(resultrap.objDCampaign.Status__c) && dcSource!= 'Audience Track' && dcSource!= 'SPP'){
                var dcStat = dcStatus.split(',');
                dcStat.forEach(stat => {dcStatusList+=stat+'\n'})
                this.showToast("error", "Error!", `YISF can only be edited in the following Statuses:\n ${dcStatusList}`);           
                isValid = false;
            }else{
                let flag = false;
                let k = 0;
            //console.log("resultrap.objDCampaign.Efficiency_Packages__@@@@", resultrap.objDCampaign.Efficiency_Packages__c);
                for(var i=0;i<=5;i++){
                    console.log('****0 Index cpm value::::',RowItemList[0].CPM );
                    console.log('****1 Index cpm value::::',RowItemList[1].CPM );
                    console.log('****1 Index cpm value not::::',!RowItemList[1].CPM );
                    console.log('****5 Index cpm value::::',RowItemList[5].CPM );
                    console.log('****5 Index cpm value not::::',!RowItemList[5].CPM );
                    
                    console.log('****isAllSelected::::',isAllSelected);
                    if(RowItemList[i].CPM && yieldExVal == false && k==0){
                        flag = true;
                        k = k+1;
                    }
                    if(resultrap.objDCampaign.Efficiency_Packages__c ){
                        if(i>0 && (RowItemList[i].CPM || RowItemList[i].Cost || (RowItemList[i].objIS.Exclusions__c && RowItemList[i].objIS.Exclusions__c != "None"))){
                                component.set("v.isDMLError", true);
                                this.showToast("error", "Error!",  "There is an Efficiency Package on this DC, only Freewheel - O&O/Affiliate/Direct inventory is allowed.");
                                isValid = false;
                                break;
                        }else if(i==0 && RowItemList[i].CPM && RowItemList[i].CPM >= 0 && !isAllSelected ){
                                component.set("v.isDMLError", true);
                                this.showToast("error", "Error!", "Exclusion selected should be 'All'");
                                isValid = false;
                                break;
                        }    
                        }
                        else if(!resultrap.objDCampaign.Efficiency_Packages__c){
                            if(i>0 && RowItemList[i].CPM && RowItemList[i].CPM <= 25 && RowItemList[i].CPM >= 0 && yieldExVal == false){
                                component.set("v.isDMLError", true);
                                this.showToast("error", "Error!", "Gross CPM Value should be greater than $25");
                                isValid = false;
                                break;
                            }else if(i!=0 && i!=4 && RowItemList[i].CPM && RowItemList[i].CPM <= 25 && RowItemList[i].CPM >= 0 && yieldExVal == false){
                                component.set("v.isDMLError", true);
                                this.showToast("error", "Error!", "Gross CPM Value should be greater than $25 except for Only Freewheel - O&O/Affiliate/Direct inventory and TTD-CTV");
                                isValid = false;
                                break;
                            }else if(i==0  && RowItemList[i].CPM == 0 && !isAllSelected &&
                                    yieldExVal == false ){
                                console.log('****In else if');
                                component.set("v.isDMLError", true);
                                this.showToast("error", "Error!",  "Error! Gross CPM i $0, Exclusion selected should be 'All'");
                                isValid = false;
                                break;
                        }else if(i==0 && RowItemList[i].CPM >= 0.01 && RowItemList[i].CPM <= 15 && RowItemList[i].CPM && yieldExVal == false && excludeRangeFor18to25==false ){
                                component.set("v.isDMLError", true);
                                let arryString = listExcludeRangeFor18_25.join(", ");
                            this.showToast("error", "Error!", "Gross CPM is in the range $0.01-$15, Valid exclusions for this range is: \n" +arryString);
                           
                                isValid = false;
                                break;
                        }else if(i==0 && !isAllSelected && RowItemList[i].CPM <= 25 && RowItemList[i].CPM && RowItemList[i].CPM >= 0 && yieldExVal == false &&(
                                (RowItemList[1].CPM && RowItemList[1].CPM <= 25) || (RowItemList[2].CPM && RowItemList[2].CPM <= 25) || 
                            (RowItemList[3].CPM && RowItemList[3].CPM <= 25) || (RowItemList[4].CPM && RowItemList[4].CPM <= 25)||
                            (RowItemList[5].CPM && RowItemList[5].CPM <= 25) )){
                                component.set("v.isDMLError", true);
                                this.showToast("error", "Error!", "Only Freewheel - O&O/Affiliate/Direct inventory can be less than $25");
                                isValid = false;
                                break;
                            } else if(i==0 && RowItemList[i].CPM <= 25 && RowItemList[i].CPM && RowItemList[i].CPM >= 0 && yieldExVal == false &&(
                                (RowItemList[1].CPM && RowItemList[1].CPM <= 25) || (RowItemList[2].CPM && RowItemList[2].CPM <= 25) || (RowItemList[3].CPM && RowItemList[3].CPM <= 25) || (RowItemList[5].CPM && RowItemList[5].CPM <= 25))){
                                component.set("v.isDMLError", true);
                                this.showToast("error", "Error!", "Only Freewheel - O&O/Affiliate/Direct inventory and TTD-CTV can be less than $25");
                                isValid = false;
                                break;
                            }    
                        }
                        console.log('flag in loop:::',flag);
                }
                console.log('flag:::',flag);
            // if(!flag && !yieldExVal){
                // this.showToast("error", "Error!", "CPM(GROSS) can not be blank");
                    //isValid = false;
                
                //}
                

            }
            if(isValid){
                component.set("v.spinner", true);
                var action    = component.get("c.UpdateData");
                console.log('datesArray: ',RowItemList);
                console.log('YieldEx@@: ',typeof(yieldExVal));
                action.setParams({
                    dcRecordId: recId,
                    wrapInvSrcData : JSON.stringify(RowItemList),
                    totImpressions : totImp,
                    totCPM : totCPM,
                    totCOST : totcost1,
                    yieldEx : yieldExVal
                });
                action.setCallback(this, function(response) {
                if (response.getState() === "SUCCESS") {
                    var objWrap = response.getReturnValue();
                    console.log("objWrapNew=====@@@@",objWrap);
                    component.set("v.resultWrap", objWrap);
                    component.set("v.isDMLError", false);
                    this.showToast("success", "Success!", "Details have been added successfully.")
                    
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
                component.set("v.spinner", false);
                $A.get("e.force:refreshView").fire();
            });
            $A.enqueueAction(action);
            }
        }
	},
    
    isEmpty : function(val){ 
		return (val === undefined || val == null || val.length <= 0) ? true : false; 
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