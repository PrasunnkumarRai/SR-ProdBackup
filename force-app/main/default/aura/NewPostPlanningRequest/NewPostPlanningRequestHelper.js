({
	validateform: function(component) {    
        //START: SRSF-4643 :"Required fields" validation
         var requiredBlankFields = this.getMissingRequiredFields(component.find('requiredField'));
         if ((requiredBlankFields && requiredBlankFields.length > 0) ) {      
           for(var field of requiredBlankFields) {                     
               field.setErrors();
           }        
           this.showerrorToast(component);         
           return ;
       }  
       else{
           console.log('form--success---');
           component.find("editform").submit();
        }  
        //END: SRSF-4643 
	},
    
    showerrorToast : function(component) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": "Required Field Error!",
            "type": "error",
            "message": "Please fill the required fields and then try to save again."
            
        });
        toastEvent.fire(); 
    },
    
    dismissQuickAction : function( component, event, helper ){
        var dismissActionPanel = $A.get("e.force:closeQuickAction");
        dismissActionPanel.fire();
    },
    //START: SRSF-4643 :"Required fields" validation
      getMissingRequiredFields : function (fields) {
        if(!fields) {
            return [];
        } else {
            if(!$A.util.isArray(fields)){
                fields = [fields];
            }
        }
        return fields
        .filter(function (i) {
            var value = i.get('v.value');
            return !value || value == '' || value.trim().length === 0;
        })
        .map(function (i) {
          return i;
        });
    }
      //END: SRSF-4643 
})