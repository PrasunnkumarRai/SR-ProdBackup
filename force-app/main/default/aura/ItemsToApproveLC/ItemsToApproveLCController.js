({
    /*
	* @Method		: openModel
    * @Description  : calls the helper getRecords method.
	*/
    doInit : function(component, event, helper) {
        console.log('do init--');
        helper.getRecords(component, event, helper);         
    },
    /* @Method      : openModel
     * @Description : This function callls when Approve,Reject or Reassigned buttons is clicked
     					and opens the modal popup.
    */
    openModel: function(component, event, helper) {       
      console.log('inn OpenModel popup**');
      component.set("v.isOpen", true);
      var actionPopUp = component.find("actionPopUp");
      $A.util.removeClass(actionPopUp,'slds-hide');
      //$("#actionPopUp").show();
      
      console.log(' $("#actionPopUp")-->>>'+ $("#actionPopUp").css('display'));  
      var lstclickedIndx = event.getSource().get("v.name");
      var clickedIndx = lstclickedIndx.split('-')[0];
      component.set("v.id", clickedIndx);
      console.log('clickedIndx-->'+clickedIndx);
      var btnName;
      var objectName="";
      var whichOne = event.getSource().getLocalId();
      console.log(whichOne); 
        // Approve button is clicked 
        if(whichOne == 'btnApprove'){
            var UserLookup = component.find("UserLookup");
            $A.util.removeClass(UserLookup,'slds-show');
            $A.util.addClass(UserLookup,'slds-hide');
            
            var reassignbtn = component.find("ReAssign");
            $A.util.removeClass(reassignbtn,'slds-show');
            $A.util.addClass(reassignbtn,'slds-hide');
            
            var rejectbtn = component.find("RejectBtn");
            $A.util.removeClass(rejectbtn,'slds-show');
            $A.util.addClass(rejectbtn,'slds-hide');
            
            var cmpTarget = component.find("ApproveBtn");
            $A.util.removeClass(cmpTarget,'slds-hide');
            $A.util.addClass(cmpTarget,'slds-show');
            component.set("v.Status", 'Approved');
            objectName = lstclickedIndx.split('-')[1];
            /*objectName = objectName.replace("__c","")
            objectName = objectName.replace("_"," ");*/
            component.set("v.actionBtnName", "Approve "); 
            component.set("v.objName", objectName);             
            //btnName = "Approve "+objectName;
        }
        // Reject button is clicked
        if(whichOne == 'btnReject'){
            var UserLookup = component.find("UserLookup");
            $A.util.removeClass(UserLookup,'slds-show');
            $A.util.addClass(UserLookup,'slds-hide');
            
            var approvebtn = component.find("ApproveBtn");
            $A.util.removeClass(approvebtn,'slds-show');
            $A.util.addClass(approvebtn,'slds-hide');
            
            var reassignbtn = component.find("ReAssign");
            $A.util.removeClass(reassignbtn,'slds-show');
            $A.util.addClass(reassignbtn,'slds-hide');
            
            var cmpTarget = component.find("RejectBtn");
            $A.util.removeClass(cmpTarget,'slds-hide');
            $A.util.addClass(cmpTarget,'slds-show');
            component.set("v.Status", 'Rejected');
            objectName = lstclickedIndx.split('-')[1];
            /*objectName = objectName.replace("__c","")
            objectName = objectName.replace("_"," ");*/
            component.set("v.actionBtnName", "Reject "); 
            component.set("v.objName", objectName); 
            //btnName = "Reject "+objectName;
        }  
        // ReAssign button is clicked
        if(whichOne == 'btnReassign'){ 
            var UserLookup = component.find("UserLookup");
            $A.util.removeClass(UserLookup,'slds-hide');
            $A.util.addClass(UserLookup,'slds-show');
            
            var approvebtn = component.find("ApproveBtn");
            $A.util.removeClass(approvebtn,'slds-show');
            $A.util.addClass(approvebtn,'slds-hide');
            
            var rejectbtn = component.find("RejectBtn");
            $A.util.removeClass(rejectbtn,'slds-show');
            $A.util.addClass(rejectbtn,'slds-hide');
            
            var cmpTarget = component.find("ReAssign");
            $A.util.removeClass(cmpTarget,'slds-hide');
            $A.util.addClass(cmpTarget,'slds-show');
            component.set("v.Status", 'Reassigned');
            component.set("v.actionBtnName", "Reassign Approval Request"); 
            component.set("v.objName", "");         
        }
   },
   /* @Method      : getStatus
    * @Description : This function is called when buttons are clicked in popup 
    * 					and calls the helper getStatus method     					
    */   
    getStatus:function(component, event, helper) 
    { 
    	helper.getStatus(component, event, helper); 
    },
    /* @Method      : closeModel
    * @Description :  calls the helper getCloseModel method     					
    */   
    closeModel: function(component, event, helper) 
    { 
	  helper.getCloseModel(component, event, helper);
    },
    /* @Method      : previous
    *  @Description  : This Method to handle pervious records , calls helper previoushelper method					
    */ 	
    previous:function(component, event, helper)
    {       
        helper.previoushelper(component,event,helper);
    },
    /* @Method      : next
     * @Description : This Method to handle next records, calls helper nexthelper method	
    */
    next:function(component, event, helper)
    {
        helper.nexthelper(component,event,helper);
    },
    /* @Method      : getObjectValue
     * @Description : This Method to get the selected user id
    */    
 	getObjectValue :function(component, event, helper)
    {
    	var eventValue= event.getParam("sObjectId");        
        console.log('eventValue-->'+eventValue);
        component.set("v.userId", eventValue);    	
	},  
    /* @Method      : getSort
     * @Description : to sort the records by column 
    */   
    getSort : function(component, event, helper)
    {
        var records = component.get("v.approvalListRecords");
        var columnId = event.target.id;         

        // Sort records based on Request ID column
        if(columnId == 'targetObject'){            
            component.find("trgtObj").set('v.class', 'show-Arrow');
            component.find("RectypeArow").set('v.class', 'slds-hide');
            component.find("targetObjectAcc").set('v.class', 'slds-hide');    //objArow-->  targetObjectAcc     
            component.find("AcctExecutive").set('v.class', 'slds-hide');
            component.find("status").set('v.class', 'slds-hide');
            component.find("actor").set('v.class', 'slds-hide');
            component.find("date").set('v.class', 'slds-hide');                        
            
            var currentOrder = component.get("v.targetObjsortAsc");
            
            // DESC Order
            if(currentOrder == true){
                var trgtObjArrow  =component.find("trgtObj");
                trgtObjArrow.set('v.iconName', 'utility:arrowdown');
                helper.sortBy(component, "targetObjectName", false);                
                component.set("v.targetObjsortAsc",false);
            }                
            else{ // ASC Order                        
                var trgtObjArrow  =component.find("trgtObj");                               
                trgtObjArrow.set('v.iconName', 'utility:arrowup');
                helper.sortBy(component, "targetObjectName", true);
                component.set("v.targetObjsortAsc",true);
            }                            
        }
        // Sort records based on RecordType column
        if(columnId == 'RecType'){ 
            component.find("trgtObj").set('v.class', 'slds-hide');
            component.find("RectypeArow").set('v.class', 'show-Arrow');            
            component.find("targetObjectAcc").set('v.class', 'slds-hide');
            component.find("AcctExecutive").set('v.class', 'slds-hide');
            component.find("status").set('v.class', 'slds-hide');
            component.find("actor").set('v.class', 'slds-hide');
            component.find("date").set('v.class', 'slds-hide');            
            
            var currentOrder = component.get("v.RecTypesortAsc");            
            
            // DESC Order
            if(currentOrder == true){
                var RectypeArrow  =component.find("RectypeArow");                                
                RectypeArrow.set('v.iconName', 'utility:arrowdown');
                helper.sortBy(component, "RecordTypeName",false);                
                component.set("v.RecTypesortAsc",false);
            }                
            else{ // ASC Order
                var RectypeArrow  =component.find("RectypeArow");                               
                RectypeArrow.set('v.iconName', 'utility:arrowup');                
                helper.sortBy(component, "RecordTypeName",true);              
                component.set("v.RecTypesortAsc",true);
            }            
        }
        // Sort records based on Account column
        if(columnId == 'targetObjectAcc'){
            component.find("trgtObj").set('v.class', 'slds-hide');
            component.find("RectypeArow").set('v.class', 'slds-hide'); 
            component.find("targetObjectAcc").set('v.class', 'show-Arrow');       
            component.find("AcctExecutive").set('v.class', 'slds-hide');
            component.find("status").set('v.class', 'slds-hide');
            component.find("actor").set('v.class', 'slds-hide');
            component.find("date").set('v.class', 'slds-hide');
                   
            var currentOrder = component.get("v.objNameAsc");
            
            // DESC Order
            if(currentOrder == true){
                var ObjArrow  =component.find("targetObjectAcc");                                
                ObjArrow.set('v.iconName', 'utility:arrowdown');  
                helper.sortBy(component, "strAccountName",false);                
                component.set("v.objNameAsc",false);
            }                
            else{ // ASC Order
                var ObjArrow  =component.find("targetObjectAcc");                                
                ObjArrow.set('v.iconName', 'utility:arrowup'); 
                helper.sortBy(component, "strAccountName",true); 
                component.set("v.objNameAsc",true);
            }            
        }
        // Sort records based on Account Executive column
        if(columnId == 'targetObjectAccExec'){
            component.find("trgtObj").set('v.class', 'slds-hide');
            component.find("RectypeArow").set('v.class', 'slds-hide'); 
            component.find("targetObjectAcc").set('v.class', 'slds-hide');       
            component.find("AcctExecutive").set('v.class', 'show-Arrow');
            component.find("status").set('v.class', 'slds-hide');
            component.find("actor").set('v.class', 'slds-hide');
            component.find("date").set('v.class', 'slds-hide');
                   
            var currentOrder = component.get("v.acctExecSortAsc");
            
            // DESC Order
            if(currentOrder == true){
                var ObjArrow  =component.find("AcctExecutive");                                
                ObjArrow.set('v.iconName', 'utility:arrowdown');  
                helper.sortBy(component, "strAcctExecutive",false);
                component.set("v.acctExecSortAsc",false);
            }                
            else{ // ASC Order
                var ObjArrow  =component.find("AcctExecutive");                               
                ObjArrow.set('v.iconName', 'utility:arrowup'); 
                helper.sortBy(component, "strAcctExecutive",true);  
                component.set("v.acctExecSortAsc",true);            
            }                           
        }
        // Sort records based on Status column
        if(columnId == 'targetObjectStatus'){
            component.find("trgtObj").set('v.class', 'slds-hide');
            component.find("RectypeArow").set('v.class', 'slds-hide'); 
            component.find("targetObjectAcc").set('v.class', 'slds-hide');       
            component.find("AcctExecutive").set('v.class', 'slds-hide');
            component.find("status").set('v.class', 'show-Arrow');
            component.find("actor").set('v.class', 'slds-hide');
            component.find("date").set('v.class', 'slds-hide');
                   
            var currentOrder = component.get("v.statusSortAsc");            
            
            // DESC Order
            if(currentOrder == true){
                var ObjArrow  =component.find("status");                               
                ObjArrow.set('v.iconName', 'utility:arrowdown');  
                helper.sortBy(component, "strStatus",false);
                component.set("v.statusSortAsc",false);                
            }                
            else{ // ASC Order
                var ObjArrow  =component.find("status");                              
                ObjArrow.set('v.iconName', 'utility:arrowup'); 
                helper.sortBy(component, "strStatus",true);  
                component.set("v.statusSortAsc",true);               
            }           
        }
        // Sort records based on Recent Approver column
        if(columnId == 'actorName'){ 
            component.find("trgtObj").set('v.class', 'slds-hide');
            component.find("RectypeArow").set('v.class', 'slds-hide');
            component.find("targetObjectAcc").set('v.class', 'slds-hide'); 
            component.find("AcctExecutive").set('v.class', 'slds-hide');
            component.find("status").set('v.class', 'slds-hide'); 
            component.find("actor").set('v.class', 'show-Arrow');           
            component.find("date").set('v.class', 'slds-hide');
          
            var currentOrder = component.get("v.actorNamesortAsc");            
            
            // DESC Order
            if(currentOrder == true){
                var actorArrow  =component.find("actor");                               
                actorArrow.set('v.iconName', 'utility:arrowdown');  
                helper.sortBy(component, "actorName",false);
                component.set("v.actorNamesortAsc",false);               
            }                
            else{ // ASC Order
                var actorArrow  =component.find("actor");                                
                actorArrow.set('v.iconName', 'utility:arrowup');
                helper.sortBy(component, "actorName",true);
                component.set("v.actorNamesortAsc",true);               
            }                           
        }
        // Sort records based on Recent Approver column
        if(columnId == 'crtdDate'){
            component.find("trgtObj").set('v.class', 'slds-hide');
            component.find("RectypeArow").set('v.class', 'slds-hide');
            component.find("targetObjectAcc").set('v.class', 'slds-hide'); 
            component.find("AcctExecutive").set('v.class', 'slds-hide');
            component.find("status").set('v.class', 'slds-hide');
            component.find("actor").set('v.class', 'slds-hide');
            component.find("date").set('v.class', 'show-Arrow');
            
            var currentOrder = component.get("v.crtdDatesortAsc");            
                    
            // DESC Order
            if(currentOrder == true){
                var dateArrow  =component.find("date");                               
                dateArrow.set('v.iconName', 'utility:arrowdown'); 
                helper.sortBy(component, "createdDate",false);
                component.set("v.crtdDatesortAsc",false);
            }                
            else{ // ASC Order
                var dateArrow  =component.find("date");                                
                dateArrow.set('v.iconName', 'utility:arrowup'); 
                helper.sortBy(component, "createdDate",true);                
                component.set("v.crtdDatesortAsc",true);                
            }                
        }
    },

    /* @Method      : navigateToMyComponent
     * @Description : to navigate to component from home page when "viewall" is clicked
    */
    navigateToMyComponent : function(component, event, helper) 
    {            
    	var evt = $A.get("e.force:navigateToComponent");
   		evt.setParams({
            componentDef : "c:ItemsToApproveLC",
            componentAttributes: {                
                isHomePage : false
            }            
    	});
        evt.fire();
	},  
    /* SRSF-4025*/    
    handleMouseHover : function(component, event, helper) {      
        var curTarget = event.currentTarget;
        var objectId = curTarget.dataset.value;
        component.set("v.reId",objectId);
        helper.getMiniLayout(component, event, helper)
    },

    handleMouseOut: function(component, event, helper) {
        component.set("v.hoverRow",-1);
        component.set("v.togglehover",false);
    }
})