trigger Proposal_Zone_Monthly_Value_Trigger on Proposal_Zone_Monthly_Value__c (after delete, after insert, after update, before insert, before update){
    
    if (Trigger.isInsert){
        if (Trigger.isAfter){
            Proposal_Zone_Monthly_Value_Helper.afterInsert(Trigger.New,null);
        }
        if(Trigger.isBefore){
            Proposal_Zone_Monthly_Value_Helper.beforeInsert(Trigger.New,null);
        }
    }
    
    if (Trigger.isUpdate){
        if (Trigger.isAfter){
            Proposal_Zone_Monthly_Value_Helper.afterUpdate(Trigger.New,Trigger.oldMap);
        }
        if (Trigger.IsBefore){
            Proposal_Zone_Monthly_Value_Helper.beforeUpdate(Trigger.New,Trigger.oldMap);
        }
    }
    
    if (Trigger.isDelete){
        if (Trigger.isAfter){
            Proposal_Zone_Monthly_Value_Helper.afterDelete(Trigger.OldMap);
        }
    }
    
}