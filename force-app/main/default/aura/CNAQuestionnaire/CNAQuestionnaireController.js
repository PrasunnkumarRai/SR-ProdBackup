({
	doInit : function(component, event, helper) {
        helper.loadCategoryTypes( component, event, helper );
        helper.displayAnswers( component, event, helper );
        helper.getAEUserCNA(component, event, helper);
	},
    doEdit : function(component, event, helper) {
        helper.doEdit( component, event, helper );
	},
    displaySupplementalQuestions : function(component, event, helper) {
        alert("coming..");
        helper.displayQuestions( component, event, helper );
    },
    doCancel : function(component, event, helper) {
        helper.doCancel( component, event, helper );
	},
    doSave : function(component, event, helper) {
        helper.doSave( component, event, helper );
	},
    printQuestions : function(component, event, helper){
        helper.printQuestions( component, event, helper );
    },
    emailQuestions : function(component, event, helper){
        helper.emailQuestions( component, event, helper );
    }
    
})