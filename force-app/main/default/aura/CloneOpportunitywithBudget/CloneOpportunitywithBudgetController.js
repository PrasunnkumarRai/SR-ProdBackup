({
  doInit : function(component, event, helper) {        
    helper.fecthOpportunityData( component, event, helper );
  },

  handleSubmit : function(component, event, helper) {
    helper.validateData(component, event); 
  },  

  validateAgencyRepFirm : function(component, event, helper) {     
    if(component.get("v.opportunityRec.AccountId")!=''){   
      helper.validateAccountSelection (component, event, helper);
    }  
  } 
})