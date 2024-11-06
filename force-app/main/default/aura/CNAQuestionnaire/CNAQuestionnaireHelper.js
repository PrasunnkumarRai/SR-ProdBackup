({
    
    //Loads the all category type
	loadCategoryTypes : function( component, event, helper ) {
        var action = component.get("c.getCategoryTypesForEdit");
        var recid = component.get("v.recordId");
        var recordTypeName = component.get("v.recordTypeName");
        action.setParams({
            "strCNAId" : recid,
            "recordTypeName" : recordTypeName
        });
        action.setCallback(this, function( response ){
            console.log('----> response.getState(): '+response.getState());
            if(response.getState()=="SUCCESS"){
                if(response.getReturnValue() !=null && recordTypeName=='Questionnaire'){
                    component.set("v.showOptions", true);
                    component.set("v.categoryOptions", response.getReturnValue());
                    console.log("@@@=",response.getReturnValue() );
                }else if(response.getReturnValue() !=null && recordTypeName=='CNA Prep'){
                    component.set("v.showOptions", false);
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
    
	//Loads the all category type
	displayAnswers : function( component, event, helper ) {
        var action = component.get("c.getAnswers");
        console.log("component.get",component.get("v.recordTypeName"));
        action.setParams({
            "strCNAId" : component.get("v.recordId"),
            "recordTypeName" : component.get("v.recordTypeName")
            //"strCNAId" : "a0655000003sxhHAAQ"
        });
        action.setCallback(this, function( response ){
            console.log('----> response.getState(): '+response.getState());
            if(response.getState()=="SUCCESS"){
                
                var cols = [
                    {label: 'No', fieldName: 'QuestionNumber', type: 'text', initialWidth: 80},
                    {label: 'Question Name', fieldName: 'linkName',type: 'url', wrapText: true,
             typeAttributes: {label: { fieldName: 'QuestionName', }, target: '_blank'}},
                    {label: 'Category', fieldName: 'CategoryName', type: 'text', initialWidth: 100},
                    //{label: 'Question Type', fieldName: 'QuestionTypeName', type: 'text'},
                    {label: 'Answer', fieldName: 'AnswerName', type: 'text', wrapText: true}
                ];
                component.set("v.columns", cols);
                
                if(response.getReturnValue() !=null){
                    var lstAnswers = response.getReturnValue();
                    console.log("lstAnswers1", lstAnswers);
                    lstAnswers = this.prepareTableData(component, event, helper, lstAnswers);
                    console.log("lstAnswers2", lstAnswers);
                    component.set("v.Answers", lstAnswers);
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
        var recordTypeNameQuestionnaire = component.get("v.questionnaireRecordType");
        console.log("recordTypeName", recordTypeNameQuestionnaire);
        var action = component.get("c.getQuestions");
        action.setParams({
            "category" : categoryname,
            "recordTypeName" : recordTypeNameQuestionnaire
        });
        action.setCallback(this, function( response ){
            var state = response.getState();
            console.log("@@success?" , state);
            if( state === "SUCCESS"){
                if(recordTypeNameQuestionnaire == 'CNA'){
                    console.log(response.getReturnValue());
                    component.set("v.showSupplementalQuestions", true);
                    component.set("v.supplementalQuestions", response.getReturnValue());
                }else{
                    component.set("v.showSupplementalQuestions", false);
                }
                
            }
            
        });
        $A.enqueueAction(action);
    },
    
    //Helper method for preparing references field for Datatable
    prepareTableData : function (component, event, helper,lstAnswers) {
        var genIndex = 0;
        var supIndex = 0;
        for (var i = 0; i < lstAnswers.length; i++) {
            var row = lstAnswers[i];
            row.linkName = '/'+row.objAns.Id;//to redirect to Answer details
            
            // checking if any QuestionName related data in row
            if (row.objAns.Question_Name__c) {
                row.QuestionName = row.objAns.Question_Name__c;
            }
            // checking if any Category related data in row
            if (row.objAns.Questions__r.Category__c) {
                row.CategoryName = row.objAns.Questions__r.Category__c;
            }
            if(row.CategoryName=='General'){
                ++genIndex;
                row.QuestionNumber = genIndex+'.';
            }else{
                ++supIndex;
                row.QuestionNumber = 'S-'+supIndex+'.';
            }
            /*
            // checking if any QuestionType related data in row
            if(row.objAns.Questions__r.Question_Type__c) {
                row.QuestionTypeName = row.objAns.Questions__r.Question_Type__c;
            }*/ 
            // checking if any Answer with Text or multi-select related data in row
            var answer = '';
            if (row.objAns.Answer_With_Text__c !=null && row.objAns.Answer_With_Text__c!='') {
                row.AnswerName = row.objAns.Answer_With_Text__c;
            }else{
                row.AnswerName = row.objAns.Answer_Items__c;
            }
        }
        return lstAnswers;
	},
    
    doEdit : function(component, event, helper){     
        component.set("v.isEdit", true);
        helper.displayQuestions( component, event, helper );  
    },
    
    doCancel : function(component, event, helper){
        component.set("v.isEdit", false);
        component.set("v.showSupplementalQuestions", false);
    },
    
    doSave : function(component, event, helper){
        component.set("v.isSpinnerVisible", true);
        var lstAnswers = [];
        lstAnswers = component.get("v.Answers");
        
        var suppWrap = [];
        suppWrap = component.get("v.supplementalQuestions");
        //alert(lstAnswers[8].lstSelectedAanswers);
        //return;
        console.log(JSON.stringify(suppWrap));
        var action = component.get("c.saveAnswers");
        action.setParams({
            "strCNAId" : component.get("v.recordId"),
            "answers" : JSON.stringify(lstAnswers),
            "strsupplementalQuestionWrap" : JSON.stringify(suppWrap)
        });
        
        action.setCallback(this, function( response ){
            //console.log('----> response.getState(): '+response.getState());
            if(response.getState()=="SUCCESS"){
                component.set("v.isSpinnerVisible", false);
                this.loadCategoryTypes(component, event, helper);
                this.displayAnswers(component, event, helper);
                component.set("v.showSupplementalQuestions", false);
                component.set("v.selectedCategory", "");
                component.set("v.isEdit", false);
            }
        });
        $A.enqueueAction( action );
    },
    printQuestions : function(component, event, helper){
        component.set("v.isPrint", true);
        window.print();
    },
    getAEUserCNA : function(component, event, helper){
        console.log("GET AE USER");
        var action = component.get("c.getAeCNA");
        var recid = component.get("v.recordId");
        action.setParams({
            "strCNAId" : recid
        });
        action.setCallback(this, function( response ){
            console.log('----> GET AE response.getState(): '+response.getState());
            if(response.getState()=="SUCCESS"){
               var AEUSerId = response.getReturnValue();
               console.log("AEUSerId", AEUSerId);
               component.set("v.aeId",AEUSerId );
            }
    });
      $A.enqueueAction( action );  
    } ,
    
     emailQuestions : function( component, event, helper ){
        var lstgeneralAnswers = [];
        lstgeneralAnswers= component.get("v.Answers");
        //var aeId = component.get("v.aeId");
        var userId = $A.get("$SObjectType.CurrentUser.Id");
        var action = component.get("c.emailQuestionsAndAnswers");
        action.setParams({
            "strgeneralQuestionWrap" : JSON.stringify(lstgeneralAnswers),
            "aeid" : userId
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
})