({
	getDetails : function(component,event,helper) {
        console.log('========>> in getDetails');
		var recId = component.get("v.recordId");
        var action = component.get("c.getLeadDetails");
        console.log('========>> recId = ' + recId);
        console.log('========>> action = ' + action);
        action.setParams({
            strRecId : recId
        });
        action.setCallback(this,function(response){
            var state = response.getState();
            if (component.isValid() && state == "SUCCESS") {
            	console.log(response.getReturnValue());
                var wrapper = response.getReturnValue();
                var lstAcc=[];
                for(var val in wrapper.lstAccounts){
                    var acc = wrapper.lstAccounts[val].split('#$#');
                    lstAcc.push({value:acc[0] ,label:acc[1]});
                }
                console.log('In callback, wrapper: ');
                console.log(wrapper);
                
                component.set('v.LeadStatus',wrapper.lstStatus);
                component.set('v.Accounts',lstAcc);
                component.set('v.oppName',wrapper.strCompany+'-');
                component.set("v.objLead",wrapper.objLead);
                component.set("v.selUser",wrapper.recordOwnerId);


                this.displayAEWarning(wrapper.recordOwnerTeamRole);

            }
        });
        $A.enqueueAction(action);
	},
    updateAECheck: function(component, event, helper, ownerId) {
        var action = component.get("c.getRecordOwnerTeamRole");
        action.setParams({
            OwnerId : ownerId
        });
        action.setCallback(this,function(response){
            var state = response.getState();
            if (component.isValid() && state == "SUCCESS") {
                console.log(response.getReturnValue());
                this.displayAEWarning(response.getReturnValue());
            }
        });
        $A.enqueueAction(action);
	},
    
    displayAEWarning: function(recordId) {
        if(recordId != "Account Executive") {
            document.getElementById("warningDiv").style.display = 'block';
            document.getElementById("doNotOppty").checked = true;
            document.getElementById("doNotOppty").disabled = true;
        }
        else {
            document.getElementById("warningDiv").style.display = 'none';
            document.getElementById("doNotOppty").disabled = false;
        }
    },
        
    changeOppName: function(component,event,helper) {
        console.log(component.get('v.selAccount'));
    	var lstAcc = component.get('v.Accounts');
        var lead = component.get("v.objLead");
        var selectCmp = component.find("exsAccId");
		var selAccId = selectCmp.get("v.value");
        var oppName;
        
        for(var indx in lstAcc)
        {
            if (selAccId == 'NEW' || selAccId == 'NONE') {
            	oppName = lead.Company;
        	}
            else if(selAccId == lstAcc[indx].value)
            {
                var lst = lstAcc[indx].label.split('Attach to existing:');
                oppName = lst[1];
            }
        }
        component.set('v.oppName',oppName+'-');
    },
    
    getLookedUpAcc: function(component,event,helper) {
    	var accId = component.get('v.selAccount');
        var action = component.get("c.getLookedUpAccount");
        action.setParams({
            strAccId : accId
        });
        action.setCallback(this,function(response){
            var state = response.getState();
            if (component.isValid() && state == "SUCCESS") {
            	console.log(response.getReturnValue());
                var optn = response.getReturnValue();
                var lstAcc = component.get('v.Accounts');
                
                var acc = optn.split('#$#');
                lstAcc.push({value:acc[0] ,label:acc[1]});
                
                component.set('v.Accounts',lstAcc);
                component.set('v.oppName',acc[1]+'-');
                component.find("exsAccId").set("v.value", accId);
            }
        });
        $A.enqueueAction(action);
    },
    
    LeadConversion: function(component,event,helper) {
        console.log('------------->> in LeadConversion!');
   ////     $('.Spinner').css('display', 'inline');
        console.log('----->> after spinner');
        var lead = component.get("v.objLead");
        console.log('------------->> lead = ' + lead);        
        var accId = component.find("exsAccId").get("v.value");
//        console.log('------------->> accId = ' + accId);
        console.log('------------->> accId = ' + (accId == null ? "NEW" : accId));
        var doNotOpp = document.getElementById("doNotOppty").checked;
        console.log('------------->> doNotOpp = ' + doNotOpp);
        var oppName = component.get('v.oppName');
                console.log('------------->> oppName = ' + oppName);
        var ownrID = component.get('v.selUser');
        console.log('------------->> ownrID = ' + ownrID);
        if(ownrID == null)
            ownrID = lead.OwnerId;
                console.log('------------->> ownrID(1) = ' + ownrID);

        //console.log(component.get("v.userContext"));
        //console.log(test);
        //window.open("/one/one.app?source=aloha#/sObject/00Q4B000004xeARUAY");
        var action = component.get("c.convertLead");
        console.log('------------->> action = ' + action);
        action.setParams({
            objLead : lead,
            strSelectedAccount : (accId == null ? "NEW" : accId),
            doNotCreateOppty : doNotOpp,
            strOppName : oppName,
            strOwnerId : ownrID
        });
        action.setCallback(this,function(response){
            var state = response.getState();
            console.log('------->> In callback, state = ' + state);
        //    $('.Spinner').css('display', 'none');
            if (component.isValid() && state == "SUCCESS") {
                console.log('----------->> returnvalue:');
                console.log(response.getReturnValue());
                var accId = response.getReturnValue();
                console.log(accId);
                if(accId != null){
                    document.getElementById("msgDiv").style.display = 'block';
                    document.getElementById("sucMsg").innerHTML = 'Lead Converted Successfully';
                    console.log(accId);
                    
                    window.setTimeout(
                        $A.getCallback(function() {
                            if (component.isValid()) {
                                sforce.one.navigateToSObject(accId);
                            }
                        }), 500
                    );
                }
            }
            else
            {
                var error = response.getError()[0].message;
                document.getElementById("errorDiv").style.display = 'block';
                document.getElementById("errorMsg").innerHTML = error;
            }
        });
        $A.enqueueAction(action);
    }
})