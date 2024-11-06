//SRSF-2552
({
    doInit:function(component,event, helper){
		helper.getOptionsHelper(component);
 
        //helper.selectOptionHelper(component,label,isChecked);       
    },
    openDropdown:function(component,event,helper){
		if(!component.get('v.disabled')){
			$A.util.addClass(component.find('dropdown'),'slds-is-open');
			$A.util.removeClass(component.find('dropdown'),'slds-is-close');
		}
    },
    closeDropDown:function(component,event,helper){
        $A.util.addClass(component.find('dropdown'),'slds-is-close');
        $A.util.removeClass(component.find('dropdown'),'slds-is-open');
    },
    selectOption:function(component,event,helper){        
        var label = event.currentTarget.id.split("#BP#")[0];
        var isCheck = event.currentTarget.id.split("#BP#")[1];
        helper.selectOptionHelper(component,label,isCheck);
		var compEvent = component.getEvent("sampleComponentEvent");
        compEvent.setParams({
            "message" : component.get("v.isAllSelected")
        });
        compEvent.fire();
		//var compEvent2 = component.getEvent("sampleComponentEvent");
    }
})