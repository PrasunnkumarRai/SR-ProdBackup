({
    //Adding one more row with currentdate as Flight Start Date,Flight End Date 
    createObjectData: function(component, event) {
        var RowItemList = component.get("v.timArray");
        var TrafficSystemArr = component.get("v.timOrders");
        RowItemList.push({"lstTrafficSystem": TrafficSystemArr, "selTrafficSystem": "", "TIMOrder": ""});
        component.set("v.timArray", RowItemList);
    },
    
    fetchTIMOrderData: function(component, event, helper) {
        //alert("Coming..");
        var action = component.get("c.getTrafficSystemData");
        action.setCallback(this, function(response) {
            if (response.getState() === "SUCCESS") {
                console.log(response.getReturnValue());
                component.set("v.timOrders", response.getReturnValue());
                var recId = component.get("v.recordId");
				helper.fetchTIMData(component, recId, helper);
            }
        });
        $A.enqueueAction(action);
    },
    
    //Fetching all the FlightDates in the PageLoad
	fetchTIMData : function(component, recId) {
        var action = component.get("c.PrepareData");
        action.setParams({
             dcRecordId: recId
        });
        action.setCallback(this, function(response) {
            if (response.getState() === "SUCCESS") {
                var objWrap = response.getReturnValue();
                console.log(objWrap.lstTimInfo);
                var RowItemList = component.get("v.timArray");
                for(var obj in objWrap.lstTimInfo){
                    var lstTrafficSystem = objWrap.lstTimInfo[obj]['lstTrafficSystem'];
                    //console.log(lstTrafficSystem);
                    var selTrafficSystem = objWrap.lstTimInfo[obj]['selTrafficSystem'];
                    var TIMOrder = objWrap.lstTimInfo[obj]['TIMOrder'];
                	//RowItemList.push(obj);
                    RowItemList.push({"lstTrafficSystem": lstTrafficSystem,"selTrafficSystem":selTrafficSystem,"TIMOrder": TIMOrder});
                }
                component.set("v.timArray", RowItemList);
            }
        });
        //Tooltip for Flight Dates
        var tooltip = $A.get("$Label.c.CM_DCTIMInformation");
        var res = tooltip.replace(/\n/g, "<br/>");
        component.set("v.flightDtTooltip", res);
        $A.enqueueAction(action);
	},
    
    //Upserting FlightDates information
    saveTIMData : function(component, recId) {
        var updatedData = '';
        var RowItemList = component.get("v.timArray");
        for(var obj in RowItemList){
            var selTrafficSystem = RowItemList[obj]['selTrafficSystem'];
            var TIMOrder = RowItemList[obj]['TIMOrder'];
            updatedData+=selTrafficSystem+':'+TIMOrder+';';
        }
        console.log(updatedData);
        //return;
        var action = component.get("c.UpdateData");
        action.setParams({
            dcRecordId: recId,
            strData: updatedData
        });
        action.setCallback(this, function(response) {
            if (response.getState() === "SUCCESS") {
                var objWrap = response.getReturnValue();
                var RowItemList = component.get("v.timArray");
                component.set("v.timArray", RowItemList);
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