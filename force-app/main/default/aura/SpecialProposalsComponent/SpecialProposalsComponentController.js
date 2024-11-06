({
    createSCXInventoryProposal: function(component, event, helper) {
        debugger;
        //$A.get("e.force:refreshView").fire(); 
        var oppId = component.get('v.OppId');
        var recordTypeInventory = component.get('v.var_RT');
        //var url = "/apex/ProposalTIMCreate?Id= "; -- Commented as part of SRSF-1762 
       // var url = "/apex/ConfirmToSaveAccountsInTim?Id= "; // SRSF-1762 //Commented as part of SRSF-4166
        var url = "/apex/CreateShowSeekerProposal?OppId="; //SRSF-4166
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": url + oppId,
            //+"&invRT="+recordTypeInventory"id": oppId,
            //"invRT" : recordTypeInventory,
            "isredirect": "true"
        });
        urlEvent.fire();
    },
    doInit: function(component, event, helper) {
        debugger;
        //showSpinner(component);
        var recordId = component.get('v.OppId');
        if (!$A.util.isUndefinedOrNull(recordId)) {
            //hideSpinner(component,event,helper);
            var recordId = component.get('v.OppId');
            var displayRecordTypes = [];
            var action = component.get('c.fetchRecordType');
            action.setParams({
                'oppId': recordId
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                //alert(state);
                var dataMap = response.getReturnValue();
                //var dataMap = JSON.parse(response.getReturnValue());
                //alert(dataMap);
                if (dataMap != null) {
                    for (var key in dataMap) {
                        /*if (dataMap[key].DeveloperName == $A.get("$Label.c.Political_RT")) {
                            //component.set("v.showSystemInfo", true)
                            component.set('v.var_RT', '_PR');
                            //alert('showValue'+component.get('v.showSystemInfo'));
                            //alert('varRT'+component.get('v.var_RT'));
                            return;
                        } else {*/
                            displayRecordTypes.push({
                                ckey: key,
                                recName: dataMap[key].DeveloperName,
                                descr: ': ' + dataMap[key].Description
                            });

                        //}

                    }
                    if (!$A.util.isUndefinedOrNull(displayRecordTypes)) {
                        component.set('v.recordTypeList', displayRecordTypes);
                    }
                }

            });
            // Invoke the service
            $A.enqueueAction(action);
            //var oppid = component.get('v.OppId');
        }

    },

    onValueChange: function(component, event, helper) {
        debugger;
        component.set("v.showMessage", false);
        var value_scx = false;
        var value_pilot = false;
        var evt = event.getSource();
        var localName = evt.getLocalId();
        if (localName == 'SCX_Select') {
            value_scx = true;
        }
        if (localName == 'Pilot_Select') {
            value_pilot = true;
        }
        component.set('v.value_scx', value_scx);
        component.set('v.value_pilot', value_pilot);

    },
    onRecordTypeSelect: function(component, event, helper) {
        debugger;
        component.set("v.showMessage", false);
        var evt = event.getSource();
        var text = evt.get("v.text");
        var valueBool = evt.get("v.value");
        if (valueBool) {
            if (text == $A.get("$Label.c.Inventory_RT")) {
                component.set('v.var_RT', '_INV');
            } else if (text == $A.get("$Label.c.Linear_RT")) {
                component.set('v.var_RT', '_LR');
            } else if (text == $A.get("$Label.c.Periodical_RT")) {
                component.set('v.var_RT', '_PR');
            } else if (text == $A.get("$Label.c.Trade_RT")) {
                component.set('v.var_RT', '_TR');
            } else if (text == $A.get("$Label.c.Political_RT")) {
                component.set('v.var_RT', '_PR');
            }
        }

    },
    afterRecordTypeSelect: function(component, event, helper) {
        debugger;
        var selectedRT = component.get('v.var_RT');
        if ($A.util.isUndefinedOrNull(selectedRT)) {
            component.set("v.showMessage", true);
            //component.set("v.errorMessage" ,{!$Label.c.ERROR_TEXT});
        } else {
            component.set("v.showSystemInfo", true);
        }

    },


    fetchInputRadioValue: function(component, event, helper) {
        debugger;
        var value_scx = false;
        var value_pilot = false;        
        var oppId = component.get('v.OppId');
        var recordTypeInventory = component.get('v.var_RT');
        value_pilot = component.get('v.value_pilot');
        value_scx = component.get('v.value_scx');
        if (!value_scx && !value_pilot) {
            component.set("v.showMessage", true);

        } else {
            component.set("v.showMessage", false);
            var isSCX = value_scx ? true : false;
            window.location.href = '/apex/CreateShowSeekerProposal?OppId=' + oppId + '&recType=' + recordTypeInventory + '&isSCX='+isSCX; //  SRSF-4166 : Added on 22-03-2023
            /* SRSF-4166 : Commented below code : 22-03-2023
            if (value_scx) {
                // SRSF-1762 Code Starts here
                //window.location.href = '/apex/ProposalSCXUpload?OppId=' + oppId + '&recType=' + recordTypeInventory + '&isPolitical=false';
                window.location.href = '/apex/ConfirmToSaveAccountsInTim?OppId=' + oppId + '&recType=' + recordTypeInventory + '&isPolitical=false'; 
                // SRSF-1762 Code Ends here
            }
            if (value_pilot) {
                
                //  var url = "/apex/ProposalTIMCreate";
                // var urlEvent = $A.get("e.force:navigateToURL");
                //      urlEvent.setParams({
                //        "url": url+oppId,
                //        "Id" : oppId,
                //        //+"&invRT="+recordTypeInventory"id": oppId,
                //        "invRT" : recordTypeInventory,
                //        "isredirect": "true"
                //      });
                //      urlEvent.fire();
                // SRSF-1762 Code Starts here
               // window.location.href = '/apex/ProposalTIMCreate?Id=' + oppId + '&recType=' + recordTypeInventory;           
               window.location.href = '/apex/ConfirmToSaveAccountsInTim?oppId=' + oppId + '&recType=' + recordTypeInventory + '&isCTP=true';                 
                //SRSF-1762 Code Ends here
            }*/
        }
    },
    closeModal: function(component, event, helper) {
        debugger;
        var oppId = component.get('v.OppId');
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": oppId,
            "isredirect": "true"
        });
        navEvt.fire();
        // $('#modal').removeClass('slds-fade-in-open');
        // $('#backdrop').removeClass('slds-backdrop--open');
        // window.location.href = '/'+oppId;
    },

    showSpinner: function(component, event, helper) {
        component.set("v.IsSpinner", true);
    },

    hideSpinner: function(component, event, helper) {

        component.set("v.IsSpinner", false);

    },
    waiting: function(component, event, helper) {
        document.getElementById("Accspinner").style.display = "block";
    },

    doneWaiting: function(component, event, helper) {
        document.getElementById("Accspinner").style.display = "none";
    },
})