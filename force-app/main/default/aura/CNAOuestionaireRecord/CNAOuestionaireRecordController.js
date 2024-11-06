({
doInit : function(component, event, helper) {
    var action = component.get("c.getActualCNA");
    var recId = component.get("v.recordId");
    action.setParams({
        "strCNAId" : recId,
        "recordTypeName" : "Questionnaire"
        });
     action.setCallback(this, function( response ){
            console.log('----> response.getState@@@@(): '+response.getState());
            if(response.getState()=="SUCCESS"){
               var actualId = response.getReturnValue();
               console.log("actualId" ,actualId);
               component.set("v.recId",actualId );
               console.log("recId", recId);
            }
        });
        $A.enqueueAction( action );
	}
})