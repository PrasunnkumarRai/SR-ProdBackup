({
	doInit : function(component, event, helper) {
		console.log('--------->> in doInit, calling verifyOpportunityTeamMember');
		helper.verifyOpportunityTeamMember( component, event, helper );
	},

})