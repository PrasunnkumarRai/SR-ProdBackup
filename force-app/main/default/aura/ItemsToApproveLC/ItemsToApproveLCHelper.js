({
    /* @Method		: getRecords
     * @Description : To get the approval requests records on page load. 
    */
    getRecords: function(component, event, helper){       
       if(component.get("v.isHomePage") == false){         
            var viewAllBtn = component.find("ViewBtn");        
         	$A.util.addClass(viewAllBtn,'slds-hide');            
        } 
        var action = component.get("c.getApprovalData");
        var pageSize = 10; // earlier set as 100 
        action.setCallback(this, function(resp) {
            var state = resp.getState();
            if (state === "SUCCESS") {
                var results = resp.getReturnValue();               
                var approvalListArr = [];  //SRSF-3392
                
                for(var i=0;i<results.approvals.length;i++)
                {
                    if(i<pageSize)                       
                        results.approvals[i].isVisible = true;
                    else                       
                        results.approvals[i].isVisible = false;
                     
                    results.approvals[i].rowNum = i+1;                
                    approvalListArr.push(results.approvals[i]); //SRSF-3392
                }                
                component.set("v.approvalListRecords",approvalListArr);  //SRSF-3392
                var currentPage = 1; 
                component.set("v.pageSize",pageSize);
                component.set("v.pageNumber",currentPage); 
                var totalPages; 
                var resultdata = component.get('v.approvalListRecords');
                if(resultdata.length % pageSize > 0)                 
                    totalPages = parseInt(resultdata.length / pageSize)+1
                else if(resultdata.length % pageSize == 0)                 
                    totalPages = parseInt(resultdata.length / pageSize);
                console.log ('totalPages>>>>'+totalPages);			
                component.set("v.total",totalPages);
                component.set("v.hasNext",currentPage < totalPages);
                console.log('hasNext-->'+component.get("v.hasNext")); 
            }                      
        });
        
        $A.enqueueAction(action);
    },  
    /* @Method		: previoushelper
       @Description : This Method to handle pervious records in pagination
    */
    previoushelper:function(component, event, helper)
    {        
        var resultdata = component.get('v.approvalListRecords');
        var pageSize = component.get('v.pageSize');
        var pageNumber = component.get('v.pageNumber');
        pageNumber--;
        var to = pageSize*pageNumber;
        var from = (pageSize*pageNumber)-pageSize; 
        
        for(var i=0;i<resultdata.length;i++)
        {
            if(from <= i && i < to){
                resultdata[i].isVisible = true;}
            else
                resultdata[i].isVisible = false;
        }
        component.set("v.pageNumber",pageNumber);         
        component.set("v.approvalListRecords",resultdata);       
        
        console.log('hasPrevious->'+component.get("v.hasPrevious"));
        var totalPages;       
        if(resultdata.length % pageSize > 0)
            totalPages = parseInt(resultdata.length / pageSize)+1
        else if(resultdata.length % pageSize == 0)
            totalPages = parseInt(resultdata.length / pageSize);			
        component.set("v.total",totalPages);
        component.set("v.hasNext",pageNumber < totalPages);        
        component.set("v.hasPrevious",pageNumber >1); 
        console.log('totalPages'+totalPages);
        console.log('pageNumber'+pageNumber);       
        console.log('appr length'+resultdata.length);
    },
    /* @Method		: nexthelper
       @Description : This Method to handle next records
     */
    nexthelper:function(component, event, helper)
    {
        var resultdata = component.get('v.approvalListRecords');
        var pageSize = component.get('v.pageSize');
        var pageNumber = component.get('v.pageNumber'); 
        pageNumber++;
        var to = pageSize*pageNumber;
        var from = (pageSize*pageNumber)-pageSize;       
        
        for(var i=0;i<resultdata.length;i++)  
        {
            if(from <= i && i < to)
                resultdata[i].isVisible= true;
            else
                resultdata[i].isVisible= false;
        }
        component.set("v.pageNumber",pageNumber);       
        component.set("v.approvalListRecords",resultdata);
        console.log('pageNumber-->'+pageNumber);
        component.set("v.hasPrevious",true);       
        var totalPages;       
        if(resultdata.length % pageSize > 0)
            totalPages = parseInt(resultdata.length / pageSize)+1
        else if(resultdata.length % pageSize == 0)
            totalPages = parseInt(resultdata.length / pageSize);			
        component.set("v.total",totalPages);
       	component.set("v.hasNext",pageNumber < totalPages); 
        console.log('totalPages'+totalPages); 
    },
   	/* @Method		: getStatus
   	   @Description : Based on button click,to update the status to approved, reject or reassigned of Approval requests
   	*/
    getStatus :function(component, event, helper){       
        var action = component.get("c.UpdateStatus");
        var selectCmp = component.find("commentsId");
        var commentval= selectCmp.get("v.value"); 
        var usrId = component.get("v.userId");
        action.setParams({
            status : component.get("v.Status"),            
            ids : component.get("v.id"), 
            comment : commentval, 
            User : usrId,
        }); 
        action.setCallback(this, function(resp) {
            var state=resp.getState();                        
            if(state === "SUCCESS"){
                var resultData = resp.getReturnValue();
                if(resultData!=""){
                	this.showToast("error", "Error!", resultData);
                }else{
                    this.showToast("success", "Success!", "The action has been updated.");
                    this.getRecords(component, event, helper);
                }
            }
        }); 
        helper.getCloseModel(component, event, helper);       
        $A.enqueueAction(action);
    },
    /* @Method 		: getCloseModel
     * @Description	: to close the modal popup.
    */
    getCloseModel :function(component, event, helper){		        
        helper.getRecords(component, event, helper);         		        
        var actionPopUp = component.find("actionPopUp");
       	$A.util.addClass(actionPopUp,'slds-hide');
    },   
    
    /* @Method 		: showToast
     * @Description	: Display Message on Component.
    */
    showToast : function( type, title, msg ){
    	var toastEvent = $A.get("e.force:showToast");
    	toastEvent.setParams({
    		"type": type,
            "title": title,
            "message": msg
        });
        toastEvent.fire();
    },
    //SRSF-3392
    sortBy: function(component, field, sortAsc) { 
        var records = component.get("v.approvalListRecords");  
              
        records.sort(function(a,b){
            var t1 = a[field] == b[field],
                t2 = a[field] > b[field];
            return t1? 0: (sortAsc?-1:1)*(t2?-1:1);
        });       
    
        component.set("v.approvalListRecords", records);       
    },

    //Fetch the releted account on mouseHover 
    getMiniLayout:function(component, event, helper){        
        var getAccount = component.get('v.approvalListRecords');        
        for(var i=0;i<getAccount.length;i++){
            if(getAccount[i].targetObjectId == component.get("v.reId")){
                component.set('v.mouseHoverData', getAccount[i]);
                break;
            }
        }
        component.set("v.hoverRow", parseInt(event.target.dataset.index)); 
        component.set("v.togglehover",true);
    },
})