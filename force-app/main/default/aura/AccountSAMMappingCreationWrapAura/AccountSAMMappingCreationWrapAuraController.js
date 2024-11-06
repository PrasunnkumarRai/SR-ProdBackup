({
    handleFilterChange: function (component, event) {
        window.setTimeout($A.getCallback(function () {
            window.location.reload();
        }), 2000);
    },
});

// var navService = component.find("navService");

        // var pageReference = {
        //     "type": "standard__webPage",
        //     "attributes": {
        //         "url": "https://spectrumreach--preproddev.sandbox.lightning.force.com/lightning/r/Account/0014100001ydMMJAA2/related/Account_SAM_Mappings__r/view"
        //     }
        // };

        // navService.navigate(pageReference);
        // var navEvt = $A.get("e.force:navigateToSObject");
        // navEvt.setParams({
        //     "recordId": '0014100001ydMMJAA2', //THIS IS WHERE YOUR OPPTY ID GOES
        //     "slideDevName": "related"
        // });
        // navEvt.fire();
        //setTimeout(window.location.reload(), 2000);
        //`var CloseClicked = event.getParam('close');
        //component.set('v.message', 'Close Clicked');


        // var workspaceAPI = component.find("workspace");
        // console.log('workspaceAPI:: @@@@', workspaceAPI);
        // workspaceAPI.getFocusedTabInfo().then(function (response) {
        //     var focusedTabId = response.tabId;
        //     workspaceAPI.closeTab({ tabId: focusedTabId });
        // })
        //     .catch(function (error) {
        //         console.log('AccountSAMMappingCreationAura Error:: @@@@', error);
        //     });

        // var navService = component.find("navService");

        // // Define the attributes for the navigation
        // var pageReference = {

        //     "type": "standard__webPage",
        //     "attributes": {
        //         "url": "https://spectrumreach--preproddev.sandbox.lightning.force.com/lightning/r/Account/0014100001ydMMJAA2/related/Account_SAM_Mappings__r/view"
        //     }
        // };

        // // Navigate to the related list
        // navService.navigate(pageReference);

        // var closeAction = $A.get("e.force:closeQuickAction");
        // if (closeAction) {
        //     closeAction.fire();
        // }

        //window.close();