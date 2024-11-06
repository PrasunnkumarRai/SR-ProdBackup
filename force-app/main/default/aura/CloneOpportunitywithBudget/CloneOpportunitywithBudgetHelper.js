({
    cloneOpportunityBudget : function(component, event, helper) { 
        $A.util.removeClass(component.find("mySpinner"),"slds-hide");
        var action = component.get("c.cloneOpportunity");
        var opp = component.get("v.opportunityRec");
        action.setParams({
            "recordId" : component.get("v.recordId"),
            "record" : opp
        });
        
        action.setCallback(this, function( response ){
            console.log('---->getState: '+response.getState());
            var state = response.getState();           
            if( state === "SUCCESS" ){
                console.log('response value>>>>>'+response.getReturnValue());
                if(response.getReturnValue() !=null){
                    $A.get("e.force:closeQuickAction").fire();
                    var newOpp = response.getReturnValue();
                    console.log('newOpp>>>>>'+newOpp);
                    component.set("v.recordId", newOpp.Id);                     
                    $A.get("e.force:showToast").setParams({
                        "type" : "success",
                        "message" : 'Opportunity '+newOpp.Name+" was created."
                    }).fire();                    
                    $A.get("e.force:navigateToSObject").setParams({
                        "recordId" : newOpp.Id,
                        "slideDevName": "detail"
                    }).fire();               
                
                }/*else{
                    console.log ('Entered in else>>>>');
                    component.find('notifLib').showToast({
                        "variant": "warning",
                        "title": "Warning!",
                        "mode" : "dismissable",
                        "message": "You are not eligible to clone this Opportunity as you are not the Owner."
                    });                   
                }*/
            }else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + 
                                 errors[0].message);                    
                        component.find('notifLib').showToast({
                        "variant": "error",
                        "title": "Error!",
                        "mode" : "dismissable",
                        'message': errors[0].message
                    });
                    }
                } else {
                    console.log("Unknown error");
                }
            } else { 
                console.log('Unknown problem, state: ' + response.getState() + ', error: ' + response.getError());
            }
            $A.util.addClass(component.find("mySpinner"), "slds-hide");
        });
        $A.enqueueAction( action );   
    },

    fecthOpportunityData : function(component, event, helper) {         
        var accountMap = component.get("v.advMap");     
        var action = component.get("c.prePopulateOppData");
        action.setParams({
            "recordId" : component.get("v.recordId")
        });
        
        action.setCallback(this, function( response ){            
            console.log('---->getState: '+response.getState());
            var state = response.getState();           
            if( state === "SUCCESS" ){
                console.log('response value>>>>>'+response.getReturnValue());
                if(response.getReturnValue() !=null){
                    var newOpp = response.getReturnValue();

                    if (response.getReturnValue().Agency_Account__c!=undefined || response.getReturnValue().Agency_Account__c!=''){
                        accountMap[response.getReturnValue().Agency_Account__c] = response.getReturnValue().Agency_Account__c;                  
                    }
                    if (response.getReturnValue().Rep_Firm__c!=undefined || response.getReturnValue().Rep_Firm__c!=''){    
                        accountMap[response.getReturnValue().Rep_Firm__c] = response.getReturnValue().Rep_Firm__c;                  
                    }                
                               
                    newOpp.Name = 'Clone of '+response.getReturnValue().Name;                 
                    component.set("v.opportunityRec",newOpp);
                    component.set("v.advMap",accountMap);
                    console.log('accountMap>>>>>'+component.get("v.advMap")); 

                    // Start: Sridhar: 12-04-2021
                    console.log('newAcct at 130>>>>>'+newOpp);
                   // console.log('Recordtype>>>>'+newOpp.Account.RecordType.DeveloperName);
                    if(newOpp.Account!=null && newOpp.Account.RecordType.DeveloperName!="Advertiser_Account"){
                        component.find('notifLib').showToast({
                                "variant": "warning",
                                "title": "Warning!",
                              //"mode" : "dismissable",
                                "mode" : "sticky",
                                'message': $A.get("$Label.c.Warning_when_create_Opp_for_Agency_RepFirm")
                        });        
                        return false;               
                    }
                    // End: Sridhar: 12-04-2021                
                }
            }else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + errors[0].message);
                        component.find('notifLib').showToast({
	                        "variant": "error",
	                        "title": "Error!",
	                        "mode" : "dismissable",
	                        'message': errors[0].message
	                    });
                    }
                }
                else {
                    console.log("Unknown error");
                }
            } else {  
                console.log('Unknown problem, state: ' + response.getState() + ', error: ' + response.getError());
            }
        });
        $A.enqueueAction( action );
    },
    validateAccountSelection : function(component, event, helper){
        component.set('v.recordError',''); 
        var adv = component.get("v.opportunityRec.AccountId");        
        var accountMap = component.get("v.advMap");       
        console.log('Adv ID>>>>'+adv[0]);      
        var action = component.get("c.validateAccountSelection");
        action.setParams({
            "recId" : adv[0]
        });

        action.setCallback(this, function( response ){
            console.log('---->getState: '+response.getState());
            var state = response.getState();           
            if( state === "SUCCESS" ){
                console.log('response value>>>>>'+response.getReturnValue());
                if(response.getReturnValue() !=null){
                    var newAcct = response.getReturnValue();

                    // Start: Sridhar: 12-04-2021
                    console.log('newAcct at 130>>>>>'+newAcct);
                    console.log('Recordtype>>>>'+newAcct.RecordType.DeveloperName);
                    if(newAcct.RecordType.DeveloperName!="Advertiser_Account"){                        
                        component.find('notifLib').showToast({
                                "variant": "warning",
                                "title": "Warning!",
                              //  "mode" : "dismissable",
                                "mode" : "sticky",
                                'message': $A.get("$Label.c.Warning_when_create_Opp_for_Agency_RepFirm")
                        });        
                        return false;
                    }                         
                    // End: Sridhar: 12-04-2021  


                    if (newAcct.Agency__c==undefined){
                        component.set("v.opportunityRec.Agency_Account__c","");                        
                    } else { 
                        component.set("v.opportunityRec.Agency_Account__c",newAcct.Agency__c);                        
                        accountMap[newAcct.Agency__c] = newAcct.Agency__c;                        
                    }   
                    if (newAcct.Rep_Firm__c==undefined){
                        component.set("v.opportunityRec.Rep_Firm__c","");
                    } else { 
                        component.set("v.opportunityRec.Rep_Firm__c",newAcct.Rep_Firm__c);                        
                        accountMap[newAcct.Rep_Firm__c] = newAcct.Rep_Firm__c;
                    }
                    console.log('accountMap>>>>>'+accountMap); 
                }
            }else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + 
                                 errors[0].message);
                        component.set("v.recordError",errors[0].message);
                        component.find('notifLib').showToast({
	                        "variant": "error",
	                        "title": "Error!",
	                        "mode" : "dismissable",
	                        'message': errors[0].message
	                    });
                    }
                } else {
                    console.log("Unknown error");
                }
            } else {  
                console.log('Unknown problem, state: ' + response.getState() + ', error: ' + response.getError());
            }
        });
        $A.enqueueAction( action );
    },

    validateData : function(component,event){
        event.preventDefault();
        console.log('Error>>>>'+component.get('v.recordError'));
        var fields = event.getParam("fields");        
        try{         
            var cloneOppRec = component.get('v.opportunityRec'); 

            if(cloneOppRec.AccountId==""){
                component.find('notifLib').showToast({
                        "variant": "warning",
                        "title": "Warning!",
                        "mode" : "dismissable",
                        'message': $A.get("$Label.c.Select_Advertiser_on_Opportunity")
                });        
                return false;
            }
            var today = new Date();   
            var dd = today.getDate();
            var mm = today.getMonth() + 1; //January is 0!
            var yyyy = today.getFullYear();
         // if date is less then 10, then append 0 before date   
            if(dd < 10){
                dd = '0' + dd;
            } 
        // if month is less then 10, then append 0 before date    
            if(mm < 10){
                mm = '0' + mm;
            }
        
            var todayFormattedDate = yyyy+'-'+mm+'-'+dd;             
            
            if(cloneOppRec.CloseDate < todayFormattedDate){ 
                component.find('notifLib').showToast({
                        "variant": "warning",
                        "title": "Warning!",
                        "mode" : "dismissable",
                        'message': $A.get("$Label.c.Presentation_Date_Validation_on_Opportunity")
                });        
                return false;
            }             
                    
            console.log ('recordError>>>>>>'+component.get("v.recordError"));
           
            var advMap1 = new Map();            
            var advertMap = component.get("v.advMap");
            // iterate map
            for (var key in advertMap){
                console.log("key: " + key + ", value: " + advertMap[key]);
                advMap1.set(key, advertMap[key]);
            } 
            console.log('map has Agency>>>'+advMap1.has(component.get("v.opportunityRec.Agency_Account__c"))); 
            console.log('map has RepFirm>>>'+advMap1.has(component.get("v.opportunityRec.Rep_Firm__c"))); 
                  
            if(component.get("v.recordError")==''){
                console.log ('In v.recordError check>>>>'); 
                if(advMap1.has(component.get("v.opportunityRec.Agency_Account__c")) && advMap1.has(component.get("v.opportunityRec.Rep_Firm__c"))){                    
                    this.cloneOpportunityBudget (component, event, helper);
                } else if (component.get("v.opportunityRec.Agency_Account__c")=='' || component.get("v.opportunityRec.Agency_Account__c")==undefined) {
                    component.set("v.opportunityRec.Agency_Account__c","");
                    if(component.get("v.opportunityRec.Rep_Firm__c")=='' || component.get("v.opportunityRec.Rep_Firm__c")==undefined){
                        component.set("v.opportunityRec.Rep_Firm__c","");
                        this.cloneOpportunityBudget (component, event, helper);
                    } else if (!advMap1.has(component.get("v.opportunityRec.Rep_Firm__c"))){
                        this.handleConfirmDialog(component, event, helper);
                    } else{
                        this.cloneOpportunityBudget (component, event, helper);
                    }
                } else if (component.get("v.opportunityRec.Rep_Firm__c")=='' || component.get("v.opportunityRec.Rep_Firm__c")==undefined) {
                    component.set("v.opportunityRec.Rep_Firm__c","");
                    if(component.get("v.opportunityRec.Agency_Account__c")=='' || component.get("v.opportunityRec.Agency_Account__c")==undefined){
                        component.set("v.opportunityRec.Agency_Account__c","");
                        this.cloneOpportunityBudget (component, event, helper);
                    } else if (!advMap1.has(component.get("v.opportunityRec.Agency_Account__c"))){
                        this.handleConfirmDialog(component, event, helper);
                    } else {
                        this.cloneOpportunityBudget (component, event, helper); 
                    }
                } else {
                    if (!advMap1.has(component.get("v.opportunityRec.Agency_Account__c")) || !advMap1.has(component.get("v.opportunityRec.Rep_Firm__c"))){
                        this.handleConfirmDialog(component, event, helper);
                    } else {
                        this.cloneOpportunityBudget (component, event, helper);  
                    }                           
                }               
            } else{
                component.find('notifLib').showToast({
                    "variant": "error",
                    "title": "Error!",
                    "mode" : "dismissable",
                    'message': component.get('v.recordError')
                });        
                return false;
            }                
        }catch(e){            
            return false;
        }      
    },
    handleConfirmDialog : function(component, event, helper) {
        var msg = $A.get("$Label.c.Confirmation_dialogue_for_Clone_Opp_Budget");
        if (!confirm(msg)) {
            console.log('Not Confirmed>>>>');
            return false;
        } else {
            console.log('Yes Confirmed>>>>');
            if (component.get("v.opportunityRec.Agency_Account__c")=='') { 
                component.set("v.opportunityRec.Agency_Account__c","");
            }         
            if (component.get("v.opportunityRec.Rep_Firm__c")=='') { 
                component.set("v.opportunityRec.Rep_Firm__c",""); 
            }
            this.cloneOpportunityBudget (component, event, helper);
        }
    },  
})