({
    loadARRecordTypes : function( component, event, helper ) {
        
        var action = component.get("c.getARRecordTypes");
        action.setParams({
            "recordId" : component.get("v.recordId")
        });
        action.setCallback(this, function( response ){ 
            var state = response.getState();
            if( state == "SUCCESS"){
                var respWrapper = response.getReturnValue();
                component.set("v.responseObj", respWrapper );
                console.log('----> respWrapper: '+JSON.stringify(respWrapper) );
                console.log('----> profileName: '+respWrapper.profileName );

                // for(var j=0;j<respWrapper.lstRecordTypes.length;j++) {
                //     if(respWrapper.lstRecordTypes[j].Name == 'Team Member Request'){
                //       var Recordtype= respWrapper.lstRecordTypes[j].Name;
                //       break;
                //     }
                //    }
                //    console.log('Recordtype',Recordtype);
            // if(respWrapper.profileName == "Master - Digital Operations" || respWrapper.profileName == "Master - Optimization Manager"){
            //    component.set("v.showUserAEList",false);
            // }
           		
                 if(respWrapper.profileName == "Master - Account Executive"){
                    var userId = $A.get("$SObjectType.CurrentUser.Id");
                    console.log('is current logged in user is AE? - ',respWrapper.profileName == "Master - Account Executive",' UserId - ',userId);
                    component.set("v.selectedAE",userId);
            	 }


                if( respWrapper.lstRecordTypes != null && respWrapper.lstRecordTypes.length > 0 ){
                    component.set( "v.selectedRT", respWrapper.lstRecordTypes[0].Id );
                    var selectedRT = component.get("v.selectedRT");
                     var responseObj = component.get("v.responseObj");
                    var selectedRecordType = responseObj.lstRecordTypes.find(function(recordType) {
                        return recordType.Id === selectedRT;
                    });

                    // Retrieve the Name property if a match is found
                    var selectedRecordTypeName = selectedRecordType ? selectedRecordType.Name : null;
                    // Now, selectedRecordTypeName contains the Name of the matching record type
                    console.log(selectedRecordTypeName);

                    if(selectedRecordTypeName == 'Team Member Request' || selectedRecordTypeName == 'Search ID Request'|| respWrapper.isCurrentUserAE ==true){
                        component.set("v.showUserAEList",false);
                    }
                    else{
                        component.set("v.showUserAEList",true);
                    }
                    // component.set( "v.selectedRTName", respWrapper.lstRecordTypes[0].Name );

                    // console.log('v.selectedRTName : ',respWrapper.lstRecordTypes[0].Name);
                    component.find("btnNext").set("v.disabled", false);
                    if( !respWrapper.isCurrentUserAE )
                        helper.getAETeamMembers( component, event, helper );

                }else{
                    component.set("v.rtAccessFailed", true);
                }
                
            }else if( state == "ERROR"){
                var errors = response.getError(); 
                console.log('----> Error : '+JSON.stringify( errors[0] ) );
            }
        });
        $A.enqueueAction( action );
    },
    
    getAETeamMembers : function( component, event, helper ){
        var action = component.get("c.getAETeamMembers");
        action.setParams({
            "accountId" : component.get("v.recordId")
        });
        action.setCallback(this, function( response ){
            var state = response.getState();
            if( state == "SUCCESS" ){
                var responseObj = component.get("v.responseObj");
                var lstUsers = response.getReturnValue();
                responseObj.lstUsers = lstUsers;
                component.set( "v.responseObj", responseObj );
                console.log('---> getAETeamMembers lstUsers: '+JSON.stringify( lstUsers ));
                console.log('---> getAETeamMembers responseObj.lstUsers: '+JSON.stringify( responseObj.lstUsers ));
                component.set('v.selectedAE', '');
                if( ( this.isNotBlack( responseObj.switchRTId ) && responseObj.lstRecordTypes[0].Id == responseObj.switchRTId && !responseObj.isUserLSM ) || 
                   	  this.isNotBlack( responseObj.teamMemberRTId ) && responseObj.lstRecordTypes[0].Id == responseObj.teamMemberRTId ){
                    console.log('---> getAETeamMembers inside if.');
                    component.set("v.showUserList", false );
                }else{
                    console.log('---> getAETeamMembers inside else.');
                
                    if( lstUsers.length == 0 ){
                        console.log('---> getAETeamMembers inside else if.');
                        component.set("v.showUserList", false );
                        component.set("v.aeAccessFailed", true);
                        component.find("btnNext").set("v.disabled", true);
                        
                    }else{
                        console.log('---> getAETeamMembers inside else else');
                        component.set("v.showUserList", true );
                        console.log('---> getAETeamMembers inside else else '+component.get("v.showUserList") );
                        component.set( "v.selectedAE", lstUsers[0].Id );
                        component.find("btnNext").set("v.disabled", false);
                    }
                }
            }
            if( state == "ERROR"){
                var errors = response.getError();
                console.log('----> Error : '+JSON.stringify( errors[0] ) );
            }
        });
        $A.enqueueAction( action );
    },
    
    createNewAccountRequestHelper : function( component, event, helper ) {
        var accountId = component.get("v.recordId");
        var selectedRT = component.get("v.selectedRT");
        var selectedAE = component.get("v.selectedAE");
        var responseObj = component.get("v.responseObj");
        var action = component.get("c.getAccountData");

        var selectedRecordType = responseObj.lstRecordTypes.find(function(recordType) {
            return recordType.Id === selectedRT;
        });

        // Retrieve the Name property if a match is found
        var selectedRecordTypeName = selectedRecordType ? selectedRecordType.Name : null;
        // Now, selectedRecordTypeName contains the Name of the matching record type
        console.log(selectedRecordTypeName);

        

        if(selectedRecordTypeName === 'Audience Trak Access Request'){
            // component.set("v.openContactRequestFlow", false);
            component.set("v.selectedRTNameForContactRequest",selectedRT);
            console.log('selectedRTNameForContactRequest:', component.get("v.selectedRTNameForContactRequest"));

            var inputVariables = [
                {
                    name : "record",
                    type : "String",
                    value : component.get("v.recordId")

                },
                {
                    name : "accountExecutive",
                    type : "String",
                    value : component.get("v.selectedAE")
                }
                ];
        // component.find('contectRequestComponnet').callFromParent(inputVariables);  
            var flow = component.find("contactRequest");
            flow.startFlow("contactRequestFlow",inputVariables);
            }
            else{
                action.setParams({
            "recordId" : accountId, 
            "selectedRT" : selectedRT,
            "selectedAE" : selectedAE,
            "isCurrentUserAE" : responseObj.isCurrentUserAE
        });
        action.setCallback(this, function( response ){
            var state = response.getState();
            if(state == "SUCCESS"){
                var data = response.getReturnValue();
                if(data.selRTName != 'Team_Member_Request'){
                    if( data.isAddressChangeRequest && !data.allowAddressRequest ){
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            type : "error",
                            duration: 10000,
                            message : "New \"Account Address/Contact Update\" request is not allowed when other is in process."
                        });
                        toastEvent.fire();
                        helper.dismissQuickActionHelper( component, event, helper );
                        return false;
                    }else{
                        var createRecordEvent = $A.get("e.force:createRecord");
                        createRecordEvent.setParams({
                            "entityApiName": "Account_Request__c",
                            "recordTypeId" : component.get("v.selectedRT"),
                            "defaultFieldValues": data.pre_populatedFields
                        });
                        createRecordEvent.fire();
                        helper.dismissQuickActionHelper( component, event, helper );
                    }
                }else{
                    component.set( "v.responseObj", data );
                    component.set( "v.selectedAEForTeamMemRecType", data.selAEId );
                }
            }
            if( state == "ERROR"){
                var errors = response.getError();
                console.log('----> Error : '+JSON.stringify( errors[0] ) );
            }
            
        });
        $A.enqueueAction( action );
            }

                
        
    },
    
    createNewAccountRequestForTeamRTHelper : function( component, event, helper ) {
        var jsAccId = component.get("v.responseObj.objAR.Advertiser_Agency_Rep_Firm__c");
        var jsSelectedRT = component.get("v.selectedRT");
        var jsStatus = component.get("v.responseObj.objAR.Status__c");
        var accExeId = component.get("v.selectedAEForTeamMemRecType");
        var jsDtComplete = component.get("v.responseObj.objAR.Date_Completed__c");
        var jsComments = component.get("v.responseObj.objAR.Comments__c");
        
        // var selectedRecordType = responseObj.lstRecordTypes.find(function(recordType) {
        //     return recordType.Id === selectedRT;
        // });

        // // Retrieve the Name property if a match is found
        // var selectedRecordTypeName = selectedRecordType ? selectedRecordType.Name : null;

        // // Now, selectedRecordTypeName contains the Name of the matching record type
        // console.log(selectedRecordTypeName);

        // if(selectedRecordTypeName === 'Audience Track Contact Request'){

        //      var inputVariables = [
        //         {
        //             name : "record",
        //             type : "String",
        //             value : component.get("v.recordId")

        //         }
        //         ];
        //     // component.set("v.openContactRequestFlow", true);
        //     var flow = component.find("contactRequest");
        //     flow.startFlow("contactRequestFlow",inputVariables);
        // }
        // else{
        //     component.set("v.openContactRequestFlow", false);
        // }


        if(accExeId == undefined && accExeId[0] == undefined)
            return false;
        component.set("v.Spinner", true); 
        var action = component.get("c.saveAccountRequest");
        action.setParams({
            "accId" : jsAccId,
            "selectedRT" : jsSelectedRT,
            "status" : jsStatus,
            "aeId" : accExeId,
            "dtComplete" : jsDtComplete,
            "comments" : jsComments
        });
        action.setCallback(this, function( response ){
            var state = response.getState();
            if(state == "SUCCESS"){
                var accreqId = response.getReturnValue();
                
                var navService = component.find("navService");
                var pageReference = {
                    type: 'standard__recordPage',
                    attributes: {
                        "recordId": accreqId,
                        "objectApiName": "Account_Request__c",
                        "actionName": "view"
                    }
                }
                event.preventDefault();
                navService.navigate(pageReference);
                
            }else if( state == "ERROR"){
                var errors = response.getError();
                let toastParams = {
                    title: "Error",
                    message: "Unknown error", // Default error message
                    type: "error"
                };
                // Pass the error message if any
                if (errors && Array.isArray(errors) && errors.length > 0) {
                    toastParams.message = errors[0].message;
                }
                // Fire error toast
                let toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams(toastParams);
                toastEvent.fire();
            }
            
        });
        component.set("v.Spinner", false); 
        $A.enqueueAction( action );
    },
    
    checkForAEInAccTeamHelper : function( component, event, helper ){
        var action = component.get("c.checkForAEInAccTeam");
        var accExeId = component.get("v.selectedAEForTeamMemRecType");
        if(accExeId[0] == undefined)
            return false;
        action.setParams({
            "aeId" : accExeId[0],
            "accId" : component.get("v.recordId")
        });
        action.setCallback(this, function( response ){ 
            var state = response.getState();
            if( state == "SUCCESS"){
                var objResData = response.getReturnValue();
                console.log(objResData);
                if(objResData.isAEExists == true){
                    
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        type : "warning",
                        duration: 10000,
                        message : objResData.errorMsg
                    });
                    toastEvent.fire();
                }
            }else if( state == "ERROR"){
                var errors = response.getError(); 
                console.log('----> Error : '+JSON.stringify( errors[0] ) );
            }
        });
        $A.enqueueAction( action );
    },
    
    SaveDataHelper : function(component, event, helper) {
        //component.find("recordEditForm").submit();
        this.createNewAccountRequestForTeamRTHelper(component, event, helper);
    },
    
    recordTypeChanged : function( component, event, helper ){
        var selectedRT = component.get("v.selectedRT");
        var responseObj = component.get("v.responseObj");
        //var isCurrentUserAE = component.get("v.isCurrentUserAE");
        console.log(' ---> selectedRT: '+selectedRT);
        console.log(' ---> switchRTID: '+responseObj.switchRTId);
        console.log(' ---> isCurrentUserAE: '+responseObj.isCurrentUserAE);
        var selectedRecordType = responseObj.lstRecordTypes.find(function(recordType) {
            return recordType.Id === selectedRT;
        });

        // Retrieve the Name property if a match is found
        var selectedRecordTypeName = selectedRecordType ? selectedRecordType.Name : null;
        // Now, selectedRecordTypeName contains the Name of the matching record type
        console.log(selectedRecordTypeName);

        if(selectedRecordTypeName == 'Team Member Request' || selectedRecordTypeName == 'Search ID Request' || responseObj.isCurrentUserAE==true){
            component.set("v.showUserAEList",false);
        }else{
            component.set("v.showUserAEList",true);
        }
        //  var selectedRecordType = responseObj.lstRecordTypes.find(function(recordType) {
        //     return recordType.Id === selectedRT;
        // });

        // // Retrieve the Name property if a match is found
        // var selectedRecordTypeName = selectedRecordType ? selectedRecordType.Name : null;
        // // Now, selectedRecordTypeName contains the Name of the matching record type
        // console.log(selectedRecordTypeName);

        

        // if(selectedRecordTypeName === 'Audience Trak Access Request'){
        //     // component.set("v.openContactRequestFlow", false);
        //     component.set("v.selectedRTNameForContactRequest",selectedRT);
        //     console.log('selectedRTNameForContactRequest:', component.get("v.selectedRTNameForContactRequest"));

        //     var inputVariables = [
        //         {
        //             name : "record",
        //             type : "String",
        //             value : component.get("v.recordId")

        //         },
        //         {
        //             name : "accountExecutive",
        //             type : "String",
        //             value : component.get("v.selectedAE")
        //         }
        //         ];
        // // component.find('contectRequestComponnet').callFromParent(inputVariables);  
        //     var flow = component.find("contactRequest");
        //     flow.startFlow("contactRequestFlow",inputVariables);
        // }else{
            // component.set("v.openContactRequestFlow", true);
            if( this.isNotBlack( selectedRT ) && !responseObj.isCurrentUserAE ){
            component.set('v.selectedAE', '');
                
            if(  selectedRT != responseObj.switchRTId && selectedRT != responseObj.teamMemberRTId ){
                //helper.getAETeamMembers( component, event, helper ); 
                var lstUser = responseObj.lstUsers;
                if( lstUser.length == 0 ){
                    component.set("v.aeAccessFailed", true);
                    component.find("btnNext").set("v.disabled", true);
                }else{
                    component.set( "v.showUserList", true );
                    component.set( "v.selectedAE", lstUser[0].Id );
                    component.find("btnNext").set("v.disabled", false);
                }
            }else if( responseObj.isUserLSM && selectedRT == responseObj.switchRTId ){
                var lstUser = responseObj.lstUsers;
                if( lstUser.length == 0 ){
                    component.set("v.aeAccessFailed", true);
                    component.find("btnNext").set("v.disabled", true);
                }else{
                    component.set( "v.showUserList", true );
                    component.set( "v.selectedAE", lstUser[0].Id );
                    component.find("btnNext").set("v.disabled", false);
                }
            }else{
                component.set("v.showUserList", false );
                component.set("v.aeAccessFailed", false);
                component.find("btnNext").set("v.disabled", false);
            }
        }
        // }

        
    },
    dismissQuickActionHelper : function( component, event, helper ) {
        $A.get("e.force:closeQuickAction").fire();
    },
    isNotBlack : function( str ){
        return str != null && str != '';
    }
})