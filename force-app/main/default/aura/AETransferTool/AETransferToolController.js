({
   onfocus : function(component,event,helper){
       $A.util.addClass(component.find("mySpinner"), "slds-show");
        var forOpen = component.find("searchRes");
            $A.util.addClass(forOpen, 'slds-is-open');
            $A.util.removeClass(forOpen, 'slds-is-close');
        // Get Default 5 Records order by createdDate DESC  
         var getInputkeyWord = '';       
         helper.searchHelper(component,event,getInputkeyWord);
    },
    onblur : function(component,event,helper){         
        component.set("v.listOfSearchRecords", null );        
        var forclose = component.find("searchRes");
        $A.util.addClass(forclose, 'slds-is-close');
        $A.util.removeClass(forclose, 'slds-is-open');
    },
    keyPressController : function(component, event, helper) {       
       // get the search Input keyword   
         var getInputkeyWord = component.get("v.SearchKeyWord");      
       // alert(getInputkeyWord);
       // check if getInputKeyWord size id more then 0 then open the lookup result List and 
       // call the helper 
       // else close the lookup result List part.   
        if( getInputkeyWord.length > 0 ){            
             var forOpen = component.find("searchRes");            
               $A.util.addClass(forOpen, 'slds-is-open');
               $A.util.removeClass(forOpen, 'slds-is-close');
            helper.searchHelper(component,event,getInputkeyWord);
        }
        else{  
             component.set("v.listOfSearchRecords", null );                         
             var forclose = component.find("searchRes");            
               $A.util.addClass(forclose, 'slds-is-close');
               $A.util.removeClass(forclose, 'slds-is-open');
          }
	},
    
  // function for clear the Record Selaction 
    clear :function(component,event,heplper){
         var pillTarget = component.find("lookup-pill");
         var lookUpTarget = component.find("lookupField"); 
        
         $A.util.addClass(pillTarget, 'slds-hide');
         $A.util.removeClass(pillTarget, 'slds-show');
        
         $A.util.addClass(lookUpTarget, 'slds-show');
         $A.util.removeClass(lookUpTarget, 'slds-hide');
      
         component.set("v.SearchKeyWord",null);
         component.set("v.listOfSearchRecords", null );
         component.set("v.selectedRecord", {} );   
    },
    
  // This function call when the end User Select any record from the result list.   
    handleComponentEvent : function(component, event, helper) {
    // get the selected User record from the COMPONETN event 	      
       var selectedUserGetFromEvent = event.getParam("recordByEvent");        
	   component.set("v.selectedRecord" , selectedUserGetFromEvent);        
        var forclose = component.find("lookup-pill");
           $A.util.addClass(forclose, 'slds-show');
           $A.util.removeClass(forclose, 'slds-hide');
  
        var forclose = component.find("searchRes");
           $A.util.addClass(forclose, 'slds-is-close');
           $A.util.removeClass(forclose, 'slds-is-open');
        
        var lookUpTarget = component.find("lookupField");
            $A.util.addClass(lookUpTarget, 'slds-hide');
            $A.util.removeClass(lookUpTarget, 'slds-show');   
        
        component.set("v.childComp",true);
        component.set("v.shwBtnFlag", true);
        component.set("v.shwResetBtn",true);
        component.set("v.shwDtlsFlag", false);
        component.set("v.shwTransfrFlag", false);
        component.set("v.transferBtn", false);
        component.set("v.error",false);
        component.set("v.erorMessage",'');

        //alert('In Parent:: '+selectedUserGetFromEvent.Id);
        component.set("v.UserId",selectedUserGetFromEvent.Id);
        /*
        var action = component.get("c.setUserId");
        action.setParams({
            'usrId': selectedUserGetFromEvent.Id
         });
       $A.enqueueAction(action);
       */
        
	}, 
        //Code starts for child component
    onfocusChild : function(component,event,helper){
        console.log('focused');
       $A.util.addClass(component.find("mySpinnerChild"), "slds-show");
        var forOpen = component.find("searchResChild");
            $A.util.addClass(forOpen, 'slds-is-open');
            $A.util.removeClass(forOpen, 'slds-is-close');
        // Get Default 5 Records order by createdDate DESC  
         var getInputkeyWord = ''; 
         helper.searchHelperChild(component,event,getInputkeyWord);
    },
    onblurChild : function(component,event,helper){         
        component.set("v.listOfSearchRecordsChild", null );        
        var forclose = component.find("searchResChild");
        $A.util.addClass(forclose, 'slds-is-close');
        $A.util.removeClass(forclose, 'slds-is-open');
    },
    keyPressControllerChild : function(component, event, helper) {       
       // get the search Input keyword   
         var getInputkeyWord = component.get("v.SearchKeyWordChild");      
		
        if( getInputkeyWord.length > 0 ){            
             var forOpen = component.find("searchResChild");            
               $A.util.addClass(forOpen, 'slds-is-open');
               $A.util.removeClass(forOpen, 'slds-is-close');
            helper.searchHelperChild(component,event,getInputkeyWord);
        }
        else{  
             component.set("v.listOfSearchRecordsChild", null );                         
             var forclose = component.find("searchResChild");            
               $A.util.addClass(forclose, 'slds-is-close');
               $A.util.removeClass(forclose, 'slds-is-open');
          }
	},
    
  // function for clear the Record Selaction 
    clearChild :function(component,event,heplper){
         var pillTarget = component.find("lookup-pillChild");
         var lookUpTarget = component.find("lookupFieldChild"); 
        
         $A.util.addClass(pillTarget, 'slds-hide');
         $A.util.removeClass(pillTarget, 'slds-show');
        
         $A.util.addClass(lookUpTarget, 'slds-show');
         $A.util.removeClass(lookUpTarget, 'slds-hide');
      
         component.set("v.SearchKeyWordChild",null);
         component.set("v.listOfSearchRecordsChild", null );
         component.set("v.selectedRecordChild", {} );   
    },
    
  // This function call when the end User Select any record from the result list.   
    handleComponentEventChild : function(component, event, helper) {
    // get the selected User record from the COMPONETN event 	      
       var selectedUserGetFromEvent = event.getParam("recordByEventChild");   
       
	   component.set("v.selectedRecordChild" , selectedUserGetFromEvent);        
        var forclose = component.find("lookup-pillChild");
           $A.util.addClass(forclose, 'slds-show');
           $A.util.removeClass(forclose, 'slds-hide');
  
        var forclose = component.find("searchResChild");
           $A.util.addClass(forclose, 'slds-is-close');
           $A.util.removeClass(forclose, 'slds-is-open');
        
        var lookUpTarget = component.find("lookupFieldChild");
            $A.util.addClass(lookUpTarget, 'slds-hide');
            $A.util.removeClass(lookUpTarget, 'slds-show');  
        
        component.set("v.newUserId",selectedUserGetFromEvent.Id);

	},
    
    showAccountDetails : function(component,event,helper){
       component.set("v.spinnerDisplay", "block");
	     var action = component.get("c.showAccounts");
      	 // set param to method  
        action.setParams({
            'UserId':component.get("v.UserId")
          });
         // set a callBack    
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") { 
                var storeResponse = response.getReturnValue();
                component.set("v.accountTeamMembers", storeResponse);
                 component.set("v.spinnerDisplay", "none");
                console.log('In Sucess');
                console.log(storeResponse.length);
                if(storeResponse.length>0){
                  component.set("v.shwDtlsFlag",true);
                  component.set("v.shwTransfrFlag", false);
                  component.set("v.transferBtn", false);
                  component.set("v.shwBtnFlag", false);
                  component.set("v.shwResetBtn", true);
                  component.find("cbox").set("v.value",false);
                  component.set("v.error",false);
                  component.set("v.erorMessage",'');
                }
                else{
                  component.set("v.shwDtlsFlag",false);
                  component.set("v.shwTransfrFlag", false);
                  component.set("v.transferBtn", false);
                  component.set("v.shwBtnFlag", false);
                  component.set("v.shwResetBtn", true);
                  component.find("cbox").set("v.value",false);                 
                  component.set("v.error",true);
                  component.set("v.erorMessage",'No Accounts with the selected user');
                }

            }
        });
        $A.enqueueAction(action);
	},

  selectAllChckBx : function(component,event,helper){
        var slctCheck = event.getSource().get("v.value");
        var getCheckAllId = component.find("cboxRow");
        if(getCheckAllId!=undefined){
          if(getCheckAllId.length==undefined){
            if(getCheckAllId.get.length==1){
               component.find("cboxRow").set("v.value", slctCheck);
            }
          }
          else{
              for (var i = 0; i < getCheckAllId.length; i++) {
                  component.find("cboxRow")[i].set("v.value", slctCheck);             
              }
          }
        }
    },
    selectAllOppChckBx : function(component,event,helper){
        var slctCheck = event.getSource().get("v.value");
        var getCheckAllId = component.find("cboxRowOpp");
        console.log(getCheckAllId);
        if(getCheckAllId!=undefined){
          if(getCheckAllId.length==undefined){
            if(getCheckAllId.get.length==1){
               component.find("cboxRowOpp").set("v.value", slctCheck);
            }
          }
          else{
              for (var i = 0; i < getCheckAllId.length; i++) {
                  component.find("cboxRowOpp")[i].set("v.value", slctCheck);             
              }
          }
        }
    },

    changeSelectAll:function(component,event, helper){
        var slctCheckRow = event.getSource().get("v.value");
        var getCheckAllId = component.find("cbox");
        if(slctCheckRow == false) {
            component.find("cbox").set("v.value", false);
        }
    },
    
    changeSelectAllOpp:function(component,event, helper){
        var slctCheckRow = event.getSource().get("v.value");
        var getCheckAllId = component.find("cboxOpp");
        if(slctCheckRow == false) {
            component.find("cboxOpp").set("v.value", false);
        }
    },

    fetchOpp : function(component,event,helper){
      component.set("v.spinnerDisplay", "block");
      var getCheckAllId = component.find("cboxRow");
      var selctedRec = [];
      if(getCheckAllId!=undefined){
        if(getCheckAllId.length==undefined){
            if(getCheckAllId.get.length==1 && getCheckAllId.get("v.value")){
               selctedRec.push(getCheckAllId.get("v.text"));
            }
        }
        else{
          for (var i = 0; i < getCheckAllId.length; i++) {
                 
                if(getCheckAllId[i].get("v.value") == true )
                {
                    selctedRec.push(getCheckAllId[i].get("v.text")); 
                }
          }
        }
        if(selctedRec.length>0){
          var closeDate  = component.get("v.oppclosedate");
          console.log(component.get("v.oppclosedate"));
          if(closeDate!=null){
            component.set("v.error",false);
            component.set("v.spinnerDisplay", "block");
            var action = component.get("c.showOpportunities");
            action.setParams({
             'AccountIds':selctedRec,
             'oppCloseDate' : component.get("v.oppclosedate"),
             'oldUserId' : component.get("v.UserId")
            });
            action.setCallback(this, function(response) {
                  var state = response.getState();
                  if (state === "SUCCESS") { 
                      var storeResponse = response.getReturnValue();
                      component.set("v.oppList", storeResponse);
                      component.set("v.spinnerDisplay", "none");
                      if(storeResponse.length>0){

/*                        var crossMark = document.getElementsByClassName("slds-pill__remove");
                        
                        for (var i=0; i<crossMark.length; i++) {
                          crossMark[i].className += ' slds-hide';
                        }*/

                        component.set("v.SelectedAccountIds", selctedRec);
                        
                        component.set("v.shwTransfrFlag", true);
                        component.set("v.shwDtlsFlag", false);
                        component.set("v.shwBtnFlag", false);
                        component.set("v.transferBtn", true);

                        //document.getElementById("previousUserId").childNodes[0].childNodes[2].classList.add('slds-hide');
                        var cmpTarget = component.find("previousUserId");
                        $A.util.addClass(cmpTarget, 'slds-hide');
                      }
                      else{
                        component.set("v.shwTransfrFlag", false);
                        component.set("v.transferBtn", false);
                        component.set("v.shwDtlsFlag", true);
                        component.set("v.shwBtnFlag", false);
                        component.set("v.error",true);
                        component.set("v.erorMessage",'No Opportunities for Selected Account');
                      }

                  }
                  else if (state=="ERROR") {
                    console.log(action.getError()[0].message);
                  }
            });
            $A.enqueueAction(action);
          }
          else{
            component.set("v.error",true);
            component.set("v.erorMessage",'Please Select Proposal End Date');
            component.set("v.spinnerDisplay", "none");
          }
        }
        else{
            component.set("v.error",true);
            component.set("v.erorMessage",'Please Select Account to fetch opportunities');
            component.set("v.spinnerDisplay", "none");
        }
      }
      console.log('at last');
        component.set("v.spinnerDisplay", "none");
    },

    transfer : function(component,event,helper){
      var getCheckAllId = component.find("cboxRowOpp");
      var selctedRec = [];
      if(getCheckAllId!=undefined){
        if(getCheckAllId.length==undefined){
            if(getCheckAllId.get.length==1 && getCheckAllId.get("v.value")){
               selctedRec.push(getCheckAllId.get("v.text"));
            }
        }
        else{
          for (var i = 0; i < getCheckAllId.length; i++) {
                 
                if(getCheckAllId[i].get("v.value") == true )
                {
                    selctedRec.push(getCheckAllId[i].get("v.text")); 
                }
          }
        }
        if(selctedRec.length>0){
            var newOwnerId = component.get("v.newUserId");
            console.log(newOwnerId);
            if(newOwnerId=='null'){
                component.set("v.error",true);
                component.set("v.erorMessage",'Please Select New Owner');
            }
            else{
              component.set("v.spinnerDisplay", "block");
              component.set("v.shwTransfrFlag", false);
              var action = component.get("c.AEtransfer");
               // set param to method  
              console.log(component.get("v.oppList"));
              action.setParams({
                  'wrapperString': JSON.stringify(component.get("v.oppList")),
                  'newUserId' : component.get("v.newUserId"),
                  'oldUserId' : component.get("v.UserId"),
                  'AccountIds' : component.get("v.SelectedAccountIds"),
                  'proposalEndDate' : component.get("v.oppclosedate")
                });
               // set a callBack    
              action.setCallback(this, function(response) {
                  var state = response.getState();
                  if (state === "SUCCESS") {
                      var adminStatus = response.getReturnValue();
                      
                      component.set("v.transferBtn", false);
                      component.set("v.transferStatus", 'block');
                      component.set("v.error",false);
                      component.set("v.erorMessage",'');
                      component.set("v.transferSuccessFlag", true);
                      
                      var interval  = setInterval(
                          $A.getCallback(function(){
                              
                                  var action2 = component.get("c.returnAdminToolStatus");
                                  action2.setParams({
                  					'adminStatusId': adminStatus
                                  });
                                  action2.setCallback(this, function(response) {
                                      var state = response.getState();
                                      if (state === "SUCCESS") {
                                          var storeAEResponse = response.getReturnValue();
                                          console.log('response ae :::'+storeAEResponse);
                                          component.set("v.AdminStatusSummary", storeAEResponse);
                                          component.set("v.progress",storeAEResponse.of_completion__c)
                                         //$A.get('e.force:refreshView').fire(); 
                                          if(storeAEResponse.Batch_Completed__c){
                                            component.set("v.spinnerDisplay", "none"); 
                                           	clearInterval(interval);   
                                          }
                                      }
                                  });
                                  $A.enqueueAction(action2);
                          }) , 10000);
                      
                  }
              });
              $A.enqueueAction(action);
            }
        }
        else{
            component.set("v.error",true);
            component.set("v.erorMessage",'Please Select Opportunities to Transfer');
        }
      }
    },

    resetSelection : function(component,event,helper){
      window.location.reload();
    }
    
/*    onRender: function (cmp) {
        var interval = setInterval($A.getCallback(function () {
            var progress = cmp.get('v.progress');
            cmp.set('v.progress', progress === 100 ? clearInterval(interval) : progress + 10);
        }), 200);
    }*/

    
})