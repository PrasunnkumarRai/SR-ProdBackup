({
    displayQuestions : function( component, event, helper ) {
        //var categoryname = component.get("v.selectedCategory");
        var action = component.get("c.getQuestions");
        //alert(categoryname);
        action.setParams({
            "category" : null
        });
        action.setCallback(this, function( response ){
            var state = response.getState();
            if( state === "SUCCESS"){
                component.set("v.showGeneralQuestions", true);
                component.set("v.generalQuestions", response.getReturnValue());
            }
            
        });
        $A.enqueueAction(action);
    },
    
    reviewQuestions : function( component, event, helper ){
        component.set("v.isReview", true);
        component.set("v.isReadonly", true);
        //window.print();
    },
    
    editQuestions : function( component, event, helper ){
        component.set("v.isReadonly", false);
        component.set("v.isReview", false);
        //window.print();
    },
    
    printQuestions : function( component, event, helper ){
        //document.getElementById("btndiv").style.display="none";
        component.set("v.isPrint", true);
        window.print();
    },
    
    emailQuestions : function( component, event, helper ){
        //console.log(component.get("v.generalQuestions"));
        var lstgeneralQuestions = [];
        lstgeneralQuestions = component.get("v.generalQuestions");
        //console.log(JSON.stringify(lstgeneralQuestions));
        var aeId = component.get("v.aeId");
        var action = component.get("c.emailQuestionsAndAnswers");
        action.setParams({
            "strgeneralQuestionWrap" : JSON.stringify(lstgeneralQuestions),
            "aeid" : aeId
        });
        action.setCallback(this, function( response ){
            console.log('---->getState: '+response.getState());
            var state = response.getState();
            if( state == "SUCCESS" ){
                $A.get("e.force:showToast").setParams({
                    "type" : "success",
                    "message" : "Email sent successfully."
                }).fire();
            }else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + 
                                 errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            } else {
                console.log('Unknown problem, state: ' + response.getState() + ', error: ' + response.getError());
            }
        });
        $A.enqueueAction(action);
    },
    
    dismissQuickAction : function( component, event, helper ){
        var dismissActionPanel = $A.get("e.force:closeQuickAction");
        dismissActionPanel.fire();
    }
})