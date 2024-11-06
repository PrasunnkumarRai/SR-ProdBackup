({
    validateform: function(component) {
        let assignedTo ;
        var userProfile = component.get("v.currentUser.Profile.Name");
        var profilesVisibleAssignedTo_PR = $A.get("$Label.c.ProfilesVisibleAssignedTo_PR");
        var profilesVisibleAssignedTo_PRList = profilesVisibleAssignedTo_PR.split(',');
        var reqFieldAssignedTo = component.find('requiredField1');       
        if(profilesVisibleAssignedTo_PRList.includes(userProfile)){
            if($A.util.isEmpty(reqFieldAssignedTo.get("v.value"))){
                reqFieldAssignedTo.reportValidity();
                console.log('reqFieldAssignedToreqFieldAssignedTo---->'+ reqFieldAssignedTo);
                assignedTo = true;
            } 
            else{
                assignedTo =false;
            }
        }
        
      //START: SRSF-4643 :"Required fields" validation
        var requiredBlankFields1 ;
        if(assignedTo){
            requiredBlankFields1 = this.getMissingRequiredFields(component.find('requiredField1'));
        }        
        var requiredBlankFields = this.getMissingRequiredFields(component.find('requiredField')); 
        if(requiredBlankFields1 && requiredBlankFields1.length>0)
            requiredBlankFields = [...requiredBlankFields1,...requiredBlankFields];    
        if ((requiredBlankFields && requiredBlankFields.length > 0) ) {
            
            for(var field of requiredBlankFields) {                 
                field.setErrors();
            }        
            this.showerrorToast(component);         
            return ;
        }      
        else {
            console.log('form--success---');
            component.find("editform").submit();           
        } 
        //END:SRSF-4643 
    },
    
    showerrorToast : function(component) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": "Required Field Error!",
            "type": "error",
            "message": "Please fill the required fields and then try to save again"
           
        });
        toastEvent.fire();
    },
    
    //START: SRSF-4643 : Added this method
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
            var value = i.get('v.value')
            return !value || value == '' || value.trim().length === 0;
        })
        .map(function (i) {
            //return i.get('v.fieldName');
            return i;
        });
    },
    //END: SRSF-4643 :
})