({
    //Adding one more row with currentdate as Flight Start Date,Flight End Date 
    createObjectData: function(component, event, helper) {
        var RowItemList = component.get("v.datesArray");
        var objWrap = component.get("v.resultWrap");
        var maxcampaignstartdate = (objWrap.objDCampaign.Campaign_Start_Date__c!=undefined)? objWrap.objDCampaign.Campaign_Start_Date__c : new Date();
        var maxcampaignenddate = (objWrap.objDCampaign.Campaign_End_Date__c!=undefined)? objWrap.objDCampaign.Campaign_End_Date__c : new Date();
        //alert(RowItemList.length);
        if(RowItemList.length == 0){
            var maxst = maxcampaignstartdate;
            var maxend = maxcampaignenddate;
            RowItemList.push({"startDate": maxst,"endDate": maxend,"maxst":maxst,"maxend":maxend,"disable":false});          
        }else{
        	var maxst = RowItemList[RowItemList.length-1].endDate;
            var maxend = maxcampaignenddate;
            RowItemList.push({"startDate": maxst,"endDate": maxend,"maxst":maxst,"maxend":maxend,"disable":false});              
        }
        for(var i=0;i<RowItemList.length;i++){
            if(i == (RowItemList.length-1)){
        		RowItemList[i].disable = false;
            }
            else{
                RowItemList[i].disable = true;
            }
        }
		component.set("v.datesArray", RowItemList);
        this.checkForErrorMessage(component, event, helper);
    },
    
    checkForErrorMessage: function(component, event, helper) {
    	var objWrap = component.get("v.resultWrap");
        var maxcampaignenddate = objWrap.objDCampaign.Campaign_End_Date__c;
        var RowItemList = component.get("v.datesArray");
        /*for(var i=0;i<RowItemList.length;i++){
            var inputstdate = this.formatDate(RowItemList[i].startDate);
            var inputenddate = this.formatDate(RowItemList[i].endDate);
            console.log(maxcampaignenddate+'##'+this.formatDate(inputstdate)+'=='+this.formatDate(inputenddate));
            if( (inputstdate > maxcampaignenddate) || (inputenddate > maxcampaignenddate) ){
                component.set("v.showErrorMsg", true);
            }else{
                component.set("v.showErrorMsg", false);
            }
        }*/
        if(RowItemList.length>0 && RowItemList[RowItemList.length-1].endDate != maxcampaignenddate){
            component.set("v.showErrorMsg", true);
        }else{
            component.set("v.showErrorMsg", false);
        }
    },
    
    formatDate: function(date) {
        var d = new Date(date),
            month = '' + (d.getMonth() + 1),
            day = '' + d.getDate(),
            year = d.getFullYear();
    
        if (month.length < 2){ 
            month = '0' + month;
        }
        if (day.length < 2){ 
            day = '0' + day;
        }
    
        return [year, month, day].join('-');
    },
    
    //Fetching all the FlightDates in the PageLoad
	fetchFlightDate : function(component, recId) {
        //alert(recId);
        var action = component.get("c.PrepareData");
        action.setParams({
             dcRecordId: recId
        });
        action.setCallback(this, function(response) {
            if (response.getState() === "SUCCESS") {
                var objWrap = response.getReturnValue();
                component.set("v.resultWrap", objWrap);
                console.log(objWrap.objDCampaign);
                var maxcampaignstartdate = (objWrap.objDCampaign.Campaign_Start_Date__c!=undefined)? objWrap.objDCampaign.Campaign_End_Date__c : new Date();
                var maxcampaignenddate = (objWrap.objDCampaign.Campaign_End_Date__c!=undefined)? objWrap.objDCampaign.Campaign_End_Date__c : new Date();
                var RowItemList = component.get("v.datesArray");
                for(var obj in objWrap.lstFlightDates){
                    var stdt = this.formatDate(objWrap.lstFlightDates[obj]['startDate']);
                    var enddt = this.formatDate(objWrap.lstFlightDates[obj]['endDate']);
                	var isdisable = false;
                    if(obj == (objWrap.lstFlightDates.length-1)){
                        var maxstdt;
                        var len = objWrap.lstFlightDates.length;
                        if(len == 1){
                            maxstdt = maxcampaignstartdate;
                        }else{
                            maxstdt = this.formatDate(objWrap.lstFlightDates[len-2]['endDate']);
                        }
                        RowItemList.push({"startDate": stdt,"endDate": enddt,"maxst":maxstdt,"maxend":maxcampaignenddate,"disable":false});
                    }
                    else{
                        RowItemList.push({"startDate": stdt,"endDate": enddt,"maxst":stdt,"maxend":maxcampaignenddate,"disable":true});
                    }
                }
                component.set("v.datesArray", RowItemList);
                
                //check for Error message
                var RowItemList = component.get("v.datesArray");
                if(RowItemList.length>0 && RowItemList[RowItemList.length-1].endDate != maxcampaignenddate){
                    component.set("v.showErrorMsg", true);
                }else{
                    component.set("v.showErrorMsg", false);
                }
            }
        });
        //Tooltip for Flight Dates
        var tooltip = $A.get("$Label.c.CM_Flight_Dates");
        var res = tooltip.replace(/\n/g, "<br/>");
        component.set("v.flightDtTooltip", res);
        $A.enqueueAction(action);
	},
    
    //Upserting FlightDates information
    saveFlightDate : function(component, recId) {
        var isError = component.get("v.showErrorMsg");
        if(isError){
            var objWrap = component.get("v.resultWrap");
        	var maxcampaignenddate = objWrap.objDCampaign.Campaign_End_Date__c;
            this.showToast("error", "Error!", "The Flight End date must end on "+maxcampaignenddate);
            return false;
        }
        var updatedData = '';
        var RowItemList = component.get("v.datesArray");
        if(RowItemList.length == 1){
            this.showToast("error", "Error!", "At least two sets of dates are required.");
            return false;
        }
        for(var obj in RowItemList){
            var stdt = RowItemList[obj]['startDate'];
            var enddt = RowItemList[obj]['endDate'];
            //console.log("Before");
            //console.log(stdt);
            //console.log(enddt);
            if( stdt.indexOf(',')>0 ){
                //console.log(stdt+"chageDateFormatJSToApex");
            	stdt = this.chageDateFormatJSToApex(stdt);
            }
            else{
                //console.log(stdt+"chageDateFormatJSToApexNew");
                stdt = this.chageDateFormatJSToApexNew(stdt);
            }
            //console.log("After");
            if( enddt.indexOf(',')>0 ){
            	enddt = this.chageDateFormatJSToApex(enddt);
            }else{
                enddt = this.chageDateFormatJSToApexNew(enddt);
            }
            updatedData+=stdt+':'+enddt+';';
        }
        //console.log(updatedData);
        var action = component.get("c.UpdateData");
        action.setParams({
            dcRecordId: recId,
            strData: updatedData
        });
        action.setCallback(this, function(response) {
            if (response.getState() === "SUCCESS") {
                var objWrap = response.getReturnValue();
                //console.log(objWrap.lstFlightDates);
                var RowItemList = component.get("v.datesArray");
                component.set("v.datesArray", RowItemList);
                if( objWrap.strMsg.indexOf('Error') == -1 ){
                    this.showToast("success", "Success!", objWrap.strMsg);
                }else{
                    this.showToast("error", "Error!", objWrap.strMsg);
                }
            }else{
                this.showToast("error", "Error!", JSON.stringify(response.error));
            }
        });
        $A.enqueueAction(action);
	},
    
    //Converting JS date to Apex date(Not using)
    chageDateFormatJSToApex : function(strDate){
        var mapMonthToNumber = this.prepareMonToNum();
        var lst = strDate.split(' ');
        var resultDate = mapMonthToNumber[lst[0]]+'/'+(lst[1]).replace(',','')+'/'+lst[2];
        return resultDate;
    },
    
    //Converting JS date to Apex date
    chageDateFormatJSToApexNew : function(strDate){
        var lst = strDate.split('-');
        var resultDate = lst[1]+'/'+lst[2]+'/'+lst[0];
        return resultDate;
    },
    
    //Preparing Month to Number
    prepareMonToNum : function(){
        var mapMonthToNumber = new Object();
        mapMonthToNumber['Jan'] = '01';
        mapMonthToNumber['Feb'] = '02';
        mapMonthToNumber['Mar'] = '03';
        mapMonthToNumber['Apr'] = '04';
        mapMonthToNumber['May'] = '05';
        mapMonthToNumber['Jun'] = '06';
        mapMonthToNumber['Jul'] = '07';
        mapMonthToNumber['Aug'] = '08';
        mapMonthToNumber['Sep'] = '09';
        mapMonthToNumber['Oct'] = '10';
        mapMonthToNumber['Nov'] = '11';
        mapMonthToNumber['Dec'] = '12';
        return mapMonthToNumber;
    },
    
    //Preparing Number to Month
    prepareNumToMon : function(){
        var mapNumberToMonth = new Object();
        mapNumberToMonth['01'] = 'Jan';
        mapNumberToMonth['02'] = 'Feb';
        mapNumberToMonth['03'] = 'Mar';
        mapNumberToMonth['04'] = 'Apr';
        mapNumberToMonth['05'] = 'May';
        mapNumberToMonth['06'] = 'Jun';
        mapNumberToMonth['07'] = 'Jul';
        mapNumberToMonth['08'] = 'Aug';
        mapNumberToMonth['09'] = 'Sep';
        mapNumberToMonth['10'] = 'Oct';
        mapNumberToMonth['11'] = 'Nov';
        mapNumberToMonth['12'] = 'Dec';
        return mapNumberToMonth;
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