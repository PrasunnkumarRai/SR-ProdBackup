({
    doInit: function(component, event, helper) {
        component.set("v.sortDesc", true);
        component.set("v.sortByField", 'Probability');
        component.set("v.sortByFieldHumanReadable", 'Probability');
        helper.performInitialization(component, event, false);
    },
    refresh:  function(component, event, helper) {
        helper.refresh(component, event);
    },

    handleOpptyFieldChange : function(component, event, helper) {
        helper.handleOpptyFieldChange(component, event);
    },
    handleSelectChangeEvent : function(component, event, helper) {
        var selectedVals = event.getParam("values");
        //console.log('in event helper... ' + selectedVals + "!"+selectedVals.join(", ")+"!!");
        component.set("v.filterValue",selectedVals.join("+"));

    },

    handleEditSelect : function(component, event, helper) {
        var opptyId = event.getParam("value");
        var menuItem = event.detail.menuItem.get("v.label");
        //console.log('menuItem = ' + menuItem);
        //console.log('$$$$$$$$$$$$$$$--->> in handleEditSelect, opportunity Id= ' + event.getParam("value"));
        if (menuItem == 'Edit') {
            helper.editOpportunity(component, event, opptyId);
        } else if (menuItem == 'Opportunity Budget') {

            var recAccessMap = component.get("v.recAccessMap");
            //console.log('-------->> user has edit access = ' + recAccessMap[opptyId]);
            var budgetAccess = component.get("v.budgetAccessList");
            var onOpptyTeam = false;
            if (budgetAccess !== 'undefined') {
                onOpptyTeam = (budgetAccess.indexOf(opptyId) > -1) ? true : false;
            }

            if (recAccessMap[opptyId] == false || onOpptyTeam == false) {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "type" : "error",
                    "title": "Error Loading Opportunity Budgets",
                    "mode" : "sticky",
                    "message": "You are currently not on the Opportunity team for this Opportunity. You do not have access to create or edit Opportunity Budgets."
                });
                toastEvent.fire();
            } else {
                helper.goToOpptyBudget(component, event, opptyId);
            }          
        }
    },

    saveFilterRename : function(component, event, helper) {
        //console.log('****** in saveFilter ******');
        var filterName = component.get('v.selectedListView');
        var filterNameOld = component.get('v.selectedListViewOld');
        //console.log('********* filterrename = ' + filterName);
        
        var cmpTarget = component.find('Modalbox');
        var cmpBack = component.find('Modalbackdrop');
        $A.util.removeClass(cmpBack,'slds-backdrop--open');
        $A.util.removeClass(cmpTarget, 'slds-fade-in-open'); 

        helper.saveFilter(component, event, filterNameOld, false, false, filterName, false);

    },

    saveSharingSettings : function(component, event, helper) {
        //console.log('****** in saveSharingSettings ******');
        var listView = component.get('v.selectedListView');
        
        var cmpTarget = component.find('SharingModalbox');
        var cmpBack = component.find('SharingModalbackdrop');
        $A.util.removeClass(cmpBack,'slds-backdrop--open');
        $A.util.removeClass(cmpTarget, 'slds-fade-in-open'); 

        helper.saveFilter(component, event, listView , false, false, null, true);

    },

    saveFilter : function(component, event, helper) {
        //console.log('****** in saveFilter ******');
        var filterName = component.get('v.selectedListView');
        //console.log('********* filterName = ' + filterName);
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": "Saving filter...",
            "message": " ",
            "duration": 2000
        });
        toastEvent.fire();

        helper.saveFilter(component, event, filterName, false, false);
     //   helper.closeModalBox(component, event);
        var cmpTarget = component.find('Modalbox');
        var cmpBack = component.find('Modalbackdrop');
        $A.util.removeClass(cmpBack,'slds-backdrop--open');
        $A.util.removeClass(cmpTarget, 'slds-fade-in-open'); 
    },

    saveNewFilter : function(component, event, helper) {
        //console.log('****** in saveNewFilter ******');
        var filterName = component.get('v.newFilterName');
        //console.log('********* filterName = ' + filterName);
        //console.log('********* TIMING saveNewFilter START');
        helper.saveFilter(component, event, filterName, true, false);
        //console.log('********* TIMING saveNewFilter END');
        var cmpTarget = component.find('ModalboxNew');
        var cmpBack = component.find('ModalbackdropNew');
        $A.util.removeClass(cmpBack,'slds-backdrop--open');
        $A.util.removeClass(cmpTarget, 'slds-fade-in-open'); 
    },

    closeNewFilter : function(component, event, helper) {
        //helper.saveFilter(component, event, filterName, true, false);
        var cmpTarget = component.find('ModalboxNew');
        var cmpBack = component.find('ModalbackdropNew');
        $A.util.removeClass(cmpBack,'slds-backdrop--open');
        $A.util.removeClass(cmpTarget, 'slds-fade-in-open'); 
    },

    applySort : function(component, event, helper) {
        //console.log('****** in applySort ******');
        var fField = component.find("sortField").get("v.value");
        //console.log('********* fField = ' + fField);
        var sortField = fField.split(';')[0];
        var sortFieldReadable = fField.split(';')[2];
        //console.log('********* sortField = ' + sortField);
        //console.log('********* sortFieldReadable = ' + sortFieldReadable);
        component.set("v.sortByField", sortField);
        component.set("v.sortByFieldHumanReadable", sortFieldReadable);
        helper.doApplySort(component, event);

        var cmpTarget = component.find('ModalboxSort');
        var cmpBack = component.find('ModalbackdropSort');
        $A.util.removeClass(cmpBack,'slds-backdrop--open');
        $A.util.removeClass(cmpTarget, 'slds-fade-in-open'); 
    },

    applyDelete : function(component, event, helper) {
        //console.log('****** in applyDelete ******');

        helper.doApplyDelete(component, event);

        var cmpTarget = component.find('ModalboxDelete');
        var cmpBack = component.find('ModalbackdropDelete');
        $A.util.removeClass(cmpBack,'slds-backdrop--open');
        $A.util.removeClass(cmpTarget, 'slds-fade-in-open'); 
    },

    lossReasonSelected : function(component, event, helper) {
        //console.log('****** in lossReasonSelected ******');
        var newLossReason = component.find('lossReason').get("v.value");
        //console.log('============>> newLossReason selected = ' + newLossReason);
        // close dialog
        var cmpTarget = component.find('ModalboxLossReason');
        var cmpBack = component.find('ModalbackdropLossReason');
        $A.util.removeClass(cmpBack,'slds-backdrop--open');
        $A.util.removeClass(cmpTarget, 'slds-fade-in-open'); 

        if (newLossReason == '--None--') {
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "type" : "error",
                "title": "Loss Reason Required",
                "mode" : "sticky",
                "message": "You must enter a Loss Reason to move this Opportunity to Close Lost"
            });
            toastEvent.fire();
        } else {
            var tar = component.get("v.dropTarget");
            var fromStage = component.get("v.fromStage");
            var toStage = component.get("v.toStage");
            var oppId = component.get("v.droppedOppId");
            helper.handleDrop(component, oppId, fromStage, toStage, tar, newLossReason);
        }
    },

    toggleSortOrder : function(component, event, helper) {
        var sortDescCmp = component.find("v.sortDesc");
        var sortDesc = component.get("v.sortDesc");
        if (sortDesc === 'undefined' || sortDesc == true) {
            component.set("v.sortDesc", false);
            event.getSource().set('v.iconName', 'utility:up');
        } else {
            component.set("v.sortDesc", true);
            event.getSource().set('v.iconName', 'utility:down');
        }
        helper.changeListView(component, event, component.get("v.selectedListView"));
    },


    saveClonedFilter : function(component, event, helper) {
        //console.log('****** in saveClonedFilter ******');
        var newFilterName = component.get('v.clonedListView');
        //console.log('********* newFilterName = ' + newFilterName);
        var currentFilter = component.get('v.selectedListView');
        //console.log('********* currentFilter = ' + currentFilter);
        helper.saveFilter(component, event, currentFilter, false, true, newFilterName, false);
  ///      helper.saveFilter(component, event, filterName, false, true, filterName);
        var cmpTarget = component.find('ModalboxClone');
        var cmpBack = component.find('ModalbackdropClone');
        $A.util.removeClass(cmpBack,'slds-backdrop--open');
        $A.util.removeClass(cmpTarget, 'slds-fade-in-open'); 
    },

    openModal : function(component, event, helper) {
        var cmpTarget = component.find('Modalbox');
        var cmpBack = component.find('Modalbackdrop');

        $A.util.addClass(cmpTarget, 'slds-fade-in-open');
        $A.util.addClass(cmpBack, 'slds-backdrop--open');
    },

    handleFilterSettings : function(component, event, helper) {
        var selectedMenuItemValue = event.getParam("value");
        //console.log('in handleFilterSettings, value = ' + selectedMenuItemValue);
        if(selectedMenuItemValue == "new") {
            helper.newFilter(component, event);
        }
        else if(selectedMenuItemValue == "rename") {
            var cmpTarget = component.find('Modalbox');
            var cmpBack = component.find('Modalbackdrop');
            component.set('v.selectedListViewOld', component.get('v.selectedListView'));
            //console.log('Old=='+component.get('v.selectedListViewOld'));
            //console.log('=='+component.get('v.selectedListView'));
            $A.util.addClass(cmpTarget, 'slds-fade-in-open');
            $A.util.addClass(cmpBack, 'slds-backdrop--open');
        }
        else if(selectedMenuItemValue == "clone") {
            component.set("v.filterAudience", 'Me');
            var cmpTarget = component.find('ModalboxClone');
            var cmpBack = component.find('ModalbackdropClone');
        //    component.set('v.selectedListViewOld', component.get('v.selectedListView'));
        //    //console.log('Old=='+component.get('v.selectedListViewOld'));
        //    //console.log('=='+component.get('v.selectedListView'));
            $A.util.addClass(cmpTarget, 'slds-fade-in-open');
            $A.util.addClass(cmpBack, 'slds-backdrop--open');
        }
        else if(selectedMenuItemValue == "sort") {
            var cmpTarget = component.find('ModalboxSort');
            var cmpBack = component.find('ModalbackdropSort');
            $A.util.addClass(cmpTarget, 'slds-fade-in-open');
            $A.util.addClass(cmpBack, 'slds-backdrop--open');
        }
        else if(selectedMenuItemValue == "delete") {
            var cmpTarget = component.find('ModalboxDelete');
            var cmpBack = component.find('ModalbackdropDelete');
            $A.util.addClass(cmpTarget, 'slds-fade-in-open');
            $A.util.addClass(cmpBack, 'slds-backdrop--open');
        }
        else if(selectedMenuItemValue == "sharing") {
            var cmpTarget = component.find('SharingModalbox');
            var cmpBack = component.find('SharingModalbackdrop');
            $A.util.addClass(cmpTarget, 'slds-fade-in-open');
            $A.util.addClass(cmpBack, 'slds-backdrop--open');
        }
    },
    newFilter : function(component, event, helper) {
        helper.newFilter(component, event);
    },

    closeSharingSettings:function(component,event,helper){    
        //console.log('****** in closeSharingSettings ******');
        var cmpTarget = component.find('SharingModalbox');
        var cmpBack = component.find('SharingModalbackdrop');
        $A.util.removeClass(cmpBack,'slds-backdrop--open');
        $A.util.removeClass(cmpTarget, 'slds-fade-in-open'); 
    },

    closeModal:function(component,event,helper){    
        //console.log('****** in closeModal ******');
        var cmpTarget = component.find('Modalbox');
        var cmpBack = component.find('Modalbackdrop');
        $A.util.removeClass(cmpBack,'slds-backdrop--open');
        $A.util.removeClass(cmpTarget, 'slds-fade-in-open'); 
    },

    closeModalClone : function(component,event,helper){    
        //console.log('****** in closeModalClone ******');
        var cmpTarget = component.find('ModalboxClone');
        var cmpBack = component.find('ModalbackdropClone');
        $A.util.removeClass(cmpBack,'slds-backdrop--open');
        $A.util.removeClass(cmpTarget, 'slds-fade-in-open'); 
    },

    closeModalSort : function(component,event,helper){    
        //console.log('****** in closeModalSort ******');
        var cmpTarget = component.find('ModalboxSort');
        var cmpBack = component.find('ModalbackdropSort');
        $A.util.removeClass(cmpBack,'slds-backdrop--open');
        $A.util.removeClass(cmpTarget, 'slds-fade-in-open'); 
    },

    closeModalDelete : function(component,event,helper){    
        //console.log('****** in closeModalDelete ******');
        var cmpTarget = component.find('ModalboxDelete');
        var cmpBack = component.find('ModalbackdropDelete');
        $A.util.removeClass(cmpBack,'slds-backdrop--open');
        $A.util.removeClass(cmpTarget, 'slds-fade-in-open'); 
    },

    closeModalLossReason : function(component,event,helper){    
        //console.log('****** in closeModalLossReason ******');
        var cmpTarget = component.find('ModalboxLossReason');
        var cmpBack = component.find('ModalbackdropLossReason');
        $A.util.removeClass(cmpBack,'slds-backdrop--open');
        $A.util.removeClass(cmpTarget, 'slds-fade-in-open'); 
    },

    doView: function(component, event, helper) {
        //alert("doView--");
        var editRecordEvent = $A.get("e.force:navigateToSObject");
        //console.log('$$$$$$$$$$$$$$$--->> event.target.id = ' + event.target.id);
        //console.log(event);
        editRecordEvent.setParams({
            "recordId": event.target.id,
            "slideDevName": "related" 
        });
        editRecordEvent.fire();
        /*window.open('/' + event.target.id);
        var device = '';
        device = $A.get("$Browser.formFactor");
        
        if(device == "DESKTOP"){
        	window.open('/lightning/r/Opportunity/' + event.target.id+'/view','_blank');
        }else{
            var navEvt = $A.get("e.force:navigateToSObject");
            navEvt.setParams({
                "recordId": event.target.id,
                "slideDevName": "related"
        	});
        	navEvt.fire();
        }*/
    },

    doView1: function(component, event, helper) {
        //alert("doView1---");
        var editRecordEvent = $A.get("e.force:navigateToSObject");
        var curTarget = event.currentTarget;
        var objectId = curTarget.dataset.value;
        //console.log('$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$--->> objectId = ' + objectId);
        //console.log(event);
        editRecordEvent.setParams({
            "recordId": objectId,
            "slideDevName": "related"
        });
        //editRecordEvent.fire();
        
        //window.open('/' + objectId);
        var device = '';
        device = $A.get("$Browser.formFactor");
        
        if(device == "DESKTOP"){
        	window.open('/lightning/r/Opportunity/' + objectId+'/view','_blank');
        }else{
            var navEvt = $A.get("e.force:navigateToSObject");
            navEvt.setParams({
                "recordId": objectId,
                "slideDevName": "related"
        	});
        	navEvt.fire();
        }
    },

    allowDrop: function(component, event, helper) {
        event.preventDefault();
    },
    
    drag: function (component, event, helper) {
        var tar = event.target;
        var fromStage = '';
        //console.log('------------->> in drag, event.target:');
        //console.log(event.target);
        //console.log('------------->> in drag, event.target.dataset:');
        //console.log(event.target.dataset);
        //console.log('------------------->> in drag, stage(this is the from stage supposedly) = ' + event.target.dataset.item);

        //console.log('$$$$$$$$$$$$$$----->> event.target.id = ' + event.target.id);
        var opptyId = event.target.id;

        var liElem = document.getElementById(opptyId);
        //console.log('$$$$$$$$$$$$$$$$$$$----->> <li> element:');
        //console.log(liElem);
        if (liElem != null) {
            fromStage = liElem.dataset.item;
        }
    //console.log('$$$$$$$$$$$$$$$$$$$----->> fromStage = ' + fromStage);


        event.dataTransfer.setData("text", event.target.id + ';;;' + fromStage);
      //  event.dataTransfer.setData("fromStage", event.target.dataset.item);
    //console.log('$$$$$$$$$$$$$$$$$$$----->> after SetData call #1');
        //event.dataTransfer.setAttribute("fromStage", fromStage);
    //console.log('$$$$$$$$$$$$$$$$$$$----->> after SetData call #2');
    },
    
    drop: function (component, event, helper) {

        var dataFull = event.dataTransfer.getData("text");
        //console.log('-------------->> dataFull = ' + dataFull);
        var data = dataFull.split(';;;')[0];
        //console.log('-------------->> data = ' + data);
        var fromStage = dataFull.split(';;;')[1];
        //console.log('-------------->> fromStage = ' + fromStage);
        if(fromStage =='undefined') {
            //console.log("!!!! IN DROP: drag+drop not allowed! returning...");
            alert("Warning: please use the whitespace in the card to drag it to another Stage.");
            return;
        }

        var recAccessMap = component.get("v.recAccessMap");
        //console.log('-------->> user has edit access = ' + recAccessMap[data]);

        if (recAccessMap[data] == false) {
            alert("You are currently not on the Opportunity team for this Opportunity. You do not have access to edit this record.");
            return;
        }
        event.preventDefault();
        //var fromStage = event.dataTransfer.getAttribute("fromStage");
        var tar = event.target;
        //console.log('-------------->> tar:' );
        //console.log(tar);
        //console.log('-------------->> event:' + event);
        var toStage = tar.getAttribute('data-Pick-Val');
        if (fromStage == toStage)
            return;
        //console.log('-------------->> toStage = ' + toStage);

        var okToMoveOppty = true;
        var newLossReason;
        if (toStage == 'Closed Lost') {
            var kbData = component.get('v.kanbanData');
            //console.log('=========>> kbData:');
            //console.log(kbData);
            //console.log('=========>> kbData.records:');
            //console.log(kbData.records);
            //console.log('kbData.records.length = ' + kbData.records.length);
            //console.log('=================================================');
            for (var i = 0; i < kbData.records.length; i++) {
                //console.log('****************  Loss Reason = ' + kbData.records[i]['Loss_Reason__c']);
                if (kbData.records[i]['Id'] == data) {
                    //console.log('--------_>> found Record!  Id = ' + data);
                    if (kbData.records[i]['Loss_Reason__c']) {
                        //console.log('----->> found loss reason! --> ' + kbData.records[i]['Loss_Reason__c']);
                    } else {
                        okToMoveOppty = false;
                        component.set("v.dropTarget", tar);
                        component.set("v.fromStage", fromStage);
                        component.set("v.toStage", toStage);
                        component.set("v.droppedOppId", data);
                        //console.log('opening loss reason modal...');
                        var cmpTarget = component.find('ModalboxLossReason');
                        var cmpBack = component.find('ModalbackdropSort');
                        $A.util.addClass(cmpTarget, 'slds-fade-in-open');
                        $A.util.addClass(cmpBack, 'slds-backdrop--open');
                    }

                    /*
                    Object.keys(kbData.records[1]).forEach(function(key) {
                        //console.log('key = ' + key);
                        //console.log('value = ' + kbData.records[i][key]);
                        if (kbData.records[i][key] == 'Loss_Reason__c') {

                        }
                    }); */                
                }
            }            
        }
        if (okToMoveOppty) {
            /*
            while(tar.tagName != 'ul' && tar.tagName != 'UL')
            tar = tar.parentElement;
            tar.appendChild(document.getElementById(data));
            document.getElementById(data).style.backgroundColor = "#ffb75d";
            */
            helper.handleDrop(component, data, fromStage, toStage, tar, newLossReason);            
        }

    },

    showNewFilterPanel : function(component, event, helper) {

    },


    showFilterPanel : function(component, event, helper) {
        helper.showFilterPanel(component, event);
    },

    removeFilterRule : function(component, event, helper) {
        //console.log('--->> remove rule #'+event.getSource().getLocalId().slice(-1));
        var ruleNum = parseInt(event.getSource().getLocalId().slice(-1));
        helper.removeFilterRule(component, event, ruleNum);
    },
    clearFilters : function(component, event, helper) {
        helper.removeFilterRule(component, event, 1);
        helper.removeFilterRule(component, event, 2);
        helper.removeFilterRule(component, event, 3);
    },

    showWhichOpptiesWindow : function(component, event, helper) {
        helper.showWhichOpptiesWindow(component, event);
    },

    showFilterWindow : function(component, event, helper) {
        helper.showFilterWindow(component, event, event.currentTarget.getAttribute("id") != null ? event.currentTarget.getAttribute("id").slice(-1) : null, true);
    },

    cancelFilterWindow : function(component, event, helper) {
        helper.showFilterWindow(component, event, event.currentTarget.getAttribute("id") != null ? event.currentTarget.getAttribute("id").slice(-1) : null, false);
    },

    setVisibility : function(component, event, helper) {
        component.set("v.filterAudience", event.getSource().get("v.value"));
        //console.log('Value radio vis changed -----> '+ event.getSource().get("v.value"));
    },
    setSharingSettings : function(component, event, helper) {
        component.set("v.filterAudience", event.getSource().get("v.value"));
        //console.log('Value radio vis changed -----> '+ event.getSource().get("v.value"));
    },
    setWhichOppties : function(component, event, helper) {
        component.set("v.selectedWhichOppties", event.getSource().get("v.value"));
        //console.log('Value radio which oppties changed -----> '+ event.getSource().get("v.value"));
        var editor0 = component.find("editor0");
        if(!$A.util.hasClass(editor0,'edited'))
                $A.util.addClass(editor0,'edited');
    },
    showFilterMenuItems : function(component, event, helper) {
        helper.showFilterMenuItems(component, event);
    },
    closeFilterMenuItems : function(component, event, helper) {
        helper.closeFilterMenuItems(component, event);
    },
    menuMouseEnter : function(component, event, helper) {
        component.set("v.isMenuMouseIn", "1");
        //console.log('********* event:');
        //console.log(event);
        
    },
    menuMouseOut : function(component, event, helper) {
        component.set("v.isMenuMouseIn", "0");
    },
    closeFilterMenuItemsConditional : function(component, event, helper) {
        var isInMenu = component.get("v.isMenuMouseIn");
        //console.log("isMenuMouseIn? " + isInMenu);
        if(isInMenu != "1")
            helper.closeFilterMenuItems(component, event);
    },
    settingsMenuFocus : function(component, event, helper) {
        helper.showOrHideSaveButton(component, event);
    },
    handleListView : function(component, event, helper) {
//        var selectedMenuItemValue = event.getParam("value");
     ////   var selectedMenuItemValue = (event.target.id =="" || event.target.id ==null ? event.target.parentElement.id: event.target.id);
  //    //console.log('=========>> selected item value = ' + event.getParam("value"));
   //   //console.log('=========>> selected item label = ' + event.detail.menuItem.get("v.label"));

      


        //console.log('6:');
        if(event == null) {
            return;
        }
        else {
            //console.log(event);
        }
        try {
            //debugger;
            //console.log(event.target);
        }
        catch(error) {
          //console.log(error);
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                type: 'warning',
                duration : 10000,
                message: "Error: Please select the text portion of the listview rather than the whitespace before or after the desired listview.  This issue will be resolved soon."
            });
            toastEvent.fire();
            return;
        }
      
      //console.log('---->> event:');
      //console.log(event);


        var selectedMenuItemValue = event.target.getAttribute('id');

        //console.log('!!!!!!!!!!!!!!!!----->> selectedMenuItemValue = ' + selectedMenuItemValue);
        var listViewMap = component.get("v.listViews");
        //console.log('----->> length of listViewMap is ' + listViewMap.length);
        //console.log(listViewMap);

                Object.keys(listViewMap[0]).forEach(function(key) {

                    //console.log('--->> key   = ' + key);
                    //console.log('--->> listViewMap[0][key].Name = ' + listViewMap[0][key].Name);
                    //console.log('--->> listViewMap[0][key].Id = ' + listViewMap[0][key].Id);

                    for (var k in listViewMap[0][key]["Opportunity_Forecasting_Filter_Values__r"]) {
                        //console.log('-------->> k = ' + k);
                        //console.log('-------->> listViewMap[0][key]["Opportunity_Forecasting_Filter_Values__r"][k] = ' + listViewMap[0][key]["Opportunity_Forecasting_Filter_Values__r"][k]);
                        //console.log(listViewMap[0][key]["Opportunity_Forecasting_Filter_Values__r"][k].Id);
                        //console.log(listViewMap[0][key]["Opportunity_Forecasting_Filter_Values__r"][k].API_Name__c);
                        //console.log(listViewMap[0][key]["Opportunity_Forecasting_Filter_Values__r"][k].Field_Data_Type__c);
                        //console.log(listViewMap[0][key]["Opportunity_Forecasting_Filter_Values__r"][k].Field_Name__c);
                        //console.log(listViewMap[0][key]["Opportunity_Forecasting_Filter_Values__r"][k].Operator__c);
                        //console.log(listViewMap[0][key]["Opportunity_Forecasting_Filter_Values__r"][k].Opportunity_Scope__c);
                        //console.log(listViewMap[0][key]["Opportunity_Forecasting_Filter_Values__r"][k].Value__c);
                    }



                });

        component.set("v.selectedListView", listViewMap[0][selectedMenuItemValue].Name);
        component.set("v.selectedListViewId", selectedMenuItemValue);
        helper.showOrHideSaveButton(component, event);
        helper.changeListView(component, event, selectedMenuItemValue); 
      helper.closeFilterMenuItems(component, event);
      },
    
      onAccOppSearch : function(component, event, helper) {
          //alert("Coming..");
      	  helper.performInitialization(component, event, false,component.get('v.selectedListView'));
	  },


})