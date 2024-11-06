({    
    showToastMsg : function(component,title,type,msg)
    {
        var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": title,
                "type" : type,
                "mode" : "dismissible",
                "duration" : 5000,
                "message": msg
            });
        toastEvent.fire();        
    }    
})