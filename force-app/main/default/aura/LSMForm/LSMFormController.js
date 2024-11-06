({
	doInit : function(component, event, helper) {
        helper.displayQuestions( component, event, helper );
	},
    dismissQuickAction : function(component, event, helper){
        helper.dismissQuickAction( component, event, helper );
    },
    reviewQuestions : function(component, event, helper){
        helper.reviewQuestions( component, event, helper );
    },
    editQuestions : function(component, event, helper){
        helper.editQuestions( component, event, helper );
    },
    printQuestions : function(component, event, helper){
        helper.printQuestions( component, event, helper );
    },
    emailQuestions : function(component, event, helper){
        helper.emailQuestions( component, event, helper );
    }
})