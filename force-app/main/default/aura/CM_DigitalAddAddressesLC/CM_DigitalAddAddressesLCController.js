({
	doLoad : function(component, event, helper) {
        var recId = component.get("v.recordId");
        //alert(recId);
		helper.loadAddress(component,recId);
	},
    
    updateAddress : function(component, event, helper) {
        
        var lockRecord = component.get("v.lockRecord");
        if( lockRecord ) 
            return false;
        
        var recId = component.get("v.recordId");
        var street = component.get("v.Street");
        var city = component.get("v.City");
        var state = component.get("v.State");
        var zip = component.get("v.Zip");
        var type = component.get("v.Type");
        var radius = component.get("v.Radius");
        var isnone = component.get("v.isNone");
        helper.updateAddressCH(component,recId,street,city,state,zip,type,radius,isnone);
    },
    
    deleteAddress : function(component, event, helper) {
        var lockRecord = component.get("v.lockRecord");
        if( lockRecord ) 
            return false;
        var recId = component.get("v.recordId");
        var indx = event.target.id;
        helper.deleteAddressCH(component,recId,indx);
    },
    
    togleInfo : function(component, event, helper) {
        alert(1);
        console.log(component.find('help'));
        var info = component.find('help');
        $A.util.toggleClass(info,'slds-rise-from-ground')
        
        }
    }
})