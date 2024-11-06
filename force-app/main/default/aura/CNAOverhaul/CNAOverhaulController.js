({
	doInit : function(component, event, helper) {
        helper.loadCategoryTypes( component, event, helper );
        helper.displayQuestions( component, event, helper );
       
	},
    displaySupplementalQuestions : function(component, event, helper) {
        //alert("coming..");
        helper.displayQuestions( component, event, helper );
    },
    dismissQuickAction : function(component, event, helper){
        helper.dismissQuickAction( component, event, helper );
    },
    SaveQuestions : function(component, event, helper){
        helper.saveQuestions( component, event, helper );
    }
})