({

  doInit : function(component, event, helper) {
     //alert("Do Init");
     helper.getUserId(component);
     helper.getUserProfileName(component);  //SRSF - 1672     
      
   // SRSF-873  helper.setAccountRTs(component, event);

     component.set('v.LEXBaseURL', $A.get("$Label.c.LEX_Base_URL"));
     component.set('v.LEXObjectURL', $A.get("$Label.c.LEX_sObject_URL"));
      //SRSF-4770 start
     component.set('v.firstLookVisibility', $A.get("$Label.c.firstLookforNewOpportunity"));
        //SRSF-4770 end
     //console.log('=========================================================================');
      var isCreateContact = component.get("v.isCreateContact");
      var recId = component.get("v.recordId");
       if (recId !== "undefined" && recId != null && (component.get("v.sObjectName") == 'Account')) {
           //alert("Account Info.")createOpportunity
           helper.getAcctInfo(component, recId);
      }
      if (isCreateContact) {
//////          helper.setContactRoles(component, event);
          //alert("isCreateContact")
          helper.setContactRTs(component, event, false);
          //helper.setAdContactTypes(component, event);
      }


    var SObjectName = component.get("v.sObjectName");
    //console.log('SObjectName = ' + SObjectName);
    if (SObjectName == 'Opportunity') {
        helper.getAgencyRT(component);
        helper.setOpptyAttributes(component);
    }


    //console.log('==============>> before getObjMap');      
    helper.getObjMap(component);
    //console.log('==============>> before getKeyMap');
    helper.getObjKeyMap(component);
    helper.setRecTypePicklist(component);
    
    var isCreateOppty = component.get("v.isCreateOppty");

    if (isCreateOppty) {
        var blankATM = {"text" : " ", "label" : " " } ;
        component.set("v.AccountTeamAEs", blankATM);
        helper.getOpptyStages(component); 
        helper.getSalesProbability(component);  // SRSF -1672
        helper.getFirstLookFields(component);   // SRSF -1672               
        // helper.getDemandSupplyPlatforms(component, 'Demand_Side_Platform__c'); // SRSF-4392
       // helper.getDemandSupplyPlatforms(component, 'Supply_Side_Platform__c'); // SRSF-4392   
        helper.getPicklistValues(component, 'Demand_Side_Platform__c'); // SRSF-4392
        helper.getPicklistValues(component, 'Supply_Side_Platform__c'); // SRSF-4392            
        helper.getPicklistValues(component, 'Business_Classification__c'); // SRSF-4604 
        //helper.getPicklistValues(component, 'Discount_Code__c'); // SRSF-4927           
    }
      
  }, /* Code Added for SRSR-1672 Starts Here */
     getDMAValues : function(component,event,helper) { 
        var aeId = event.getParam("AEId");
        var dmaMap = [];  // SRSF-2306
        console.log('------------->> aeId in getParam = ' + aeId);
        var action = component.get("c.getBudgetDMAValue");
        action.setParam("userId", aeId);
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                for(var key in result){
                    /* component.set("v.BudgetDMAs", result[key]);*/ // Commented for SRSF-2306
                   component.set("v.DMASelected",key);
                   dmaMap.push({key: key, value: result[key]});   // SRSF-2306                   
                }
                component.set("v.dmaMap", dmaMap);  // SRSF-2306
            }
        });
        $A.enqueueAction(action);        
    }, /* Code Added for SRSR-1672 Ends Here */
    
    // keyPressController manages all of the type ahead functionality
    keyPressController : function(component, event, helper) {

        var newObjectButt = component.find("newObjectButton");
        var newObjectButt1 = component.find("newObjectButton1");
        var newObjectButtDiv = component.find("newObjectButtDiv");
        var newObjectButtDiv1 = component.find("newObjectButtDiv1");
        var showNewObjButt = component.get("v.showNewButton");
        var sbDiv;
        var sbDiv1;
        try {
            sbDiv = component.find("insertMarkupAboveSaveButtDiv");
        } catch (err) {
          console.log("**************>> couldn't find insertMarkupDiv!");
        }
        try {
            sbDiv1 = component.find("insertMarkupAboveSaveButtDiv1");
        } catch (err) {
          console.log("**************>> couldn't find insertMarkupDiv1!");
        }
        var SObjectName = component.get("v.sObjectName");
          if (SObjectName == 'Opportunity') {
                
          }

 /* 
   // see: http://salesforce.stackexchange.com/questions/71557/delay-query-while-user-is-typing-in-lightning-component-search-bar
          var timer = component.get('v.timer');
        clearTimeout(timer);
  
        var timer = setTimeout(function(){  */  

       // get the search Input keyword   
                var getInputkeyWord = component.get("v.SearchKeyWord");
          //      var sbDiv = component.get("v.insertMarkupAboveSaveButtDiv");
          //      var sbDiv1 = component.get("v.insertMarkupAboveSaveButtDiv1");

              // check if getInputKeyWord size is more than 1 then open the lookup result List and 
              // call the helper 
              // else close the lookup result List part.   
                if( getInputkeyWord.length >= 3 ){
                     var forOpen = component.find("searchRes");
                       $A.util.addClass(forOpen, 'slds-is-open');
                       $A.util.removeClass(forOpen, 'slds-is-close');
                       if (showNewObjButt == true && SObjectName != 'Opportunity') {
                          $A.util.addClass(newObjectButt1, "slds-hide");
                          $A.util.removeClass(newObjectButt1, "slds-show");                       
                          $A.util.removeClass(newObjectButt, "slds-hide");
                          $A.util.addClass(newObjectButt, "slds-show"); 


                          if (sbDiv1 !== "undefined" ) {
                            //console.log('**********>> sbDiv1(3) = ' + sbDiv1); 
                            $A.util.addClass(sbDiv1, "slds-hide");
                            $A.util.removeClass(sbDiv1, "slds-show");
                            // bab2018
                            var cancelButt1 = component.find("v.cancelButton1");
                            $A.util.addClass(cancelButt1, 'slds-hide');
                            $A.util.removeClass(cancelButt1, 'slds-show');
                            var cancelButtLayout1 = component.find("v.cancelButtLayout1");
                            $A.util.addClass(cancelButtLayout1, 'slds-hide');
                            $A.util.removeClass(cancelButtLayout1, 'slds-show');
                        //    var x = document.getElementById("inLookup1");
                          //  x.style.display = "none";
                          }

                          if (sbDiv !== "undefined") { 
                            //console.log('**********>> sbDiv(3) = ' + sbDiv);                      
                            $A.util.removeClass(sbDiv, "slds-hide");
                            $A.util.addClass(sbDiv, "slds-show"); 
                          }
                          
                        } 





                    helper.searchHelper(component,event,getInputkeyWord);
                }
                else if( getInputkeyWord.length < 3 ){    // don't show results unless they've entered at least 3 chars
                    component.set("v.listOfSearchRecords", null ); 
                     var forclose = component.find("searchRes");
                       $A.util.addClass(forclose, 'slds-is-close');
                       $A.util.removeClass(forclose, 'slds-is-open');
                       if (getInputkeyWord.length >=1) {    // don't show buttons until they've entered at least one char
                          //console.log('==========>> showing button, getInputkeyWord.length = ' + getInputkeyWord.length);
                      //     $A.util.removeClass(newObjectButt, "slds-hide");
                       //    $A.util.addClass(newObjectButt, "slds-show"); 
                           if (showNewObjButt == true && SObjectName != 'Opportunity') {
                               $A.util.addClass(newObjectButt1, "slds-show");
                               $A.util.removeClass(newObjectButt1, "slds-hide"); 
                               $A.util.addClass(newObjectButtDiv1, "newObjectButtDiv");
                               $A.util.removeClass(newObjectButtDiv1, "slds-hide");
                               $A.util.addClass(newObjectButtDiv1, "newObjectButtDiv");  
                               $A.util.addClass(newObjectButtDiv1, "inlineOnRight"); 
                        //       $A.util.removeClass(inputSelect1, "slds-hide");
                              
                          if (sbDiv1 !== "undefined") { 
                                //console.log('**********>> sbDiv1(<3) = ' + sbDiv);                       
                               $A.util.removeClass(sbDiv1, "slds-hide");
                               $A.util.addClass(sbDiv1, "slds-show");
                             }
                             
                           }                                                   
                       } else {   // getInputKeyword.length == 0
                            //console.log('==========>> hiding button, getInputkeyWord.length = ' + getInputkeyWord.length);
                        if (sbDiv1 !== "undefined") {
                          //console.log('**********>> sbDiv1(0) = ' + sbDiv1);
                           $A.util.removeClass(sbDiv1, "slds-show");
                           $A.util.addClass(sbDiv1, "slds-hide");  
                        }   

                        if (sbDiv !== "undefined") {
                          //console.log('**********>> sbDiv(0) = ' + sbDiv);
                           $A.util.removeClass(sbDiv, "slds-show");
                           $A.util.addClass(sbDiv, "slds-hide");  
                        } 

                         //  $A.util.addClass(newObjectButt, "slds-hide");
                         //  $A.util.removeClass(newObjectButt, "slds-show");                       
                          $A.util.addClass(newObjectButt1, "slds-hide");
                           $A.util.removeClass(newObjectButt1, "slds-show"); 
                           
                   
                       }
                  }
/*            clearTimeout(timer);
            component.set('v.timer', 0);
        }, 1000);
    
        component.set('v.timer', timer);
 */        
  },

      generateSupWhere : function(component, event, helper) {
        //console.log('$$$$$$$$$$--->> in generateSupWhere');
          var agencyRT = component.get("v.accountAgencyRecType");
          var curUserId = component.get("v.curUserId");
          //console.log('$$$$$$$$$$$$$$$$$$--->> agencyRT = ' + agencyRT + ', curUserId = ' + curUserId);
          if (typeof agencyRT !== 'undefined' && agencyRT != '' && typeof curUserId !== 'undefined' && curUserId != '') {
              //console.log('================================>> calling helper.generateSupplemental!!!!!!!!!!');
              helper.generateSupplemental(component, agencyRT, curUserId);
          }
      },

      handleAccountTeams : function(component, event, helper) {
          var aTeams = component.get("v.accTeamMembers");
          //console.log('*****************************************************************---->> aTeams = ' + aTeams);
          //console.log('********************---->> aTeams:');
          console.log(aTeams);
          //alert('handleAccountTeams');
          helper.setAccountExecs(component, event, aTeams, true);
          helper.getDMAValues(component);
      } ,

      handleCreateRecordEvent : function(component, event) {
          //console.log('------->> in handleCreateRecordEvent!!!');
          var sobjType = event.getParam("entityApiName");
          //console.log('------->> sobjType = ' + sobjType);
      },

      recordTypeChange : function(component) {
          //console.log('@@@@@@@@@@@@@  in recordTypeChange!!!');
          var currentSelection = component.get("v.selectedRecordType");
          //console.log('----------->> currentSelection = ' + currentSelection);
          var curPickList = component.find("acctRecTypePickList");
          //console.log('----------->> curPickList = ' + curPickList);
          var selectedRecord = curPickList.get("v.value");
          //console.log('------------>> selectedRecord = ' + selectedRecord);
          component.set("v.selectedRecordType", selectedRecord);
      },

      recordTypeChange1 : function(component) {
          //console.log('@@@@@@@@@@@@@  in recordTypeChange1  !!!');
          var currentSelection = component.get("v.selectedRecordType");
          //console.log('----------->> currentSelection = ' + currentSelection);
          var curPickList = component.find("acctRecTypePickList1");
          //console.log('----------->> curPickList = ' + curPickList);
          var selectedRecord = curPickList.get("v.value");
          //console.log('------------>> selectedRecord = ' + selectedRecord);
          component.set("v.selectedRecordType", selectedRecord);
      },

  
      createObject : function(component, event, helper) {
          var callback = component.get("v.callback");
          var recType = component.get("v.selectedRecordType");
          var objectType = component.get("v.createObjectType");
          var myUITheme = component.get("v.myUITheme");
          var acctName = component.get("v.SearchKeyWord");
         ////   if (myUITheme && myUITheme == 'Theme4t') {  // Salesforce1 mobile
            if (typeof sforce !== 'undefined' && typeof sforce.one !== 'undefined') {  
                console.log('------>> found sforce one!');
                sforce.one.createRecord(objectType, recType);
            }
            /* this is for the VF page, which was removed
            else if (callback) {
              //console.log('############### calling the callback!!!');
              callback('createObject', null, recType);
            } 
            */else {
                //console.log("=====>> in createObject!!!");
                var createRecordEvent = $A.get("e.force:createRecord");
                           // for single SObject searches
                if (objectType.indexOf(',') > -1) {
                    objectType = component.get("v.createObjectType");     // for cross object searches
                }


                if (!recType) recType = component.get("v.defaultRecordType");
                //console.log('----------->> objectType = ' + objectType);
                //console.log('----------->> recType = ' + recType);
                //console.log('----------->> acctName = ' + acctName);
                createRecordEvent.setParams({
                    "entityApiName": objectType,
                    "recordTypeId" : recType,
                    'defaultFieldValues': {
                          'Name': acctName
                      }  
                });
                createRecordEvent.fire();
                //console.log('************************************  after createRecordEvent!!!!!!');
            }              
    },

    addAdvertiser : function(component, event, helper) {
        //console.log('==============================>> in addAdvertiser!!!!');
        var opptyId = component.get("v.recordId");
        //console.log('==============================>> opptyId = ' + opptyId);
        var objId = component.get("v.selectedRecord");
        var action = component.get("c.addAdAccount");
        action.setParams({
            'opptyId'             : opptyId,
            'advertiserAccount'   : objId.Id
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            //console.log('------------------->> addAdvertiser state = ' + state);
            if (component.isValid() && state === "SUCCESS") {
                var retVal = response.getReturnValue();
                //console.log('%%%%%%%%$$$$$$$--->> retVal = ' + retVal);
                //console.log('---------->> doing check for error');
        //        if (retVal.startsWith('ERROR')) { stupid IE doesn't support startswith
                if (retVal.indexOf('ERROR') === 0) {
                    var dismissActionPanel = $A.get("e.force:closeQuickAction");
                    dismissActionPanel.fire();
                     var toastEvent = $A.get("e.force:showToast");
                     toastEvent.setParams({
                        "title": "Error!",
                        "type" : "error",
                        "mode" : "sticky",
                        "message": "The following error occured while updating the Opportunity: " + retVal
                      });
                      toastEvent.fire();    
                } else {
                  var dismissActionPanel = $A.get("e.force:closeQuickAction");
                  dismissActionPanel.fire();                  
                  $A.get('e.force:refreshView').fire();   // refresh to see field updates
                  ////  helper.navToSObject(opptyId);
                }
            }
        });

        $A.enqueueAction(action);

    },

    navigateToOppty : function(component, event, helper) {
      var opptyId = component.get("v.opptyId");
      var opptyIdStr = '' + opptyId;
  //    var callback = component.get("v.callback");
      //console.log('###########--->> opptyId  (in navigateToOppty)= ' + opptyId);
 //     console.log('###########--->> callback = ' + callback);

      if (opptyIdStr.indexOf('ERROR:') > -1) {
          //console.log('**************  throwing error!');
          var dismissActionPanel = $A.get("e.force:closeQuickAction");
          dismissActionPanel.fire();
          var toastEvent = $A.get("e.force:showToast");
          toastEvent.setParams({
              "title": "Error!",
              "type" : "error",
              "mode" : "sticky",
              "message": opptyIdStr
          });
        toastEvent.fire(); 
      } else {
        helper.navToSObject(opptyId);
        /*
        if (typeof sforce !== 'undefined' && typeof sforce.one !== 'undefined') {
            //console.log('NAVIGATING!!!!');
            sforce.one.navigateToSObject(opptyId);
        } 
        
     //   else if (callback) {
       //     console.log('@@@@@@@@@@@@--->> calling callback!!!');
         //   callback('navigateToOppty', opptyId);
          //} 
          
          else {
                //console.log('&&&&&&&&&&&&&&&&&&&&&&----->> navigating via navToSObjEvt!!!');
                  var navToSObjEvt = $A.get("e.force:navigateToSObject");
                    navToSObjEvt.setParams({
                        'recordId': opptyId
                  }); 
                navToSObjEvt.fire();    
              } */
          }
    },

    createOpportunity : function(component, event, helper) {
        var okToSave = true;
        var opptyName;
        var acctId;
        var opptyStage;
        var closeDate;
        var ae;
        var createActivityVal;

        var opptyNameComp = component.find("opptyName");
        if (typeof opptyNameComp !== 'undefined') {
            opptyName = opptyNameComp.get("v.value");
            if (!opptyName) {
                okToSave = false;
                //console.log ('before opptyname set');
                opptyNameComp.set("v.errors", [{message:"Please enter an Opportunity name" }]);
                //console.log ('after opptyname set');
            } else {
                opptyNameComp.set("v.errors", null);
            }

        } else
            okToSave = false;
        //console.log('------------------>> opptyName = ' + opptyName);

        acctId = component.get("v.id");

        var closeDateComp = component.find("opptyCloseDate");
        if (typeof closeDateComp !== 'undefined') {
            closeDate = closeDateComp.get("v.value");
          if (!closeDate) {
              okToSave = false;
              closeDateComp.set("v.errors", [{message:"Please enter close date" }]);
          } else {
                closeDateComp.set("v.errors", null);
            }
        } else
            okToSave = false; 

        var opptyStageComp = component.find("opptyStagePicklist");
        if (typeof opptyStageComp !== 'undefined') {
           opptyStage = opptyStageComp.get("v.value");
          if (!opptyStage) {
              var stagePickList = component.find("opptyStagePicklist");
              var myStages = component.get("v.opptyStages");
              if (myStages[0]) {
                  opptyStage = myStages[0].ApiName;
                  stagePickList.set("v.value", opptyStage  );
              } else {
                  okToSave = false;
                  opptyStageComp.set("v.errors", [{message:"Please select an Opportunity stage" }]);                
              }

          } else {
                opptyStageComp.set("v.errors", null);
            }
        } else
            okToSave = false;  

        var  aeComp = component.find("aePicklist");
        if (typeof aeComp !== 'undefined') {
            ae = aeComp.get("v.value");
          if (!ae) {
              var aePicklist = component.find("aePicklist");
              var myAEs = component.get("v.AccountTeamAEs");
              if (myAEs[0]) {
                  ae = myAEs[0].Id;
                  aePicklist.set("v.value", ae );
              } else {
              okToSave = false;
              aeComp.set("v.errors", [{message:"Please select an Account Executive or Local Sales Manager to own this account" }]);
            }
          } else {
                aeComp.set("v.errors", null);
            }
        }  else {
          okToSave = false;
        }

        var agency = component.get('v.selectedAgencyId');
        var repFirm = component.get('v.selectedRepFirmId');
        var holdingAccount = component.get('v.selectedHoldingAccId'); // SRSF-4392

        /*console.log('------------------>> agency = ' + agency);
        console.log('------------------>> repFirm = ' + repFirm);

        console.log('------------------>> closeDateComp = ' + closeDateComp);
        console.log('------------------>> aeComp = ' + aeComp);  
        console.log('------------------>> acctId = ' + acctId);
        console.log('------------------>> closeDate = ' + closeDate);
        console.log('------------------>> opptyStage = ' + opptyStage);
        console.log('------------------>> ae = ' + ae);
        console.log('------------------>> okToSave = ' + okToSave);*/

        if (okToSave) {
            var userProfile = component.get("v.UserProfileName");  
           // var selectedDMA = component.find("aeDMA").get("v.value");  // Commented by Sridhar
            // Start: SRSF-3571
            if(userProfile!='Master - National Account Coordinator' && userProfile!='Master - National Sales Manager' 
                && userProfile!='Master - National Account Planner' && userProfile!='Master - National Sales Director' && userProfile!='Master - Enterprise Sales Manager'){
                component.set("v.selectedDMAs", component.find("aeDMA").get("v.value"));
            } else {
                helper.getSelectedDMAValues(component, event, helper);
            }
            var selectedDMA = component.get("v.selectedDMAs");
            // End: SRSF-3571
            if(selectedDMA=='None'){
                alert("Please Select DMA");
            }
            else if (confirm("You are trying to create Opportunity under '"+selectedDMA + "' DMA. Are you sure ?")){
            //console.log('in okToSave');
            var spinnerDiv = component.find("spinnerDiv");
            //console.log('======>> spinnerDiv: ');
            //console.log(spinnerDiv);
            $A.util.removeClass(spinnerDiv, "slds-hide");
            $A.util.addClass(spinnerDiv, "slds-show"); 
            //console.log('calling helper.saveOppty!!!!!!!!!!');
            if(selectedDMA=='None')
                selectedDMA ='';
            //alert(agency);
            if(agency=='' || agency == undefined)
                agency = null;
       /* Commeting for SRSF-4945 CAMA
           var faceToface = component.find("faceToface").get("v.value");
            var virtual = component.find("virtual").get("v.value");  
              // Commeting for SRSF-4945 CAMA*/
                if(component.get("v.showCreateActivity") == true){
                    createActivityVal = component.find("createActivity").get("v.value");
                }else{
                    createActivityVal = false;
                }
            if(holdingAccount=='' || holdingAccount == undefined) //SRSF-4392
                holdingAccount = null;
            helper.saveOppty(component, acctId, opptyName, opptyStage, closeDate, ae, agency, repFirm, holdingAccount, selectedDMA,createActivityVal); //SRSF-4392: Added holding account
           
//  helper.saveOppty(component, acctId, opptyName, opptyStage, closeDate, ae, agency, repFirm, selectedDMA,faceToface,virtual,createActivityVal); 

            // error handling will happen in navigateToOppty once the opptyId component gets updated
          }
        }

    }, 
    // Start: SRSF-3571   
    fetchDMAValues : function(component, event, helper) {
        helper.getSelectedDMAValues(component, event, helper);
    },
    // End: SRSF-3571
    setAccountInfo : function(component, event, helper) {
        var acct = component.get("v.selectedAccount");
        if (typeof acct !== "undefined") {
            component.set("v.id", acct.Id);
        }
    },

    checkAccountTeamMembership : function(component, event, helper) {
        var onAcctTeam = component.get("v.isUserOnAccountTeam");
        if (typeof onAcctTeam !== "undefined") {
          //console.log('--------_>> in checkAccountTeamMembership, onAcctTeam = ' + onAcctTeam);
          if (!onAcctTeam) {
             var haveError = component.get("v.errorThrown");
             //console.log('=========>> in checkAccountTeamMembership, haveError = ' + haveError);
             if (!haveError) {
                component.set("v.errorThrown", true);
                var dismissActionPanel = $A.get("e.force:closeQuickAction");
                dismissActionPanel.fire();
             //   this.cancelCreateOpportunity;
             //   history.go(-1);
             }
             var msg;
             var isCreateContact = component.get("v.isCreateContact");
             if (isCreateContact == true) {
                msg = "You must be on the Account Team in order to create a Contact on this Account"
             } else {
                msg = "You must be on the Account Team in order to create an Opportunity on this Account"
             }
             var toastEvent = $A.get("e.force:showToast");
             toastEvent.setParams({
                "title": "Error!",
                "type" : "error",
                "mode" : "sticky",
                "message": msg
              });
              toastEvent.fire();    
          }
             
        }
    },


    cancelCreateOpportunity : function(component, event, helper) {
        if (typeof sforce !== 'undefined' && typeof sforce.one !== 'undefined') {
          //console.log('===================>> found sforce!!!!!!!!!!!!!!!!!!!');
          sforce.one.back(true);
        }  else {
          //console.log('===================>> did not find sforce!!!!!!!!!!!!!!!!!!!')
          window.history.go(-1);
        }
    },

        cancel : function(component, event, helper) {   // used to be cancelCreateOpportunity - if those buttons get commented out, they'll have to be renamed.  I renamed this to be more generic
        var resBanner = component.find("searchResultBanner");
        if (typeof sforce !== 'undefined' && typeof sforce.one !== 'undefined') {
          //console.log('===================>> found sforce!!!!!!!!!!!!!!!!!!!');
          $A.util.removeClass(resBanner, "slds-show");
          $A.util.addClass(resBanner, "slds-hide");  
          $A.get('e.force:refreshView').fire();
         // helper.doInit(component, event);        

         // sforce.one.back(true);

        }  else {
          //console.log('===================>> did not find sforce!!!!!!!!!!!!!!!!!!!')
          $A.util.removeClass(resBanner, "slds-show");
          $A.util.addClass(resBanner, "slds-hide");  
          $A.get('e.force:refreshView').fire(); 
        //  helper.doInit(component, event);       

         // window.history.go(-1);
        }
    },

