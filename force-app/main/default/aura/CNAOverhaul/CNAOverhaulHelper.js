({
    //Loads the all category type
	loadCategoryTypes : function( component, event, helper ) {
        var action = component.get("c.getCategoryTypes");
        var recid = component.get("v.recordId");
        action.setParams({
            "opportunityId" : recid
        });
        action.setCallback(this, function( response ){
            //console.log('----> response.getState(): '+response.getState());
            if(response.getState()=="SUCCESS"){
                if(response.getReturnValue() !=null){
                    component.set("v.showOptions", true);
                    component.set("v.categoryOptions", response.getReturnValue());
                }else{
                    var objName = (recid.startsWith("001"))? "Account" : "Opportunity";
                    var toastEvent = $A.get("e.force:showToast");
                     toastEvent.setParams({
                       mode: "sticky",
                       type:"error",
                       message: "You must be on the "+objName+" Team in order to create a CNA on this Opportunity.",              
                     });
                     $A.get("e.force:closeQuickAction").fire();
                     toastEvent.fire();
                     $A.get("e.force:refreshView").fire();
                }
            }else if( state == "ERROR" ){
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + 
                                 errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
        $A.enqueueAction( action );
	},
    
    displayQuestions : function( component, event, helper ) {
        var categoryname = component.get("v.selectedCategory");
        var action = component.get("c.getQuestions");
        console.log('@@@@@2' , component.get("v.recordTypeName"));
        //alert(categoryname);
        action.setParams({
            "category" : categoryname,
            "recordTypeName" : component.get("v.recordTypeName")
        });
        
        action.setCallback(this, function( response ){
            var state = response.getState();
            if( state === "SUCCESS"){
                if(categoryname == 'General'){
                	component.set("v.showGeneralQuestions", true);
                    component.set("v.generalQuestions", response.getReturnValue());
                }
                if(categoryname != 'General' && component.get("v.recordTypeName") == 'CNA'){
                    component.set("v.showSupplementalQuestions", true);
                    component.set("v.supplementalQuestions", response.getReturnValue());
                    //component.set("v.showOptions", false);
                }
                else if(component.get("v.recordTypeName") == 'CNA Prep Sheet'){
                    component.set("v.showSupplementalQuestions", false);
                    component.set("v.showOptions", false);
                }
                console.log(response.getReturnValue());
            }
            
        });
        $A.enqueueAction(action);
    },
    
    saveQuestions : function( component, event, helper ){
        component.set("v.isSpinnerVisible", true);
        var categoryname = component.get("v.selectedCategory");
        var action = component.get("c.insertQuestionsAndAnswers");
        console.log(component.get("v.recordId"));
        console.log(component.get("v.selectedCategory"));
        console.log(component.get("v.generalQuestions"));
        console.log(component.get("v.supplementalQuestions"));
        action.setParams({
            "opportunityId" : component.get("v.recordId"),
            "generalCategory" : "General",
            "supplementalCategory" : component.get("v.selectedCategory"),
            "strgeneralQuestionWrap" : JSON.stringify(component.get("v.generalQuestions")),
            "strsupplementalQuestionWrap" : JSON.stringify(component.get("v.supplementalQuestions")) ,
            "recordTypeName" : component.get("v.recordTypeName")
        });
        action.setCallback(this, function( response ){
            console.log('---->getState: '+response.getState());
            var state = response.getState();
            if( state == "SUCCESS" ){
                component.set("v.isSpinnerVisible", false);
                var newQuestioneer = response.getReturnValue();
                //alert(newQuestioneer);
                $A.get("e.force:navigateToSObject").setParams({
                    "recordId": newQuestioneer
                }).fire();
                $A.get("e.force:closeQuickAction").fire();
                $A.get("e.force:showToast").setParams({
                    "type" : "success",
                    "message" : "CNA Questionnaire is created successfully."
                }).fire();
            }else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + errors[0].message);
                        //SRSF-4428: Added toastevent
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "type": "error",
                            "title": "Error!",
                            "message": errors[0].message ,
                            "duration": "10000"
                        });                 
                        toastEvent.fire();  
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
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": component.get("v.recordId")
        });
    navEvt.fire();
    }
})