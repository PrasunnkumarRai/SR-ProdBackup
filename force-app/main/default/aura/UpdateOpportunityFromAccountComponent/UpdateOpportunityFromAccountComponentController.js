({
    doInit: function (component, event, helper) {
        
        // Check to enable or disable button on load        
        var enableButton = component.get('c.isBatchRunning');
        enableButton.setCallback(this,function(res){
            var currentState = res.getState();
            if(currentState === 'SUCCESS'){
                console.log(res.getReturnValue());
                component.set('v.buttonEnabled',res.getReturnValue());
                // Check if batch is running
                if(res.getReturnValue() == false){
                    component.find("UpdateOpportunity").set("v.disabled",true);
                    $A.createComponents([
                        ["ui:message",{ 
                            "title" : $A.get("$Label.c.OpportunityUpdateViaBatchInProgress") + " in progress",
                            "severity" : "warning",
                        }],
                        ["ui:outputText",{
                            "value" : ""
                        }]
                    ],
                                        function(components, status, errorMessage){
                                            
                                            var message = components[0];
                                            var outputText = components[1];
                                            // set the body of the ui:message to be the ui:outputText
                                            message.set("v.body", outputText);
                                            var batchStarted = component.find("batchStarted");
                                            // Replace div body with the dynamic component
                                            batchStarted.set("v.body", message);
                                        }
                                        
                                        
                                       );
                }
            }
        });
        $A.enqueueAction(enableButton);
        
        var action = component.get('c.getAccountList');
        action.setCallback(this,function(res){
            var state = res.getState();
            if(state ==='SUCCESS'){
                console.log(res.getReturnValue());
                component.set('v.AccountData',res.getReturnValue());
                if(res.getReturnValue().length == 0 ){
                    component.find("UpdateOpportunity").set("v.disabled",true);
                    $A.createComponents([
                        ["ui:message",{
                            "title" : "No Accounts found",
                            "severity" : "warning",
                        }],
                        ["ui:outputText",{
                            "value" : ""
                        }]
                    ],
                                        function(components, status, errorMessage){
                                            
                                            var message = components[0];
                                            var outputText = components[1];
                                            // set the body of the ui:message to be the ui:outputText
                                            message.set("v.body", outputText);
                                            var noRecordFound = component.find("noRecordFound");
                                            // Replace div body with the dynamic component
                                            noRecordFound.set("v.body", message);
                                        }
                                        
                                        
                                       );      
                }
                //console.log('size of Account List'+res.getReturnValue().length);
                
                
            }
            
        });
        $A.enqueueAction(action);
        
        
    },
    runBatch: function(component,event,helper){
        $A.createComponents([ 
            ["ui:message",{
                "title" : $A.get("$Label.c.OpportunityUpdateViaBatchStarted"),
                "severity" : "info",
            }],
            ["ui:outputText",{
                "value" : ""
            }]
        ],
                            function(components, status, errorMessage){
                                
                                var message = components[0];
                                var outputText = components[1];
                                // set the body of the ui:message to be the ui:outputText
                                message.set("v.body", outputText);
                                var batchStarted = component.find("batchStarted");
                                // Replace div body with the dynamic component
                                batchStarted.set("v.body", message);
                            }
                           );
        var action = component.get('c.runBatchApex');
        action.setCallback(this,function(res){
            var state = res.getState();
            if(state === 'SUCCESS'){
                console.log(res.getReturnValue());
                component.set("v.jobId",res.getReturnValue());
                var btn = event.getSource();
                btn.set("v.disabled",true);//Disable the button
                window.setInterval(
                    $A.getCallback(function(){
                        var checkResult = component.get("c.getBatchStatus");
                        checkResult.setParams({jobId: component.get("v.jobId")})
                        checkResult.setCallback(this,function(result){
                            if(result.getReturnValue().Status == 'Completed'){
                                var action = component.get('c.getAccountList');
                                action.setCallback(this,function(res){
                                    var state = res.getState();
                                    if(state ==='SUCCESS'){
                                        console.log(res.getReturnValue());
                                        component.set('v.AccountData',res.getReturnValue());
                                        if(res.getReturnValue().length == 0 ){
                                            component.find("UpdateOpportunity").set("v.disabled",true);
                                            $A.createComponents([
                                                ["ui:message",{
                                                    "title" : "No Accounts found",
                                                    "severity" : "warning",
                                                }],
                                                ["ui:outputText",{
                                                    "value" : ""
                                                }]
                                            ],
                                                                function(components, status, errorMessage){
                                                                    
                                                                    var message = components[0];
                                                                    var outputText = components[1];
                                                                    // set the body of the ui:message to be the ui:outputText
                                                                    message.set("v.body", outputText);
                                                                    var noRecordFound = component.find("noRecordFound");
                                                                    // Replace div body with the dynamic component
                                                                    noRecordFound.set("v.body", message);
                                                                }
                                                                
                                                                
                                                               );      
                                        }
                                        //console.log('size of Account List'+res.getReturnValue().length);
                                        
                                        
                                    }
                                    
                                });
                                $A.enqueueAction(action);                                
                            }
                            var severityClass= "info";
                            if(result.getReturnValue().ExtendedStatus != null){
                                severityClass ="error";
                            }
                            $A.createComponents([ 
                                ["ui:message",{
                                    "title" : $A.get("$Label.c.OpportunityUpdateViaBatchInProgress")+' '+result.getReturnValue().Status,
                                    "severity" : severityClass,
                                }],
                                ["ui:outputText",{
                                    "value" : result.getReturnValue().ExtendedStatus
                                }]
                            ],
                                                function(components, status, errorMessage){
                                                    
                                                    var message = components[0];
                                                    var outputText = components[1];
                                                    // set the body of the ui:message to be the ui:outputText
                                                    message.set("v.body", outputText);
                                                    var batchStarted = component.find("batchStarted");
                                                    // Replace div body with the dynamic component
                                                    batchStarted.set("v.body", message);
                                                }
                                               );
                            
                        });
                        $A.enqueueAction(checkResult);
                    }),500
                )
                
            }
        });
        $A.enqueueAction(action)
  
    }
})