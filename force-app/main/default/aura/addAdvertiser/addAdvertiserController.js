({
 doInit : function(component, event, helper) {
    console.log('************************************************');
    console.log('SObjectName = ' + component.get("v.sObjectName"));

    var recId = component.get("v.recordId");
    console.log('recordId = ' + component.get("v.recordId"));
 //    helper.getUserId(component); 

    
    console.log('==============>> before getObjMap');
    helper.getObjMap(component);
    console.log('==============>> before getKeyMap');
    helper.getObjKeyMap(component);
   // helper.setRecTypePicklist(component);

  //   var selRecType = recType == '' ? component.get("v.defaultRecordType") : recType;
  //  component.set("v.selectedRecordType", selRecType); 

    //component.set("v.selectedRecordTypeText", component.get("v.defaultRecordTypeText"));
    /*
    var isCreateOppty = component.get("v.isCreateOppty");
    if (isCreateOppty) {
        var blankATM = {"text" : " ", "label" : " " } ;
        component.set("v.AccountTeamAEs", blankATM);
        helper.getOpptyStages(component); 
      console.log('#########--->> current href = ' + window.location.href);   
      }
*/
      if (recId !== "undefined" && recId != null) {
        helper.getAcctInfo(component, component.get("v.recordId"));
      } 

  },

})