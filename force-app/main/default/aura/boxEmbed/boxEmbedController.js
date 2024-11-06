({
	doInit : function(component, event, helper) {
		var retHTML = '<iframe src="https://app.box.com/embed_widget/s/ywzxu10ah9dg0ldcek9cjql8ne2hsbs9?view=list&sort=date&direction=ASC&theme=blue" width="600" height="400" frameborder="0" allowfullscreen="webkitallowfullscreen"></iframe>';
		console.log('------------>> retHTML = ' + retHTML);
		component.set('v.boxFrame', retHTML);
		//return retHTML;
	}
})