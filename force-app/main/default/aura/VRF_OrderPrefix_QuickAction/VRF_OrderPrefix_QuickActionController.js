({
    doInit : function(component, event, helper) {
      
        helper.getUrl(component);
        
    },
    download : function(component, event, helper) {

        var url = component.get("v.OrderPrefixUrl");

        console.log('Url: ' + url);


        window.location.href = url;
        $A.get("e.force:refreshView").fire();
        $A.get("e.force:closeQuickAction").fire();
    }
})