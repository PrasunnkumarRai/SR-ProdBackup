//SRSF-2552
({
    selectOptionHelper : function(component,label,isCheckPreviously) {

		var optionSelected =[];
		var allOptions = component.get('v.options');

	 if(label=="None"){
			for(var i=0;i<allOptions.length;i++){
				if(allOptions[i].label==label){
					allOptions[i].isChecked = true;
				} 
				else{
					allOptions[i].isChecked = false;
				}
				if(allOptions[i].isChecked ){				
					optionSelected.push(allOptions[i].label);
				} 
			}
         component.set("v.isAllSelected", false);
		}else if(label=="All"){
			for(var i=0;i<allOptions.length;i++){
					if(allOptions[i].label==label){
						allOptions[i].isChecked = !allOptions[i].isChecked;
					}else if(allOptions[i].label=="None"){
						allOptions[i].isChecked =  false;
					} 
					else{
						allOptions[i].isChecked =  true;
					}
					if(allOptions[i].isChecked ){				
						optionSelected.push(allOptions[i].label);
					} 
			}
            component.set("v.isAllSelected", true);
		}else{
			for(var i=0;i<allOptions.length;i++){
					if(allOptions[i].label==label){
						allOptions[i].isChecked = !allOptions[i].isChecked;
					}else if(allOptions[i].label=="None"){
						allOptions[i].isChecked = false;
					}
					if(allOptions[i].isChecked ){				
						optionSelected.push(allOptions[i].label);
					} 
			}
            component.set("v.isAllSelected", false);
		}		

        component.set("v.selectedOptions",optionSelected.join(";"));
        component.set('v.options',allOptions);
        
        var optionSelected1 =[];
		var allOptions1 = component.get('v.options');
        for(var i=0;i<allOptions1.length;i++){
            if(allOptions1[i].label=="All"){
                allOptions1[i].isChecked =  false;
            }
            if(allOptions1[i].isChecked ){				
                optionSelected1.push(allOptions1[i].label);    
            } 
        }
        component.set("v.selectedOptions",optionSelected1.join(";")); 
        component.set('v.options',allOptions1);
    },
	getOptionsHelper: function(component)
	{
		var opt = [];
        var valueFromParent = component.get("v.selectedOptions");
        console.log("valueFromParent", valueFromParent);
		var action = component.get("c.getOptions");
		action.setCallback(this, function(response) {
            var state = response.getState();
            var returnValue = response.getReturnValue();
            for(let i = 0; i < returnValue.length; i++){
                opt.push({ label: returnValue[i].label , value:returnValue[i].value, isChecked:returnValue[i].isChecked });
            } 
            component.set("v.options", opt);
            if(valueFromParent){
                var allOptions = component.get("v.options");
                for(var i=0;i<allOptions.length;i++){
                    var check = valueFromParent.includes(allOptions[i].label);
                    if(check){
                        allOptions[i].isChecked = true;
                    }
                    else{
                        allOptions[i].isChecked = false;
                    }
                    
                }
            }
        })
     $A.enqueueAction(action);
	}
    
})