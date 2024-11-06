({
	doInit : function(component, event,helper){
		//console.log('atmAdminToolController doInit');
		var recordId = component.get("v.recordId");
        //console.log('component recordId '+recordId);
        helper.doInit(component,event,helper);
    },
    selectAllCheckBox : function(component,event,helper){
    	helper.selectAllCheckBox(component,event,helper);
    },
    changeRowSelectedCheckBox : function(component,event,helper){
    	helper.changeRowSelectedCheckBox(component,event,helper);
    },        
    doDeleteSelectedAtm : function(component,event,helper){
      //console.log('doDeleteSelectedAtm controller ');
      helper.doDeleteSelectedAtm(component,event,helper);
	},
    /* @Method      : previous
    *  @Description  : This Method to handle previous records , calls helper previoushelper method					
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
    resetSelection : function(component,event,helper){
      window.location.reload();
    },
    
    dismissQuickAction : function( component, event, helper ){
        helper.dismissQuickAction( component, event, helper );
    }   
})