/*
    recTypeSelectChange : function(component, event, helper) {
        var selected = component.find("recTypeSelect1");
        console.log('===============>> selected = ' + selected);
        console.log(selected);
        var inputValue = selected.get("v.value");
        console.log('===============>> inputValue = ' + inputValue);
        component.set('v.selectedRecordType', inputValue);
    },
    */

      selectedObjectChange : function(component, event, helper) {
        var id = component.get("v.id");
        var isCreateOppty = component.get("v.isCreateOppty");
        //console.log('---------------->> isCreateOppty = ' + isCreateOppty);
        if (isCreateOppty == true) {
          // set the account name in the search box
            var acct = component.get("v.selectedRecord");
            var searchInput = component.find("searchBox");
            searchInput.set("v.value", acct.Name);

            var insertMarkupDiv = component.find("insertMarkupDiv");
            $A.util.removeClass(insertMarkupDiv, "slds-hide");
            $A.util.addClass(insertMarkupDiv, "slds-show"); 

           if (typeof id !== "undefined") {
          ////////////    helper.getAcctInfo(component, id);
              //console.log('%%%%%%%%--->> in selectedObjectChange, id = ' + id);
              helper.setIsUserOnAccountTeam(component, id);   // check to make sure user is on the account team
            }
        }
    },

  gotoObjectDetail : function(component, event, helper) {
        //console.log('============>> in gotoObjectDetail!');
          var sObjId = component.get("v.selectedRecord.Id");  
          //console.log('------------->> sObjId = ' + sObjId); 
            var navToSObjEvt = $A.get("e.force:navigateToSObject");
            navToSObjEvt.setParams({
                recordId: sObjId,
                slideDevName: "detail"
            }); 
            navToSObjEvt.fire();
            /* for VF Page
              var callback = component.get("v.callback");

              if (callback) {
                //console.log('############### calling the callback!!!');
                callback('objectDetail', sObjId);
              } else {
            */
  },
  
  /* SRSF-873 - this was commmented out anyway, so removed the event handler in the .cmp file and commented this out
  setOpptyRecordType : function(component, event, helper) {
    / *
          var accRecType = component.get("v.selectedRecordTypeDevName");
          //console.log('-------------------------------->> in setOpportunityRecordType, accRecType = ' + accRecType);
          if (typeof accRecType !== 'undefined') {
              console.log('-------------------------------->> in setOpportunityRecordType(1), accRecType = ' + accRecType);
              helper.setOpportunityRecordType(component, accRecType, null, false);
          }
          * /
  },
  */
  
  // function for clear the Record Selection 
    clear :function(component,event,helper){
      
         var pillTarget = component.find("lookup-pill");
         var lookUpTarget = component.find("lookupField"); 
        
         $A.util.addClass(pillTarget, 'slds-hide');
         $A.util.removeClass(pillTarget, 'slds-show');
        
         $A.util.addClass(lookUpTarget, 'slds-show');
         $A.util.removeClass(lookUpTarget, 'slds-hide');

        var banner = component.find("searchResultBanner");
            $A.util.removeClass(banner, "slds-show");
            $A.util.addClass(banner, "slds-hide"); 
      
         component.set("v.SearchKeyWord",null);
         component.set("v.listOfSearchRecords", null );

          var insertMarkupDiv = component.find("insertMarkupDiv");
          $A.util.removeClass(insertMarkupDiv, "slds-show");
          $A.util.addClass(insertMarkupDiv, "slds-hide"); 
    },
    
  // This function is called when the end User Selects any record from the result list.   
    handleComponentEvent : function(component, event, helper) {

      //console.log('=======>> in handleComponentEvent!!!!!');
     
    // get the selected Contact record from the COMPONENT event    
       var selectedObjectGetFromEvent = event.getParam("objectByEvent");
       //console.log('========>> in handleComponentEvent, selectedObjectGetFromEvent = ' + JSON.stringify(selectedObjectGetFromEvent));
     
     component.set("v.selectedRecord" , selectedObjectGetFromEvent); 
     //console.log('----------------->> selectedObjectGetFromEvent.Id = ' + selectedObjectGetFromEvent.Id);
        var SObjectName = component.get("v.sObjectName");
     //console.log('##########----->> SObjectName = ' + SObjectName);
  //  weirdness here...   if (SObjectName != 'Opportunity') {
        
       var isCreateOppty = component.get("v.isCreateOppty");
       if (isCreateOppty) {

          //console.log('--------------->> atms:');
          //console.log(selectedObjectGetFromEvent.AccountTeamMembers);
          helper.setAccountExecs(component, event, selectedObjectGetFromEvent.AccountTeamMembers, false);
        }

        if (SObjectName == 'Opportunity') {
            var newObjectButt1 = component.find("newObjectButton1");
            var newObjectButtDiv1 = component.find("newObjectButtDiv1");

           $A.util.addClass(newObjectButt1, "slds-show");
           $A.util.removeClass(newObjectButt1, "slds-hide"); 
           $A.util.addClass(newObjectButtDiv1, "slds-show");
           $A.util.removeClass(newObjectButtDiv1, "slds-hide"); 
        }


          var insertMarkupDiv = component.find("insertMarkupDiv");
          $A.util.removeClass(insertMarkupDiv, "slds-hide");
          $A.util.addClass(insertMarkupDiv, "slds-show"); 

          component.set("v.id", selectedObjectGetFromEvent.Id);
          var forclose = component.find("lookup-pill");
             $A.util.addClass(forclose, 'slds-show');
             $A.util.removeClass(forclose, 'slds-hide');
        
          var searchRes = component.find("searchRes");
             $A.util.addClass(searchRes, 'slds-is-close');
             $A.util.removeClass(searchRes, 'slds-is-open');
          var lookUpTarget = component.find("lookupField");
              $A.util.addClass(lookUpTarget, 'slds-hide');
              $A.util.removeClass(lookUpTarget, 'slds-show'); 

          var banner = component.find("searchResultBanner");
              $A.util.removeClass(banner, "sldsl-hide");
              $A.util.addClass(banner, "slds-show");

          // new cross object code starts here...
          var objKeyMap = component.get("v.sobjectKeys");
          var selRec = selectedObjectGetFromEvent;
          var objKey = selRec.Id.substring(0, 3);
          //console.log('===========>> objKey = ' + objKey);
          var currentKey = objKeyMap[objKey].SObject__c;
          var queryObjMap = component.get("v.queryObject");
          var currentObject;
          var htmlMarkup = component.get("v.HTMLMarkup");
          //console.log('===========>> htmlMarkup = ' + htmlMarkup);
          //console.log(htmlMarkup);

          // IE11 insanity          for (var k in queryObjMap) {
          for (var k = 0; k < queryObjMap.length; k++) {
              if (queryObjMap[k].objectType == currentKey) {
                  currentObject = queryObjMap[k];
              }
          }
          var myfields = currentObject.fields;

          var fieldArray = myfields.split(',');
          var currentRec;
          var HTMLMarkUp = '';

          ////  because IE11 is stoooopid    for (var j in fieldArray) {
          for (var j = 0; j <  fieldArray.length; j++) {
              if (fieldArray[j] == 'Id') continue;    // ignore Id
              var index = fieldArray[j].trim();
              if (index.indexOf('.') == -1) {
                  currentRec = selRec[index];
              } else {
                  var parentChild = index.split('.');
                  // the next 2 lines are because the Javascript gods didn't like selRec[parentChild[0]][parentChild[1]]
                  var parentRec = selRec[parentChild[0]];
                  currentRec = parentRec[parentChild[1]];
              }

              // Now get the Custom Setting record
              // add to the HTML
              var htmlMarkupObj = htmlMarkup[currentObject.objectType];
              var startTag = (typeof htmlMarkupObj[index].HTMLStartTag != 'undefined') ?  htmlMarkupObj[index].HTMLStartTag : '';
              var endTag   = (typeof htmlMarkupObj[index].HTMLEndTag != 'undefined') ? htmlMarkupObj[index].HTMLEndTag : '';
              if (endTag == ',') {
                endTag += ' ';      // SF trims trailing spaces in a custom setting, so need to add one for proper spacing
              }
              //console.log('currentRec = ' + currentRec);

              if (currentRec)
                HTMLMarkUp += startTag + currentRec + endTag;
          }


          // Set the markup in the lightning component
          //    console.log('===========>> HTMLMarkup = ' + HTMLMarkup);
          //console.log('===========>> icon = ' + 'standard:' + currentObject.objectType.toLowerCase());
          component.set("v.selectedObjectHTML", HTMLMarkUp); 
          component.set("v.iconForDetailDisplay",  'standard:' + currentObject.objectType.toLowerCase());
          component.set("v.showObjDetails", true);

     //     var objDetDiv = component.find("objectDetailDiv");
          var resBanner = component.find("searchResultBanner");
       //   console.log('-------->> objDetDiv = ' + objDetDiv);
      //    $A.util.removeClass(objDetDiv, "slds-hide");
       //   $A.util.addClass(objDetDiv, "slds-show");          
          $A.util.removeClass(resBanner, "slds-hide");
          $A.util.addClass(resBanner, "slds-show");          
         
   /* this is an example of how to navigate to an object detail record      
          if (SObjectName == 'Account') {
              var sObjId = selectedObjectGetFromEvent.Id;    
              //console.log('------>> about to navigate to: ' + sObjId);      
                    var navToSObjEvt = $A.get("e.force:navigateToSObject");
                    navToSObjEvt.setParams({
                        recordId: sObjId,
                        slideDevName: "detail"
                    }); 
                    navToSObjEvt.fire();      
              }
              */
     // bab - weird check for sobject != opportunity     }

  },


    // automatically call when the component is done waiting for a response to a server request.  
    hideSpinner : function (component, event, helper) {
        var spinner = component.find('spinner');
        if (spinner != null) {
            var evt = spinner.get("e.toggle");
            evt.setParams({ isVisible : false });
            evt.fire();
        }
    
    },

    // automatically call when the component is waiting for a response to a server request.
    showSpinner : function (component, event, helper) {
        var spinner = component.find('spinner');
        if (spinner != null) {
            var evt = spinner.get("e.toggle");
            evt.setParams({ isVisible : true });
            evt.fire();         
        }
   
    },

    dupModalCancel : function (component, event, helper) {

    },

    dupModalSave : function (component, event, helper) {

    },
    //Start : SRSF-3212
    calculateEndDate : function(component, event, helper) {
        console.log('inside calculateEndDate-->');  
        var flightStartDate = component.get('v.FlightStartDate');
        var numberOfWeeks = component.get('v.NoOfWeeks');
        console.log('flightStartDate>>>>'+flightStartDate);
        console.log('numberOfWeeks>>>>'+numberOfWeeks); 
        var action = component.get('c.getFlightEndDate');
        action.setParams({          
          "startDt" : flightStartDate,
          "noOfWeeks": numberOfWeeks 
        });
        action.setCallback(this,function(a){
          try{
            component.set('v.FlightEndDate', a.getReturnValue());
            console.log('FlightEndDate>>>>>>>'+component.get('v.FlightEndDate'));
          }catch(e){}
        });

        $A.enqueueAction(action);
    },
    calculateNoOfBroadcastWeeks : function(component, event, helper) {
        console.log('inside calculateNumberOfWeeks-->');
        var flightStartDate = component.get('v.FlightStartDate');
        var flightEndDate = component.get('v.FlightEndDate');
        console.log('flightStartDate>>>>'+flightStartDate);
        console.log('flightEndDate>>>>'+flightEndDate);
        var action = component.get('c.getNoOfBroadcastWeeks');
        action.setParams({          
          "startDt" : flightStartDate,
          "endDt": flightEndDate 
        });
        action.setCallback(this,function(a){
          try{
            component.set('v.NoOfWeeks', a.getReturnValue());
            console.log('NoOfWeeks>>>>>>>'+component.get('v.NoOfWeeks'));
          }catch(e){}
        });

        $A.enqueueAction(action);
    }
    //End : SRSF-3212
})