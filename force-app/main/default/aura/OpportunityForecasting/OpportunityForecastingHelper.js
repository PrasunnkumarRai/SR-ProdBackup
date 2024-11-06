({
    // User clicked the refresh button (GUI refresh button, not the browser refresh button)
    refresh:  function(component, event) {
        var currentListViewName = component.get('v.selectedListView');
        var listView = '';
        var listViewMap = component.get("v.listViews");

        Object.keys(listViewMap[0]).forEach(function(key) {
            //console.log('%%%%% key = ' + key);
            if (listViewMap[0][key].Name == currentListViewName) {

                listView = key;
            }       
        });

        if (listView != '') {
            //console.log('THISISIT! '+ listView);
            this.changeListView(component, event, listView);

        }
        else {
            //console.log('Blank List View');

        }
        /*
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": "Refreshing...",
            "message": " "
        });
        toastEvent.fire();
        var refreshBackdrop = component.find("refreshBackdrop");
        $A.util.addClass(refreshBackdrop,'slds-backdrop_open');
        //var refreshBackdropIcon = component.find("refreshBackdropIcon");
        //$A.util.removeClass(refreshBackdropIcon,'refreshIcon_hide');
        helper.performInitialization(component, event, true);
        */
    },
    showFilterMenuItems : function(component, event) {
        var menu = component.find("topLevelDropdown");
        if(!$A.util.hasClass(menu,'slds-is-open'))
                $A.util.addClass(menu,'slds-is-open');
        else
                $A.util.removeClass(menu,'slds-is-open');

    },
    closeFilterMenuItems : function(component, event) {
        var menu = component.find("topLevelDropdown");
        if($A.util.hasClass(menu,'slds-is-open'))
                $A.util.removeClass(menu,'slds-is-open');

    },
    setStageContainerHeight : function(component, event) {
        // each card: 177.73px (178) tall -- make height
        var opptyStages = component.get('v.opptyCountByStage');
        var cardHeight = 186;
        var max = 0;
        for(var i = 0; i < opptyStages.length; i++) {
            var curHeight = (parseInt(opptyStages[i].count)+1)*cardHeight;
            max = (curHeight > max ? curHeight : max);
            //console.log("Stage " + i + ": cur="+curHeight+" , max="+max + " (cardHeight="+cardHeight+"px)");
        }
        component.set("v.stageContainerHeight"," height: "+max+"px;");
    },
    setListViewId : function(component, event, lvName) {
        var listViewMap = component.get("v.userListViews");
            //console.log('setListViewId: START!');
        if(listViewMap==null)
            return;
        Object.keys(listViewMap).forEach(function(key) {
            //console.log('setListViewId: '+key+',v='+listViewMap[key].value+','+listViewMap[key].Id);
            if(listViewMap[key].value == lvName) {
                component.set("v.selectedListViewId", listViewMap[key].Id);
                //console.log("Setting v.selectedListViewId to: " +  listViewMap[key].Id);
            }
        });

    },

    performInitialization : function(component, event, showRefreshMessage, listViewName) {

        //console.log('********* TIMING saveNew Helper performInitialization START');
        if(!showRefreshMessage) {
            var msgRefreshTitle = "Opportunity Pipeline is loading...";
            var msgRefresh = " ";
            var refreshBackdropTop = component.find("refreshBackdrop");''
            $A.util.addClass(refreshBackdropTop,'slds-backdrop_open');

            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": msgRefreshTitle,
                "message": msgRefresh
            });
            toastEvent.fire();
        }

// **** John King added 2020-03-16  -- START
        var actionIsMobile = component.get("c.isMobile");
        actionIsMobile.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                //console.log("Is mobile? "+ response.getReturnValue());
                if(response.getReturnValue()) {
                    var r = confirm("It appears you are on a mobile device. Return to previous page?");
                    if (r == true) {
                        window.history.go(-1);
                    } else {
                        //console.log("Continue to pipeline");
                    }
                }
            }
        });
        $A.enqueueAction(actionIsMobile);
// **** John King added 2020-03-16  -- END


        var actionLV = component.get("c.getOpptyListViews");
        actionLV.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var listViews = response.getReturnValue();
                console.log('--------->> in getListViews, retVal = ');
                console.log("listViews", listViews);
                var listViewList = component.get("v.listViews");
                console.log("listViewList",listViewList);
                var userLVs = [];
                var lName;
                var listViewIdTemp = "";
                var listViewId = "";
                Object.keys(listViews).forEach(function(key) {
                    lName = listViews[key].Name;
                    userLVs.push( {Id : key, value : lName});
                    if(lName == "My Opportunities")
                        listViewIdTemp = key;
                    if(lName == listViewName)
                        listViewId = key;
                });
                if(listViewId == "") {
                    listViewName = "My Opportunities";
                    listViewId = listViewIdTemp;
                }
                component.set("v.selectedListViewId", listViewId);
                component.set("v.selectedListView", listViewName);
                component.set("v.userListViews", userLVs);
                component.set("v.listViews", listViews);
                //console.log("Selected LV ID! " + listViewId);
                //console.log("Selected LV! " + listViewName);

                this.showOrHideSaveButton(component, event);


                component.set("v.refreshAge", 'Updated a few seconds ago');
                component.set("v.lastRefreshDateTime", this.getCurrentTime());
                this.lastRefreshTimer(component);
                component.set("v.kanbanPicklistField", "StageName");
                //console.log('==============>> objFields = ' + component.get("v.objFields"));
                var taskToolTipHTML = this.getTaskToolTipHTML(component);
                component.set("v.takeActionHTML", taskToolTipHTML);
               

                var selectedWhichOppties = component.get("v.selectedWhichOppties");
                //console.log('======>> selectedWhichOppties = ' + selectedWhichOppties);

                //check the current value of isUerAdmin -- if null, then need to make the call; otherwise don't call again
                var isUserAdmin = component.get("v.isUserAdmin");
                if (isUserAdmin == null) {
                    var actionAdmin = component.get("c.isCurrentUserAdmin");
                    //console.log('********* TIMING saveNew Helper performInitialization isAdmin? START');
                    actionAdmin.setCallback(this, function(response2){
                        //console.log("isUserAdmin ---------------->> " + response2.getReturnValue());
                        component.set("v.isUserAdmin", response2.getReturnValue());
                        //console.log('********* TIMING saveNew Helper performInitialization isAdmin? END');
                    });
                    //console.log("calling: isUserAdmin ----------------?? ");
                    $A.enqueueAction(actionAdmin);
                }

				//alert(component.get("v.accOppName"));
                var action = component.get("c.changeCurrentListView");
                action.setParams({
                    "objName":component.get("v.objName"),
                    "objFields":component.get("v.objFields"),
                    "kanbanField":component.get("v.kanbanPicklistField"),
                    "showOnlyMyOpportunities":!(component.get("v.selectedWhichOppties").split(" ")[0] == "All"),
                    "listViewId":listViewId,
                    "checkListViewCache":!showRefreshMessage,
                     "sortBy" : component.get("v.sortByField"),
                   "isSortDesc" : component.get("v.sortDesc"),
                    "nameFilter" : component.get("v.accOppName")
                });
                action.setCallback(this, function(response){
                    var state2 = response.getState();
                    console.log('===========>> state2 = ' + state2); 
                    if (state2 == "SUCCESS") {
                        var retVal = response.getReturnValue();
                        console.log("retVal", retVal);
                        if(retVal.listViewName != listViewName)
                            listViewName = retVal.listViewName;
                        console.log('=============>> Stinking return value = ' , retVal);
                        console.dir(retVal);

                        this.processKanbanResponse(component, event, retVal);

                        var msgRefreshTitle = "Refresh Complete";
                        var msgRefresh = "Opportunity Pipeline has been refreshed.";

                        if(!showRefreshMessage) {
                            var msgRefreshTitle = "Loading Complete";
                            var msgRefresh = "Opportunity Pipeline has been loaded.";
                        }
                        var refreshBackdrop = component.find("refreshBackdrop");
                        $A.util.removeClass(refreshBackdrop,'slds-backdrop_open');
        //                    var refreshBackdropIcon = component.find("refreshBackdropIcon");
        //                    $A.util.addClass(refreshBackdropIcon,'refreshIcon_hide');

                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "title": msgRefreshTitle,
                            "message": msgRefresh
                        });
                        toastEvent.fire();

                        if(listViewName != null){
                            component.set("v.selectedListView", listViewName);
                            this.setListViewId(component, event, listViewName);
                            //console.log('The listView is TIMING: ' + listViewName);
                            //console.log('The listView ID is TIMING: ' + component.get("v.selectedListViewId"));
                            this.showOrHideSaveButton(component, event);
                            
        //                    this.refresh(component, event);
                        }


                        //console.log('********* TIMING saveNew Helper performInitialization Refresh END');
                    }
				// SRSF-1282 start
				else if(state2=="ERROR") {
				    //console.log("********* Error processing before in performInitialization");
				   	var errors = response.getError();
					var message = '*********Unknown error in performInitialization'; // Default error message
					if (errors && Array.isArray(errors) && errors.length > 0) {
						message = errors[0].message;
						console.error(message);
			    		//console.log("********* after error in performInitialization");
					}

				}
				// SRSF-1282 end
                });
                /* CRA //console.log('********* TIMING saveNew Helper performInitialization Refresh START');
                //console.log(            "TIMING ?????????????? objName=" + component.get("v.objName")+
                    "  objFields="+component.get("v.objFields")+
                    "  kanbanField="+component.get("v.kanbanPicklistField")+
                    "  listViewId??="+listViewId);*/
                $A.enqueueAction(action);


            }
        });
        $A.enqueueAction(actionLV);


        //this.getListViews(component, event);
