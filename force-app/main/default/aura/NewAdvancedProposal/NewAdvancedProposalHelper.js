({
    fetchProposalData : function(component, event, helper)
    {
        console.log ('inside fetchProposalDates>>>>>');
        var recordId = component.get("v.recordId");
        var action = component.get("c.fetchProposalData");
        action.setParams({
            "proposalId" : recordId                     
        }); 
        action.setCallback(this, function(response)
        {
            var state = response.getState();
            if(state == "SUCCESS")
            {
               var data = response.getReturnValue();
               if(data != "" || data != null)
                {
                    component.set("v.recordData", data);                   
                    var msg;
                    var prop = data.defaultFieldValues;
                    console.log('data--->'+prop);      
                    component.set('v.propStartDt',prop.Start_Date__c);
                    component.set('v.propEndDt',prop.End_Date__c);         

                    /*if(prop.DigitalPropsCnt == null || prop.DigitalPropsCnt == 0)
                    { 
                    msg = $A.get("$Label.c.Advanced_Prop_can_t_be_created_for_Non_Digital_Proposal_Zones");
                    }
                    else*/
                    if(!prop.Active__c)
                    {
                    msg = $A.get("$Label.c.Advanced_Proposal_can_t_be_created_for_Inactive_Proposals");
                    }
                    else if(prop.StageName == 'Closed Lost' || prop.StageName =='Closed Lost to Competitor')
                    { 
                    msg = $A.get("$Label.c.Advanced_Prop_Cannot_be_created_for_Closed_Lost_Opportunities");
                    } 
                    console.log('msg-->'+msg);
                    if(msg != undefined)
                    {
                        this.showToastMsg (component, "Error!","error", msg);
                        $A.get("e.force:closeQuickAction").fire();
                    }
                }
            }
        });
        $A.enqueueAction(action);
    },    

    createAdvancedProposal : function(component, event, helper) 
    {
        console.log ('inside createAdvancedProposal>>>>>');       
        var msg;
        var recordId = component.get("v.recordId");
        var orderType = component.find("orderType").get("v.value");
        console.log('>>>'+orderType);
        var prodType = component.get("v.productType").toString();
        console.log('prodType>>>>>'+prodType);            
        var productType = prodType.replaceAll(",", ";");
        console.log('productType>>>>>'+productType);
        var selectedStartDt = component.find("startDt").get("v.value");
        var selectedEndDt = component.find("endDt").get("v.value");
        var today = $A.localizationService.formatDate(new Date(), "YYYY-MM-DD");
        
        /*if(selectedStartDt < component.get('v.propStartDt') || selectedEndDt > component.get('v.propEndDt'))
        {
            msg = $A.get("$Label.c.Adv_Prop_Dates_must_be_within_Prop_Dates_Range");
            this.showToastMsg (component, "ERROR!","Error", msg);           
        } 
        else */
        if(selectedStartDt < today || selectedEndDt < today) 
        {
            msg = $A.get("$Label.c.Adv_Prop_Dates_must_be_in_future_Dates");
            this.showToastMsg (component, "ERROR!","Error", msg);           
        } 
        else if (orderType == null || orderType == '' || orderType == undefined)
        {
            msg = 'Order Type must be mandatory';
            this.showToastMsg (component, "ERROR!","Error", msg);
        } 
        else if (prodType == null || prodType == '' || prodType == undefined)
        {
            msg = 'Product Type must be mandatory';
            this.showToastMsg (component, "ERROR!","Error", msg);
        }
        else 
        {
            var action = component.get("c.createAdvancedProposal");
            action.setParams({
                "pilotPropId" : recordId,
                "orderType" : component.find("orderType").get("v.value"),
                "productType" : productType,
                "advPropName" : component.find("advpropName").get("v.value"),
                "startDt" : selectedStartDt,
                "endDt" : selectedEndDt                        
            }); 
            action.setCallback(this, function(response)
            {
                var state = response.getState();
                if(state == "SUCCESS" && response.getReturnValue()!=null)
                { 
                    console.log('response value>>>>>'+response.getReturnValue());                   
                    var newAdvProp = response.getReturnValue();
                    console.log('newAdvProp>>>>>'+newAdvProp);
                    
                    msg = "Advanced Proposal record has been created successfully.";
                    this.showToastMsg(component, "Success!","success", msg); 

                    $A.get("e.force:navigateToSObject").setParams({
                    "recordId" : newAdvProp.Id,
                    "slideDevName": "detail"
                    }).fire();  

                    $A.get("e.force:closeQuickAction").fire();
                }
                else if(state == "ERROR")
                {
                    var errors = response.getError();
                    if (errors)
                    {
                        if (errors[0] && errors[0].message)
                        {
                            console.log("Error message: " + errors[0].message);
                            this.showToastMsg(component, "ERROR!","Error", errors[0].message);
                        }
                    } 
                    else
                    {
                        console.log("Unknown error");
                    }
                }
            });
            $A.enqueueAction( action );
        }    
    },
    showToastMsg : function(component,title,type,msg) {
        var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": title,
                "type" : type,
                "mode" : "dismissible",
                "duration" : 5000,
                "message": msg
            });
        toastEvent.fire();        
    },
    getPicklistValues : function(component, fieldName, orderType)
    {
        var action = component.get("c.getPicklistValues");
        action.setParams({ 'dependentfieldName' : fieldName, 'controllingFieldValue' : orderType});    
        action.setCallback(this, function(response)
        {
            console.log ('response-1>>>>'+response);
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS")
            {                    
                var options = [];
                var result = response.getReturnValue();
                for (var i = 0; i < result.length; i++)
                {
                    options.push({
                        label: result[i],
                        value: result[i]
                    });
                }                    
                if(fieldName == 'Product_Type__c')
                {
                    component.set("v.productTypeList", options);
                }
            }
        });
        $A.enqueueAction(action);      
    }
})