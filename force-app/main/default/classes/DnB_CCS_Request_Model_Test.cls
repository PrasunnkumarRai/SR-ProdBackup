@IsTest
public class DnB_CCS_Request_Model_Test {

	static testMethod void testParse() {
		String json = '{' +
		'	\"dunsList\": [\"504347444\",\"504347555\"],' +
		'	\"pageSize\": 50,' +
		'	\"pageNumber\": 1' +
		'}';
		DnB_CCS_Request_Model obj = DnB_CCS_Request_Model.parse(json);
		System.assert(obj != null);
	}
}