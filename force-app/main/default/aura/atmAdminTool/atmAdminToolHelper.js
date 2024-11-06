({
    doInit : function(component,event,helper){
		//alert('atmAdminToolHelper doInit');
        var action = component.get("c.showAccountTeamMembers");
        var recordId = component.get('v.recordId');
        var pageSize = component.get('v.pageSize');
        action.setParams({
              'AccId': recordId
          });
      // set a callBack 
        action.setCallback(this, function(response) {
          //$A.util.removeClass(component.find("mySpinner"), "slds-show");
            var state = response.getState();
            if (state === "SUCCESS") { 
                var storeResponse = response.getReturnValue(); 
                //alert(storeResponse);
                console.log(storeResponse);
              // if storeResponse size is equal 0 ,display No Result Found... message on screen.}
              if (storeResponse == null) {
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Error!",
                        "type" : "error",
                        "mode" : "dismissible",
                        "duration" : 5000,
                        "message": "You are not allowed to remove a Team Member as you are not a DOS or LSM user."
                    });
                    toastEvent.fire();
                    var navEvt = $A.get("e.force:navigateToSObject");
                    navEvt.setParams({
                      "recordId": recordId,
                    });
                    navEvt.fire();                 
              } else {
                  //alert('state === SUCCESS doInit');
                    //component.set("v.listOfSearchRecords", storeResponse);
                 var atmSMCountJS = 0;
                  for(var i=0;i<storeResponse.length;i++)
                  {
                        if(i<pageSize)
                            storeResponse[i].isVisible = true;
                        else
                            storeResponse[i].isVisible = false;
                        //storeResponse[i].rowNum = i+1;
                        
                        if(storeResponse[i].TeamMemberRole == 'Sales Manager' || storeResponse[i].TeamMemberRole =='Account Executive'){
                            atmSMCountJS++;
                        }           
                    }
                  component.set("v.atmSMCount", atmSMCountJS);
                  var currentPage = 1;   
                  //console.log('results-->',storeResponse);
                  component.set("v.listOfSearchRecords",storeResponse);
                  //console.log('attt>>>',component.get("v.listOfSearchRecords"));
                  //component.set("v.pageSize",pageSize);
                  component.set("v.pageNumber",currentPage); 
                  component.set("v.totalRecords", storeResponse.length);
                  var results = component.get('v.listOfSearchRecords');
                  var totalPages;
                  if(storeResponse.length % pageSize > 0){
                      totalPages = parseInt(storeResponse.length / pageSize)+1
                  }
                  else if(storeResponse.length % pageSize == 0) {
                      totalPages = parseInt(storeResponse.length / pageSize);	
                  }
                  component.set("v.totalPages",totalPages);
                  component.set("v.currentPage",currentPage);
                  component.set("v.hasNext",currentPage < totalPages);
                  //console.log('hasNext-->'+component.get("v.hasNext")); 
            	}
        	} else {           
            	component.set("v.Message", '');
    		}    
    	});
        this.getDMAValues(component);
      	// enqueue the Action  
        $A.enqueueAction(action);
    },
    
    /* Added for SRSF-1741 */
    getDMAValues : function(component) {
        var action = component.get("c.getDMAValue");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.lstDMA",response.getReturnValue());
            }
        });
        $A.enqueueAction(action);        
    }, 
    
    /* Added for SRSF-1741 */
    checkForOpenAccountDMA : function(component,event,helper){
        var results = component.get('v.listOfSearchRecords');
      	var atmSMCountJS = component.get("v.atmSMCount");
      	var results = component.get('v.listOfSearchRecords');
        var selectedDMA = component.get('v.selDMA');
      	var selATMSMCountJS = 0;
        for (var i = 0; i < results.length; i++) {
            if( results[i].isChecked==true && (results[i].TeamMemberRole == 'Sales Manager' || results[i].TeamMemberRole =='Account Executive') ){
                selATMSMCountJS++;              
            }
        }
        //alert(atmSMCountJS+'->'+selATMSMCountJS+'->'+selectedDMA);
        if(atmSMCountJS!=0 && atmSMCountJS==selATMSMCountJS && (selectedDMA =='None' || selectedDMA =='--None--')){
            var errorMsg = $A.get("$Label.c.Open_Account_Error_Message");
            alert(errorMsg);
            component.set("v.isOpenAccDMA", true);
            //component.find("v.openAccountDMA").focus();
            return false;
        }else if(atmSMCountJS!=0 && atmSMCountJS==selATMSMCountJS && selectedDMA !='None' && selectedDMA !='--None--'){
            component.set("v.isUpdateOpenAccDMA", true);
        }
      	return true;
	},
    
    doDeleteSelectedAtm : function(component,event,helper){
      //  alert('helper.doDeleteSelectedAtm');
      //console.log('helper.doDeleteSelectedAtm');
      //helper.doDeleteSelectedAtm(component,event,helper);
      var isError = this.checkForOpenAccountDMA(component,event,helper);
      //alert(isError);
      if(isError==false)
          return false;
      var results = component.get('v.listOfSearchRecords');
      //component.set("v.spinnerDisplay", "block");
      //var getCheckAllId = component.find("cboxRow");
      var selectedRec = [];
        for (var i = 0; i < results.length; i++) {
            if( results[i].isChecked==true ){
                selectedRec.push(results[i].atmInformation);               
            }
        }
        //console.log('component selectedRec.length after '+selectedRec.length);
        //console.log('component selectedRec.JSON after '+JSON.stringify(selectedRec));
        if (selectedRec.length>0){
             var isUpdateAcc = component.get('v.isUpdateOpenAccDMA');
             var strSelDMA = component.get('v.selDMA');
             var action = component.get("c.deleteSelectedAtm");
             var recordId = component.get('v.recordId');
             // set param to method  
             action.setParams({
                'isUpdateOpenAccDMA':isUpdateAcc,
                'strDMA':strSelDMA,
                 'accId':recordId,
                'AccountIds':selectedRec
              });
             // set a callBack    
             action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") { 
                    var storeResponse = response.getReturnValue();
                    console.log('In storeResponse' + storeResponse); 
                    if (storeResponse == 'Error') {
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "title": "Error!",
                            "type" : "error",
                            "mode" : "sticky",
                            "duration" : 5000,
                            "message": $A.get("$Label.c.ListManagementBudgetError")
                        });
                        toastEvent.fire();
                        var navEvt = $A.get("e.force:navigateToSObject");
                        navEvt.setParams({
                          "recordId": recordId,
                        });
                        navEvt.fire();                 
              		}
                    else{
                        $A.get("e.force:closeQuickAction").fire();
                        $A.get("e.force:showToast").setParams({
                            "type" : "success",
                            "message" : "Removed  "+selectedRec.length+" Account Team Members."
                        }).fire();
                        //component.set("v.spinnerDisplay", "none");
                        console.log('In Sucess doDeleteSelectedAtm');                     
                    }
                }
             });
            
        }
        //console.log('component selectedRec.length after '+selectedRec.length);
        //console.log('component selectedRec.JSON after '+JSON.stringify(selectedRec));
        $A.enqueueAction(action);
	},
    
    /* @Method		: selectAllCheckBox
       @Description : This Method to handle check all box in pagination
    */
	selectAllCheckBox : function(component,event,helper){
        var results = component.get('v.listOfSearchRecords');
        var checkAllValue = event.getSource().get("v.value");
        var getCheckAllId = component.find("cboxRow");
        if(getCheckAllId!=undefined){
          if(getCheckAllId.length==undefined){
            if(getCheckAllId.get.length==1){
               component.find("cboxRow").set("v.value", checkAllValue);
               component.set("v.shwDeleteBtn", checkAllValue);
            }
          }
          else{
              //alert('for getCheckAllId.length '+getCheckAllId.length);
              for (var i = 0; i < getCheckAllId.length; i++) {
                  component.find("cboxRow")[i].set("v.value", checkAllValue); 
                  //component.set("v.shwDeleteBtn", checkAllValue);
              }
          }
        }
        
        var selected=0;
        for (var i = 0; i < results.length; i++) {
            if( results[i].isChecked==true ){
            	selected++;                
            }
        }
		component.set("v.selectedRecords",selected);
        component.set("v.shwDeleteBtn", selected > 0);
    },
    /* @Method		: changeRowSelectedCheckBox
       @Description : This Method to handle single row check box in pagination
    */
    changeRowSelectedCheckBox:function(component, event, helper){
        //helper.changeRowSelectedCheckBox(component,event,helper);
        var results = component.get('v.listOfSearchRecords');
        var selectCheckBoxRow = event.getSource().get("v.value");
        //console.log('helper.changeRowSelectedCheckBox selectCheckBoxRow '+selectCheckBoxRow);
        var slctCheckRowIndex = event.getSource().get("v.requiredIndicatorClass");
        //console.log('helper.changeRowSelectedCheckBox slctCheckRowIndex '+slctCheckRowIndex);
        component.set("v.isChecked", true);
        
        var selected=0;
        for (var i = 0; i < results.length; i++) {
            if( results[i].isChecked==true ){
            	selected++;                
            }
        }
		component.set("v.selectedRecords",selected);
        component.set("v.shwDeleteBtn", selected > 0);
    },

    /* @Method		: previoushelper
       @Description : This Method to handle previous records in pagination
    */
    previoushelper:function(component, event, helper)
    {
        var results = component.get('v.listOfSearchRecords');
        var pageSize = component.get('v.pageSize');
        var pageNumber = component.get('v.pageNumber');
        pageNumber--;
        var to = pageSize*pageNumber;
        var from = (pageSize*pageNumber)-pageSize; 
          for(var i=0;i<results.length;i++)
        {
            if(from <= i && i < to){
                results[i].isVisible = true;
            }
            else {
                results[i].isVisible = false;
            }
        }
        component.set("v.pageNumber",pageNumber);
        component.set("v.listOfSearchRecords",results);        
        //component.set("v.hasPrevious",pageNumber == 1);  
        //console.log('hasPrevious->'+component.get("v.hasPrevious"));
        var totalPages;
        if(results.length % pageSize > 0){
            totalPages = parseInt(results.length / pageSize)+1
        } 
            else if(results.length % pageSize == 0){
            totalPages = parseInt(results.length / pageSize);	
    	}
        var selected=0;
        for (var i = 0; i < results.length; i++) {
            //alert('for results.length');
            //component.find("cboxRow")[i].set("v.value", slctCheck); 
            //component.set("v.shwDeleteBtn", slctCheck);
            if( results[i].isChecked==true ){
            	selected++;                
            }
        }
        component.find("cBoxAll").set("v.value", false);
		component.set("v.selectedRecords", selected);
        component.set("v.shwDeleteBtn", selected > 0);
        component.set("v.totalPages", totalPages);
        component.set("v.hasNext", pageNumber < totalPages);        
        component.set("v.hasPrevious", pageNumber >1); 
        //console.log('totalPages'+totalPages);
        //console.log('pageNumber'+pageNumber);
        //console.log('appr length'+results.length);
    },
    /* @Method		: nexthelper
       @Description : This Method to handle next records
     */
    nexthelper:function(component, event, helper)
    {     
        var results = component.get('v.listOfSearchRecords');
        //console.log('-->',component.get('v.listOfSearchRecords'));
        var pageSize = component.get('v.pageSize');
        var pageNumber = component.get('v.pageNumber');       
        //console.log('results-->'+results.length);
        pageNumber++;
        var to = pageSize*pageNumber;
        var from = (pageSize*pageNumber)-pageSize;       
        for(var i=0;i<results.length;i++)  
        {
            if(from <= i && i < to)
                results[i].isVisible= true;
            else
                results[i].isVisible= false;
        }    
        component.find("cBoxAll").set("v.value", false);
        component.set("v.pageNumber",pageNumber);
        component.set("v.listOfSearchRecords",results);
        //console.log('pageNumber-->'+pageNumber);
        component.set("v.hasPrevious",true);
       // component.set("v.hasPrevious",pageNumber == 1);
        var totalPages;
        if(results.length % pageSize > 0){
            totalPages = parseInt(results.length / pageSize)+1
        }
            else if(results.length % pageSize == 0){
            totalPages = parseInt(results.length / pageSize);	
    	}
        component.set("v.totalPages",totalPages);
       	component.set("v.hasNext",pageNumber < totalPages);
        var selected=0;
        for (var i = 0; i < results.length; i++) {
            //alert('for results.length');
            //component.find("cboxRow")[i].set("v.value", slctCheck); 
            //component.set("v.shwDeleteBtn", slctCheck);
            if( results[i].isChecked==true ){
            	selected++;                
            }
        }
		component.set("v.selectedRecords",selected);
        component.set("v.shwDeleteBtn", selected > 0);
        //console.log('totalPages'+totalPages);        
        //console.log('appr length'+results.length);
    },
    dismissQuickAction : function( component, event, helper ){
        // Close the action panel
        var dismissActionPanel = $A.get("e.force:closeQuickAction");
        dismissActionPanel.fire();
    }      
})