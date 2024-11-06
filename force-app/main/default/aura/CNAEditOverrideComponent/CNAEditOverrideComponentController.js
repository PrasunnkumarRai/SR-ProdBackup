({
	doInit : function(component, event, helper) {
		console.log('--------->> in doInit, calling verifyAccountTeamMember');
		helper.verifyAccountTeamMember( component, event, helper );
	},

})