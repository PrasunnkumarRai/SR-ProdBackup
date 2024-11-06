({
	handleVIPCheckBox : function(component, event, helper) {
		var VipCB = component.find("c.contactAffVIP");
		
	},

	reallyCreateContact : function(component, event, helper) {
		console.log('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  in reallyCreateContact!!!!!!!!!!!');
		helper.createContact(component, event, true);
	},

	createContact : function(component, event, helper) {
		helper.createContact(component, event, false);
	},

	hideFieldsForAE : function(component, event, helper) {
		console.log('*******************  in hideFieldsForAE!!!  ******************');
		var firstName = component.find("firstName");
		var lastName = component.find("lastName");
		var email = component.find("email");
		var aePicklist = component.find("aePicklist");
		$A.util.addClass(firstName, 'slds-hide');
		$A.util.addClass(lastName, 'slds-hide');
		$A.util.addClass(email, 'slds-hide');
		$A.util.addClass(aePicklist, 'slds-hide');

	},
})