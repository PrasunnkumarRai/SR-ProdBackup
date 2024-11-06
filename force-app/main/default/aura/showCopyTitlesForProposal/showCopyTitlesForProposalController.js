({
    doInit : function(component, event, helper) {
    	helper.fetchProposalList(component,helper);
        helper.fetchCopyTitlesForProposal(component,helper);        
    }
})