//         component.set("v.selectedListView", "My Opportunities")
    },

    // doesn't appear to be used - commenting out for now
    /*
    getFilterableFields : function(component, event) {
        //console.log('in getFilterableFields!');
        var action = component.get("c.getOpptyFields");
        //console.log('after call to component get getOpptyFields');
        action.setCallback(this, function(response) {
            //console.log('!@@@@@@@@@@@@ in callback!!!!!!');
            var state = response.getState();
            //console.log('===========---+++===>> state =' + state);
            if (state === "SUCCESS") {
                var retVal = response.getReturnValue();
                //console.log('=======>> in getFilterableFields, retVal:');
                //console.log(retVal);
                component.set("v.opptyFields", retVal);
            }
        });
        $A.enqueueAction(action);
    }, 
*/

    saveFilter : function(component, event, filterName, isNew, isClone, filterNameChanged, isUpdatedSharingSettings) {
        //console.log('-------->> in saveFilter in helper, filterName = ' + filterName);
        var action = component.get("c.saveFilterData");
        //console.log('rule1Field = ' + component.get("v.rule1Field"));
        //console.log('rule2Field = ' + component.get("v.rule2Field"));
        //console.log('visibility = ' + (component.get("v.selectedWhichOppties").split(" ")[0] == "My"));
        //console.log('why filtername! ' + filterName + " == "+ filterNameChanged + " ???");

        //console.log('=========+>> filterAudience = ' + component.get("v.filterAudience"));

        action.setParams({
            "filterName"    : filterName,
            "filterChangedName"    : filterNameChanged,
            "isNew"         : isNew,
            "isClone"       : isClone,
            "filterAudience": component.get("v.filterAudience"),
            "showOnlyMyOpportunities" : (component.get("v.selectedWhichOppties").split(" ")[0] == "My"),
            "userList"      : '',
            "apiName1"      : (typeof component.get("v.rule1Field_value")    === 'undefined') ? '' : component.get("v.rule1Field_value"),
            "label1"        : (typeof component.get("v.rule1Field")    === 'undefined') ? '' : component.get("v.rule1Field"),
            "operator1"     : (typeof component.get("v.rule1Operator") === 'undefined') ? '' : component.get("v.rule1Operator"),
            "value1"        : (typeof component.get("v.rule1Value")    === 'undefined') ? '' : component.get("v.rule1Value"),
            "dataType1"     : (typeof component.get("v.rule1Field_type")    === 'undefined') ? '' : component.get("v.rule1Field_type"),
            "apiName2"      : (typeof component.get("v.rule2Field_value")    === 'undefined') ? '' : component.get("v.rule2Field_value"),
            "label2"        : (typeof component.get("v.rule2Field")    === 'undefined') ? '' : component.get("v.rule2Field"),
            "operator2"     : (typeof component.get("v.rule2Operator") === 'undefined') ? '' : component.get("v.rule2Operator"),
            "value2"        : (typeof component.get("v.rule2Value")    === 'undefined') ? '' : component.get("v.rule2Value"),
            "dataType2"     : (typeof component.get("v.rule2Field_type")    === 'undefined') ? '' : component.get("v.rule2Field_type"),
            "apiName3"      : (typeof component.get("v.rule3Field_value")    === 'undefined') ? '' : component.get("v.rule3Field_value"),
            "label3"        : (typeof component.get("v.rule3Field")    === 'undefined') ? '' : component.get("v.rule3Field"),
            "operator3"     : (typeof component.get("v.rule3Operator") === 'undefined') ? '' : component.get("v.rule3Operator"),
            "value3"        : (typeof component.get("v.rule3Value")    === 'undefined') ? '' : component.get("v.rule3Value"),
            "dataType3"     : (typeof component.get("v.rule3Field_type")    === 'undefined') ? '' : component.get("v.rule3Field_type")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            //console.log('response');
            //console.log(response);
            if (state === "SUCCESS") {
                //console.log('********* TIMING saveNew Helper END1');
                // do somethng
                var retVal = response.getReturnValue();
                //console.log('######$$$$%%%% retVal = ');
                //console.log(retVal);
                var toastMessageTitle = "List View '"+filterName+"' saved. Refreshing...";
                var toastMessage = " ";

                if(filterNameChanged != null && filterNameChanged != '' && filterNameChanged != filterName) {
                    toastMessageTitle = "List View '"+filterName+"' renamed to '"+filterNameChanged+"' -- Refreshing...";
                    filterName = filterNameChanged;
                }
                else if(typeof isUpdatedSharingSettings === 'boolean' && isUpdatedSharingSettings === true) {
                    toastMessageTitle = "Updating '"+filterName+"' Sharing Settings...";
                }

                if(retVal.errorMessage != null && retVal.errorMessage.indexOf("ERROR") != -1) {
                    toastMessageTitle = "List View '"+filterName+"' unable to save!";
                    toastMessage = retVal.errorMessage;
                }
                else if(isNew) {
                    component.set("v.selectedListView", filterName);
                    //console.log('********* TIMING saveNew Helper changeListView1');
                    this.changeListView(component, event, filterName);
                    //console.log('********* TIMING saveNew Helper changeListView2');
                    component.set("v.lastRefreshDateTime", this.getCurrentTime());
                    this.updateStatus(component);

                    this.showOrHideSaveButton(component, event);


                    var sharingMenuItem = component.find("sharingMenuItem");
                    var renameMenuItem = component.find("renameMenuItem");
                    //console.log('********* TIMING saveNew Helper performInit1');
                    this.performInitialization(component, event, true, filterName);
                    this.refreshButtonsAndStates(component, event);
                    //console.log('********* TIMING saveNew Helper performInit2');
                    $A.util.removeClass(sharingMenuItem,'hideInit');
                    $A.util.removeClass(renameMenuItem,'hideInit');
                }
                else {
                    this.refreshButtonsAndStates(component, event);
                    toastMessageTitle = "List View '"+filterName+"' has been saved.";
                    //console.log('********* TIMING saveNew Helper performInit3 ' + filterName);
                    this.performInitialization(component, event, true, filterName);
                    //console.log('********* TIMING saveNew Helper performInit4 ' + filterName);
                    $A.util.removeClass(sharingMenuItem,'hideInit');
                    $A.util.removeClass(renameMenuItem,'hideInit');
                }
    
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": toastMessageTitle,
                    "message": toastMessage,
                    "duration": 3000
                });
                toastEvent.fire();
/*                if(isNew) {
                    var cmpListViewMenu = component.find('listViewMenu');

                    $A.createComponent(
                        "lightning:menuItem",
                        {
                            "value": filterName,
                            "label": filterName
                        },
                        function(newButton, status, errorMessage){
                            //Add the new button to the body array
                            if (status === "SUCCESS") {
                                var body = cmpListViewMenu.get("v.body");
                                //console.log("-------------->> cmpListViewMenu");
                                //console.log(body);
                                body.push(newButton);
                                cmpListViewMenu.set("v.body", body);
                                //console.log(cmpListViewMenu);
                                //console.log("Is the new menu item in List View?")
                            }
                            else if (status === "INCOMPLETE") {
                                //console.log("No response from server or client is offline.")
                                // Show offline error
                            }
                            else if (status === "ERROR") {
                                //console.log("Error: " + errorMessage);
                                // Show error message
                            }
                        }
                    );
                    
                }*/
                //console.log('********* TIMING saveNew Helper END2');
            }
            else {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Unable to save List View '"+filterName+"'",
                    "message": "Issue is: "+ (response.getReturnValue() == null ? "No return value" + " ["+JSON.stringify(response)+"]" : response.getReturnValue().errorMessage + " ["+response.getError()+"]")
                });
                toastEvent.fire();

            }
        });
        //console.log('********* TIMING saveNew Helper START');
         $A.enqueueAction(action);
        /*
        var el = document.getElementById("9722:0");
        var selectedField = el.options[el.selectedIndex].value;
        //console.log('-------->> in saveFilter in helper, selected field = ' + selectedField);
        el = document.getElementById("10088:0");
        var operator = el.options[el.selectedIndex].text;
        //console.log('-------->> in saveFilter in helper, operator = ' + operator); */
    },

    newFilter : function(component, event) {
        //console.log('****** in newFilter ******');
        var cmpTarget = component.find('ModalboxNew');
        var cmpBack = component.find('ModalbackdropNew');
        $A.util.addClass(cmpTarget, 'slds-fade-in-open');
        $A.util.addClass(cmpBack, 'slds-backdrop--open');

        var filterPanel = component.find("opptyFilterPanel");
        if($A.util.hasClass(filterPanel,'slds-hide')) {
                this.showFilterPanel(component, event);
        }

    },

    closeModalBox : function(component, event) {

    },


    removeFilterRule : function(component, event, ruleNum) {

        if( (component.get("v.rule" + ruleNum + "Field_type") != "" && component.get("v.rule" + ruleNum + "Field_type") != null)||
            (component.get("v.rule" + ruleNum + "Field_value") != "" && component.get("v.rule" + ruleNum + "Field_value") != null) ||
            (component.get("v.rule" + ruleNum + "Field") != "" && component.get("v.rule" + ruleNum + "Field") != null) ||
            (component.get("v.rule" + ruleNum + "Operator") != "" && component.get("v.rule" + ruleNum + "Operator") != null) ||
            (component.get("v.rule" + ruleNum + "Value") != "" && component.get("v.rule" + ruleNum + "Value") != null))
        {
            var editor = component.find("editor"+ruleNum);
            if(!$A.util.hasClass(editor,'edited'))
                    $A.util.addClass(editor,'edited');
        }

        component.set("v.rule" + ruleNum + "Field_type","");
        component.set("v.rule" + ruleNum + "Field_value","");
        component.set("v.rule" + ruleNum + "Field","");
        component.set("v.rule" + ruleNum + "Operator","");
        component.set("v.rule" + ruleNum + "Value","");



    },

    handleDrop : function(component, recId, fromStage, toStage, tar, lossReason) {
        //console.log('========>> recId = ' + recId);
        //console.log('========>> fromStage = ' + fromStage);
        //console.log('========>> toStage = ' + toStage);
        while(tar.tagName != 'ul' && tar.tagName != 'UL')
            tar = tar.parentElement;
  // bab p3      tar.appendChild(document.getElementById(recId));
        document.getElementById(recId).style.backgroundColor = "#ffb75d";

        var opptyCountByStage = component.get("v.opptyCountByStage");
        //console.log('=========>> opptyCountByStage:');
        //console.log(opptyCountByStage);
        this.updateStageCounts(component, fromStage, toStage, opptyCountByStage);

        var opptyTotalsByStage = component.get("v.pickListNamesAndVals");
        //console.log('=========>> pickListNamesAndVals:');
        //console.log(opptyTotalsByStage);

        var opptyRecs = component.get("{!v.kanbanData.records}");
        var droppedRec;
        for (var i in opptyRecs) {
            if (opptyRecs[i].Id == recId) {
                droppedRec = opptyRecs[i];
                break;
            }
        }
        //console.log('========>> droppedRec:');
        //console.log(droppedRec);
        this.updateStageTotals(component, fromStage, toStage, droppedRec, opptyTotalsByStage);

        var probMap = component.get("v.probabilityMap");
        //console.log('========>> probMap:');
        //console.log(probMap);
        this.updateProbability(component, toStage, droppedRec, probMap, opptyRecs);

        this.setStageContainerHeight(component, event);

        var action = component.get("c.getUpdateStage");
        action.setParams({
            "recId":recId,
            "kanbanField":"StageName",
            "kanbanNewValue":toStage,
            "lossReasonField":"Loss_Reason__c",
            "lossReason":lossReason
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                //console.log('------->> return value from getUpdateStage:');
                //console.log(response.getReturnValue());
                document.getElementById(recId).style.backgroundColor = "#04844b";
                setTimeout(function(){ document.getElementById(recId).style.backgroundColor = ""; }, 300);
            }
        });
        $A.enqueueAction(action);
    },

    // sets attributes that are associated with the data returned from the call to the Apex controller
    // this happens on initialization, when the user changes list views, etc
    processKanbanResponse : function(component, event, retVal, showRefreshMessage) {
        if (retVal.errorMessage != '') {
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "type" : "error",
                "title": "Error Loading List View",
                "mode" : "sticky",
                "message": retVal.errorMessage
            });
            toastEvent.fire();
        } else {
            //console.log('%%%%%%%%%%^^^^^^^^******** retVal:');
            ////console.log(retVal);
                //console.log('********* TIMING processKanbanResponse START');
            for (var i = 0; i < retVal.records.length; i++) {
                retVal.records[i].CreatedDate = retVal.records[i].CreatedDate.substring(0,10);  // convert DateTime to Date
            }
            //console.log('******************** recordAccessMap:');
            //console.log(retVal.recordAccessMap);
            component.set('v.recAccessMap', retVal.recordAccessMap);
            var recMap = component.get('v.recAccessMap');
            //console.log('**************************** v.recAccessMap:');
            //console.log(recMap);
            //console.log('******************** oppsEditableByUser:');
            //console.log(retVal.oppsEditableByUser);
            component.set("v.budgetAccessList", retVal.oppsEditableByUser);

            component.set("v.lossReasonPicklist", retVal.PickList_LossReason);
            //console.log('********&&&&&&&&&&------->> retVal.PickList_LossReason:');
            //console.log(retVal.PickList_LossReason);

            //console.log('******************** setting up totals array');
            var totalsArray = [];
            var countsArray = [];
            var pendingArray = [];

            //console.log('pickVals:');
            //console.log(retVal.pickVals);
            for (var i = 0; i < retVal.pickVals.length; i++) {
                //console.log('------->> pickval = ' + retVal.pickVals[i]);
                //console.log('------------->> value = ' + retVal.stageTotals[retVal.pickVals[i]]);
                var totalAmount = (typeof retVal.stageTotals[retVal.pickVals[i]] == 'undefined') ? 0 : retVal.stageTotals[retVal.pickVals[i]];
                var totalPendingAmount = (typeof retVal.pendingTotals[retVal.pickVals[i]] == 'undefined') ? 0 : retVal.pendingTotals[retVal.pickVals[i]];
                var totalCount = (typeof retVal.opptyCounts[retVal.pickVals[i]] == 'undefined') ? 0 : retVal.opptyCounts[retVal.pickVals[i]];
                totalsArray.push({stage : retVal.pickVals[i], amount : totalAmount, pendingAmount: totalPendingAmount, count : totalCount});
                pendingArray.push({stage : retVal.pickVals[i], amount : totalPendingAmount});
                countsArray.push({stage : retVal.pickVals[i], count : totalCount});
            }
            //console.log('***************----->> pendingArray:');
            //console.log(pendingArray);
            var broadcastMonthArray = [];
      /*      for (var i = 0; i < retVal.broadcastMonthValues.length; i++) {
                var toolTipStr = helper.generateToolTipHTML(component, retVal.broadcastMonthValues[i].broadcastMonthGrossValues, retVal.broadcastMonthValues[i].broadcastMonthNetValues);
                broadcastMonthArray.push({opptyId : retVal.broadcastMonthValues[i].opptyId, grossValue : retVal.broadcastMonthValues[i].broadcastMonthGrossValues, netValue : retVal.broadcastMonthValues[i].broadcastMonthNetValues});
            }
            //console.log('######------>> broadcastMonthArray =');
            //console.log(broadcastMonthArray);
            */
            //console.log('***************----->> retVal.filterRules:');
            //console.log(retVal.filterRules);

            //console.log('***************----->> retVal.showOnlyMyOpportunities: ' + retVal.showOnlyMyOpportunities);


            this.removeFilterRule(component, event, 1);
            this.removeFilterRule(component, event, 2);
            this.removeFilterRule(component, event, 3);
            component.set("v.selectedWhichOppties", (retVal.showOnlyMyOpportunities == null || retVal.showOnlyMyOpportunities ? "My Opportunities" : "All Opportunities"));
            Object.keys(retVal.filterRules).forEach(function(key) {
                var keyNum = parseInt(key);
                    component.set("v.rule"+(keyNum+1)+"Field", retVal.filterRules[key]["label"]);
                    component.set("v.rule"+(keyNum+1)+"Field_type", retVal.filterRules[key]["dataType"]);
                    component.set("v.rule"+(keyNum+1)+"Field_value", retVal.filterRules[key]["ApiName"]);
                    component.set("v.rule"+(keyNum+1)+"Operator", retVal.filterRules[key]["operator"]);
                    component.set("v.rule"+(keyNum+1)+"Value", retVal.filterRules[key]["value"]);
            });
   //         for (var i in retVal.filterRules) {
    //            //console.log('------>> retVal.filterRule[' + i + '].value = ' + retVal.filterRule[i].value);
     //       }
            //console.log('######------>> totalsArray = ');
            //console.log(totalsArray);
            //console.log('######------>> countsArray = ');
            //console.log(countsArray);
            component.set("v.pickListNamesAndVals", totalsArray);
            component.set("v.kanbanData", retVal);
            component.set("v.filterAudience", retVal.filterVisibility);
            component.set('v.stageTotals', retVal.stageTotals);
            component.set("v.pendingTotals", retVal.pendingArray);
            component.set('v.opptyCountByStage', countsArray);
            component.set('v.probabilityMap', retVal.probabilityMap);

            if(showRefreshMessage) {
                        var refreshBackdrop = component.find("refreshBackdrop");
                        $A.util.removeClass(refreshBackdrop,'slds-backdrop_open');
    //                    var refreshBackdropIcon = component.find("refreshBackdropIcon");
    //                    $A.util.addClass(refreshBackdropIcon,'refreshIcon_hide');

                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "title": "Loading List View Complete",
                            "message": " "
                        });
                        toastEvent.fire();

            }
            this.refreshButtonsAndStates(component, event);
            this.setStageContainerHeight(component, event);
                //console.log('********* TIMING ___you should only see me once!!!!!___processKanbanResponse END');
        }
            component.set("v.lastRefreshDateTime", this.getCurrentTime());
            this.updateStatus(component);


    },

    updateStageCounts : function(component, fromStage, toStage, opptyCountByStage) {
       for (var i in opptyCountByStage) {
         if (opptyCountByStage[i].stage == fromStage) {
            opptyCountByStage[i].count -= 1;
         } else if (opptyCountByStage[i].stage == toStage) {
            opptyCountByStage[i].count += 1;
         }
       }
       component.set("v.opptyCountByStage", opptyCountByStage);
    },

    updateStageTotals : function(component, fromStage, toStage, oppty, opptyTotalsByStage) {
       for (var i in opptyTotalsByStage) {
         if (opptyTotalsByStage[i].stage == fromStage) {
            var amount = (oppty.Total_Forecast_Amount__c == null || typeof oppty.Total_Forecast_Amount__c == 'undefined') ? 0 : oppty.Total_Forecast_Amount__c; 
            var pendingAmount = (oppty.Pending_Gross_Amount__c == null || typeof oppty.Pending_Gross_Amount__c == 'undefined') ? 0 : oppty.Pending_Gross_Amount__c; 
            opptyTotalsByStage[i].amount -= amount;
            opptyTotalsByStage[i].pendingAmount -= pendingAmount;
         } else if (opptyTotalsByStage[i].stage == toStage) {
            var amount = (oppty.Total_Forecast_Amount__c == null || typeof oppty.Total_Forecast_Amount__c == 'undefined') ? 0 : oppty.Total_Forecast_Amount__c;
            var pendingAmount = (oppty.Pending_Gross_Amount__c == null || typeof oppty.Pending_Gross_Amount__c == 'undefined') ? 0 : oppty.Pending_Gross_Amount__c; 
            opptyTotalsByStage[i].amount += amount;
            opptyTotalsByStage[i].pendingAmount += pendingAmount;
         }
       }
       component.set("v.pickListNamesAndVals", opptyTotalsByStage);
    },

    updateProbability : function(component, toStage, oppty, probMap, opptyRecords) {
     // SRSF-1131   var toPercent = probMap[toStage];
    // SRSF-1131    oppty.Probability = toPercent;
    // SRSF-1131 start
        var newProbability = (typeof oppty.Sales_Probability__c === 'undefined') ? '0' : oppty.Sales_Probability__c;      
        if (newProbability != '0') {
            newProbability.slice(1, -1);
        }
        oppty.Probability = newProbability;
        //SRSF-1131 End
        oppty.StageName = toStage;      // updating stage name as well - didn't think a separate function was warranted
        for (var i in opptyRecords) {
            if (opptyRecords[i].Id == oppty.Id) {
                opptyRecords[i] = oppty;               
                break;
            }
        }
       component.set("{!v.kanbanData.records}", opptyRecords);
    },

    editOpportunity : function(component, event, opptyId) {
            var editRecordEvent = $A.get("e.force:editRecord");
            editRecordEvent.setParams({
                 "recordId": opptyId
            });
            editRecordEvent.fire();
    },

    goToOpptyBudget : function(component, event, opptyId) {
        var urlEvent = $A.get("e.force:navigateToURL");
        var navTo = '/apex/ProposalOpportunityBudget?oppId=' + opptyId;
        urlEvent.setParams({
          "url": navTo
        });
        urlEvent.fire();
    },
    doApplyDelete : function(component, event) {
        var isUserAdmin = component.get("v.selectedListView");
        var listViewId = component.get("v.selectedListViewId");
        //console.log('In doApplySort: listViewId ='+listViewId);
        var action = component.get("c.deleteListView");
        var showRefreshMessage = true;
        action.setParams({
            "listViewId":listViewId,
            "isUserAdmin":isUserAdmin
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            //console.log('===========>> state = ' + state); 
            if (state === "SUCCESS") {
                var retVal = response.getReturnValue();
                if(retVal == "") {
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "List View successfully deleted. Refreshing...",
                        "message": " "
                    });
                    toastEvent.fire();
                    this.performInitialization(component, event, false, "My Opportunities");
                }
                else {
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Error deleting List View",
                        "message": retVal
                    });
                    toastEvent.fire();

                }
            }

        });
        $A.enqueueAction(action);
    },

    doApplySort : function(component, event) {
        var sortField = component.get("v.sortByField")
        //console.log('in doApplySort, sortField = ' + sortField);
        var listViewName = component.get("v.selectedListView");
        var listViewId = component.get("v.selectedListViewId");
        //console.log('In doApplySort: listViewId ='+listViewId);
        var action = component.get("c.changeCurrentListView");
        var showRefreshMessage = true;
        action.setParams({
            "objName":component.get("v.objName"),
            "objFields":component.get("v.objFields"),
            "kanbanField":component.get("v.kanbanPicklistField"),
            "showOnlyMyOpportunities":!(component.get("v.selectedWhichOppties").split(" ")[0] == "All"),
            "listViewId":listViewId,
//            "listViewId":(listViewName != null ? listViewName : "My Opportunities"),
            "checkListViewCache": false,
            "sortBy" : sortField,
            "isSortDesc" : component.get('v.sortDesc'),
            "nameFilter" : component.get("v.accOppName")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            //console.log('===========>> state = ' + state); 
            if (state === "SUCCESS") {
                var retVal = response.getReturnValue();
                if(retVal.listViewName != listViewName)
                    listViewName = retVal.listViewName;
                //console.log('=============>> Stinking return value = ' + retVal);
                console.dir(retVal);

                //console.log('********* TIMING saveNew Helper performInit:processKanban START');

                this.processKanbanResponse(component, event, retVal);

                //console.log('********* TIMING saveNew Helper performInit:processKanban END');

                var msgRefreshTitle = "Refresh Complete";
                var msgRefresh = "Opportunity Pipeline has been refreshed.";

                if(!showRefreshMessage) {
                    var msgRefreshTitle = "Loading Complete";
                    var msgRefresh = "Opportunity Pipeline has been loaded.";
                }
                var refreshBackdrop = component.find("refreshBackdrop");
                $A.util.removeClass(refreshBackdrop,'slds-backdrop_open');

                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": msgRefreshTitle,
                    "message": msgRefresh
                });
                toastEvent.fire();

                }
                //console.log('********* TIMING saveNew Helper doApplySort Refresh END');

            });
            $A.enqueueAction(action);
    },

    getCurrentTime : function() {
        var currentDate = new Date();
        var rightNow = Math.round(currentDate / 1000);
        return rightNow;
    },

    // updates the status line - ex: 125 Records - Sorted by Probability - Updated 10 minutes ago
    // updates the status every 60 seconds
    updateStatus : function(component) {
        //console.log('===========>> in updateStatus');
        var startTime = component.get("v.lastRefreshDateTime");
    //    //console.log('===========>> startTime = ' + startTime);
      ////  this didn't work because of some weird callback thing  var currentTime = getCurrentTime();
        var currentDate = new Date();
        var currentTime = Math.round(currentDate / 1000);
        var numMinutes = Math.round((currentTime - startTime) / 60);

     //   //console.log('--------------->> numMinutes = ' + numMinutes);
        var refreshStr;
        if (numMinutes < 60) {
            var minuteDisplayStr = (numMinutes == 1) ? ' minute' : ' minutes';
            refreshStr = 'Updated ' + numMinutes + minuteDisplayStr + ' ago';
        } else {
            var numHours = Math.floor(numMinutes / 60);
            var numMinutes = numMinutes % 60;
            var numHoursStr = ((numHours == 1) ? ' 1 Hour' : numHours + ' Hours');
            var numMinutesStr = (numMinutes == 0) ? ' ' : ((numMinutes == 1) ? ' and 1 minute' : ' and ' + numMinutes + ' minutes');
       /*     //console.log('numHours = ' + numHours);
            //console.log('numHoursStr = ' + numHoursStr);
            //console.log('numMinutes = ' + numMinutes);
            //console.log('numMinutesStr = ' + numMinutesStr);
        */
            refreshStr = 'Updated ' + numHoursStr + numMinutesStr + ' ago';
            //console.log('refreshStr = ' + refreshStr);
        }
        component.set("v.refreshAge", refreshStr);
    },

    lastRefreshTimer : function(component) {
   //     setTimeout(this.updateStatus, 60000, component);

        setInterval(this.updateStatus, 60000, component);
        /*
        var statusFunc = this.updateStatus;
        statusFunc.comp = component
          setInterval( statusFunc, 60000);
          */
    },

    getTaskToolTipHTML : function(component) {
        var html = '<p><b>No open activites</b><br/>Take Action to keep this deal moving.<br/></p>';
     //   html += '<a href="New Task" onclick="{! c.createTask }" />';
       // html += '<lightning:button variant="base" label="New Action" onclick="{! c.createAction }" />';
        return html;
    },

    getListViews : function(component, event) {
        var action = component.get("c.getOpptyListViews");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var listViews = response.getReturnValue();
                //console.log('--------->> in getListViews, retVal = ');
                //console.log(listViews);
                var listViewList = component.get("v.listViews");
                var userLVs = [];
                var lName;
                Object.keys(listViews).forEach(function(key) {
                    lName = listViews[key].Name;
                  //  listViewList[key] = value;
                    //console.log('--->> key   = ' + key);
                    //console.log('--->> listViews[key].Name = ' + listViews[key].Name);
                    //console.log('--->> listViews[key].Id = ' + listViews[key].Id);

                    for (var k in listViews[key]["Opportunity_Forecasting_Filter_Values__r"]) {
                        //console.log('-------->> k = ' + k);
                        //console.log('-------->> listViews[key]["Opportunity_Forecasting_Filter_Values__r"][k] = ' + listViews[key]["Opportunity_Forecasting_Filter_Values__r"][k]);
                        //console.log(listViews[key]["Opportunity_Forecasting_Filter_Values__r"][k].Id);
                        //console.log(listViews[key]["Opportunity_Forecasting_Filter_Values__r"][k].API_Name__c);
                        //console.log(listViews[key]["Opportunity_Forecasting_Filter_Values__r"][k].Field_Data_Type__c);
                        //console.log(listViews[key]["Opportunity_Forecasting_Filter_Values__r"][k].Field_Name__c);
                        //console.log(listViews[key]["Opportunity_Forecasting_Filter_Values__r"][k].Operator__c);
                        //console.log(listViews[key]["Opportunity_Forecasting_Filter_Values__r"][k].Opportunity_Scope__c);
                        //console.log(listViews[key]["Opportunity_Forecasting_Filter_Values__r"][k].Value__c);
                    }

                    userLVs.push( {Id : key, value : lName});

                });
                //console.log('----->> userLVs:');
                //console.log(userLVs);
                component.set("v.userListViews", userLVs);

                component.set("v.listViews", listViews); 
            }
        });
        $A.enqueueAction(action);
    },

    changeListView : function(component, event, viewName) {
        // viewId is actually the Id~Name
      //  var selectedItem = viewId.split('~');
    //console.log('********* TIMING  Helper changeListView START');

      var refreshBackdrop = component.find("refreshBackdrop");
    $A.util.addClass(refreshBackdrop,'slds-backdrop_open');
    var toastEvent = $A.get("e.force:showToast");
    toastEvent.setParams({
        "title": "Loading List View...",
        "message": " ",
        "duration": 3000
    });
    toastEvent.fire();
      //console.log('viewName = '+ viewName);
      var listViewMap = component.get("v.listViews");
   ////     component.set("v.selectedListView", listViewMap[0][viewName]);
        //console.log('theObjName = ' + component.get("v.objName"));
        //console.log('theobjFields = ' + component.get("v.objFields"));
        //console.log('theObjName = ' + component.get("v.objName"));
        //console.log('thekanbanField = ' + component.get("v.kanbanPicklistField"));
        var action = component.get("c.changeCurrentListView");
        action.setParams({
            "objName":component.get("v.objName"),
            "objFields":component.get("v.objFields"),
            "kanbanField":component.get("v.kanbanPicklistField"),
            "showOnlyMyOpportunities":!(component.get("v.selectedWhichOppties").split(" ")[0] == "All"),
            "listViewId":viewName,
            "checkListViewCache":false,
            "sortBy" : component.get("v.sortByField"),
            "isSortDesc" : component.get("v.sortDesc"),
            "nameFilter" : component.get("v.accOppName")
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                //console.log('------->> return value from changeListView:');
                //console.log(response.getReturnValue());
                this.processKanbanResponse(component, event, response.getReturnValue(), true);
           //     this.showFilterPanel(component, event);
                //this.refreshButtonsAndStates(component, event);
                //console.log('********* TIMING  Helper changeListView:processKanban END');
            }
        });
        $A.enqueueAction(action);
            //console.log('********* TIMING  Helper changeListView:processKanban START');

            //console.log('********* TIMING  Helper changeListView START');


    },
    showOrHideSaveButton : function(component, event) {
                //console.log("in showOrHideSaveButton");
                var listViewName = component.get("v.selectedListView");
                var saveButton = component.find("saveButton");
                if(listViewName == "All Opportunities" || listViewName == "My Opportunities") {
                    //console.log('why: if-true');
                    if(!$A.util.hasClass(saveButton,'hideInitSave'))
                        $A.util.addClass(saveButton,'hideInitSave');

                    if(!(component.find("sharingMenuItem") == undefined)) {
                        var sharing = component.find("sharingMenuItem");
                        sharing.set("v.disabled", true);
                    }
                    if(!(component.find("deleteMenuItem") == undefined)) {
                        var deleteButton = component.find("deleteMenuItem");
                        deleteButton.set("v.disabled", true);
                    }
                    if(!(component.find("renameMenuItem") == undefined)) {
                        var renameMenuItem = component.find("renameMenuItem");
                        renameMenuItem.set("v.disabled", true);
                    }
                }
                else {
                    //console.log('why: if-false');
                    if($A.util.hasClass(saveButton,'hideInitSave'))
                        $A.util.removeClass(saveButton,'hideInitSave');
                    if(!(component.find("sharingMenuItem") == undefined)) {
                        var sharing = component.find("sharingMenuItem");
                        sharing.set("v.disabled", false);
                    }
                    if(!(component.find("deleteMenuItem") == undefined)) {
                        var deleteButton = component.find("deleteMenuItem");
                        deleteButton.set("v.disabled", false);
                    }
                    if(!(component.find("renameMenuItem") == undefined)) {
                        var renameMenuItem = component.find("renameMenuItem");
                        renameMenuItem.set("v.disabled", false);
                    }
                }
                //console.log("end showOrHideSaveButton");
    },
    refreshButtonsAndStates : function(component, event) {
                var listViewName = component.get("v.selectedListView");
                //console.log('****why is listViewName: ' + listViewName);
                var sharingMenuItem = component.find("sharingMenuItem");
                var renameMenuItem = component.find("renameMenuItem");
                var editor0 = component.find("editor0");
                var editor1 = component.find("editor1");
                var editor2 = component.find("editor2");
                var editor3 = component.find("editor3");
                var saveButton = component.find("saveButton");
                if($A.util.hasClass(editor0,'edited'))
                        $A.util.removeClass(editor0,'edited');
                if($A.util.hasClass(editor1,'edited'))
                        $A.util.removeClass(editor1,'edited');
                if($A.util.hasClass(editor2,'edited'))
                        $A.util.removeClass(editor2,'edited');
                if($A.util.hasClass(editor3,'edited'))
                        $A.util.removeClass(editor3,'edited');
                //console.log('why1 ['+listViewName+'] sharing hasClass hideInit? ' +($A.util.hasClass(sharingMenuItem,'hideInit')));
                //console.log('why1 ['+listViewName+'] rename hasClass hideInit? ' +($A.util.hasClass(renameMenuItem,'hideInit')));
                if(listViewName == "All Opportunities" || listViewName == "My Opportunities") {
                    //console.log('why: if-true');
                    if(!$A.util.hasClass(sharingMenuItem,'hideInit'))
                        $A.util.addClass(sharingMenuItem,'hideInit');
                    if(!$A.util.hasClass(renameMenuItem,'hideInit'))
                        $A.util.addClass(renameMenuItem,'hideInit');
                    if(!$A.util.hasClass(saveButton,'hideInit'))
                        $A.util.addClass(saveButton,'hideInit');
                }
                else {
                    //console.log('why: if-false');
                    if($A.util.hasClass(sharingMenuItem,'hideInit'))
                        $A.util.removeClass(sharingMenuItem,'hideInit');
                    if($A.util.hasClass(renameMenuItem,'hideInit'))
                        $A.util.removeClass(renameMenuItem,'hideInit');
                    if($A.util.hasClass(saveButton,'hideInit'))
                        $A.util.removeClass(saveButton,'hideInit');
                }
                //console.log('why2 ['+listViewName+'] sharing hasClass hideInit? ' +($A.util.hasClass(sharingMenuItem,'hideInit')));
                //console.log('why2 ['+listViewName+'] rename hasClass hideInit? ' +($A.util.hasClass(renameMenuItem,'hideInit')));


    },

    showWhichOpptiesWindow : function(component, event) {
        var whichOpptiesEditor = component.find("showOpportunities");
        //console.log('in showFilterWindow');
        //console.log('-------------->> event:' + event);
        if($A.util.hasClass(whichOpptiesEditor,'slds-hide')) {
            $A.util.removeClass(whichOpptiesEditor,'slds-hide');
            $A.util.addClass(whichOpptiesEditor,'slds-show');
            $A.util.addClass(whichOpptiesEditor,'open');
        }
        else {
            $A.util.removeClass(whichOpptiesEditor,'slds-show');
            $A.util.removeClass(whichOpptiesEditor,'open');
            $A.util.addClass(whichOpptiesEditor,'slds-hide');
        }

    },
    handleOpptyFieldChange : function(component, event, vValue, vDataType) {
        var exampleStr = "Example: ";
        var exampleValueStr = "";
//        var dataType = event.getSource().get("v.value").split(";")[1]; 
//        var dataApiName = event.getSource().get("v.value").split(";")[0]; 
        var dataType = component.find("filterField").get("v.value").split(";")[1]; 
        var dataApiName = component.find("filterField").get("v.value").split(";")[0]; 

        
        var isPicklist = false;

        component.set("v.filterValue", "");
        component.find("filterOperator").set("v.value", "equals");

        if(dataType == "BOOLEAN") {
            exampleValueStr = "false";
        }
        else if(dataType == "REFERENCE" || dataType == "ID") {
            exampleValueStr = "001g000002haZtwAAE";
        }
        else if(dataType == "PERCENT" ) {
            exampleValueStr = "50  (%)";
        }
        else if(dataType == "PICKLIST" ) {
            exampleValueStr = "Item1, Item2, Item3";
            isPicklist = true;
            exampleValueStr = "[Hold 'Shift' to select multiple]";
            exampleStr = "";
        }
        else if(dataType == "STRING" || dataType == "TEXT") {
            exampleValueStr = "xyz";
        }
        else if(dataType == "CURRENCY" || dataType == "DOUBLE" ) {
            exampleValueStr = "400.00";
        }
        else if( dataType == "INTEGER" ) {
            exampleValueStr = "123";
        }
        else if(dataType == "DATE") {
            exampleValueStr = "12/31/2017";
        }
        else if(dataType == "DATETIME") {
            exampleValueStr = "12/31/2017";
        }
        else if(dataType == "NONE") {
            exampleValueStr = "";
            exampleStr = "";
        }

        var inputElementTextfield = component.find('filterValueSpan');
        var inputElementPicklist = component.find('filterValuePicklistSpan');
        var filterOperatorSpan = component.find('filterOperatorSpan');
        if(isPicklist) {
            if($A.util.hasClass(inputElementPicklist,'slds-hide')) {
                $A.util.addClass(inputElementTextfield,'slds-hide')
                $A.util.addClass(filterOperatorSpan,'slds-hide')
                $A.util.removeClass(inputElementPicklist,'slds-hide')
            }
        }
        else {
            if($A.util.hasClass(inputElementTextfield,'slds-hide')) {
                $A.util.addClass(inputElementPicklist,'slds-hide')
                $A.util.removeClass(filterOperatorSpan,'slds-hide')
                $A.util.removeClass(inputElementTextfield,'slds-hide')
            }
        }

        if($A.util.hasClass(inputElementTextfield,'slds-hide')) {
            component.find("filterOperator").set("v.value", "contains");
            var kanbanData = component.get("v.kanbanData");
            var picklistVals;
            //console.log("kanbanData (slice):");
            console.dir(kanbanData);
            //var filterInputPicklist = filterValuePicklist;
            if(dataApiName == "Bill_To__c") {
                picklistVals = kanbanData.PickList_BillTo.slice();
            }
            else if(dataApiName == "Type") {
                picklistVals = kanbanData.PickList_Type.slice();
            }
            else if(dataApiName == "Owner_Sales_Office__c") {
                picklistVals = kanbanData.PickList_Owner_Sales_Office.slice();
            }
            else if(dataApiName == "Owner_Region__c") {
                picklistVals = kanbanData.PickList_Region.slice();
            }
            else if(dataApiName == "Owner_Division__c") {
                picklistVals = kanbanData.PickList_Division.slice();
            }
            else { //if(dataApiName == "Record_Type__c") {
                picklistVals = kanbanData.PickList_RecordType.slice();
            }
            //component.set("v.filterValue", picklistVals.join(', '));
            var selectItems = [];
            var selectedItems = [];
            if(vValue != null && vDataType == "PICKLIST") {
                selectedItems = vValue.split("+");

            }
            //console.log("selectedItems:");
            console.dir(selectedItems);
            for(var v in picklistVals) {
                if(v != "includes") {
                    var idx = selectItems.length;
                    selectItems[idx] = [];
                    selectItems[idx].value = picklistVals[v];
                    selectItems[idx].label = picklistVals[v];
                    //console.log('[dataApiName='+dataApiName+'] v='+v+ ' , picklistVals[v]=' + picklistVals[v] + ' , selectItems[idx].value=' + selectItems[idx].value); 
                    selectItems[idx].selected = false;
                    //console.log("Select test for: " + picklistVals[v])
                    for(var str2 in selectedItems) {
                        if(selectedItems[str2] == picklistVals[v]) {
                            //console.log("Please select: " + selectItems[str2])
                            selectItems[idx].selected = true;
                        }
                    }
                    ////console.log("idx["+idx+"]="+selectItems[idx]);
                }
            }
            component.find('my-multi-select').set('v.options', selectItems);
            component.find('my-multi-select').reInit();
            //component.set("v.kanbanData", kanbanData)
        }

        component.set("v.inputExample", exampleStr);
        component.set("v.inputExampleValue", exampleValueStr);
    },


    showFilterWindow : function(component, event, ruleNum, doPerformSave) {
        //console.log('in showFilterWindow (4)');
        //console.log('-------------->> event:' + event);
        var filterEditor = component.find("filterEditor");
        if($A.util.hasClass(filterEditor,'slds-hide')) {
            //console.log('-------------->> button top:' + (100 + event.target.getBoundingClientRect().top )+ "px");
            $A.util.removeClass(filterEditor,'slds-hide');
            $A.util.addClass(filterEditor,'slds-show');
            $A.util.addClass(filterEditor,'open');
            $A.util.removeClass(filterEditor,'filterEdit1');
            $A.util.removeClass(filterEditor,'filterEdit2');
            $A.util.removeClass(filterEditor,'filterEdit3');
            $A.util.addClass(filterEditor,'filterEdit'+ ruleNum);
            component.set("v.currentRuleNum", ruleNum);
            //console.log('-------------->> setting name:' + ruleNum);

            component.set("v.filterEditNum",ruleNum + "");

            var currentRuleNum = ruleNum;
            var gOperator = component.get("v.rule" + currentRuleNum + "Operator");
            var gFieldValue = component.get("v.rule" + currentRuleNum + "Field_value");
            var gFieldType = component.get("v.rule" + currentRuleNum + "Field_type");
            var gField = component.get("v.rule" + currentRuleNum + "Field");
            var gValue = component.get("v.rule" + currentRuleNum + "Value");
            if(gValue != null && gValue != "") {
                component.find("filterField").set("v.value", gFieldValue + ";" + gFieldType + ";" + gField);
                this.handleOpptyFieldChange(component, event, gValue, gFieldType);
                if(gFieldType != "PICKLIST") {
                    component.find("filterOperator").set("v.value", gOperator);
                    component.set("v.filterValue", gValue);
                }
            }

            //document.getElementById("filterEditor").style.top = (100 + event.target.getBoundingClientRect().top )+ "px";
        }
        else {
            var isValidated = true;
            var validationMessage = "";
            if(ruleNum == null) {
                var currentRuleNum = component.get("v.currentRuleNum");

                var fOp = component.find("filterOperator").get("v.value");
                var fField = component.find("filterField").get("v.value");
                var dataType = fField.split(";")[1];
                //console.log("dataType="+dataType);
                var fValue = component.get("v.filterValue");
                if(doPerformSave && fField.split(";")[1] != "NONE" && (fValue != "" && fValue != null) &&(fOp != "" && fOp != null)) {
                    if(dataType == "BOOLEAN") {
                        if(fValue == null || (fValue.toLowerCase() != 'false' && fValue.toLowerCase() != 'true')) {
                            validationMessage = "Value must be either 'true' or 'false'";
                            isValidated = false;
                        }
                    }
                    else if(dataType == "PERCENT" || dataType == "DOUBLE" || dataType == "CURRENCY") {
                        if(isNaN(parseFloat(fValue))) {
                            validationMessage = "Value must be a valid number (i.e. 400.00)";
                            isValidated = false;
                        }
                    }
                    else if(dataType == "INTEGER") {
                        if(isNaN(parseInt(fValue))) {
                            validationMessage = "Value must be a valid number (i.e. 123)";
                            isValidated = false;
                        }
                    }
                    else if(dataType == "DATE" || dataType == "DATETIME") {
                        if(isNaN(Date.parse(fValue))) {
                            if(fValue != null) {
                                var isGood = false;
                                fValue = fValue.toUpperCase().trim();
                                var keywords = fValue.split(" ");
                                if(keywords.length == 3 &&
                                      (keywords[0] == "LAST" || keywords[0] == "NEXT") &&
                                      (keywords[2] == "DAYS" || keywords[2] == "QUARTERS" || keywords[2] == "YEARS") &&
                                      !isNaN(parseInt(keywords[1])) ) {
                                    isGood = true;
                                }
                                else if(keywords.length == 2 &&
                                        (keywords[0] == "LAST" || keywords[0] == "THIS" || keywords[0] == "NEXT") && 
                                        (keywords[1] == "WEEK" || keywords[1] == "MONTH" || keywords[1] == "QUARTER" || keywords[1] == "YEAR")) {
                                    isGood = true;
                                }
                                else if(keywords.length == 1 &&
                                        (fValue == "YESTERDAY" || fValue == "TODAY" || fValue == "TOMORROW")) {
                                    isGood = true;

                                }
                                if(!isGood) {
                                    validationMessage = "Value must be a valid date (i.e. 12/31/2017) or keyword (i.e. LAST WEEK)";
                                    isValidated = false;
                                }
 
                            }
                            else {
                                validationMessage = "Value must be a valid date (i.e. 12/31/2017) or keyword (i.e. LAST WEEK)";
                                isValidated = false;
                            }
                        }
                    }

                    if(isValidated) {
                        var editor = component.find("editor"+currentRuleNum);
                        if(!$A.util.hasClass(editor,'edited'))
                                $A.util.addClass(editor,'edited');

                        component.set("v.rule" + currentRuleNum + "Operator",fOp);
                        component.set("v.rule" + currentRuleNum + "Field_value",fField.split(";")[0]);
                        component.set("v.rule" + currentRuleNum + "Field_type",fField.split(";")[1]);
                        component.set("v.rule" + currentRuleNum + "Field",fField.split(";")[2]);
                        if(fOp.indexOf("NULL") !== -1) {
                            component.set("v.rule" + currentRuleNum + "Value","");
                        }
                        else {
                            component.set("v.rule" + currentRuleNum + "Value",fValue);
                        }
                    }
                    else {
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "title": "Unable to save Filter Rule",
                            "message": validationMessage
                        });
                        toastEvent.fire();
                    }
                }
    
            }
            if(isValidated) {
                $A.util.removeClass(filterEditor,'slds-show');
                $A.util.removeClass(filterEditor,'open');
                $A.util.addClass(filterEditor,'slds-hide');
            }
        }

    },

    showFilterPanelNoToggle : function(component, event) {
        //console.log('in showFilterPanelNoToggle');
        var filterPanel = component.find("opptyFilterPanel");
        var filterButton = component.find("filtButtAlign");
        var filterClose = component.find("filtButtClose");
        var filterRuleRemove = component.find("filtRuleClose");
        if($A.util.hasClass(filterPanel,'slds-show')) {
            $A.util.removeClass(filterPanel,'slds-hide');
            $A.util.addClass(filterPanel,'slds-show');
            $A.util.addClass(filterButton,'slds-button_brand');
        $A.util.removeClass(filterClose,'slds-button--neutral');
        $A.util.removeClass(filterRuleRemove,'slds-button--neutral');
    }ß
    },

    showFilterPanel : function(component, event) {
        //console.log('in showFilterPanel');
        var filterPanel = component.find("opptyFilterPanel");
        var filterButton = component.find("filtButtAlign");
        var filterClose = component.find("filtButtClose");
        var filterRuleRemove = component.find("filtRuleClose");
        if($A.util.hasClass(filterPanel,'slds-hide')) {
            $A.util.removeClass(filterPanel,'slds-hide');
            $A.util.addClass(filterPanel,'slds-show');
            $A.util.addClass(filterButton,'slds-button_brand');
        }
        else {
            $A.util.removeClass(filterPanel,'slds-show');
            $A.util.addClass(filterPanel,'slds-hide');
            $A.util.removeClass(filterButton,'slds-button_brand');
        }
        $A.util.removeClass(filterClose,'slds-button--neutral');
        $A.util.removeClass(filterRuleRemove,'slds-button--neutral');
    },
    
    doSearchForOppAcc : function(component, event) {
        console.log('in doSearchForOppAcc');
        
    },

})