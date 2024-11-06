@isTest
private class SelectItem_Test {
	static testMethod void testMEthod1() {

		SelectItem si1 = new SelectItem('1','1',true);		
		SelectItem si2 = new SelectItem('2','2');
		si1.label = si2.label;
		si1.value = si2.value;
		si1.selected = si2.selected;

	}
}