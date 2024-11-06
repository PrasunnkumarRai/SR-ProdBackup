({
    recordTypeHelper: function(component, event, helper) {
        var action = component.get('c.getRecordType');
        action.setParams({ "recordTypeId": component.get("v.recordTypeId__c") });

        var userId = $A.get("$SObjectType.CurrentUser.Id");
        var getUserDetail = component.get('c.getUserDetail');
        getUserDetail.setParams({ "userId": userId });

        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state == "SUCCESS") {
                var result = response.getReturnValue();
                component.set('v.recordTypeName__c', result.DeveloperName);
                component.set('v.recordTypeLabel__c', result.Name);

                getUserDetail.setCallback(this, function(callbackResponse) {
                    var resState = callbackResponse.getState();
                    if (resState == "SUCCESS") {
                        var navigateToOldAccCreation = false;
                        var userDetailResult = callbackResponse.getReturnValue();
                        var profileOldAccCreation = $A.get("$Label.c.National_Profiles").split(',');
                        if (profileOldAccCreation.includes(userDetailResult.Profile.Name)) {
                            navigateToOldAccCreation = true;
                        }
                        if (navigateToOldAccCreation == true || result.DeveloperName == 'In_House_Agency_Account' || (userDetailResult.Budget_Type__c != undefined && userDetailResult.Budget_Type__c.toUpperCase() == 'NATIONAL')) {
                            component.set('v.renderNewAccountCreation', false);
                            component.set('v.renderOldAccountCreation', true);
                            var evt = $A.get("e.force:navigateToComponent");
                            evt.setParams({
                                componentDef: "c:crossObjectlookup",
                                componentAttributes: {
                                    recordTypeId__c: component.get("v.recordTypeId__c"),
                                    recordTypeName__c: component.get("v.recordTypeLabel__c"),
                                    userType: userDetailResult.Budget_Type__c == undefined ? '' : userDetailResult.Budget_Type__c
                                }
                            });
                            evt.fire();
                        } else {
                            component.set('v.renderNewAccountCreation', true);
                            component.set('v.renderOldAccountCreation', false);
                        }
                           //SRSF-4212 start

                     var ProfilecreateREPfirmsAccount = $A.get("$Label.c.Profile").split(',');

                        if(component.get("v.recordTypeLabel__c") == 'Rep Firm' && !ProfilecreateREPfirmsAccount.includes(userDetailResult.Profile.Name) ){

                             component.set('v.renderNewAccountCreation', false);

                            component.set('v.renderOldAccountCreation', false); 

                              var toastEvent = $A.get("e.force:showToast");

                                           toastEvent.setParams({

                                           title : 'Warning',

                                           message: 'You are not the authorised user to  Create Rep Firm Account',

                                    	   duration:' 5000',

                                       	   key: 'info_alt',

                                           type: 'error',

                                            mode: 'pester'

        });

        toastEvent.fire();

                            setTimeout(function() {

        					window.open(window.location.origin + '/lightning/o/Account/list?filterName=__Recent');

        // Optionally reload the window if needed after opening

        // window.location.reload();

    }, 1000); // 5000ms = 5 seconds

                        }

                   //SRSF-4212 end
                    }
                });
            }
        });
        $A.enqueueAction(action);
        $A.enqueueAction(getUserDetail);
    },
})