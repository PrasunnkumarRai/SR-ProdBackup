trigger ProposalZoneTrigger on Proposal_Zone__c (before insert, before update, after insert, after update, after delete) {
    // Added by gthathera - 11/13/2017 
	if( String.isNotBlank( System.Label.isActiveProposalZoneTrigger ) && System.Label.isActiveProposalZoneTrigger == 'true' ){
	    
	    if(Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate)){
	        Proposal_Zone_Monthly_Value_Helper.proposalZoneBeforeInsertAndUpdate(Trigger.new);
	        Proposal_Zone_Monthly_Value_Helper.populateSyscode(Trigger.new);
	    }
	    
	    if(Trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate)){
	        Proposal_Zone_Monthly_Value_Helper.updateOpportuityStage(Trigger.new, Trigger.oldMap);	        
	    }

	    if(trigger.isAfter && Trigger.isDelete)
	    {
	    	Proposal_Zone_Monthly_Value_Helper.ProposalZoneDelete(Trigger.OldMap);
	    }
	}
}