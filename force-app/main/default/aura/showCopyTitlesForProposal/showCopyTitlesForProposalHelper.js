({
    fetchProposalList : function(component, event, helper) {
    	var propId = component.get('v.recordId');
    	var action = component.get('c.getProposalList');
        
        action.setParams({        	
            "proposalId" : propId
        });

        action.setCallback(this,function(a){
        	try{
        		component.set('v.proposalList', a.getReturnValue());
        	}catch(e){}
        });

        $A.enqueueAction(action);
    },
    
    fetchCopyTitlesForProposal : function(component, event, helper) {   
        var propId = component.get('v.recordId');
    	var action = component.get('c.getCopyTitlesForProposal');
        action.setParams({        	
            "proposalId" : propId
        });
        
        action.setCallback(this, function( response ){
            console.log('---->getState: '+response.getState());
            var state = response.getState();           
            if( state === "SUCCESS" ){
                console.log('response value>>>>>'+response.getReturnValue());
                var copyTitls = [];                
                if(response.getReturnValue() !=null){
                    var titles = response.getReturnValue();
                    for ( var key in titles ) {
                        console.log('key>>>>>'+key.split(':')[0]);
                        console.log('value>>>>>'+titles[key]);
                        var keySplit = key.split(':')[0];                        

                        if(keySplit == 'BookedTop'){                            
                            keySplit = 'Bookend Top';
                        } else if (keySplit == 'BookedBtm'){
                            keySplit = 'Bookend Bottom';
                        }
                       copyTitls.push({key:key, key0:keySplit, key1:key.split(':')[1], value:titles[key]});                       
                    }
                    console.log ('copyTitls>>>>'+copyTitls);
                    component.set("v.copyTitles", copyTitls);                  
                }
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) 
                    {
                        console.log("Error message: " + errors[0].message);                      
                        component.find('notifLib').showToast({
                            "variant": "error",
                            "title": "Error!",
                            "mode" : "dismissable",
                            'message': errors[0].message                      
                        });
                    }
                } else {
                    console.log("Unknown error");                  
                    component.find('notifLib').showToast({
                        "variant": "error",
                        "title": "Error!",
                        "mode" : "dismissable",
                        'message': "Unknown error"
                    });
                }
            } 
            else {
                console.log('Unknown problem, state: ' + response.getState() + ', error: ' + response.getError());
            	component.find('notifLib').showToast({
                    "variant": "error",
                    "title": "Error!",
                    "mode" : "dismissable",
                    'message': response.getError()
                });
            }
        });
        $A.enqueueAction( action );
    }
})