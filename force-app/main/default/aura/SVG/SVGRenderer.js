({
	render: function(component, helper) {
		var iconSpanCmp = component.find('iconSpan');
		//grab attributes from the component markup
		var classname = component.get("v.class");
		var xlinkhref = component.get("v.xlinkHref");
		var ariaHidden = component.get("v.aria-hidden");
		var myIcon = component.get("v.myIcon");
		var iconBase = component.get("v.iconBaseType");
		var iconClass = component.get("v.iconClass");

		//return an svg element w/ the attributes
		var svg = document.createElementNS("http://www.w3.org/2000/svg", "svg");
		var iconStr;
		if (myIcon == 'contact') {
			iconStr = 'slds-icon-standard-event';	// set to the pink background of the event icon to make it more distiguishable from the purple account color
		} else if (iconClass == 'utility')  {
//			iconStr = 'slds-icon-standard-apps';
			iconStr = 'slds-icon-utility-' + myIcon;
		} else {
			iconStr = iconBase + myIcon;
		}
		svg.setAttribute('class', classname + ' ' + iconStr);
		svg.setAttribute('aria-hidden', ariaHidden);
			
			 console.log('***************************  iconStr = ' + iconStr);
			$A.util.addClass(component, iconStr);
			$A.util.addClass(iconSpanCmp, 'slds-icon_container');
			$A.util.addClass(iconSpanCmp, iconStr);
		
		xlinkhref += '/assets/icons/' + iconClass + '-sprite/svg/symbols.svg#' + myIcon;
		console.log('*********>>> xlinkhref = ' + xlinkhref);
		svg.innerHTML = '<use xlink:href="'+xlinkhref+'" xmlns:xlink="http://www.w3.org/1999/xlink"></use>';
		return svg;
	}
})