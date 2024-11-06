({

    // searchHelper takes the user input, performs the search, and formats the results
    searchHelper: function (component, event, getInputkeyWord) {
        //console.log('----------->> in searchHelper, getInputkeyWord = ' + getInputkeyWord);
        var action = component.get("c.getObjects");
        var htmlMarkup = component.get("v.HTMLMarkup");
        //console.log('---->> htmlMarkup:');
        //console.log(htmlMarkup);

        var crossObjQuery = component.get("v.queryObject");

        //console.log('----->> crossObjQuery:');
        //console.log(crossObjQuery);

        //   var nestedQuery = component.get("v.nestedQuerySOQL");
        //   //console.log('----->> nestedQuery = ' + nestedQuery);

        var theObjectMap = component.get("v.objMap");
        //console.log('----->> theObjectMap:');
        //console.log(theObjectMap);

        var supWhere = component.get("v.supplementalWhereClause");
        //console.log('#########################===>> supWhere = ' + supWhere);
        if (!crossObjQuery) return;
        // generate where clause
        for (var i in crossObjQuery) {
            //console.log('crossObjQuery[' + i + '].whereClause = ' + crossObjQuery[i].whereClause);
            if (!isNaN(parseInt(i))) {
                // replace the ---ReplaceMe--- string with the search string input by the user
                crossObjQuery[i].whereClause = crossObjQuery[i].whereClause.replace(/\%(.+?)\%/g, "%" + getInputkeyWord + "%");
                var lastChar = crossObjQuery[i].whereClause[crossObjQuery[i].whereClause.length - 1];
                if (lastChar != ')') {
                    crossObjQuery[i].whereClause += ')';
                }
                //console.log('-------->> after replacing whereClause: ' + crossObjQuery[i].whereClause);
                //console.log('-------->> crossObjQuery[' + i + '].nestedQuery = ' + crossObjQuery[i].nestedQuery);
                crossObjQuery[i].supplementalWhereClause = supWhere;
            }
        }

        action.setParams({ 'objQuery': JSON.stringify(crossObjQuery) });
        // set a callBack    
        action.setCallback(this, function (response) {
            //console.log('--------------------->> searchHelper, in callback!!!!!');
            var newObjectButt = component.find("newObjectButton");
            var objKeyMap = component.get("v.sobjectKeys");
            var state = response.getState();
            //console.log('------------------>> state = ' + state);
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
                // if storeResponse size is equal 0 ,display 'No Results Found.' message on screen.
                if (storeResponse.length == 0) {
                    component.set("v.Message", 'No Results Found...');
                } else {
                    component.set("v.Message", 'Search Results...');
                }

                // set searchResult list with return value from server.
                component.set("v.listOfSearchRecords", storeResponse);

                var lookupResults = storeResponse;
                var objectMap = component.get("v.objMap");
                var customSettingRecord = objectMap[0];
                var currentRec;
                var HTMLMarkUp = '';

                var queryObjMap = component.get("v.queryObject");

                var objRecords = [];
                var tempATMs = [];

                ////   because IE11 is stoooopid     for (var i in lookupResults) {
                for (var i = 0; i < lookupResults.length; i++) {
                    var objRecord = {};
                    var recordMarkup = '';
                    var objKey = lookupResults[i].Id.substring(0, 3);
                    var currentKey = objKeyMap[objKey].SObject__c;
                    if (!currentKey) continue;
                    var currentObject;
                    //// IE11 insanity     for (var k in queryObjMap) {
                    for (var k = 0; k < queryObjMap.length; k++) {
                        if (queryObjMap[k].objectType == currentKey) {
                            currentObject = queryObjMap[k];
                        }
                    }

                    var htmlMarkupObj = htmlMarkup[currentKey];

                    var searchFields = currentObject.fields;
                    var fieldArray = searchFields.split(',');
                    ////  because IE11 is stoooopid    for (var j in fieldArray) {
                    for (var j = 0; j < fieldArray.length; j++) {
                        //console.log('----->> j = ' + j);

                        var index = fieldArray[j].trim();
                        if (index == 'Id' || index == 'Name') continue;    // ignore Id and Name (Name is handled separately)

                        if (index.indexOf('.') == -1) {
                            currentRec = lookupResults[i][index];
                        } else {
                            var parentChild = index.split('.');
                            //console.log('parentChild: ');
                            //console.log(parentChild);
                            // we've found a relationship query object (such as Account.Name), and we're only interested in the 2nd element (1st is Id) 
                            currentRec = lookupResults[i][1];
                        }
                        //        //console.log('--->> currentRec = ' + JSON.stringify(currentRec));

                        // Now get the Custom Setting record (used for formatting the results)
                        var custSetRec = currentObject; //customSettingRecord[index];
                        //     //console.log('---->> custSetRec = ' + JSON.stringify(custSetRec));
                        // add to the HTML
                        var startTag = (typeof htmlMarkupObj[index].HTMLResultStartTag != 'undefined') ? htmlMarkupObj[index].HTMLResultStartTag : '';
                        var endTag = (typeof htmlMarkupObj[index].HTMLResultEndTag != 'undefined') ? htmlMarkupObj[index].HTMLResultEndTag : '';
                        if (currentRec) {
                            recordMarkup += startTag + currentRec + endTag;    // no need for markup if field is empty.  This will prevent exteraneous delimiters
                            //        //console.log('#####--->> recordMarkup = ' + recordMarkup);
                        }
                    }
                    if (recordMarkup.charAt(0) == ',')           // if first field is blank we tend to get leading commas
                        recordMarkup = recordMarkup.substr(1);
                    objRecord.Name = lookupResults[i].Name;
                    objRecord.HTML = recordMarkup;
                    objRecord.objectType = currentKey.toLowerCase();
                    objRecord.objectIcon = '/assets/icons/standard-sprite/svg/symbols.svg#' + objRecord.objectType;
                    objRecord.objectLightningIcon = 'standard:' + objRecord.objectType;
                    objRecord.sObjectRec = lookupResults[i];

                    if (lookupResults[i].AccountTeamMembers) {
                        console.log('$$$$$$$$$$$$---->> ATM:');
                        console.log(lookupResults[i].AccountTeamMembers);
                        var atm = lookupResults[i].AccountTeamMembers;
                    }
                    objRecords.push(objRecord);
                }
                //console.log('$$$$$$$$$$$$$$$$$$----->> objRecords:');
                //console.log(objRecords);
                // Set the markup in the lightning component
                component.set("v.lookupResults", objRecords);
            }
        });
        // enqueue the Action  
        $A.enqueueAction(action);

    },

    saveOppty: function (component, acctId, opptyName, stage, closeDate, ae, agency, repFirm, holdingAccount, selectedDMA, f2f, vir, createActivityVal) { // SRSF-4392 - Add 'holdingAccount' 
        //console.log('------------------->> in saveOppty!');
        //console.log('------------------>> agency = ' + agency);
        //console.log('------------------>> repFirm = ' + repFirm);
        //console.log('------------------>> opptyName = ' + opptyName);  
        //console.log('------------------>> acctId = ' + acctId);
        //console.log('------------------>> closeDate = ' + closeDate);
        //console.log('------------------>> stage = ' + stage);
        //console.log('------------------>> ae = ' + ae); 
        //console.log('------------------>> RecordType = ' + component.get("v.selectedRecordType"));
        //console.log('------------------>> RecordType Dev Name = ' + component.get("v.selectedRecordTypeDevName"));
        //console.log('------------------>> Oppty record type = ' + component.get("v.opptyRecordType"));
        //console.log('------------------>> NCC_Account_Rep__c = ' + component.get("v.NCCAccountRep"));
        var oRecType = component.get("v.opptyRecordType");
        // var recTypeName = component.get("v.selectedRecordTypeDevName");
        // //console.log('------------------>> recTypeName = ' + recTypeName);
        // var isNationalOppty = (recTypeName.startsWith('National')) ? true : false;
        // Code for SRSF - 1672 Starts here
        var salesProb = component.get("v.Salesprobability");
        var flightStartDate = component.get("v.FlightStartDate");
        var flightEndDate = component.get("v.FlightEndDate");
        var description = component.get("v.Description");

        var createAct;
        if (component.get("v.UserProfileName") == 'Master - Account Executive') {
            createAct = component.get("v.createActivityChange");
        } else {
            createAct = false;
        }

        //alert('before'+component.get("v.UserProfileName") );
        var fstLook;
     //   if (component.get("v.UserProfileName") == 'Master - Account Executive' && $A.get("$Label.c.HideorShowFirstLookFields") == 'true') {
            fstLook = component.get("v.FirstLookVal");
      /*  } else {
            fstLook = '';
        }*/
        //alert(fstLook);
        //var fstLook = component.get("v.FirstLookVal");
        //var fstLook = component.find("FirstLookId").get("v.value");
        // alert(fstLook);

        var FirstLookContValue = component.get("v.FirstLookContValue");
        // Code for SRSF - 1672 Ends here

        var action = component.get("c.createOppty");
        action.setParams({
            'opptyName': opptyName,
            'Created_By_Account_Executive__c': true,
            'acctId': acctId,
            'stage': stage,
            'closeDate': closeDate,
            'acctExec': ae,
            'recTypeId': oRecType,
            'agency': agency,
            'nwToAvoid': component.get("v.networksToAvoid"),
            'repFirm': repFirm,
            //    'nccAgency'          : component.get("v.NCCAgency"),
            'nccAccountRep': component.get("v.NCCAccountRep"),
            // Code for SRSF - 1672 Starts here
            'dma': selectedDMA,
            'salesProb': salesProb,
            'flghtSrtDt': flightStartDate,
            'flghtEndDt': flightEndDate,
            'dscrptn': description,
            'firstLook': fstLook,
            'firstLookContVal': FirstLookContValue,
            // Code for SRSF - 1672 Ends here
        /*Commeting for SRSF-4945 CAMA
            'facetoface': f2f,
            'virtualval': vir, // Commeting for SRSF-4945 CAMA */
            'createActivity': createActivityVal,           
            'holdingAcct'                       : holdingAccount,        
            'dsPlatform'                        : component.get("v.demandSidePlatform"),  // SRSF-4392
            'ssPlatform'                        : component.get("v.supplySidePlatform"),  // SRSF-4392
            'seatId'                            : component.get("v.seatId"),              // SRSF-4392
            'businessClassification'            : component.get("v.businessClassification"), //SRSF-4606 
           // 'discountCode'                      : component.get("v.discountCode") //SRSF-4606           
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                //Start : SRSF-3571  
                var retVal = response.getReturnValue();
                console.log('%%%%%%%%$$$$$$$--->> retVal = ' + retVal);
                var oppDetails = JSON.parse(retVal);
                var opps = [];
                //component.set("v.opptyId", retVal);//commented for SRSF-3571
                for (var key in oppDetails) {
                    opps.push({ value: oppDetails[key].Name, key: key });
                }
                console.log('Opps--->' + opps);
                if (opps.length > 1) {
                    component.set("v.displayModal", true);
                    component.set("v.showOpps", opps);
                }
                else {
                    component.set("v.opptyId", opps[0].key);
                }
                //END : SRSF-3571
            }
            //SRSF-4428: Added else if block
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) 
                    {
                        if (errors[0] && errors[0].message) {
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "type": "error",
                            "title": "Error!",
                            "message": errors[0].message ,
                            "duration": "10000"
                        });
                        toastEvent.fire();
                        }                        
                    }
                } else {
                    console.log("Unknown error"); 
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "type": "error",
                        "title": "Error!",
                        'message': "Unknown error",
                        "duration": "10000"
                    });
                }
                var dismissActionPanel = $A.get("e.force:closeQuickAction");
                dismissActionPanel.fire();
            } 
        });
        $A.enqueueAction(action);
        
    },

    getUserId: function (component) {
        //console.log('============>> in getUserId!!!');
        var action = component.get("c.getMyUserId");
        //console.log('============>> in getUserId, after call to component.get');
        //console.log('action :' );

        //console.log(action);
        action.setCallback(this, function (response) {
            var state = response.getState();
            //console.log('=========> state:');
            //console.log(state);
            if (component.isValid() && state === "SUCCESS") {
                var retVal = response.getReturnValue();
                component.set("v.curUserId", retVal);
                //console.log('%%%%%%%%%%%%%%%%%%%%--->> UserId = ' + retVal);
            }
        });
        $A.enqueueAction(action);
    },
    getUserProfileName: function (component) {
        var action = component.get("c.getUserProfileName");
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                var retVal = response.getReturnValue();
                component.set("v.UserProfileName", retVal);

                //SRSF-1840 start
                var isProfileCondition = false;
                var isProfileAllowedToCreateActivity = false;
                var profiles = $A.get("$Label.c.Opportunity_Create_FlightDate_Profile");
                var profilesForCreateActivity = $A.get("$Label.c.Opportunity_CreateActivity_Profile");
                if (profiles != undefined) {
                    var lstProf = profiles.split(",");
                    for (var i = 0; i < lstProf.length; i++) {
                        if (retVal == lstProf[i]) {
                            isProfileCondition = true;
                            break;
                        }
                    }
                }
                component.set("v.showFlightDates", isProfileCondition);

                if (profilesForCreateActivity != undefined) {
                    var lstProfs = profilesForCreateActivity.split(",");
                    for (var i = 0; i < profilesForCreateActivity.length; i++) {
                        if (retVal == lstProfs[i]) {
                            isProfileAllowedToCreateActivity = true;
                            break;
                        }
                    }
                }
                component.set("v.showCreateActivity", isProfileAllowedToCreateActivity);
            }
        });
        $A.enqueueAction(action);
    },

    // a lot of data is set in getAcctInfo, and other functions depend on this data
    // this can result in timing issues, which have all been resolved at this point
    // however, future changes may necssitate implementing a different strategy to coordinate
    // and ensure that all data is received before decisions are made   
    getAcctInfo: function (component, accountId) {
        //console.log('============>> in getAcctInfo!!!  accountId = ' + accountId);
        var action = component.get("c.getAccountInfo");
        action.setParams({ 'acctId': accountId });
        action.setCallback(this, function (response) {
            var state = response.getState();
            //console.log('============>> in getAcctInfo!!!  state = ' + state);
            if (component.isValid() && state === "SUCCESS") {
                var retVal = response.getReturnValue();
                //console.log('=======>> in getAccountInfo, retval = ' + retVal);
                //console.log('=======>> in getAccountInfo, retval:');
                //console.log(retVal);
                component.set("v.selectedRecord", retVal);
                if (retVal.Id !== "undefined" && retVal.Id !== null) {
                    // Set address fields
                    component.set("v.ShippingStreet", retVal.ShippingStreet);
                    component.set("v.ShippingCity", retVal.ShippingCity);
                    component.set("v.ShippingState", retVal.ShippingState);
                    component.set("v.ShippingPostalCode", retVal.ShippingPostalCode);
                    component.set("v.ShippingCountry", retVal.ShippingCountry);

                    component.set("v.networksToAvoid", retVal.Networks_to_Avoid__c);
                    component.set("v.id", retVal.Id);
                    component.set("v.selectedRecordTypeText", retVal.RecordType.Name);
                    component.set("v.selectedRecordType", retVal.recordTypeId);
                    component.set("v.selectedRecordTypeDevName", retVal.RecordType.DeveloperName);
                    component.set("v.agency", retVal.Agency__c);
                    component.set("v.repFirm", retVal.Rep_Firm__c);
                    component.set("v.NCCAccountRep", retVal.NCC_Account_Rep__c);
                    component.set("v.accTeamMembers", retVal.AccountTeamMembers);                    
                    var isCreateContact = component.get("v.isCreateContact");
                    //console.log('------->> isCreateContact = ' + isCreateContact);
                    if (!isCreateContact) {
                        if (retVal.Agency__r && retVal.Agency__r.Name) {
                            var agComp = component.get('v.selectedAgency');
                            if (typeof agComp !== 'undefined') {    // will only be defined for accountLookup, so need to check
                                //console.log('=======>> agComp is defined, setting  agency stuff...');
                                //console.log('v.selectedRepFirm = ' + retVal.Agency__r.Name);
                                //console.log('v.selectedRepFirmId = ' + retVal.Agency__c);
                                //SRSF-4925 start
                               /* if(retVal.Landscape_Client__c == null){
                                component.set('v.selectedAgency', retVal.Agency__r.Name);
                                component.set('v.selectedAgencyId', retVal.Agency__c);
                                }*/
                                //SRSF-4925 end
                            }
                        }

                        if (retVal.Rep_Firm__r && retVal.Rep_Firm__r.Name) {
                            var rfComp = component.get('v.selectedRepFirm');
                            //console.log('---->> rfComp = ' + rfComp);
                            if (typeof rfComp !== 'undefined') {    // will only be defined for accountLookup, so need to check
                                //console.log('=======>> rfComp is defined, setting rep firm stuff...');
                                //console.log('v.selectedRepFirm = ' + retVal.Rep_Firm__r.Name);
                                //console.log('v.selectedRepFirmId = ' + retVal.Rep_Firm__c);
                                //SRSF-4925 start
                                /* if(retVal.Landscape_Client__c == null){
                                component.set('v.selectedRepFirm', retVal.Rep_Firm__r.Name);
                                component.set('v.selectedRepFirmId', retVal.Rep_Firm__c);
                                 }*/
                                //SRSF-4925 end
                            }
                        }
                        /* START : SRSF-4392
                        if (retVal.Holding_Account__r && retVal.Holding_Account__r.Name) {
                            var holdingAcctComp = component.get('v.selectedHoldingAcc');
                            if (typeof holdingAcctComp !== 'undefined') {                                 
                                component.set('v.selectedHoldingAcc', retVal.Holding_Account__r.Name);
                                component.set('v.selectedHoldingAccId', retVal.Holding_Account__c);
                            }
                        }
                         END : SRSF-4392 */
                    }
                    if (isCreateContact) {
                        this.setContactRecordType(component, retVal.RecordType.Name);
                    } else {
                        var accountRT = retVal.RecordType.DeveloperName;
                        if (accountRT == 'Agency_Account') {
                            var conf = confirm("You are trying to create an Opportunity from Agency Account. Do you want to continue?");
                            if (!conf) {
                                //component.set("v.isCreateOppty",false);
                                var dismissActionPanel = $A.get("e.force:closeQuickAction");
                                dismissActionPanel.fire();
                            } else {
                                this.setOpportunityRecordType(component, retVal.RecordType.DeveloperName, retVal.AccountTeamMembers, true);
                            }
                        }
                        //START : SRSF-4392
                        if (accountRT == 'Holding_Account') {
                            var conf = confirm("You are trying to create an Opportunity from Hold Co. Do you want to continue?");
                            if (!conf) {
                                //component.set("v.isCreateOppty",false);
                                var dismissActionPanel = $A.get("e.force:closeQuickAction");
                                dismissActionPanel.fire();
                            } else {
                                this.setOpportunityRecordType(component, retVal.RecordType.DeveloperName, retVal.AccountTeamMembers, true);
                            }
                        }
                        //END : SRSF-4392
                    }
                }
                //console.log('!!!!!@@@@@@@########$$$$$$$$$%%%%%%%%%%%^^^^^^^^');
                //bab         this.setAccountExecs(component, retVal.AccountTeamMembers, false);
            }
        });
        $A.enqueueAction(action);
    },

    setContactRecordType: function (component, acctRecType) {
        var action = component.get("c.getAvailRecordTypes");
        action.setParams({
            'objectApiName': 'Contact'
        });
        //console.log('---> action: ');
        //console.log(action);
        action.setCallback(this, function (response) {
            var state = response.getState();
            //console.log('============================>>in helper, setContactRTs, state = ' + state);
            if (component.isValid() && state === "SUCCESS") {
                var retVal = response.getReturnValue();
                //console.log('%%%%%%%%%%%%%%%%%%%%--->> contactRecordTypes: '+retVal);
                //console.log(retVal);
                var recTypes = [];
                for (var key in retVal) {
                    //console.log('key = ' + key);
                    //console.log('value = ' + retVal[key]);
                    recTypes.push({ value: retVal[key], Id: key });
                }
                component.set("v.contactRecordTypes", recTypes);
                var contactRTs = component.get('v.contactRecordTypes');
                if (contactRTs) {
                    //alert(acctRecType);
                    var accTypeSplit = acctRecType.split(' ');
                    var accType = accTypeSplit[0];
                    //alert(accType);
                    //console.log('##############=====>>  accType = ' + accType);
                    //console.log(contactRTs);
                    for (var i = 0; i < contactRTs.length; i++) {
                        //alert(contactRTs[i].value);
                        var contactSplit = contactRTs[i].value.split(' ');
                        //console.log('##############=====>>  contactSplit[0] = ' + contactSplit[0]);
                        //alert(contactSplit[0]+'<->'+accType)
                        if (contactSplit[0] == accType) {
                            //alert('Matched->'+contactRTs[i].Id)
                            //    component.set('v.contractRecordType', contactRTs[0].value);
                            //console.log('##############=====>>  contractRecordType name is: ' + contactRTs[i].value);
                            component.set('v.contractRecordType', contactRTs[i].Id);
                            //console.log('##############=====>> setting stinking contractRecordType to ' + contactRTs[i].Id);
                            break;
                        }
                    }
                }
            }
        });
        $A.enqueueAction(action);
    },

    setOpportunityRecordType: function (component, acctRecType, acctTeamMembers, callSetAEs) {
        //console.log('============>> in setOpportunityRecordType!!!');
        var action = component.get("c.getOpportunityRecordType");
        //action.setParams({'ownerId':null});
        //    action.setParams({ 'acctRecType' : acctRecType});
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                var retVal = response.getReturnValue();
                //console.log('=======>> in setOpportunityRecordType, retval:');
                //console.log(retVal);
                if (retVal !== "undefined" && retVal !== null) {
                    component.set("v.opptyRecordType", retVal);
                }
                //console.log('$$$$$$$$$$$$$--->> acctTeamMembers:');
                //console.log(acctTeamMembers);
                //bab     if (callSetAEs && acctTeamMembers )
                //bab       this.setAccountExecs(component, acctTeamMembers, true);
            }
        });
        $A.enqueueAction(action);
    },

    setIsUserOnAccountTeam: function (component, accountId) {
        var action = component.get("c.isCurrentUserOnAccountTeam");
        action.setParams({ 'acctId': accountId });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                var retVal = response.getReturnValue();
                //console.log('=======>> in setIsUserOnAccountTeam, retval:');
                component.set("v.isUserOnAccountTeam", retVal);
            }
        });
        $A.enqueueAction(action);
    },

    // Sets the list of account executives in the AccountTeamAEs attribute to be placed in a picklist for selection
    // if the current user is an AE, and navigateIfAE is true, then set values in known fields and redirect user to the standard
    // create record screen
    setAccountExecs: function (component, event, atms, navigateIfAE) {
        console.log('====================>> in setAccountExecs, atms:');
        console.log(atms);
        console.log('#################### navigateIfAE = ' + navigateIfAE);
        //      if ((atms == null || atms.length == 0) && navigateIfAE) {
        if (atms == null || atms.length == 0) {
            //console.log('#################### checking for AEs!');
            var haveError = component.get("v.errorThrown");
            //console.log('=========>> in setAccountExecs, haveError = ' + haveError);
            if (!haveError) {
                //console.log('[[[[[[[[[]]]]]]]] in haveError in setAccountExecs!!!!');
                component.set("v.errorThrown", true);
                //console.log('DISMISSACTIONPANEL 111');
                var dismissActionPanel = $A.get("e.force:closeQuickAction");
                dismissActionPanel.fire();
                //   history.go(-1);
            }
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "Error!",
                "type": "error",
                "mode": "sticky",
                "message": "Account must have an Account Executive or a Sales Manager on the Account Team in order to create an Opportunity on this Account"
            });
            toastEvent.fire();
        }
        var curUserId = component.get("v.curUserId");
        //console.log('**********---> curUserId = ' + curUserId);
        var oRecType = component.get("v.opptyRecordType");
        //console.log('**********---> oRecType = ' + oRecType);
        //console.log('**********---> atms = ' + atms);
        //console.log(atms);

        var aes = [];
        var aesList = [];
        var boomiAE = {};
        var loggedUserObj = {};
        if (atms) {
            //// IE11 insanity       for (var i in atms) {
            for (var i = 0; i < atms.length; i++) {
                if (i == 0) {
                    if (typeof atms[i].User.Profile !== 'undefined') {
                        //console.log('##########--->> setting curUserProfile to: ' + atms[i].User.Profile.Name);
                        component.set('v.curUserProfile', atms[i].User.Profile.Name);
                    }
                }
                var ae = {};
                //console.log('******** atms[i]:');
                //console.log(atms[i]);
                ae.Id = atms[i].User.Id;
                ae.Name = atms[i].User.Name;
                //if (navigateIfAE) {
                // SRSF-1333
                if (navigateIfAE && atms[i].TeamMemberRole != 'Sales Manager') {
                    console.log('$$$$$$$$$$$$----->> atms[i].TeamMemberRole ' + atms[i].TeamMemberRole);
                    if (typeof curUserId != "undefined" && curUserId == ae.Id) {  // current user is an ae, so just let him create an oppty
                        //console.log('$$$$$$$$$$$$----->> current user is an AE!!!');
                        if (typeof sforce !== 'undefined' && typeof sforce.one !== 'undefined') {
                            console.log('------>> found sforce one!');
                            sforce.one.createRecord('Opportunity', oRecType);
                        } else {
                            //console.log('User is an AE!  ------------------>> Agency__c = ' + component.get("v.agency"));
                            //console.log('User is an AE!  ------------------>> Rep_Firm__c = ' + component.get("v.repFirm"));
                            //console.log('-------------------------->> ae.Id = ' + ae.Id);
                            var agency = component.get("v.agency");
                            var repFirm = component.get("v.repFirm");
                            //var holdingAccount = component.get("v.holdingAccount"); //SRSF-4392
                            //console.log('!@#$%^----->> agency:');
                            //console.log(agency);
                            var networksToAvoid = component.get("v.networksToAvoid");
                            var acctId = component.get("v.id");
                            var createRecordEvent = $A.get("e.force:createRecord");
                            var isCreateContact = component.get("v.isCreateContact");
                            if (isCreateContact) {
                                var contractRecordType = component.get('v.contractRecordType');
                                if (typeof contractRecordType == 'undefined') {
                                    //alert("Yes..");
                                    this.setContactRTs(component, event, true);
                                } else {
                                    //console.log('------->> ShippingStreet = ' + component.get('v.ShippingStreet'));
                                    createRecordEvent.setParams({
                                        "entityApiName": "Contact",
                                        "recordTypeId": contractRecordType,
                                        'defaultFieldValues': {
                                            'AccountId': acctId,
                                            'MailingStreet': component.get('v.ShippingStreet'),
                                            'MailingCity': component.get('v.ShippingCity'),
                                            'MailingState': component.get('v.ShippingState'),
                                            'MailingPostalCode': component.get('v.ShippingPostalCode'),
                                            'MailingCountry': component.get('v.ShippingCountry')
                                        }
                                    });
                                    createRecordEvent.fire();
                                }

                            } else {        // not creating contact, creating opportunity
                                console.log('-----__>> firing createRecord event, agency = ' + agency);
                                createRecordEvent.setParams({
                                    "entityApiName": "Opportunity",
                                    "recordTypeId": oRecType,
                                    'defaultFieldValues': {
                                        'AccountId': acctId,
                                        'Created_By_Account_Executive__c': true,
                                        'Agency_Account__c': agency,
                                        'Rep_Firm__c': repFirm,                                        
                                        'Temp_AE_Id__c': curUserId,
                                        'Networks_to_Avoid__c': networksToAvoid
                                    }
                                });
                                //createRecordEvent.fire();
                            }
                            /*
                            //console.log('&&&&&********(((((((())))))))');
                            window.setTimeout(
                              $A.getCallback(function() {
                                  //console.log('10101010@@@@@########$$$$$$$$$$%%%%%%%%^^^^^^^^');
                                  $A.get("e.force:closeQuickAction").fire();
                              }), 10000
                          );
                          */

                        } // end of outer else                  
                    }
                }
                //Code Changes for SRSF  - 1672 Starts here
                if (ae.Id == curUserId) {
                    loggedUserObj = ae;
                }
                else if (ae.Name == 'Boomi Integration User') {
                    boomiAE = ae;
                }
                else
                    aesList.push(ae);
                //Code Changes for SRSF  - 1672 ends here
            }
            //Code Changes for SRSF  - 1672 Starts here
            /*
            var isCreateCont = component.get("v.isCreateContact");
                if (!isCreateCont && component.get("v.UserProfileName") == 'Master - Account Executive') {
              if(loggedUserObj.Name!=null && loggedUserObj.Name!=undefined) aes.push(loggedUserObj);
            }
            else{ */
            if (loggedUserObj.Name != null && loggedUserObj.Name != undefined) aes.push(loggedUserObj);
            for (i = 0; i < aesList.length; i++) {
                aes.push(aesList[i]);
            }
            if (boomiAE.Name != null && boomiAE.Name != undefined) aes.push(boomiAE);

            //Code Changes for SRSF  - 1672 ends here
        } else {
            aes = { "text": " ", "label": " " };

        }
        console.log('--------->> aes:');
        console.log(aes);
        component.set("v.AccountTeamAEs", aes);
        if (aes[0] != null && aes[0].Id != null) {
            component.set("v.currentAEId", aes[0].Id); // SRSF-1672
            //component.set("v.aePicklist" , aes[0].Id);
        }

    },



    /*  Orignial (pre-cross object) function  
        getObjMap : function(component) {
            var action = component.get("c.getQueryFields");
            var obType = component.get("v.objectType");
            //console.log('----->> obType = ' + obType);
            action.setParams({ objectType : component.get("v.objectType") });
            //console.log(action);
            action.setCallback(this, function (response) {
                var state = response.getState();
                if (component.isValid() && state === "SUCCESS") {
                    var retVal = response.getReturnValue();
                    var retValSize = Object.keys(retVal).length;
                    //console.log('------------>> retValSize = ' + retValSize);
                    //console.log('======>> retVal:');
                    //console.log(retVal);
                    component.set("v.objMap", retVal);
                    var fields = 'Id, ';
                    var whereClause = ' where ';
                    for (var key in retVal)  {
                        //console.log('========>> key = ' + key);
                        if (retVal.hasOwnProperty(key)) {
                            //console.log('----------->> retVal[key] = ' + retVal[key].Field_To_Search__c);
                            fields += retVal[key].Field_To_Search__c + ', ';
                            whereClause += retVal[key].Field_To_Search__c + ' LIKE ' + "'%---ReplaceMe---%'" + ' OR ';
                        }
                    }
                    fields = fields.slice(0, -2);       // remove the last comma and space
                    whereClause = whereClause.slice(0, -3); // remove the last 'OR ' 
                    component.set("v.searchFields", fields);
                    component.set("v.whereClause", whereClause);
                }
            });
            $A.enqueueAction(action);
        },
    */

    // getObjMap builds a list of query objects (which contains query information and display info as well)
    getObjMap: function (component) {
        var action = component.get("c.getQueryFields");
        //console.log('###############----->> action = ' + action);
        var obType = component.get("v.objectType");
        var numRecs = component.get("v.numRecords");
        var nestedQuery = component.get("v.nestedQuerySOQL");
        //console.log('----->> obType = ' + obType);
        //console.log('----->> nestedQuery = ' + nestedQuery);
        action.setParams({ objectType: obType });
        //console.log('--------->> after setParams');
        //console.log(action);
        var queryObject = [];
        var HTMLMarkupObject = {};
        ////        var supWhere = component.get("v.supplementalWhereClause");
        ////    //console.log('---------------------------------->> supWhere = ' + supWhere);

        //console.log('--------->> before setCallback');
        action.setCallback(this, function (response) {
            //console.log('************--->> got call back, response:');
            //console.log(response);
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                var retVal = response.getReturnValue();
                var retValSize = Object.keys(retVal).length;
                //console.log('$$$$$$$$$$$$$--->  before setting v.objMap, retVal = ');
                //console.log(retVal);
                component.set("v.objMap", retVal);
                for (var key in retVal) {
                    var fields = 'Id, ';
                    var whereClause = ' where ( ';
                    var tempQueryObj = {};
                    var HTMLMarkup = {};
                    var tempHtmlMarkup = {};
                    for (var fieldName in retVal[key].fieldMap) {
                        var markup = {};
                        if (retVal[key].fieldMap.hasOwnProperty(fieldName)) {
                            fields += retVal[key].fieldMap[fieldName].Field_To_Search__c + ', ';
                            if (retVal[key].fieldMap[fieldName].Is_Searchable__c == true)
                                whereClause += retVal[key].fieldMap[fieldName].Field_To_Search__c + ' LIKE ' + "'%---ReplaceMe---%'" + ' OR ';

                            markup.HTMLStartTag = retVal[key].fieldMap[fieldName].HTML_Start_Tags__c;
                            markup.HTMLEndTag = retVal[key].fieldMap[fieldName].HTML_End_Tags__c;
                            markup.HTMLResultStartTag = retVal[key].fieldMap[fieldName].Result_HTML_Start_Tag__c;
                            markup.HTMLResultEndTag = retVal[key].fieldMap[fieldName].Result_HTML_End_Tag__c;
                            tempHtmlMarkup[fieldName] = markup;
                        }
                    }

                    tempQueryObj.objectType = retVal[key].objectType;
                    tempQueryObj.fields = fields.slice(0, -2);       // remove the last comma and space
                    tempQueryObj.whereClause = whereClause.slice(0, -3); // remove the last 'OR '
                    tempQueryObj.numRecords = numRecs;
                    tempQueryObj.nestedQuery = nestedQuery;     // See commment in objectLookupController.cls for an explanation of this field
                    queryObject.push(tempQueryObj);

                    HTMLMarkupObject[retVal[key].objectType] = tempHtmlMarkup;

                }
                //     //console.log('$$$$$$$$$$$$$--->  setting final 2 attributes');
                component.set("v.queryObject", queryObject);
                component.set("v.HTMLMarkup", HTMLMarkupObject);
            }
        });
        //console.log('==============>> before calling getQueryFields');
        $A.enqueueAction(action);
        //console.log('==============>> after calling getQueryFields');
    },

    getObjKeyMap: function (component) {
        var action = component.get("c.getObjectKeys");
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                //    //console.log('###############--->> object keys:');
                //    //console.log(response.getReturnValue());
                component.set("v.sobjectKeys", response.getReturnValue());
            }
        });
        $A.enqueueAction(action);
    },

    getOpptyStages: function (component) {
        var action = component.get("c.getOpportunityStages");
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                //console.log('###############--->> Opportunity Stages:');
                //console.log(response.getReturnValue());
                component.set("v.opptyStages", response.getReturnValue());
            }
        });
        $A.enqueueAction(action);
    },
    /* Code Added for SRSR-1672 Starts Here */
    getSalesProbability: function (component) {
        var action = component.get("c.getSalesProbability");
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                component.set("v.opptySalesProbList", response.getReturnValue());
            }
        });
        $A.enqueueAction(action);
    },
    getFirstLookFields: function (component) {
        var action = component.get("c.getFirstLookFields");
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                var result = response.getReturnValue();
                   //SRSF-4770 start
                 var options=[];
              // for (var i = 0; i < result.length; i++) {
   // let s = result[i]; // Get the current item
    let itr = {
        label:'2025 First Look',
        value:'2025 First Look'
    };
    options.push(itr); // Add the object to the options array
//}
                component.set("v.getFirstLookList", options);
               // component.set("v.getFirstLookList", result);
                if (result.length > 0) {
                    //component.set("v.FirstLookVal", result[0]);
                }
                  //SRSF-4770 end
            }
        });
        $A.enqueueAction(action);
    },

    getDMAValues: function (component) {
        var dmaMap = [];   // SRSF-2306
        var aeId = component.get("v.currentAEId");
        //var aeId  = $A.get("$Label.c.BoomiUserId");
        //var aeId = $A.get("$SObjectType.CurrentUser.Id");
        //var aeId = component.find("aePicklist").get("v.value");
        console.log('------------->> aeId In Helper= ' + aeId);
        var action = component.get("c.getBudgetDMAValue");
        action.setParam("userId", aeId);
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                for (var key in result) {
                    /* component.set("v.BudgetDMAs", result[key]);*/ // Commented : SRSF-2306
                    component.set("v.DMASelected", key);
                    dmaMap.push({ key: key, value: result[key] }); // SRSF-2306
                }
                component.set("v.dmaMap", dmaMap);  // SRSF-2306
            }
        });
        $A.enqueueAction(action);
    }, /* Code Added for SRSR-1672 Ends Here */

    setOpptyAttributes: function (component) {
        component.set("v.createButtLabel", "Add Advertiser");
        component.set("v.objectType", "Account");
        component.set("v.numRecords", "10");
        component.set("v.createObjectType", "Opportunity");
        component.set("v.showObjDetails", "false");
        component.set("v.showRTselector", "false");
    },

    getAgencyRT: function (component) {
        var action = component.get("c.getAccountAgencyRT");
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                //console.log('###############--->> Opportunity Advertiser RecordType Id = ' + response.getReturnValue());
                //console.log(response.getReturnValue());
                component.set("v.accountAgencyRecType", response.getReturnValue());
            }
        });
        $A.enqueueAction(action);
    },

    generateSupplemental: function (component, agencyRT, userId) {
        //    var swc = "AND Id in (SELECT AccountId FROM AccountTeamMember where userId = '" + userId + "' )  and RecordTypeId = '" + agencyRT + "'";  IMHO, this is the right query, but SR disagrees :(
        //   var swc = "AND RecordTypeId = '" + agencyRT + "'";
        var swc = "AND Advertiser_Account__c = true";
        //console.log('------------------->> supplementaWhereClause = ' + swc); 
        component.set("v.supplementalWhereClause", swc);
    },

    navToSObject: function (objectId) {
        if (typeof sforce !== 'undefined' && typeof sforce.one !== 'undefined') {
            //console.log('Navigating to object Id = ' + objectId);
            sforce.one.navigateToSObject(objectId);
        } else {
            //console.log('&&&&&&&&&&&&&&&&&&&&&&----->> navigating via navToSObjEvt!!!');
            var navToSObjEvt = $A.get("e.force:navigateToSObject");
            navToSObjEvt.setParams({
                'recordId': objectId
            });
            navToSObjEvt.fire();

        }
    },


    setRecTypePicklist: function (component) {
        //console.log('-------------->> in setRecTypePicklist!!!');
        // ditching the object agnostic rectype picklist for now       var action = component.get("c.getRecTypeMap");
        //       action.setParams({objectType : component.get("v.createObjectType")});
        var action = component.get("c.getAccountRecTypeInfo");
        action.setCallback(this, function (response) {
            var state = response.getState();

            if (component.isValid() && state === "SUCCESS") {
                var retVal = response.getReturnValue();
                //console.log('%%%%%%%%%%%--->> retVal:');
                //console.log(retVal);
                var optMap = [];
             var allowedProfiles = $A.get("$Label.c.Profile"); // Custom label containing the list of profiles SRSF-5212

             var userProfile = component.get("v.UserProfileName"); // SRSF-5212


                //// IE11 insanity      for (var key in retVal) {
                for (var key = 0; key < retVal.length; key++) {
                    var menuItem = {};
                    menuItem.class = "optionClass";
                    menuItem.label = retVal[key].recordTypeName;
                    menuItem.value = retVal[key].recordTypeId;
                    if (retVal[key].isDefault) {
                        component.set("v.defaultRecordTypeText", retVal[key].recordTypeName);
                        component.set("v.defaultRecordType", retVal[key].recordTypeId);
                        component.set("v.selectedRecordType", retVal[key].recordTypeId);
                        component.set("v.selectedRecordTypeText", retVal[key].recordTypeName);
                    }
                       // Check for the Rep Firm record type and logged-in user's profile SRSF-5212

                  if (retVal[key].recordTypeDeveloperName == 'Rep_Firm' && !allowedProfiles.includes(userProfile)) { //SRSF-5212

                  continue; // Skip adding Rep Firm if the user's profile is not in the allowed profiles

                        }
                 if (component.get("v.userType") == '' || (component.get("v.userType") != undefined && component.get("v.userType").toUpperCase() == 'LOCAL')) {
                        //Start SRSF-4485
                        if (component.get("v.UserProfileName") == 'Master - Enterprise Digital') {
                            optMap.push(menuItem);
                        }
                        //End SRSF-4485
                        else if (retVal[key].recordTypeDeveloperName == 'In_House_Agency_Account') {
                            optMap.push(menuItem);
                        }
                    }
                    else {
                        optMap.push(menuItem);
                    }
                }
                if (component.get("v.recordTypeId__c") != undefined) {
                    component.set("v.defaultRecordTypeText", component.get("v.recordTypeName__c"));
                    component.set("v.defaultRecordType", component.get("v.recordTypeId__c"));
                    component.set("v.selectedRecordType", component.get("v.recordTypeId__c"));
                    component.set("v.selectedRecordTypeText", component.get("v.recordTypeName__c"));
                }
                component.set("v.recTypeSelect", optMap);
            }
        });
        $A.enqueueAction(action);
    },


    // delay typing to not call the lookup so often: 220 ms is good threshold
    delay: function () {
        var timer = 0;
        return function (callback, ms) {
            clearTimeout(timer);
            timer = setTimeout(callback, ms);
        };
    },

    /* SRSF-873 believe no longer used

    setContactRoles: function (component, event) {
        //console.log('============================>>in helper, setContactRoles');
        //console.log('component:');
        //console.log(component);
        var action = component.get("c.getContactRoles");

        //console.log('---> action: ');
        //console.log(action);
        action.setCallback(this, function (response) {
            var state = response.getState();
            //console.log('============================>>in helper, setContactRoles, state = ' + state);
            if (component.isValid() && state === "SUCCESS") {
                var retVal = response.getReturnValue();
                component.set("v.contactRoles", retVal);
                //console.log('%%%%%%%%%%%%%%%%%%%%--->> contactRoles = ' + retVal);
            }
        });
        $A.enqueueAction(action);
    },
    */

    // sets the contactRecordTypes attribute with a list of Contact RecordTypes
    // if createRec = true, then create a Contact record and redirect the user to that record
    setContactRTs: function (component, event, createRec) {
        //console.log('============================>>in helper, setContactRTs');
        //console.log('component:');
        //console.log(component);
        var action = component.get("c.getAvailRecordTypes");
        action.setParams({
            'objectApiName': 'Contact'
        });
        //console.log('---> action: ');
        //console.log(action);
        action.setCallback(this, function (response) {
            var state = response.getState();
            //console.log('============================>>in helper, setContactRTs, state = ' + state);
            if (component.isValid() && state === "SUCCESS") {
                var retVal = response.getReturnValue();
                //console.log('%%%%%%%%%%%%%%%%%%%%--->> contactRecordTypes: '+retVal);
                //console.log(retVal);
                var recTypes = [];
                for (var key in retVal) {
                    //console.log('key = ' + key);
                    //console.log('value = ' + retVal[key]);
                    recTypes.push({ value: retVal[key], Id: key });
                }
                //console.log('selected record type-->'+component.get("v.selectedRecordTypeText"));
                component.set("v.contactRecordTypes", recTypes);
                var acctRTName = component.get("v.selectedRecordTypeText");
                //console.log('%%%%%%%%%%%%%%%%%%%%--->> acctRTName = ' + acctRTName);
                //////  consider setting a change event handler for this        this.setContactRecordType(component, acctRTName);
                if (createRec) {

                    var objAcc = component.get("v.selectedRecord", retVal);
                    //alert(objAcc.RecordType.Name);
                    var acctRecType = objAcc.RecordType.Name;
                    var accTypeSplit = acctRecType.split(' ');
                    var accType = accTypeSplit[0];
                    for (var i = 0; i < recTypes.length; i++) {
                        //alert(recTypes[i].value);
                        var contactSplit = recTypes[i].value.split(' ');
                        //console.log('##############=====>>  contactSplit[0] = ' + contactSplit[0]);
                        //alert(contactSplit[0]+'<->'+accType)
                        if (contactSplit[0] == accType) {
                            //alert('Matched')
                            //    component.set('v.contractRecordType', recTypes[0].value);
                            //console.log('##############=====>>  contractRecordType name is: ' + recTypes[i].value);
                            component.set('v.contractRecordType', recTypes[i].Id);
                            //console.log('##############=====>> setting stinking contractRecordType to ' + recTypes[i].Id);
                            break;
                        }
                    }

                    var createRecordEvent = $A.get("e.force:createRecord");
                    createRecordEvent.setParams({
                        "entityApiName": "Contact",
                        "recordTypeId": component.get('v.contractRecordType'),
                        "defaultFieldValues": {
                            'AccountId': component.get('v.id'),
                            'MailingStreet': component.get('v.ShippingStreet'),
                            'MailingCity': component.get('v.ShippingCity'),
                            'MailingState': component.get('v.ShippingState'),
                            'MailingPostalCode': component.get('v.ShippingPostalCode'),
                            'MailingCountry': component.get('v.ShippingCountry')
                        }
                    });
                    //console.log('%%%%%%%%%%%%%%%%%%%%--->> before createRecord');
                    createRec = false;
                    createRecordEvent.fire();
                    var dismissActionPanel = $A.get("e.force:closeQuickAction");
                    dismissActionPanel.fire();
                }
                this.setAdContactTypes(component, event);
            }
        });
        $A.enqueueAction(action);
    },
    /*  SRSF-873 Believe this is no longer used
        setAccountRTs: function (component, event) { 
            //console.log('============================>>in helper, setContactRTs');
            //console.log('component:');
            //console.log(component);
            var action = component.get("c.getAvailRecordTypes");
            action.setParams ({
                'objectApiName' : 'Account'
            });
            //console.log('---> action: ');
            //console.log(action);
            action.setCallback(this, function (response) {
                var state = response.getState();
                //console.log('============================>>in helper, setAccountRTs, state = ' + state);
                if (component.isValid() && state === "SUCCESS") {
                    var retVal = response.getReturnValue();
                    //console.log('%%%%%%%%%%%%%%%%%%%%--->> accountRecordTypes: ');
                    //console.log(retVal);
                    var recTypes = [];
                    for (var key in retVal) {
                        //console.log('key = ' + key);
                        //console.log('value = ' + retVal[key]);
                        recTypes.push({value:retVal[key], Id:key});
                    }
                    component.set("v.accountRecordTypes", recTypes);
                }
            });
            $A.enqueueAction(action);
        },
    
        getAccountRecTypeId : function (component, event, accRecTypeName) {
            var accRecTypes = component.get("v.accountRecordTypes");
            //console.log('--------->> in getAccountRecTypeId, accRecTypeName = ' + accRecTypeName);
            //console.log('--------->> accRecTypes:');
            //console.log(accRecTypes);
        },
    */
    setAdContactTypes: function (component, event) {
        //console.log('============================>>in helper, setAdContactTypes');
        //console.log('component:');
        //console.log('component--');
        var action = component.get("c.getAdContactTypes");
        var recTypeInfo = component.get('v.selectedRecord');
        //console.log(recTypeInfo);
        //alert(recTypeInfo);
        action.setParams({
            'recordId': component.get('v.recordId')
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            //console.log('============================>>in helper, setAdContactTypes, state = ' + state);
            if (component.isValid() && state === "SUCCESS") {
                var retVal = response.getReturnValue();
                //console.log('%%%%%%%%%%%%%%%%%%%%--->> setAdContactTypes: ');
                //console.log(retVal);
                var recTypes = [];
                for (var key in retVal) {
                    //console.log('key = ' + key);
                    //console.log('value = ' + retVal[key]);
                    if (key == 0)
                        component.set("v.adConTypePicklist", retVal[key]);
                    recTypes.push({ value: retVal[key], Id: key });
                }
                component.set("v.AdContactType", recTypes);
            }
        });
        $A.enqueueAction(action);
    },

    // checks to ensure fields are populated and valid, then calls saveContact, which does the save
    createContact: function (component, event, forceCreate) {
        var firstName = component.get('v.firstName');
        console.log('firstName:' + firstName);
        /*alert('firstName:'+firstName);
        if (typeof firstName == 'undefined' ) {
            firstName = '';
        }
        //console.log('===========>> firstName = ' + firstName);*/
        var lastName = component.get('v.lastName');
        console.log('lastName:' + lastName);
        /*alert('lastName:'+lastName);
        if (typeof lastName == 'undefined' || lastName == null) {
            //console.log('=====>> need lastName!!!');
            var lm = component.find('lastName');
            lm.showHelpMessageIfInvalid();
        }*/

        var title = component.get('v.title');
        /*alert('title:'+title);
        if (typeof title == 'undefined' || title == null) {
            //console.log('=====>> need email!!!');
            //var tm = component.find('title');
            //tm.showHelpMessageIfInvalid();
            title = '';
        }*/

        var email = component.get('v.email');
        console.log('email:' + email);
        /*alert('email:'+email);
        if (typeof email == 'undefined' || email == null) {
            //console.log('=====>> need email!!!');
            var em = component.find('email');
            em.showHelpMessageIfInvalid();
        }*/
        var ae = component.get('v.aePicklist');
        console.log('ae:', ae);
        // alert('ae:'+ae);
        if (!ae) {
            var firstAE = component.get('{!v.AccountTeamAEs}');
            console.log('firstAE', firstAE);
            if (firstAE[0] && firstAE[0].Id) {
                ae = firstAE[0].Id;
            }
        }

        var adConType = component.get('v.adConTypePicklist');
        /*alert('adConType:'+adConType);
        if (typeof adConType == 'undefined') {
            var firstAdConType = component.get('{!v.AdContactType}');
            //console.log('------>> firstAdConType:');
            //console.log(firstAdConType);
            //console.log(firstAdConType[0].value);
            adConType = firstAdConType[0].value;
        }*/
        //console.log('===========>> adConType = ' + adConType);

        var phone = component.get('v.Phone');
        /*alert('phone:'+phone);
        if (typeof phone == 'undefined' || phone == null) {
            //var pm = component.find('Phone');
            //pm.showHelpMessageIfInvalid();
            phone='';
        }*/

        var mobile = component.get('v.Mobile');
        /*alert('mobile:'+mobile);
        if (typeof mobile == 'undefined' || mobile == null) {
            //console.log('=====>> need email!!!');
            //var mm = component.find('Moblie');
            //mm.showHelpMessageIfInvalid();
            mobile = '';
        }*/

        var street = component.get('v.street');
        /*alert('street:'+street);
        if (typeof street == 'undefined' || street == null) {
            //console.log('=====>> need email!!!');
            //var sm = component.find('street');
            //sm.showHelpMessageIfInvalid();
            street = '';
        }*/

        var city = component.get('v.city');
        /*alert('city:'+city);
        if (typeof city == 'undefined' || city == null) {
            //console.log('=====>> need email!!!');
            //var cm = component.find('city');
            //cm.showHelpMessageIfInvalid();
            city = '';
        }*/

        var state = component.get('v.state');
        /*alert('state:'+state);
        if (typeof state == 'undefined' || state == null) {
            //console.log('=====>> need email!!!');
            //var sm = component.find('state');
            //sm.showHelpMessageIfInvalid();
            state = '';
        }*/

        var zip = component.get('v.zip');
        /*alert('zip:'+zip);
        if (typeof zip == 'undefined' || zip == null) {
            //console.log('=====>> need email!!!');
            //var zm = component.find('zip');
            //zm.showHelpMessageIfInvalid();
            zip = '';
        }*/

        var country = component.get('v.country');
        /*alert('country:'+country);
        if (typeof country == 'undefined' || country == null) {
            //console.log('=====>> need email!!!');
            //var cm = component.find('country');
            //cm.showHelpMessageIfInvalid();
            country = '';
        }*/

        if (lastName && email && ae && adConType) {
            console.log('********  calling saveContact with forceCreate = ' + forceCreate);
            this.saveContact(component, event, firstName, lastName, email, ae, adConType, title, phone, mobile, street, city, state, zip, country, forceCreate);
        }
    },

    checkValid: function (fieldid, fieldname) {
        var allValid = component.find('fieldId').reduce(function (validSoFar, inputCmp) {
            inputCmp.showHelpMessageIfInvalid();
            return validSoFar && !inputCmp.get('v.validity').valueMissing;
        }, true);
        return allValid
    },


    saveContact: function (component, event, firstName, lastName, email, aeId, adConType, title, phone, mobile, street, city, state, zip, country, forceCreate) {
        console.log('********  in saveContact with forceCreate = ' + forceCreate);
        var accountRecId = component.get("{!v.recordId}");
        var acrtid = component.get('v.selectedRecordTypeText');
        console.log('acrtid = ' + acrtid);
        this.setContactRecordType(component, acrtid);
        console.log('==========>> accountRecId = ' + accountRecId);
        console.log('============================>>in helper, saveContact');
        var action = component.get("c.createNewContact");
        var contactRecTypeId = component.get('v.contractRecordType');
        //alert(adConType);
        action.setParams({
            'fName': firstName,
            'lName': lastName,
            'emailAddr': email,
            'aeId': aeId,
            'recTypeId': contactRecTypeId,
            'acctId': accountRecId,
            'adConType': adConType,
            'strTitle': title,
            'strPhone': phone,
            'strMobile': mobile,
            'strStreet': street,
            'strCity': city,
            'strState': state,
            'strZip': zip,
            'strCountry': country,
            'forceSave': forceCreate
        });

        action.setCallback(this, function (response) {
            var state = response.getState();
            console.log('============================>>in helper, saveContact, state = ' + state);
            if (component.isValid() && state === "SUCCESS") {
                ////   var dismissActionPanel = $A.get("e.force:closeQuickAction");
                ////    dismissActionPanel.fire();
                var retVal = response.getReturnValue();
                //console.log('=====>> retval:');
                //console.log(retVal);
                console.log(retVal.result);
                if (retVal.result == 'ERROR') {
                    console.log('**************** found an error!!!  **********');
                    var toastEvent = $A.get("e.force:showToast");
                    //console.log('toastEvent = ');
                    //console.log(toastEvent);
                    //console.log('errorMessage = ');
                    console.log(retVal);

                    toastEvent.setParams({
                        "type": "error",
                        "title": "Error occured creating Contact: " + retVal,
                        "mode": "sticky",
                        "message": retVal
                    });
                    //console.log('!!!!!!!!!!!!!!!!!  firing toastEvent!!!!!!!!!!!');
                    toastEvent.fire();
                } else if (retVal.result == 'DUPLICATES FOUND') {
                    //console.log('!!!-------------==========>> DUPLICATES found!!!');
                    component.set('v.duplicateRecordsFound', retVal.duplicateRecords);
                    var insertMarkupDiv = component.find("insertMarkupDiv");
                    //console.log('=====>> insertMarkupDiv = ' + insertMarkupDiv);
                    //console.log('*******  dupContactDiv = ' + component.find('dupContactDiv'));
                    var dupModal = component.find('dupContactPopup');
                    //console.log('!!!@@@ >>>> ----->> dupModal = ' + dupModal);
                    ////  dupModal.show();
                    //console.log('*******  dupContactDivNC = ' + component.find('dupContactDivNC'));
                    var dupModalNC = component.find('dupContactPopupNC');
                    //console.log('!!!@@@ >>>> ----->> dupModalNC = ' + dupModalNC);
                    dupModalNC.show();
                } else {
                    //console.log('==========>> create contact succeeded!  Id = ' + retVal.result);
                    var navToSObjEvt = $A.get("e.force:navigateToSObject");
                    navToSObjEvt.setParams({
                        "recordId": retVal.result
                    });
                    navToSObjEvt.fire();
                }
            }

        });
        $A.enqueueAction(action);
    },
    // START : SRSF-3571
    getSelectedDMAValues: function (component, event, helper) {        
        var selected = document.getElementById('multiselect');        
        var selectedDMAs = getSelectedOption(selected);        
        function getSelectedOption(selected) {
            var opt;
            var selectedDMA = '';
            for (var i = 0, len = selected.options.length; i < len; i++) {
                opt = selected.options[i];
                if (opt.selected === true) {
                    selectedDMA = selectedDMA + ',' + opt.value;
                }
            }
            selectedDMA = selectedDMA.substring(1);
            return selectedDMA;
        }
        component.set("v.selectedDMAs", selectedDMAs);
        var resultCmp = component.find("multiResult");
        resultCmp.set("v.value", selectedDMAs);
        $A.util.addClass(resultCmp, "textClass");
    },
    // END : SRSF-3571
    // START : SRSF-4392  
    // getDemandSupplyPlatforms : function(component, fieldName){
    getPicklistValues : function(component, fieldName){
        var action = component.get("c.getPicklistValues");
        action.setParams({ 'fieldName' : fieldName});
        action.setCallback(this, function(response) {
            console.log ('response-1>>>>'+response);
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {                    
                var options = [];
                var result = response.getReturnValue();
                for (var i = 0; i < result.length; i++) {
                    options.push({
                        label: result[i],
                        value: result[i]
                    });
                }                    
                if(fieldName == 'Demand_Side_Platform__c'){
                    component.set("v.dsPlatformList", options);
                } 
                else if(fieldName == 'Supply_Side_Platform__c'){
                    component.set("v.ssPlatformList", options);
                }
                else if(fieldName == 'Business_Classification__c'){ // SRSF-4604
                    component.set("v.businessClassList", options);
                } 
                /*else if(fieldName == 'Discount_Code__c'){ // SRSF-4927
                    component.set("v.discountCodeList", options);
                }*/ 
            }
        });
        $A.enqueueAction(action);      
    }
    // END : SRSF-4392
})